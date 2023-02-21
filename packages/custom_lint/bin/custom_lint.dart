import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:custom_lint/custom_lint.dart';

Future<void> entrypoint([List<String> args = const []]) async {
  final parser = ArgParser()
    ..addFlag(
      'watch',
      help: "Watches plugins' sources and perform a hot-reload on change",
      negatable: false,
    )
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Prints command usage',
    )
    ..addOption(
      'format',
      valueHelp: 'value',
      help: 'Specifies the format to display errors.',
      allowed: ['default', 'json'],
      allowedHelp: {
        'default': 'The default output format. This format is intended to be user '
            'consumable.\nThe format is not specified and can change '
            'between releases.',
        'json': 'A machine readable output in a JSON format.',
      },
    );
  final result = parser.parse(args);

  final help = result['help'] as bool;
  if (help) {
    stdout.writeln('Usage: custom_lint [--watch]');
    stdout.writeln(parser.usage);
    return;
  }

  final watchMode = result['watch'] as bool;
  final format = (result['format'] as String?) ?? 'default';

  await customLint(
    workingDirectory: Directory.current,
    watchMode: watchMode,
    format: format,
  );
}

void main([List<String> args = const []]) async {
  await entrypoint(args);
  // TODO figure out why this exit is necessary
  exit(exitCode);
}
