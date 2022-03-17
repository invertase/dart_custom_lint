import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:async/async.dart' show StreamGroup;
import 'package:path/path.dart' as p;
import 'package:analyzer/file_system/file_system.dart' as analyzer;
import 'package:analyzer_plugin/protocol/protocol.dart' as plugin;
import 'package:analyzer_plugin/protocol/protocol_common.dart' as plugin;
import 'package:analyzer_plugin/protocol/protocol_generated.dart' as plugin;
import 'package:analyzer_plugin/src/protocol/protocol_internal.dart' as plugin
    show RequestParams;
import 'package:riverpod/riverpod.dart';

import '../../protocol.dart';
import '../log.dart';

final _pluginSourceChangeProvider =
    StreamProvider.autoDispose.family<void, Uri>((ref, pluginRootUri) {
  final pluginRootPath = pluginRootUri.toFilePath();

  return StreamGroup.merge([
    Directory(p.join(pluginRootPath, 'lib')).watch(recursive: true),
    Directory(p.join(pluginRootPath, 'bin')).watch(recursive: true),
    // watch package dir but not recursively, for pubspec/analysis changes
    File(p.join(pluginRootPath, 'pubspec.yaml')).watch(recursive: true),
    File(
      p.join(pluginRootPath, '.dart_tool', 'package_config.json'),
    ).watch(recursive: true),
    // TODO possibly watch package dependencies too, for when working on custom_lint
  ]);
});

final pluginLinkProvider =
    Provider.autoDispose.family<PluginLink, Uri>((ref, pluginRootUri) {
  log('build plugin $pluginRootUri');
  ref.watch(_pluginSourceChangeProvider(pluginRootUri));
  ref.listen<Object?>(_pluginSourceChangeProvider(pluginRootUri), (_, value) {
    log('Source changed for $pluginRootUri: $value');
  });

  ref.onDispose(() {
    log('Close plugin $pluginRootUri');
  });

  final receivePort = ReceivePort();
  ref.onDispose(receivePort.close);

  final pluginRootPath = pluginRootUri.toFilePath();
  // TODO configure that through build.yaml-like file
  final mainPath = Uri.file(
    p.join(pluginRootPath, 'lib', 'main.dart'),
  );

  final isolate = Isolate.spawnUri(
    mainPath,
    const [],
    receivePort.sendPort,
    automaticPackageResolution: true,
  );

// // TODO do we ca re about killing isolates before _listenIsolate completes?

  final sendPortCompleter = Completer<SendPort>();

  final link = PluginLink._(
    isolate,
    sendPortCompleter.future,
    pluginRootUri,
  );
  ref.onDispose(link.close);

  // TODO close subscribption
  receivePort.listen(
    (Object? obj) {
      if (obj is SendPort) {
        sendPortCompleter.complete(obj);
        return;
      }

      // log('Received $obj');

      try {
        final json = Map<String, Object?>.from(obj! as Map);

        if (json.containsKey(plugin.Notification.EVENT)) {
          final notification = plugin.Notification.fromJson(json);

          switch (json[plugin.Notification.EVENT]) {
            case PrintParams.key:
              final print = PrintParams.fromNotification(notification);
              link._messagesController.add(print);
              break;
            case 'plugin.error':
              final error =
                  plugin.PluginErrorParams.fromNotification(notification);
              link._errorsController.add(error);
              break;
            default:
              link._notificationsController.add(notification);
          }
        } else {
          final response = plugin.Response.fromJson(json);
          link._responsesController.add(response);
        }
      } catch (err, stack) {
        log('failed to decode message $obj with:\n$err\n$stack');
        // TODO handle
      }
    },
    // TODO handle errors
    onDone: () {
      link._errorsController.close();
      link._messagesController.close();
      link._responsesController.close();
      link._notificationsController.close();
    },
  );

  return link;
});

class PluginLink {
  PluginLink._(
    this._isolate,
    this._sendPort,
    this.key,
  );

  final Uri key;
  final Future<Isolate> _isolate;
  final Future<SendPort> _sendPort;
  final lintsForLibrary = <String, plugin.AnalysisErrorsParams>{};

  final _messagesController = StreamController<PrintParams>.broadcast();
  Stream<PrintParams> get messages => _messagesController.stream;

  final _errorsController =
      StreamController<plugin.PluginErrorParams>.broadcast();
  Stream<plugin.PluginErrorParams> get error => _errorsController.stream;

  final _responsesController = StreamController<plugin.Response>.broadcast();
  Stream<plugin.Response> get responses => _responsesController.stream;

  final _notificationsController =
      StreamController<plugin.Notification>.broadcast();
  Stream<plugin.Notification> get notifications =>
      _notificationsController.stream;

  void send(Map<String, Object?> json) {
    _sendPort.then((value) => value.send(json));
  }

  Future<void> close() async {
    await Future.wait<void>([
      _isolate.then((value) => value.kill()),
      _errorsController.close(),
      _responsesController.close(),
      _messagesController.close(),
      _notificationsController.close(),
    ]);
  }
}
