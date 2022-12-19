import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:analyzer_plugin/protocol/protocol.dart';
// ignore: implementation_imports
import 'package:custom_lint/src/channels.dart';
// ignore: implementation_imports
import 'package:custom_lint/src/v2/protocol.dart';

import '../../custom_lint_builder.dart';
import 'client.dart';

/// Converts a Stream/Sink into a Sendport/ReceivePort equivalent
class StreamToSentPortAdapter {
  /// Converts a Stream/Sink into a Sendport/ReceivePort equivalent
  StreamToSentPortAdapter(
    Stream<Map<String, Object?>> input,
    void Function(Map<String, Object?> output) output,
  ) {
    final Stream<Object?> outputStream = _outputReceivePort.asBroadcastStream();
    final inputSendport =
        outputStream.where((e) => e is SendPort).cast<SendPort>().first;

    final sub = outputStream
        .where((e) => e is! SendPort)
        .map((e) => e! as Map<String, Object?>)
        .listen((e) => output(e));

    input.listen(
      (e) {
        inputSendport.then((value) => value.send(e));
      },
      onDone: () {
        _outputReceivePort.close();
        sub.cancel();
      },
    );
  }

  SendPort get sendPort => _outputReceivePort.sendPort;
  final _outputReceivePort = ReceivePort();
}

typedef PluginMain = PluginBase Function();

Future<void> runSocket(Map<String, PluginMain> pluginMains, int port) async {
  final client = Completer<CustomLintPluginClient>();

  await runZonedGuarded(
    () async {
      final socket = JsonSocketChannel(await Socket.connect('localhost', port));
      final registeredPlugins = <String, PluginBase>{};
      client.complete(
        CustomLintPluginClient(
          _SocketCustomLintClientChannel(socket, registeredPlugins),
        ),
      );

      for (final main in pluginMains.entries) {
        Zone.current.runGuarded(
          () => registeredPlugins[main.key] = main.value(),
        );
      }
    },
    (error, stackTrace) {
      client.future.then((value) => value.handleError(error, stackTrace));
    },
    zoneSpecification: ZoneSpecification(
      print: (self, parent, zone, line) {
        client.future.then((value) => value.handlePrint(line));
      },
    ),
  );
}

abstract class CustomLintClientChannel {
  CustomLintClientChannel(this.registeredPlugins);

  /// The [SendPort] that will be passed to analyzer_plugin
  SendPort get sendPort;

  final Map<String, PluginBase> registeredPlugins;

  Stream<CustomLintRequest> get input;

  void _sendJson(Map<String, Object?> json);

  void sendResponse(CustomLintResponse response) {
    _sendJson(CustomLintMessage.response(response).toJson());
  }

  void sendEvent(CustomLintEvent event) {
    _sendJson(CustomLintMessage.event(event).toJson());
  }
}

class _SocketCustomLintClientChannel extends CustomLintClientChannel {
  _SocketCustomLintClientChannel(this.socket, super.registeredPlugins);

  @override
  SendPort get sendPort => _adapter.sendPort;

  final JsonSocketChannel socket;

  late final StreamToSentPortAdapter _adapter = StreamToSentPortAdapter(
    input
        .where((e) => e is CustomLintRequestAnalyzerPluginRequest)
        .cast<CustomLintRequestAnalyzerPluginRequest>()
        .map((event) => event.request.toJson()),
    (analyzerPluginOutput) {
      if (analyzerPluginOutput.containsKey(Notification.EVENT)) {
        sendEvent(
          CustomLintEvent.analyzerPluginNotification(
            Notification.fromJson(analyzerPluginOutput),
          ),
        );
      } else {
        final response = Response.fromJson(analyzerPluginOutput);
        sendResponse(
          CustomLintResponse.analyzerPluginResponse(response, id: response.id),
        );
      }
    },
  );

  @override
  late final Stream<CustomLintRequest> input = socket.messages
      .cast<Map<String, Object?>>()
      .map(CustomLintRequest.fromJson)
      .asBroadcastStream();

  @override
  void _sendJson(Map<String, Object?> json) {
    socket.sendJson(json);
  }
}
