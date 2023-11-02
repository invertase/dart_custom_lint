import 'dart:convert';

import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:cli_util/cli_logging.dart';

import 'output_format.dart';

/// The JSON output format.
///
/// Code is an adaption of the original Dart SDK JSON format.
/// See: https://github.com/dart-lang/sdk/blob/main/pkg/dartdev/lib/src/commands/analyze.dart
class JsonOutputFormat implements OutputFormat {
  @override
  void render({
    required Iterable<AnalysisError> errors,
    required Logger log,
  }) {
    final diagnostics = <Map<String, Object?>>[];
    for (final error in errors) {
      final contextMessages = <Map<String, Object?>>[];
      if (error.contextMessages != null) {
        for (final contextMessage in error.contextMessages!) {
          final startOffset = contextMessage.location.offset;
          contextMessages.add({
            'location': _location(
              file: contextMessage.location.file,
              range: _range(
                start: _position(
                  offset: startOffset,
                  line: contextMessage.location.startLine,
                  column: contextMessage.location.startColumn,
                ),
                end: _position(
                  offset: startOffset + contextMessage.location.length,
                  line: contextMessage.location.endLine,
                  column: contextMessage.location.endColumn,
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
        'location': _location(
          file: error.location.file,
          range: _range(
            start: _position(
              offset: startOffset,
              line: error.location.startLine,
              column: error.location.startColumn,
            ),
            end: _position(
              offset: startOffset + error.location.length,
              line: error.location.endLine,
              column: error.location.endColumn,
            ),
          ),
        ),
        'problemMessage': error.message,
        if (error.correction != null) 'correctionMessage': error.correction,
        if (contextMessages.isNotEmpty) 'contextMessages': contextMessages,
        if (error.url != null) 'documentation': error.url,
      });
    }
    log.stdout(
      json.encode({
        'version': 1,
        'diagnostics': diagnostics,
      }),
    );
  }

  Map<String, Object?> _location({
    required String file,
    required Map<String, Object?> range,
  }) {
    return {
      'file': file,
      'range': range,
    };
  }

  Map<String, Object?> _position({
    int? offset,
    int? line,
    int? column,
  }) {
    return {
      'offset': offset,
      'line': line,
      'column': column,
    };
  }

  Map<String, Object?> _range({
    required Map<String, Object?> start,
    required Map<String, Object?> end,
  }) {
    return {
      'start': start,
      'end': end,
    };
  }
}
