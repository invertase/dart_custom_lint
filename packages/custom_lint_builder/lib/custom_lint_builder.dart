import 'dart:async';
import 'dart:isolate';

import 'package:analyzer_plugin/protocol/protocol.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';
import 'package:custom_lint/protocol.dart';

import 'src/analyzer_plugin/client.dart';
import 'src/analyzer_plugin/isolate_channel.dart';
import 'src/plugin_base.dart';

export 'src/plugin_base.dart' show PluginBase;

void startPlugin(SendPort sendPort, PluginBase plugin) {
  void send(Map<String, Object> json) {
    sendPort.send(json);
  }

  runZonedGuarded(
    () {
      final client = Client(plugin);
      client.start(PluginIsolateChannel(sendPort));
    },
    (err, stack) => send(
      PluginErrorParams(
        false,
        err.toString(),
        stack.toString(),
      ).toNotification().toJson(),
    ),
    zoneSpecification: ZoneSpecification(
      print: (self, zoneDelegate, zone, message) {
        send(PrintParams(message).toNotification().toJson());
      },
    ),
  );
}
