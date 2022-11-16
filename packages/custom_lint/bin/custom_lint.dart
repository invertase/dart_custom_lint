import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:custom_lint/basic_runner.dart';

Future<void> main(List<String> args) async {
  final parser = ArgParser()
    ..addFlag(
      'hot-reload',
      defaultsTo: true,
      help: 'Enables hot reload support',
    );
  final results = parser.parse(args)['hot-reload'] as bool;
  await runCustomLintOnDirectory(Directory.current, hotReload: results);
}
