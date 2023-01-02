import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

abstract class AnalyzerPluginClientChannel {
  Stream<Object?> get messages;

  void sendJson(Map<String, Object?> json);

  void close();
}

class JsonSendPortChannel implements AnalyzerPluginClientChannel {
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

class JsonSocketChannel implements AnalyzerPluginClientChannel {
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
