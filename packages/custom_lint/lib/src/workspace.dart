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
import 'package:pub_semver/pub_semver.dart';
import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:rxdart/rxdart.dart';
import 'package:yaml/yaml.dart';

import 'package_utils.dart';

/// Compute the constraint for a dependency which matches with all the constraints
/// used in the workspace.
String _buildDependencyConstraint(
  String name,
  List<({CustomLintProject project, Dependency dependency})> dependencies, {
  required Directory workingDirectory,
  required String fileName,
}) {
  // We can't pick the "first" then use .skip(1) because the pattern match
  // may transform the shared constraint. Such as modifying path dependencies
  // to all use absolute paths.
  Dependency? sharedConstraint;
  for (final (:project, :dependency) in dependencies) {
    final dependencyMeta = dependencies.map(
      (d) => DependencyConstraintMeta.fromDependency(
        d.dependency,
        d.project,
        workingDirectory: workingDirectory,
      ),
    );

    Never throws() => throw IncompatibleDependencyConstraintsException(
          ConflictKind.dependency(name),
          dependencyMeta.toList(),
          fileName: fileName,
        );

    switch ((dependency: dependency, constraint: sharedConstraint)) {
      case (
          :final HostedDependency dependency,
          :final HostedDependency? constraint,
        ):
        sharedConstraint = dependency;

        if (constraint == null) continue;

        if (constraint.hosted?.declaredName !=
                dependency.hosted?.declaredName ||
            constraint.hosted?.url != dependency.hosted?.url) {
          throws();
        }

        final newConstraint = constraint.version.intersect(dependency.version);
        if (newConstraint.isEmpty) throws();

        sharedConstraint = HostedDependency(
          version: newConstraint,
          hosted: constraint.hosted,
        );

      case (
          :final PathDependency dependency,
          :final PathDependency? constraint,
        ):
        final absoluteDependencyPath = normalize(
          absolute(
            project.directory.path,
            dependency.path,
          ),
        );
        sharedConstraint = PathDependency(absoluteDependencyPath);

        if (constraint == null) continue;
        if (constraint.path != absoluteDependencyPath) throws();

      case (
          :final SdkDependency dependency,
          :final SdkDependency? constraint,
        ):
        sharedConstraint = dependency;

        if (constraint == null) continue;
        if (constraint.sdk != dependency.sdk) throws();

      case (
          :final GitDependency dependency,
          :final GitDependency? constraint,
        ):
        sharedConstraint = dependency;

        if (constraint == null) continue;
        if (constraint.url != dependency.url ||
            constraint.path != dependency.path ||
            constraint.ref != dependency.ref) {
          throws();
        }

      default:
        throws();
    }
  }

  switch (sharedConstraint) {
    case HostedDependency():
      return ' ${sharedConstraint.getDisplayString()}';
    case PathDependency():
      return '\n    path: "${sharedConstraint.path}"';
    case SdkDependency():
      return '\n    sdk: ${sharedConstraint.sdk}';
    case GitDependency():
      final result = StringBuffer('\n    git:');
      result.write('\n      url: ${sharedConstraint.url}');

      if (sharedConstraint.ref != null) {
        result.write('\n      ref: ${sharedConstraint.ref}');
      }
      if (sharedConstraint.path != null) {
        result.write('\n      path: "${sharedConstraint.path}"');
      }

      return result.toString();
    case _:
      throw StateError(
        'Unknown constraint type: ${sharedConstraint.runtimeType}',
      );
  }
}

/// A type of version conflict
sealed class ConflictKind {
  /// A conflict between two dependencies from different packages in the same workspace.
  factory ConflictKind.dependency(String packageName) = _DependencyConflict;

  /// A conflict between two dependencies from the same package in the same workspace.
  factory ConflictKind.environment(String packageName) = _EnvironmentConflict;

  /// The human readable name of the conflict type.
  String get kindDisplayString;

  /// The value of the conflict.
  String get value;
}

class _EnvironmentConflict implements ConflictKind {
  _EnvironmentConflict(this.key);

  @override
  String get kindDisplayString => 'environment';

  @override
  String get value => key;

  final String key;
}

class _DependencyConflict implements ConflictKind {
  _DependencyConflict(this.packageName);

  @override
  String get kindDisplayString => 'package';

  @override
  String get value => packageName;

  final String packageName;
}

/// Information related to a dependency and the project it is used in.
class DependencyConstraintMeta {
  DependencyConstraintMeta._(
    this.dependencyDisplayString,
    CustomLintProject project, {
    required Directory workingDirectory,
  })  : projectName = project.pubspec.name,
        projectPath = join(
          '.',
          normalize(
            relative(project.directory.path, from: workingDirectory.path),
          ),
        );

  /// Construct a [DependencyConstraintMeta] from a [VersionConstraint].
  DependencyConstraintMeta.fromVersionConstraint(
    VersionConstraint constraint,
    CustomLintProject project, {
    required Directory workingDirectory,
  }) : this._(
          HostedDependency(version: constraint).getDisplayString(),
          project,
          workingDirectory: workingDirectory,
        );

  /// Construct a [DependencyConstraintMeta] from a [Dependency].
  DependencyConstraintMeta.fromDependency(
    Dependency dependency,
    CustomLintProject project, {
    required Directory workingDirectory,
  }) : this._(
          dependency.getDisplayString(),
          project,
          workingDirectory: workingDirectory,
        );

  /// Either a [VersionConstraint] or a [Dependency].
  final String dependencyDisplayString;

  /// The name of the project which uses the dependency.
  final String projectName;

  /// The path to the project which uses the dependency.
  final String projectPath;
}

extension on Dependency {
  String getDisplayString() {
    final that = this;
    return switch (that) {
      HostedDependency() when that.version == VersionConstraint.any => 'any',
      HostedDependency() => '"${that.version}"',
      PathDependency() => '"${that.path}"',
      SdkDependency() => 'sdk: ${that.sdk}',
      GitDependency() => 'git: ${that.url}',
      _ => throw ArgumentError.value(
          runtimeType,
          'this',
          'Unknown dependency type',
        ),
    };
  }
}

/// {@template IncompatibleDependencyConstraintsException}
/// An exception thrown when a dependency is used with different constraints
/// {@endtemplate}
class IncompatibleDependencyConstraintsException implements Exception {
  /// {@macro IncompatibleDependencyConstraintsException}
  IncompatibleDependencyConstraintsException(
    this.kind,
    this.conflictingDependencies, {
    required this.fileName,
  }) : assert(
          conflictingDependencies.length > 1,
          'Must have at least 2 items',
        );

  /// The name of the file where the conflict was found.
  final String fileName;

  /// The type of conflict.
  final ConflictKind kind;

  /// The conflicting dependencies.
  final List<DependencyConstraintMeta> conflictingDependencies;

  @override
  String toString() {
    final buffer = StringBuffer(
      'The ${kind.kindDisplayString} "${kind.value}" has incompatible version constraints in the project:\n',
    );

    for (final DependencyConstraintMeta(
          dependencyDisplayString: dependency,
          :projectName,
          :projectPath
        ) in conflictingDependencies) {
      buffer.write('''
- $dependency
  from "$projectName" at "${join(projectPath, fileName)}".
''');
    }

    return buffer.toString();
  }
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

/// A typedef for [Process.run].
typedef RunProcess = Future<ProcessResult> Function(
  String executable,
  List<String> arguments, {
  String? workingDirectory,
  Map<String, String>? environment,
  bool includeParentEnvironment,
  bool runInShell,
  Encoding? stdoutEncoding,
  Encoding? stderrEncoding,
});

/// A mockable way to run processes.
@visibleForTesting
RunProcess runProcess = Process.run;

/// An error thrown when [CustomLintPlugin._visitSelfAndTransitiveDependencies] tries to iterate over
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
    this.uniquePluginNames, {
    required this.workingDirectory,
  });

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
      workingDirectory: workingDirectory,
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
    List<analyzer_plugin.ContextRoot> contextRoots, {
    required Directory workingDirectory,
  }) async {
    final cache = CustomLintPluginCheckerCache();
    final projects = await Future.wait([
      for (final contextRoot in contextRoots)
        CustomLintProject.parse(contextRoot, cache),
    ]);

    final uniquePluginNames =
        projects.expand((e) => e.plugins).map((e) => e.name).toSet();

    return CustomLintWorkspace._(
      projects,
      contextRoots,
      uniquePluginNames,
      workingDirectory: workingDirectory,
    );
  }

  /// Whether the workspace is using flutter.
  bool get isUsingFlutter => projects
      .expand((e) => e.packageConfig.packages)
      .any((e) => e.name == 'flutter');

  /// The working directory of the workspace.
  /// This is the directory from which the workspace was initialized.
  final Directory workingDirectory;

  /// The list of analyzed projects.
  final List<analyzer_plugin.ContextRoot> contextRoots;

  /// The list of analyzed projects.
  final List<CustomLintProject> projects;

  /// The names of all enabled plugins.
  final Set<String> uniquePluginNames;

  /// A method to generate a `pubspec.yaml` in the client project
  ///
  /// This is the combination of all `pubspec.yaml` in the workspace.
  @internal
  String computePubspec() {
    final buffer = StringBuffer('''
name: custom_lint_client
description: A client for custom_lint
version: 0.0.1
publish_to: 'none'
''');

    _writeEnvironment(buffer);
    _writePubspecDependencies(buffer);

    return buffer.toString();
  }

  void _writeEnvironment(StringBuffer buffer) {
    final environmentKeys = projects
        .expand((e) => e.pubspec.environment?.keys ?? <String>[])
        .toSet();

    if (environmentKeys.isEmpty) return;

    buffer.writeln('\nenvironment:');

    for (final key in environmentKeys) {
      final projectMeta = projects
          .map((project) {
            final constraint = project.pubspec.environment?[key];
            if (constraint == null) return null;
            return (project: project, constraint: constraint);
          })
          // TODO what if some projects specify SDK/Flutter but some don't?
          .whereNotNull()
          .toList();

      final constraintCompatibleWithAllProjects = projectMeta.fold(
        VersionConstraint.any,
        (acc, constraint) => acc.intersect(constraint.constraint),
      );

      if (constraintCompatibleWithAllProjects.isEmpty) {
        throw IncompatibleDependencyConstraintsException(
          ConflictKind.environment(key),
          projectMeta
              .map(
                (e) => DependencyConstraintMeta.fromVersionConstraint(
                  e.constraint,
                  e.project,
                  workingDirectory: workingDirectory,
                ),
              )
              .toList(),
          fileName: 'pubspec.yaml',
        );
      }

      buffer.writeln('  $key: "$constraintCompatibleWithAllProjects"');
    }
  }

  void _writePubspecDependencies(StringBuffer buffer) {
    final uniqueDependencyNames = projects.expand((e) sync* {
      yield* e.pubspec.devDependencies.keys;
      yield* e.pubspec.dependencyOverrides.keys;
    }).toSet();

    final dependenciesByName = {
      for (final name in uniqueDependencyNames)
        name: (
          devDependencies: projects
              .map((project) {
                final dependency = project.pubspec.devDependencies[name];
                if (dependency == null) return null;
                return (project: project, dependency: dependency);
              })
              .whereNotNull()
              .toList(),
          dependencyOverrides: projects
              .map((project) {
                final dependency = project.pubspec.dependencyOverrides[name];
                if (dependency == null) return null;
                return (project: project, dependency: dependency);
              })
              .whereNotNull()
              .toList(),
        ),
    };

    // A flag for whether the "dependencies:" header has been written.
    var didWriteDevDependenciesHeader = false;
    // Write dev_dependencies
    for (final name in uniquePluginNames) {
      final allDependencies = dependenciesByName[name];
      if (allDependencies == null) continue;

      // // We don't write dev_dependencies which are sometimes prod dependencies,
      // // as dev_dependencies, because then we'd be specifying the dependency twice.
      if (
          // allDependencies.dependencies.isNotEmpty ||
          allDependencies.devDependencies.isEmpty) {
        continue;
      }

      if (!didWriteDevDependenciesHeader) {
        didWriteDevDependenciesHeader = true;
        buffer.writeln('\ndev_dependencies:');
      }

      final constraint = allDependencies.dependencyOverrides.isNotEmpty
          ? ' any'
          : _buildDependencyConstraint(
              name,
              allDependencies.devDependencies,
              workingDirectory: workingDirectory,
              fileName: 'pubspec.yaml',
            );
      buffer.writeln('  $name:$constraint');
    }

    _writeDependencyOverrides(
      buffer,
      dependencyOverrides: {
        for (final entry in dependenciesByName.entries)
          if (entry.value.dependencyOverrides.isNotEmpty)
            entry.key: entry.value.dependencyOverrides,
      },
    );
  }

  void _writeDependencyOverrides(
    StringBuffer buffer, {
    required Map<String,
            List<({Dependency dependency, CustomLintProject project})>>
        dependencyOverrides,
  }) {
    var didWriteDependencyOverridesHeader = false;
    for (final entry in dependencyOverrides.entries) {
      if (!didWriteDependencyOverridesHeader) {
        didWriteDependencyOverridesHeader = true;
        // Add empty line to separate dependency_overrides from other dependencies.
        if (buffer.isNotEmpty) buffer.writeln();
        buffer.writeln('dependency_overrides:');
      }

      final constraint = _buildDependencyConstraint(
        entry.key,
        entry.value,
        workingDirectory: workingDirectory,
        fileName: 'pubspec_overrides.yaml',
      );
      buffer.writeln('  ${entry.key}:$constraint');
    }
  }

  /// A method to generate a `pubspec_overrides.yaml` in the client project.
  ///
  /// This is the combination of all `pubspec_overrides.yaml` in the workspace.
  @internal
  String? computePubspecOverride() {
    final uniqueDependencyNames = projects //
        .expand((e) => e.pubspecOverrides?.keys ?? <String>[])
        .toSet();

    if (uniqueDependencyNames.isEmpty) return null;

    final dependenciesByName = {
      for (final name in uniqueDependencyNames)
        name: projects
            .map((project) {
              final dependency = project.pubspecOverrides?[name];
              if (dependency == null) return null;
              return (project: project, dependency: dependency);
            })
            .whereNotNull()
            .toList(),
    };

    final buffer = StringBuffer();

    _writeDependencyOverrides(
      buffer,
      dependencyOverrides: dependenciesByName,
    );

    return buffer.toString();
  }

  /// Generate a package_config.json combining all the dependencies from all
  /// the contextRoots.
  ///
  /// This also changes relative paths into absolute paths.
  Map<String, Package> _computeDependencies() {
    final conflictingPackagesChecker = _ConflictingPackagesChecker();

    // A cache object to avoid parsing the same pubspec multiple times,
    // as two plugins might depend on the same package.
    // We still want to visit the dependencies of the package multiple times,
    // as the resolved package in the project's package_config.json might be different.
    final pubspecCache = PubspecCache();
    final visitedPackages = <String>{};

    Iterable<Package> visitPluginsAndDependencies() sync* {
      for (final project in projects) {
        for (final plugin in project.plugins) {
          final packages = plugin._visitSelfAndTransitiveDependencies(
            pubspecCache,
          );

          for (final package in packages) {
            conflictingPackagesChecker.addPluginPackage(
              project,
              plugin,
              package,
              workingDirectory: workingDirectory,
            );

            /// Only add a package in the package_config.json if it was not already added.
            /// We do not care about version conflicts here and assume that the
            /// previously added package is the correct one.
            /// Version conflicts will be checked later with
            /// [ConflictingPackagesChecker.throwErrorIfConflictingPackages].
            if (visitedPackages.add(package.package.name)) {
              yield package.package;
            }
          }
        }
      }
    }

    final result = <String, Package>{
      for (final package in visitPluginsAndDependencies())
        package.name: package,
    };

    // Check if there are conflicting packages.
    // We do so after computing the result to avoid allocating a temporary
    // list of packages, by visiting dependencies using an Iterable instead of List.
    conflictingPackagesChecker.throwErrorIfConflictingPackages();

    return result;
  }

  String _computePackageConfig(Map<String, Package> dependencies) {
    return jsonEncode(<String, Object?>{
      'configVersion': 2,
      'generated': DateTime.now().toIso8601String(),
      'generator': 'custom_lint',
      'generatorVersion': '0.0.1',
      'packages': <Object?>[
        for (final dependency in dependencies.values)
          {
            'name': dependency.name,
            // This is somehow enough to change relative paths into absolute ones.
            // It seems that PackageConfig.parse already converts the paths into
            // absolute ones.
            'rootUri': dependency.root.toString(),
            'packageUri': dependency.packageUriRoot.toString(),
            'languageVersion': dependency.languageVersion.toString(),
            'extraData': dependency.extraData.toString(),
          },
      ],
    });
  }

  /// First attempts at creating the plugin host locally. And if it fails,
  /// it will fallback to resolving packages using "pub get".
  Future<void> resolvePluginHost(
    Directory tempDir,
  ) async {
    final pubspecContent = computePubspec();
    final pubspecOverride = computePubspecOverride();

    tempDir.pubspec.writeAsStringSync(pubspecContent);
    if (pubspecOverride != null) {
      tempDir.pubspecOverrides.writeAsStringSync(pubspecOverride);
    }

    try {
      await resolvePackageConfigOffline(tempDir);
    } catch (_) {
      await runPubGet(tempDir);
    }
  }

  /// Attempts at creating the plugin host without having to run "pub get".
  ///
  /// This works by combining all the `package_config.json` of the various
  /// plugins.
  ///
  /// May throw if failed to create the plugin host.
  /// Will throw a [PackageVersionConflictException] if there are conflicting
  /// versions of the same package.
  Future<void> resolvePackageConfigOffline(Directory tempDir) async {
    final dependencies = _computeDependencies();
    final packageConfigContent = _computePackageConfig(dependencies);
    final packageConfigFile = tempDir.packageConfig;

    await packageConfigFile.create(recursive: true);
    await packageConfigFile.writeAsString(packageConfigContent);
  }

  /// Run "pub get" in the client project.
  Future<void> runPubGet(Directory tempDir) async {
    final command = isUsingFlutter ? 'flutter' : 'dart';

    final result = await runProcess(
      command,
      const ['pub', 'get'],
      stdoutEncoding: utf8,
      stderrEncoding: utf8,
      workingDirectory: tempDir.path,
    );
    if (result.exitCode != 0) {
      throw Exception(
        'Failed to run "pub get" in the client project:\n'
        '${result.stdout}\n'
        '${result.stderr}',
      );
    }
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

/// An util for parsing a pubspec once.
@internal
class PubspecCache {
  final _cache = <Directory, Pubspec Function()>{};

  /// Parses a pubspec and throws if the parsing fails.
  ///
  /// If the value is already cached, it will return the cached value or rethrow
  /// the previously thrown error.
  Pubspec call(Directory directory) {
    final cached = _cache[directory];
    if (cached != null) return cached();

    try {
      final pubspec = parsePubspecSync(directory);
      _cache[directory] = () => pubspec;
      return pubspec;
    } catch (e) {
      // ignore: only_throw_errors, use_rethrow_when_possible
      _cache[directory] = () => throw e;

      rethrow;
    }
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
    required this.pubspecOverrides,
  });

  /// Decode a [CustomLintProject] from a directory.
  static Future<CustomLintProject> parse(
    analyzer_plugin.ContextRoot contextRoot,
    CustomLintPluginCheckerCache cache,
  ) async {
    final directory = Directory(contextRoot.root);

    final projectPubspec = await parsePubspec(directory)
        // ignore: avoid_types_on_closure_parameters
        .catchError((Object err, StackTrace stack) {
      throw PubspecParseError._(
        directory.path,
        error: err,
        errorStackTrace: stack,
      );
    });
    final pubspecOverrides = await tryParsePubspecOverrides(directory);
    final projectPackageConfig = await parsePackageConfig(directory)
        // ignore: avoid_types_on_closure_parameters
        .catchError((Object err, StackTrace stack) {
      throw PackageConfigParseError._(
        directory.path,
        error: err,
        errorStackTrace: stack,
      );
    });

    // TODO check that only dev_dependencies are checked
    final plugins = await Future.wait(
      projectPubspec.devDependencies.entries.map((e) async {
        final packageWithName = projectPackageConfig.packages
            .firstWhereOrNull((p) => p.name == e.key);
        if (packageWithName == null) {
          throw PluginNotFoundInPackageConfigError._(e.key, directory.path);
        }

        final pluginDirectory = Directory.fromUri(packageWithName.root);
        final isPlugin = await cache.isPlugin(pluginDirectory);
        if (!isPlugin) return null;

        // TODO test error
        final pluginPubspec = await parsePubspec(pluginDirectory);

        return CustomLintPlugin._(
          name: e.key,
          directory: pluginDirectory,
          pubspec: pluginPubspec,
          package: packageWithName,
          constraint: PubspecDependency.fromDependency(e.value),
          ownerPubspec: projectPubspec,
          ownerPackageConfig: projectPackageConfig,
        );
      }),
    );

    return CustomLintProject._(
      plugins: plugins.whereNotNull().toList(),
      directory: directory,
      packageConfig: projectPackageConfig,
      pubspec: projectPubspec,
      pubspecOverrides: pubspecOverrides,
    );
  }

  /// The resolved package_config.json at the moment of parsing.
  final PackageConfig packageConfig;

  /// The pubspec.yaml at the moment of parsing.
  final Pubspec pubspec;

  /// The pubspec.yaml at the moment of parsing.
  final Map<String, Dependency>? pubspecOverrides;

  /// The folder of the project being analyzed.
  final Directory directory;

  /// The enabled plugins for this project.
  final List<CustomLintPlugin> plugins;
}

class _PackageAndPubspec {
  _PackageAndPubspec({required this.package, required this.parentPubspec});

  final Package package;
  final Pubspec parentPubspec;
}

class _PackageNameAndPubspec {
  _PackageNameAndPubspec({
    required this.packageName,
    required this.parentPubspec,
  });

  static Iterable<_PackageNameAndPubspec> fromPubspecDependencies(
    Pubspec pubspec,
  ) {
    return pubspec.dependencies.keys.map(
      (packageName) => _PackageNameAndPubspec(
        packageName: packageName,
        parentPubspec: pubspec,
      ),
    );
  }

  final String packageName;
  final Pubspec parentPubspec;
}

/// A custom_lint plugin and its version constraints.
@internal
class CustomLintPlugin {
  CustomLintPlugin._({
    required this.name,
    required this.directory,
    required this.constraint,
    required this.ownerPackageConfig,
    required this.ownerPubspec,
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

  /// The pubspec of the project which depends on this plugin.
  final Pubspec ownerPubspec;

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
  Iterable<_PackageAndPubspec> _visitSelfAndTransitiveDependencies(
    PubspecCache pubspecCache,
  ) sync* {
    yield _PackageAndPubspec(
      package: package,
      parentPubspec: ownerPubspec,
    );

    // A map of of the packages defined in package_config.json for fast lookup.
    // This avoids an O(n^2) lookup in the loop below.
    final packages = Map.fromEntries(
      ownerPackageConfig.packages.map((e) => MapEntry(e.name, e)),
    );

    // Only queue "dependencies" but no "dev_dependencies" or "dependency_overrides".
    // This is plugins are considered in to be in "release mode", in which case
    // dev only dependencies are not included.
    final dependenciesToVisit = ListQueue<_PackageNameAndPubspec>.of(
      _PackageNameAndPubspec.fromPubspecDependencies(pubspec),
    );

    /// The set of already visited pubspecs
    final visited = <String>{};

    while (dependenciesToVisit.isNotEmpty) {
      // Check if the dependency is already visited
      final dependency = dependenciesToVisit.removeFirst();
      if (!visited.add(dependency.packageName)) continue;

      // Emit the dependency's package metadata.
      final package = packages[dependency.packageName];
      if (package == null) {
        throw UnresolvedTransitiveDependencyException._(dependency.packageName);
      }

      final packageDir = Directory.fromUri(package.root);
      // TODO test error
      final dependencyPubspec = pubspecCache(packageDir);

      yield _PackageAndPubspec(
        package: package,
        parentPubspec: dependency.parentPubspec,
      );

      // Now queue the dependencies of the dependency to be emitted too.
      // Only queue "dependencies" but no "dev_dependencies" or "dependency_overrides".
      // This is plugins are considered in to be in "release mode", in which case
      // dev only dependencies are not included.
      dependenciesToVisit.addAll(
        _PackageNameAndPubspec.fromPubspecDependencies(dependencyPubspec),
      );
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
  _ConflictEntry(
    this.plugin,
    this.project,
    this.packageMeta, {
    required this.workingDirectory,
  });

  final CustomLintPlugin plugin;
  final CustomLintProject project;
  final _PackageAndPubspec packageMeta;
  final Directory workingDirectory;

  /// Whether [packageMeta] is the plugin itself.
  late final bool _isPlugin = packageMeta.package.name == plugin.name;

  String get _name => packageMeta.package.name;

  PubspecDependency _dependency() {
    // Short path for when the constraint is readily available.
    if (_isPlugin) return plugin.constraint;

    final dependency = packageMeta.parentPubspec.getDependency(_name);
    if (dependency == null) {
      // TODO test error
      throw ArgumentError(
        'Package ${packageMeta.parentPubspec.name} does not depend on package $_name\n${packageMeta.parentPubspec.dependencies}',
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
    final trailingMessage = _isPlugin
        ? 'Used by project "${project.pubspec.name}" at "${project.directory.relativeTo(workingDirectory)}"'
        : 'Used by plugin "${plugin.name}" at "${plugin.directory.relativeTo(workingDirectory)}" '
            'in the project "${project.pubspec.name}" at "${project.directory.relativeTo(workingDirectory)}"';
    return '''
- ${_dependency().buildShortDescription()}
  Resolved with ${packageMeta.package.root.toFilePath()}
  $trailingMessage''';
  }
}

/// A class that checks if there are conflicting packages in the context roots.
class _ConflictingPackagesChecker {
  final _entries = <_ConflictEntry>[];

  /// Registers a [Package] and its associated [CustomLintPlugin]/[CustomLintProject]
  /// to be checked against version conflicts.
  void addPluginPackage(
    CustomLintProject project,
    CustomLintPlugin plugin,
    _PackageAndPubspec package, {
    required Directory workingDirectory,
  }) {
    _entries.add(
      _ConflictEntry(
        plugin,
        project,
        package,
        workingDirectory: workingDirectory,
      ),
    );
  }

  /// Throws an error if there are conflicting packages.
  void throwErrorIfConflictingPackages() {
    final packageNameRootMap = <String, Set<Uri>>{};
    // Group packages by name and collect all unique roots,
    // since we're using a set
    for (final entry in _entries) {
      final entriesForName =
          packageNameRootMap[entry.packageMeta.package.name] ??= {};
      entriesForName.add(entry.packageMeta.package.root);
    }

    // Find packages with more than one root
    final packagesWithConflictingVersions = packageNameRootMap.entries
        .where((entry) => entry.value.length > 1)
        .map((e) => e.key)
        .toSet();

    // If there are no conflicting versions, return
    if (packagesWithConflictingVersions.isEmpty) return;

    throw PackageVersionConflictException._(
      packagesWithConflictingVersions,
      _entries,
    );
  }
}

/// An error thrown if a custom_lint workspace contains two or more projects
/// which depend on the same package (directly or transitively) with different versions.
class PackageVersionConflictException implements Exception {
  PackageVersionConflictException._(
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
          _entries
              .where((entry) => entry.packageMeta.package.name == packageName)
              .sortedBy((value) => value.project.pubspec.name),
        ),
      ),
    );

    final errorMessageBuilder = StringBuffer('''
PackageVersionConflictException – Some dependencies with conflicting versions were identified:

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
          .map((entry) => entry.packageMeta.package.name)
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
