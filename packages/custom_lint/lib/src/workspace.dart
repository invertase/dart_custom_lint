import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/analysis/context_locator.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart'
    as analyzer_plugin;
import 'package:async/async.dart';
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:package_config/package_config.dart';
import 'package:path/path.dart';
import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:rxdart/rxdart.dart';
import 'package:yaml/yaml.dart';

import 'package_utils.dart';

String _computePubspec(Iterable<String> plugins) {
  // TODO should import dependency_overrides related to the plugin too
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

/// An exception thrown by [visitAnalysisOptionAndIncludes] when an "include"
/// directive creates a cycle.
class CyclicIncludeException implements Exception {
  CyclicIncludeException._(this.path);

  /// The path that ends-up including itself.
  final String path;

  @override
  String toString() => 'Cyclic include detected: $path';
}

/// Returns a stream of YAML maps obtained by recursively following the "include"
/// keys in an analysis options file, starting from the given [analysisOptionsFile].
///
/// The function yields the YAML map in the original analysis options file first,
/// and then yields the YAML maps in the included files in order.

/// If the analysis options file does not exist or is not a YAML map, or if
/// any included file does not exist or is not a YAML map, the function skips
/// that file and will end execution. If no YAML maps are found in the
/// analysis options file or its included files, the function returns
/// an empty stream.
///
///
/// If an included file contains a "package" URI scheme, the function resolves
/// the URI using the `package_config.json` file in the same directory as the
/// [analysisOptionsFile].
/// If the `package_config.json` file does not exist or the `package_config.json`
/// does not contain the imported package, the function will stop its execution.
///
/// If any included file is visited multiple times, the function throws a
/// [CyclicIncludeException] indicating a cycle in the include graph.
Stream<YamlMap> visitAnalysisOptionAndIncludes(
  File analysisOptionsFile,
) async* {
  final visited = <String>{};
  late final packageConfigFuture = loadPackageConfig(
    File(
      join(analysisOptionsFile.parent.path, '.dart_tool/package_config.json'),
    ),
  ).then<PackageConfig?>(
    (value) => value,
    // On error, return null to not throw. The function later handles the null
    onError: (e, s) => null,
  );

  for (Uri? optionsPath = analysisOptionsFile.uri; optionsPath != null;) {
    final optionsFile = File.fromUri(optionsPath);
    if (!visited.add(optionsFile.path)) {
      // The file was visited multiple times. This is a cycle.
      throw CyclicIncludeException._(optionsFile.path);
    }

    if (!optionsFile.existsSync()) return;

    final yaml = loadYaml(optionsFile.readAsStringSync());
    if (yaml is! YamlMap) return;

    yield yaml;

    final includePath = yaml['include'];
    if (includePath is! String) return;

    final includeUri = Uri.tryParse(includePath);
    if (includeUri == null) return;

    if (includeUri.scheme == 'package') {
      final packageName = includeUri.pathSegments.first;
      final packageConfig = await packageConfigFuture;

      // Search for the package with matching name in packageConfig
      final package = packageConfig?.packages.firstWhereOrNull(
        (package) => package.name == packageName,
      );
      if (package == null) return;

      final packageRoot = Directory.fromUri(package.packageUriRoot);
      final packagePath = join(
        packageRoot.path,
        // Skip the first segment, which is the package name.
        // In package:foo/src/file.dart, we only care about src/file.dart
        joinAll(includeUri.pathSegments.skip(1)),
      );
      optionsPath = Uri.file(packagePath);
      continue;
    }

    optionsPath = optionsPath.resolveUri(includeUri);
  }
}

/// An error thrown when [CustomLintPlugin.visitSelfAndTransitiveDependencies] tries to iterate over
/// the dependencies of a package, but the package cannot be found in
/// the `package_config.json`.
class UnresolvedTransitiveDependencyException implements Exception {
  UnresolvedTransitiveDependencyException._(this.dependencyName);

  /// The dependency that failed to resolve
  final String dependencyName;

  @override
  String toString() {
    return 'Unresolved transitive dependency: $dependencyName. Did you forget to run "pub get"?';
  }
}

/// The holder of metadatas related to the enabled plugins and analyzed projects.
@internal
class CustomLintWorkspace {
  /// Creates a new workspace.
  CustomLintWorkspace._(
    this.projects,
    this.contextRoots,
    this.uniquePluginNames,
  );

  /// Initializes the custom_lint workspace from a directory.
  static Future<CustomLintWorkspace> fromPaths(
    List<String> paths, {
    required Directory workingDirectory,
  }) async {
    final contextLocator = ContextLocator(
      resourceProvider: PhysicalResourceProvider.INSTANCE,
    );
    final allContextRoots = contextLocator.locateRoots(
      includedPaths: paths.map((e) => join(workingDirectory.path, e)).toList(),
    );

    final contextRootsWithCustomLint = await Future.wait(
      allContextRoots.map((contextRoot) async {
        final pubspecFile = Directory(contextRoot.root.path).pubspec;
        if (!pubspecFile.existsSync()) {
          return null;
        }

        final optionFile = contextRoot.optionsFile;
        if (optionFile == null) {
          return null;
        }
        final options = File(optionFile.path);

        final pluginDefinition = await _isCustomLintEnabled(options);
        if (!pluginDefinition) {
          return null;
        }

        // TODO test
        return analyzer_plugin.ContextRoot(
          contextRoot.root.path,
          contextRoot.excluded.map((e) => e.path).toList(),
          optionsFile: contextRoot.optionsFile?.path,
        );
      }),
    );

    return fromContextRoots(
      contextRootsWithCustomLint.whereNotNull().toList(),
    );
  }

  static Future<bool> _isCustomLintEnabled(File options) async {
    final enabledPlugins = await visitAnalysisOptionAndIncludes(options)
        .map((event) {
          final analyzerMap = event['analyzer'];
          if (analyzerMap is! YamlMap) return null;
          return analyzerMap['plugins'];
        })
        .whereNotNull()
        .firstOrNull;

    if (enabledPlugins is! YamlList) return false;

    return enabledPlugins.contains('custom_lint');
  }

  /// Initializes the custom_lint workspace from a compilation of context roots.
  static Future<CustomLintWorkspace> fromContextRoots(
    List<analyzer_plugin.ContextRoot> contextRoots,
  ) async {
    final cache = CustomLintPluginCheckerCache();
    final projects = await Future.wait([
      for (final contextRoot in contextRoots)
        CustomLintProject.parse(contextRoot, cache),
    ]);

    final uniquePluginNames =
        projects.expand((e) => e.plugins).map((e) => e.name).toSet();

    return CustomLintWorkspace._(projects, contextRoots, uniquePluginNames);
  }

  /// The list of analyzed projects.
  final List<analyzer_plugin.ContextRoot> contextRoots;

  /// The list of analyzed projects.
  final List<CustomLintProject> projects;

  /// The names of all enabled plugins.
  final Set<String> uniquePluginNames;

  /// Generate a package_config.json combining all the dependencies from all
  /// the contextRoots.
  ///
  /// This also changes relative paths into absolute paths.
  String _computePackageConfigForTempProject() {
    final conflictingPackagesChecker = ConflictingPackagesChecker();

    Iterable<Package> visitPluginsAndDependencies() sync* {
      final visitedPackages = <String>{};

      for (final project in projects) {
        for (final plugin in project.plugins) {
          final packages = plugin.visitSelfAndTransitiveDependencies(
            // This ensures that we do not visit nor parse the same package twice.
            shouldVisit: (package) => visitedPackages.add(package.root.path),
          );

          for (final package in packages) {
            conflictingPackagesChecker.addPluginPackage(
              project,
              plugin,
              package,
            );
            yield package;
          }
        }
      }
    }

    final result = jsonEncode(<String, Object?>{
      'configVersion': 2,
      'generated': DateTime.now().toIso8601String(),
      'generator': 'custom_lint',
      'generatorVersion': '0.0.1',
      'packages': <Object?>[
        for (final dependency in visitPluginsAndDependencies())
          {
            'name': dependency.name,
            // This is somehow enough to change relative paths into absolute ones.
            // It seems that PackageConfig.parse already converts the paths into
            // absolute ones.
            'rootUri': dependency.root.toString(),
            'packageUri': dependency.packageUriRoot.toString(),
            'languageVersion': dependency.languageVersion.toString(),
            'extraData': dependency.extraData.toString(),
          }
      ],
    });

    // Check if there are conflicting packages.
    // We do so after computing the result to avoid allocating a temporary
    // list of packages, by visiting dependencies using an Iterable instead of List.
    conflictingPackagesChecker.throwErrorIfConflictingPackages();

    return result;
  }

  /// Create the Dart project which will contain all the custom_lint plugins.
  Future<Directory> createPluginHostDirectory() async {
    final packageConfigContent = _computePackageConfigForTempProject();
    // The previous line will throw if there are conflicting packages.
    // So it is safe to deduplicate the plugins by name here.
    final pubspecContent = _computePubspec(uniquePluginNames);

    // We only create the temporary directories after computing all the files.
    // This avoids creating a temporary directory if we're going to throw anyway.
    final tempDir = Directory.systemTemp.createTempSync('custom_lint_client');
    final pubspecFile = tempDir.pubspec;
    final packageConfigFile = tempDir.packageConfig;

    await Future.wait([
      pubspecFile
          .create(recursive: true)
          .then((_) => pubspecFile.writeAsString(pubspecContent)),
      Future(() async {
        await packageConfigFile.create(recursive: true);
        await packageConfigFile.writeAsString(packageConfigContent);
      }),
    ]);

    return tempDir;
  }
}

/// An util for detecting if a project is a custom_lint plugin.
@internal
class CustomLintPluginCheckerCache {
  final _cache = <Directory, Future<bool>>{};

  /// Returns `true` if the project at [directory] is a custom_lint plugin.
  ///
  /// A project is considered a custom_lint plugin if it has a dependency on
  /// `custom_lint_builder`.
  Future<bool> isPlugin(Directory directory) {
    final cached = _cache[directory];
    if (cached != null) return cached;

    return _cache[directory] = Future(() async {
      final pubspec = await parsePubspec(directory);

      // TODO test that dependency_overrides & dev_dependencies aren't checked.
      return pubspec.dependencies.containsKey('custom_lint_builder');
    });
  }
}

/// No pubspec.yaml file was found for a plugin.
@internal
class PubspecParseError extends Error {
  PubspecParseError._(
    this.path, {
    required this.error,
    required this.errorStackTrace,
  });

  /// The path where the pubspec.yaml file was expected.
  final String path;

  /// The inner error that was thrown when trying to parse the pubspec.
  final Object error;

  /// The stacktrace of [error].
  final StackTrace errorStackTrace;

  @override
  String toString() {
    return 'Failed to read pubspec.yaml at $path:\n'
        '$error\n'
        '$errorStackTrace';
  }
}

/// No .dart_tool/package_config.json file was found for a plugin.
@internal
class PackageConfigParseError extends Error {
  PackageConfigParseError._(
    this.path, {
    required this.error,
    required this.errorStackTrace,
  });

  /// The path where the pubspec.yaml file was expected.
  final String path;

  /// The inner error that was thrown when trying to parse the pubspec.
  final Object error;

  /// The stacktrace of [error].
  final StackTrace errorStackTrace;

  @override
  String toString() =>
      'Failed to decode .dart_tool/package_config.json at $path. '
      'Make sure to run `pub get` first.\n'
      '$error\n'
      '$errorStackTrace';
}

/// The plugin was not found in the package config.
@internal
class PluginNotFoundInPackageConfigError extends Error {
  PluginNotFoundInPackageConfigError._(this.name, this.path);

  /// The name of the plugin.
  final String name;

  /// The path where the pubspec.yaml file was expected.
  final String path;

  @override
  String toString() => 'The plugin $name was not found in the package config '
      'at $path. Make sure to run `pub get` first.';
}

/// A project analyzed by custom_lint, with its enabled plugins.
@internal
class CustomLintProject {
  CustomLintProject._({
    required this.plugins,
    required this.directory,
    required this.packageConfig,
    required this.pubspec,
  });

  /// Decode a [CustomLintProject] from a directory.
  static Future<CustomLintProject> parse(
    analyzer_plugin.ContextRoot contextRoot,
    CustomLintPluginCheckerCache cache,
  ) async {
    final directory = Directory(contextRoot.root);

    // ignore() the errors as we want to throw a custom error.
    final pubspecFuture = parsePubspec(directory)..ignore();
    final packageConfigFuture = parsePackageConfig(directory)..ignore();

    final pubspec =
        // ignore: avoid_types_on_closure_parameters
        await pubspecFuture.catchError((Object err, StackTrace stack) {
      throw PubspecParseError._(
        directory.path,
        error: err,
        errorStackTrace: stack,
      );
    });
    final packageConfig =
        // ignore: avoid_types_on_closure_parameters
        await packageConfigFuture.catchError((Object err, StackTrace stack) {
      throw PackageConfigParseError._(
        directory.path,
        error: err,
        errorStackTrace: stack,
      );
    });

    // TODO check that only dev_dependencies are checked
    final plugins = await Future.wait(
      pubspec.devDependencies.entries.map((e) async {
        final packageWithName =
            packageConfig.packages.firstWhereOrNull((p) => p.name == e.key);
        if (packageWithName == null) {
          throw PluginNotFoundInPackageConfigError._(e.key, directory.path);
        }

        final packageDirectory = Directory(packageWithName.root.path);
        final isPlugin = await cache.isPlugin(packageDirectory);
        if (!isPlugin) return null;

        // TODO test error
        final pubspec = await parsePubspec(packageDirectory);

        return CustomLintPlugin._(
          name: e.key,
          directory: packageDirectory,
          pubspec: pubspec,
          package: packageWithName,
          constraint: PubspecDependency.fromDependency(e.value),
          ownerPackageConfig: packageConfig,
        );
      }),
    );

    return CustomLintProject._(
      plugins: plugins.whereNotNull().toList(),
      directory: directory,
      packageConfig: packageConfig,
      pubspec: pubspec,
    );
  }

  /// The resolved package_config.json at the moment of parsing.
  final PackageConfig packageConfig;

  /// The pubspec.yaml at the moment of parsing.
  final Pubspec pubspec;

  /// The folder of the project being analyzed.
  final Directory directory;

  /// The enabled plugins for this project.
  final List<CustomLintPlugin> plugins;
}

/// A custom_lint plugin and its version constraints.
@internal
class CustomLintPlugin {
  CustomLintPlugin._({
    required this.name,
    required this.directory,
    required this.constraint,
    required this.ownerPackageConfig,
    required this.package,
    required this.pubspec,
  });

  /// The plugin name.
  final String name;

  /// The directory containing the source of the plugin according to the
  /// project's package_config.json.
  ///
  /// See also [ownerPackageConfig].
  final Directory directory;

  /// The resolved pubspec.yaml of the plugin.
  final Pubspec pubspec;

  /// The resolved package_config.json metadata of this plugin.
  ///
  /// This can be found in [ownerPackageConfig].
  final Package package;

  /// The resolved package_config.json of the project which depends on this plugin.
  final PackageConfig ownerPackageConfig;

  /// The version constraints in the project's `pubspec.yaml`.
  final PubspecDependency constraint;

  /// Returns an iterable of the transitive dependencies of a Dart project
  /// located at the given [directory]. The function uses the `pubspec.yaml`
  /// and `package_config.json` files of the project to resolve the
  /// transitive dependencies.
  ///
  /// The function uses a breadth-first search algorithm to traverse the
  /// dependency tree. The root project's dependencies are processed first,
  /// followed by their transitive dependencies, and so on.
  ///
  /// The function will only visit a dependency if the [shouldVisit] function
  /// returns `true`.
  /// If it returns `false`, the dependency and all of its transitive
  /// dependencies will be skipped.
  ///
  /// If a transitive dependency cannot be resolved (i.e., it is not listed
  /// in the `package_config.json` file), the function throws an
  /// [UnresolvedTransitiveDependencyException].
  ///
  /// The function will also throw if a pubspec/package_config.json could not
  /// be decoded, such as if the file is missing or incorrectly formatted.
  ///
  /// Example usage:
  /// ```dart
  /// final dependencies = _listTransitiveDependencies('/path/to/my/project').toList();
  /// ```
  Iterable<Package> visitSelfAndTransitiveDependencies({
    required bool Function(Package) shouldVisit,
  }) sync* {
    if (!shouldVisit(package)) return;
    yield package;

    // A map of of the packages defined in package_config.json for fast lookup.
    // This avoids an O(n^2) lookup in the loop below.
    final packages = Map.fromEntries(
      ownerPackageConfig.packages.map((e) => MapEntry(e.name, e)),
    );

    final dependenciesToVisit =
        ListQueue<String>.from(pubspec.dependencies.keys);
    // TODO test that dev_dependencies and dependency_overrides are visited on the
    // root projects but not on the transitive dependencies
    dependenciesToVisit.addAll(pubspec.devDependencies.keys);
    dependenciesToVisit.addAll(pubspec.dependencyOverrides.keys);

    /// The set of already visited pubspecs
    final visited = <String>{};

    while (dependenciesToVisit.isNotEmpty) {
      // Check if the dependency is already visited
      final dependency = dependenciesToVisit.removeFirst();
      if (visited.add(dependency)) continue;

      // Emit the dependency's package metadata.
      final package = packages[dependency];
      if (package == null) {
        throw UnresolvedTransitiveDependencyException._(dependency);
      }

      if (!shouldVisit(package)) continue;
      yield package;

      /// Now queue the dependencies of the dependency to be emitted too.
      final packageDir = Directory.fromUri(package.root);
      // TODO test error
      final dependencyPubspec = parsePubspecSync(packageDir);
      dependenciesToVisit.addAll(dependencyPubspec.dependencies.keys);
    }
  }
}

/// A dependency in a `pubspec.yaml`.
///
/// This is used for easy comparison between the constraints of the same
/// plugin used by different projects.
///
/// See also [intersect] and [isCompatibleWith].
@internal
abstract class PubspecDependency {
  const PubspecDependency._();

  /// A dependency using `git`
  factory PubspecDependency.fromGitDependency(GitDependency dependency) =
      GitPubspecDependency;

  /// A path dependency.
  factory PubspecDependency.fromPathDependency(PathDependency dependency) =
      PathPubspecDependency;

  /// A dependency using `hosted` (pub.dev)
  factory PubspecDependency.fromHostedDependency(HostedDependency dependency) =
      HostedPubspecDependency;

  /// A dependency using `sdk`
  factory PubspecDependency.fromSdkDependency(SdkDependency dependency) =
      SdkPubspecDependency;

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

  /// Builds a short description of this dependency.
  String buildShortDescription();

  /// Checks whether this and [dependency] can both be resolved at the same time.
  ///
  /// For example, "^1.0.0" is not compatible with "^2.0.0", but "^1.0.0" is
  /// compatible with "^1.1.0" (and vice-versa).
  bool isCompatibleWith(PubspecDependency dependency);

  /// Returns the intersection of this and [dependency], or `null` if they are
  /// not compatible.
  PubspecDependency? intersect(PubspecDependency dependency) {
    if (!isCompatibleWith(dependency)) return null;

    // ignore: avoid_returning_this
    return this;
  }
}

/// A dependency using `git`.
class GitPubspecDependency extends PubspecDependency {
  /// A dependency using `git`.
  GitPubspecDependency(this.dependency) : super._();

  /// The original git dependency
  final GitDependency dependency;

  @override
  String buildShortDescription() {
    final versionBuilder = StringBuffer();
    versionBuilder.write('From git url ${dependency.url}');
    final dependencyRef = dependency.ref;
    if (dependencyRef != null) {
      versionBuilder.write(' ref $dependencyRef');
    }
    final dependencyPath = dependency.path;
    if (dependencyPath != null) {
      versionBuilder.write(' path $dependencyPath');
    }
    return versionBuilder.toString();
  }

  @override
  bool isCompatibleWith(PubspecDependency dependency) {
    return dependency is GitPubspecDependency &&
        this.dependency.url == dependency.dependency.url &&
        this.dependency.ref == dependency.dependency.ref &&
        this.dependency.path == dependency.dependency.path;
  }
}

/// A dependency using `path`
class PathPubspecDependency extends PubspecDependency {
  /// A dependency using `path`
  PathPubspecDependency(this.dependency) : super._();

  /// The original path dependency
  final PathDependency dependency;

  @override
  bool isCompatibleWith(PubspecDependency dependency) {
    return dependency is PathPubspecDependency &&
        this.dependency.path == dependency.dependency.path;
  }

  @override
  String buildShortDescription() => 'From path ${dependency.path}';
}

/// A dependency using `hosted` (pub.dev)
class HostedPubspecDependency extends PubspecDependency {
  /// A dependency using `hosted` (pub.dev)
  HostedPubspecDependency(this.dependency) : super._();

  /// The original hosted dependency
  final HostedDependency dependency;

  @override
  String buildShortDescription() {
    return 'Hosted with version constraint: ${dependency.version}';
  }

  @override
  bool isCompatibleWith(PubspecDependency dependency) {
    return dependency is HostedPubspecDependency &&
        this.dependency.hosted?.name == dependency.dependency.hosted?.name &&
        this.dependency.hosted?.url == dependency.dependency.hosted?.url &&
        this.dependency.version.allowsAny(dependency.dependency.version);
  }

  @override
  PubspecDependency? intersect(PubspecDependency dependency) {
    if (!isCompatibleWith(dependency)) return null;

    dependency as HostedPubspecDependency;
    return HostedPubspecDependency(
      HostedDependency(
        hosted: this.dependency.hosted,
        version: this.dependency.version.intersect(
              dependency.dependency.version,
            ),
      ),
    );
  }
}

/// A dependency using `sdk`
class SdkPubspecDependency extends PubspecDependency {
  /// A dependency using `sdk`
  SdkPubspecDependency(this.dependency) : super._();

  /// The original sdk dependency
  final SdkDependency dependency;

  @override
  bool isCompatibleWith(PubspecDependency dependency) {
    return dependency is SdkPubspecDependency &&
        this.dependency.sdk == dependency.dependency.sdk;
  }

  @override
  String buildShortDescription() {
    return 'From SDK: ${dependency.sdk}';
  }
}

class _ConflictEntry {
  _ConflictEntry(this.plugin, this.project, this.package);

  final CustomLintPlugin plugin;
  final CustomLintProject project;
  final Package package;

  /// Whether [package] is the plugin itself.
  bool get _isPlugin => package.name == plugin.name;

  String get _name => package.name;

  PubspecDependency _dependency() {
    if (_isPlugin) return plugin.constraint;

    final dependency = plugin.pubspec.getDependency(package.name);
    if (dependency == null) {
      // TODO test error
      throw ArgumentError(
        'Plugin ${plugin.name} does not depend on package ${package.name}',
      );
    }

    return PubspecDependency.fromDependency(dependency);
  }

  String buildConflictHeader() {
    if (_isPlugin) {
      return 'Plugin $_name:';
    }
    return 'Package $_name:';
  }

  String buildConflictingMessage() {
    return '''
- ${_dependency().buildShortDescription()}
  Resolved with ${package.root.toFilePath()}
  Used by project "${project.pubspec.name}" at ${project.directory.path}''';
  }
}

/// A class that checks if there are conflicting packages in the context roots.
@internal
class ConflictingPackagesChecker {
  final _entries = <_ConflictEntry>[];

  /// Adds a [contextRoot] and its [packages] to the checker.
  /// We need to pass the [pubspec] to check if the package is a git dependency
  /// and to check if the context root is a flutter package.
  void addPluginPackage(
    CustomLintProject project,
    CustomLintPlugin plugin,
    Package package,
  ) {
    _entries.add(
      _ConflictEntry(
        plugin,
        project,
        package,
      ),
    );
  }

  /// Throws an error if there are conflicting packages.
  void throwErrorIfConflictingPackages() {
    final packageNameRootMap = <String, Set<Uri>>{};
    // Group packages by name and collect all unique roots,
    // since we're using a set
    for (final entry in _entries) {
      final entriesForName = packageNameRootMap[entry.package.name] ??= {};
      entriesForName.add(entry.package.root);
    }

    // Find packages with more than one root
    final packagesWithConflictingVersions = packageNameRootMap.entries
        .where((entry) => entry.value.length > 1)
        .map((e) => e.key)
        .toSet();

    // If there are no conflicting versions, return
    if (packagesWithConflictingVersions.isEmpty) return;

    throw PackageVersionConflictError._(
      packagesWithConflictingVersions,
      _entries,
    );
  }
}

class PackageVersionConflictError extends Error {
  PackageVersionConflictError._(
    this._packagesWithConflictingVersions,
    this._entries,
  );

  final Set<String> _packagesWithConflictingVersions;
  final List<_ConflictEntry> _entries;

  @override
  String toString() {
    final conflictingEntriesByPackages = Map.fromEntries(
      _packagesWithConflictingVersions.map(
        (packageName) => MapEntry(
          packageName,
          _entries.where((entry) => entry.package.name == packageName).toList(),
        ),
      ),
    );

    final errorMessageBuilder = StringBuffer('''
PackageVersionConflictError – Some dependencies with conflicting versions were identified:

''');

    // Build conflicting packages message
    for (final conflictingEntriesForPackage
        in conflictingEntriesByPackages.values) {
      errorMessageBuilder.writeln(
        conflictingEntriesForPackage.first.buildConflictHeader(),
      );
      for (final conflictEntry in conflictingEntriesForPackage) {
        errorMessageBuilder.writeln(conflictEntry.buildConflictingMessage());
      }
      errorMessageBuilder.writeln();
    }

    errorMessageBuilder
      ..writeln(
        'This is not supported. Custom_lint shares the analysis between all'
        ' packages. As such, all plugins are started under a single process,'
        ' sharing the dependencies of all the packages that use custom_lint. '
        "Since there's a single process for all plugins, if 2 plugins try to"
        ' use different versions for a dependency, the process cannot be '
        'reasonably started. Please make sure all packages have the same version.',
      )
      ..writeln('You could run the following commands to try fixing this:')
      ..writeln();

    // Organize conflicting packages by project instead of by name
    final conflictingEntriesByProjects =
        <CustomLintProject, List<_ConflictEntry>>{};
    for (final conflictingEntriesForPackage
        in conflictingEntriesByPackages.values) {
      for (final conflictEntry in conflictingEntriesForPackage) {
        final project = conflictEntry.project;
        final projectConflictingEntries =
            conflictingEntriesByProjects[project] ?? [];
        projectConflictingEntries.add(conflictEntry);
        conflictingEntriesByProjects[project] = projectConflictingEntries;
      }
    }

    // Build fix commands
    for (final conflictingEntriesForProject
        in conflictingEntriesByProjects.entries) {
      final pubspec = conflictingEntriesForProject.key.pubspec;
      final isFlutter = pubspec.dependencies.containsKey('flutter');

      final command = isFlutter ? 'flutter' : 'dart';

      final conflictingPackageEntries = conflictingEntriesForProject.value;
      final conflictingPackagesNames = conflictingPackageEntries
          .map((entry) => entry.package.name)
          .join(' ');

      errorMessageBuilder
        ..writeln('cd ${conflictingEntriesForProject.key.directory.path}')
        ..writeln('$command pub upgrade $conflictingPackagesNames');
    }

    return errorMessageBuilder.toString();
  }
}

extension on Pubspec {
  Dependency? getDependency(String name) {
    return dependencies[name] ??
        devDependencies[name] ??
        dependencyOverrides[name];
  }
}
