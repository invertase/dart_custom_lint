import 'package:custom_lint/src/protocol/public_protocol.dart';
import 'package:source_span/source_span.dart';
import 'package:test/test.dart';

import '../matchers.dart';

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

      test('toSourceSpan', () {
        final file = SourceFile.fromString('''
Hello
Paris
and
London
''');
        expect(
          LintLocation.fromOffsets(offset: 5, length: 8).toSourceSpan(file),
          file.span(5, 13),
        );
        expect(
          LintLocation.fromOffsets(offset: 5, endOffset: 15).toSourceSpan(file),
          file.span(5, 15),
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

      test('toSourceSpan', () {
        final file = SourceFile.fromString('''
Hello
Paris
and
London
''');
        expect(
          LintLocation.fromLines(startLine: 1, endLine: 2).toSourceSpan(file),
          file.span(6, 12),
        );
        expect(
          LintLocation.fromLines(
            startLine: 1,
            endLine: 2,
            endColumn: 3,
          ).toSourceSpan(file),
          file.span(6, 15),
        );
        expect(
          LintLocation.fromLines(
            startLine: 1,
            startColumn: 3,
            endLine: 2,
          ).toSourceSpan(file),
          file.span(9, 12),
        );
      });
    });

    test('fromSourceSpan', () {
      final file = SourceFile.fromString('Hello world');
      final span = file.span(1, 10);

      expect(
        LintLocation.fromSourceSpan(span)
            .toSourceSpan(SourceFile.fromString('')),
        span,
      );
    });
  });
}
