import 'dart:async';
import 'dart:isolate';

import 'package:analyzer_plugin/protocol/protocol_generated.dart';
import 'package:custom_lint/protocol.dart';
// ignore: implementation_imports, safe since we are using tight constraints
import 'package:custom_lint/src/analyzer_plugin/isolate_channel.dart';

import 'src/analyzer_plugin/client.dart';
import 'src/plugin_base.dart';

export 'src/plugin_base.dart' show PluginBase;

/// Starts a plugin and emits lints/fixes/...
///
/// [startPlugin] will redirect errors and prints within [plugin]
/// to a log file, as they would otherwise be unvisible.
///
/// See also [PluginBase].
void startPlugin(SendPort sendPort, PluginBase plugin) {
  void send(Map<String, Object> json) {
    sendPort.send(json);
  }

  runZonedGuarded(
    () async {
      final client = Client(plugin);
      client.start(PluginIsolateChannel(sendPort));
    },
    (err, stack) {
      send(
        PluginErrorParams(
          false,
          err.toString(),
          stack.toString(),
        ).toNotification().toJson(),
      );
    },
    zoneSpecification: ZoneSpecification(
      print: (self, zoneDelegate, zone, message) {
        send(PrintNotification(message).toNotification().toJson());
      },
    ),
  );
}
