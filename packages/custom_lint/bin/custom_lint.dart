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
    )
    ..addMultiOption(
      'files',
      abbr: 'f',
      help: 'List of files to scan',
    )
    ..addMultiOption(
      'dirs',
      abbr: 'd',
      help: 'List of directories to scan. '
          'Will recursively run on all the files of these directories.',
    );
  final result = parser.parse(args);

  final help = result['help'] as bool;
  if (help) {
    stdout.writeln('Usage: custom_lint [--watch]');
    stdout.writeln(parser.usage);
    return;
  }

  final fileList = result['files'] as List<String>;
  final dirList = result['dirs'] as List<String>;
  final watchMode = result['watch'] as bool;

  for (var i = 0; i < fileList.length; i++) {
    if (path.isRelative(fileList[i])) {
      fileList[i] = path.absolute(fileList[i]);
    }
  }

  for (var i = 0; i < dirList.length; i++) {
    if (path.isRelative(dirList[i])) {
      dirList[i] = path.absolute(dirList[i]);
    }
  }

  for (final dirPath in dirList) {
    final dir = Directory(dirPath);
    final fileEntities = dir.listSync(recursive: true);

    for (final fileEntity in fileEntities) {
      fileList.add(fileEntity.path);
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
