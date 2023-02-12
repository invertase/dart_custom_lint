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
  setUp(() {
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

    includeConfig = CustomLintConfigs.parse(includeFile);
  });

  test('Empty config', () {
    expect(CustomLintConfigs.empty.enableAllLintRules, null);
    expect(CustomLintConfigs.empty.rules, isEmpty);
  });

  group('parse', () {
    test('if file is null, defaults to empty', () {
      final configs = CustomLintConfigs.parse(null);
      expect(configs, same(CustomLintConfigs.empty));
    });

    test('if file does not exist, defaults to empty ', () {
      final configs = CustomLintConfigs.parse(
        PhysicalResourceProvider.INSTANCE.getFile('/this-does-no-exist'),
      );
      expect(configs, same(CustomLintConfigs.empty));
    });

    test('if custom_lint not present in the option file, clones "include"', () {
      final analysisOptions = createAnalysisOptions('''
include: ${includeFile.path}
linter:
  rules:
    public_member_api_docs: false
''');
      final configs = CustomLintConfigs.parse(analysisOptions);

      expect(configs, includeConfig);
    });

    test('if custom_lint not present in the option file, clones "include"', () {
      final analysisOptions = createAnalysisOptions('''
include: ${includeFile.path}
linter:
  rules:
    public_member_api_docs: false
''');
      final configs = CustomLintConfigs.parse(analysisOptions);

      expect(configs, includeConfig);
    });

    test('if custom_lint is present but empty, clones "include"', () {
      final analysisOptions = createAnalysisOptions('''
include: ${includeFile.path}
linter:
  rules:
    public_member_api_docs: false

custom_lint:
''');
      final configs = CustomLintConfigs.parse(analysisOptions);

      expect(configs, includeConfig);
    });

    test('has an immutable list of rules', () {
      final analysisOptions = createAnalysisOptions('''
custom_lint:
  rules: 
  - a
''');
      final configs = CustomLintConfigs.parse(analysisOptions);

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
        () {
      final analysisOptions = createAnalysisOptions('''
include: ${includeFile.path}
linter:
  rules:
    public_member_api_docs: false

custom_lint:
  enable_all_lint_rules: false
''');
      final configs = CustomLintConfigs.parse(analysisOptions);

      expect(configs.enableAllLintRules, false);
      expect(configs.rules, includeConfig.rules);
    });

    test(
        'if custom_lint.enable_all_lint_rules is not present, uses value from "include"',
        () {
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
      final configs = CustomLintConfigs.parse(analysisOptions);

      expect(configs.enableAllLintRules, false);
      expect(configs.rules, {
        'a': const LintOptions.empty(enabled: true),
      });
    });

    test('if custom_lint.rules is present, merges with "include"', () {
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
      final configs = CustomLintConfigs.parse(analysisOptions);

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
      test('Defaults to empty if yaml fails to parse', () {
        final configs = CustomLintConfigs.parse(
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
