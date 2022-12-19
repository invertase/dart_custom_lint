import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:analyzer/dart/analysis/context_locator.dart';
import 'package:analyzer/file_system/overlay_file_system.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';
import 'package:cli_util/cli_util.dart';
import 'package:path/path.dart' as p;

import 'analyzer_utils/analyzer_utils.dart';
import 'server_isolate_channel.dart';
import 'v2/custom_lint_analyzer_plugin.dart';

const _pluginName = 'custom_lint';
const _analyzerPluginProtocolVersion = '1.0.0-alpha.0';

/// A runner for programmatically interacting with a plugin.
class CustomLintRunner {
  /// A runner for programmatically interacting with a plugin.
  CustomLintRunner(this._server, this.workingDirectory)
      : channel = ServerIsolateChannel();

  SendPort get sendPort => channel.receivePort.sendPort;

  /// The directory in which this command is exected in.
  final Directory workingDirectory;

  /// The connection between the server and the plugin.
  final ServerIsolateChannel channel;
  final CustomLintServer _server;

  var _closed = false;

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
      await _server.awaitAnalysisDone();
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
      channel.close();
    }
  }
}
