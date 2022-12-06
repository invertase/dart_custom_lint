import 'dart:async';
import 'dart:isolate';

import 'package:analyzer_plugin/protocol/protocol.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';
// ignore: implementation_imports
import 'package:analyzer_plugin/src/protocol/protocol_internal.dart'
    show RequestParams;
import 'package:async/async.dart';
import 'package:uuid/uuid.dart';

import '../protocol/internal_protocol.dart';

const _uuid = Uuid();

abstract class _BaseIsolateChannel {
  _BaseIsolateChannel(this._receivePort);

  final ReceivePort _receivePort;
  late final Stream<Object?> _receivePortStream =
      _receivePort.asBroadcastStream();

  late final _sendPort = _receivePortStream
      .where((event) => event is SendPort)
      .cast<SendPort>()
      .first;

  /// The [Notification]s emitted by the plugin
  late final Stream<Notification> notifications = _receivePortStream
      .where((e) => e is Map)
      .map((e) => e! as Map)
      .where((e) => e.containsKey(Notification.EVENT))
      .map(Notification.fromJson);

  /// The [Notification]s emitted by the plugin
  late final Stream<PrintNotification> messages = notifications
      .where((e) => e.event == PrintNotification.key)
      .map(PrintNotification.fromNotification);

  /// The [Response]s emitted by the plugin
  late final Stream<Response> responses = _receivePortStream
      .where((event) => event is Map<String, Object?>)
      .map((event) => event! as Map<String, Object?>)
      .where((e) => e.containsKey(Response.ID))
      .map(Response.fromJson);

  /// Error [Notification]s.
  late final Stream<PluginErrorParams> pluginErrors =
      StreamGroup.mergeBroadcast([
    // Manual error notifications from the plugin
    notifications
        .where((e) => e.event == 'plugin.error')
        .map(PluginErrorParams.fromNotification),

    // When the receivePort is passed to Isolate.onError, error events are
    // received as ["error", "stackTrace"]
    _receivePortStream
        .where((event) => event is List)
        .cast<List>()
        .map((event) {
      // The plugin had an uncaught error.
      if (event.length != 2) {
        throw UnsupportedError(
          'Only ["error", "stackTrace"] list messages are supported',
        );
      }

      final error = event.first.toString();
      final stackTrace = event.last.toString();
      return PluginErrorParams(false, error, stackTrace);
    }),
  ]);

  /// Errors for [Request]s that failed.
  late final Stream<RequestError> responseErrors =
      responses.where((e) => e.error != null).map((e) => e.error!);

  /// Sends a json object to the plugin, without awaiting for an answer
  Future<void> sendJson(Map<String, Object?> json) {
    return _sendPort.then((value) => value.send(json));
  }

  /// Send a request and obtains the associated response
  Future<Response> sendRequest(
    RequestParams requestParams,
  ) async {
    final id = _uuid.v4();

    final request = requestParams.toRequest(id);
    final responseFuture = responses.firstWhere(
      (message) => message.id == id,
      orElse: () => throw StateError(
        'No response for request ${request.method} $id',
      ),
    );
    await sendJson(request.toJson());
    final response = await responseFuture;

    if (response.error != null) {
      throw RequestFailure(response.error!);
    }

    return response;
  }
}

/// An interface for interacting with the plugin server.
class ServerIsolateChannel extends _BaseIsolateChannel {
  /// An interface for interacting with the plugin server.
  ServerIsolateChannel(super.receivePort);

  /// Lints emitted by the plugin
  late final Stream<AnalysisErrorsParams> lints = notifications
      .where((e) => e.event == 'analysis.errors')
      .map(AnalysisErrorsParams.fromNotification);
}

/// An interface for connecting plugins with the plugin server.
class PluginIsolateChannel extends _BaseIsolateChannel {
  /// An interface for connecting plugins with the plugin server.
  PluginIsolateChannel(super.receivePort);

  /// Lints emitted by the plugin
  late final Stream<CustomAnalysisNotification> lints = notifications
      .where((e) => e.event == 'analysis.errors')
      .map(CustomAnalysisNotification.fromNotification);
}
