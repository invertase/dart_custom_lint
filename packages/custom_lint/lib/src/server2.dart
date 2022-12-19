// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'dart:isolate';
// import 'dart:typed_data';

// import 'package:analyzer_plugin/protocol/protocol.dart';
// import 'package:analyzer_plugin/protocol/protocol_generated.dart';
// import 'package:package_config/package_config.dart';
// import 'package:path/path.dart';
// import 'package:pub_semver/pub_semver.dart';
// import 'package:riverpod/riverpod.dart';

// import 'analyzer_plugin/plugin_delegate.dart';
// import 'analyzer_plugin/plugin_link.dart';
// import 'analyzer_plugin_isolate_channel.dart';
// import 'custom_lint_plugin_channel.dart';

// class CustomLintServer {
//   CustomLintServer({
//     required this.delegate,
//     required this.includeBuiltInLints,
//     required this.watchMode,
//     required this.analyzerPluginChannel,
//   }) {
//     _channelSubscription = analyzerPluginChannel.listenRequests(
//       handlePluginShutdown: _handlePluginShutdown,
//       handlePluginVersionCheck: _handlePluginVersionCheck,
//       handleAnalysisSetContextRoots: _handleAnalysisSetContextRoots,
//       orElse: _handleUnknownRequest,
//     );
//   }

//   final CustomLintDelegate delegate;
//   final bool includeBuiltInLints;
//   final bool watchMode;
//   final AnalyzerPluginIsolateChannel analyzerPluginChannel;

//   late final StreamSubscription<void> _channelSubscription;
//   final _versionCheck = Completer<PluginVersionCheckParams>();
//   // final _customLintPluginChannel = Completer<CustomLintPluginChannel>();

//   Future<ServerSocket>? _serverSocket;
//   Directory? _temporaryDirectory;
//   AnalysisSetContextRootsParams? _params;
//   Future<Process>? _process;

//   /// An error was detected. This will redirect it to a log file.
//   void handleUncaughtError(Object error, StackTrace stackTrace) {
//     final roots = _params;
//     if (roots == null) return;
//     for (final root in roots.roots) {
//       final logFile = File(join(root.root, 'custom_lint.log'));
//       logFile.writeAsStringSync('$error\n$stackTrace\n', mode: FileMode.append);
//     }
//   }

//   /// A print was detected. This will redirect it to a log file.
//   void handlePrint(String message) {
//     final roots = _params;
//     if (roots == null) return;
//     for (final root in roots.roots) {
//       final logFile = File(join(root.root, 'custom_lint.log'));
//       logFile.writeAsStringSync('$message\n', mode: FileMode.append);
//     }
//   }

//   Future<void> _handlePluginShutdown() async {
//     // TODO send shutdown to process
//     print('showDown');

//     // The channel will be automatically closed on shutdown.
//     // Closing it manually would prevent the follow-up logic to send a
//     // response to the shutdown request.

//     await Future.wait([
//       _channelSubscription.cancel(),
//       if (_temporaryDirectory != null) _temporaryDirectory!.delete(),
//       if (_serverSocket != null) _serverSocket!.then((value) => value.close()),
//       if (_process != null) _process!.then((value) => value.kill()),
//     ]);
//   }

//   FutureOr<Response?> _handleUnknownRequest(Request request, int requestTime) {}

//   FutureOr<PluginVersionCheckResult> _handlePluginVersionCheck(
//     PluginVersionCheckParams parameters,
//   ) {
//     // The even should be sent only once. Plugins don't handle multiple
//     // version check.
//     // So we let "complete" throw by not checking "isCompleted".
//     _versionCheck.complete(parameters);

//     final versionString = parameters.version;
//     final serverVersion = Version.parse(versionString);
//     final clientVersion = Version.parse('1.0.0-alpha.0');

//     return PluginVersionCheckResult(
//       serverVersion <= clientVersion,
//       'custom_lint',
//       clientVersion.toString(),
//       ['*.dart'],
//       contactInfo: 'https://github.com/invertase/dart_custom_lint/issues',
//     );
//   }

//   FutureOr<AnalysisSetContextRootsResult> _handleAnalysisSetContextRoots(
//     AnalysisSetContextRootsParams parameters,
//   ) async {
//     await _maybeSpawnCustomLintPlugin(parameters);

//     return AnalysisSetContextRootsResult();
//   }

//   Future<void> _maybeSpawnCustomLintPlugin(
//     AnalysisSetContextRootsParams parameters,
//   ) async {
//     _params = parameters;
//     if (_customLintPluginChannel.isCompleted) {
//       // If the completer is already completed, it means a plugin was already spawned.
//       final channel = await _customLintPluginChannel.future;
//       await channel.setContextRoots(parameters);
//       return;
//     }

//     final serverSocket = _serverSocket = _createServerSocket();
//     print('Server socket started at ${(await serverSocket).port}');

//     final s = await serverSocket;
//     s.listen((socket) {
//       print('Client connected: ${socket.port}');
//       socket.add(utf8.encode('Hello from server'));

//       socket.map(utf8.decode).listen((event) {
//         print('Got message from client: $event');
//       });
//     });

//     final temporaryDirectory =
//         _temporaryDirectory = Directory.systemTemp.createTempSync();

//     final packageConfigUri = _writePackageConfigForTempProject(
//       temporaryDirectory,
//       parameters.roots,
//     );

//     final container = ProviderContainer();
//     container.read(activeContextRootsProvider.notifier).state =
//         parameters.roots;
//     final keysSub = container.listen(
//       allPluginLinkKeysProvider,
//       (previous, next) {},
//     );

//     final packageNames = keysSub
//         .read()
//         .map((e) => container.read(pluginMetaProvider(e)).name)
//         .toList();

//     final imports = packageNames
//         .map(
//           (packageName) =>
//               "import 'package:$packageName/$packageName.dart' as $packageName;\n",
//         )
//         .join();

//     final plugins = packageNames
//         .map((packageName) => '$packageName.createPlugin,\n')
//         .join();

//     container.dispose();

//     final mainFile = File(join(temporaryDirectory.path, 'lib', 'main.dart'));
//     mainFile.createSync(recursive: true);
//     mainFile.writeAsStringSync('''
// import 'dart:convert';
// import 'dart:io';
// import 'package:custom_lint_builder/src/channel.dart';
// $imports

// void main(List<String> args) async {
//   final port = int.parse(args.single);

//   runSocket([$plugins], port);
// }
// ''');

//     _process = Process.start(
//       'dart',
//       [
//         // '--enable-vm-service',
//         join('lib', 'main.dart'),
//         await serverSocket.then((value) => value.port.toString())
//       ],
//       workingDirectory: temporaryDirectory.path,
//     );

//     final process = await _process!;

//     process.stdout.map(utf8.decode).listen((event) {
//       print('Client log: $event');
//     });
//     process.stderr.map(utf8.decode).listen((event) {
//       print('Client err: $event');
//     });

//     final channel = CustomLintPluginIsolateChannel(
//       contextRoots: parameters,
//       versionCheckParams: await _versionCheck.future,
//     );
//     _customLintPluginChannel.complete(channel);
//     await channel.start();
//   }
// }

// /// Generate a package_config.json combining all the dependencies from all
// /// the contextRoots.
// ///
// /// This also changes relative paths into absolute paths.
// Uri _writePackageConfigForTempProject(
//   Directory tempDirectory,
//   List<ContextRoot> contextRoots,
// ) {
//   final targetFile = File(
//     join(tempDirectory.path, '.dart_tool', 'package_config.json'),
//   );

//   final packageMap = <String, Package>{};
//   for (final contextRoot in contextRoots) {
//     final uri = Uri.file(
//       join(contextRoot.root, '.dart_tool', 'package_config.json'),
//     );
//     final file = File.fromUri(uri);

//     String content;
//     try {
//       content = file.readAsStringSync();
//     } on FileSystemException {
//       throw StateError(
//         'No package_config.json found. Did you forget to run `pub get`?\n'
//         'Tried to look in:\n${contextRoots.map((e) => '- ${e.root}\n').join()}',
//       );
//     }

//     final packageConfig = PackageConfig.parseString(content, uri);

//     for (final package in packageConfig.packages) {
//       final currentPackage = packageMap[package.name];

//       if (currentPackage != null && currentPackage.root != package.root) {
//         throw StateError(
//           '''
// Two ContextRoots depend on ${package.name} but use different version,
// therefore custom_lint does not know which one to pick.
// - ${package.root}
// - ${currentPackage.root}
// ''',
//         );
//       }

//       packageMap[package.name] = package;
//     }
//   }

//   targetFile.createSync(recursive: true);

//   targetFile.writeAsStringSync(
//     jsonEncode(<String, Object?>{
//       'configVersion': 2,
//       'generated': '2022-12-08T08:06:29.988146Z',
//       'generator': 'pub',
//       'generatorVersion': '2.19.0-467.0.dev',
//       'packages': <Object?>[
//         for (final package in packageMap.values)
//           <String, String>{
//             'name': package.name,
//             // This is somehow enough to change relative paths into absolute ones.
//             // It seems that PackageConfig.parse already converts the paths into
//             // absolute ones.
//             'rootUri': package.root.toString(),
//             'packageUri': package.packageUriRoot.toString(),
//             'languageVersion': package.languageVersion.toString(),
//             'extraData': package.extraData.toString(),
//           }
//       ],
//     }),
//   );

//   return targetFile.uri;
// }

// Future<ServerSocket> _createServerSocket() async {
//   try {
//     return await ServerSocket.bind(InternetAddress.loopbackIPv6, 0);
//   } on SocketException {
//     return ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
//   }
// }
