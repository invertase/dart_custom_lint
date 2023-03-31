import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:analyzer_plugin/protocol/protocol.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';
// ignore: implementation_imports
import 'package:analyzer_plugin/src/protocol/protocol_internal.dart'
    show ResponseResult;

/// An interface for interacting with analyzer_plugin
abstract class AnalyzerPluginClientChannel {
  /// The list of messages sent by analyzer_plugin.
  Stream<Object?> get messages;

  /// Sends a JSON object to the analyzer_plugin server
  void sendJson(Map<String, Object?> json);

  /// Sends a [Response] to the analyzer_plugin server.
  void sendResponse({
    ResponseResult? data,
    RequestError? error,
    required String requestID,
    required int requestTime,
  }) {
    sendJson(
      Response(
        requestID,
        requestTime,
        result: data?.toJson(),
        error: error,
      ).toJson(),
    );
  }

  /// Releases the resources
  void close();
}

/// An interface for discussing with analyzer_plugin using a [SendPort]
class JsonSendPortChannel extends AnalyzerPluginClientChannel {
  /// An interface for discussing with analyzer_plugin using a [SendPortƒ]
  JsonSendPortChannel(this._sendPort) : _receivePort = ReceivePort() {
    _sendPort.send(_receivePort.sendPort);
  }

  final SendPort _sendPort;
  final ReceivePort _receivePort;

  @override
  late final Stream<Object?> messages = _receivePort.asBroadcastStream();

  @override
  void sendJson(Map<String, Object?> json) {
    _sendPort.send(json);
  }

  @override
  void close() => _receivePort.close();
}

/// An interface for discussing with analyzer_plugin using web sockets
class JsonSocketChannel extends AnalyzerPluginClientChannel {
  /// An interface for discussing with analyzer_plugin using web sockets
  JsonSocketChannel(this._socket);

  final Socket _socket;

  @override
  late final Stream<Object?> messages = _socket
      .map(utf8.decode)

      /// Sometimes the socket receives multiple messages at once,
      /// concatenated with `\n` (see [sendJson]).
      /// So we're splitting the message into multiple bits
      .expand(
        (e) => e.split('\n')
          // Since all messages always include a trailing \n, after
          // a split the last string will be "". Removing it
          ..removeLast(),
      )
      .map<Object?>(jsonDecode)
      .asBroadcastStream();

  @override
  void sendJson(Map<String, Object?> json) {
    _socket.add(
      utf8.encode(
        // Adding a trailing \n to handle the scenario where a Socket
        // merges multiple messages in one.
        // The \n is used as EOL to separate the different messages
        '${jsonEncode(json)}\n',
      ),
    );
  }

  @override
  void close() {}
}
