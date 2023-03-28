import 'dart:convert';
import 'dart:io';

import 'package:analyzer_plugin/protocol/protocol_generated.dart';
import 'package:custom_lint/src/workspace.dart';
import 'package:package_config/package_config.dart';
import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:test/test.dart';

Package createPackage(String name, String version) {
  return Package(
    name,
    Uri.parse('file:///Users/user/.pub-cache/hosted/pub.dev/$name-$version/'),
  );
}

Package createGitPackage(String name, String gitPath) {
  return Package(
    name,
    Uri.parse('file:///Users/user/.pub-cache/git/$name-$gitPath/'),
  );
}

Package createPathPackage(String name, String path) {
  return Package(
    name,
    Uri.parse('file://$path'),
    relativeRoot: false,
  );
}

ContextRoot createContextRoot(String relativePath) {
  return ContextRoot('/Users/user/project/$relativePath', []);
}

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
          'url': that.url,
          if (that.path != null) 'path': that.path,
          if (that.ref != null) 'ref': that.ref,
        }
      };
    } else if (that is PathDependency) {
      return that.path;
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
      'version': version.toString(),
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
  List<Object> projectEntry,
) async {
  /// The number of time we've created a package with a given name.
  final packageCount = <String, int>{};

  String getFolderName(Pubspec pubspec) {
    // If a package with the same name was already created previously,
    // we suffix the folder name with an incrementing number.
    final projectFolderSuffix = packageCount[pubspec.name] == null
        ? ''
        : packageCount[pubspec.name]!.toString();
    final folderName = '${pubspec.name}$projectFolderSuffix';

    // Increment the counter for changing the suffix for the next similarly
    // named package
    packageCount[pubspec.name] = (packageCount[pubspec.name] ?? 1) + 1;

    return folderName;
  }

  return createWorkspace({
    for (final projectEntry in projectEntry)
      if (projectEntry is Pubspec)
        getFolderName(projectEntry): projectEntry
      else if (projectEntry is String)
        projectEntry: Pubspec(
          p.basename(projectEntry),
          version: Version(1, 0, 0),
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
Future<Directory> createWorkspace(Map<String, Pubspec> pubspecs) async {
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
          packageConfigs: [
            for (final dependency in pubspecEntry.value.dependencies.entries)
              dependency.value.toPackageJson(
                name: dependency.key,
                rootUri: packagePathOf(dependency.value, dependency.key),
              ),
            for (final dependency in pubspecEntry.value.devDependencies.entries)
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
  final dir = Directory.systemTemp.createTempSync('custom_lint_test');
  addTearDown(() => dir.deleteSync(recursive: true));
  return dir;
}

extension on Directory {
  File file(String name) => File(p.join(path, name));
  Directory dir(String name) => Directory(p.join(path, name));

  File get analysisOptions => file('analysis_options.yaml');
  File get pubspec => file('pubspec.yaml');
  File get packageConfig => dir('.dart_tool').file('package_config.json');
}

void writeFile(File file, String content) {
  file.createSync(recursive: true);
  file.writeAsStringSync(content);
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
          packageDir.dir('lib').file('other.yaml'),
          'foo: bar',
        );

        const package2Name = 'bar';
        final package2Dir = dir.dir('packages/$package2Name');
        writeFile(
          package2Dir.dir('lib').dir('src').file('file.yaml'),
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

      final includedFile = dir.dir('dir').file('included.yaml');
      // The relative path is based on the location of includedFile
      // rather than "analysisOptions".
      writeFile(includedFile, 'include: ../dir2/other.yaml');

      final otherFile = dir.dir('dir2').file('other.yaml');
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
    group('fromDirectory', () {
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

        final customLintWorkspace = await CustomLintWorkspace.fromDirectory(
          workspace,
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

        final customLintWorkspace = await CustomLintWorkspace.fromDirectory(
          workspace,
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
      test('throws MissingPubspecError if package does not contain a pubspec',
          () async {
        final workspace = await createSimpleWorkspace([]);
        workspace.dir('package').createSync(recursive: true);

        expect(
          () => CustomLintWorkspace.fromContextRoots([
            p.join(workspace.path, 'package'),
          ]),
          throwsA(isA<MissingPubspecError>()),
        );
      });

      test(
          'throws MissingPackageConfigError if package has a pubspec but no .dart_tool/package_config.json',
          () async {
        final workspace = await createSimpleWorkspace(['package']);
        workspace.dir('package').dir('.dart_tool').deleteSync(recursive: true);

        expect(
          () => CustomLintWorkspace.fromContextRoots([
            p.join(workspace.path, 'package'),
          ]),
          throwsA(isA<MissingPackageConfigError>()),
        );
      });

      test('Supports empty workspace', () async {
        final customLintWorkspace =
            await CustomLintWorkspace.fromContextRoots([]);

        expect(customLintWorkspace.contextRoots, isEmpty);
        expect(customLintWorkspace.uniquePluginNames, isEmpty);
        expect(customLintWorkspace.projects, isEmpty);
      });

      test('Supports projects with no plugins', () async {
        final workspace = await createSimpleWorkspace(['package']);

        final customLintWorkspace = await CustomLintWorkspace.fromContextRoots([
          p.join(workspace.path, 'package'),
        ]);

        expect(
          customLintWorkspace.contextRoots,
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

        final customLintWorkspace = await CustomLintWorkspace.fromContextRoots([
          p.join(workspace.path, 'a'),
          p.join(workspace.path, 'b'),
        ]);

        expect(
          customLintWorkspace.contextRoots,
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
  });

  group(ConflictingPackagesChecker, () {
    test('should NOT throw error when there are no conflicting packages', () {
      final checker = ConflictingPackagesChecker();
      // We don't need to pass a real pubspec here
      final pubspec = Pubspec('fake_package');
      final contextRoots = [
        createContextRoot('app'),
        createContextRoot('app/packages/http'),
      ];
      final firstContextRootPackages = [
        createPackage('riverpod', '2.2.0'),
        createPackage('flutter_hooks', '0.18.6'),
        createPackage('freezed', '2.3.2'),
      ];
      final secondContextRootPackages = [
        // Same package as in the first context root
        // so there is no conflict here
        createPackage('riverpod', '2.2.0'),
        createPackage('http', '0.13.3'),
        createPackage('http_parser', '4.0.0'),
      ];

      checker.addContextRoot(
        contextRoots[0].root,
        firstContextRootPackages,
        pubspec,
      );
      checker.addContextRoot(
        contextRoots[1].root,
        secondContextRootPackages,
        pubspec,
      );

      expect(
        checker.throwErrorIfConflictingPackages,
        returnsNormally,
      );
    });

    test('should throw error when there are conflicting packages', () {
      final checker = ConflictingPackagesChecker();
      final flutterDependency = HostedDependency();
      final firstPubspec = Pubspec(
        'app',
        dependencies: {
          'flutter': flutterDependency,
        },
      );
      final secondPubspec = Pubspec(
        'http',
        dependencies: {
          'flutter': flutterDependency,
        },
      );
      final thirdPubspec = Pubspec(
        'design_system',
        dependencies: {
          'flutter': flutterDependency,
          'freezed': GitDependency(
            Uri.parse('ssh://git@github.com/rrousselGit/freezed.git'),
            ref: '4cdfbf9159f2e9746fce29d2862f148f901da66a',
            path: 'packages/freezed',
          ),
        },
      );
      final firstContextRoot = createContextRoot('app');
      final secondContextRoot = createContextRoot('app/packages/http');
      final thirdContextRoot = createContextRoot('app/packages/design_system');
      final firstContextRootPackages = [
        createPackage('riverpod', '2.2.0'),
        createPackage('flutter_hooks', '0.18.6'),
        createPackage('freezed', '2.3.2'),
      ];
      final secondContextRootPackages = [
        // Same package as in the first context root, but with different version
        // this should cause an error
        createPackage('riverpod', '2.1.0'),
        // This should also be shown in the error message
        createPackage('flutter_hooks', '0.18.5'),
        createPackage('http', '0.13.3'),
        createPackage('http_parser', '4.0.0'),
        createPathPackage('freezed', '/Users/user/freezed/packages/freezed/'),
        // This is to simulate a transitive git dependency
        createGitPackage(
          'http_parser',
          '4cdfbf9159123746fce29d2862f148f901da66a',
        ),
      ];
      // Here we want to test that the error message contains multiple locations
      final thirdContextRootPackages = [
        createPackage('riverpod', '2.1.1'),
        createPackage('flutter_hooks', '0.18.5'),
        // This is a git package, so we want to make sure it's handled correctly
        createGitPackage(
          'freezed',
          '4cdfbf9159f2e9746fce29d2862f148f901da66a/packages/freezed',
        ),
        createPackage('http_parser', '4.0.0'),
      ];

      checker.addContextRoot(
        firstContextRoot.root,
        firstContextRootPackages,
        firstPubspec,
      );
      checker.addContextRoot(
        secondContextRoot.root,
        secondContextRootPackages,
        secondPubspec,
      );
      checker.addContextRoot(
        thirdContextRoot.root,
        thirdContextRootPackages,
        thirdPubspec,
      );

      expect(
        checker.throwErrorIfConflictingPackages,
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            equals(
              '''
Some dependencies with conflicting versions were identified:

app at /Users/user/project/app
- riverpod v2.2.0
- flutter_hooks v0.18.6
- freezed v2.3.2

http at /Users/user/project/app/packages/http
- riverpod v2.1.0
- flutter_hooks v0.18.5
- http_parser v4.0.0
- freezed from path /Users/user/freezed/packages/freezed/
- http_parser from git 4cdfbf9159123746fce29d2862f148f901da66a/

design_system at /Users/user/project/app/packages/design_system
- riverpod v2.1.1
- flutter_hooks v0.18.5
- freezed from git url ssh://git@github.com/rrousselGit/freezed.git ref 4cdfbf9159f2e9746fce29d2862f148f901da66a path packages/freezed
- http_parser v4.0.0

This is not supported. Custom_lint shares the analysis between all packages. As such, all plugins are started under a single process, sharing the dependencies of all the packages that use custom_lint. Since there's a single process for all plugins, if 2 plugins try to use different versions for a dependency, the process cannot be reasonably started. Please make sure all packages have the same version.
You could run the following commands to try fixing this:

cd /Users/user/project/app
flutter pub upgrade riverpod flutter_hooks freezed
cd /Users/user/project/app/packages/http
flutter pub upgrade riverpod flutter_hooks http_parser freezed http_parser
cd /Users/user/project/app/packages/design_system
flutter pub upgrade riverpod flutter_hooks freezed http_parser
''',
            ),
          ),
        ),
      );
    });

    test('pure dart packages should have simple pub upgrade command', () {
      final checker = ConflictingPackagesChecker();
      final firstPubspec = Pubspec('app');
      final secondPubspec = Pubspec('http');
      final firstContextRoot = createContextRoot('app');
      final secondContextRoot = createContextRoot('app/packages/http');
      final firstContextRootPackages = [
        createPackage('riverpod', '2.2.0'),
        createPackage('freezed', '2.3.2'),
      ];
      final secondContextRootPackages = [
        createPackage('riverpod', '2.1.0'),
        createPackage('freezed', '2.3.1'),
      ];

      checker.addContextRoot(
        firstContextRoot.root,
        firstContextRootPackages,
        firstPubspec,
      );
      checker.addContextRoot(
        secondContextRoot.root,
        secondContextRootPackages,
        secondPubspec,
      );

      expect(
        checker.throwErrorIfConflictingPackages,
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            equals(
              '''
Some dependencies with conflicting versions were identified:

app at /Users/user/project/app
- riverpod v2.2.0
- freezed v2.3.2

http at /Users/user/project/app/packages/http
- riverpod v2.1.0
- freezed v2.3.1

This is not supported. Custom_lint shares the analysis between all packages. As such, all plugins are started under a single process, sharing the dependencies of all the packages that use custom_lint. Since there's a single process for all plugins, if 2 plugins try to use different versions for a dependency, the process cannot be reasonably started. Please make sure all packages have the same version.
You could run the following commands to try fixing this:

cd /Users/user/project/app
dart pub upgrade riverpod freezed
cd /Users/user/project/app/packages/http
dart pub upgrade riverpod freezed
''',
            ),
          ),
        ),
      );
    });

    test('should show git dependency without path and ref', () {
      final checker = ConflictingPackagesChecker();
      final firstPubspec = Pubspec('app');
      final secondPubspec = Pubspec(
        'http',
        dependencies: {
          'freezed': GitDependency(
            Uri.parse('ssh://git@github.com/rrousselGit/freezed.git'),
          ),
        },
      );
      final firstContextRoot = createContextRoot('app');
      final secondContextRoot = createContextRoot('app/packages/http');
      final firstContextRootPackages = [
        createPackage('riverpod', '2.2.0'),
        createPackage('freezed', '2.3.2'),
      ];
      final secondContextRootPackages = [
        createPackage('riverpod', '2.1.0'),
        createGitPackage('freezed', '4cdfbf9159f2e9746fce29d2862f148f901da66a'),
      ];

      checker.addContextRoot(
        firstContextRoot.root,
        firstContextRootPackages,
        firstPubspec,
      );
      checker.addContextRoot(
        secondContextRoot.root,
        secondContextRootPackages,
        secondPubspec,
      );

      expect(
        checker.throwErrorIfConflictingPackages,
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            equals(
              '''
Some dependencies with conflicting versions were identified:

app at /Users/user/project/app
- riverpod v2.2.0
- freezed v2.3.2

http at /Users/user/project/app/packages/http
- riverpod v2.1.0
- freezed from git url ssh://git@github.com/rrousselGit/freezed.git

This is not supported. Custom_lint shares the analysis between all packages. As such, all plugins are started under a single process, sharing the dependencies of all the packages that use custom_lint. Since there's a single process for all plugins, if 2 plugins try to use different versions for a dependency, the process cannot be reasonably started. Please make sure all packages have the same version.
You could run the following commands to try fixing this:

cd /Users/user/project/app
dart pub upgrade riverpod freezed
cd /Users/user/project/app/packages/http
dart pub upgrade riverpod freezed
''',
            ),
          ),
        ),
      );
    });

    test('should show git dependency without path', () {
      final checker = ConflictingPackagesChecker();
      final firstPubspec = Pubspec('app');
      final secondPubspec = Pubspec(
        'http',
        dependencies: {
          'freezed': GitDependency(
            Uri.parse('ssh://git@github.com/rrousselGit/freezed.git'),
            ref: '4cdfbf9159f2e9746fce29d2862f148f901da66a',
          ),
        },
      );
      final firstContextRoot = createContextRoot('app');
      final secondContextRoot = createContextRoot('app/packages/http');
      final firstContextRootPackages = [
        createPackage('riverpod', '2.2.0'),
        createPackage('freezed', '2.3.2'),
      ];
      final secondContextRootPackages = [
        createPackage('riverpod', '2.1.0'),
        createGitPackage('freezed', '4cdfbf9159f2e9746fce29d2862f148f901da66a'),
      ];

      checker.addContextRoot(
        firstContextRoot.root,
        firstContextRootPackages,
        firstPubspec,
      );
      checker.addContextRoot(
        secondContextRoot.root,
        secondContextRootPackages,
        secondPubspec,
      );

      expect(
        checker.throwErrorIfConflictingPackages,
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            equals(
              '''
Some dependencies with conflicting versions were identified:

app at /Users/user/project/app
- riverpod v2.2.0
- freezed v2.3.2

http at /Users/user/project/app/packages/http
- riverpod v2.1.0
- freezed from git url ssh://git@github.com/rrousselGit/freezed.git ref 4cdfbf9159f2e9746fce29d2862f148f901da66a

This is not supported. Custom_lint shares the analysis between all packages. As such, all plugins are started under a single process, sharing the dependencies of all the packages that use custom_lint. Since there's a single process for all plugins, if 2 plugins try to use different versions for a dependency, the process cannot be reasonably started. Please make sure all packages have the same version.
You could run the following commands to try fixing this:

cd /Users/user/project/app
dart pub upgrade riverpod freezed
cd /Users/user/project/app/packages/http
dart pub upgrade riverpod freezed
''',
            ),
          ),
        ),
      );
    });

    test('should show git dependency without ref', () {
      final checker = ConflictingPackagesChecker();
      final firstPubspec = Pubspec('app');
      final secondPubspec = Pubspec(
        'http',
        dependencies: {
          'freezed': GitDependency(
            Uri.parse('ssh://git@github.com/rrousselGit/freezed.git'),
            path: 'packages/freezed',
          ),
        },
      );
      final firstContextRoot = createContextRoot('app');
      final secondContextRoot = createContextRoot('app/packages/http');
      final firstContextRootPackages = [
        createPackage('riverpod', '2.2.0'),
        createPackage('freezed', '2.3.2'),
      ];
      final secondContextRootPackages = [
        createPackage('riverpod', '2.1.0'),
        createGitPackage('freezed', '4cdfbf9159f2e9746fce29d2862f148f901da66a'),
      ];

      checker.addContextRoot(
        firstContextRoot.root,
        firstContextRootPackages,
        firstPubspec,
      );
      checker.addContextRoot(
        secondContextRoot.root,
        secondContextRootPackages,
        secondPubspec,
      );

      expect(
        checker.throwErrorIfConflictingPackages,
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            equals(
              '''
Some dependencies with conflicting versions were identified:

app at /Users/user/project/app
- riverpod v2.2.0
- freezed v2.3.2

http at /Users/user/project/app/packages/http
- riverpod v2.1.0
- freezed from git url ssh://git@github.com/rrousselGit/freezed.git path packages/freezed

This is not supported. Custom_lint shares the analysis between all packages. As such, all plugins are started under a single process, sharing the dependencies of all the packages that use custom_lint. Since there's a single process for all plugins, if 2 plugins try to use different versions for a dependency, the process cannot be reasonably started. Please make sure all packages have the same version.
You could run the following commands to try fixing this:

cd /Users/user/project/app
dart pub upgrade riverpod freezed
cd /Users/user/project/app/packages/http
dart pub upgrade riverpod freezed
''',
            ),
          ),
        ),
      );
    });

    test('should show git dependency from dev dependencies', () {
      final checker = ConflictingPackagesChecker();
      final firstPubspec = Pubspec('app');
      final secondPubspec = Pubspec(
        'http',
        devDependencies: {
          'freezed': GitDependency(
            Uri.parse('ssh://git@github.com/rrousselGit/freezed.git'),
          ),
        },
      );
      final firstContextRoot = createContextRoot('app');
      final secondContextRoot = createContextRoot('app/packages/http');
      final firstContextRootPackages = [
        createPackage('riverpod', '2.2.0'),
        createPackage('freezed', '2.3.2'),
      ];
      final secondContextRootPackages = [
        createPackage('riverpod', '2.1.0'),
        createGitPackage('freezed', '4cdfbf9159f2e9746fce29d2862f148f901da66a'),
      ];

      checker.addContextRoot(
        firstContextRoot.root,
        firstContextRootPackages,
        firstPubspec,
      );
      checker.addContextRoot(
        secondContextRoot.root,
        secondContextRootPackages,
        secondPubspec,
      );

      expect(
        checker.throwErrorIfConflictingPackages,
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            equals(
              '''
Some dependencies with conflicting versions were identified:

app at /Users/user/project/app
- riverpod v2.2.0
- freezed v2.3.2

http at /Users/user/project/app/packages/http
- riverpod v2.1.0
- freezed from git url ssh://git@github.com/rrousselGit/freezed.git

This is not supported. Custom_lint shares the analysis between all packages. As such, all plugins are started under a single process, sharing the dependencies of all the packages that use custom_lint. Since there's a single process for all plugins, if 2 plugins try to use different versions for a dependency, the process cannot be reasonably started. Please make sure all packages have the same version.
You could run the following commands to try fixing this:

cd /Users/user/project/app
dart pub upgrade riverpod freezed
cd /Users/user/project/app/packages/http
dart pub upgrade riverpod freezed
''',
            ),
          ),
        ),
      );
    });
  });
}
