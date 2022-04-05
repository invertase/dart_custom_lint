import 'dart:async';
import 'dart:isolate';

import 'package:analyzer_plugin/protocol/protocol_generated.dart';

import 'analyzer_plugin.dart';
import 'client_isolate_channel.dart';

/// Connects custom_lint to the analyzer server using the analyzer_plugin protocol
void start(Iterable<String> _, SendPort sendPort) {
  final channel = ClientIsolateChannel(sendPort);

  runZonedGuarded(
    () {
      final server = CustomLintPlugin();
      server.start(channel);
    },
    (err, stack) {
      sendPort.send(
        PluginErrorParams(false, err.toString(), stack.toString())
            .toNotification()
            .toJson(),
      );
    },
  );
}
