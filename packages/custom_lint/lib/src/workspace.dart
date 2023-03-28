import 'dart:async';
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

extension on Directory {
  File get pubspec => File(join(path, 'pubspec.yaml'));

  File get packageConfig =>
      File(join(path, '.dart_tool', 'package_config.json'));
}

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
  static Future<CustomLintWorkspace> fromDirectory(Directory directory) async {
    final contextLocator = ContextLocator(
      resourceProvider: PhysicalResourceProvider.INSTANCE,
    );
    final allContextRoots = contextLocator.locateRoots(
      includedPaths: [directory.path],
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
  Future<String> _computePackageConfigForTempProject() async {
    final packageMap = <String, Package>{};
    final conflictingPackagesChecker = ConflictingPackagesChecker();
    for (final project in projects) {
      final validPackages = [
        for (final package in project.packageConfig.packages)
          // Don't include the project that has a plugin enabled in the list
          // of dependencies of the plugin.
          // This avoids the plugin from being hot-reloaded when the analyzed
          // code changes.
          if (package.name != project.pubspec.name) package
      ];

      // Add the contextRoot and its packages to the conflicting packages checker
      conflictingPackagesChecker.addContextRoot(
        project.directory.path,
        validPackages,
        project.pubspec,
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
        await packageConfigFile.writeAsString(await packageConfigContent);
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
      final pubspec = await _parsePubspec(directory);

      // TODO test that dependency_overrides & dev_dependencies aren't checked.
      return pubspec.dependencies.containsKey('custom_lint_builder');
    });
  }
}

Future<Pubspec> _parsePubspec(Directory dir) async {
  final pubspecFile = dir.pubspec;
  final pubspecContent = pubspecFile.readAsString();

  return Pubspec.parse(await pubspecContent, sourceUrl: pubspecFile.uri);
}

Future<PackageConfig> _parsePackageConfig(Directory dir) async {
  final packageConfigFile = dir.packageConfig;
  final packageConfigContent = packageConfigFile.readAsBytes();

  return PackageConfig.parseBytes(
    await packageConfigContent,
    packageConfigFile.uri,
  );
}

/// No pubspec.yaml file was found for a plugin.
@internal
class MissingPubspecError extends Error {
  MissingPubspecError._(this.path);

  /// The path where the pubspec.yaml file was expected.
  final String path;

  @override
  String toString() => 'Missing pubspec.yaml at $path';
}

/// No .dart_tool/package_config.json file was found for a plugin.
@internal
class MissingPackageConfigError extends Error {
  MissingPackageConfigError._(this.path);

  /// The path where the pubspec.yaml file was expected.
  final String path;

  @override
  String toString() => 'No .dart_tool/package_config.json found at $path. '
      'Make sure to run `pub get` first.';
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
    final pubspecFuture = _parsePubspec(directory)..ignore();
    final packageConfigFuture = _parsePackageConfig(directory)..ignore();

    final pubspec = await pubspecFuture.catchError((err) {
      throw MissingPubspecError._(directory.path);
    });
    final packageConfig = await packageConfigFuture.catchError((err) {
      throw MissingPackageConfigError._(directory.path);
    });

    // TODO check that only dev_dependencies are checked
    final plugins = await Future.wait(
      pubspec.devDependencies.entries.map((e) async {
        final dependencyPath = packageConfig.packages
            .firstWhereOrNull((p) => p.name == e.key)
            ?.root
            .path;
        if (dependencyPath == null) {
          throw PluginNotFoundInPackageConfigError._(e.key, directory.path);
        }

        final isPlugin = await cache.isPlugin(Directory(dependencyPath));
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
}

/// A dependency using `hosted` (pub.dev)
class HostedPubspecDependency extends PubspecDependency {
  /// A dependency using `hosted` (pub.dev)
  HostedPubspecDependency(this.dependency) : super._();

  /// The original hosted dependency
  final HostedDependency dependency;

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
}

/// A class that checks if there are conflicting packages in the context roots.
@internal
class ConflictingPackagesChecker {
  final _contextRootPackagesMap = <String, List<Package>>{};
  final _contextRootPubspecMap = <String, Pubspec>{};

  /// Adds a [contextRoot] and its [packages] to the checker.
  /// We need to pass the [pubspec] to check if the package is a git dependency
  /// and to check if the context root is a flutter package.
  void addContextRoot(
    String contextRoot,
    List<Package> packages,
    Pubspec pubspec,
  ) {
    _contextRootPackagesMap[contextRoot] = packages;
    _contextRootPubspecMap[contextRoot] = pubspec;
  }

  /// Throws an error if there are conflicting packages.
  void throwErrorIfConflictingPackages() {
    final packageNameRootMap = <String, Set<Uri>>{};
    // Group packages by name and collect all unique roots,
    // since we're using a set
    for (final packages in _contextRootPackagesMap.values) {
      for (final package in packages) {
        final rootSet = packageNameRootMap[package.name] ?? {};
        packageNameRootMap[package.name] = rootSet..add(package.root);
      }
    }
    // Find packages with more than one root
    final packagesWithConflictingVersions = packageNameRootMap.entries
        .where((entry) => entry.value.length > 1)
        .map((e) => e.key)
        .toList();

    // If there are no conflicting versions, return
    if (packagesWithConflictingVersions.isEmpty) return;

    final contextRootConflictingPackages =
        _contextRootPackagesMap.map((contextRoot, packages) {
      final conflictingPackages = packages.where(
        (package) => packagesWithConflictingVersions.contains(package.name),
      );
      return MapEntry(contextRoot, conflictingPackages);
    });

    final errorMessageBuilder = StringBuffer();

    errorMessageBuilder
      ..writeln('Some dependencies with conflicting versions were identified:')
      ..writeln();

    // Build conflicting packages message
    for (final entry in contextRootConflictingPackages.entries) {
      final contextRoot = entry.key;
      final conflictingPackages = entry.value;
      final pubspec = _contextRootPubspecMap[contextRoot]!;
      final locationName = pubspec.name;
      errorMessageBuilder.writeln('$locationName at $contextRoot');
      for (final package in conflictingPackages) {
        errorMessageBuilder.writeln(package.buildConflictingMessage(pubspec));
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

    // Build fix commands
    for (final entry in contextRootConflictingPackages.entries) {
      final contextRoot = entry.key;
      final pubspec = _contextRootPubspecMap[contextRoot]!;
      final isFlutter = pubspec.dependencies.containsKey('flutter');
      final command = isFlutter ? 'flutter' : 'dart';

      final conflictingPackages = entry.value;
      final conflictingPackagesNames =
          conflictingPackages.map((package) => package.name).join(' ');
      errorMessageBuilder
        ..writeln('cd $contextRoot')
        ..writeln('$command pub upgrade $conflictingPackagesNames');
    }

    throw StateError(errorMessageBuilder.toString());
  }
}

extension on Pubspec {
  Dependency? getDependency(String name) {
    return dependencies[name] ??
        devDependencies[name] ??
        dependencyOverrides[name];
  }
}

extension on Package {
  bool get isGitDependency => root.path.contains('/.pub-cache/git/');

  bool get isHostedDependency => root.path.contains('/.pub-cache/hosted/');

  String buildConflictingMessage(Pubspec pubspec) {
    final versionString = _buildVersionString(pubspec);
    return '- $name $versionString';
  }

  String _buildVersionString(Pubspec pubspec) {
    if (isGitDependency) {
      return _buildGitPackageVersion(pubspec);
    } else if (isHostedDependency) {
      return _buildHostedPackageVersion();
    } else {
      return _buildPathDependency();
    }
  }

  String _buildHostedPackageVersion() {
    final segments = root.pathSegments;
    final version = segments[segments.length - 2].split('-').last;
    return 'v$version';
  }

  String _buildPathDependency() {
    return 'from path ${root.path}';
  }

  String _buildGitPackageVersion(Pubspec pubspec) {
    final dependency = pubspec.getDependency(name);

    // We might not be able to find a dependency if the package is a transitive dependency
    if (dependency == null || dependency is! GitDependency) {
      final version = root.path.split('/git/').last.replaceFirst('$name-', '');
      // We're not able to find the dependency, so we'll just return
      // the version from the path, which is not ideal, but better than nothing
      return 'from git $version';
    }
    final versionBuilder = StringBuffer();
    versionBuilder.write('from git url ${dependency.url}');
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
}
