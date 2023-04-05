import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

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
  Future<void> sendJson(Map<String, Object?> json);

  /// Sends a [Response] to the analyzer_plugin server.
  Future<void> sendResponse({
    ResponseResult? data,
    RequestError? error,
    required String requestID,
    required int requestTime,
  }) async {
    await sendJson(
      Response(
        requestID,
        requestTime,
        result: data?.toJson(),
        error: error,
      ).toJson(),
    );
  }

  /// Releases the resources
  Future<void> close();
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
  Future<void> sendJson(Map<String, Object?> json) async {
    _sendPort.send(json);
  }

  @override
  Future<void> close() async {
    _receivePort.close();
  }
}

/// An interface for discussing with analyzer_plugin using web sockets
class JsonSocketChannel extends AnalyzerPluginClientChannel {
  /// An interface for discussing with analyzer_plugin using web sockets
  JsonSocketChannel(this._socket) {
    // Pipe the socket messages in a broadcast stream
    _subscription = Stream.fromFuture(_socket).asyncExpand((e) => e).listen(
          _controller.add,
          onError: _controller.addError,
          onDone: _controller.close,
        );
  }

  final Future<Socket> _socket;

  final _controller = StreamController<Uint8List>.broadcast();
  late StreamSubscription<Object?> _subscription;

  @override
  late final Stream<Object?> messages = _controller.stream
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
      .map<Object?>(jsonDecode);

  @override
  Future<void> sendJson(Map<String, Object?> json) async {
    // ignore: close_sinks
    final socket = await _socket;
    socket.add(
      utf8.encode(
        // Adding a trailing \n to handle the scenario where a Socket
        // merges multiple messages in one.
        // The \n is used as EOL to separate the different messages
        '${jsonEncode(json)}\n',
      ),
    );
  }

  @override
  Future<void> close() async {
    await Future.wait([
      _subscription.cancel(),
      _controller.close(),
    ]);
  }
}
