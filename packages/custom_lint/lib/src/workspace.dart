import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/analysis/context_locator.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:collection/collection.dart';
import 'package:package_config/package_config.dart';
import 'package:path/path.dart';
import 'package:pubspec_parse/pubspec_parse.dart';

import 'v2/server_to_client_channel.dart';

String _computePubspec(Iterable<String> plugins) {
  // TODO handle environment constraints conflicts.
  final dependencies = plugins.map((plugin) => '  $plugin: any').join();

  return '''
name: custom_lint_client
version: 0.0.1
publish_to: 'none'

environment:
  sdk: '>=2.17.1 <3.0.0'

dependencies:
$dependencies
''';
}

/// Generate a package_config.json combining all the dependencies from all
/// the contextRoots.
///
/// This also changes relative paths into absolute paths.
String _computePackageConfigForTempProject(List<String> contextRoots) {
  final packageMap = <String, Package>{};
  final conflictingPackagesChecker = ConflictingPackagesChecker();
  for (final contextRoot in contextRoots) {
    // TODO Refactor to use async IO operations and Future.wait
    final contextRootPackageConfigUri = Uri.file(
      join(contextRoot, '.dart_tool', 'package_config.json'),
    );
    final packageConfigFile = File.fromUri(contextRootPackageConfigUri);
    final contextRootPubspecFile = File(
      join(contextRoot, 'pubspec.yaml'),
    );

    final packageConfigContent = packageConfigFile.readAsStringSync();
    final packageConfig = PackageConfig.parseString(
      packageConfigContent,
      contextRootPackageConfigUri,
    );

    final pubspecContent = contextRootPubspecFile.readAsStringSync();
    final pubspec = Pubspec.parse(
      pubspecContent,
      sourceUrl: contextRootPubspecFile.uri,
    );
    final validPackages = [
      for (final package in packageConfig.packages)
        // Don't include the project that has a plugin enabled in the list
        // of dependencies of the plugin.
        // This avoids the plugin from being hot-reloaded when the analyzed
        // code changes.
        if (package.name != pubspec.name) package
    ];

    // Add the contextRoot and its packages to the conflicting packages checker
    conflictingPackagesChecker.addContextRoot(
      contextRoot,
      validPackages,
      pubspec,
    );

    for (final package in validPackages) {
      packageMap[package.name] = package;
    }
  }

  // Check if there are conflicting packages
  conflictingPackagesChecker.throwErrorIfConflictingPackages();

  return jsonEncode(<String, Object?>{
    'configVersion': 2,
    'generated': DateTime.now().toIso8601String(),
    'generator': 'custom_lint',
    'generatorVersion': '0.0.1',
    'packages': <Object?>[
      for (final package in packageMap.values)
        <String, String>{
          'name': package.name,
          // This is somehow enough to change relative paths into absolute ones.
          // It seems that PackageConfig.parse already converts the paths into
          // absolute ones.
          'rootUri': package.root.toString(),
          'packageUri': package.packageUriRoot.toString(),
          'languageVersion': package.languageVersion.toString(),
          'extraData': package.extraData.toString(),
        }
    ],
  });
}

/// The holder of metadatas related to the enabled plugins and analyzed projects.
class CustomLintWorkspace {
  /// Creates a new workspace.
  CustomLintWorkspace._(
    this.projects,
    this.contextRoots,
  );

  /// Initializes the custom_lint workspace from a directory.
  static Future<CustomLintWorkspace> fromDirectory(Directory directory) async {
    final contextLocator = ContextLocator(
      resourceProvider: PhysicalResourceProvider.INSTANCE,
    );
    final allContextRoots = contextLocator.locateRoots(
      includedPaths: [directory.path],
    );

    return fromContextRoots(
      allContextRoots.map((e) => e.root.path).toList(),
    );
  }

  /// Initializes the custom_lint workspace from a compilation of context roots.
  static Future<CustomLintWorkspace> fromContextRoots(
    List<String> contextRoots,
  ) async {
    final cache = CustomLintPluginCheckerCache();
    final projects = await Future.wait([
      for (final contextRoot in contextRoots)
        CustomLintProject.parse(Directory(contextRoot), cache),
    ]);

    return CustomLintWorkspace._(
      projects,
      contextRoots,
    );
  }

  /// The list of analyzed projects.
  final List<String> contextRoots;

  /// The list of analyzed projects.
  final List<CustomLintProject> projects;

  /// Create the Dart project which will contain all the custom_lint plugins.
  Future<Directory> createPluginHostDirectory() async {
    final packageConfigContent = _computePackageConfigForTempProject(
      contextRoots,
    );
    // The previous line will throw if there are conflicting packages.
    // So it is safe to deduplicate the plugins by name here.
    final pubspecContent = _computePubspec(
      projects.expand((e) => e.plugins).map((e) => e.name).toSet(),
    );

    // We only create the temporary directories after computing all the files.
    // This avoids creating a temporary directory if we're going to throw anyway.
    final tempDir = Directory.systemTemp.createTempSync('custom_lint_client');
    final pubspecFile = File(join(tempDir.path, 'pubspec.yaml'));
    final packageConfigFile = File(
      join(tempDir.path, '.dart_tool', 'package_config.json'),
    );

    await Future.wait([
      pubspecFile.writeAsString(pubspecContent),
      packageConfigFile.writeAsString(packageConfigContent),
    ]);

    return tempDir;
  }
}

/// An util for detecting if a project is a custom_lint plugin.
class CustomLintPluginCheckerCache {
  final _cache = <String, Future<bool>>{};

  /// Returns `true` if the project at [path] is a custom_lint plugin.
  ///
  /// A project is considered a custom_lint plugin if it has a dependency on
  /// `custom_lint_builder`.
  Future<bool> isPlugin(String path) {
    final cached = _cache[path];
    if (cached != null) return cached;

    return _cache[path] = Future(() async {
      final pubspec = await _parsePubspec(path);

      // TODO test that dependency_overrides & dev_dependencies aren't checked.
      return pubspec.dependencies.containsKey('custom_lint_builder');
    });
  }
}

Future<Pubspec> _parsePubspec(String path) async {
  final pubspecFile = File(join(path, 'pubspec.yaml'));
  final pubspecContent = pubspecFile.readAsString();

  return Pubspec.parse(await pubspecContent, sourceUrl: pubspecFile.uri);
}

Future<PackageConfig> _parsePackageConfig(String path) async {
  final packageConfigFile = File(
    join(path, '.dart_tool', 'package_config.json'),
  );
  final packageConfigContent = packageConfigFile.readAsBytes();

  return PackageConfig.parseBytes(
    await packageConfigContent,
    packageConfigFile.uri,
  );
}

/// A project analyzed by custom_lint, with its enabled plugins.
class CustomLintProject {
  CustomLintProject._({
    required this.plugins,
    required this.directory,
  });

  /// Decode a [CustomLintProject] from a directory.
  static Future<CustomLintProject> parse(
    Directory directory,
    CustomLintPluginCheckerCache cache,
  ) async {
    final pubspecFuture = _parsePubspec(directory.path);
    final packageConfigFuture = _parsePackageConfig(directory.path);

    final pubspec = await pubspecFuture;
    final packageConfig = await packageConfigFuture;

    // TODO check that only dev_dependencies are checked
    final plugins = await Future.wait(
      pubspec.devDependencies.entries.map((e) async {
        final dependencyPath = packageConfig.packages
            .firstWhereOrNull((p) => p.name == e.key)
            ?.root
            .path;
        if (dependencyPath == null) return null;

        final isPlugin = await cache.isPlugin(dependencyPath);
        if (!isPlugin) return null;

        return CustomLintPlugin._(
          name: e.key,
          resolvedPluginPath: dependencyPath,
          constraint: PubspecDependency.fromDependency(e.value),
        );
      }),
    );

    return CustomLintProject._(
      plugins: plugins.whereNotNull().toList(),
      directory: directory,
    );
  }

  /// The folder of the project being analyzed.
  final Directory directory;

  /// The enabled plugins for this project.
  final List<CustomLintPlugin> plugins;
}

/// A custom_lint plugin and its version constraints.
class CustomLintPlugin {
  CustomLintPlugin._({
    required this.name,
    required this.resolvedPluginPath,
    required this.constraint,
  });

  /// The plugin name.
  final String name;

  /// The file system location of where the plugin is location according to the
  /// project's package_config.json.
  final String resolvedPluginPath;

  /// The version constraints in the project's `pubspec.yaml`.
  final PubspecDependency constraint;
}

/// A dependency in a `pubspec.yaml`.
abstract class PubspecDependency {
  const PubspecDependency._();

  /// A dependency using `git`
  factory PubspecDependency.fromGitDependency(GitDependency dependency) =
      _GitPubspecDependency;

  /// A path dependency.
  factory PubspecDependency.fromPathDependency(PathDependency dependency) =
      _PathPubspecDependency;

  /// A dependency using `hosted` (pub.dev)
  factory PubspecDependency.fromHostedDependency(HostedDependency dependency) =
      _HostedPubspecDependency;

  /// A dependency using `sdk`
  factory PubspecDependency.fromSdkDependency(SdkDependency dependency) =
      _SdkPubspecDependency;

  /// Automatically converts any [Dependency] into a [PubspecDependency].
  factory PubspecDependency.fromDependency(Dependency dependency) {
    if (dependency is HostedDependency) {
      return PubspecDependency.fromHostedDependency(dependency);
    } else if (dependency is GitDependency) {
      return PubspecDependency.fromGitDependency(dependency);
    } else if (dependency is PathDependency) {
      return PubspecDependency.fromPathDependency(dependency);
    } else if (dependency is SdkDependency) {
      return PubspecDependency.fromSdkDependency(dependency);
    } else {
      throw ArgumentError.value(dependency, 'dependency', 'Unknown dependency');
    }
  }

  /// Checks whether this and [dependency] can both be resolved at the same time.
  ///
  /// For example, "^1.0.0" is not compatible with "^2.0.0", but "^1.0.0" is
  /// compatible with "^1.1.0" (and vice-versa).
  bool isCompatibleWith(PubspecDependency dependency);

  /// Returns the intersection of this and [dependency], or `null` if they are
  /// not compatible.
  PubspecDependency? intersect(PubspecDependency dependency) {
    if (!isCompatibleWith(dependency)) return null;

    return dependency;
  }
}

class _GitPubspecDependency extends PubspecDependency {
  _GitPubspecDependency(this.dependency) : super._();

  final GitDependency dependency;

  @override
  bool isCompatibleWith(PubspecDependency dependency) {
    return dependency is _GitPubspecDependency &&
        this.dependency.url == dependency.dependency.url &&
        this.dependency.ref == dependency.dependency.ref &&
        this.dependency.path == dependency.dependency.path;
  }
}

class _PathPubspecDependency extends PubspecDependency {
  _PathPubspecDependency(this.dependency) : super._();

  final PathDependency dependency;

  @override
  bool isCompatibleWith(PubspecDependency dependency) {
    return dependency is _PathPubspecDependency &&
        this.dependency.path == dependency.dependency.path;
  }
}

class _HostedPubspecDependency extends PubspecDependency {
  _HostedPubspecDependency(this.dependency) : super._();

  final HostedDependency dependency;

  @override
  bool isCompatibleWith(PubspecDependency dependency) {
    return dependency is _HostedPubspecDependency &&
        this.dependency.hosted?.name == dependency.dependency.hosted?.name &&
        this.dependency.hosted?.url == dependency.dependency.hosted?.url &&
        this.dependency.version.allowsAny(dependency.dependency.version);
  }

  @override
  PubspecDependency? intersect(PubspecDependency dependency) {
    if (!isCompatibleWith(dependency)) return null;

    dependency as _HostedPubspecDependency;
    return _HostedPubspecDependency(
      HostedDependency(
        hosted: this.dependency.hosted,
        version: this.dependency.version.intersect(
              dependency.dependency.version,
            ),
      ),
    );
  }
}

class _SdkPubspecDependency extends PubspecDependency {
  _SdkPubspecDependency(this.dependency) : super._();

  final SdkDependency dependency;

  @override
  bool isCompatibleWith(PubspecDependency dependency) {
    return dependency is _SdkPubspecDependency &&
        this.dependency.sdk == dependency.dependency.sdk;
  }
}
