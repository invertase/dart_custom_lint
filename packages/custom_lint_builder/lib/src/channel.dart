import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:analyzer_plugin/protocol/protocol.dart';
// ignore: implementation_imports
import 'package:custom_lint/src/async_operation.dart';
// ignore: implementation_imports
import 'package:custom_lint/src/channels.dart';
// ignore: implementation_imports
import 'package:custom_lint/src/v2/protocol.dart';
import 'package:custom_lint_core/custom_lint_core.dart';

import 'client.dart';

/// Converts a Stream/Sink into a Sendport/ReceivePort equivalent
class StreamToSentPortAdapter {
  /// Converts a Stream/Sink into a Sendport/ReceivePort equivalent
  StreamToSentPortAdapter(
    Stream<Map<String, Object?>> input,
    void Function(Map<String, Object?> output) output, {
    required void Function() onDone,
  }) {
    final Stream<Object?> outputStream = _outputReceivePort.asBroadcastStream();
    final inputSendport =
        outputStream.where((e) => e is SendPort).cast<SendPort>().safeFirst;

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
        onDone();
      },
    );
  }

  /// The [SendPort] associated with the input [Stream].
  SendPort get sendPort => _outputReceivePort.sendPort;

  // TODO appears to sometime not be closed.
  // Could be because of the `onDone` callback not being invoked.
  final _outputReceivePort = ReceivePort();
}

/// The prototype of plugin's `createPlugin` entrypoint function.
typedef CreatePluginMain = PluginBase Function();

/// Starts a custom_lint client using web sockets.
Future<void> runSocket(
  Map<String, CreatePluginMain> pluginMains, {
  required int port,
  required String host,
  required bool includeBuiltInLints,
}) async {
  late Future<CustomLintPluginClient> client;

  await asyncRunZonedGuarded(
    () => client = Future(() async {
      // ignore: close_sinks, connection stays open until the plugin is killed
      final socket = await Socket.connect(host, port);
      final socketChannel = JsonSocketChannel(Future.value(socket));
      final registeredPlugins = <String, PluginBase>{};

      for (final main in pluginMains.entries) {
        Zone.current.runGuarded(
          () => registeredPlugins[main.key] = main.value(),
        );
      }

      return CustomLintPluginClient(
        includeBuiltInLints: includeBuiltInLints,
        _SocketCustomLintClientChannel(
          socketChannel,
          registeredPlugins,
          onDone: () {
            // If the server somehow quit, forcibly stop the client.
            // In theory it should stop naturally, but let's make sure of this to prevent leaks.
            // Tried with `socket.done.then` but it somehow was never invoked
            exit(0);
          },
        ),
      );
    }),
    (error, stackTrace) {
      client.then((value) => value.handleError(error, stackTrace));
    },
    zoneSpecification: ZoneSpecification(
      print: (self, parent, zone, line) {
        client.then((value) => value.handlePrint(line));
      },
    ),
  );
}

/// An interface for clients to send messages to the custom_lint server.
abstract class CustomLintClientChannel {
  /// An interface for clients to send messages to the custom_lint server.
  CustomLintClientChannel(this.registeredPlugins);

  /// The [SendPort] that will be passed to analyzer_plugin
  SendPort get sendPort;

  /// The list of plugins installed by custom_lint.
  final Map<String, PluginBase> registeredPlugins;

  /// Messages from the custom_lint server
  Stream<CustomLintRequest> get input;

  void _sendJson(Map<String, Object?> json);

  /// Sends a response to the custom_lint server, associated to a request
  void sendResponse(CustomLintResponse response) {
    _sendJson(CustomLintMessage.response(response).toJson());
  }

  /// Sends a notification to the custom_lint server, which is not associated with
  /// a request.
  void sendEvent(CustomLintEvent event) {
    _sendJson(CustomLintMessage.event(event).toJson());
  }
}

class _SocketCustomLintClientChannel extends CustomLintClientChannel {
  _SocketCustomLintClientChannel(
    this.socket,
    super.registeredPlugins, {
    required this.onDone,
  });

  @override
  SendPort get sendPort => _adapter.sendPort;

  final void Function() onDone;
  final JsonSocketChannel socket;

  late final StreamToSentPortAdapter _adapter = StreamToSentPortAdapter(
    onDone: onDone,
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
