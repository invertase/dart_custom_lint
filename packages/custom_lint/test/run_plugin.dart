import 'dart:async';
import 'dart:io';

import 'package:analyzer_plugin/protocol/protocol_generated.dart';
import 'package:custom_lint/src/plugin_delegate.dart';
import 'package:custom_lint/src/runner.dart';
import 'package:custom_lint/src/server_isolate_channel.dart';
import 'package:custom_lint/src/v2/custom_lint_analyzer_plugin.dart';
import 'package:custom_lint/src/workspace.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

Future<List<AnalysisErrorsParams>> runServerInCliModeForApp(
  Directory directory,

  // to ignoreErrors as we cannot explicitly handle errors
) async {
  final runner = await startRunnerForApp(directory, includeBuiltInLints: false);
  return runner.runner.getLints(reload: false);
}

class ManualRunner {
  ManualRunner(this.runner, this.channel);

  final CustomLintRunner runner;
  final ServerIsolateChannel channel;

  Future<void> get initialize => runner.initialize;

  Future<List<AnalysisErrorsParams>> getLints({required bool reload}) async {
    return runner.getLints(reload: reload);
  }

  Future<EditGetFixesResult> getFixes(
    String path,
    int offset,
  ) async {
    return runner.getFixes(path, offset);
  }

  Future<void> close() async {
    await runner.close();
    await channel.close();
  }
}

Future<ManualRunner> startRunnerForApp(
  Directory directory, {
  bool ignoreErrors = false,
  bool includeBuiltInLints = true,
  bool watchMode = false,
  bool fix = false,
}) async {
  final zone = Zone.current;
  final channel = ServerIsolateChannel();

  final customLintServer = await CustomLintServer.start(
    sendPort: channel.receivePort.sendPort,
    workingDirectory: directory,
    fix: fix,
    delegate: CommandCustomLintDelegate(),
    includeBuiltInLints: includeBuiltInLints,
    watchMode: watchMode,
  );

  return CustomLintServer.runZoned(() => customLintServer, () async {
    final workspace = await CustomLintWorkspace.fromPaths(
      [directory.path],
      workingDirectory: directory,
    );
    final runner = CustomLintRunner(customLintServer, workspace, channel);
    addTearDown(runner.close);

    if (!ignoreErrors) {
      runner.channel
        ..responseErrors.listen((event) {
          zone.handleUncaughtError(
            TestFailure(
              '${event.message} ${event.code}\n${event.stackTrace}',
            ),
            StackTrace.current,
          );
        })
        ..pluginErrors.listen((event) {
          zone.handleUncaughtError(
            TestFailure('${event.message}\n${event.stackTrace}'),
            StackTrace.current,
          );
        });
    }

    unawaited(runner.initialize);

    return ManualRunner(runner, channel);
  });
}

extension LogFile on Directory {
  File get log {
    return File(p.join(path, 'custom_lint.log'));
  }
}
