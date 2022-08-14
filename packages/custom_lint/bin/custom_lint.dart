import 'dart:async';
import 'dart:io';

import 'package:analyzer_plugin/protocol/protocol_generated.dart';
import 'package:custom_lint/src/analyzer_plugin/analyzer_plugin.dart';
import 'package:custom_lint/src/analyzer_plugin/plugin_delegate.dart';
import 'package:custom_lint/src/runner.dart';
import 'package:path/path.dart' as p;

Future<int> main() async {
  var code = 0;

  await runZonedGuarded(() async {
    final runner = CustomLintRunner(
      CustomLintPlugin(
        delegate: CommandCustomLintDelegate(),
        includeBuiltInLints: false,
      ),
      Directory.current,
    );

    runner.channel
      ..responseErrors.listen((event) => code = -1)
      ..pluginErrors.listen((event) => code = -1);

    try {
      await runner.initialize();
      final lints = await runner.getLints();

      lints
          .sort((a, b) => a.relativeFilePath().compareTo(b.relativeFilePath()));

      for (final lintsForFile in lints) {
        final relativeFilePath = lintsForFile.relativeFilePath();

        lintsForFile.errors.sort((a, b) {
          final lineCompare =
              a.location.startLine.compareTo(b.location.startLine);
          if (lineCompare != 0) return lineCompare;
          final columnCompare =
              a.location.startColumn.compareTo(b.location.startColumn);
          if (columnCompare != 0) return columnCompare;

          final codeCompare = a.code.compareTo(b.code);
          if (codeCompare != 0) return codeCompare;

          return a.message.compareTo(b.message);
        });

        for (final lint in lintsForFile.errors) {
          code = -1;
          stdout.writeln(
            '  $relativeFilePath:${lint.location.startLine}:${lint.location.startColumn}'
            ' • ${lint.message} • ${lint.code}',
          );
        }
      }
    } finally {
      await runner.close();
    }
  }, (err, stack) {
    code = -1;
    stderr.writeln('$err\n$stack');
  });

  // Since no problem happened, we print a message saying everything went well
  if (code == 0) {
    stdout.writeln('No issues found!');
  }

  exit(code);
}

extension on AnalysisErrorsParams {
  String relativeFilePath() {
    return p.relative(
      file,
      from: Directory.current.path,
    );
  }
}
