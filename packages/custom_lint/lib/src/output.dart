import 'dart:convert';
import 'dart:io';

import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';
import 'package:cli_util/cli_logging.dart';
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;

/// The maximum length of any of the existing severity labels.
const int _severityWidth = 7;

/// The number of spaces needed to indent follow-on lines (the body) under the
/// message. The width left for the severity label plus the separator width.
const int _bodyIndentWidth = _severityWidth + 3;

final String _bodyIndent = ' ' * _bodyIndentWidth;

/// is used as the usageLineLength.
int? get _dartdevUsageLineLength =>
    stdout.hasTerminal ? stdout.terminalColumns : null;

/// Renders a list of lints in the given format.
@internal
void renderLints(
  Logger log,
  List<AnalysisErrorsParams> lints, {
  required Directory workingDirectory,
  required String format,
}) {
  final errors = lints
      .expand(
        (lintsForFile) => lintsForFile.errors
          ..sort((a, b) {
            final lineCompare =
                a.location.startLine.compareTo(b.location.startLine);
            if (lineCompare != 0) return lineCompare;
            final columnCompare =
                a.location.startColumn.compareTo(b.location.startColumn);
            if (columnCompare != 0) return columnCompare;

            final codeCompare = a.code.compareTo(b.code);
            if (codeCompare != 0) return codeCompare;

            return a.message.compareTo(b.message);
          }),
      )
      .sortedBy((e) => _relativeFilePath(e.location.file, workingDirectory))
      .sortedBy<num>((e) => -AnalysisErrorSeverity.VALUES.indexOf(e.severity));

  if (errors.isEmpty) {
    log.writeln('No issues found!');
    return;
  }

  switch (format) {
    case 'json':
      emitJsonFormat(log, errors);
      break;
    default:
      emitDefaultFormat(log, errors, workingDirectory);
      break;
  }
}

/// Emits a list of lints in the Dart analyzer style JSON format.
@internal
void emitJsonFormat(
  Logger log,
  Iterable<AnalysisError> errors,
) {
  Map<String, dynamic> location(String filePath, Map<String, dynamic> range) =>
      {
        'file': filePath,
        'range': range,
      };

  Map<String, dynamic> position(int? offset, int? line, int? column) => {
        'offset': offset,
        'line': line,
        'column': column,
      };

  Map<String, dynamic> range(
    Map<String, dynamic> start,
    Map<String, dynamic> end,
  ) =>
      {
        'start': start,
        'end': end,
      };

  final diagnostics = <Map<String, dynamic>>[];
  for (final error in errors) {
    final contextMessages = <Map<String, dynamic>>[];
    if (error.contextMessages != null) {
      for (final contextMessage in error.contextMessages!) {
        final startOffset = contextMessage.location.offset;
        contextMessages.add({
          'location': location(
            contextMessage.location.file,
            range(
              position(
                startOffset,
                contextMessage.location.startLine,
                contextMessage.location.startColumn,
              ),
              position(
                startOffset + contextMessage.location.length,
                contextMessage.location.endLine,
                contextMessage.location.endColumn,
              ),
            ),
          ),
          'message': contextMessage.message,
        });
      }
    }
    final startOffset = error.location.offset;
    diagnostics.add({
      'code': error.code,
      'severity': error.severity,
      'type': error.type,
      'location': location(
        error.location.file,
        range(
          position(
            startOffset,
            error.location.startLine,
            error.location.startColumn,
          ),
          position(
            startOffset + error.location.length,
            error.location.endLine,
            error.location.endColumn,
          ),
        ),
      ),
      'problemMessage': error.message,
      if (error.correction != null) 'correctionMessage': error.correction,
      if (contextMessages.isNotEmpty) 'contextMessages': contextMessages,
      if (error.url != null) 'documentation': error.url,
    });
  }
  log.writeln(json.encode({'version': 1, 'diagnostics': diagnostics}));
}

/// Emits a list of lints in the Dart analyzer style default format.
@internal
void emitDefaultFormat(
  Logger log,
  Iterable<AnalysisError> errors,
  Directory workingDirectory,
) {
  final ansi = log.ansi;
  final bullet = ansi.bullet;

  final wrapWidth = _dartdevUsageLineLength == null
      ? null
      : (_dartdevUsageLineLength! - _bodyIndentWidth);

  log.writeln('');

  for (final error in errors) {
    var severity = error.severity.name.toLowerCase().padLeft(_severityWidth);
    if (error.severity == AnalysisErrorSeverity.ERROR) {
      severity = ansi.error(severity);
    }

    final filePath = _relativeFilePath(error.location.file, workingDirectory);

    var message = ansi.emphasized(error.message);
    if (error.correction != null) {
      message += ' ${error.correction}';
    }

    final location =
        '$filePath:${error.location.startLine}:${error.location.startColumn}';
    var output = '$location $bullet '
        '$message $bullet '
        '${ansi.green}${error.code}${ansi.none}';

    // performing line wrapping.
    output = _wrapText(output, width: wrapWidth);
    log.writeln(
      '$severity $bullet '
      '${output.replaceAll('\n', '\n$_bodyIndent')}',
    );

    // Add any context messages as bullet list items.
    if (error.contextMessages != null) {
      for (final message in error.contextMessages!) {
        final contextPath =
            _relativeFilePath(error.location.file, workingDirectory);
        var messageSentenceFragment = message.message;
        messageSentenceFragment = messageSentenceFragment.endsWith('.')
            ? messageSentenceFragment.replaceRange(
                messageSentenceFragment.length - 1,
                messageSentenceFragment.length,
                '',
              )
            : messageSentenceFragment;

        log.writeln('$_bodyIndent'
            ' - ${message.message.endsWith('.')} at '
            '$contextPath:${message.location.startLine}:${message.location.startColumn}.');
      }
    }
  }

  log.writeln('');

  final errorCount = errors.length;
  log.writeln('$errorCount issue${errorCount > 1 ? 's' : ''} found.');
}

String _relativeFilePath(String file, Directory fromDir) {
  return p.relative(
    file,
    from: fromDir.absolute.path,
  );
}

/// Wraps [text] to the given [width], if provided.
///
/// Method taken from:
/// https://github.com/dart-lang/sdk/blob/d71a37af18751e6086d66d868521e31b0126e0a5/pkg/dartdev/lib/src/utils.dart#L58
String _wrapText(String text, {int? width}) {
  if (width == null) {
    return text;
  }

  final buffer = StringBuffer();
  var lineMaxEndIndex = width;
  var lineStartIndex = 0;

  while (true) {
    if (lineMaxEndIndex >= text.length) {
      buffer.write(text.substring(lineStartIndex, text.length));
      break;
    } else {
      var lastSpaceIndex = text.lastIndexOf(' ', lineMaxEndIndex);
      if (lastSpaceIndex == -1 || lastSpaceIndex <= lineStartIndex) {
        // No space between [lineStartIndex] and [lineMaxEndIndex]. Get the
        // _next_ space.
        lastSpaceIndex = text.indexOf(' ', lineMaxEndIndex);
        if (lastSpaceIndex == -1) {
          // No space at all after [lineStartIndex].
          lastSpaceIndex = text.length;
          buffer.write(text.substring(lineStartIndex, lastSpaceIndex));
          break;
        }
      }
      buffer.write(text.substring(lineStartIndex, lastSpaceIndex));
      buffer.writeln();
      lineStartIndex = lastSpaceIndex + 1;
    }
    lineMaxEndIndex = lineStartIndex + width;
  }
  return buffer.toString();
}

extension on Logger {
  void writeln(String message) {
    write(message);
    write('\n');
  }
}
