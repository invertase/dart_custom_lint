import 'dart:io';

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/error/listener.dart';
// ignore: implementation_imports
import 'package:custom_lint/src/package_utils.dart' show parsePackageConfig;
import 'package:custom_lint_core/custom_lint_core.dart';

import 'package:test/test.dart';

import 'assist_test.dart';
import 'configs_test.dart';

class TestLintRule extends LintRule {
  const TestLintRule({required this.enabledByDefault})
      : super(
          code: const LintCode(
            name: 'test_lint',
            problemMessage: 'Test lint',
          ),
        );

  @override
  List<String> get filesToAnalyze => ['*'];

  @override
  final bool enabledByDefault;

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {}
}

class MyLintRule extends DartLintRule {
  const MyLintRule()
      : super(
          code: const LintCode(
            name: 'my_lint_code',
            problemMessage: 'message',
          ),
        );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addMethodInvocation((node) {
      reporter.reportErrorForNode(code, node.methodName);
    });
  }
}

void main() async {
  const onByDefault = TestLintRule(enabledByDefault: true);
  const offByDefault = TestLintRule(enabledByDefault: false);
  final packageConfig = await parsePackageConfig(Directory.current);

  test('LintRule.testRun', () async {
    const assist = MyLintRule();

    final file = writeToTemporaryFile('''
void main() {
  print('Hello world');
}
''');
    final result = await resolveFile2(path: file.path);
    result as ResolvedUnitResult;

    final analysisErrors = await assist.testRun(result);

    expect(analysisErrors, hasLength(1));

    expect(analysisErrors.first.errorCode.name, 'my_lint_code');
    expect(analysisErrors.first.message, 'message');
    expect(analysisErrors.first.offset, 16);
    expect(analysisErrors.first.length, 'print'.length);
  });

  test('LintRule.testAnalyzeAndRun', () async {
    const assist = MyLintRule();

    final file = writeToTemporaryFile('''
void main() {
  print('Hello world');
}
''');

    final analysisErrors = await assist.testAnalyzeAndRun(file);

    expect(analysisErrors, hasLength(1));

    expect(analysisErrors.first.errorCode.name, 'my_lint_code');
    expect(analysisErrors.first.message, 'message');
    expect(analysisErrors.first.offset, 16);
    expect(analysisErrors.first.length, 'print'.length);
  });

  group('LintRule.isEnabled', () {
    test('defaults to checking "enabedByDefault"', () {
      expect(onByDefault.isEnabled(CustomLintConfigs.empty), true);
      expect(offByDefault.isEnabled(CustomLintConfigs.empty), false);
    });

    test('always enabled if on in the config files', () {
      final analysisOptionFile = createAnalysisOptions('''
custom_lint:
  rules:
  - test_lint
''');
      final configs =
          CustomLintConfigs.parse(analysisOptionFile, packageConfig);

      expect(onByDefault.isEnabled(configs), true);
      expect(offByDefault.isEnabled(configs), true);
    });

    test('always disabled if off in the config files', () {
      final analysisOptionFile = createAnalysisOptions('''
custom_lint:
  rules:
  - test_lint: false
''');
      final configs =
          CustomLintConfigs.parse(analysisOptionFile, packageConfig);

      expect(onByDefault.isEnabled(configs), false);
      expect(offByDefault.isEnabled(configs), false);
    });
  });
}
