import 'package:analyzer/error/error.dart';
import 'package:collection/collection.dart';
import 'package:custom_lint_core/custom_lint_core.dart';

/// Metadata about ignores at a given line.
class IgnoreMetadata {
  IgnoreMetadata._(
    this._codes, {
    required this.startOffset,
    required this.endOffset,
  });

  factory IgnoreMetadata._parse(
    RegExpMatch? ignore, {
    required int startOffset,
  }) {
    if (ignore == null) return IgnoreMetadata.empty;

    final fullMatchString = ignore.group(0)!;

    final codes = fullMatchString
        .substring(fullMatchString.indexOf(':') + 1)
        .split(',')
        .map((e) => e.trim())
        .toSet();

    return IgnoreMetadata._(
      codes,
      startOffset: ignore.start + startOffset,
      endOffset: startOffset + ignore.end,
    );
  }

  /// Empty metadata.
  static final empty = IgnoreMetadata._(
    null,
    startOffset: -1,
    endOffset: -1,
  );

  final Set<String>? _codes;

  /// Whether there are any ignores for this line.
  bool get hasIgnore => _codes != null;

  /// Whether all lints are ignored using `type=lint`
  // ignore: use_if_null_to_convert_nulls_to_bools
  bool get disablesAllLints => _codes?.contains('type=lint') == true;

  /// The offset of where the ignore starts.
  ///
  /// Will be -1 if there is no ignore.
  final int startOffset;

  /// The offset of where the ignore ends.
  final int endOffset;

  /// Whether the given code is ignored.
  bool isIgnored(String code) {
    final codes = _codes;
    if (codes == null) return false;
    return codes.contains(code) || disablesAllLints;
  }
}

final _ignoreRegex = RegExp(r'//\s*ignore\s*:.*?$', multiLine: true);

/// Searches for `// ignore:` matching a given line.
IgnoreMetadata parseIgnoreForLine(
  int offset,
  CustomLintResolver resolver,
) {
  final line = resolver.lineInfo.getLocation(offset).lineNumber - 1;

  if (line <= 0) return IgnoreMetadata.empty;

  final previousLineOffset = resolver.lineInfo.getOffsetOfLine(line - 1);
  final previousLine = resolver.source.contents.data.substring(
    previousLineOffset,
    offset - 1,
  );

  final codeContent = _ignoreRegex.firstMatch(previousLine);
  if (codeContent == null) return IgnoreMetadata.empty;

  return IgnoreMetadata._parse(codeContent, startOffset: previousLineOffset);
}

final _ignoreForFileRegex =
    RegExp(r'//\s*ignore_for_file\s*:.*$', multiLine: true);

/// Searches for `// ignore_for_file:` in a given file.
List<IgnoreMetadata> parseIgnoreForFile(String source) {
  final ignoreForFiles = _ignoreForFileRegex.allMatches(source).whereNotNull();

  return ignoreForFiles
      .map((e) => IgnoreMetadata._parse(e, startOffset: 0))
      .toList();
}

/// Built in fix to ignore a lint.
class IgnoreCode extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    final ignoreForLine = parseIgnoreForLine(analysisError.offset, resolver);
    final ignoreForFile = parseIgnoreForFile(resolver.source.contents.data);

    final ignoreForLineChangeBuilder = reporter.createChangeBuilder(
      message: 'Ignore "${analysisError.errorCode.name}" for line',
      priority: 35,
    );

    ignoreForLineChangeBuilder.addDartFileEdit((builder) {
      if (ignoreForLine.hasIgnore) {
        builder.addSimpleInsertion(
          ignoreForLine.endOffset,
          ', ${analysisError.errorCode.name}',
        );
      } else {
        final offsetLine =
            resolver.lineInfo.getLocation(analysisError.offset).lineNumber - 1;

        final startLineOffset = resolver.lineInfo.getOffsetOfLine(offsetLine);

        final indentLength = resolver.source.contents.data
            .substring(startLineOffset)
            .indexOf(RegExp(r'\S'));

        builder.addSimpleInsertion(
          startLineOffset,
          '${' ' * indentLength}// ignore: ${analysisError.errorCode.name}\n',
        );
      }
    });

    final ignoreForFileChangeBuilder = reporter.createChangeBuilder(
      message: 'Ignore "${analysisError.errorCode.name}" for file',
      priority: 34,
    );

    ignoreForFileChangeBuilder.addDartFileEdit((builder) {
      final firstIgnore = ignoreForFile.firstOrNull;
      if (firstIgnore == null) {
        builder.addSimpleInsertion(
          0,
          '// ignore_for_file: ${analysisError.errorCode.name}\n',
        );
      } else {
        builder.addSimpleInsertion(
          firstIgnore.endOffset,
          ', ${analysisError.errorCode.name}',
        );
      }
    });
  }
}
