import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer/source/line_info.dart';
import 'package:meta/meta.dart';

import '../custom_lint_builder.dart';

final _expectLintRegex = RegExp(r'//\s*expect_lint\s*:(.+)$', multiLine: true);

/// A class implementing the logic for `// expect_lint: code` comments
@internal
class ExpectLint {
  /// A class implementing the logic for `// expect_lint: code` comments
  const ExpectLint(this.analysisErrors);

  static const _code = LintCode(
    name: 'unfulfilled_expect_lint',
    problemMessage:
        'Expected to find the lint {0} on next line but none found.',
    correctionMessage: 'Either update the code such that it emits the lint {0} '
        'or update the expect_lint clause to not include the code {0}.',
    errorSeverity: ErrorSeverity.ERROR,
  );

  /// The list of lints emitted in the file.
  final List<AnalysisError> analysisErrors;

  /// Emits expect_lints
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
  ) {
    final expectLints = _getAllExpectedLints(
      resolver.source.contents.data,
      resolver.lineInfo,
      filePath: resolver.path,
    );

    final allExpectedLints = expectLints
        .map((e) => _ComparableExpectLintMeta(e.line, e.code))
        .toSet();

    // The list of all the expect_lints codes that don't have a matching lint.
    final unfulfilledExpectedLints = expectLints.toList();

    for (final lint in analysisErrors) {
      final lintLine = resolver.lineInfo.getLocation(lint.offset);

      final matchingExpectLintMeta = _ComparableExpectLintMeta(
        // Lints use 1-based offsets but expectLints use 0-based offsets. So
        // we remove 1 to have them on the same unit. Then we remove 1 again
        // to access the line before the lint.
        lintLine.lineNumber - 2,
        lint.errorCode.name,
      );

      if (allExpectedLints.contains(matchingExpectLintMeta)) {
        // The lint has a matching expect_lint. Let's ignore the lint and mark
        // the associated expect_lint as fulfilled.
        unfulfilledExpectedLints.removeWhere(
          (e) =>
              e.line == matchingExpectLintMeta.line &&
              e.code == matchingExpectLintMeta.code,
        );
      } else {
        // The lint has no matching expect_lint. Therefore we let it propagate
        reporter.reportError(lint);
      }
    }

    // Some expect_lint clauses where not respected
    for (final unfulfilledExpectedLint in unfulfilledExpectedLints) {
      reporter.reportErrorForOffset(
        _code,
        unfulfilledExpectedLint.offset,
        unfulfilledExpectedLint.code.length,
        [unfulfilledExpectedLint.code],
      );
    }
  }

  List<_ExpectLintMeta> _getAllExpectedLints(
    String source,
    LineInfo lineInfo, {
    required String filePath,
  }) {
    // expect_lint is only supported in dart files as it relies on dart comments
    if (!filePath.endsWith('.dart')) return const [];

    final expectLints = _expectLintRegex.allMatches(source);

    return expectLints.expand((expectLint) {
      final lineNumber = lineInfo.getLocation(expectLint.start).lineNumber - 1;
      final codesStartOffset = source.indexOf(':', expectLint.start) + 1;

      final codes = expectLint.group(1)!.split(',');
      var codeOffsetAcc = codesStartOffset;

      return codes.map((rawCode) {
        final codeOffset =
            codeOffsetAcc + (rawCode.length - rawCode.trimLeft().length);
        codeOffsetAcc += rawCode.length + 1;

        final code = rawCode.trim();

        return _ExpectLintMeta(
          line: lineNumber,
          code: code,
          offset: codeOffset,
        );
      });
    }).toList();
  }
}

/// Information about an `// expect_lint: code` clause
@immutable
class _ExpectLintMeta {
  /// Information about an `// expect_lint: code` clause
  const _ExpectLintMeta({
    required this.line,
    required this.code,
    required this.offset,
  }) : assert(line >= 0, 'line must be positive');

  /// A 0-based offset of the line having the expect_lint clause.
  final int line;

  /// The code expected.
  final String code;

  /// The index of the first character of [code] within the analyzed file.
  final int offset;
}

@immutable
class _ComparableExpectLintMeta {
  const _ComparableExpectLintMeta(this.line, this.code);

  final int line;
  final String code;

  @override
  int get hashCode => Object.hash(line, code);

  @override
  bool operator ==(Object other) {
    return other is _ComparableExpectLintMeta &&
        other.code == code &&
        other.line == line;
  }
}
