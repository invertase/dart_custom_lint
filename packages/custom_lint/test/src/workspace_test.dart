import 'dart:convert';
import 'dart:io';

import 'package:analyzer_plugin/protocol/protocol_generated.dart';
import 'package:custom_lint/src/package_utils.dart';
import 'package:custom_lint/src/workspace.dart';
import 'package:package_config/package_config.dart';
import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:test/test.dart';

const conflictExplanation =
    'This is not supported. Custom_lint shares the analysis between all packages. '
    'As such, all plugins are started under a single process, '
    'sharing the dependencies of all the packages that use custom_lint. '
    "Since there's a single process for all plugins, if 2 plugins try to use "
    'different versions for a dependency, the process cannot be reasonably started. '
    'Please make sure all packages have the same version.';

extension on Dependency {
  Map<String, Object?> toPackageJson({
    required String name,
    required String rootUri,
  }) {
    return {
      'name': name,
      'rootUri': rootUri,
      'packageUri': 'lib/',
      'languageVersion': '2.12',
    };
  }

  Object? toJson() {
    final that = this;
    if (that is HostedDependency) {
      return that.version.toString();
    } else if (that is GitDependency) {
      return {
        'git': {
          'url': that.url.toString(),
          if (that.path != null) 'path': that.path,
          if (that.ref != null) 'ref': that.ref,
        }
      };
    } else if (that is PathDependency) {
      return {
        'path': that.path,
      };
    } else if (that is SdkDependency) {
      return {
        'sdk': that.sdk,
      };
    } else {
      throw ArgumentError.value(that, 'dependency', 'Unknown dependency');
    }
  }
}

extension on Pubspec {
  Map<String, Object?> toJson() {
    return {
      'name': name,
      if (version != null) 'version': version.toString(),
      if (environment != null)
        'environment': {
          for (final env in environment!.entries)
            if (env.value != null) env.key: env.value.toString(),
        },
      if (dependencies.isNotEmpty)
        'dependencies': {
          for (final dependency in dependencies.entries)
            dependency.key: dependency.value.toJson(),
        },
      if (devDependencies.isNotEmpty)
        'dev_dependencies': {
          for (final dependency in devDependencies.entries)
            dependency.key: dependency.value.toJson(),
        },
      if (dependencyOverrides.isNotEmpty)
        'dependency_overrides': {
          for (final dependency in dependencyOverrides.entries)
            dependency.key: dependency.value.toJson(),
        }
    };
  }
}

Future<Directory> createProject(
  Directory dir,
  Pubspec pubspec, {
  required List<Map<String, Object?>> packageConfigs,
}) async {
  // Write the pubpsec.yaml
  final pubspecFile = dir.pubspec;
  pubspecFile.createSync(recursive: true);
  pubspecFile.writeAsStringSync(json.encode(pubspec.toJson()));

  // Write a package_config.json matching the dependencies
  final packageConfigFile = dir.packageConfig;
  packageConfigFile.createSync(recursive: true);
  packageConfigFile.writeAsStringSync(
    json.encode({
      'configVersion': 2,
      'packages': packageConfigs,
    }),
  );

  return dir;
}

void writePackageConfig(Directory dir, [List<Package> packages = const []]) {
  writeFile(
    dir.packageConfig,
    json.encode({
      'configVersion': 2,
      'packages': [
        for (final package in packages)
          {
            'name': package.name,
            'rootUri': package.root.toString(),
            'packageUri': 'lib/',
            'languageVersion': '2.12',
          },
      ],
    }),
  );
}

/// A simplified [writePackageConfig] which alleviates the need to specify
/// a [Package] object.
///
/// This receives a map of package name and paths relative to [dir].
void writeSimplePackageConfig(
  Directory dir, [
  Map<String, String> packages = const {},
]) {
  writePackageConfig(
    dir,
    [
      for (final entry in packages.entries)
        Package(
          entry.key,
          Uri.file(
            // The Package class expects a trailing slash and absolute path.
            '${p.normalize(p.join(dir.path, entry.value))}/',
          ),
        ),
    ],
  );
}

/// A simplified [createWorkspace] which alleviates the need to specify
/// both the path and the pubspec.
///
/// This receives a list of either [String] or [Pubspec] objects.
/// - If a [String] is passed, it must be a path, and a project
///   with the name of the basename of the path will be created at that location.
/// - If a [Pubspec] is passed, a project will be created in a folder at the root
///   of the workspace with the project name.
///   If two packages have the same name, the second one will be suffixed with
///   an incrementing numnber. Such that we have `package`, `package2`, ...
Future<Directory> createSimpleWorkspace(
  List<Object> projectEntry, {
  bool withPackageConfig = true,
}) async {
  /// The number of time we've created a package with a given name.
  final packageCount = <String, int>{};

  String getFolderName(String name) {
    // If a package with the same name was already created previously,
    // we suffix the folder name with an incrementing number.
    final projectFolderSuffix =
        packageCount[name] == null ? '' : packageCount[name]!.toString();
    final folderName = '$name$projectFolderSuffix';

    // Increment the counter for changing the suffix for the next similarly
    // named package
    packageCount[name] = (packageCount[name] ?? 1) + 1;

    return folderName;
  }

  return createWorkspace(withPackageConfig: withPackageConfig, {
    for (final projectEntry in projectEntry)
      if (projectEntry is Pubspec)
        getFolderName(projectEntry.name): projectEntry
      else if (projectEntry is String)
        getFolderName(projectEntry): Pubspec(
          p.basename(projectEntry),
          version: Version(1, 0, 0),
          environment: {
            'sdk': VersionConstraint.parse('>=2.17.0 <4.0.0'),
          },
        )
      else
        // https://github.com/dart-lang/language/issues/2943
        'foo': throw ArgumentError.value(
          projectEntry,
          'projectEntry',
          'Expected either a String or a Pubspec',
        ),
  });
}

/// Create a temporary mono-repository setup with package_configs and pubspecs.
Future<Directory> createWorkspace(
  Map<String, Pubspec> pubspecs, {
  bool withPackageConfig = true,
}) async {
  final dir = createTemporaryDirectory();

  String packagePathOf(Dependency dependency, String name) {
    if (dependency is HostedDependency) {
      return p.join(dir.path, name);
    } else if (dependency is PathDependency) {
      return dependency.path;
    } else {
      throw UnsupportedError('Unknown dependency ${dependency.runtimeType}.');
    }
  }

  await Future.wait([
    for (final pubspecEntry in pubspecs.entries)
      Future(() async {
        // Create the package directory
        final projectDirectory = Directory(
          p.normalize(p.absolute(dir.path, pubspecEntry.key)),
        );
        projectDirectory.createSync(recursive: true);

        await createProject(
          projectDirectory,
          pubspecEntry.value,
          packageConfigs: !withPackageConfig
              ? const []
              : [
                  for (final dependency
                      in pubspecEntry.value.dependencies.entries)
                    dependency.value.toPackageJson(
                      name: dependency.key,
                      rootUri: packagePathOf(dependency.value, dependency.key),
                    ),
                  for (final dependency
                      in pubspecEntry.value.devDependencies.entries)
                    dependency.value.toPackageJson(
                      name: dependency.key,
                      rootUri: packagePathOf(dependency.value, dependency.key),
                    ),
                  for (final dependency
                      in pubspecEntry.value.dependencyOverrides.entries)
                    dependency.value.toPackageJson(
                      name: dependency.key,
                      rootUri: packagePathOf(dependency.value, dependency.key),
                    ),
                ],
        );
      }),
  ]);

  return dir;
}

Directory createTemporaryDirectory() {
  final dir = Directory.current //
      .dir('.dart_tool')
      .createTempSync('custom_lint_test');
  addTearDown(() => dir.deleteSync(recursive: true));
  return dir;
}

void writeFile(File file, String content) {
  file.createSync(recursive: true);
  file.writeAsStringSync(content);
}

void enableCustomLint(Directory directory) {
  writeFile(directory.analysisOptions, analysisOptionsWithCustomLintEnabled);
}

const analysisOptionsWithCustomLintEnabled = '''
analyzer:
  plugins:
    - custom_lint
''';

const analysisOptionsWithCustomLintDisabled = '''
analyzer:
  plugins:
    - unrelated_plugin
''';

void main() {
  group('visitAnalysisOptionAndIncludes', () {
    test('returns empty stream if the analysis options file does not exist',
        () async {
      final dir = createTemporaryDirectory();
      final stream = visitAnalysisOptionAndIncludes(dir.analysisOptions);

      await expectLater(stream, emitsDone);
    });

    test('returns empty stream if the analysis options file is not a YAML map',
        () async {
      final dir = createTemporaryDirectory();
      writeFile(dir.analysisOptions, '42');

      await expectLater(
        visitAnalysisOptionAndIncludes(dir.analysisOptions),
        emitsDone,
      );
    });

    test('Emits a YAML map from the analysis options file', () async {
      final dir = createTemporaryDirectory();
      writeFile(dir.analysisOptions, 'foo: bar');

      await expectLater(
        visitAnalysisOptionAndIncludes(dir.analysisOptions),
        emitsInOrder([
          {'foo': 'bar'},
          emitsDone,
        ]),
      );
    });

    test('resolves an include path relative to the analysis options file',
        () async {
      final dir = createTemporaryDirectory();
      final analysisOptions = dir.analysisOptions;
      final includedFile = analysisOptions.parent.file('other.yaml');
      writeFile(analysisOptions, 'include: other.yaml');
      writeFile(includedFile, 'foo: bar');

      await expectLater(
        visitAnalysisOptionAndIncludes(analysisOptions),
        emitsInOrder([
          {'include': 'other.yaml'},
          {'foo': 'bar'},
        ]),
      );
    });

    test(
      'handles nested package imports, '
      'picking up dependencies from the root package config',
      () async {
        final dir = createTemporaryDirectory();

        const packageName = 'foo';
        final packageDir = dir.dir('packages/$packageName');
        writeFile(
          packageDir.file('lib', 'other.yaml'),
          'foo: bar',
        );

        const package2Name = 'bar';
        final package2Dir = dir.dir('packages/$package2Name');
        writeFile(
          package2Dir.file('lib', 'src', 'file.yaml'),
          'include: package:$packageName/other.yaml',
        );

        final analysisOptions = dir.analysisOptions;
        writeFile(
          analysisOptions,
          'include: package:$package2Name/src/file.yaml',
        );

        final packageConfig = '''
        {
          "configVersion":2,
          "packages":[
            {
              "name":"$packageName",
              "rootUri":"file://${packageDir.path}",
              "packageUri":"lib/"
            },
            {
              "name":"$package2Name",
              "rootUri":"file://${package2Dir.path}",
              "packageUri":"lib/"
            }
          ]
        }
      ''';
        writeFile(dir.packageConfig, packageConfig);

        await expectLater(
          visitAnalysisOptionAndIncludes(analysisOptions),
          emitsInOrder([
            {'include': 'package:bar/src/file.yaml'},
            {'include': 'package:foo/other.yaml'},
            {'foo': 'bar'},
            emitsDone,
          ]),
        );
      },
    );

    test(
        'handles include paths with the "package" scheme, '
        'but package config does not contain the package', () async {
      final dir = createTemporaryDirectory();
      final analysisOptions = dir.analysisOptions;
      final packageConfigFile = dir.packageConfig;
      writeFile(analysisOptions, 'include: package:foo/other.yaml');

      const packageConfig = '''
    {
      "configVersion":2,
      "packages":[{
        "name":"bar",
        "rootUri":"file:///path/to/packages/bar",
        "packageUri":"lib/"
      }]
    }
  ''';
      writeFile(packageConfigFile, packageConfig);

      await expectLater(
        visitAnalysisOptionAndIncludes(analysisOptions),
        emitsInOrder([
          {'include': 'package:foo/other.yaml'},
          // The "other.yaml" file was not visited because we could not resolve
          // the import.
          emitsDone,
        ]),
      );
    });

    test(
        'handles include paths with the "package" scheme, '
        'but package config does not exist', () async {
      final dir = createTemporaryDirectory();
      final analysisOptions = dir.analysisOptions;
      writeFile(analysisOptions, 'include: package:foo/other.yaml');

      await expectLater(
        visitAnalysisOptionAndIncludes(analysisOptions),
        emitsInOrder([
          {'include': 'package:foo/other.yaml'},
          emitsDone,
        ]),
      );
    });

    test('handles includes with relative paths', () async {
      final dir = createTemporaryDirectory();
      final analysisOptions = dir.analysisOptions;
      final includedFile = dir.file('other.yaml');
      writeFile(analysisOptions, 'include: other.yaml');
      writeFile(includedFile, 'foo: bar');

      await expectLater(
        visitAnalysisOptionAndIncludes(analysisOptions),
        emitsInOrder([
          {'include': 'other.yaml'},
          {'foo': 'bar'},
          emitsDone,
        ]),
      );
    });

    test('handles includes with absolute paths', () async {
      final dir = createTemporaryDirectory();
      final analysisOptions = dir.analysisOptions;
      final includedFile = dir.file('other.yaml');
      writeFile(analysisOptions, 'include: ${includedFile.path}');
      writeFile(includedFile, 'foo: bar');

      await expectLater(
        visitAnalysisOptionAndIncludes(analysisOptions),
        emitsInOrder([
          {'include': includedFile.path},
          {'foo': 'bar'},
          emitsDone,
        ]),
      );
    });

    test('handles nested relative include paths', () async {
      final dir = createTemporaryDirectory();
      final analysisOptions = dir.analysisOptions;
      writeFile(analysisOptions, 'include: dir/included.yaml');

      final includedFile = dir.file('dir', 'included.yaml');
      // The relative path is based on the location of includedFile
      // rather than "analysisOptions".
      writeFile(includedFile, 'include: ../dir2/other.yaml');

      final otherFile = dir.file('dir2', 'other.yaml');
      writeFile(otherFile, 'baz: qux');

      final stream = visitAnalysisOptionAndIncludes(analysisOptions);
      await expectLater(
        stream,
        emitsInOrder([
          {'include': 'dir/included.yaml'},
          {'include': '../dir2/other.yaml'},
          {'baz': 'qux'},
          emitsDone,
        ]),
      );
    });

    test('handles circular includes by throwing a CyclicIncludeException',
        () async {
      final dir = createTemporaryDirectory();

      writeFile(dir.analysisOptions, 'include: other.yaml');
      writeFile(dir.file('other.yaml'), 'include: analysis_options.yaml');

      await expectLater(
        visitAnalysisOptionAndIncludes(dir.analysisOptions),
        emitsInOrder([
          {'include': 'other.yaml'},
          {'include': 'analysis_options.yaml'},
          emitsError(isA<CyclicIncludeException>()),
        ]),
      );
    });

    test('handles errors in loading package config files', () async {
      final dir = createTemporaryDirectory();

      writeFile(dir.analysisOptions, 'include: package:foo/other.yaml');
      writeFile(dir.file('other.yaml'), 'foo: bar');
      writeFile(dir.packageConfig, 'invalid json');

      await expectLater(
        visitAnalysisOptionAndIncludes(dir.analysisOptions),
        emitsInOrder([
          {'include': 'package:foo/other.yaml'},
          // The "other.yaml" file was not visited because we could not resolve
          // the package config.
          emitsDone,
        ]),
      );
    });
  });

  group(CustomLintWorkspace, () {
    group(CustomLintWorkspace.fromPaths, () {
      test('Handles relative paths', () async {
        final workspace = await createSimpleWorkspace(['package']);

        writeFile(
          workspace.dir('package').analysisOptions,
          analysisOptionsWithCustomLintEnabled,
        );

        final customLintWorkspace = await CustomLintWorkspace.fromPaths(
          ['package'],
          workingDirectory: workspace,
        );

        expect(customLintWorkspace.contextRoots, hasLength(1));
        expect(
          customLintWorkspace.contextRoots.first.root,
          workspace.dir('package').path,
        );

        expect(
          customLintWorkspace.projects.map((e) => e.pubspec.name),
          ['package'],
        );
      });

      test('Decodes contextRoots', () async {
        final workspace = await createSimpleWorkspace([
          'package',
          p.join('package', 'subpackage'),
        ]);

        writeFile(
          workspace.dir('package').analysisOptions,
          analysisOptionsWithCustomLintEnabled,
        );

        final customLintWorkspace = await CustomLintWorkspace.fromPaths(
          [workspace.path],
          workingDirectory: workspace,
        );

        expect(customLintWorkspace.contextRoots, hasLength(2));

        expect(
          customLintWorkspace.contextRoots.first.root,
          workspace.dir('package').path,
        );
        expect(
          customLintWorkspace.contextRoots.first.exclude,
          [workspace.dir('package', 'subpackage').path],
        );
        expect(
          customLintWorkspace.contextRoots.first.optionsFile,
          workspace.dir('package').analysisOptions.path,
        );

        expect(
          customLintWorkspace.contextRoots[1].root,
          workspace.dir('package', 'subpackage').path,
        );
        expect(customLintWorkspace.contextRoots[1].exclude, isEmpty);
        expect(
          customLintWorkspace.contextRoots[1].optionsFile,
          workspace.dir('package').analysisOptions.path,
        );
      });

      test(
          'When looking for projects with custom_lint enabled, '
          'supports analysis_options.yaml imports', () async {
        final workspace = await createSimpleWorkspace([
          'enabled_import',
          'disabled_import',
        ]);
        final enabledAnalysisOptions = workspace.dir('enabled').analysisOptions;
        writeFile(enabledAnalysisOptions, analysisOptionsWithCustomLintEnabled);

        final disabledAnalysisOptions =
            workspace.dir('disabled').analysisOptions;
        writeFile(
          disabledAnalysisOptions,
          analysisOptionsWithCustomLintDisabled,
        );

        final enabledImportOptions =
            workspace.dir('enabled_import').analysisOptions;
        writeFile(
          enabledImportOptions,
          'include: ${enabledAnalysisOptions.path}',
        );

        final disabledImportOptions =
            workspace.dir('disabled_import').analysisOptions;
        writeFile(
          disabledImportOptions,
          'include: ${disabledAnalysisOptions.path}',
        );

        final customLintWorkspace = await CustomLintWorkspace.fromPaths(
          [workspace.path],
          workingDirectory: workspace,
        );

        expect(
          customLintWorkspace.projects.map((e) => e.pubspec.name),
          ['enabled_import'],
        );
      });

      test('Parses all projects in the directory where custom_lint is enabled',
          () async {
        final workspace = await createSimpleWorkspace([
          // A folder with no analysis_options.yaml
          'disabled_package',
          // A folder with an analysis_options.yaml that does not have custom_lint enabled
          'explicitly_disabled_package',
          // A folder with an analysis_options.yaml that has custom_lint enabled
          'package_with_custom_lint',
        ]);

        final subPackage = workspace.dir('disabled_package').dir('sub_package');
        await createProject(
          subPackage,
          Pubspec('sub_package', version: Version(1, 0, 0)),
          packageConfigs: [],
        );

        // Enable custon_lint in sub_package and package_with_custom_lint
        final analysisOptions = [
          workspace.dir('package_with_custom_lint').analysisOptions,
          subPackage.analysisOptions,
          // Insert the analysis_options.yaml above the project to test that
          // the resolution handles inherited analysis_options.yaml files.
          workspace.dir('packages').analysisOptions,
        ];
        for (final file in analysisOptions) {
          writeFile(file, analysisOptionsWithCustomLintEnabled);
        }

        writeFile(
          workspace.dir('explicitly_disabled_package').analysisOptions,
          analysisOptionsWithCustomLintDisabled,
        );

        final customLintWorkspace = await CustomLintWorkspace.fromPaths(
          [workspace.path],
          workingDirectory: workspace,
        );

        expect(
          customLintWorkspace.projects.map((e) => e.pubspec.name),
          unorderedEquals([
            'package_with_custom_lint',
            'sub_package',
          ]),
        );
      });
    });

    group('fromContextRoots', () {
      /// Shorthand for calling [CustomLintWorkspace.fromContextRoots] from
      /// a list of path.
      Future<CustomLintWorkspace> fromContextRootsFromPaths(
        List<String> paths, {
        required Directory workingDirectory,
      }) {
        return CustomLintWorkspace.fromContextRoots(
          paths.map((path) => ContextRoot(path, [])).toList(),
          workingDirectory: workingDirectory,
        );
      }

      test('throws MissingPubspecError if package does not contain a pubspec',
          () async {
        final workspace = await createSimpleWorkspace([]);
        workspace.dir('package').createSync(recursive: true);

        expect(
          () => fromContextRootsFromPaths(
            [p.join(workspace.path, 'package')],
            workingDirectory: workspace,
          ),
          throwsA(isA<PubspecParseError>()),
        );
      });

      test(
          'throws MissingPackageConfigError if package has a pubspec but no .dart_tool/package_config.json',
          () async {
        final workspace = await createSimpleWorkspace(['package']);
        workspace.dir('package', '.dart_tool').deleteSync(recursive: true);

        expect(
          () => fromContextRootsFromPaths(
            [p.join(workspace.path, 'package')],
            workingDirectory: workspace,
          ),
          throwsA(isA<PackageConfigParseError>()),
        );
      });

      test('Supports empty workspace', () async {
        final customLintWorkspace = await fromContextRootsFromPaths(
          [],
          // The working directory is not used, but it is required by the API.
          workingDirectory: Directory.current,
        );

        expect(customLintWorkspace.contextRoots, isEmpty);
        expect(customLintWorkspace.uniquePluginNames, isEmpty);
        expect(customLintWorkspace.projects, isEmpty);
      });

      test('Supports projects with no plugins', () async {
        final workspace = await createSimpleWorkspace(['package']);

        final customLintWorkspace = await fromContextRootsFromPaths(
          [p.join(workspace.path, 'package')],
          workingDirectory: workspace,
        );

        expect(
          customLintWorkspace.contextRoots.map((e) => e.root),
          [p.join(workspace.path, 'package')],
        );
        // No plugin is used, so the list of unique plugin names is empty.
        expect(customLintWorkspace.uniquePluginNames, isEmpty);

        expect(customLintWorkspace.projects, hasLength(1));
        expect(customLintWorkspace.projects.first.plugins, isEmpty);
        expect(
          customLintWorkspace.projects.first.packageConfig.packages,
          isEmpty,
        );
        expect(
          customLintWorkspace.projects.first.directory.path,
          p.join(workspace.path, 'package'),
        );
        expect(customLintWorkspace.projects.first.pubspec.name, 'package');
      });

      test('Supports projects with shared plugins', () async {
        final workspace = await createSimpleWorkspace([
          Pubspec(
            'plugin1',
            version: Version(1, 0, 0),
            dependencies: {'custom_lint_builder': HostedDependency()},
          ),
          Pubspec(
            'plugin2',
            version: Version(1, 0, 0),
            dependencies: {'custom_lint_builder': HostedDependency()},
          ),
          Pubspec(
            'plugin3',
            version: Version(1, 0, 0),
            dependencies: {'custom_lint_builder': HostedDependency()},
          ),
          'random_dep',
          'custom_lint_builder',
          Pubspec(
            'a',
            version: Version(1, 0, 0),
            devDependencies: {
              'plugin1': HostedDependency(),
              'plugin3': HostedDependency(),
              'random_dep': HostedDependency(),
            },
          ),
          Pubspec(
            'b',
            version: Version(1, 0, 0),
            devDependencies: {
              'plugin2': HostedDependency(),
              'plugin3': HostedDependency(),
              'random_dep': HostedDependency(),
            },
          ),
        ]);

        final customLintWorkspace = await fromContextRootsFromPaths(
          [
            p.join(workspace.path, 'a'),
            p.join(workspace.path, 'b'),
          ],
          workingDirectory: workspace,
        );

        expect(
          customLintWorkspace.contextRoots.map((e) => e.root),
          [p.join(workspace.path, 'a'), p.join(workspace.path, 'b')],
        );
        // No plugin is used, so the list of unique plugin names is empty.
        expect(
          customLintWorkspace.uniquePluginNames,
          {'plugin1', 'plugin2', 'plugin3'},
        );

        expect(customLintWorkspace.projects, hasLength(2));

        expect(customLintWorkspace.projects.first.plugins, hasLength(2));
        expect(customLintWorkspace.projects.first.plugins[0].name, 'plugin1');
        expect(
          customLintWorkspace.projects.first.plugins[0].constraint,
          isA<HostedPubspecDependency>(),
        );
        expect(customLintWorkspace.projects.first.plugins[1].name, 'plugin3');
        expect(
          customLintWorkspace.projects.first.plugins[1].constraint,
          isA<HostedPubspecDependency>(),
        );
        expect(customLintWorkspace.projects.first.pubspec.name, 'a');

        expect(customLintWorkspace.projects[1].plugins, hasLength(2));
        expect(customLintWorkspace.projects[1].plugins[0].name, 'plugin2');
        expect(
          customLintWorkspace.projects[1].plugins[1].constraint,
          isA<HostedPubspecDependency>(),
        );
        expect(customLintWorkspace.projects[1].plugins[1].name, 'plugin3');
        expect(
          customLintWorkspace.projects[1].plugins[1].constraint,
          isA<HostedPubspecDependency>(),
        );
        expect(customLintWorkspace.projects[1].pubspec.name, 'b');
      });
    });
  });

  group(PubspecDependency, () {
    group('fromHostedDependency', () {
      test('intersect', () {
        final beforeV2 = PubspecDependency.fromDependency(
          HostedDependency(version: VersionConstraint.parse('<2.0.0')),
        );
        final afterV1 = PubspecDependency.fromDependency(
          HostedDependency(version: VersionConstraint.parse('>=1.0.0')),
        );

        expect(
          afterV1.intersect(
            PubspecDependency.fromDependency(
              HostedDependency(version: Version(0, 0, 1)),
            ),
          ),
          null,
        );

        final intersection = afterV1.intersect(beforeV2)!;
        final intersection2 = beforeV2.intersect(afterV1)!;

        for (final intersection in [intersection, intersection2]) {
          expect(
            intersection.isCompatibleWith(
              PubspecDependency.fromDependency(
                HostedDependency(version: Version(1, 0, 0)),
              ),
            ),
            true,
          );
          expect(
            intersection.isCompatibleWith(
              PubspecDependency.fromDependency(
                HostedDependency(version: Version(1, 1, 0)),
              ),
            ),
            true,
          );
          expect(
            intersection.isCompatibleWith(
              PubspecDependency.fromDependency(
                HostedDependency(version: Version(2, 0, 0)),
              ),
            ),
            false,
          );
          expect(
            intersection.isCompatibleWith(
              PubspecDependency.fromDependency(
                HostedDependency(version: Version(0, 1, 0)),
              ),
            ),
            false,
          );
        }
      });

      test('isCompatibleWith', () {
        final from10 = PubspecDependency.fromDependency(
          HostedDependency(version: VersionConstraint.parse('^1.0.0')),
        );
        final from11 = PubspecDependency.fromDependency(
          HostedDependency(version: VersionConstraint.parse('^1.1.0')),
        );

        expect(from10.isCompatibleWith(from10), true);
        expect(from10.isCompatibleWith(from11), true);
        expect(from11.isCompatibleWith(from10), true);
        expect(
          from10.isCompatibleWith(
            PubspecDependency.fromDependency(
              HostedDependency(version: Version(1, 0, 0)),
            ),
          ),
          true,
        );
        expect(
          from10.isCompatibleWith(
            PubspecDependency.fromDependency(
              HostedDependency(version: Version(2, 0, 0)),
            ),
          ),
          false,
        );

        final hosted = PubspecDependency.fromDependency(
          HostedDependency(
            version: Version(1, 0, 0),
            hosted: HostedDetails('name', Uri.parse('google.com')),
          ),
        );
        expect(
          hosted.isCompatibleWith(
            PubspecDependency.fromDependency(
              HostedDependency(
                version: Version(1, 0, 0),
                hosted: HostedDetails('name', Uri.parse('google.com')),
              ),
            ),
          ),
          true,
        );
        expect(
          hosted.isCompatibleWith(
            PubspecDependency.fromDependency(
              HostedDependency(
                version: Version(1, 0, 0),
                hosted: HostedDetails('name2', Uri.parse('google.com')),
              ),
            ),
          ),
          false,
        );
        expect(
          hosted.isCompatibleWith(
            PubspecDependency.fromDependency(
              HostedDependency(
                version: Version(1, 0, 0),
                hosted: HostedDetails('name', Uri.parse('google2.com')),
              ),
            ),
          ),
          false,
        );
      });
    });

    group('fromSdkDependency', () {
      test('intersect', () {
        final dependency = PubspecDependency.fromDependency(
          SdkDependency('path'),
        );

        expect(
          dependency.intersect(
            PubspecDependency.fromDependency(
              SdkDependency('path'),
            ),
          ),
          same(dependency),
        );
        expect(
          dependency.intersect(
            PubspecDependency.fromDependency(
              SdkDependency('path2'),
            ),
          ),
          null,
        );
      });

      test('isCompatibleWith', () {
        final dependency = PubspecDependency.fromDependency(
          SdkDependency('path'),
        );

        expect(dependency.isCompatibleWith(dependency), true);
        expect(
          dependency.isCompatibleWith(
            PubspecDependency.fromDependency(
              SdkDependency('path'),
            ),
          ),
          true,
        );
        expect(
          dependency.isCompatibleWith(
            PubspecDependency.fromDependency(
              SdkDependency('path2'),
            ),
          ),
          false,
        );
      });
    });

    group('fromPathDependency', () {
      test('intersect', () {
        final dependency = PubspecDependency.fromDependency(
          PathDependency('path'),
        );

        expect(
          dependency.intersect(
            PubspecDependency.fromDependency(
              PathDependency('path'),
            ),
          ),
          same(dependency),
        );
        expect(
          dependency.intersect(
            PubspecDependency.fromDependency(
              PathDependency('path2'),
            ),
          ),
          null,
        );
      });

      test('isCompatibleWith', () {
        final dependency = PubspecDependency.fromDependency(
          PathDependency('path'),
        );

        expect(dependency.isCompatibleWith(dependency), true);
        expect(
          dependency.isCompatibleWith(
            PubspecDependency.fromDependency(
              PathDependency('path'),
            ),
          ),
          true,
        );
        expect(
          dependency.isCompatibleWith(
            PubspecDependency.fromDependency(
              PathDependency('path2'),
            ),
          ),
          false,
        );
      });
    });

    group('fromGitDependency', () {
      test('intersect', () {
        final dependency = PubspecDependency.fromDependency(
          GitDependency(
            Uri.parse('google.com'),
            path: 'path',
            ref: '01',
          ),
        );

        expect(
          dependency.intersect(
            PubspecDependency.fromDependency(
              GitDependency(
                Uri.parse('google.com'),
                path: 'path',
                ref: '01',
              ),
            ),
          ),
          same(dependency),
        );
        expect(
          dependency.intersect(
            PubspecDependency.fromDependency(
              GitDependency(
                Uri.parse('google.com2'),
                path: 'path',
                ref: '01',
              ),
            ),
          ),
          null,
        );
      });

      test('isCompatibleWith', () {
        final dependency = PubspecDependency.fromDependency(
          GitDependency(
            Uri.parse('google.com'),
            path: 'path',
            ref: '01',
          ),
        );

        expect(dependency.isCompatibleWith(dependency), true);
        expect(
          dependency.isCompatibleWith(
            PubspecDependency.fromDependency(
              GitDependency(
                Uri.parse('google.com'),
                path: 'path',
                ref: '01',
              ),
            ),
          ),
          true,
        );
        expect(
          dependency.isCompatibleWith(
            PubspecDependency.fromDependency(
              GitDependency(
                Uri.parse('google2.com'),
                path: 'path',
                ref: '01',
              ),
            ),
          ),
          false,
        );
        expect(
          dependency.isCompatibleWith(
            PubspecDependency.fromDependency(
              GitDependency(
                Uri.parse('google.com'),
                path: 'path2',
                ref: '01',
              ),
            ),
          ),
          false,
        );
        expect(
          dependency.isCompatibleWith(
            PubspecDependency.fromDependency(
              GitDependency(
                Uri.parse('google.com'),
                path: 'path',
                ref: '013',
              ),
            ),
          ),
          false,
        );
      });
    });

    group('createPluginHostDirectory', () {
      test(
          'should create a package_config.json with no package duplicates if a dependency is used by multiple plugins',
          () async {
        final workspace =
            await createSimpleWorkspace(withPackageConfig: false, [
          Pubspec(
            'dep',
            dependencies: {
              'custom_lint_builder': HostedDependency(),
              'transitive': HostedDependency(),
            },
          ),
          'transitive',
          Pubspec(
            'dep2',
            dependencies: {
              'custom_lint_builder': HostedDependency(),
              'transitive': HostedDependency(),
            },
          ),
          'custom_lint_builder',
          Pubspec('app', devDependencies: {'dep': HostedDependency()}),
          Pubspec('app2', devDependencies: {'dep2': HostedDependency()}),
        ]);

        enableCustomLint(workspace.dir('app'));
        enableCustomLint(workspace.dir('app2'));

        writeSimplePackageConfig(workspace.dir('app'), {
          'dep': '../dep',
          'custom_lint_builder': '../custom_lint_builder',
          'transitive': '../transitive',
        });
        writeSimplePackageConfig(workspace.dir('app2'), {
          'dep2': '../dep2',
          'custom_lint_builder': '../custom_lint_builder',
          'transitive': '../transitive',
        });

        final customLintWorkspace = await CustomLintWorkspace.fromPaths(
          [workspace.path],
          workingDirectory: workspace,
        );

        final pluginHostDirectory =
            await customLintWorkspace.createPluginHostDirectory();
        final packageConfig = parsePackageConfigSync(pluginHostDirectory);

        expect(packageConfig.packages, hasLength(4));
        expect(
          packageConfig.packages.map((p) => p.name),
          unorderedEquals([
            'custom_lint_builder',
            'dep',
            'dep2',
            'transitive',
          ]),
        );
        expect(
          packageConfig.packages
              .firstWhere((p) => p.name == 'custom_lint_builder')
              .root,
          workspace.dir('custom_lint_builder').uri,
        );
        expect(
          packageConfig.packages.firstWhere((p) => p.name == 'dep').root,
          workspace.dir('dep').uri,
        );
        expect(
          packageConfig.packages.firstWhere((p) => p.name == 'dep2').root,
          workspace.dir('dep2').uri,
        );
        expect(
          packageConfig.packages.firstWhere((p) => p.name == 'transitive').root,
          workspace.dir('transitive').uri,
        );
      });

      test(
          'should create a package_config.json listing all the plugins and their transitive dependencies only',
          () async {
        final workspace =
            await createSimpleWorkspace(withPackageConfig: false, [
          Pubspec(
            'dep',
            dependencies: {
              'custom_lint_builder': HostedDependency(),
              'transitive': HostedDependency(),
            },
            devDependencies: {'dev_transitive': HostedDependency()},
            dependencyOverrides: {'dev_transitive': HostedDependency()},
          ),
          'transitive',
          'dev_transitive',
          Pubspec(
            'dep2',
            dependencies: {
              'custom_lint_builder': HostedDependency(),
              'transitive2': HostedDependency(),
            },
            devDependencies: {'dev_transitive2': HostedDependency()},
            dependencyOverrides: {'dev_transitive2': HostedDependency()},
          ),
          'transitive2',
          'dev_transitive2',
          'custom_lint_builder',
          Pubspec('app', devDependencies: {'dep': HostedDependency()}),
          Pubspec('app2', devDependencies: {'dep2': HostedDependency()}),
        ]);

        enableCustomLint(workspace.dir('app'));
        enableCustomLint(workspace.dir('app2'));

        writeSimplePackageConfig(workspace.dir('app'), {
          'dep': '../dep',
          'custom_lint_builder': '../custom_lint_builder',
          'transitive': '../transitive',
          'dev_transitive': '../dev_transitive',
        });
        writeSimplePackageConfig(workspace.dir('app2'), {
          'dep2': '../dep2',
          'custom_lint_builder': '../custom_lint_builder',
          'transitive2': '../transitive2',
          'dev_transitive2': '../dev_transitive2',
        });

        final customLintWorkspace = await CustomLintWorkspace.fromPaths(
          [workspace.path],
          workingDirectory: workspace,
        );

        final pluginHostDirectory =
            await customLintWorkspace.createPluginHostDirectory();
        final packageConfig = parsePackageConfigSync(pluginHostDirectory);

        expect(packageConfig.packages, hasLength(5));
        expect(
          packageConfig.packages.map((p) => p.name),
          unorderedEquals([
            'custom_lint_builder',
            'dep',
            'dep2',
            'transitive',
            'transitive2'
          ]),
        );
        expect(
          packageConfig.packages
              .firstWhere((p) => p.name == 'custom_lint_builder')
              .root,
          workspace.dir('custom_lint_builder').uri,
        );
        expect(
          packageConfig.packages.firstWhere((p) => p.name == 'dep').root,
          workspace.dir('dep').uri,
        );
        expect(
          packageConfig.packages.firstWhere((p) => p.name == 'dep2').root,
          workspace.dir('dep2').uri,
        );
        expect(
          packageConfig.packages.firstWhere((p) => p.name == 'transitive').root,
          workspace.dir('transitive').uri,
        );
        expect(
          packageConfig.packages
              .firstWhere((p) => p.name == 'transitive2')
              .root,
          workspace.dir('transitive2').uri,
        );
      });

      test('should NOT throw error when there are no conflicting packages',
          () async {
        final workspace =
            await createSimpleWorkspace(withPackageConfig: false, [
          Pubspec(
            'dep',
            dependencies: {'custom_lint_builder': HostedDependency()},
          ),
          'custom_lint_builder',
          Pubspec('app', devDependencies: {'dep': HostedDependency()}),
          Pubspec('app2', devDependencies: {'dep': HostedDependency()}),
        ]);

        enableCustomLint(workspace.dir('app'));
        enableCustomLint(workspace.dir('app2'));

        writeSimplePackageConfig(workspace.dir('app'), {
          'dep': '../dep',
          'custom_lint_builder': '../custom_lint_builder',
        });
        writeSimplePackageConfig(workspace.dir('app2'), {
          'dep': '../dep',
          'custom_lint_builder': '../custom_lint_builder',
        });

        final customLintWorkspace = await CustomLintWorkspace.fromPaths(
          [workspace.path],
          workingDirectory: workspace,
        );

        expect(
          await customLintWorkspace.createPluginHostDirectory(),
          isA<Directory>().having((e) => e.existsSync(), 'exists()', true),
        );
      });

      test(
          'should NOT throw if projects use different plugins with unrelated dependencies',
          () async {
        final workspace =
            await createSimpleWorkspace(withPackageConfig: false, [
          'custom_lint_builder',
          Pubspec(
            'plugin',
            dependencies: {
              'custom_lint_builder': HostedDependency(),
              'plugin_dep': HostedDependency(),
            },
          ),
          Pubspec(
            'another_plugin',
            dependencies: {
              'custom_lint_builder': HostedDependency(),
              'another_plugin_dep': HostedDependency()
            },
          ),
          'plugin_dep',
          'another_plugin_dep',
          Pubspec('app', devDependencies: {'plugin': HostedDependency()}),
          Pubspec(
            'app2',
            devDependencies: {'another_plugin': HostedDependency()},
          ),
        ]);

        enableCustomLint(workspace.dir('app'));
        enableCustomLint(workspace.dir('app2'));

        writeSimplePackageConfig(workspace.dir('app'), {
          'plugin': '../plugin',
          'plugin_dep': '../plugin_dep',
          'custom_lint_builder': '../custom_lint_builder',
        });
        writeSimplePackageConfig(workspace.dir('app2'), {
          'another_plugin': '../another_plugin',
          'another_plugin_dep': '../another_plugin_dep',
          'custom_lint_builder': '../custom_lint_builder',
        });

        final customLintWorkspace = await CustomLintWorkspace.fromPaths(
          [workspace.path],
          workingDirectory: workspace,
        );

        expect(
          await customLintWorkspace.createPluginHostDirectory(),
          isA<Directory>().having((e) => e.existsSync(), 'exists()', true),
        );
      });

      test(
          'Does not check conflicts on devDependencies & dependency_overrides of plugins',
          () async {
        final workspace =
            await createSimpleWorkspace(withPackageConfig: false, [
          Pubspec(
            'plugin',
            dependencies: {'custom_lint_builder': HostedDependency()},
            devDependencies: {'transitive_dep': HostedDependency()},
            dependencyOverrides: {'transitive_dep': HostedDependency()},
          ),
          Pubspec(
            'another_plugin',
            dependencies: {'custom_lint_builder': HostedDependency()},
            devDependencies: {'transitive_dep': HostedDependency()},
            dependencyOverrides: {'transitive_dep': HostedDependency()},
          ),
          'transitive_dep',
          'transitive_dep',
          'custom_lint_builder',
          Pubspec(
            'app',
            devDependencies: {
              'plugin': HostedDependency(version: Version(1, 0, 0))
            },
          ),
          Pubspec(
            'app2',
            devDependencies: {
              'another_plugin': HostedDependency(version: Version(2, 0, 0))
            },
          ),
        ]);

        enableCustomLint(workspace.dir('app'));
        enableCustomLint(workspace.dir('app2'));

        writeSimplePackageConfig(workspace.dir('app'), {
          'plugin': '../plugin',
          'transitive_dep': '../transitive_dep',
          'custom_lint_builder': '../custom_lint_builder',
        });
        writeSimplePackageConfig(workspace.dir('app2'), {
          'another_plugin': '../another_plugin',
          'transitive_dep': '../transitive_dep2',
          'custom_lint_builder': '../custom_lint_builder',
        });

        final customLintWorkspace = await CustomLintWorkspace.fromPaths(
          [workspace.path],
          workingDirectory: workspace,
        );

        await expectLater(
          customLintWorkspace.createPluginHostDirectory(),
          completes,
        );
      });

      test(
          'Does not check conflicts on transitive devDependencies & dependency_overrides of plugins',
          () async {
        final workspace =
            await createSimpleWorkspace(withPackageConfig: false, [
          Pubspec(
            'plugin',
            dependencies: {
              'custom_lint_builder': HostedDependency(),
              'transitive_dep': HostedDependency(),
            },
          ),
          Pubspec(
            'another_plugin',
            dependencies: {
              'custom_lint_builder': HostedDependency(),
              'transitive_dep': HostedDependency(),
            },
          ),
          Pubspec(
            'transitive_dep',
            devDependencies: {'plugin_transitive_dep': HostedDependency()},
            dependencyOverrides: {'plugin_transitive_dep': HostedDependency()},
          ),
          'plugin_transitive_dep',
          'plugin_transitive_dep',
          'custom_lint_builder',
          Pubspec(
            'app',
            devDependencies: {
              'plugin': HostedDependency(version: Version(1, 0, 0))
            },
          ),
          Pubspec(
            'app2',
            devDependencies: {
              'another_plugin': HostedDependency(version: Version(2, 0, 0))
            },
          ),
        ]);

        enableCustomLint(workspace.dir('app'));
        enableCustomLint(workspace.dir('app2'));

        writeSimplePackageConfig(workspace.dir('app'), {
          'plugin': '../plugin',
          'transitive_dep': '../transitive_dep',
          'plugin_transitive_dep': '../plugin_transitive_dep',
          'custom_lint_builder': '../custom_lint_builder',
        });
        writeSimplePackageConfig(workspace.dir('app2'), {
          'another_plugin': '../another_plugin',
          'transitive_dep': '../transitive_dep',
          'custom_lint_builder': '../custom_lint_builder',
          'plugin_transitive_dep': '../plugin_transitive_dep2',
        });

        final customLintWorkspace = await CustomLintWorkspace.fromPaths(
          [workspace.path],
          workingDirectory: workspace,
        );

        await expectLater(
          customLintWorkspace.createPluginHostDirectory(),
          completes,
        );
      });

      test(
          'Handles common transitive dependency conflict with two different plugin',
          () async {
        final workspace =
            await createSimpleWorkspace(withPackageConfig: false, [
          Pubspec(
            'plugin',
            dependencies: {
              'custom_lint_builder': HostedDependency(),
              'transitive_dep': HostedDependency(
                version: VersionConstraint.parse('^1.0.0'),
              ),
            },
          ),
          Pubspec(
            'another_plugin',
            dependencies: {
              'custom_lint_builder': HostedDependency(),
              'transitive_dep': HostedDependency(
                version: VersionConstraint.parse('^2.0.0'),
              ),
            },
          ),
          'transitive_dep',
          'transitive_dep',
          'custom_lint_builder',
          Pubspec(
            'app',
            devDependencies: {
              'plugin': HostedDependency(version: Version(1, 0, 0))
            },
          ),
          Pubspec(
            'app2',
            devDependencies: {
              'another_plugin': HostedDependency(version: Version(2, 0, 0))
            },
          ),
        ]);

        enableCustomLint(workspace.dir('app'));
        enableCustomLint(workspace.dir('app2'));

        writeSimplePackageConfig(workspace.dir('app'), {
          'plugin': '../plugin',
          'transitive_dep': '../transitive_dep',
          'custom_lint_builder': '../custom_lint_builder',
        });
        writeSimplePackageConfig(workspace.dir('app2'), {
          'another_plugin': '../another_plugin',
          'transitive_dep': '../transitive_dep2',
          'custom_lint_builder': '../custom_lint_builder',
        });

        final customLintWorkspace = await CustomLintWorkspace.fromPaths(
          [workspace.path],
          workingDirectory: workspace,
        );
        final app = customLintWorkspace.projects.firstWhere(
          (project) => project.pubspec.name == 'app',
        );
        final app2 = customLintWorkspace.projects.firstWhere(
          (project) => project.pubspec.name == 'app2',
        );

        await expectLater(
          customLintWorkspace.createPluginHostDirectory(),
          throwsA(
            isA<PackageVersionConflictError>().having(
              (error) => error.toString(),
              'toString()',
              equals(
                '''
PackageVersionConflictError – Some dependencies with conflicting versions were identified:

Package transitive_dep:
- Hosted with version constraint: ^1.0.0
  Resolved with ${workspace.dir('transitive_dep').path}/
  Used by plugin "plugin" at "plugin" in the project "app" at "app"
- Hosted with version constraint: ^2.0.0
  Resolved with ${workspace.dir('transitive_dep2').path}/
  Used by plugin "another_plugin" at "another_plugin" in the project "app2" at "app2"

$conflictExplanation
You could run the following commands to try fixing this:

cd ${app.directory.path}
dart pub upgrade transitive_dep
cd ${app2.directory.path}
dart pub upgrade transitive_dep
''',
              ),
            ),
          ),
        );
      });

      test(
          'Handles transitive dependency conflict with identical plugin version',
          () async {
        final workspace =
            await createSimpleWorkspace(withPackageConfig: false, [
          'custom_lint_builder',
          Pubspec(
            'dep',
            dependencies: {
              'custom_lint_builder': HostedDependency(),
              'transitive_dep': HostedDependency(
                version: VersionConstraint.parse('^1.0.0'),
              ),
            },
          ),
          // Another package for the sake of it
          'transitive_dep',
          'transitive_dep',
          Pubspec(
            'app',
            devDependencies: {
              'dep': HostedDependency(version: Version(1, 0, 0))
            },
          ),
          Pubspec(
            'app2',
            devDependencies: {
              'dep': HostedDependency(version: Version(2, 0, 0))
            },
          ),
        ]);

        enableCustomLint(workspace.dir('app'));
        enableCustomLint(workspace.dir('app2'));

        writeSimplePackageConfig(workspace.dir('app'), {
          'dep': '../dep',
          'transitive_dep': '../transitive_dep',
          'custom_lint_builder': '../custom_lint_builder',
        });
        writeSimplePackageConfig(workspace.dir('app2'), {
          'dep': '../dep',
          'transitive_dep': '../transitive_dep2',
          'custom_lint_builder': '../custom_lint_builder',
        });

        final customLintWorkspace = await CustomLintWorkspace.fromPaths(
          [workspace.path],
          workingDirectory: workspace,
        );
        final app = customLintWorkspace.projects.firstWhere(
          (project) => project.pubspec.name == 'app',
        );
        final app2 = customLintWorkspace.projects.firstWhere(
          (project) => project.pubspec.name == 'app2',
        );

        await expectLater(
          customLintWorkspace.createPluginHostDirectory(),
          throwsA(
            isA<PackageVersionConflictError>().having(
              (error) => error.toString(),
              'toString()',
              equals(
                '''
PackageVersionConflictError – Some dependencies with conflicting versions were identified:

Package transitive_dep:
- Hosted with version constraint: ^1.0.0
  Resolved with ${workspace.dir('transitive_dep').path}/
  Used by plugin "dep" at "dep" in the project "app" at "app"
- Hosted with version constraint: ^1.0.0
  Resolved with ${workspace.dir('transitive_dep2').path}/
  Used by plugin "dep" at "dep" in the project "app2" at "app2"

$conflictExplanation
You could run the following commands to try fixing this:

cd ${app.directory.path}
dart pub upgrade transitive_dep
cd ${app2.directory.path}
dart pub upgrade transitive_dep
''',
              ),
            ),
          ),
        );
      });

      test('Handles multiple conflicts', () async {
        final workspace =
            await createSimpleWorkspace(withPackageConfig: false, [
          'custom_lint_builder',
          Pubspec(
            'dep',
            dependencies: {'custom_lint_builder': HostedDependency()},
          ),
          // Make two packages with the same name, such that app & app2 depends
          // on a different version of the same package
          Pubspec(
            'dep',
            dependencies: {'custom_lint_builder': HostedDependency()},
          ),
          // Another package for the sake of it
          Pubspec(
            'second_dep',
            dependencies: {'custom_lint_builder': HostedDependency()},
          ),
          Pubspec(
            'second_dep',
            dependencies: {'custom_lint_builder': HostedDependency()},
          ),
          Pubspec(
            'second_dep',
            dependencies: {'custom_lint_builder': HostedDependency()},
          ),
          Pubspec(
            'app',
            devDependencies: {
              'dep': HostedDependency(version: Version(1, 0, 0)),
              'second_dep': HostedDependency(version: Version(1, 1, 0)),
            },
          ),
          Pubspec(
            'app2',
            devDependencies: {
              'dep': HostedDependency(version: Version(2, 0, 0)),
              'second_dep': HostedDependency(version: Version(2, 1, 0)),
            },
          ),
          Pubspec(
            'app3',
            devDependencies: {
              'dep': HostedDependency(version: Version(1, 0, 0)),
              'second_dep': HostedDependency(version: Version(3, 1, 0)),
            },
          ),
        ]);

        enableCustomLint(workspace.dir('app'));
        enableCustomLint(workspace.dir('app2'));
        enableCustomLint(workspace.dir('app3'));

        writeSimplePackageConfig(workspace.dir('app'), {
          'dep': '../dep',
          'second_dep': '../second_dep',
          'custom_lint_builder': '../custom_lint_builder',
        });
        writeSimplePackageConfig(workspace.dir('app2'), {
          'dep': '../dep2',
          'second_dep': '../second_dep2',
          'custom_lint_builder': '../custom_lint_builder',
        });
        writeSimplePackageConfig(workspace.dir('app3'), {
          'dep': '../dep2',
          'second_dep': '../second_dep3',
          'custom_lint_builder': '../custom_lint_builder',
        });

        final customLintWorkspace = await CustomLintWorkspace.fromPaths(
          [workspace.path],
          workingDirectory: workspace,
        );
        final app = customLintWorkspace.projects.firstWhere(
          (project) => project.pubspec.name == 'app',
        );
        final app2 = customLintWorkspace.projects.firstWhere(
          (project) => project.pubspec.name == 'app2',
        );
        final app3 = customLintWorkspace.projects.firstWhere(
          (project) => project.pubspec.name == 'app3',
        );

        await expectLater(
          customLintWorkspace.createPluginHostDirectory(),
          throwsA(
            isA<PackageVersionConflictError>().having(
              (error) => error.toString(),
              'toString()',
              equals(
                '''
PackageVersionConflictError – Some dependencies with conflicting versions were identified:

Plugin dep:
- Hosted with version constraint: 1.0.0
  Resolved with ${app.plugins[0].package.root.path}
  Used by project "app" at "app"
- Hosted with version constraint: 2.0.0
  Resolved with ${app2.plugins[0].package.root.path}
  Used by project "app2" at "app2"
- Hosted with version constraint: 1.0.0
  Resolved with ${app3.plugins[0].package.root.path}
  Used by project "app3" at "app3"

Plugin second_dep:
- Hosted with version constraint: 1.1.0
  Resolved with ${app.plugins[1].package.root.path}
  Used by project "app" at "app"
- Hosted with version constraint: 2.1.0
  Resolved with ${app2.plugins[1].package.root.path}
  Used by project "app2" at "app2"
- Hosted with version constraint: 3.1.0
  Resolved with ${app3.plugins[1].package.root.path}
  Used by project "app3" at "app3"

$conflictExplanation
You could run the following commands to try fixing this:

cd ${app.directory.path}
dart pub upgrade dep second_dep
cd ${app2.directory.path}
dart pub upgrade dep second_dep
cd ${app3.directory.path}
dart pub upgrade dep second_dep
''',
              ),
            ),
          ),
        );
      });

      test('Handles SDK dependencies', () async {
        final workspace =
            await createSimpleWorkspace(withPackageConfig: false, [
          'custom_lint_builder',
          Pubspec(
            'dep',
            dependencies: {'custom_lint_builder': HostedDependency()},
          ),
          // Make two packages with the same name, such that app & app2 depends
          // on a different version of the same package
          Pubspec(
            'dep',
            dependencies: {'custom_lint_builder': HostedDependency()},
          ),
          Pubspec(
            'app',
            devDependencies: {
              'dep':
                  HostedDependency(version: VersionConstraint.parse('^1.0.0'))
            },
          ),
          Pubspec(
            'app2',
            devDependencies: {'dep': SdkDependency('flutter')},
          ),
        ]);

        enableCustomLint(workspace.dir('app'));
        enableCustomLint(workspace.dir('app2'));

        writeSimplePackageConfig(workspace.dir('app'), {
          'dep': '../dep',
          'custom_lint_builder': '../custom_lint_builder',
        });
        writeSimplePackageConfig(workspace.dir('app2'), {
          'dep': '../dep2',
          'custom_lint_builder': '../custom_lint_builder',
        });

        final customLintWorkspace = await CustomLintWorkspace.fromPaths(
          [workspace.path],
          workingDirectory: workspace,
        );
        final app = customLintWorkspace.projects.firstWhere(
          (project) => project.pubspec.name == 'app',
        );
        final app2 = customLintWorkspace.projects.firstWhere(
          (project) => project.pubspec.name == 'app2',
        );

        await expectLater(
          customLintWorkspace.createPluginHostDirectory(),
          throwsA(
            isA<PackageVersionConflictError>().having(
              (error) => error.toString(),
              'toString()',
              equals(
                '''
PackageVersionConflictError – Some dependencies with conflicting versions were identified:

Plugin dep:
- Hosted with version constraint: ^1.0.0
  Resolved with ${app.plugins.single.package.root.path}
  Used by project "app" at "app"
- From SDK: flutter
  Resolved with ${app2.plugins.single.package.root.path}
  Used by project "app2" at "app2"

$conflictExplanation
You could run the following commands to try fixing this:

cd ${app.directory.path}
dart pub upgrade dep
cd ${app2.directory.path}
dart pub upgrade dep
''',
              ),
            ),
          ),
        );
      });

      test('Handles hosted dependencies', () async {
        final workspace =
            await createSimpleWorkspace(withPackageConfig: false, [
          'custom_lint_builder',
          Pubspec(
            'dep',
            dependencies: {'custom_lint_builder': HostedDependency()},
          ),
          // Make two packages with the same name, such that app & app2 depends
          // on a different version of the same package
          Pubspec(
            'dep',
            dependencies: {'custom_lint_builder': HostedDependency()},
          ),
          Pubspec(
            'app',
            devDependencies: {
              'dep':
                  HostedDependency(version: VersionConstraint.parse('^1.0.0'))
            },
          ),
          Pubspec(
            'app2',
            devDependencies: {
              'dep': HostedDependency(
                version: VersionConstraint.parse('>=2.0.0 <3.0.0'),
              )
            },
          ),
        ]);

        enableCustomLint(workspace.dir('app'));
        enableCustomLint(workspace.dir('app2'));

        writeSimplePackageConfig(workspace.dir('app'), {
          'dep': '../dep',
          'custom_lint_builder': '../custom_lint_builder',
        });
        writeSimplePackageConfig(workspace.dir('app2'), {
          'dep': '../dep2',
          'custom_lint_builder': '../custom_lint_builder',
        });

        final customLintWorkspace = await CustomLintWorkspace.fromPaths(
          [workspace.path],
          workingDirectory: workspace,
        );
        final app = customLintWorkspace.projects.firstWhere(
          (project) => project.pubspec.name == 'app',
        );
        final app2 = customLintWorkspace.projects.firstWhere(
          (project) => project.pubspec.name == 'app2',
        );

        await expectLater(
          customLintWorkspace.createPluginHostDirectory(),
          throwsA(
            isA<PackageVersionConflictError>().having(
              (error) => error.toString(),
              'toString()',
              equals(
                '''
PackageVersionConflictError – Some dependencies with conflicting versions were identified:

Plugin dep:
- Hosted with version constraint: ^1.0.0
  Resolved with ${app.plugins.single.package.root.path}
  Used by project "app" at "app"
- Hosted with version constraint: >=2.0.0 <3.0.0
  Resolved with ${app2.plugins.single.package.root.path}
  Used by project "app2" at "app2"

$conflictExplanation
You could run the following commands to try fixing this:

cd ${app.directory.path}
dart pub upgrade dep
cd ${app2.directory.path}
dart pub upgrade dep
''',
              ),
            ),
          ),
        );
      });

      test('Handles path dependencies', () async {
        final workspace =
            await createSimpleWorkspace(withPackageConfig: false, [
          'custom_lint_builder',
          Pubspec(
            'dep',
            dependencies: {'custom_lint_builder': HostedDependency()},
          ),
          // Make two packages with the same name, such that app & app2 depends
          // on a different version of the same package
          Pubspec(
            'dep',
            dependencies: {'custom_lint_builder': HostedDependency()},
          ),
          Pubspec(
            'app',
            devDependencies: {
              'dep': HostedDependency(version: Version(1, 0, 0))
            },
          ),
          Pubspec(
            'app2',
            devDependencies: {'dep': PathDependency('../dep2')},
          ),
        ]);

        enableCustomLint(workspace.dir('app'));
        enableCustomLint(workspace.dir('app2'));

        writeSimplePackageConfig(workspace.dir('app'), {
          'dep': '../dep',
          'custom_lint_builder': '../custom_lint_builder',
        });
        writeSimplePackageConfig(workspace.dir('app2'), {
          'dep': '../dep2',
          'custom_lint_builder': '../custom_lint_builder',
        });

        final customLintWorkspace = await CustomLintWorkspace.fromPaths(
          [workspace.path],
          workingDirectory: workspace,
        );
        final app = customLintWorkspace.projects.firstWhere(
          (project) => project.pubspec.name == 'app',
        );
        final app2 = customLintWorkspace.projects.firstWhere(
          (project) => project.pubspec.name == 'app2',
        );

        await expectLater(
          customLintWorkspace.createPluginHostDirectory(),
          throwsA(
            isA<PackageVersionConflictError>().having(
              (error) => error.toString(),
              'toString()',
              equals(
                '''
PackageVersionConflictError – Some dependencies with conflicting versions were identified:

Plugin dep:
- Hosted with version constraint: 1.0.0
  Resolved with ${app.plugins.single.package.root.path}
  Used by project "app" at "app"
- From path ../dep2
  Resolved with ${app2.plugins.single.package.root.path}
  Used by project "app2" at "app2"

$conflictExplanation
You could run the following commands to try fixing this:

cd ${app.directory.path}
dart pub upgrade dep
cd ${app2.directory.path}
dart pub upgrade dep
''',
              ),
            ),
          ),
        );
      });

      test(
          'Picks between "flutter pub" and "dart pub" '
          'depending on if a provider uses flutter or not', () async {
        final workspace =
            await createSimpleWorkspace(withPackageConfig: false, [
          'custom_lint_builder',
          Pubspec(
            'dep',
            dependencies: {'custom_lint_builder': HostedDependency()},
          ),
          // Make two packages with the same name, such that app & app2 depends
          // on a different version of the same package
          Pubspec(
            'dep',
            dependencies: {'custom_lint_builder': HostedDependency()},
          ),
          Pubspec(
            'app',
            devDependencies: {
              'dep': HostedDependency(version: Version(1, 0, 1))
            },
          ),
          Pubspec(
            'app2',
            dependencies: {'flutter': SdkDependency('flutter')},
            devDependencies: {
              'dep': HostedDependency(version: Version(1, 0, 0))
            },
          ),
        ]);

        enableCustomLint(workspace.dir('app'));
        enableCustomLint(workspace.dir('app2'));

        writeSimplePackageConfig(workspace.dir('app'), {
          'dep': '../dep',
          'custom_lint_builder': '../custom_lint_builder',
        });
        writeSimplePackageConfig(workspace.dir('app2'), {
          'dep': '../dep2',
          'custom_lint_builder': '../custom_lint_builder',
        });

        final customLintWorkspace = await CustomLintWorkspace.fromPaths(
          [workspace.path],
          workingDirectory: workspace,
        );
        final app = customLintWorkspace.projects.firstWhere(
          (project) => project.pubspec.name == 'app',
        );
        final app2 = customLintWorkspace.projects.firstWhere(
          (project) => project.pubspec.name == 'app2',
        );

        await expectLater(
          customLintWorkspace.createPluginHostDirectory(),
          throwsA(
            isA<PackageVersionConflictError>().having(
              (error) => error.toString(),
              'toString()',
              equals(
                '''
PackageVersionConflictError – Some dependencies with conflicting versions were identified:

Plugin dep:
- Hosted with version constraint: 1.0.1
  Resolved with ${app.plugins.single.package.root.path}
  Used by project "app" at "app"
- Hosted with version constraint: 1.0.0
  Resolved with ${app2.plugins.single.package.root.path}
  Used by project "app2" at "app2"

$conflictExplanation
You could run the following commands to try fixing this:

cd ${app.directory.path}
dart pub upgrade dep
cd ${app2.directory.path}
flutter pub upgrade dep
''',
              ),
            ),
          ),
        );
      });

      test('should show git dependency without path and ref', () async {
        final workspace =
            await createSimpleWorkspace(withPackageConfig: false, [
          'custom_lint_builder',
          Pubspec(
            'dep',
            dependencies: {'custom_lint_builder': HostedDependency()},
          ),
          // Make two packages with the same name, such that app & app2 depends
          // on a different version of the same package
          Pubspec(
            'dep',
            dependencies: {'custom_lint_builder': HostedDependency()},
          ),
          Pubspec(
            'app',
            devDependencies: {
              'dep': GitDependency(
                Uri.parse('ssh://git@github.com/rrousselGit/freezed.git'),
              ),
            },
          ),
          Pubspec(
            'app2',
            devDependencies: {
              'dep': HostedDependency(version: Version(1, 0, 0))
            },
          ),
        ]);

        enableCustomLint(workspace.dir('app'));
        enableCustomLint(workspace.dir('app2'));

        writeSimplePackageConfig(workspace.dir('app'), {
          'dep': '../dep',
          'custom_lint_builder': '../custom_lint_builder',
        });
        writeSimplePackageConfig(workspace.dir('app2'), {
          'dep': '../dep2',
          'custom_lint_builder': '../custom_lint_builder',
        });

        final customLintWorkspace = await CustomLintWorkspace.fromPaths(
          [workspace.path],
          workingDirectory: workspace,
        );
        final app = customLintWorkspace.projects.firstWhere(
          (project) => project.pubspec.name == 'app',
        );
        final app2 = customLintWorkspace.projects.firstWhere(
          (project) => project.pubspec.name == 'app2',
        );

        await expectLater(
          customLintWorkspace.createPluginHostDirectory(),
          throwsA(
            isA<PackageVersionConflictError>().having(
              (error) => error.toString(),
              'toString()',
              equals(
                '''
PackageVersionConflictError – Some dependencies with conflicting versions were identified:

Plugin dep:
- From git url ssh://git@github.com/rrousselGit/freezed.git
  Resolved with ${app.plugins.single.package.root.path}
  Used by project "app" at "app"
- Hosted with version constraint: 1.0.0
  Resolved with ${app2.plugins.single.package.root.path}
  Used by project "app2" at "app2"

$conflictExplanation
You could run the following commands to try fixing this:

cd ${app.directory.path}
dart pub upgrade dep
cd ${app2.directory.path}
dart pub upgrade dep
''',
              ),
            ),
          ),
        );
      });

      test('should show git dependency without path', () async {
        final workspace =
            await createSimpleWorkspace(withPackageConfig: false, [
          'custom_lint_builder',
          Pubspec(
            'dep',
            dependencies: {'custom_lint_builder': HostedDependency()},
          ),
          // Make two packages with the same name, such that app & app2 depends
          // on a different version of the same package
          Pubspec(
            'dep',
            dependencies: {'custom_lint_builder': HostedDependency()},
          ),
          Pubspec(
            'app',
            devDependencies: {
              'dep': GitDependency(
                Uri.parse('ssh://git@github.com/rrousselGit/freezed.git'),
                path: 'packages/freezed',
              ),
            },
          ),
          Pubspec(
            'app2',
            devDependencies: {
              'dep': HostedDependency(version: Version(1, 0, 0))
            },
          ),
        ]);

        enableCustomLint(workspace.dir('app'));
        enableCustomLint(workspace.dir('app2'));

        writeSimplePackageConfig(workspace.dir('app'), {
          'dep': '../dep',
          'custom_lint_builder': '../custom_lint_builder',
        });
        writeSimplePackageConfig(workspace.dir('app2'), {
          'dep': '../dep2',
          'custom_lint_builder': '../custom_lint_builder',
        });

        final customLintWorkspace = await CustomLintWorkspace.fromPaths(
          [workspace.path],
          workingDirectory: workspace,
        );
        final app = customLintWorkspace.projects.firstWhere(
          (project) => project.pubspec.name == 'app',
        );
        final app2 = customLintWorkspace.projects.firstWhere(
          (project) => project.pubspec.name == 'app2',
        );

        await expectLater(
          customLintWorkspace.createPluginHostDirectory(),
          throwsA(
            isA<PackageVersionConflictError>().having(
              (error) => error.toString(),
              'toString()',
              equals(
                '''
PackageVersionConflictError – Some dependencies with conflicting versions were identified:

Plugin dep:
- From git url ssh://git@github.com/rrousselGit/freezed.git path packages/freezed
  Resolved with ${app.plugins.single.package.root.path}
  Used by project "app" at "app"
- Hosted with version constraint: 1.0.0
  Resolved with ${app2.plugins.single.package.root.path}
  Used by project "app2" at "app2"

$conflictExplanation
You could run the following commands to try fixing this:

cd ${app.directory.path}
dart pub upgrade dep
cd ${app2.directory.path}
dart pub upgrade dep
''',
              ),
            ),
          ),
        );
      });

      test('should show git dependency without ref', () async {
        final workspace =
            await createSimpleWorkspace(withPackageConfig: false, [
          'custom_lint_builder',
          Pubspec(
            'dep',
            dependencies: {'custom_lint_builder': HostedDependency()},
          ),
          // Make two packages with the same name, such that app & app2 depends
          // on a different version of the same package
          Pubspec(
            'dep',
            dependencies: {'custom_lint_builder': HostedDependency()},
          ),
          Pubspec(
            'app',
            devDependencies: {
              'dep': GitDependency(
                Uri.parse('ssh://git@github.com/rrousselGit/freezed.git'),
                ref: '123',
              ),
            },
          ),
          Pubspec(
            'app2',
            devDependencies: {
              'dep': HostedDependency(version: Version(1, 0, 0))
            },
          ),
        ]);

        enableCustomLint(workspace.dir('app'));
        enableCustomLint(workspace.dir('app2'));

        writeSimplePackageConfig(workspace.dir('app'), {
          'dep': '../dep',
          'custom_lint_builder': '../custom_lint_builder',
        });
        writeSimplePackageConfig(workspace.dir('app2'), {
          'dep': '../dep2',
          'custom_lint_builder': '../custom_lint_builder',
        });

        final customLintWorkspace = await CustomLintWorkspace.fromPaths(
          [workspace.path],
          workingDirectory: workspace,
        );
        final app = customLintWorkspace.projects.firstWhere(
          (project) => project.pubspec.name == 'app',
        );
        final app2 = customLintWorkspace.projects.firstWhere(
          (project) => project.pubspec.name == 'app2',
        );

        await expectLater(
          customLintWorkspace.createPluginHostDirectory(),
          throwsA(
            isA<PackageVersionConflictError>().having(
              (error) => error.toString(),
              'toString()',
              equals(
                '''
PackageVersionConflictError – Some dependencies with conflicting versions were identified:

Plugin dep:
- From git url ssh://git@github.com/rrousselGit/freezed.git ref 123
  Resolved with ${app.plugins.single.package.root.path}
  Used by project "app" at "app"
- Hosted with version constraint: 1.0.0
  Resolved with ${app2.plugins.single.package.root.path}
  Used by project "app2" at "app2"

$conflictExplanation
You could run the following commands to try fixing this:

cd ${app.directory.path}
dart pub upgrade dep
cd ${app2.directory.path}
dart pub upgrade dep
''',
              ),
            ),
          ),
        );
      });
    });
  });
}
