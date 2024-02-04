import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:analyzer/source/line_info.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';
import 'package:matcher/matcher.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart';

/// Encodes a list of [PrioritizedSourceChange] into a string.
///
/// This strips the file paths from the json output.
///
/// If [source] is specified, the changes will be applied on the source,
/// and the result will be inserted in the json output.
String encodePrioritizedSourceChanges(
  Iterable<PrioritizedSourceChange> changes, {
  JsonEncoder? encoder,
  String? source,
}) {
  if (source != null) {
    final sourceLineInfo = LineInfo.fromContent(source);

    final buffer = StringBuffer();

    for (final prioritizedSourceChange in changes) {
      buffer.writeln('Message: `${prioritizedSourceChange.change.message}`');
      buffer.writeln('Priority: ${prioritizedSourceChange.priority}');
      if (prioritizedSourceChange.change.id != null) {
        buffer.writeln('Id: `${prioritizedSourceChange.change.id}`');
      }

      final output = SourceEdit.applySequence(
        source,
        prioritizedSourceChange.change.edits.expand((element) => element.edits),
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
        final lastChangedLine = lineInfo.getLocation(endOffset).lineNumber - 1;
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

      buffer.writeln('Diff (starting at line ${firstChangedLine + 1}):');
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

      buffer.writeln('\n');
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
/// If [source] is specified, the changes will be applied on the source,
/// and the result will be inserted in the json output.
@visibleForTesting
Matcher matcherNormalizedPrioritizedSourceChangeSnapshot(
  String filePath, {
  JsonEncoder? encoder,
  String? source,
}) {
  return _MatcherNormalizedPrioritizedSourceChangeSnapshot(
    filePath,
    encoder: encoder,
    source: source,
  );
}

class _MatcherNormalizedPrioritizedSourceChangeSnapshot extends Matcher {
  _MatcherNormalizedPrioritizedSourceChangeSnapshot(
    this.path, {
    this.encoder,
    String? source,
  }) : _source = source;

  final String path;
  final JsonEncoder? encoder;
  final String? _source;

  static final Object _mismatchedValueKey = Object();
  static final Object _expectedKey = Object();

  @override
  bool matches(
    covariant Iterable<PrioritizedSourceChange> object,
    Map<Object?, Object?> matchState,
  ) {
    final file = isRelative(path)
        ? File(join(Directory.current.path, 'test', path))
        : File(path);
    if (!file.existsSync()) {
      matchState[_mismatchedValueKey] = 'File not found: $path';
      return false;
    }

    final actual = encodePrioritizedSourceChanges(
      object,
      encoder: encoder,
      source: _source,
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
