import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:analyzer_plugin/protocol/protocol.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';
import 'package:async/async.dart';
import 'package:path/path.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

import '../channels.dart';
import '../workspace.dart';
import 'custom_lint_analyzer_plugin.dart';
import 'protocol.dart';

Future<int> _findPossiblyUnusedPort() {
  return _SocketCustomLintServerToClientChannel._createServerSocket()
      .then((value) => value.port);
}

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

class _SocketCustomLintServerToClientChannel
    implements CustomLintServerToClientChannel {
  _SocketCustomLintServerToClientChannel(
    this._server,
    this._version,
    this._contextRoots,
  ) : _serverSocket = _createServerSocket() {
    _socket = _serverSocket.then(
      (server) async {
        // ignore: close_sinks
        final socket = await server.firstOrNull;
        if (socket == null) return null;
        return JsonSocketChannel(socket);
      },
    );
  }

  final CustomLintServer _server;
  final PluginVersionCheckParams _version;
  late final Directory _tempDirectory;
  final Future<ServerSocket> _serverSocket;
  late final Future<JsonSocketChannel?> _socket;
  late final Future<Process> _processFuture;

  AnalysisSetContextRootsParams _contextRoots;

  late final Stream<CustomLintMessage> _messages = Stream.fromFuture(_socket)
      .whereNotNull()
      .asyncExpand((e) => e.messages)
      .map((e) => e! as Map<String, Object?>)
      .map(CustomLintMessage.fromJson)
      .asBroadcastStream();

  late final Stream<CustomLintResponse> _responses = _messages
      .where((msg) => msg is CustomLintMessageResponse)
      .cast<CustomLintMessageResponse>()
      .map((e) => e.response);

  @override
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

  @override
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
  Future<Process> _startProcess() async {
    final workspace = await CustomLintWorkspace.fromContextRoots(
      _contextRoots.roots.map((e) => e.root).toList(),
    );

    _tempDirectory = await workspace.createPluginHostDirectory();
    _writeEntrypoint(workspace.uniquePluginNames);

    return _asyncRetry(retryCount: 5, () async {
      // Using "late" to fetch the port only if needed (in watch mode)
      late final port = _findPossiblyUnusedPort();
      final process = await Process.start(
        Platform.resolvedExecutable,
        [
          if (_server.watchMode) '--enable-vm-service=${await port}',
          join('lib', 'custom_lint_client.dart'),
          await _serverSocket.then((value) => value.port.toString())
        ],
        workingDirectory: _tempDirectory.path,
      );
      return process;
    });
  }

  void _writeEntrypoint(Iterable<String> pluginNames) {
    final imports = pluginNames
        .map((name) => "import 'package:$name/$name.dart' as $name;\n")
        .join();

    final plugins = pluginNames
        .map((pluginName) => "'$pluginName': $pluginName.createPlugin,\n")
        .join();

    final mainFile = File(
      join(_tempDirectory.path, 'lib', 'custom_lint_client.dart'),
    );
    mainFile.createSync(recursive: true);
    mainFile.writeAsStringSync('''
import 'dart:convert';
import 'dart:io';
import 'package:custom_lint_builder/src/channel.dart';
$imports

void main(List<String> args) async {
  final port = int.parse(args.single);

  runSocket(
    port: port,
    includeBuiltInLints: ${_server.includeBuiltInLints},
    {$plugins},
  );
}
''');
  }

  @override
  Future<void> init() async {
    _processFuture = _startProcess();
    final process = await _processFuture;

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

  Future<void> _checkInitializationFail(Process process) async {
    var running = true;
    try {
      return await Future.any<void>([
        _socket,
        process.exitCode.then((exitCode) async {
          // A socket was returned before the exitCode was obtained.
          // As such, the process correctly started
          if (!running) return;

          _server.delegate.pluginInitializationFail(
            _server,
            'Failed to start plugins',
            allContextRoots: _contextRoots.roots,
          );

          _server.analyzerPluginClientChannel.sendJson(
            PluginErrorParams(true, 'Failed to start plugins', '')
                .toNotification()
                .toJson(),
          );

          throw StateError('Failed to start the plugins.');
        }),
      ]);
    } finally {
      running = false;
    }
  }

  @override
  Future<void> close() async {
    await Future.wait([
      _tempDirectory.delete(recursive: true),
      _serverSocket.then((value) => value.close()),
      _processFuture.then(
        (value) => value.kill(),
        // The process wasn't started. No need to do anything.
        onError: (_) {},
      ),
    ]);
  }

  @override
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

  @override
  Future<CustomLintResponse> sendCustomLintRequest(
    CustomLintRequest request,
  ) async {
    final matchingResponse = _responses.firstWhere((e) => e.id == request.id);

    await _socket.then((socket) {
      if (socket == null) {
        throw StateError('Client disconnected, cannot send requests');
      }
      socket.sendJson(request.toJson());
    });

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
    return 'A request throw the exception:$message\n$stackTrace';
  }
}

/// custom_lint's analyzer_plugin -> custom_lint's plugin host
abstract class CustomLintServerToClientChannel {
  /// Starts a custom_lint client, in charge of running all plugins.
  factory CustomLintServerToClientChannel.spawn(
    CustomLintServer server,
    PluginVersionCheckParams version,
    AnalysisSetContextRootsParams contextRoots,
  ) = _SocketCustomLintServerToClientChannel;

  /// The events sent by the client.
  Stream<CustomLintEvent> get events;

  /// Initializes and waits for the client to start
  Future<void> init();

  /// Updates the context roots on the client
  Future<AnalysisSetContextRootsResult> setContextRoots(
    AnalysisSetContextRootsParams contextRoots,
  );

  /// Sends a custom_lint request to the client, expecting a custom_lint response
  Future<CustomLintResponse> sendCustomLintRequest(CustomLintRequest request);

  /// Sends a request based on the analyzer_plugin protocol, expecting
  /// an analyzer_plugin response.
  Future<Response> sendAnalyzerPluginRequest(Request request);

  /// Stops the client, liberating the resources.
  Future<void> close();
}
