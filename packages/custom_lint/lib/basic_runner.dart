import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:analyzer_plugin/protocol/protocol_generated.dart';
import 'package:path/path.dart' as p;

import 'src/analyzer_plugin/analyzer_plugin.dart';
import 'src/analyzer_plugin/plugin_delegate.dart';
import 'src/protocol/internal_protocol.dart';
import 'src/runner.dart';

// ignore: unnecessary_const, do_not_use_environment
const _release = const bool.fromEnvironment('dart.vm.product');

/// Runs plugins with custom_lint.dart on the given directory
///
/// In debug mode
/// * This will run until the user types q to quit
/// * The plugin will hot-reload when the user changes it's code, and will cause a re-lint
/// * The exit code is the one from the last lint before quitting
/// * The user can force a reload by typing r
///
/// In release mode
/// * There is no hot-reload or watching so linting only happens once
/// * The process exits with the most recent result of the linter
Future<int> runCustomLintOnDirectory(Directory dir,
    {bool hotReload = true}) async {
  final completer = Completer<int>();

  await runZonedGuarded(() async {
    final runner = CustomLintRunner(
        CustomLintPlugin(
          delegate: CommandCustomLintDelegate(),
          includeBuiltInLints: false,
        ),
        dir);

    var code = 0;

    var first = true;
    Future<void> lint() async {
      // Reset the code
      code = 0;

      try {
        final lints = await runner.getLints(reload: !first);

        first = false;
        lints.sort((a, b) =>
            a.relativeFilePath(dir).compareTo(b.relativeFilePath(dir)));

        for (final lintsForFile in lints) {
          final relativeFilePath = lintsForFile.relativeFilePath(dir);

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
      } catch (err, stack) {
        code = -1;
        stderr.writeln('$err\n$stack');
      }

      // Since no problem happened, we print a message saying everything went well
      if (code == 0) {
        stdout.writeln('No issues found!');
      }
    }

    runner.channel
      ..responseErrors.listen((event) => code = -1)
      ..pluginErrors.listen((event) => code = -1)
      ..notifications.listen((event) async {
        if (!_release && hotReload) {
          switch (event.event) {
            case PrintNotification.key:
              final notification = PrintNotification.fromNotification(event);
              stdout.writeln(notification.message);
              break;
            case AutoReloadNotification.key:
              stdout.writeln('Re-linting...');
              await lint();
              stdout.writeln(
                  '\nCustom lint runner commands:\nr: Force re-lint\nq: Quit\n\n');
              break;
          }
        }
      });

    await runner.initialize();
    await lint();

    // Listen for user input or get the first result depending on release mode
    if (!_release && hotReload) {
      // Listen for reload on debug builds
      late StreamSubscription sub;
      sub = stdin.listen((d) async {
        final input = utf8.decode(d);
        if (input.contains('r\n')) {
          stdout.writeln('Manual Reload...');
          await runner.channel.sendRequest(ForceReload());
        } else if (input.contains('q\n')) {
          await sub.cancel();
          exit(code);
        }
      });

      stdout.writeln(
          '\nCustom lint runner commands:\nr: Force re-lint\nq: Quit\n\n');
    } else {
      completer.complete(code);
    }
  }, (err, stack) {
    stderr.writeln('$err\n$stack');
  });
  return completer.future;
}

extension on AnalysisErrorsParams {
  String relativeFilePath(Directory dir) {
    return p.relative(
      file,
      from: dir.path,
    );
  }
}
