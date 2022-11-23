import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:analyzer_plugin/protocol/protocol_generated.dart';
import 'package:path/path.dart' as p;

import 'src/analyzer_plugin/analyzer_plugin.dart';
import 'src/analyzer_plugin/plugin_delegate.dart';
import 'src/protocol/internal_protocol.dart';
import 'src/runner.dart';

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
  required Directory workingDirectory,
}) async {
  await runZonedGuarded(() async {
    final runner = CustomLintRunner(
      CustomLintPlugin(
        delegate: CommandCustomLintDelegate(),
        includeBuiltInLints: false,
        watchMode: watchMode,
      ),
      workingDirectory,
    );

    runner.channel
      ..responseErrors.listen((event) => exitCode = -1)
      ..pluginErrors.listen((event) => exitCode = -1)
      ..notifications.listen((event) async {
        if (watchMode) {
          switch (event.event) {
            case PrintNotification.key:
              final notification = PrintNotification.fromNotification(event);
              stdout.writeln(notification.message);
              break;
            case DidHotReloadNotification.key:
              stdout.writeln(
                'Did hot-reload the sources of a plugin.\nRecomputing lints...',
              );
              await _runPlugins(runner, reload: true);
              stdout.writeln(_help);
              break;
          }
        }
      });

    try {
      await runner.initialize();
      await _runPlugins(runner, reload: false);

      if (watchMode) {
        await _startWatchMode(runner);
      }
    } finally {
      await runner.close();
    }
  }, (err, stack) {
    exitCode = -1;
    stderr.writeln('$err\n$stack');
  });
}

Future<void> _runPlugins(
  CustomLintRunner runner, {
  required bool reload,
}) async {
  // Reset the code
  exitCode = 0;

  try {
    final lints = await runner.getLints(reload: reload);

    if (lints.any((lintsForFile) => lintsForFile.errors.isNotEmpty)) {
      exitCode = -1;
    }

    _renderLints(lints, workingDirectory: runner.workingDirectory);
  } catch (err, stack) {
    exitCode = -1;
    stderr.writeln('$err\n$stack');
  }

  // Since no problem happened, we print a message saying everything went well
  if (exitCode == 0) {
    stdout.writeln('No issues found!');
  }
}

void _renderLints(
  List<AnalysisErrorsParams> lints, {
  required Directory workingDirectory,
}) {
  lints.sort(
    (a, b) => a
        .relativeFilePath(workingDirectory)
        .compareTo(b.relativeFilePath(workingDirectory)),
  );

  for (final lintsForFile in lints) {
    final relativeFilePath = lintsForFile.relativeFilePath(workingDirectory);

    lintsForFile.errors.sort((a, b) {
      final lineCompare = a.location.startLine.compareTo(b.location.startLine);
      if (lineCompare != 0) return lineCompare;
      final columnCompare =
          a.location.startColumn.compareTo(b.location.startColumn);
      if (columnCompare != 0) return columnCompare;

      final codeCompare = a.code.compareTo(b.code);
      if (codeCompare != 0) return codeCompare;

      return a.message.compareTo(b.message);
    });

    for (final lint in lintsForFile.errors) {
      exitCode = -1;
      stdout.writeln(
        '  $relativeFilePath:${lint.location.startLine}:${lint.location.startColumn}'
        ' • ${lint.message} • ${lint.code}',
      );
    }
  }
}

Future<void> _startWatchMode(CustomLintRunner runner) async {
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
        // Reruning lints
        stdout.writeln('Manual Reload...');
        await _runPlugins(runner, reload: true);
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

extension on AnalysisErrorsParams {
  String relativeFilePath(Directory dir) {
    return p.relative(
      file,
      from: dir.path,
    );
  }
}
