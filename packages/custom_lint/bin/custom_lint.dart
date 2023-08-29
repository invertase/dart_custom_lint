import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:custom_lint/custom_lint.dart';

Future<void> entrypoint([List<String> args = const []]) async {
  final parser = ArgParser()
    ..addFlag(
      'fatal-infos',
      help: 'Treat info level issues as fatal',
      defaultsTo: true,
    )
    ..addFlag(
      'fatal-warnings',
      help: 'Treat warning level issues as fatal',
      defaultsTo: true,
    )
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
  final fatalInfos = result['fatal-infos'] as bool;
  final fatalWarnings = result['fatal-warnings'] as bool;

  await customLint(
    workingDirectory: Directory.current,
    watchMode: watchMode,
    fatalInfos: fatalInfos,
    fatalWarnings: fatalWarnings,
  );
}

void main([List<String> args = const []]) async {
  try {
    await entrypoint(args);
  } finally {
    // TODO figure out why this exit is necessary
    exit(exitCode);
  }
}
