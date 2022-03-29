import 'dart:convert';
import 'dart:io';

import 'package:package_config/package_config.dart';
import 'package:path/path.dart';
import 'package:test/scaffolding.dart';

import 'peer_project_meta.dart';

const _pluginDefaultPubspec = '<<<default>>>';

Directory createPlugin({
  required String name,
  String? pubpsec = _pluginDefaultPubspec,
  String? analysisOptions,
  String? main,
  Map<String, String>? sources,
}) {
  return createDartProject(
    sources: {
      ...?sources,
      if (main != null) 'lib/main.dart': main,
    },
    pubspec: pubpsec == _pluginDefaultPubspec
        ? '''
name: $name
version: 0.0.1
publish_to: none

environment:
  sdk: ">=2.16.0 <3.0.0"

dependencies:
  analyzer: any
  analyzer_plugin: any
  custom_lint_builder:
    path: ${PeerProjectMeta.current.customLintBuilderPath}
'''
        : pubpsec,
    analysisOptions: analysisOptions,
    packageConfig: pubpsec != _pluginDefaultPubspec
        ? null
        : createPackageConfig(customLintBuilder: true),
    name: name,
  );
}

Directory creatLintUsage({
  Map<String, Uri> plugins = const {},
  Map<String, String> source = const {},
  required String name,
}) {
  final pluginDevDependencies = plugins.entries.map((e) => '''
  ${e.key}:
    path: ${e.value}
''').join('\n');

  return createDartProject(
    sources: source,
    analysisOptions: '''
analyzer:
  plugins:
    - custom_lint

''',
    pubspec: '''
name: $name
version: 0.0.1
publish_to: none

environment:
  sdk: ">=2.16.0 <3.0.0"

dependencies:
  analyzer: any
  analyzer_plugin: any

dev_dependencies:
  custom_lint:
    path: ${PeerProjectMeta.current.customLintPath}
$pluginDevDependencies
''',
    packageConfig: createPackageConfig(
      plugins: plugins,
      customLintBuilder: false,
    ),
    name: name,
  );
}

String createPackageConfig({
  Map<String, Uri> plugins = const {},
  required bool customLintBuilder,
}) {
  return jsonEncode({
    ...PeerProjectMeta.current.exampleLintPackageConfig,
    'packages': <Object?>[
      ...(PeerProjectMeta.current.exampleLintPackageConfig['packages']!
              as List<Object?>)
          .cast<Map>()
          .where(
            (e) =>
                e['name'] != 'custom_lint' &&
                e['name'] != 'custom_lint_builder',
          ),
      for (final plugin in plugins.entries)
        {
          'name': plugin.key,
          'rootUri': plugin.value.toFilePath(),
          'packageUri': 'lib/',
          'languageVersion': '2.16'
        },
      <String, String>{
        'name': 'custom_lint',
        'rootUri': PeerProjectMeta.current.customLintPath,
        'packageUri': 'lib/',
        'languageVersion': '2.16'
      },
      if (customLintBuilder)
        <String, String>{
          'name': 'custom_lint_builder',
          'rootUri': PeerProjectMeta.current.customLintBuilderPath,
          'packageUri': 'lib/',
          'languageVersion': '2.16'
        },
    ],
  });
}

Directory createDartProject({
  String? analysisOptions,
  String? pubspec,
  String? packageConfig,
  Map<String, String>? sources,
  required String name,
}) {
  // TODO import .dart_tool/package_config.json by default for speed, avoiding unnecessary pub get

  return createTmpFolder(
    {
      ...?sources,
      if (analysisOptions != null) 'analysis_options.yaml': analysisOptions,
      if (pubspec != null) 'pubspec.yaml': pubspec,
      if (packageConfig != null)
        '.dart_tool/package_config.json': packageConfig,
    },
    name,
  );
}

Directory createTmpFolder(Map<String, String> files, String name) {
  final newFolder = Directory.systemTemp.createTempSync(name);
  addTearDown(() => newFolder.deleteSync(recursive: true));

  for (final fileEntry in files.entries) {
    assert(isRelative(fileEntry.key), 'Only relative file paths are supported');

    final file = File(join(newFolder.path, fileEntry.key));
    file.createSync(recursive: true);
    addTearDown(file.deleteSync);
    file.writeAsStringSync(fileEntry.value);
  }

  return newFolder;
}
