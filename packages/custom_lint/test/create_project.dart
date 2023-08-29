import 'dart:convert';
import 'dart:io';

import 'package:analyzer/error/error.dart';
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
    this.startUp = '',
    this.onRun = '',
    this.onVariable = '',
    this.ruleMembers = '',
    this.fixes = const [],
    this.errorSeverity = ErrorSeverity.INFO,
  });

  final String code;
  final String message;
  final String startUp;
  final String onRun;
  final String onVariable;
  final String ruleMembers;
  final List<TestLintFix> fixes;
  final ErrorSeverity errorSeverity;
}

class TestLintFix {
  TestLintFix({required this.name});

  final String name;
}

String createPluginSource(List<TestLintRule> rules) {
  final buffer = StringBuffer('''
import 'package:analyzer/dart/element/element.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer/error/error.dart';

PluginBase createPlugin() => _Plugin();

class _Plugin extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
''');

  buffer.writeAll(rules.map((e) => '${e.code}()'), ',');

  buffer.write(']; }');

  for (final rule in rules) {
    final fixes = rule.fixes.isEmpty
        ? ''
        : '''
@override
List<Fix> getFixes() => [${rule.fixes.map((e) => '${e.name}()').join(',')}];
''';

    for (final fix in rule.fixes) {
      buffer.write('''
class ${fix.name} extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addVariableDeclarationList((node) {
      if (!analysisError.sourceRange.intersects(node.sourceRange)) return;

      final changeBuilder = reporter.createChangeBuilder(
        priority: 1,
        message: 'Fix ${rule.code}',
      );
      changeBuilder.addDartFileEdit((builder) {});
    });
  }
}
''');
    }

    buffer.write('''
class ${rule.code} extends DartLintRule {
  ${rule.code}()
    : super(
        code: LintCode(name: '${rule.code}',
        problemMessage: '${rule.message}',
        errorSeverity: ErrorSeverity.${rule.errorSeverity.displayName.toUpperCase()}),
      );

$fixes
${rule.ruleMembers}
''');

    if (rule.startUp.isNotEmpty) {
      buffer.write('''
  @override
  Future<void> startUp(
    CustomLintResolver resolver,
    CustomLintContext context,
  ) async {
    ${rule.startUp}
  }
''');
    }

    buffer.write(
      '''
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
  Directory? parent,
  String pubpsec = _pluginDefaultPubspec,
  String? analysisOptions,
  String? main,
  Map<String, String>? sources,
  bool omitPackageConfig = false,
  Map<String, String> extraDependencies = const {},
}) {
  assert(
    pubpsec == _pluginDefaultPubspec || extraDependencies.isEmpty,
    'Cannot specify both pubpsec and extraDependencies',
  );

  return createDartProject(
    parent: parent,
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
  sdk: ">=2.17.0 <4.0.0"

dependencies:
  analyzer: any
  analyzer_plugin: any
  custom_lint_builder:
    path: ${PeerProjectMeta.current.customLintBuilderPath}
${extraDependencies.entries.map((e) => '  ${e.key}: ${e.value}').join('\n')}
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
  Directory? parent,
  Map<String, Uri> plugins = const {},
  Map<String, String> source = const {},
  Map<String, Uri> extraPackageConfig = const {},
  required String name,
}) {
  final pluginDevDependencies = plugins.entries
      .map(
        (e) => '''
  ${e.key}:
    path: ${e.value.toFilePath()}
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
  sdk: ">=2.17.0 <4.0.0"

dependencies:
  analyzer: any
  analyzer_plugin: any

dev_dependencies:
  custom_lint:
    path: ${PeerProjectMeta.current.customLintPath}
$pluginDevDependencies
''',
    packageConfig: createPackageConfig(
      plugins: {...plugins, ...extraPackageConfig},
      name: name,
    ),
    name: name,
    parent: parent,
  );
}

String createPackageConfig({
  Map<String, Uri> plugins = const {},
  required String name,
}) {
  return const JsonEncoder.withIndent('  ').convert({
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
          'rootUri': plugin.value.toString(),
          'packageUri': 'lib/',
          'languageVersion': '2.17',
        },
      <String, String>{
        'name': name,
        'rootUri': '../',
        'packageUri': 'lib/',
        'languageVersion': '2.17',
      },
      <String, String>{
        'name': 'custom_lint',
        'rootUri': 'file://${PeerProjectMeta.current.customLintPath}',
        'packageUri': 'lib/',
        'languageVersion': '2.17',
      },
      // Custom lint builder is always a transitive dev dependency if it is used,
      // so it will be in the package config
      <String, String>{
        'name': 'custom_lint_builder',
        'rootUri': 'file://${PeerProjectMeta.current.customLintBuilderPath}',
        'packageUri': 'lib/',
        'languageVersion': '2.17',
      },
      // Custom lint core is always a transitive dev dependency if it is used,
      // so it will be in the package config
      <String, String>{
        'name': 'custom_lint_core',
        'rootUri': 'file://${PeerProjectMeta.current.customLintCorePath}',
        'packageUri': 'lib/',
        'languageVersion': '2.17',
      },
    ],
  });
}

Directory createDartProject({
  Directory? parent,
  String? analysisOptions,
  String? pubspec,
  String? packageConfig,
  Map<String, String>? sources,
  required String name,
}) {
  // TODO import .dart_tool/package_config.json by default for speed, avoiding unnecessary pub get

  return createTmpFolder(
    parent: parent,
    {
      ...?sources,
      if (analysisOptions != null) 'analysis_options.yaml': analysisOptions,
      if (pubspec != null) 'pubspec.yaml': pubspec,
      if (packageConfig != null)
        join('.dart_tool', 'package_config.json'): packageConfig,
    },
    name,
  );
}

/// Creates a temporary folder with the given [files] and [name].
///
/// The folder will be automatically deleted after the pending test ends.
Directory createTmpFolder(
  Map<String, String> files,
  String name, {
  Directory? parent,
}) {
  late Directory newFolder;
  if (parent == null) {
    newFolder = Directory.systemTemp.createTempSync(name);
  } else {
    newFolder = Directory(join(parent.path, name))..createSync();
  }
  addTearDown(() => newFolder.deleteSync(recursive: true));

  for (final fileEntry in files.entries) {
    assert(isRelative(fileEntry.key), 'Only relative file paths are supported');

    final file = File(join(newFolder.path, fileEntry.key));
    file.createSync(recursive: true);
    file.writeAsStringSync(fileEntry.value);
  }

  return newFolder;
}
