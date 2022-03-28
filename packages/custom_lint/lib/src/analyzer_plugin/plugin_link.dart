import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:analyzer_plugin/protocol/protocol.dart' as plugin;
import 'package:analyzer_plugin/protocol/protocol_generated.dart' as plugin;
// ignore: implementation_imports
import 'package:analyzer_plugin/src/protocol/protocol_internal.dart' as plugin
    show RequestParams;
import 'package:async/async.dart' show StreamGroup;
import 'package:package_config/package_config.dart';
import 'package:path/path.dart' as p;
import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:riverpod/riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../protocol.dart';
import '../log.dart';

const _uuid = Uuid();

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

final _pluginLinkProvider =
    Provider.autoDispose.family<PluginLink, Uri>((ref, pluginRootUri) {
  ref.watch(_pluginSourceChangeProvider(pluginRootUri));

  final receivePort = ReceivePort();
  final Stream<Object?> receivePortStream = receivePort;
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
    // TODO assert this file exists and show a nice error message if not
    packageConfig: Uri.parse(
      p.join(pluginRootPath, '.dart_tool', 'package_config.json'),
    ),
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
  final sub = receivePortStream.listen(
    (obj) {
      if (obj is SendPort) {
        sendPortCompleter.complete(obj);
        return;
      }

      try {
        final json = Map<String, Object?>.from(obj! as Map);

        if (json.containsKey(plugin.Notification.EVENT)) {
          final notification = plugin.Notification.fromJson(json);

          switch (json[plugin.Notification.EVENT]) {
            case PrintNotification.key:
              final print = PrintNotification.fromNotification(notification);
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

  ref.onDispose(sub.cancel);

  return link;
});

/// The interface for interacting with a plugin
class PluginLink {
  PluginLink._(
    this._isolate,
    this._sendPort,
    this.key,
  );

  /// The unique key for this plugin
  final Uri key;
  final Future<Isolate> _isolate;
  final Future<SendPort> _sendPort;

  /// The list of lints per Dart Library emitted by this plugin
  final lintsForLibrary = <String, plugin.AnalysisErrorsParams>{};

  final _messagesController = StreamController<PrintNotification>.broadcast();

  /// The [print]s emitted by the plugin
  Stream<PrintNotification> get messages => _messagesController.stream;

  final _errorsController =
      StreamController<plugin.PluginErrorParams>.broadcast();

  /// The uncaught exception within the plugin
  Stream<plugin.PluginErrorParams> get error => _errorsController.stream;

  final _responsesController = StreamController<plugin.Response>.broadcast();

  /// The [plugin.Response]s to [plugin.Request]s.
  Stream<plugin.Response> get responses => _responsesController.stream;

  final _notificationsController =
      StreamController<plugin.Notification>.broadcast();

  /// The [plugin.Notification]s emitted by the plugin.
  Stream<plugin.Notification> get notifications =>
      _notificationsController.stream;

  Future<void> _sendJson(Map<String, Object?> json) {
    return _sendPort.then((value) => value.send(json));
  }

  /// Send a request and obtains the associated response
  Future<plugin.Response> sendRequest(plugin.RequestParams request) async {
    // TODO handle errors
    final id = _uuid.v4();

    final response = responses.firstWhere((message) => message.id == id);
    await _sendJson(request.toRequest(id).toJson());
    return response;
  }

  /// Close the plugin, killing the isolate
  Future<void> close() async {
    // TODO send pluginShutdown?
    await Future.wait<void>([
      _isolate.then((value) => value.kill()),
      _errorsController.close(),
      _responsesController.close(),
      _messagesController.close(),
      _notificationsController.close(),
    ]);
  }
}

/// The latest version check parameters
final versionCheckProvider =
    StateProvider<plugin.PluginVersionCheckParams?>((ref) => null);

final _versionInitializedProvider =
    FutureProvider.autoDispose.family<void, Uri>((ref, pluginUri) async {
  final link = ref.watch(_pluginLinkProvider(pluginUri));

  final versionCheck = ref.watch(versionCheckProvider);
  if (versionCheck == null) {
    throw StateError(
      'Tried to initialze plugins before version check completed',
    );
  }

  await link.sendRequest(versionCheck);
});

/// The list of active context roots
final activeContextRootsProvider = StateProvider<List<plugin.ContextRoot>>(
  (ref) => [],
);

/// The list of plugins associated with a context root.
final pluginMetasForContextRootProvider = Provider.autoDispose
    .family<List<Package>, plugin.ContextRoot>((ref, contextRoot) {
  Iterable<Package> _getPluginsForContext(
    plugin.ContextRoot contextRoot,
  ) sync* {
    log('Start plugin ${contextRoot.root}');
    final packagePath = contextRoot.root;
    // TODO if it is a plugin definition, assert that it contains the necessary configs

    // TODO is it safe to assume that there will always be a pubspec at the root?
    // TODO will there be packages nested in this directory, or will analyzer_plugin spawn a new plugin?
    // TODO should we listen to source changes for pubspec change/creation?
    final pubspec = _loadPubspecAt(packagePath);

    final packageConfigFile = File(
      p.join(packagePath, '.dart_tool', 'package_config.json'),
    );

    if (!packageConfigFile.existsSync()) {
      // TODO should we listen to source changes for a late pub get and reload?
      throw StateError(
        'No ${packageConfigFile.path} found. Make sure to run `pub get` first.',
      );
    }

    final packageConfig = PackageConfig.parseString(
      packageConfigFile.readAsStringSync(),
      packageConfigFile.uri,
    );

    for (final dependency in {
      ...pubspec.dependencies,
      ...pubspec.devDependencies,
      ...pubspec.dependencyOverrides
    }.entries) {
      final dependencyMeta = packageConfig.packages.firstWhere(
        (package) => package.name == dependency.key,
        orElse: () => throw StateError(
          'Failed to find the source for ${dependency.key}. '
          'Make sure to run `pub get`.',
        ),
      );

      final dependencyPubspec =
          _loadPubspecAt(dependencyMeta.root.toFilePath());

// TODO extract magic value
      if (dependencyPubspec.hasDependency('custom_lint_builder')) {
        yield dependencyMeta;
        // TODO assert that they have the necessary configs
      }
    }
  }

  return _getPluginsForContext(contextRoot).toList();
});

/// The context roots that a plugin is currently analyzing
final contextRootsForPlugin =
    Provider.autoDispose.family<List<plugin.ContextRoot>, Uri>(
  (ref, packageUri) {
    final contextRoots = ref.watch(activeContextRootsProvider);

    return contextRoots
        .where(
          (contextRoot) => ref
              .watch(pluginMetasForContextRootProvider(contextRoot))
              .any((package) => package.root == packageUri),
        )
        .toList();
  },
  cacheTime: const Duration(minutes: 5),
);

final _contextRootInitializedProvider =
    FutureProvider.autoDispose.family<void, Uri>((ref, pluginUri) async {
  final link = ref.watch(_pluginLinkProvider(pluginUri));

  // TODO filter events if the previous/new values are the same
  // Call setContextRoots on the plugin with only the roots that have
  // the plugin enabled
  await link.sendRequest(
    plugin.AnalysisSetContextRootsParams(
      ref
          .watch(activeContextRootsProvider)
          .where(
            ref.watch(contextRootsForPlugin(pluginUri)).contains,
          )
          .toList(),
    ),
  );
});

/// The last list of priority files obtained.
final priorityFilesProvider =
    StateProvider<plugin.AnalysisSetPriorityFilesParams?>((ref) => null);

final _priorityFilesInitializedProvider =
    FutureProvider.autoDispose.family<void, Uri>((ref, pluginUri) async {
  final link = ref.watch(_pluginLinkProvider(pluginUri));

  final priorityFilesRequest = ref.watch(priorityFilesProvider);
  if (priorityFilesRequest == null) return;

  final priorityFilesForPlugin = priorityFilesRequest.files.where(
    (priorityFile) {
      return ref
          .watch(contextRootsForPlugin(pluginUri))
          .any((contextRoot) => p.isWithin(contextRoot.root, priorityFile));
    },
  ).toList();

  await link.sendRequest(
    plugin.AnalysisSetPriorityFilesParams(priorityFilesForPlugin),
  );
});

/// A provider for obtaining for link of a specific plugin
final pluginLinkProvider =
    FutureProvider.autoDispose.family<PluginLink, Uri>((ref, pluginUri) async {
  final link = ref.watch(_pluginLinkProvider(pluginUri));

  // TODO what if setContextRoot or priotity files changes while these
  // requests are pending?

  // TODO refresh lints, such that we don't see previous lints while plugins are rebuilding
  await ref.watch(_versionInitializedProvider(pluginUri).future);

  await Future.wait([
    ref.watch(_contextRootInitializedProvider(pluginUri).future),
    ref.watch(_priorityFilesInitializedProvider(pluginUri).future),
  ]);
  return link;
});

Pubspec _loadPubspecAt(String packagePath) {
  final pubspecFile = File(p.join(packagePath, 'pubspec.yaml'));
  if (!pubspecFile.existsSync()) {
    throw StateError('No pubspec.yaml found at $packagePath.');
  }

  return Pubspec.parse(
    pubspecFile.readAsStringSync(),
    sourceUrl: pubspecFile.uri,
  );
}

extension on Pubspec {
  bool hasDependency(String name) {
    return dependencies.containsKey(name) ||
        devDependencies.containsKey(name) ||
        dependencyOverrides.containsKey(name);
  }
}
