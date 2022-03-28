import 'dart:async';
import 'dart:io';

import 'package:custom_lint/runner.dart';
import 'package:custom_lint/src/analyzer_plugin/analyzer_plugin.dart';
import 'package:path/path.dart' as p;

const pluginName = 'custom_lint';

const analyzerPluginProtocolVersion = '1.0.0-alpha.0';

Future<void> main() async {
  await runZonedGuarded(() async {
    final runner = CustomLintRunner(CustomLintPlugin());

    runner
      ..responseErrors.listen((event) {
        exitCode = -1;
        stdout.writeln('${event.message} ${event.code}\n${event.stackTrace}');
      })
      ..pluginErrors.listen((event) {
        exitCode = -1;
        stdout.writeln('${event.message}\n${event.stackTrace}');
      });

    try {
      await runner.initialize();
      final lints = await runner.getLints();

      for (final lintsForFile in lints) {
        final relativeFilePath = p.relative(lintsForFile.file);
        for (final lint in lintsForFile.errors) {
          stdout.writeln(
            '  $relativeFilePath • ${lint.message} • ${lint.code} • ${lint.location.file}',
          );
        }
      }
    } finally {
      await runner.close();
    }
  }, (err, stack) {
    exitCode = -1;
    stdout.writeln('$err\n$stack');
  });
}
