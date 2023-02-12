import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';
import 'package:test/scaffolding.dart';

import 'peer_project_meta.dart';

const _pluginDefaultPubspec = '<<<default>>>';

const emptyPluginSource = '''
import 'package:analyzer/dart/element/element.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:analyzer/dart/analysis/results.dart';

PluginBase createPlugin() => _Plugin();

class _Plugin extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [];
}
''';

class TestLintRule {
  TestLintRule({
    required this.code,
    required this.message,
    this.onRun = '',
    this.onVariable = '',
  });

  final String code;
  final String message;
  final String onRun;
  final String onVariable;
}

String createPluginSource(List<TestLintRule> rules) {
  final buffer = StringBuffer('''
import 'package:analyzer/dart/element/element.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/error/listener.dart';

PluginBase createPlugin() => _Plugin();

class _Plugin extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
''');

  buffer.writeAll(rules.map((e) => '${e.code}()'), ',');

  buffer.write(']; }');

  for (final rule in rules) {
    buffer.write(
      '''
class ${rule.code} extends DartLintRule {
  ${rule.code}()
    : super(
        code: LintCode(name: '${rule.code}', problemMessage: '${rule.message}'),
      );

  @override
  void run(CustomLintResolver resolver, ErrorReporter reporter, CustomLintContext context) {
    ${rule.onRun}
    context.registry.addFunctionDeclaration((node) {
      ${rule.onVariable}
      reporter.reportErrorForToken(code, node.name);
    });
  }
}
''',
    );
  }

  return buffer.toString();
}

Directory createPlugin({
  required String name,
  String? pubpsec = _pluginDefaultPubspec,
  String? analysisOptions,
  String? main,
  Map<String, String>? sources,
  bool omitPackageConfig = false,
}) {
  return createDartProject(
    sources: {
      ...?sources,
      if (main != null) join('lib', '$name.dart'): main,
    },
    pubspec: pubpsec == _pluginDefaultPubspec
        ? '''
name: $name
version: 0.0.1
publish_to: none

environment:
  sdk: ">=2.17.0 <3.0.0"

dependencies:
  analyzer: any
  analyzer_plugin: any
  custom_lint_builder:
    path: ${PeerProjectMeta.current.customLintBuilderPath}
'''
        : pubpsec,
    analysisOptions: analysisOptions,
    packageConfig: omitPackageConfig || pubpsec != _pluginDefaultPubspec
        ? null
        : createPackageConfig(name: name),
    name: name,
  );
}

Directory createLintUsage({
  Map<String, Uri> plugins = const {},
  Map<String, String> source = const {},
  required String name,
}) {
  final pluginDevDependencies = plugins.entries
      .map(
        (e) => '''
  ${e.key}:
    path: ${e.value}
''',
      )
      .join('\n');

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
  sdk: ">=2.17.0 <3.0.0"

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
      name: name,
    ),
    name: name,
  );
}

String createPackageConfig({
  Map<String, Uri> plugins = const {},
  required String name,
}) {
  return jsonEncode({
    ...PeerProjectMeta.current.exampleLintPackageConfig,
    'packages': <Object?>[
      ...(PeerProjectMeta.current.exampleLintPackageConfig['packages']!
              as List<Object?>)
          .cast<Map<Object?, Object?>>()
          .where(
            (e) =>
                e['name'] != 'custom_lint' &&
                e['name'] != 'custom_lint_example_lint' &&
                e['name'] != 'custom_lint_core' &&
                e['name'] != 'custom_lint_builder',
          ),
      for (final plugin in plugins.entries)
        {
          'name': plugin.key,
          'rootUri': plugin.value.toFilePath(),
          'packageUri': 'lib/',
          'languageVersion': '2.17'
        },
      <String, String>{
        'name': name,
        'rootUri': '../',
        'packageUri': 'lib/',
        'languageVersion': '2.17'
      },
      <String, String>{
        'name': 'custom_lint',
        'rootUri': PeerProjectMeta.current.customLintPath,
        'packageUri': 'lib/',
        'languageVersion': '2.17'
      },
      // Custom lint builder is always a transitive dev dependency if it is used,
      // so it will be in the package config
      <String, String>{
        'name': 'custom_lint_builder',
        'rootUri': PeerProjectMeta.current.customLintBuilderPath,
        'packageUri': 'lib/',
        'languageVersion': '2.17'
      },
      // Custom lint core is always a transitive dev dependency if it is used,
      // so it will be in the package config
      <String, String>{
        'name': 'custom_lint_core',
        'rootUri': PeerProjectMeta.current.customLintCorePath,
        'packageUri': 'lib/',
        'languageVersion': '2.17'
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
