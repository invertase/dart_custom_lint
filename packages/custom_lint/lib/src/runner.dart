import 'dart:async';

import 'package:analyzer_plugin/protocol/protocol_generated.dart';
import 'package:cli_util/cli_util.dart';

import 'server_isolate_channel.dart';
import 'v2/custom_lint_analyzer_plugin.dart';
import 'workspace.dart';

const _analyzerPluginProtocolVersion = '1.0.0-alpha.0';

/// A runner for programmatically interacting with a plugin.
class CustomLintRunner {
  /// A runner for programmatically interacting with a plugin.
  CustomLintRunner(this._server, this.workspace, this.channel);

  /// The custom_lint project that is being run.
  final CustomLintWorkspace workspace;

  /// The connection between the server and the plugin.
  final ServerIsolateChannel channel;
  final CustomLintServer _server;
  final _accumulatedLints = <String, AnalysisErrorsParams>{};
  StreamSubscription<void>? _lintSubscription;

  var _closed = false;

  /// Starts the plugin and sends the necessary requests for initializing it.
  late final initialize = Future(() async {
    _lintSubscription = channel.lints.listen((event) {
      _accumulatedLints[event.file] = event;
    });

    await channel.sendRequest(
      PluginVersionCheckParams(
        '',
        sdkPath,
        _analyzerPluginProtocolVersion,
      ),
    );
    await channel.sendRequest(
      AnalysisSetContextRootsParams(workspace.contextRoots),
    );
  });

  /// Obtains the list of lints for the current workspace.
  Future<List<AnalysisErrorsParams>> getLints({required bool reload}) async {
    if (reload) _accumulatedLints.clear();

    await _server.awaitAnalysisDone(reload: reload);

    return _accumulatedLints.values.toList()
      ..sort((a, b) => a.file.compareTo(b.file));
  }

  /// Obtains the list of fixes for a given file/offset combo
  Future<EditGetFixesResult> getFixes(
    String path,
    int offset,
  ) async {
    final result = await channel.sendRequest(
      EditGetFixesParams(path, offset),
    );
    return EditGetFixesResult.fromResponse(result);
  }

  /// Stop the command runner, sending a [PluginShutdownParams] request in the process.
  Future<void> close() async {
    if (_closed) return;
    _closed = true;

    try {
      await channel.sendRequest(PluginShutdownParams());
    } finally {
      await _lintSubscription?.cancel();
    }
  }
}
