import 'dart:convert';

import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:cli_util/cli_logging.dart';

import 'output_format.dart';
import 'render_lints.dart';

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
    Map<String, dynamic> location(
      String filePath,
      Map<String, dynamic> range,
    ) =>
        {
          'file': filePath,
          'range': range,
        };

    Map<String, dynamic> position(
      int? offset,
      int? line,
      int? column,
    ) =>
        {
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
      final contextMessages = [];
      if (error.contextMessages != null) {
        for (final contextMessage in error.contextMessages!) {
          var startOffset = contextMessage.location.offset;
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
    log.stdout(json.encode({
      'version': 1,
      'diagnostics': diagnostics,
    }));
  }
}
