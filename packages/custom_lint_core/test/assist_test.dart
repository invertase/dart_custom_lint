import 'dart:convert';
import 'dart:io' as io;
import 'dart:io';

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:custom_lint_core/src/assist.dart';
import 'package:custom_lint_core/src/change_reporter.dart';
import 'package:custom_lint_core/src/lint_rule.dart';
import 'package:custom_lint_core/src/matcher.dart';
import 'package:custom_lint_core/src/resolver.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

File writeToTemporaryFile(String content) {
  final tempDir = io.Directory.systemTemp.createTempSync();
  addTearDown(() => tempDir.deleteSync(recursive: true));

  final file = io.File(join(tempDir.path, 'file.dart'))
    ..createSync(recursive: true)
    ..writeAsStringSync(content);

  return file;
}

Future<List<String>> readFile(String path) async {
  final file = io.File(path);
  return file.readAsLines();
}

void main() {
  test('Assist.testRun', () async {
    final assist = MyAssist('MyAssist');
    final assist2 = MyAssist('Another');

    final file = writeToTemporaryFile('''
void main() {
  print('Hello world');
}
''');
    final result = await resolveFile2(path: file.path);
    result as ResolvedUnitResult;

    final changes = assist.testRun(result, SourceRange.EMPTY);
    final changes2 = assist2.testRun(result, SourceRange.EMPTY);

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

  test('CustomAssist.testRun', () async {
    final assist = MyCustomAssist('CustomAssist', 'custom_1.txt');
    final assist2 = MyCustomAssist('AnotherCustom', 'custom_2.txt');

    final file = writeToTemporaryFile('''
void main() {
  print('Custom world');
}
''');
    final result = await resolveFile2(path: file.path);
    result as ResolvedUnitResult;

    final changes1 = assist.testRun(result, SourceRange.EMPTY);
    final changes2 = assist2.testRun(result, SourceRange.EMPTY);

    final list1 = await changes1;
    expect(
      list1,
      matcherNormalizedPrioritizedSourceChangeSnapshot('custom.json'),
    );

    expect(jsonEncode(list1[0]).contains('custom_1.txt'), true);
    expect(jsonEncode(list1[0]).contains('custom_2.txt'), false);

    final list2 = await changes2;
    expect(
      list2,
      matcherNormalizedPrioritizedSourceChangeSnapshot('custom2.json'),
    );

    expect(jsonEncode(list2[0]).contains('custom_1.txt'), false);
    expect(jsonEncode(list2[0]).contains('custom_2.txt'), true);
  });

  test('Assist.testAnalyzeAndRun', () async {
    final assist = MyAssist('MyAssist');
    final assist2 = MyAssist('Another');

    final file = writeToTemporaryFile('''
void main() {
  print('Hello world');
}
''');

    final changes = assist.testAnalyzeAndRun(file, SourceRange.EMPTY);
    final changes2 = assist2.testAnalyzeAndRun(file, SourceRange.EMPTY);

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
}

class MyAssist extends DartAssist {
  MyAssist(this.name);

  final String name;

  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    SourceRange target,
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

class MyCustomAssist extends DartAssist {
  MyCustomAssist(this.name, this.customPath);

  final String name;
  final String customPath;

  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    SourceRange target,
  ) {
    context.registry.addMethodInvocation((node) {
      final changebuilder = reporter.createChangeBuilder(
        message: name,
        priority: 1,
      );

      changebuilder.addGenericFileEdit(
        (builder) {
          builder.addSimpleInsertion(node.offset, 'Custom 2023');
        },
        customPath: customPath,
      );
    });
  }
}
