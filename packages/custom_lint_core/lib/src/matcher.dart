import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:analyzer/source/line_info.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';
import 'package:collection/collection.dart';
import 'package:glob/glob.dart';
import 'package:matcher/matcher.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;

/// Encodes a list of [PrioritizedSourceChange] into a string.
///
/// This strips the file paths from the json output.
///
/// {@template encodePrioritizedSourceChanges.args}
/// - [sources] is an optional map of file paths to their content.
///   If specified, the changes will be applied to their corresponding source,
///   and the result will be saved in the diff.
///   Glob syntax is supported in the file paths.
/// - [relativePath] can be specified to change file paths in goldens
///   to be relative to a specific directory.
/// {@endtemplate}
String encodePrioritizedSourceChanges(
  Iterable<PrioritizedSourceChange> changes, {
  JsonEncoder? encoder,
  Map<String, String>? sources,
  String? relativePath,
}) {
  if (sources != null) {
    final buffer = StringBuffer();

    for (final prioritizedSourceChange in changes) {
      buffer.writeln('Message: `${prioritizedSourceChange.change.message}`');
      buffer.writeln('Priority: ${prioritizedSourceChange.priority}');
      if (prioritizedSourceChange.change.id != null) {
        buffer.writeln('Id: `${prioritizedSourceChange.change.id}`');
      }
      if (prioritizedSourceChange.change.selection case final selection?) {
        buffer.writeln(
          'Selection: offset ${selection.offset} ; '
          'file: `${selection.file}`; '
          'length: ${prioritizedSourceChange.change.selectionLength}',
        );
      }

      final files = prioritizedSourceChange.change.edits
          .map((e) => p.normalize(p.relative(e.file, from: relativePath)))
          .toSet()
          .sortedBy<String>((a) => a);

      for (final file in files) {
        final source = sources.entries
            .firstWhereOrNull(
              (e) =>
                  Glob(e.key).matches(file) ||
                  // workaround to https://github.com/dart-lang/glob/issues/72
                  Glob('/${e.key}').matches(file),
            )
            ?.value;
        if (source == null) {
          throw StateError('No source found for file: $file');
        }

        final sourceLineInfo = LineInfo.fromContent(source);

        final output = SourceEdit.applySequence(
          source,
          prioritizedSourceChange.change.edits
              .expand((element) => element.edits),
        );

        final outputLineInfo = LineInfo.fromContent(output);

        // Get the offset of the first changed character between output and source.
        var firstDiffOffset = 0;
        for (; firstDiffOffset < source.length; firstDiffOffset++) {
          if (source[firstDiffOffset] != output[firstDiffOffset]) {
            break;
          }
        }

        // Get the last changed character offset between output and source.
        var endSourceOffset = source.length - 1;
        var endOutputOffset = output.length - 1;
        for (;
            endOutputOffset > firstDiffOffset &&
                endSourceOffset > firstDiffOffset;
            endOutputOffset--, endSourceOffset--) {
          if (source[endSourceOffset] != output[endOutputOffset]) {
            break;
          }
        }

        final firstChangedLine =
            sourceLineInfo.getLocation(firstDiffOffset).lineNumber - 1;

        void writeDiff({
          required String file,
          required LineInfo lineInfo,
          required int endOffset,
          required String token,
          required int leadingCount,
          required int trailingCount,
        }) {
          final lastChangedLine =
              lineInfo.getLocation(endOffset).lineNumber - 1;
          final endLine =
              min(lastChangedLine + trailingCount, lineInfo.lineCount - 1);
          for (var line = max(0, firstChangedLine - leadingCount);
              line <= endLine;
              line++) {
            final changed = line >= firstChangedLine && line <= lastChangedLine;
            if (changed) buffer.write(token);

            final endOfSource = !(line + 1 < lineInfo.lineCount);

            buffer.write(
              file.substring(
                lineInfo.getOffsetOfLine(line),
                endOfSource ? null : lineInfo.getOffsetOfLine(line + 1) - 1,
              ),
            );
            if (!endOfSource) buffer.writeln();
          }
        }

        buffer.writeln('Diff for file `$file:${firstChangedLine + 1}`:');
        buffer.writeln('```');
        writeDiff(
          file: source,
          lineInfo: sourceLineInfo,
          endOffset: endSourceOffset,
          leadingCount: 2,
          trailingCount: 0,
          token: '- ',
        );

        writeDiff(
          file: output,
          lineInfo: outputLineInfo,
          endOffset: endOutputOffset,
          leadingCount: 0,
          trailingCount: 2,
          token: '+ ',
        );
        buffer.writeln('```');
      }

      buffer.writeln('---');
    }

    return buffer.toString();
  }

  final json = changes.map((e) => e.toJson()).toList();
  // Remove all "file" references from the json.
  for (final change in json) {
    final changeMap = change['change']! as Map<String, Object?>;
    final edits = changeMap['edits']! as List;
    for (final edit in edits.cast<Map<String, Object?>>()) {
      edit.remove('file');
    }
  }

  encoder ??= const JsonEncoder.withIndent('  ');
  return encoder.convert(json);
}

/// Expects that a [List<PrioritizedSourceChange>] matches with a serialized snapshots.
///
/// This effectively encode the list of changes, remove file paths from the result,
/// and compare this output with the content of a file.
///
/// {@macro encodePrioritizedSourceChanges.args}
@visibleForTesting
Matcher matcherNormalizedPrioritizedSourceChangeSnapshot(
  String filePath, {
  JsonEncoder? encoder,
  Map<String, String>? sources,
  String? relativePath,
}) {
  return _MatcherNormalizedPrioritizedSourceChangeSnapshot(
    filePath,
    encoder: encoder,
    sources: sources,
    relativePath: relativePath,
  );
}

class _MatcherNormalizedPrioritizedSourceChangeSnapshot extends Matcher {
  _MatcherNormalizedPrioritizedSourceChangeSnapshot(
    this.path, {
    this.encoder,
    this.sources,
    this.relativePath,
  });

  final String path;
  final JsonEncoder? encoder;
  final Map<String, String>? sources;
  final String? relativePath;

  static final Object _mismatchedValueKey = Object();
  static final Object _expectedKey = Object();

  @override
  bool matches(
    covariant Iterable<PrioritizedSourceChange> object,
    Map<Object?, Object?> matchState,
  ) {
    final file = p.isRelative(path)
        ? File(p.join(Directory.current.path, 'test', path))
        : File(path);
    if (!file.existsSync()) {
      matchState[_mismatchedValueKey] = 'File not found: $path';
      return false;
    }

    final actual = encodePrioritizedSourceChanges(
      object,
      encoder: encoder,
      sources: sources,
      relativePath: relativePath,
    );

    final expected = file.readAsStringSync();

    if (actual != expected) {
      matchState[_mismatchedValueKey] = actual;
      matchState[_expectedKey] = expected;
      return false;
    }

    return true;
  }

  @override
  Description describe(Description description) {
    return description.add('to match snapshot at $path');
  }

  @override
  Description describeMismatch(
    Object? item,
    Description mismatchDescription,
    Map<Object?, Object?> matchState,
    bool verbose,
  ) {
    final actualValue = matchState[_mismatchedValueKey] as String?;
    if (actualValue != null) {
      final expected = matchState[_expectedKey] as String?;

      if (expected != null) {
        return mismatchDescription
            .add('Expected to match snapshot at $path:\n')
            .addDescriptionOf(expected)
            .add('\n\nbut was:\n')
            .addDescriptionOf(actualValue);
      } else {
        return mismatchDescription.add(actualValue);
      }
    }

    return mismatchDescription.add('Unknown mismatch');
  }
}
