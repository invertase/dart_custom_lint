import 'dart:async';
import 'dart:isolate';

import 'package:analyzer/file_system/physical_file_system.dart';

import '../log.dart';
import 'analyzer_plugin.dart';
import 'isolate_channel.dart';

/// Connects custom_lint to the analyzer server using the analyzer_plugin protocol
void start(Iterable<String> _, SendPort sendPort) {
  runZonedGuarded(
    () {
      final channel = PluginIsolateChannel(sendPort);
      final server = CustomLintPlugin(PhysicalResourceProvider.INSTANCE);
      server.start(channel);
    },
    (err, stack) {
      log('Uncaught error:\n$err\n$stack');
    },
  );
}
