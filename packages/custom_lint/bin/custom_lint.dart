import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:custom_lint/custom_lint.dart';
import 'package:custom_lint/src/output/output_format.dart';

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
    ..addOption(
      'format',
      valueHelp: 'value',
      help: 'Specifies the format to display lints.',
      defaultsTo: 'default',
      allowed: [
        OutputFormatEnum.plain.name,
        OutputFormatEnum.json.name,
      ],
      allowedHelp: {
        'default':
            'The default output format. This format is intended to be user '
                'consumable.\nThe format is not specified and can change '
                'between releases.',
        'json': 'A machine readable output in a JSON format.',
      },
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
  final format = result['format'] as String;

  await customLint(
    workingDirectory: Directory.current,
    watchMode: watchMode,
    fatalInfos: fatalInfos,
    fatalWarnings: fatalWarnings,
    format: OutputFormatEnum.fromName(format),
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
