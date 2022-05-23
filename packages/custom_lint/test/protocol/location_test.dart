import 'dart:io';

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:custom_lint/src/protocol/public_protocol.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

import '../matchers.dart';

TypeMatcher<LintLocation> isSourceChange({
  int? offset,
  int? length,
  int? startLine,
  int? startColumn,
  int? endLine,
  int? endColumn,
}) {
  var matcher = isA<LintLocation>();
  if (offset != null) {
    matcher = matcher.having((e) => e.offset, 'offset', offset);
  }
  if (length != null) {
    matcher = matcher.having((e) => e.length, 'length', length);
  }

  if (startLine != null) {
    matcher = matcher.having(
      (e) => e.startLine,
      'startLine',
      startLine,
    );
  }
  if (endLine != null) {
    matcher = matcher.having(
      (e) => e.endLine,
      'endLine',
      endLine,
    );
  }

  if (startColumn != null) {
    matcher = matcher.having(
      (e) => e.startColumn,
      'startColumn',
      startColumn,
    );
  }
  if (endColumn != null) {
    matcher = matcher.having(
      (e) => e.endColumn,
      'endColumn',
      endColumn,
    );
  }

  return matcher;
}

void main() {
  group('LintSourceLocation', () {
    test('asserts valid values', () {
      LintLocation(
        startLine: 1,
        startColumn: 1,
        endLine: 1,
        endColumn: 2,
        filePath: '/foo',
        offset: 0,
        length: 1,
      );
      LintLocation(
        startLine: 1,
        startColumn: 1,
        endLine: 2,
        endColumn: 1,
        filePath: '/foo',
        offset: 0,
        length: 1,
      );

      expect(
        () => LintLocation(
          startLine: 0,
          startColumn: 1,
          endLine: 2,
          endColumn: 1,
          filePath: '/foo',
          offset: 0,
          length: 1,
        ),
        throwsAssertionError,
      );
      expect(
        () => LintLocation(
          startLine: 1,
          startColumn: 0,
          endLine: 2,
          endColumn: 1,
          filePath: '/foo',
          offset: 0,
          length: 1,
        ),
        throwsAssertionError,
      );
      expect(
        () => LintLocation(
          startLine: 1,
          startColumn: 1,
          endLine: 1,
          endColumn: 1,
          filePath: '/foo',
          offset: 0,
          length: 1,
        ),
        throwsAssertionError,
      );
      expect(
        () => LintLocation(
          startLine: 1,
          startColumn: 1,
          endLine: 0,
          endColumn: 2,
          filePath: '/foo',
          offset: 0,
          length: 1,
        ),
        throwsAssertionError,
      );
      expect(
        () => LintLocation(
          startLine: 1,
          startColumn: 1,
          endLine: 2,
          endColumn: 1,
          filePath: '/foo',
          offset: -1,
          length: 1,
        ),
        throwsAssertionError,
      );
      expect(
        () => LintLocation(
          startLine: 1,
          startColumn: 1,
          endLine: 2,
          endColumn: 1,
          filePath: '/foo',
          offset: 0,
          length: 0,
        ),
        throwsAssertionError,
      );
    });

    test('fromLines', () async {
      final file = await resolveString('''
int a = 0;
int b = 42;
int c = 21;
''');

      expect(
        file.lintLocationFromLines(
          startLine: 1,
          endLine: 2,
        ),
        isSourceChange(
          offset: 0,
          length: 11,
          startLine: 1,
          endLine: 2,
          startColumn: 1,
          endColumn: 1,
        ),
      );
      expect(
        file.lintLocationFromLines(
          startLine: 2,
          endLine: 3,
          startColumn: 5,
          endColumn: 6,
        ),
        isSourceChange(
          offset: 15,
          length: 13,
          startLine: 2,
          endLine: 3,
          startColumn: 5,
          endColumn: 6,
        ),
      );
    });

    test('fromOffset', () async {
      final file = await resolveString('''
int a = 0;
int b = 42;
''');

      expect(
        file.lintLocationFromOffset(4, length: 1),
        isSourceChange(
          offset: 4,
          length: 1,
          startLine: 1,
          endLine: 1,
          startColumn: 5,
          endColumn: 6,
        ),
      );
      expect(
        file.lintLocationFromOffset(4, length: 12),
        isSourceChange(
          offset: 4,
          length: 12,
          startLine: 1,
          endLine: 2,
          startColumn: 5,
          endColumn: 6,
        ),
      );
    });
  });
}

Future<ResolvedUnitResult> resolveString(String content) {
  final dir = Directory.systemTemp.createTempSync();
  dir.createSync(recursive: true);
  addTearDown(() => dir.deleteSync(recursive: true));

  final file = File(join(dir.path, 'file.dart'));
  file.writeAsStringSync(content);

  return resolveFile2(path: file.path)
      .then((value) => value as ResolvedUnitResult);
}
