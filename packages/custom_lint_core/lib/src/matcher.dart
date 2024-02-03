import 'dart:convert';
import 'dart:io';

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
  List<PrioritizedSourceChange> changes, {
  JsonEncoder? encoder,
  String? source,
}) {
  if (source != null) {
    final buffer = StringBuffer();

    for (final prioritizedSourceChange in changes) {
      buffer.writeln('Message: `${prioritizedSourceChange.change.message}`');

      final output = SourceEdit.applySequence(
        source,
        prioritizedSourceChange.change.edits.expand((element) => element.edits),
      );

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

      buffer.writeln('<<<< start: $firstDiffOffset -- end: $endSourceOffset');
      if (firstDiffOffset != endSourceOffset) {
        buffer.writeln(source.substring(firstDiffOffset, endSourceOffset));
      }

      buffer.writeln('==== start: $firstDiffOffset -- end: $endOutputOffset');
      if (firstDiffOffset != endOutputOffset) {
        buffer.writeln(output.substring(firstDiffOffset, endOutputOffset));
      }

      buffer.writeln('>>>>');
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
    covariant List<PrioritizedSourceChange> object,
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
