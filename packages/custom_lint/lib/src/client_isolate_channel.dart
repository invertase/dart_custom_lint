import 'dart:async';
import 'dart:isolate';

import 'package:analyzer_plugin/channel/channel.dart';
import 'package:analyzer_plugin/protocol/protocol.dart';

/// A channel used to communicate with the analyzer server using the
/// analyzer_plugin protocol
///
/// Imported from package:analyzer_plugin
class ClientIsolateChannel implements PluginCommunicationChannel {
  /// Initialize a newly created channel to communicate with the server.
  ClientIsolateChannel(this._sendPort) {
    _receivePort = ReceivePort();
    _sendPort.send(_receivePort.sendPort);
  }

  /// The port used to send notifications and responses to the server.
  final SendPort _sendPort;

  /// The port used to receive requests from the server.
  late final ReceivePort _receivePort;

  /// The subscription that needs to be cancelled when the channel is closed.
  StreamSubscription<void>? _subscription;

  @override
  void close() {
    unawaited(_subscription?.cancel());
    _subscription = null;
    _receivePort.close();
  }

  @override
  void listen(
    void Function(Request request) onRequest, {
    Function? onError,
    void Function()? onDone,
  }) {
    void onData(Object? data) {
      final requestMap = data! as Map<String, Object?>;
      final request = Request.fromJson(requestMap);
      onRequest(request);
    }

    if (_subscription != null) {
      throw StateError('Only one listener is allowed per channel');
    }
    _subscription = _receivePort.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: false,
    );
  }

  @override
  void sendNotification(Notification notification) {
    final json = notification.toJson();
    _sendPort.send(json);
  }

  @override
  void sendResponse(Response response) {
    final json = response.toJson();
    _sendPort.send(json);
  }
}
