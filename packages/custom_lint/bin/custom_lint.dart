import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:analyzer/dart/analysis/context_locator.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:analyzer_plugin/protocol/protocol.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';
import 'package:analyzer_plugin/src/protocol/protocol_internal.dart'
    show RequestParams;
import 'package:cli_util/cli_util.dart';
import 'package:custom_lint/protocol.dart';
import 'package:custom_lint/src/analyzer_plugin/analyzer_plugin.dart';
import 'package:custom_lint/src/analyzer_plugin/isolate_channel.dart';
import 'package:custom_lint/src/analyzer_plugin/my_server_plugin.dart';
import 'package:custom_lint/src/analyzer_utils/analyzer_utils.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

const pluginName = 'custom_lint';

const analyzerPluginProtocolVersion = '1.0.0-alpha.0';

Future<void> main() async {
  await runZonedGuarded(() async {
    final tester = testPlugin(CustomLintPlugin());

    try {
      final resourceProvider = PhysicalResourceProvider.INSTANCE;
      final sdkPath = getSdkPath();

      await tester.sendRequest(
        PluginVersionCheckParams(
          resourceProvider.getByteStorePath(pluginName),
          sdkPath,
          analyzerPluginProtocolVersion,
        ),
      );

      final contextLocator = ContextLocator(resourceProvider: resourceProvider);
      final allContextRoots = contextLocator.locateRoots(
        includedPaths: [Directory.current.path],
      );

      final contextRoots = allContextRoots
          .where(
            (contextRoot) => File(p.join(contextRoot.root.path, 'pubspec.yaml'))
                .existsSync(),
          )
          .toList();

      final foldersToAnalyze = contextRoots
          .expand((contextRoot) => [
                p.join(contextRoot.root.path, 'lib'),
                p.join(contextRoot.root.path, 'test'),
              ])
          .where((dir) => Directory(dir).existsSync())
          .toList();

      final dartFilesToAnalyze = foldersToAnalyze
          .expand((folder) =>
              Directory(folder).listSync(recursive: true, followLinks: false))
          .whereType<File>()
          .where((file) => p.extension(file.path) == '.dart')
          .map((file) => file.path)
          .toList();

      await tester.sendRequest(
        AnalysisSetContextRootsParams([
          for (final contextRoot in contextRoots)
            ContextRoot(
              contextRoot.root.path,
              contextRoot.excludedPaths.toList(),
              optionsFile: contextRoot.optionsFile?.path,
            ),
        ]),
      );

// TODO do we need to send priority files request?

      final lintsResponse = await tester.getLints(dartFilesToAnalyze);

      for (final lintsForFile in lintsResponse.lints) {
        final relativeFilePath = p.relative(lintsForFile.file);
        for (final lint in lintsForFile.errors) {
          print(
            '  $relativeFilePath • ${lint.message} • ${lint.code}',
          );
        }
      }

      // TODO set exit code
    } finally {
      await tester.close();
    }
  }, (err, stack) {
    print('Hey $err\n$stack');
  });
}

PluginResult testPlugin(MyServerPlugin server) {
  final receivePort = ReceivePort();
  final channel = PluginIsolateChannel(receivePort.sendPort);

  server.start(channel);

  final Stream<Object?> receiveStream = receivePort.asBroadcastStream();

  return PluginResult._(
    receiveStream,
    receiveStream.first.then((value) => value! as SendPort),
    receivePort.close,
  );
}

class PluginResult {
  PluginResult._(
    this._events,
    this._sendPort,
    this._close,
  );

  final void Function() _close;
  final Future<SendPort> _sendPort;
  final Stream<Object?> _events;

  late final Stream<Notification> notifications = _events
      .where((e) => e is Map)
      .map((e) => e! as Map)
      .map(Notification.fromJson);

  Future<GetAnalysisErrorResult> getLints(List<String> files) async {
    final response = await sendRequest(GetAnalysisErrorParams(files));
    return GetAnalysisErrorResult.fromResponse(response);
  }

  Future<Response> sendRequest(RequestParams params) async {
    final id = _uuid.v4();

    final response = _events
        .where((event) => event is Map<String, Object?>)
        .map((event) => event! as Map<String, Object?>)
        .firstWhere((message) => message['id'] == id);

    await _sendJson(params.toRequest(id).toJson());
    return Response.fromJson(await response);
  }

  Future<void> _sendJson(Map<String, Object?> json) {
    return _sendPort.then((value) => value.send(json));
  }

  Future<void> close() async {
    try {
      // We actively don't care about the response since the connection
      // will be closed before we get one.
      await _sendJson(
        PluginShutdownParams().toRequest(_uuid.v4()).toJson(),
      );
    } finally {
      _close();
    }
  }
}
