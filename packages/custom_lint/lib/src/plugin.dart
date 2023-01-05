/// A library destined for utilities related to custom_lint plugins
library plugin;

import 'dart:io';

import 'package:analyzer_plugin/protocol/protocol_generated.dart'
    show ContextRoot;
import 'package:meta/meta.dart';
import 'package:package_config/package_config.dart';
import 'package:path/path.dart' as p;
import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:riverpod/riverpod.dart';

List<Package> getPackageListForContextRoots(List<ContextRoot> contextRoots) {
  final container = ProviderContainer();
  try {
    container.read(activeContextRootsProvider.notifier).state = contextRoots;

    final keysSub = container.listen(
      allPluginLinkKeysProvider,
      (previous, next) {},
    );

    return keysSub
        .read()
        .map((e) => container.read(pluginMetaProvider(e)))
        .toList();
  } finally {
    container.dispose();
  }
}

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

/// The context roots that a plugin is currently analyzing
final contextRootsForPluginProvider =
    Provider.autoDispose.family<List<ContextRoot>, PluginKey>(
  (ref, packageUri) {
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

/// The context roots currently active
final activeContextRootsProvider = StateProvider<List<ContextRoot>>(
  (ref) => [],
);

/// Package informations for the plugin
final pluginMetaProvider =
    Provider.autoDispose.family<Package, PluginKey>((ref, linkKey) {
  final contextRoot = ref.watch(contextRootsForPluginProvider(linkKey)).first;

  return ref
      .watch(pluginMetasForContextRootProvider(contextRoot))
      .firstWhere((element) => PluginKey(element.root) == linkKey);
});

/// The unique key for all active plugins.
final allPluginLinkKeysProvider = Provider.autoDispose<List<PluginKey>>((ref) {
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

/// The list of plugins associated with a context root.
final pluginMetasForContextRootProvider =
    Provider.autoDispose.family<List<Package>, ContextRoot>((ref, contextRoot) {
  Iterable<Package> _getPluginsForContext(
    ContextRoot contextRoot,
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
