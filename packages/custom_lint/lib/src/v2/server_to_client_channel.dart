import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:analyzer_plugin/protocol/protocol.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';

import '../async_operation.dart';
import '../channels.dart';
import '../workspace.dart';
import 'custom_lint_analyzer_plugin.dart';
import 'protocol.dart';

Future<T> _asyncRetry<T>(
  Future<T> Function() cb, {
  required int retryCount,
}) async {
  var i = 0;
  while (true) {
    i++;
    try {
      return await cb();
    } catch (error, stackTrace) {
      // Logging the error
      Zone.current.handleUncaughtError(error, stackTrace);
      // If out of retry, stop
      if (i >= retryCount) rethrow;
    }
  }
}

/// An interface for communicating with the plugins over a [Socket].
class SocketCustomLintServerToClientChannel {
  SocketCustomLintServerToClientChannel._(
    this._server,
    this._serverSocket,
    this._socket,
    this._version,
    this._contextRoots,
    this._workspace,
  ) : _channel = JsonSocketChannel(_socket);

  /// Starts a server socket and exposes a way to communicate with potential clients.
  ///
  /// Returns `null` if the workspace has no plugins enabled.
  static Future<SocketCustomLintServerToClientChannel?> create(
    CustomLintServer server,
    PluginVersionCheckParams version,
    AnalysisSetContextRootsParams contextRoots, {
    required Directory workingDirectory,
  }) async {
    final workspace = await CustomLintWorkspace.fromContextRoots(
      contextRoots.roots,
      workingDirectory: workingDirectory,
    );
    if (workspace.uniquePluginNames.isEmpty) return null;

    final serverSocket = await _createServerSocket();

    return SocketCustomLintServerToClientChannel._(
      server,
      serverSocket,
      // Voluntarily thow if no client connected
      serverSocket.safeFirst,
      version,
      contextRoots,
      workspace,
    );
  }

  Directory? _tempDirectory;

  final Future<Socket> _socket;
  final JsonSocketChannel _channel;
  final CustomLintServer _server;
  final PluginVersionCheckParams _version;
  final ServerSocket _serverSocket;
  late final Future<Process?> _processFuture;
  final CustomLintWorkspace _workspace;

  AnalysisSetContextRootsParams _contextRoots;

  late final Stream<CustomLintMessage> _messages = _channel.messages
      .map((e) => e! as Map<String, Object?>)
      .map(CustomLintMessage.fromJson);

  late final Stream<CustomLintResponse> _responses = _messages
      .where((msg) => msg is CustomLintMessageResponse)
      .cast<CustomLintMessageResponse>()
      .map((e) => e.response);

  /// The events sent by the client.
  late final Stream<CustomLintEvent> events = _messages
      .where((msg) => msg is CustomLintMessageEvent)
      .cast<CustomLintMessageEvent>()
      .map((eventMsg) => eventMsg.event);

  static Future<ServerSocket> _createServerSocket() async {
    try {
      return await ServerSocket.bind(InternetAddress.loopbackIPv6, 0);
    } on SocketException {
      return ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    }
  }

  /// Initializes and waits for the client to start
  Future<void> init() async {
    _processFuture = _startProcess();
    final process = await _processFuture;
    // No process started, likely because no plugin were detected. We can stop here.
    if (process == null) return;

    var out = process.stdout.map(utf8.decode);
    // Let's not log the VM service prints unless in watch mode
    if (!_server.watchMode) {
      out = out.skipWhile(
        (element) =>
            element.startsWith('The Dart VM service is listening on') ||
            element.startsWith(
              'The Dart DevTools debugger and profiler is available at:',
            ),
      );
    }

    out.listen((event) => _server.handlePrint(event, isClientMessage: true));
    process.stderr
        .map(utf8.decode)
        .listen((e) => _server.handleUncaughtError(e, StackTrace.empty));

    // Checking process failure _after_ piping stdout/stderr to the log files.
    // This is so that if client failed to boot, logs in it should still be available
    await _checkInitializationFail(process);

    await Future.wait([
      sendAnalyzerPluginRequest(_version.toRequest(const Uuid().v4())),
      sendAnalyzerPluginRequest(_contextRoots.toRequest(const Uuid().v4())),
    ]);
  }

  /// Updates the context roots on the client
  Future<AnalysisSetContextRootsResult> setContextRoots(
    AnalysisSetContextRootsParams contextRoots,
  ) {
    _contextRoots = contextRoots;
    // TODO: implement setContextRoots
    throw UnimplementedError();
  }

  /// Encapsulates all the logic for initializing the process,
  /// without setting up the connection.
  ///
  /// Will throw if the process fails to start.
  Future<Process?> _startProcess() async {
    final tempDir = _tempDirectory =
        Directory.systemTemp.createTempSync('custom_lint_client');

    try {
      await _workspace.resolvePluginHost(tempDir);
      _writeEntrypoint(_workspace.uniquePluginNames, tempDir);

      return _asyncRetry(retryCount: 5, () async {
        final process = await Process.start(
          Platform.resolvedExecutable,
          [
            if (_server.watchMode) '--enable-vm-service=0',
            join('lib', 'custom_lint_client.dart'),
            _serverSocket.address.host,
            _serverSocket.port.toString(),
          ],
          workingDirectory: tempDir.path,
        );
        return process;
      });
    } catch (_) {
      // If the process failed to start, we can delete the temp directory
      await _tempDirectory?.delete(recursive: true);
      rethrow;
    }
  }

  void _writeEntrypoint(
    Iterable<String> pluginNames,
    Directory tempDirectory,
  ) {
    final imports = pluginNames
        .map((name) => "import 'package:$name/$name.dart' as $name;\n")
        .join();

    final plugins = pluginNames
        .map((pluginName) => "'$pluginName': $pluginName.createPlugin,\n")
        .join();

    final mainFile = File(
      join(tempDirectory.path, 'lib', 'custom_lint_client.dart'),
    );
    mainFile.createSync(recursive: true);
    mainFile.writeAsStringSync('''
import 'dart:convert';
import 'dart:io';
import 'package:custom_lint_builder/src/channel.dart';
$imports

void main(List<String> args) async {
  final host = args[0];
  final port = int.parse(args[1]);

  runSocket(
    port: port,
    host: host,
    fix: ${_server.fix},
    includeBuiltInLints: ${_server.includeBuiltInLints},
    {$plugins},
  );
}
''');
  }

  Future<void> _checkInitializationFail(Process process) async {
    var running = true;
    try {
      return await Future.any<void>([
        _socket,
        process.exitCode.then((exitCode) async {
          // A socket was returned before the exitCode was obtained.
          // As such, the process correctly started
          if (!running) return;

          await _server.handlePluginInitializationFail();

          throw StateError('Failed to start the plugins.');
        }),
      ]);
    } finally {
      running = false;
    }
  }

  /// Sends a request based on the analyzer_plugin protocol, expecting
  /// an analyzer_plugin response.
  Future<Response> sendAnalyzerPluginRequest(Request request) async {
    final response = await sendCustomLintRequest(
      CustomLintRequest.analyzerPluginRequest(request, id: request.id),
    );

    return response.maybeMap<Response>(
      analyzerPluginResponse: (r) => r.response,
      orElse: () => throw UnsupportedError(
        'Expected a CustomLintResponse.analyzerPluginResponse '
        'but received ${response.runtimeType}.',
      ),
    );
  }

  /// Sends a custom_lint request to the client, expecting a custom_lint response
  Future<CustomLintResponse> sendCustomLintRequest(
    CustomLintRequest request,
  ) async {
    final matchingResponse = _responses.firstWhere((e) => e.id == request.id);

    await _channel.sendJson(request.toJson());

    final response = await matchingResponse;

    response.map(
      awaitAnalysisDone: (_) {},
      pong: (_) {},
      analyzerPluginResponse: (response) {
        final error = response.response.error;
        if (error != null) {
          throw CustomLintRequestFailure(
            message: error.message,
            stackTrace: error.stackTrace,
            request: request,
          );
        }
      },
      error: (response) {
        throw CustomLintRequestFailure(
          message: response.message,
          stackTrace: response.stackTrace,
          request: request,
        );
      },
    );

    return response;
  }

  /// Stops the client, liberating the resources.
  Future<void> close() async {
    // TODO send shutdown request

    await Future.wait([
      if (_tempDirectory != null) _tempDirectory!.delete(recursive: true),
      _socket.then((value) => value.close()),
      _serverSocket.close(),
      _channel.close(),
      _processFuture.then<void>(
        (value) => value?.kill(),
        // The process wasn't started. No need to do anything.
        onError: (_) {},
      ),
    ]);
  }
}

/// A custom_lint request failed
class CustomLintRequestFailure implements Exception {
  /// A custom_lint request failed
  CustomLintRequestFailure({
    required this.message,
    required this.stackTrace,
    required this.request,
  });

  /// The error message
  final String message;

  /// The stacktrace of the error
  final String? stackTrace;

  /// The request that failed.
  final CustomLintRequest request;

  @override
  String toString() {
    return 'A request threw the exception:$message\n$stackTrace';
  }
}
