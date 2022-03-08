import 'dart:isolate';

import 'package:custom_lint/src/analyzer_plugin/analyzer_plugin_starter.dart';

import 'log.dart';

void main(List<String> args, SendPort sendPort) {
  log('main');
  start(args, sendPort);
  // Future<void>.delayed(Duration(hours: 2));
}
