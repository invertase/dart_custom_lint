import 'dart:io' as io;
import 'dart:io';

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';
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

  // Extract the name of the changed file and makes the test failing if the internal structure is not the expected one
  String _extractFileName(PrioritizedSourceChange change) {
    final map = change.toJson();

    expect(map.containsKey('change'), true);
    final changes = map['change']! as Map;

    expect(changes.containsKey('edits'), true);
    final edits = changes['edits']! as List;

    expect(edits.length, 1);
    final edit = edits[0]! as Map;

    expect(edit.containsKey('file'), true);
    final fileName = edit['file'] as String;

    return fileName;
  }

  test('CustomAssist.testRun', () async {
    final assist1 = MyCustomAssist('CustomAssist', 'custom_1.txt');
    final assist2 = MyCustomAssist('AnotherCustom', 'custom_2.txt');

    final file = writeToTemporaryFile('''
void main() {
  print('Custom world');
}
''');
    final result = await resolveFile2(path: file.path);
    result as ResolvedUnitResult;

    final changeList1 = await assist1.testRun(result, SourceRange.EMPTY);
    final changeList2 = await assist2.testRun(result, SourceRange.EMPTY);

    final change1 = changeList1[0];
    final change2 = changeList2[0];

    final file1 = _extractFileName(change1);
    final file2 = _extractFileName(change2);

    expect(file1, 'custom_1.txt');
    expect(file2, 'custom_2.txt');
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
