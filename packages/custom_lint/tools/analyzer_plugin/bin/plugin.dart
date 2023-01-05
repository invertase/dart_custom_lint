import 'dart:isolate';

import 'package:custom_lint/src/analyzer_plugin_starter.dart';

void main(List<String> args, SendPort sendPort) {
  start(args, sendPort);
}
