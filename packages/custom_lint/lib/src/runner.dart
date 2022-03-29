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

import '../protocol.dart';
import 'analyzer_plugin/client_isolate_channel.dart';
import 'analyzer_plugin/my_server_plugin.dart';
import 'analyzer_plugin/server_isolate_channel.dart';
import 'analyzer_utils/analyzer_utils.dart';

const _uuid = Uuid();
const _pluginName = 'custom_lint';
const _analyzerPluginProtocolVersion = '1.0.0-alpha.0';

/// A runner for programmatically interact with a plugin.
class CustomLintRunner {
  /// Creates a runner from a [ServerPlugin].
  CustomLintRunner(this._server, this._workingDirectory) {
    _server.start(_clientChannel);
  }

  final ServerPlugin _server;
  final Directory _workingDirectory;

  late final _receivePort = ReceivePort();
  late final _clientChannel = ClientIsolateChannel(_receivePort.sendPort);

  /// The connection between the server and pluginsÌ
  late final channel = ServerIsolateChannel(_receivePort);

  late final _resourceProvider = _server.resourceProvider;
  late final _sdkPath = getSdkPath();

  late final _contextLocator =
      ContextLocator(resourceProvider: _resourceProvider);
  late final _allContextRoots = _contextLocator.locateRoots(
    includedPaths: [_workingDirectory.path],
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

  /// Sends a [GetAnalysisErrorParams] request to the plugin and obtains the
  /// [GetAnalysisErrorResult] response.
  Future<GetAnalysisErrorResult> _sendGetAnalysisErrorRequest(
    GetAnalysisErrorParams parameters,
  ) async {
    final response = await channel.sendRequest(parameters);
    return GetAnalysisErrorResult.fromResponse(response)
      // Sort lints based on file path
      ..lints.sort((a, b) => a.file.compareTo(b.file));
  }

  /// Starts the plugin and send the necessary requests for initializing it.
  Future<void> initialize() async {
    await channel.sendRequest(
      PluginVersionCheckParams(
        _resourceProvider.getByteStorePath(_pluginName),
        _sdkPath,
        _analyzerPluginProtocolVersion,
      ),
    );
    await channel.sendRequest(
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

  /// Stop the command runner, sending a [PluginShutdownParams] request in the process.
  Future<void> close() async {
    try {
      // Voluntarily don't await for the response because the connection may
      // get closed before response is received
      await channel.sendJson(
        PluginShutdownParams().toRequest(_uuid.v4()).toJson(),
      );
    } finally {
      _clientChannel.close();
      _receivePort.close();
    }
  }
}
