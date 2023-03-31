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
  return runner.getLints(reload: false);
}

Future<CustomLintRunner> startRunnerForApp(
  Directory directory, {
  bool ignoreErrors = false,
  bool includeBuiltInLints = true,
  bool watchMode = false,
}) async {
  final zone = Zone.current;
  final channel = ServerIsolateChannel();

  // TODO use IO override to mock & test stdout/stderr
  try {
    return await CustomLintServer.run(
      sendPort: channel.receivePort.sendPort,
      workingDirectory: directory,
      delegate: CommandCustomLintDelegate(),
      includeBuiltInLints: includeBuiltInLints,
      watchMode: watchMode,
      (customLintServer) async {
        Zone.root.print('Run');
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

        return runner;
      },
    );
  } finally {
    Zone.root.print('did run');
  }
}

extension LogFile on Directory {
  File get log {
    return File(p.join(path, 'custom_lint.log'));
  }
}
