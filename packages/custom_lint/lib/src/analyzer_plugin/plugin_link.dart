import 'dart:async';
import 'dart:isolate';

import 'package:path/path.dart' as p;
import 'package:analyzer/file_system/file_system.dart' as analyzer;
import 'package:analyzer_plugin/protocol/protocol.dart' as plugin;
import 'package:analyzer_plugin/protocol/protocol_common.dart' as plugin;
import 'package:analyzer_plugin/protocol/protocol_generated.dart' as plugin;
import 'package:analyzer_plugin/src/protocol/protocol_internal.dart' as plugin
    show RequestParams;

import '../../protocol.dart';
import '../log.dart';

class PluginLink {
  PluginLink._(
    this._isolate,
    this._sendPort,
    this._responsesController,
    this._notificationsController,
    this._messagesController,
    this._errorController,
    this._receivePort,
    this.key,
  );

  factory PluginLink.spawn(Uri pluginRootUri) {
    // TODO configure that through build.yaml-like file
    final mainPath = Uri.file(
      p.join(pluginRootUri.toFilePath(), 'lib', 'main.dart'),
    );

    final receivePort = ReceivePort();

    final isolate = Isolate.spawnUri(
      mainPath,
      const [],
      receivePort.sendPort,
      automaticPackageResolution: true,
    );

// // TODO do we ca re about killing isolates before _listenIsolate completes?

    final errors = StreamController<plugin.PluginErrorParams>.broadcast();
    final messages = StreamController<PrintParams>.broadcast();
    final responses = StreamController<plugin.Response>.broadcast();
    final notifications = StreamController<plugin.Notification>.broadcast();
    final sendPortCompleter = Completer<SendPort>();

    // TODO close subscribption
    receivePort.listen(
      (Object? obj) {
        if (obj is SendPort) {
          sendPortCompleter.complete(obj);
          return;
        }

        try {
          final json = Map<String, Object?>.from(obj! as Map);

          if (json.containsKey(plugin.Notification.EVENT)) {
            final notification = plugin.Notification.fromJson(json);

            switch (json[plugin.Notification.EVENT]) {
              case PrintParams.key:
                final print = PrintParams.fromNotification(notification);
                messages.add(print);
                break;
              case 'plugin.error':
                final error =
                    plugin.PluginErrorParams.fromNotification(notification);
                errors.add(error);
                break;
              default:
                notifications.add(notification);
            }
          } else {
            final response = plugin.Response.fromJson(json);
            responses.add(response);
          }
        } catch (err, stack) {
          log('failed to decode message $obj with:\n$err\n$stack');
          // TODO handle
        }
      },
      // TODO handle errors
      onDone: () {
        errors.close();
        messages.close();
        responses.close();
        notifications.close();
      },
    );

    return PluginLink._(
      isolate,
      sendPortCompleter.future,
      responses,
      notifications,
      messages,
      errors,
      receivePort,
      pluginRootUri,
    );
  }

  final Uri key;
  final Future<Isolate> _isolate;
  final Future<SendPort> _sendPort;
  final ReceivePort _receivePort;
  final contextRoots = <plugin.ContextRoot>{};
  final lintsForLibrary = <String, plugin.AnalysisErrorsParams>{};

  final StreamController<PrintParams> _messagesController;
  Stream<PrintParams> get messages => _messagesController.stream;

  final StreamController<plugin.PluginErrorParams> _errorController;
  Stream<plugin.PluginErrorParams> get error => _errorController.stream;

  final StreamController<plugin.Response> _responsesController;
  Stream<plugin.Response> get responses => _responsesController.stream;

  final StreamController<plugin.Notification> _notificationsController;
  Stream<plugin.Notification> get notifications =>
      _notificationsController.stream;

  void send(Map<String, Object?> json) {
    _sendPort.then((value) => value.send(json));
  }

  Future<void> close() async {
    _receivePort.close();
    _messagesController.close();
    _errorController.close();
    _notificationsController.close();
    _responsesController.close();
    return _isolate.then((i) => i.kill());
  }
}
