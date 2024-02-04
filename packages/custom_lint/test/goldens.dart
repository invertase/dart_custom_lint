import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:analyzer/source/line_info.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';
import 'package:custom_lint/src/package_utils.dart';
import 'package:test/test.dart';

final _fixesGoldenFile =
    Directory.current.file('test', 'goldens', 'ignore_quick_fix.json');

void saveGoldensFixes(
  Iterable<PrioritizedSourceChange> fixes, {
  String? source,
  File? file,
}) {
  final f = file ?? _fixesGoldenFile;
  f.createSync(recursive: true);

  f.writeAsStringSync(
    _encodePrioritizedSourceChanges(fixes, source: source),
  );
}

void expectMatchesGoldenFixes(
  Iterable<PrioritizedSourceChange> fixes, {
  File? file,
  String? source,
}) {
  expect(
    _encodePrioritizedSourceChanges(fixes, source: source),
    (file ?? _fixesGoldenFile).readAsStringSync(),
  );
}

// forked from custom-lint-core
String _encodePrioritizedSourceChanges(
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
