// ignore_for_file: type=lint
// Forked from analyzer_plugin to fix https://github.com/invertase/dart_custom_lint/issues/87

// Copyright (c) 2017, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/source/line_info.dart' as analyzer;
import 'package:analyzer/diagnostic/diagnostic.dart' as analyzer;
import 'package:analyzer/error/error.dart' as analyzer;
import 'package:analyzer/source/error_processor.dart' as analyzer;
import 'package:analyzer/src/generated/engine.dart' as analyzer;
import 'package:analyzer_plugin/protocol/protocol_common.dart' as plugin;

/// An object used to convert between objects defined by the 'analyzer' package
/// and those defined by the plugin protocol.
///
/// Clients may not extend, implement or mix-in this class.
class CustomAnalyzerConverter {
  /// Convert the analysis [error] from the 'analyzer' package to an analysis
  /// error defined by the plugin API. If a [lineInfo] is provided then the
  /// error's location will have a start line and start column. If a [severity]
  /// is provided, then it will override the severity defined by the error.
  plugin.AnalysisError convertAnalysisError(
    analyzer.AnalysisError error, {
    analyzer.LineInfo? lineInfo,
    analyzer.DiagnosticSeverity? severity,
  }) {
    var errorCode = error.errorCode;
    severity ??= errorCode.errorSeverity;
    var offset = error.offset;
    var startLine = -1;
    var startColumn = -1;
    var endLine = -1;
    var endColumn = -1;
    if (lineInfo != null) {
      var startLocation = lineInfo.getLocation(offset);
      startLine = startLocation.lineNumber;
      startColumn = startLocation.columnNumber;
      var endLocation = lineInfo.getLocation(offset + error.length);
      endLine = endLocation.lineNumber;
      endColumn = endLocation.columnNumber;
    }
    List<plugin.DiagnosticMessage>? contextMessages;
    if (error.contextMessages.isNotEmpty) {
      contextMessages = error.contextMessages
          .map((message) =>
              convertDiagnosticMessage(message, lineInfo: lineInfo))
          .toList();
    }
    return plugin.AnalysisError(
      convertErrorSeverity(severity),
      convertErrorType(errorCode.type),
      plugin.Location(
          error.source.fullName, offset, error.length, startLine, startColumn,
          endLine: endLine, endColumn: endColumn),
      error.message,
      errorCode.name.toLowerCase(),
      contextMessages: contextMessages,
      correction: error.correction,
      hasFix: null,
      url: errorCode.url,
    );
  }

  /// Convert the list of analysis [errors] from the 'analyzer' package to a
  /// list of analysis errors defined by the plugin API. If a [lineInfo] is
  /// provided then the resulting errors locations will have a start line and
  /// start column. If an analysis [options] is provided then the severities of
  /// the errors will be altered based on those options.
  List<plugin.AnalysisError> convertAnalysisErrors(
      List<analyzer.AnalysisError> errors,
      {analyzer.LineInfo? lineInfo,
      analyzer.AnalysisOptions? options}) {
    var serverErrors = <plugin.AnalysisError>[];
    for (var error in errors) {
      var processor = analyzer.ErrorProcessor.getProcessor(options, error);
      if (processor != null) {
        var severity = processor.severity;
        // Errors with null severity are filtered out.
        if (severity != null) {
          // Specified severities override.
          serverErrors.add(convertAnalysisError(error,
              lineInfo: lineInfo, severity: severity));
        }
      } else {
        serverErrors.add(convertAnalysisError(error, lineInfo: lineInfo));
      }
    }
    return serverErrors;
  }

  /// Convert the diagnostic [message] from the 'analyzer' package to an
  /// analysis error defined by the plugin API. If a [lineInfo] is provided then
  /// the error's location will have a start line and start column.
  plugin.DiagnosticMessage convertDiagnosticMessage(
      analyzer.DiagnosticMessage message,
      {analyzer.LineInfo? lineInfo}) {
    var file = message.filePath;
    var offset = message.offset;
    var length = message.length;
    var startLine = -1;
    var startColumn = -1;
    var endLine = -1;
    var endColumn = -1;
    if (lineInfo != null) {
      var lineLocation = lineInfo.getLocation(offset);
      startLine = lineLocation.lineNumber;
      startColumn = lineLocation.columnNumber;
      var endLocation = lineInfo.getLocation(offset + length);
      endLine = endLocation.lineNumber;
      endColumn = endLocation.columnNumber;
    }
    return plugin.DiagnosticMessage(
        message.messageText(includeUrl: true),
        plugin.Location(file, offset, length, startLine, startColumn,
            endLine: endLine, endColumn: endColumn));
  }

  /// Convert the error [severity] from the 'analyzer' package to an analysis
  /// error severity defined by the plugin API.
  plugin.AnalysisErrorSeverity convertErrorSeverity(
          analyzer.DiagnosticSeverity severity) =>
      plugin.AnalysisErrorSeverity.values.byName(severity.name);

  /// Convert the error [type] from the 'analyzer' package to an analysis error
  /// type defined by the plugin API.
  plugin.AnalysisErrorType convertErrorType(analyzer.DiagnosticType type) =>
      plugin.AnalysisErrorType.values.byName(type.name);
}
