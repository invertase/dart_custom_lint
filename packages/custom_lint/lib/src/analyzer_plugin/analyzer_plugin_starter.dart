import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:analyzer_plugin/starter.dart';
import 'package:custom_lint/src/analyzer_plugin/custom_server_plugin_starter.dart';

import '../log.dart';

import 'analyzer_plugin.dart';

void start(Iterable<String> _, SendPort sendPort) {
  log('Start custom_plugin');

  runZonedGuarded(
    () {
      MyServerPluginStarter(CustomLintPlugin(PhysicalResourceProvider.INSTANCE))
          .start(sendPort);
    },
    (err, stack) {
      log('Uncaught error:\n$err\n$stack');
    },
  );
}
