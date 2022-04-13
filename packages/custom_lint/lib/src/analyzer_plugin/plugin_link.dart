import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:analyzer_plugin/protocol/protocol_generated.dart' as plugin;
import 'package:async/async.dart' show StreamGroup;
import 'package:package_config/package_config.dart';
import 'package:path/path.dart' as p;
import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:riverpod/riverpod.dart';

import 'result.dart';
import 'server_isolate_channel.dart';

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

final _pluginLinkProvider = FutureProvider.autoDispose
    .family<PluginLink, Uri>((ref, pluginRootUri) async {
  ref.watch(_pluginSourceChangeProvider(pluginRootUri));

  final pluginName = ref
      .watch(pluginMetaProvider(pluginRootUri).select((value) => value.name));

  final receivePort = ReceivePort();
  ref.onDispose(receivePort.close);

  final pluginRootPath = pluginRootUri.toFilePath();

  // TODO configure that through build.yaml-like file
  final mainUri = Uri.file(
    p.join(pluginRootPath, 'bin', 'custom_lint.dart'),
  );

  final isolate = await Isolate.spawnUri(
    mainUri,
    const [],
    receivePort.sendPort,
    // TODO assert this file exists and show a nice error message if not
    packageConfig: Uri.file(
      p.join(pluginRootPath, '.dart_tool', 'package_config.json'),
    ),
    // TODO test error in main (outside of runZonedGuarded)
    onError: receivePort.sendPort,
  );

  final link = PluginLink._(
    isolate,
    ServerIsolateChannel(receivePort),
    pluginRootUri,
    pluginName,
  );
  ref.onDispose(link.close);

  return link;
});

/// The interface for interacting with a plugin
class PluginLink {
  PluginLink._(
    this._isolate,
    this.channel,
    this.key,
    this.name,
  );

  final Isolate _isolate;

  /// The name of this plugin
  final String name;

  /// The unique key for this plugin
  final Uri key;

  /// A channel for interacting with this plugin
  final ServerIsolateChannel channel;

  /// Close the plugin, killing the isolate
  Future<void> close() async {
    // TODO send pluginShutdown?
    return _isolate.kill();
  }
}

/// The latest version check parameters
final versionCheckProvider =
    StateProvider<plugin.PluginVersionCheckParams?>((ref) => null);

final _versionInitializedProvider =
    FutureProvider.autoDispose.family<void, Uri>((ref, linkKey) async {
  final link = await ref.watch(_pluginLinkProvider(linkKey).future);

  final versionCheck = ref.watch(versionCheckProvider);
  if (versionCheck == null) {
    throw StateError(
      'Tried to initialze plugins before version check completed',
    );
  }

  await link.channel.sendRequest(versionCheck);
});

/// The context roots currently active
final activeContextRootsProvider = StateProvider<List<plugin.ContextRoot>>(
  (ref) => [],
);

/// Package informations for the plugin
final pluginMetaProvider =
    Provider.autoDispose.family<Package, Uri>((ref, linkKey) {
  final contextRoot = ref.watch(contextRootsForPluginProvider(linkKey)).first;

  return ref
      .watch(pluginMetasForContextRootProvider(contextRoot))
      .firstWhere((element) => element.root == linkKey);
});

/// The list of plugins associated with a context root.
final pluginMetasForContextRootProvider = Provider.autoDispose
    .family<List<Package>, plugin.ContextRoot>((ref, contextRoot) {
  Iterable<Package> _getPluginsForContext(
    plugin.ContextRoot contextRoot,
  ) sync* {
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
final contextRootsForPluginProvider =
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
);

final _contextRootInitializedProvider =
    FutureProvider.autoDispose.family<void, Uri>((ref, linkKey) async {
  final link = await ref.watch(_pluginLinkProvider(linkKey).future);

  // TODO filter events if the previous/new values are the same
  // Call setContextRoots on the plugin with only the roots that have
  // the plugin enabled
  await link.channel.sendRequest(
    plugin.AnalysisSetContextRootsParams(
      ref
          .watch(activeContextRootsProvider)
          .where(
            ref.watch(contextRootsForPluginProvider(linkKey)).contains,
          )
          .toList(),
    ),
  );
});

/// The last list of priority files obtained.
final priorityFilesProvider =
    StateProvider<plugin.AnalysisSetPriorityFilesParams?>((ref) => null);

final _priorityFilesInitializedProvider =
    FutureProvider.autoDispose.family<void, Uri>((ref, linkKey) async {
  final link = await ref.watch(_pluginLinkProvider(linkKey).future);

  final priorityFilesRequest = ref.watch(priorityFilesProvider);
  if (priorityFilesRequest == null) return;

  final priorityFilesForPlugin = priorityFilesRequest.files.where(
    (priorityFile) {
      return ref
          .watch(contextRootsForPluginProvider(linkKey))
          .any((contextRoot) => p.isWithin(contextRoot.root, priorityFile));
    },
  ).toList();

  await link.channel.sendRequest(
    plugin.AnalysisSetPriorityFilesParams(priorityFilesForPlugin),
  );
});

/// A provider for obtaining for link of a specific plugin
final pluginLinkProvider =
    FutureProvider.autoDispose.family<PluginLink, Uri>((ref, linkKey) async {
  final link = await ref.watch(_pluginLinkProvider(linkKey).future);

  // TODO what if setContextRoot or priotity files changes while these
  // requests are pending?

  // TODO refresh lints, such that we don't see previous lints while plugins are rebuilding
  await ref.watch(_versionInitializedProvider(linkKey).future);

  await Future.wait([
    ref.watch(_contextRootInitializedProvider(linkKey).future),
    ref.watch(_priorityFilesInitializedProvider(linkKey).future),
  ]);
  return link;
});

/// The unique key for all active plugins.
final allPluginLinkKeysProvider = Provider.autoDispose<List<Uri>>((ref) {
  final contextRoots = ref.watch(activeContextRootsProvider);

  return contextRoots
      .expand(
        (contextRoot) =>
            ref.watch(pluginMetasForContextRootProvider(contextRoot)),
      )
      .map((e) => e.root)
      .toSet()
      .toList();
});

/// The [PluginLink] of all active plugins.
final allPluginLinksProvider =
    FutureProvider.autoDispose<Map<Uri, Result<PluginLink>>>((ref) async {
  final linkKeys = ref.watch(allPluginLinkKeysProvider);

  final linkEntries = await Future.wait([
    for (final linkKey in linkKeys)
      ref
          .watch(pluginLinkProvider(linkKey).future)
          .then<Result<PluginLink>>(
            Result<PluginLink>.data,
            onError: Result<PluginLink>.error,
          )
          .then((e) => MapEntry(linkKey, e)),
  ]);

  return Map.fromEntries(linkEntries);
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
