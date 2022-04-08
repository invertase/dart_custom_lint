import 'package:meta/meta.dart';
import 'package:source_span/source_span.dart' as source_span;

/// The severify of a [Lint]. This influences how the IDE shows the lint.
enum LintSeverity {
  /// A potential change that should be made to the code.
  info,

  /// A possible problem in the code.
  warning,

  /// A problem in the code that is absolutely certain.
  error
}

/// Informations on a possible problem/change that should be made in the user's code
@immutable
class Lint {
  /// Informations on a possible problem/change that should be made in the user's code
  const Lint({
    required this.code,
    required this.message,
    required this.location,
    this.severity = LintSeverity.info,
    this.correction,
    this.url,
  });

  /// The severify of a [Lint]. This influences how the IDE shows the lint.
  final LintSeverity severity;

  /// The message to be displayed for this error. The message should indicate
  /// what is wrong with the code and why it is wrong.
  final String message;

  /// A unique key for this error.
  ///
  /// This key will be used for `// ignore: my_code`.
  final String code;

  /// The location associated with the error.
  final LintLocation location;

  /// The correction message to be displayed for this error.
  ///
  /// The correction message should indicate how the user can fix the error.
  /// The field is omitted if there is no correction message associated with
  /// the error code.
  final String? correction;

  /// The URL of a page containing documentation associated with this error.
  final String? url;
}

/// Indications on where a [Lint] is placed within the source code
@immutable
class LintLocation {
  /// Indications on where something in placed within the source code.
  LintLocation.fromOffsets({
    required int offset,
    int? length,
    int? endOffset,
  })  : assert(
          (length == null) ^ (endOffset == null),
          'Must specify either length or endOffset',
        ),
        assert(offset >= 0, 'offset must be positivie'),
        assert(length == null || length > 0, 'length must be positive'),
        assert(
          endOffset == null || endOffset > offset,
          'endOffset must be greater than offset',
        ),
        _toSourceSpan = ((sourceFile) {
          return sourceFile.span(
            offset,
            length != null ? offset + length : endOffset!,
          );
        });

  /// Indications on where something in placed within the source code.
  LintLocation.fromLines({
    required int startLine,
    int? startColumn,
    required int endLine,
    int? endColumn,
  })  : assert(startLine <= endLine, 'endLine must be greater than startLine'),
        assert(startLine >= 0, 'startLine must be positivie'),
        assert(
          startColumn == null ||
              endColumn == null ||
              startLine != endLine ||
              startColumn < endColumn,
          'When startLine == endLine, endColumn must be greater than startColumn',
        ),
        assert(endLine >= 0, 'endLine must be positive'),
        assert(
          startColumn == null || startColumn > 0,
          'startColumn must be positive',
        ),
        assert(
          endColumn == null || endColumn > 0,
          'endColumn must be positive',
        ),
        _toSourceSpan = ((sourceFile) {
          return sourceFile.span(
            sourceFile.getOffset(startLine, startColumn),
            sourceFile.getOffset(endLine, endColumn),
          );
        });

  // TODO use factory
  final source_span.SourceSpan Function(source_span.SourceFile sourceFile)
      _toSourceSpan;

  /// Converts a [LintLocation] into a [source_span.SourceSpan].
  source_span.SourceSpan toSourceSpan(source_span.SourceFile sourceFile) {
    return _toSourceSpan(sourceFile);
  }
}
