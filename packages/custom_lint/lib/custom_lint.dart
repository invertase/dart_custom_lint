import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';
import 'package:collection/collection.dart';
import 'package:path/path.dart' as p;

import 'src/plugin_delegate.dart';
import 'src/runner.dart';
import 'src/server_isolate_channel.dart';
import 'src/v2/custom_lint_analyzer_plugin.dart';

const _help = '''

Custom lint runner commands:
r: Force re-lint
q: Quit

''';

/// Runs plugins with custom_lint.dart on the given directory
///
/// In watch mode:
/// * This will run until the user types q to quit
/// * The plugin will hot-reload when the user changes it's code, and will cause a re-lint
/// * The exit code is the one from the last lint before quitting
/// * The user can force a reload by typing r
///
/// Otherwise:
/// * There is no hot-reload or watching so linting only happens once
/// * The process exits with the most recent result of the linter
///
/// Watch mode cannot be enabled if in release mode.
Future<void> customLint({
  bool watchMode = true,
  bool fatalInfos = false,
  bool fatalWarnings = true,
  required Directory workingDirectory,
}) async {
  // Reset the code
  exitCode = 0;

  final channel = ServerIsolateChannel();
  await CustomLintServer.run(
    sendPort: channel.receivePort.sendPort,
    watchMode: watchMode,
    // In the CLI, only show user defined lints. Errors & logs will be
    // rendered separately
    includeBuiltInLints: false,
    delegate: CommandCustomLintDelegate(),
    (customLintServer) async {
      final runner =
          CustomLintRunner(customLintServer, workingDirectory, channel);
      try {
        await runner.initialize;
        await _runPlugins(
          runner,
          reload: false,
          fatalInfos: fatalInfos,
          fatalWarnings: fatalWarnings,
        );

        if (watchMode) {
          await _startWatchMode(
            runner,
            fatalInfos: fatalInfos,
            fatalWarnings: fatalWarnings,
          );
        }
      } catch (err) {
        exitCode = 1;
      } finally {
        await runner.close();
      }
    },
  );
}

Future<void> _runPlugins(
  CustomLintRunner runner, {
  required bool reload,
  required bool fatalInfos,
  required bool fatalWarnings,
}) async {
  try {
    final lints = await runner.getLints(reload: reload);
    _renderLints(
      lints,
      workingDirectory: runner.workingDirectory,
      fatalInfos: fatalInfos,
      fatalWarnings: fatalWarnings,
    );
  } catch (err, stack) {
    exitCode = 1;
    stderr.writeln('$err\n$stack');
  }
}

void _renderLints(
  List<AnalysisErrorsParams> lints, {
  required Directory workingDirectory,
  required bool fatalInfos,
  required bool fatalWarnings,
}) {
  var errors = lints.expand((lint) => lint.errors);

  // Sort errors by file, line, column, code, message
  errors = errors.sorted((a, b) {
    final fileCompare = _relativeFilePath(a.location.file, workingDirectory)
        .compareTo(_relativeFilePath(b.location.file, workingDirectory));
    if (fileCompare != 0) return fileCompare;

    final lineCompare = a.location.startLine.compareTo(b.location.startLine);
    if (lineCompare != 0) return lineCompare;

    final columnCompare =
        a.location.startColumn.compareTo(b.location.startColumn);
    if (columnCompare != 0) return columnCompare;

    final codeCompare = a.code.compareTo(b.code);
    if (codeCompare != 0) return codeCompare;

    return a.message.compareTo(b.message);
  });

  if (errors.isEmpty) {
    stdout.writeln('No issues found!');
    return;
  } else {
    for (final error in errors) {
      stdout.writeln(
        '  ${_relativeFilePath(error.location.file, workingDirectory)}:${error.location.startLine}:${error.location.startColumn}'
        ' • ${error.message} • ${error.code}',
      );
    }
  }

  var hasErrors = false;
  var hasWarnings = false;
  var hasInfos = false;
  for (final error in errors) {
    hasErrors |= error.severity == AnalysisErrorSeverity.ERROR;
    hasWarnings |= error.severity == AnalysisErrorSeverity.WARNING;
    hasInfos |= error.severity == AnalysisErrorSeverity.INFO;
  }

  if (hasErrors) {
    exitCode = 1;
    return;
  }

  if (fatalWarnings && hasWarnings) {
    exitCode = 1;
    return;
  }

  if (fatalInfos && hasInfos) {
    exitCode = 1;
    return;
  }
}

Future<void> _startWatchMode(
  CustomLintRunner runner, {
  required bool fatalInfos,
  required bool fatalWarnings,
}) async {
  if (stdin.hasTerminal) {
    stdin
      // Let's not pollute the output with whatever the user types
      ..echoMode = false
      // Let's not force user to have to press "enter" to input a command
      ..lineMode = false;
  }

  stdout.writeln(_help);

  // Handle user inputs, forcing the command to continue until the user asks to "quit"
  await for (final input in stdin.transform(utf8.decoder)) {
    switch (input) {
      case 'r':
        // Rerunning lints
        stdout.writeln('Manual Reload...');
        await _runPlugins(
          runner,
          reload: true,
          fatalInfos: fatalInfos,
          fatalWarnings: fatalWarnings,
        );
        break;
      case 'q':
        // Let's quit the command line
        // TODO(rrousselGit) Investigate why an "exit" is required and we can't simply "return"
        exit(exitCode);
      default:
      // Unknown command. Nothing to do
    }
  }
}

String _relativeFilePath(String file, Directory fromDir) {
  return p.relative(
    file,
    from: fromDir.absolute.path,
  );
}
