import 'package:analyzer/source/line_info.dart';
import 'package:custom_lint/src/protocol/public_protocol.dart';
import 'package:test/test.dart';

import '../matchers.dart';

TypeMatcher<SourceRange> isSourceChange({
  int? startOffset,
  int? endOffset,
  int? startLine,
  int? startColumn,
  int? endLine,
  int? endColumn,
  CharacterLocation? startLocation,
  CharacterLocation? endLocation,
}) {
  var matcher = isA<SourceRange>();
  if (startOffset != null) {
    matcher = matcher.having((e) => e.startOffset, 'startOffset', startOffset);
  }
  if (endOffset != null) {
    matcher = matcher.having((e) => e.endOffset, 'endOffset', endOffset);
  }
  if (startLocation != null) {
    matcher = matcher.having(
      (e) => e.startLocation,
      'startLocation',
      startLocation,
    );
  }
  if (endLocation != null) {
    matcher = matcher.having((e) => e.endLocation, 'endLocation', endLocation);
  }

  if (startLine != null) {
    matcher = matcher.having(
      (e) => e.startLocation.lineNumber,
      'startLocation.lineNumber',
      startLine,
    );
  }
  if (endLine != null) {
    matcher = matcher.having(
      (e) => e.endLocation.lineNumber,
      'endLocation.lineNumber',
      endLine,
    );
  }

  if (startColumn != null) {
    matcher = matcher.having(
      (e) => e.startLocation.columnNumber,
      'startLocation.columnNumber',
      startColumn,
    );
  }
  if (endColumn != null) {
    matcher = matcher.having(
      (e) => e.endLocation.columnNumber,
      'endLocation.columnNumber',
      endColumn,
    );
  }

  return matcher;
}

void main() {
  group('LintSourceLocation', () {
    group('fromOffset', () {
      test('asserts parameters are positive', () {
        LintLocation.fromOffsets(offset: 0, length: 1);
        LintLocation.fromOffsets(offset: 0, endOffset: 5);

        expect(
          () => LintLocation.fromOffsets(offset: 0, length: 1, endOffset: 5),
          throwsAssertionError,
        );
        expect(
          () => LintLocation.fromOffsets(offset: 0),
          throwsAssertionError,
        );
        expect(
          () => LintLocation.fromOffsets(offset: 5, endOffset: 2),
          throwsAssertionError,
        );
        expect(
          () => LintLocation.fromOffsets(offset: -1, length: 1),
          throwsAssertionError,
        );
        expect(
          () => LintLocation.fromOffsets(offset: 0, length: 0),
          throwsAssertionError,
        );
      });

      test('getRange', () {
        final file = LineInfo.fromContent('''
Hello
Paris
and
London
''');
        expect(
          LintLocation.fromOffsets(offset: 5, length: 8).getRange(file),
          isSourceChange(
            startOffset: 5,
            endOffset: 13,
            startLocation: file.getLocation(5),
            endLocation: file.getLocation(13),
          ),
        );
        expect(
          LintLocation.fromOffsets(offset: 5, endOffset: 15).getRange(file),
          isSourceChange(
            startOffset: 5,
            endOffset: 15,
            startLocation: file.getLocation(5),
            endLocation: file.getLocation(15),
          ),
        );
      });
    });

    group('fromLines', () {
      test('asserts parameters are positive', () {
        LintLocation.fromLines(startLine: 0, endLine: 0);
        LintLocation.fromLines(
          startLine: 0,
          startColumn: 5,
          endLine: 0,
          endColumn: 10,
        );

        expect(
          () => LintLocation.fromLines(startLine: 1, endLine: 0),
          throwsAssertionError,
        );
        expect(
          () => LintLocation.fromLines(startLine: -1, endLine: 0),
          throwsAssertionError,
        );
        expect(
          () => LintLocation.fromLines(startLine: 0, endLine: -1),
          throwsAssertionError,
        );
        expect(
          () => LintLocation.fromLines(
            startLine: 0,
            endLine: 0,
            startColumn: -1,
          ),
          throwsAssertionError,
        );
        expect(
          () => LintLocation.fromLines(
            startLine: 0,
            endLine: 0,
            endColumn: -1,
          ),
          throwsAssertionError,
        );
        expect(
          () => LintLocation.fromLines(
            startLine: 0,
            startColumn: 10,
            endLine: 0,
            endColumn: 5,
          ),
          throwsAssertionError,
        );
      });

      test('getRange', () {
        final file = LineInfo.fromContent('''
Hello
Paris
and
London
''');
        expect(
          LintLocation.fromLines(startLine: 1, endLine: 2).getRange(file),
          isSourceChange(
            startOffset: 6,
            endOffset: 12,
            startLocation: file.getLocation(6),
            endLocation: file.getLocation(12),
          ),
        );
        expect(
          LintLocation.fromLines(
            startLine: 1,
            endLine: 2,
            endColumn: 3,
          ).getRange(file),
          isSourceChange(
            startOffset: 6,
            endOffset: 15,
            startLocation: file.getLocation(6),
            endLocation: file.getLocation(15),
          ),
        );
        expect(
          LintLocation.fromLines(
            startLine: 1,
            startColumn: 3,
            endLine: 2,
          ).getRange(file),
          isSourceChange(
            startOffset: 9,
            endOffset: 12,
            startLocation: file.getLocation(9),
            endLocation: file.getLocation(12),
          ),
        );
      });
    });
  });
}
