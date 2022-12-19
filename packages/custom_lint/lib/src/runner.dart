import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:analyzer/dart/analysis/context_locator.dart';
import 'package:analyzer/file_system/overlay_file_system.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';
import 'package:cli_util/cli_util.dart';
import 'package:path/path.dart' as p;

import 'analyzer_plugin/client_isolate_channel.dart';
import 'analyzer_plugin/server_isolate_channel.dart';
import 'analyzer_plugin/server_plugin.dart';
import 'analyzer_utils/analyzer_utils.dart';
import 'protocol/internal_protocol.dart';

const _pluginName = 'custom_lint';
const _analyzerPluginProtocolVersion = '1.0.0-alpha.0';

/// A runner for programmatically interacting with a plugin.
class CustomLintRunner {
  /// Creates a runner from a [ServerPlugin].
  CustomLintRunner(this._server, this.workingDirectory) {
    _server.start(_clientChannel);
  }

  final ServerPlugin _server;

  /// The directory in which this command is exected in.
  final Directory workingDirectory;

  var _closed = false;

  late final _receivePort = ReceivePort();
  late final _clientChannel = ClientIsolateChannel(_receivePort.sendPort);

  /// The connection between the server and the plugin.
  late final channel = ServerIsolateChannel(_receivePort);

  late final _resourceProvider = OverlayResourceProvider(
    PhysicalResourceProvider.INSTANCE,
  );

  late final _sdkPath = getSdkPath();

  late final _contextLocator =
      ContextLocator(resourceProvider: _resourceProvider);
  late final _allContextRoots = _contextLocator.locateRoots(
    includedPaths: [workingDirectory.path],
  );

  late final _contextRoots = _allContextRoots
      .where(
        (contextRoot) =>
            File(p.join(contextRoot.root.path, 'pubspec.yaml')).existsSync(),
      )
      .toList();

  /// Starts the plugin and sends the necessary requests for initializing it.
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

  /// Obtains the list of lints for the current workspace.
  Future<List<AnalysisErrorsParams>> getLints({
    required bool reload,
  }) async {
    final result = <String, AnalysisErrorsParams>{};

    StreamSubscription<void>? sub;
    try {
      sub = channel.lints.listen((event) => result[event.file] = event);
      await channel.sendRequest(AwaitAnalysisDoneParams(reload: reload));
      return result.values.toList()..sort((a, b) => a.file.compareTo(b.file));
    } finally {
      await sub?.cancel();
    }
  }

  /// Stop the command runner, sending a [PluginShutdownParams] request in the process.
  Future<void> close() async {
    if (_closed) return;
    _closed = true;

    try {
      await channel.sendRequest(PluginShutdownParams());
    } finally {
      _clientChannel.close();
      _receivePort.close();
    }
  }
}
