import 'dart:async';
import 'dart:io';

import 'package:analyzer_plugin/protocol/protocol_generated.dart';
import 'package:custom_lint/src/plugin_delegate.dart';
import 'package:custom_lint/src/runner.dart';
import 'package:custom_lint/src/server_isolate_channel.dart';
import 'package:custom_lint/src/v2/custom_lint_analyzer_plugin.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

Future<List<AnalysisErrorsParams>> runServerInCliModeForApp(
  Directory directory,
  // to ignoreErrors as we cannot explictly handle errors
) async {
  final runner = startRunnerForApp(directory, includeBuiltInLints: false);
  return runner.getLints(reload: false);
}

CustomLintRunner startRunnerForApp(
  Directory directory, {
  bool ignoreErrors = false,
  bool includeBuiltInLints = true,
}) {
  final channel = ServerIsolateChannel();

  // TODO use IO override to mock & test stdout/stderr
  return CustomLintServer.run(
    sendPort: channel.receivePort.sendPort,
    delegate: CommandCustomLintDelegate(),
    includeBuiltInLints: includeBuiltInLints,
    watchMode: false,
    (customLintServer) {
      final runner = CustomLintRunner(customLintServer, directory, channel);
      addTearDown(runner.close);

      if (!ignoreErrors) {
        runner.channel
          ..responseErrors.listen((event) {
            fail('${event.message} ${event.code}\n${event.stackTrace}');
          })
          ..pluginErrors.listen((event) {
            fail('${event.message}\n${event.stackTrace}');
          });
      }

      unawaited(runner.initialize);

      return runner;
    },
  )!;
}

extension LogFile on Directory {
  File get log {
    return File(p.join(path, 'custom_lint.log'));
  }
}
