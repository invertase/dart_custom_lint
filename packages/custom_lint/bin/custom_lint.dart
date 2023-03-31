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
    );
  final result = parser.parse(args);

  final help = result['help'] as bool;
  if (help) {
    stdout.writeln('Usage: custom_lint [--watch]');
    stdout.writeln(parser.usage);
    return;
  }

  final watchMode = result['watch'] as bool;

  await customLint(workingDirectory: Directory.current, watchMode: watchMode);
}

void main([List<String> args = const []]) async {
  try {
    await entrypoint(args);
  } finally {
    // TODO figure out why this exit is necessary
    exit(exitCode);
  }
}
