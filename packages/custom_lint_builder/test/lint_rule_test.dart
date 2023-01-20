import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:test/test.dart';

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

void main() {
  const onByDefault = TestLintRule(enabledByDefault: true);
  const offByDefault = TestLintRule(enabledByDefault: false);

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
      final configs = CustomLintConfigs.parse(analysisOptionFile);

      expect(onByDefault.isEnabled(configs), true);
      expect(offByDefault.isEnabled(configs), true);
    });

    test('always disabled if off in the config files', () {
      final analysisOptionFile = createAnalysisOptions('''
custom_lint:
  rules:
  - test_lint: false
''');
      final configs = CustomLintConfigs.parse(analysisOptionFile);

      expect(onByDefault.isEnabled(configs), false);
      expect(offByDefault.isEnabled(configs), false);
    });
  });
}
