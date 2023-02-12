import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/error/error.dart';
import 'package:custom_lint_core/src/change_reporter.dart';
import 'package:custom_lint_core/src/fixes.dart';
import 'package:custom_lint_core/src/lint_rule.dart';
import 'package:custom_lint_core/src/matcher.dart';
import 'package:custom_lint_core/src/resolver.dart';
import 'package:test/test.dart';

import 'assist_test.dart';
import 'lint_rule_test.dart';

void main() {
  test('Fix.testRun', () async {
    final fix = MyFix('MyAssist');
    final fix2 = MyFix('Another');

    final file = writeToTemporaryFile('''
void main() {
  print('Hello world');
}
''');
    final result = await resolveFile2(path: file.path);
    result as ResolvedUnitResult;

    final errors = await const MyLintRule().testRun(result);

    final changes = fix.testRun(result, errors.single, errors);
    final changes2 = fix2.testRun(result, errors.single, errors);

    expect(
      await changes,
      matcherNormalizedPrioritizedSourceChangeSnapshot('snapshot.json'),
    );
    expect(
      await changes,
      isNot(matcherNormalizedPrioritizedSourceChangeSnapshot('snapshot2.json')),
    );

    expect(
      await changes2,
      isNot(matcherNormalizedPrioritizedSourceChangeSnapshot('snapshot.json')),
    );
    expect(
      await changes2,
      matcherNormalizedPrioritizedSourceChangeSnapshot('snapshot2.json'),
    );
  });

  test('Fix.testAnalyzeRun', () async {
    final fix = MyFix('MyAssist');

    final file = writeToTemporaryFile('''
void main() {
  print('Hello world');
}
''');
    final errors = await const MyLintRule().testAnalyzeAndRun(file);

    final changes = fix.testAnalyzeAndRun(file, errors.single, errors);

    expect(
      await changes,
      matcherNormalizedPrioritizedSourceChangeSnapshot('snapshot.json'),
    );
    expect(
      await changes,
      isNot(matcherNormalizedPrioritizedSourceChangeSnapshot('snapshot2.json')),
    );
  });
}

class MyFix extends DartFix {
  MyFix(this.name);

  final String name;

  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addMethodInvocation((node) {
      final changebuilder = reporter.createChangeBuilder(
        message: name,
        priority: 1,
      );

      changebuilder.addGenericFileEdit((builder) {
        builder.addSimpleInsertion(node.offset, 'Hello');
      });
    });
  }
}
