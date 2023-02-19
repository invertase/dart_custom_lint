import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:custom_lint/custom_lint.dart';
import 'package:path/path.dart' as path;

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

  final restArgs = [...result.rest];

  final fileList = <String>[];
  final watchMode = result['watch'] as bool;

  // Coverting to absolute paths as the linter expects
  for (var i = 0; i < restArgs.length; i++) {
    if (path.isRelative(restArgs[i])) {
      restArgs[i] = path.absolute(restArgs[i]);
    }
  }

  // Populating fileList with all the files we can find
  for (var i = 0; i < restArgs.length; i++) {
    final pathStats = File(restArgs[i]).statSync();
    if (pathStats.type == FileSystemEntityType.file) {
      fileList.add(restArgs[i]);
    } else {
      final dir = Directory(restArgs[i]);
      final fileEntities = dir.listSync(recursive: true);

      for (final fileEntity in fileEntities) {
        fileList.add(fileEntity.path);
      }
    }
  }

  await customLint(
    workingDirectory: Directory.current,
    workingFiles: fileList.isEmpty ? null : fileList,
    watchMode: watchMode,
  );
}

void main([List<String> args = const []]) async {
  await entrypoint(args);
  // TODO figure out why this exit is necessary
  exit(exitCode);
}
