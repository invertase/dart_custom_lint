import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cli_util/cli_logging.dart';

import 'src/cli_logger.dart';
import 'src/output/output_format.dart';
import 'src/output/render_lints.dart';
import 'src/plugin_delegate.dart';
import 'src/runner.dart';
import 'src/server_isolate_channel.dart';
import 'src/v2/custom_lint_analyzer_plugin.dart';
import 'src/workspace.dart';

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
  bool fatalInfos = true,
  bool fatalWarnings = true,
  OutputFormatEnum format = OutputFormatEnum.plain,
  bool fix = false,
}) async {
  // Reset the code
  exitCode = 0;

  final channel = ServerIsolateChannel();
  try {
    await _runServer(
      channel,
      watchMode: watchMode,
      workingDirectory: workingDirectory,
      fatalInfos: fatalInfos,
      fatalWarnings: fatalWarnings,
      format: format,
      fix: fix,
    );
  } catch (_) {
    exitCode = 1;
  } finally {
    await channel.close();
  }
}

Future<void> _runServer(
  ServerIsolateChannel channel, {
  required bool watchMode,
  required Directory workingDirectory,
  required bool fatalInfos,
  required bool fatalWarnings,
  required OutputFormatEnum format,
  required bool fix,
}) async {
  final customLintServer = await CustomLintServer.start(
    sendPort: channel.receivePort.sendPort,
    watchMode: watchMode,
    fix: fix,
    workingDirectory: workingDirectory,
    // In the CLI, only show user defined lints. Errors & logs will be
    // rendered separately
    includeBuiltInLints: false,
    delegate: CommandCustomLintDelegate(),
  );

  await CustomLintServer.runZoned(() => customLintServer, () async {
    CustomLintRunner? runner;

    try {
      final workspace = await CustomLintWorkspace.fromPaths(
        [workingDirectory.path],
        workingDirectory: workingDirectory,
      );
      runner = CustomLintRunner(customLintServer, workspace, channel);

      await runner.initialize;

      final log = CliLogger();
      final progress =
          format == OutputFormatEnum.json ? null : log.progress('Analyzing');

      await _runPlugins(
        runner,
        log: log,
        progress: progress,
        reload: false,
        workingDirectory: workingDirectory,
        fatalInfos: fatalInfos,
        fatalWarnings: fatalWarnings,
        format: format,
      );

      if (watchMode) {
        await _startWatchMode(
          runner,
          log: log,
          workingDirectory: workingDirectory,
          fatalInfos: fatalInfos,
          fatalWarnings: fatalWarnings,
          format: format,
        );
      }
    } finally {
      await runner?.close();
    }
  }).whenComplete(() async {
    // Closing the server output of "runZoned" to ensure that "runZoned" completes
    // before the server is closed.
    // Failing to do so could cause exceptions within "runZoned" to be handled
    // after the server is closed, preventing the exception from being printed.
    await customLintServer.close();
  });
}

Future<void> _runPlugins(
  CustomLintRunner runner, {
  required Logger log,
  required bool reload,
  required Directory workingDirectory,
  required bool fatalInfos,
  required bool fatalWarnings,
  required OutputFormatEnum format,
  Progress? progress,
}) async {
  final lints = await runner.getLints(reload: reload);

  renderLints(
    lints,
    log: log,
    progress: progress,
    workingDirectory: workingDirectory,
    fatalInfos: fatalInfos,
    fatalWarnings: fatalWarnings,
    format: format,
  );
}

Future<void> _startWatchMode(
  CustomLintRunner runner, {
  required Logger log,
  required Directory workingDirectory,
  required bool fatalInfos,
  required bool fatalWarnings,
  required OutputFormatEnum format,
}) async {
  if (stdin.hasTerminal) {
    stdin
      // Let's not pollute the output with whatever the user types
      ..echoMode = false
      // Let's not force user to have to press "enter" to input a command
      ..lineMode = false;
  }

  log.stdout(_help);

  // Handle user inputs, forcing the command to continue until the user asks to "quit"
  await for (final input in stdin.transform(utf8.decoder)) {
    switch (input) {
      case 'r':
        // Rerunning lints
        final progress = log.progress('Manual re-lint');
        await _runPlugins(
          runner,
          log: log,
          progress: progress,
          reload: true,
          workingDirectory: workingDirectory,
          fatalInfos: fatalInfos,
          fatalWarnings: fatalWarnings,
          format: format,
        );
      case 'q':
        // Let's quit the command line
        return;
      default:
      // Unknown command. Nothing to do
    }
  }
}
