import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:analyzer_plugin/protocol/protocol.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';
import 'package:async/async.dart';
import 'package:meta/meta.dart';
import 'package:package_config/package_config.dart';
import 'package:path/path.dart';
import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

import '../channels.dart';
import '../plugin.dart';
import 'custom_lint_analyzer_plugin.dart';
import 'protocol.dart';

extension on Pubspec {
  Dependency? getDependency(String name) {
    return dependencies[name] ??
        devDependencies[name] ??
        dependencyOverrides[name];
  }
}

extension on Package {
  bool get isGitDependency => root.path.contains('/.pub-cache/git/');

  bool get isHostedDependency => root.path.contains('/.pub-cache/hosted/');

  String buildConflictingMessage(Pubspec pubspec) {
    final versionString = _buildVersionString(pubspec);
    return '- $name $versionString';
  }

  String _buildVersionString(Pubspec pubspec) {
    if (isGitDependency) {
      return _buildGitPackageVersion(pubspec);
    } else if (isHostedDependency) {
      return _buildHostedPackageVersion();
    } else {
      return _buildPathDependency();
    }
  }

  String _buildHostedPackageVersion() {
    final segments = root.pathSegments;
    final version = segments[segments.length - 2].split('-').last;
    return 'v$version';
  }

  String _buildPathDependency() {
    return 'from path ${root.path}';
  }

  String _buildGitPackageVersion(Pubspec pubspec) {
    final dependency = pubspec.getDependency(name);

    // We might not be able to find a dependency if the package is a transitive dependency
    if (dependency == null || dependency is! GitDependency) {
      final version = root.path.split('/git/').last.replaceFirst('$name-', '');
      // We're not able to find the dependency, so we'll just return
      // the version from the path, which is not ideal, but better than nothing
      return 'from git $version';
    }
    final versionBuilder = StringBuffer();
    versionBuilder.write('from git url ${dependency.url}');
    final dependencyRef = dependency.ref;
    if (dependencyRef != null) {
      versionBuilder.write(' ref $dependencyRef');
    }
    final dependencyPath = dependency.path;
    if (dependencyPath != null) {
      versionBuilder.write(' path $dependencyPath');
    }

    return versionBuilder.toString();
  }
}

/// A class that checks if there are conflicting packages in the context roots.
@internal
class ConflictingPackagesChecker {
  final _contextRootPackagesMap = <ContextRoot, List<Package>>{};
  final _contextRootPubspecMap = <ContextRoot, Pubspec>{};

  /// Adds a [contextRoot] and its [packages] to the checker.
  /// We need to pass the [pubspec] to check if the package is a git dependency
  /// and to check if the context root is a flutter package.
  void addContextRoot(
    ContextRoot contextRoot,
    List<Package> packages,
    Pubspec pubspec,
  ) {
    _contextRootPackagesMap[contextRoot] = packages;
    _contextRootPubspecMap[contextRoot] = pubspec;
  }

  /// Throws an error if there are conflicting packages.
  void throwErrorIfConflictingPackages() {
    final packageNameRootMap = <String, Set<Uri>>{};
    // Group packages by name and collect all unique roots,
    // since we're using a set
    for (final packages in _contextRootPackagesMap.values) {
      for (final package in packages) {
        final rootSet = packageNameRootMap[package.name] ?? {};
        packageNameRootMap[package.name] = rootSet..add(package.root);
      }
    }
    // Find packages with more than one root
    final packagesWithConflictingVersions = packageNameRootMap.entries
        .where((entry) => entry.value.length > 1)
        .map((e) => e.key)
        .toList();

    // If there are no conflicting versions, return
    if (packagesWithConflictingVersions.isEmpty) return;

    final contextRootConflictingPackages =
        _contextRootPackagesMap.map((contextRoot, packages) {
      final conflictingPackages = packages.where(
        (package) => packagesWithConflictingVersions.contains(package.name),
      );
      return MapEntry(contextRoot, conflictingPackages);
    });

    final errorMessageBuilder = StringBuffer();

    errorMessageBuilder
      ..writeln('Some dependencies with conflicting versions were identified:')
      ..writeln();

    // Build conflicting packages message
    for (final entry in contextRootConflictingPackages.entries) {
      final contextRoot = entry.key;
      final conflictingPackages = entry.value;
      final pubspec = _contextRootPubspecMap[contextRoot]!;
      final locationName = pubspec.name;
      errorMessageBuilder.writeln('$locationName at ${contextRoot.root}');
      for (final package in conflictingPackages) {
        errorMessageBuilder.writeln(package.buildConflictingMessage(pubspec));
      }
      errorMessageBuilder.writeln();
    }

    errorMessageBuilder
      ..writeln(
        'This is not supported. Custom_lint shares the analysis between all'
        ' packages. As such, all plugins are started under a single process,'
        ' sharing the dependencies of all the packages that use custom_lint. '
        "Since there's a single process for all plugins, if 2 plugins try to"
        ' use different versions for a dependency, the process cannot be '
        'reasonably started. Please make sure all packages have the same version.',
      )
      ..writeln('You could run the following commands to try fixing this:')
      ..writeln();

    // Build fix commands
    for (final entry in contextRootConflictingPackages.entries) {
      final contextRoot = entry.key;
      final pubspec = _contextRootPubspecMap[contextRoot]!;
      final isFlutter = pubspec.dependencies.containsKey('flutter');
      final command = isFlutter ? 'flutter' : 'dart';

      final conflictingPackages = entry.value;
      final conflictingPackagesNames =
          conflictingPackages.map((package) => package.name).join(' ');
      errorMessageBuilder
        ..writeln('cd ${contextRoot.root}')
        ..writeln('$command pub upgrade $conflictingPackagesNames');
    }

    throw StateError(errorMessageBuilder.toString());
  }
}

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
  final conflictingPackagesChecker = ConflictingPackagesChecker();
  for (final contextRoot in contextRoots) {
    final contextRootPackageConfigUri = Uri.file(
      join(contextRoot.root, '.dart_tool', 'package_config.json'),
    );
    final packageConfigFile = File.fromUri(contextRootPackageConfigUri);
    final contextRootPubspecFile = File(
      join(contextRoot.root, 'pubspec.yaml'),
    );

    String packageConfigContent;
    try {
      packageConfigContent = packageConfigFile.readAsStringSync();
    } on FileSystemException {
      throw StateError(
        'No package_config.json found. Did you forget to run `pub get`?\n'
        'Tried to look in:\n${contextRoots.map((e) => '- ${e.root}\n').join()}',
      );
    }
    final packageConfig = PackageConfig.parseString(
      packageConfigContent,
      contextRootPackageConfigUri,
    );

    final pubspecContent = contextRootPubspecFile.readAsStringSync();
    final pubspec = Pubspec.parse(
      pubspecContent,
      sourceUrl: contextRootPubspecFile.uri,
    );
    final validPackages = [
      for (final package in packageConfig.packages)
        // Don't include the project that has a plugin enabled in the list
        // of dependencies of the plugin.
        // This avoids the plugin from being hot-reloaded when the analyzed
        // code changes.
        if (package.name != pubspec.name) package
    ];

    // Add the contextRoot and its packages to the conflicting packages checker
    conflictingPackagesChecker.addContextRoot(
      contextRoot,
      validPackages,
      pubspec,
    );

    for (final package in validPackages) {
      packageMap[package.name] = package;
    }
  }

  // Check if there are conflicting packages
  conflictingPackagesChecker.throwErrorIfConflictingPackages();

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

class _SocketCustomLintServerToClientChannel
    implements CustomLintServerToClientChannel {
  _SocketCustomLintServerToClientChannel(
    this._server,
    this._version,
    this._contextRoots,
  )   : _packages = getPackageListForContextRoots(_contextRoots.roots),
        _serverSocket = _createServerSocket() {
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
  final List<Package> _packages;
  final Directory _tempDirectory = Directory.systemTemp.createTempSync();
  final Future<ServerSocket> _serverSocket;
  late final Future<JsonSocketChannel?> _socket;

  AnalysisSetContextRootsParams _contextRoots;
  final _process = Completer<Process>();

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

  void _writeEntrypoint() {
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

    final mainFile =
        File(join(_tempDirectory.path, 'lib', 'custom_lint_client.dart'));
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
    watchMode: ${_server.watchMode},
    includeBuiltInLints: ${_server.includeBuiltInLints},
    {$plugins},
  );
}
''');
  }

  void _writePubspec() {
    final dependencies =
        _packages.map((package) => '  ${package.name}: any').join();

    final pubspecFile = File(join(_tempDirectory.path, 'pubspec.yaml'));
    pubspecFile.createSync(recursive: true);
    pubspecFile.writeAsStringSync('''
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
    _writeEntrypoint();

    late int port;
    final processFuture = _asyncRetry(retryCount: 5, () async {
      port = await _findPossiblyUnusedPort();
      final process = await Process.start(
        Platform.resolvedExecutable,
        [
          '--enable-vm-service=$port',
          join('lib', 'custom_lint_client.dart'),
          await _serverSocket.then((value) => value.port.toString())
        ],
        workingDirectory: _tempDirectory.path,
      );
      return process;
    });

    await processFuture.then(
      _process.complete,
      onError: _process.completeError,
    );
    final process = await processFuture;

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
      sendAnalyzerPluginRequest(_contextRoots.toRequest(const Uuid().v4()))
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

          final processStderr =
              await process.stderr.transform(utf8.decoder).join();
          final errorMessage = 'Failed to start plugins\n$processStderr';

          _server.delegate.pluginInitializationFail(
            _server,
            errorMessage,
            allContextRoots: _contextRoots.roots,
          );

          _server.analyzerPluginClientChannel.sendJson(
            PluginErrorParams(true, errorMessage, '').toNotification().toJson(),
          );

          throw StateError(errorMessage);
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
  void close();
}
