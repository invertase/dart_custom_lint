import 'dart:io' as io;

import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:custom_lint_core/custom_lint_core.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

io.Directory createDir() {
  final tempDir = io.Directory.systemTemp.createTempSync();
  addTearDown(() => tempDir.delete(recursive: true));
  return tempDir;
}

File createAnalysisOptions(String content) {
  final dir = createDir();
  final ioFile = io.File(join(dir.path, 'analysis_options.yaml'));
  ioFile.writeAsStringSync(content);
  return PhysicalResourceProvider.INSTANCE.getFile(ioFile.path);
}

void main() {
  late File includeFile;
  late CustomLintConfigs includeConfig;
  const testConfigUri = 'package:include_test_package/analysis_options.yaml';
  setUp(() async {
    includeFile = createAnalysisOptions(
      '''
custom_lint:
  rules:
  - a
  - b: false
  - c:
    foo: 42
  - d
''',
    );

    includeConfig = await CustomLintConfigs.parse(includeFile);
  });

  test('Empty config', () {
    expect(CustomLintConfigs.empty.enableAllLintRules, null);
    expect(CustomLintConfigs.empty.rules, isEmpty);
  });

  group('parse', () {
    test('if file is null, defaults to empty', () async {
      final configs = await CustomLintConfigs.parse(null);
      expect(configs, same(CustomLintConfigs.empty));
    });

    test('if file does not exist, defaults to empty ', () async {
      final configs = await CustomLintConfigs.parse(
        PhysicalResourceProvider.INSTANCE.getFile('/this-does-no-exist'),
      );
      expect(configs, same(CustomLintConfigs.empty));
    });

    test('if custom_lint not present in the option file, clones "include"',
        () async {
      final analysisOptions = createAnalysisOptions('''
include: ${includeFile.path}
linter:
  rules:
    public_member_api_docs: false
''');
      final configs = await CustomLintConfigs.parse(analysisOptions);

      expect(configs, includeConfig);
    });

    test('if custom_lint not present in the option file, clones "include"',
        () async {
      final analysisOptions = createAnalysisOptions('''
include: ${includeFile.path}
linter:
  rules:
    public_member_api_docs: false
''');
      final configs = await CustomLintConfigs.parse(analysisOptions);

      expect(configs, includeConfig);
    });

    test('if custom_lint is present but empty, clones "include"', () async {
      final analysisOptions = createAnalysisOptions('''
include: ${includeFile.path}
linter:
  rules:
    public_member_api_docs: false

custom_lint:
''');
      final configs = await CustomLintConfigs.parse(analysisOptions);

      expect(configs, includeConfig);
    });

    test('has an immutable list of rules', () async {
      final analysisOptions = createAnalysisOptions('''
custom_lint:
  rules: 
  - a
''');
      final configs = await CustomLintConfigs.parse(analysisOptions);

      expect(
        configs.rules,
        {'a': const LintOptions.empty(enabled: true)},
      );

      expect(
        () => configs.rules['b'] = const LintOptions.empty(enabled: true),
        throwsUnsupportedError,
      );
    });

    test(
        'if custom_lint is present and defines some properties, merges with "include"',
        () async {
      final analysisOptions = createAnalysisOptions('''
include: ${includeFile.path}
linter:
  rules:
    public_member_api_docs: false

custom_lint:
  enable_all_lint_rules: false
''');
      final configs = await CustomLintConfigs.parse(analysisOptions);

      expect(configs.enableAllLintRules, false);
      expect(configs.rules, includeConfig.rules);
    });

    test(
        'if custom_lint.enable_all_lint_rules is not present, uses value from "include"',
        () async {
      final included = createAnalysisOptions('''
custom_lint:
  enable_all_lint_rules: false
''');
      final analysisOptions = createAnalysisOptions('''
include: ${included.path}
custom_lint:
  rules:
  - a
''');
      final configs = await CustomLintConfigs.parse(analysisOptions);

      expect(configs.enableAllLintRules, false);
      expect(configs.rules, {
        'a': const LintOptions.empty(enabled: true),
      });
    });

    test('include config using "package:" uri', () async {
      final file = createAnalysisOptions('''
include: $testConfigUri
      ''');
      final configs = await CustomLintConfigs.parse(file);

      expect(configs.rules.containsKey('from_package'), true);
    });

    test('if custom_lint.rules is present, merges with "include"', () async {
      final analysisOptions = createAnalysisOptions('''
include: ${includeFile.path}
linter:
  rules:
    public_member_api_docs: false

custom_lint:
  enable_all_lint_rules: true
  rules:
  - a2
  - b2: false
  - c2:
    foo: 21
  - d
''');
      final configs = await CustomLintConfigs.parse(analysisOptions);

      expect(configs.enableAllLintRules, true);
      expect(configs.rules, {
        'a': const LintOptions.empty(enabled: true),
        'b': const LintOptions.empty(enabled: false),
        'c': const LintOptions.fromYaml({'foo': 42}, enabled: true),
        'a2': const LintOptions.empty(enabled: true),
        'b2': const LintOptions.empty(enabled: false),
        'c2': const LintOptions.fromYaml({'foo': 21}, enabled: true),
        'd': const LintOptions.empty(enabled: true),
      });
    });

    group('Handles errors', () {
      test('Defaults to empty if yaml fails to parse', () async {
        final configs = await CustomLintConfigs.parse(
          createAnalysisOptions('''
foo:
    bar:
  baz:
'''),
        );
        expect(configs, CustomLintConfigs.empty);
      });
    });
  });
}
