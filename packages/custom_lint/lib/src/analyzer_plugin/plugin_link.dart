import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:analyzer_plugin/protocol/protocol_generated.dart' as plugin;
import 'package:async/async.dart' show StreamGroup;
import 'package:meta/meta.dart';
import 'package:package_config/package_config.dart';
import 'package:path/path.dart' as p;
import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:riverpod/riverpod.dart';

import '../protocol/internal_protocol.dart';
import '../riverpod_utils.dart';
import 'result.dart';
import 'server_isolate_channel.dart';

/// A unique key for a custom_lint plugin
@immutable
class PluginKey {
  /// A unique key for a custom_lint plugin
  const PluginKey(this.uri);

  /// The root uri of a plugin
  final Uri uri;

  @override
  String toString() => uri.toString();

  @override
  int get hashCode => uri.hashCode;

  @override
  bool operator ==(Object other) => other is PluginKey && other.uri == uri;
}

final _pluginSourceChangeProvider =
    StreamProvider.autoDispose.family<void, PluginKey>((ref, pluginRootUri) {
  if (ref.watch(watchModeProvider)) {
    // Watch mode already takes care of reloading plugins. So doing a hot-restart
    // on source change would only slow down hot-reload.
    return const Stream.empty();
  }

  ref.cache5();
  final pluginRootPath = pluginRootUri.uri.toFilePath();

  /// Don't watch source unless in development.
  // TODO test
  if (pluginRootPath.contains('.pub-cache')) return const Stream.empty();

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

/// The `package_config.json` location for a given plugin.
///
/// This isn't necesserily pointing to `plugin/.dart_tool/package_config.json`
/// as plugins when published on pub or git often don't contain the `.dart_tool`
/// folder.
///
/// In this scenario, the URI points to the application that uses the plugin instead.
Uri _findRootPackageConfigFromContextRoots(
  List<plugin.ContextRoot> contextRoots, {
  required String pluginName,
}) {
  // TODO(rrousselGit) if multiple applications depend on the same plugin
  // but use different package_config configurations, something unexpected
  // might happen.

  if (contextRoots.isEmpty) {
    throw StateError(
      'Failed to find package_config.json for the plugin $pluginName',
    );
  }

  return Uri.file(
    p.join(contextRoots.first.root, '.dart_tool', 'package_config.json'),
  );
}

final _pluginLinkProvider = FutureProvider.autoDispose
    .family<PluginLink, PluginKey>((ref, pluginRootUri) async {
  ref.cache5();
  ref.watch(_pluginSourceChangeProvider(pluginRootUri));

  final pluginName = ref
      .watch(pluginMetaProvider(pluginRootUri).select((value) => value.name));

  final receivePort = ReceivePort();
  ref.onDispose(receivePort.close);

  final pluginRootPath = pluginRootUri.uri.toFilePath();

  final packageConfig = _findRootPackageConfigFromContextRoots(
    ref.watch(contextRootsForPluginProvider(pluginRootUri)),
    pluginName: pluginName,
  );

  // TODO configure that through build.yaml-like file
  final mainUri = Uri.file(
    p.join(pluginRootPath, 'bin', 'custom_lint.dart'),
  );

  final isolate = await Isolate.spawnUri(
    mainUri,
    const [],
    receivePort.sendPort,
    // WHen published on pub or git, the plugin source often does not have a
    // package_config.json. As such, we manually specify one based on the
    // application that depends on the custom lint plugin.
    // Since the application that uses the plugin depends on said plugin,
    // the applications' package_config should contain everything that the plugin
    // needs to work.
    packageConfig: packageConfig,
    // TODO test error in main (outside of runZonedGuarded)
    debugName: pluginName,
    onError: receivePort.sendPort,
  );

  final link = PluginLink._(
    isolate,
    PluginIsolateChannel(receivePort),
    pluginRootUri.uri,
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
  final PluginIsolateChannel channel;

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
    FutureProvider.autoDispose.family<void, PluginKey>((ref, linkKey) async {
  ref.cache5();
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
    Provider.autoDispose.family<Package, PluginKey>((ref, linkKey) {
  ref.cache5();
  final contextRoot = ref.watch(contextRootsForPluginProvider(linkKey)).first;

  return ref
      .watch(pluginMetasForContextRootProvider(contextRoot))
      .firstWhere((element) => PluginKey(element.root) == linkKey);
});

/// The list of plugins associated with a context root.
final pluginMetasForContextRootProvider = Provider.autoDispose
    .family<List<Package>, plugin.ContextRoot>((ref, contextRoot) {
  ref.cache5();
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
    Provider.autoDispose.family<List<plugin.ContextRoot>, PluginKey>(
  (ref, packageUri) {
    ref.cache5();
    final contextRoots = ref.watch(activeContextRootsProvider);

    return contextRoots
        .where(
          (contextRoot) => ref
              .watch(pluginMetasForContextRootProvider(contextRoot))
              .any((package) => PluginKey(package.root) == packageUri),
        )
        .toList();
  },
);

final _contextRootInitializedProvider =
    FutureProvider.autoDispose.family<void, PluginKey>((ref, linkKey) async {
  ref.cache5();
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
    FutureProvider.autoDispose.family<void, PluginKey>((ref, linkKey) async {
  ref.cache5();
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

/// Config on whether to include plugin status lints or not.
final includeBuiltInLintsProvider = Provider<bool>(
  (ref) => throw UnimplementedError(),
);

/// Config on whether to enable watch mode
final watchModeProvider = Provider<bool>(
  (ref) => throw UnimplementedError(),
);

final _configInitializedProvider =
    FutureProvider.autoDispose.family<void, PluginKey>((ref, linkKey) async {
  ref.cache5();
  final link = await ref.watch(_pluginLinkProvider(linkKey).future);

  await link.channel.sendRequest(
    SetConfigParams(
      includeBuiltInLints: ref.watch(includeBuiltInLintsProvider),
      watchMode: ref.watch(watchModeProvider),
    ),
  );
});

/// A provider for obtaining for link of a specific plugin
final pluginLinkProvider = FutureProvider.autoDispose
    .family<PluginLink, PluginKey>((ref, linkKey) async {
  ref.cache5();
  final link = await ref.watch(_pluginLinkProvider(linkKey).future);

  // Required initializations for the plugin to work, and performed only once
  await Future.wait([
    ref.watch(_versionInitializedProvider(linkKey).future),
    ref.watch(_configInitializedProvider(linkKey).future),
  ]);

  // "optional" initializations which may trigger multiple times and are not
  // necessary to await
  // We use listen as we don't want to rebuild dependents when
  // roots or priority files changes, as the plugin link will stay the same.
  // TODO test
  ref.listen(_contextRootInitializedProvider(linkKey), (previous, next) {});
  ref.listen(_priorityFilesInitializedProvider(linkKey), (previous, next) {});

  return link;
});

/// The unique key for all active plugins.
final allPluginLinkKeysProvider = Provider.autoDispose<List<PluginKey>>((ref) {
  ref.cache5();
  final contextRoots = ref.watch(activeContextRootsProvider);

  return contextRoots
      .expand(
        (contextRoot) =>
            ref.watch(pluginMetasForContextRootProvider(contextRoot)),
      )
      .map((e) => PluginKey(e.root))
      .toSet()
      .toList();
});

/// The [PluginLink] of all active plugins.
final allPluginLinksProvider =
    FutureProvider.autoDispose<Map<PluginKey, Result<PluginLink>>>((ref) async {
  ref.cache5();
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
