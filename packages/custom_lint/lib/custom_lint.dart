import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cli_util/cli_logging.dart';

import 'src/output.dart';
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
  String format = 'default',
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
      final runner = CustomLintRunner(
        customLintServer,
        workingDirectory,
        channel,
        format,
      );

      try {
        await runner.initialize;
        await _runPlugins(runner, reload: false);

        if (watchMode) {
          await _startWatchMode(runner);
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
}) async {
  final log = Logger.standard();

  log.progress('Analyzing');

  try {
    final lints = await runner.getLints(reload: reload);

    if (lints.any((lintsForFile) => lintsForFile.errors.isNotEmpty)) {
      exitCode = 1;
    }

    renderLints(
      log,
      lints,
      workingDirectory: runner.workingDirectory,
      format: runner.format,
    );
  } catch (err, stack) {
    exitCode = 1;
    log.stderr('$err\n$stack');
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
        // Rerunning lints
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
