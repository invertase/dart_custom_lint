import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/error/error.dart'
    hide
        // ignore: undefined_hidden_name, Needed to support lower analyzer versions
        LintCode;
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

    const fileSource = '''
void main() {
  print('Hello world');
}
''';
    final file = writeToTemporaryFile(fileSource);
    final result = await resolveFile(path: file.path);
    result as ResolvedUnitResult;

    final errors = await const MyLintRule().testRun(result);

    final changes = fix.testRun(result, errors.single, errors);
    final changes2 = fix2.testRun(result, errors.single, errors);

    expect(
      await changes,
      matcherNormalizedPrioritizedSourceChangeSnapshot(
        'snapshot.diff',
        sources: {'**/*': fileSource},
        relativePath: file.parent.path,
      ),
    );
    expect(
      await changes,
      isNot(
        matcherNormalizedPrioritizedSourceChangeSnapshot(
          'snapshot2.diff',
          sources: {'**/*': fileSource},
          relativePath: file.parent.path,
        ),
      ),
    );

    expect(
      await changes2,
      isNot(
        matcherNormalizedPrioritizedSourceChangeSnapshot(
          'snapshot.diff',
          sources: {'**/*': fileSource},
          relativePath: file.parent.path,
        ),
      ),
    );
    expect(
      await changes2,
      matcherNormalizedPrioritizedSourceChangeSnapshot(
        'snapshot2.diff',
        sources: {'**/*': fileSource},
        relativePath: file.parent.path,
      ),
    );
  });

  test('Fix.testAnalyzeRun', () async {
    final fix = MyFix('MyAssist');

    const fileSource = '''
void main() {
  print('Hello world');
}
''';
    final file = writeToTemporaryFile(fileSource);
    final errors = await const MyLintRule().testAnalyzeAndRun(file);

    final changes = fix.testAnalyzeAndRun(file, errors.single, errors);

    expect(
      await changes,
      matcherNormalizedPrioritizedSourceChangeSnapshot(
        'snapshot.diff',
        sources: {'**/*': fileSource},
        relativePath: file.parent.path,
      ),
    );
    expect(
      await changes,
      isNot(
        matcherNormalizedPrioritizedSourceChangeSnapshot(
          'snapshot2.diff',
          sources: {'**/*': fileSource},
          relativePath: file.parent.path,
        ),
      ),
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
      final changeBuilder = reporter.createChangeBuilder(
        message: name,
        priority: 1,
      );

      changeBuilder.addGenericFileEdit((builder) {
        builder.addSimpleInsertion(node.offset, 'Hello');
      });
    });
  }
}
