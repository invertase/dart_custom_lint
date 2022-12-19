import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:analyzer_plugin/protocol/protocol.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';
import 'package:package_config/package_config.dart';
import 'package:path/path.dart';
import 'package:riverpod/riverpod.dart';
import 'package:uuid/uuid.dart';

import '../analyzer_plugin/plugin_link.dart';
import '../channels.dart';
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

/// Generate a package_config.json combining all the dependencies from all
/// the contextRoots.
///
/// This also changes relative paths into absolute paths.
void _writePackageConfigForTempProject(
  Directory tempDirectory,
  List<ContextRoot> contextRoots,
) {
  final targetFile = File(
    join(tempDirectory.path, '.dart_tool', 'package_config.json'),
  );

  final packageMap = <String, Package>{};
  for (final contextRoot in contextRoots) {
    final uri = Uri.file(
      join(contextRoot.root, '.dart_tool', 'package_config.json'),
    );
    final file = File.fromUri(uri);

    String content;
    try {
      content = file.readAsStringSync();
    } on FileSystemException {
      throw StateError(
        'No package_config.json found. Did you forget to run `pub get`?\n'
        'Tried to look in:\n${contextRoots.map((e) => '- ${e.root}\n').join()}',
      );
    }

    final packageConfig = PackageConfig.parseString(content, uri);

    for (final package in packageConfig.packages) {
      final currentPackage = packageMap[package.name];

      if (currentPackage != null && currentPackage.root != package.root) {
        throw StateError(
          '''
Two ContextRoots depend on ${package.name} but use different version,
therefore custom_lint does not know which one to pick.
- ${package.root}
- ${currentPackage.root}
''',
        );
      }

      packageMap[package.name] = package;
    }
  }

  targetFile.createSync(recursive: true);

  targetFile.writeAsStringSync(
    jsonEncode(<String, Object?>{
      'configVersion': 2,
      'generated': DateTime.now().toIso8601String(),
      'generator': 'custom_lint',
      'generatorVersion': '0.0.1',
      'packages': <Object?>[
        for (final package in packageMap.values)
          <String, String>{
            'name': package.name,
            // This is somehow enough to change relative paths into absolute ones.
            // It seems that PackageConfig.parse already converts the paths into
            // absolute ones.
            'rootUri': package.root.toString(),
            'packageUri': package.packageUriRoot.toString(),
            'languageVersion': package.languageVersion.toString(),
            'extraData': package.extraData.toString(),
          }
      ],
    }),
  );
}

List<Package> _getPackageListForContextRoots(List<ContextRoot> contextRoots) {
  final container = ProviderContainer();
  try {
    container.read(activeContextRootsProvider.notifier).state = contextRoots;

    final keysSub = container.listen(
      allPluginLinkKeysProvider,
      (previous, next) {},
    );

    return keysSub
        .read()
        .map((e) => container.read(pluginMetaProvider(e)))
        .toList();
  } finally {
    container.dispose();
  }
}

class _SocketCustomLintServerToClientChannel
    implements CustomLintServerToClientChannel {
  _SocketCustomLintServerToClientChannel(
    this._version,
    this._contextRoots,
  )   : _packages = _getPackageListForContextRoots(_contextRoots.roots),
        _serverSocket = _createServerSocket() {
    _socket = _serverSocket.then(
      (server) async => JsonSocketChannel(await server.first),
    );
  }

  final PluginVersionCheckParams _version;
  final List<Package> _packages;
  final Directory _tempDirectory = Directory.systemTemp.createTempSync();
  final Future<ServerSocket> _serverSocket;
  late final Future<JsonSocketChannel> _socket;

  AnalysisSetContextRootsParams _contextRoots;
  final _process = Completer<Process>();

  late final Stream<CustomLintMessage> _messages = Stream.fromFuture(_socket)
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

  void _writeMain() {
    final imports = _packages
        .map((e) => e.name)
        .map(
          (packageName) =>
              "import 'package:$packageName/$packageName.dart' as $packageName;\n",
        )
        .join();

    final plugins = _packages
        .map((e) => e.name)
        .map((packageName) => "'$packageName': $packageName.createPlugin,\n")
        .join();

    final mainFile = File(join(_tempDirectory.path, 'lib', 'main.dart'));
    mainFile.createSync(recursive: true);
    mainFile.writeAsStringSync('''
import 'dart:convert';
import 'dart:io';
import 'package:custom_lint_builder/src/v2/channel.dart';
$imports

void main(List<String> args) async {
  final port = int.parse(args.single);

  runSocket({$plugins}, port);
}
''');
  }

  void _writePubspec() {
    final dependencies =
        _packages.map((package) => '  ${package.name}: any').join();

    final mainFile = File(join(_tempDirectory.path, 'pubspec.yaml'));
    mainFile.createSync(recursive: true);
    mainFile.writeAsStringSync('''
name: custom_lint_client
version: 0.0.1
publish_to: 'none'

environment:
  sdk: '>=2.17.1 <3.0.0'

dependencies:
$dependencies
''');
  }

  @override
  Future<void> init() async {
    _writePackageConfigForTempProject(
      _tempDirectory,
      _contextRoots.roots,
    );
    _writePubspec();
    _writeMain();

    final processFuture = _asyncRetry(retryCount: 5, () async {
      final unusedPort = await _findPossiblyUnusedPort();
      return Process.start(
        'dart',
        [
          '--enable-vm-service=$unusedPort',
          join('lib', 'main.dart'),
          await _serverSocket.then((value) => value.port.toString())
        ],
        workingDirectory: _tempDirectory.path,
      );
    });

    await processFuture.then(
      _process.complete,
      onError: _process.completeError,
    );
    // TODO pipe process stdout/stderr to the log file

    await Future.wait([
      sendAnalyzerPluginRequest(_version.toRequest(const Uuid().v4())),
      sendAnalyzerPluginRequest(_contextRoots.toRequest(const Uuid().v4())),
    ]);
  }

  @override
  Future<void> close() async {
    await Future.wait([
      _tempDirectory.delete(recursive: true),
      _serverSocket.then((value) => value.close()),
      _process.future.then((value) => value.kill()),
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

    await _socket.then(
      (socket) => socket.sendJson(request.toJson()),
    );

    final response = await matchingResponse;

    response.map(
      awaitAnalysisDone: (_) {},
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

class CustomLintRequestFailure implements Exception {
  CustomLintRequestFailure({
    required this.message,
    required this.stackTrace,
    required this.request,
  });

  final String message;
  final String? stackTrace;
  final CustomLintRequest request;

  @override
  String toString() {
    return 'A request throw the exception:$message\n$stackTrace';
  }
}

/// custom_lint's analyzer_plugin -> custom_lint's plugin host
abstract class CustomLintServerToClientChannel {
  factory CustomLintServerToClientChannel.spawn(
    PluginVersionCheckParams version,
    AnalysisSetContextRootsParams contextRoots,
  ) = _SocketCustomLintServerToClientChannel;

  // factory CustomLintServerToClientChannel.fromIsolate(SendPort sendPort) {
  //   throw UnimplementedError();
  // }

  // factory CustomLintServerToClientChannel.fromSocket(Socket socket) {
  //   throw UnimplementedError();
  // }

  Stream<CustomLintEvent> get events;

  Future<void> init();

  Future<AnalysisSetContextRootsResult> setContextRoots(
    AnalysisSetContextRootsParams contextRoots,
  );

  Future<CustomLintResponse> sendCustomLintRequest(CustomLintRequest request);

  Future<Response> sendAnalyzerPluginRequest(Request request);

  void close();
}
