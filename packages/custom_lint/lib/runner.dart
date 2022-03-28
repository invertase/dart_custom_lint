import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:analyzer/dart/analysis/context_locator.dart';
import 'package:analyzer_plugin/protocol/protocol.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';
// ignore: implementation_imports
import 'package:analyzer_plugin/src/protocol/protocol_internal.dart'
    show RequestParams;
import 'package:cli_util/cli_util.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import 'protocol.dart';
import 'src/analyzer_plugin/isolate_channel.dart';
import 'src/analyzer_plugin/my_server_plugin.dart';
import 'src/analyzer_utils/analyzer_utils.dart';

const _uuid = Uuid();
const _pluginName = 'custom_lint';
const _analyzerPluginProtocolVersion = '1.0.0-alpha.0';

/// A runner for programmatically interact with a plugin.
class CustomLintRunner {
  /// Creates a runner from a [ServerPlugin].
  CustomLintRunner(this._server) {
    _server.start(_channel);
  }

  final ServerPlugin _server;

  late final _receivePort = ReceivePort();
  late final PluginIsolateChannel _channel =
      PluginIsolateChannel(_receivePort.sendPort);
  late final Stream<Object?> _events = _receivePort.asBroadcastStream();
  late final Future<SendPort> _sendPort =
      _events.first.then((value) => value! as SendPort);

  late final _resourceProvider = _server.resourceProvider;
  late final _sdkPath = getSdkPath();

  late final _contextLocator =
      ContextLocator(resourceProvider: _resourceProvider);
  late final _allContextRoots = _contextLocator.locateRoots(
    includedPaths: [Directory.current.path],
  );

  late final _contextRoots = _allContextRoots
      .where(
        (contextRoot) =>
            File(p.join(contextRoot.root.path, 'pubspec.yaml')).existsSync(),
      )
      .toList();

  late final _foldersToAnalyze = _contextRoots
      .expand((contextRoot) => [
            p.join(contextRoot.root.path, 'lib'),
            p.join(contextRoot.root.path, 'test'),
          ])
      .where((dir) => Directory(dir).existsSync())
      .toList();

  late final _dartFilesToAnalyze = _foldersToAnalyze
      .expand((folder) =>
          Directory(folder).listSync(recursive: true, followLinks: false))
      .whereType<File>()
      .where((file) => p.extension(file.path) == '.dart')
      .map((file) => file.path)
      .toList();

  /// The [Notification]s emitted by the plugin
  late final Stream<Notification> notifications = _events
      .where((e) => e is Map)
      .map((e) => e! as Map)
      .where((e) => e.containsKey(Notification.EVENT))
      .map(Notification.fromJson);

  /// The [Response]s emitted by the plugin
  late final Stream<Response> responses = _events
      .where((event) => event is Map<String, Object?>)
      .map((event) => event! as Map<String, Object?>)
      .where((e) => e.containsKey(Response.ID))
      .map(Response.fromJson);

  /// Error [Notification]s.
  late final Stream<PluginErrorParams> pluginErrors = notifications
      .where((e) => e.event == 'plugin.error')
      .map(PluginErrorParams.fromNotification);

  /// Errors for [Request]s that failed.
  late final Stream<RequestError> responseErrors =
      responses.where((e) => e.error != null).map((e) => e.error!);

  /// Sends a [GetAnalysisErrorParams] request to the plugin and obtains the
  /// [GetAnalysisErrorResult] response.
  Future<GetAnalysisErrorResult> _sendGetAnalysisErrorRequest(
    GetAnalysisErrorParams parameters,
  ) async {
    final response = await sendRequest(parameters);
    return GetAnalysisErrorResult.fromResponse(response);
  }

  /// Starts the plugin and send the necessary requests for initializing it.
  Future<void> initialize() async {
    await sendRequest(
      PluginVersionCheckParams(
        _resourceProvider.getByteStorePath(_pluginName),
        _sdkPath,
        _analyzerPluginProtocolVersion,
      ),
    );
    await sendRequest(
      AnalysisSetContextRootsParams([
        for (final contextRoot in _contextRoots)
          ContextRoot(
            contextRoot.root.path,
            contextRoot.excludedPaths.toList(),
            optionsFile: contextRoot.optionsFile?.path,
          ),
      ]),
    );
  }

  /// Obtains the list of lints for the current workspace
  Future<List<AnalysisErrorsParams>> getLints() async {
    final response = await _sendGetAnalysisErrorRequest(
      GetAnalysisErrorParams(_dartFilesToAnalyze),
    );
    return response.lints;
  }

  /// Send a [Request] to the plugin and return the [Response].
  Future<Response> sendRequest(RequestParams params) async {
    final id = _uuid.v4();

    final response = responses.firstWhere((e) => e.id == id);
    await _sendJson(params.toRequest(id).toJson());
    return response;
  }

  Future<void> _sendJson(Map<String, Object?> json) {
    return _sendPort.then((value) => value.send(json));
  }

  /// Stop the command runner, sending a [PluginShutdownParams] request in the process.
  Future<void> close() async {
    try {
      await sendRequest(PluginShutdownParams());
    } finally {
      _channel.close();
      _receivePort.close();
    }
  }
}
