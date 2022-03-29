import 'dart:async';
import 'dart:isolate';

import '../log.dart';
import 'analyzer_plugin.dart';
import 'client_isolate_channel.dart';

/// Connects custom_lint to the analyzer server using the analyzer_plugin protocol
void start(Iterable<String> _, SendPort sendPort) {
  runZonedGuarded(
    () {
      final channel = ClientIsolateChannel(sendPort);
      final server = CustomLintPlugin();
      log('start server ${server.name}');
      server.start(channel);
    },
    (err, stack) {
      log('Uncaught error:\n$err\n$stack');
    },
  );
}
