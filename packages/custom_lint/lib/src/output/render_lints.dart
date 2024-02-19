import 'dart:io';
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';
import 'package:cli_util/cli_logging.dart';
import 'package:collection/collection.dart';
import 'package:path/path.dart' as p;

import 'default_output_format.dart';
import 'json_output_format.dart';
import 'output_format.dart';

/// Renders lints according to the given format and flags.
void renderLints(
  List<AnalysisErrorsParams> lints, {
  required Logger log,
  required Directory workingDirectory,
  required bool fatalInfos,
  required bool fatalWarnings,
  required OutputFormatEnum format,
  Progress? progress,
}) {
  final OutputFormat outputFormat;
  switch (format) {
    case OutputFormatEnum.json:
      outputFormat = JsonOutputFormat();
      break;
    case OutputFormatEnum.plain:
    default:
      outputFormat = DefaultOutputFormat();
  }

  var errors = lints.expand((lint) => lint.errors);

  var fatal = false;
  for (final error in errors) {
    error.location.relativePath = p.relative(
      error.location.file,
      from: workingDirectory.absolute.path,
    );
    fatal = fatal ||
        error.severity == AnalysisErrorSeverity.ERROR ||
        (fatalWarnings && error.severity == AnalysisErrorSeverity.WARNING) ||
        (fatalInfos && error.severity == AnalysisErrorSeverity.INFO);
  }

  // Sort errors by severity, file, line, column, code, message
  // if the output format requires it
  errors = errors.sorted((a, b) {
    final severityCompare = -AnalysisErrorSeverity.VALUES
        .indexOf(a.severity)
        .compareTo(AnalysisErrorSeverity.VALUES.indexOf(b.severity));
    if (severityCompare != 0) return severityCompare;

    final fileCompare =
        a.location.relativePath.compareTo(b.location.relativePath);
    if (fileCompare != 0) return fileCompare;

    final lineCompare = a.location.startLine.compareTo(b.location.startLine);
    if (lineCompare != 0) return lineCompare;

    final columnCompare =
        a.location.startColumn.compareTo(b.location.startColumn);
    if (columnCompare != 0) return columnCompare;

    final codeCompare = a.code.compareTo(b.code);
    if (codeCompare != 0) return codeCompare;

    return a.message.compareTo(b.message);
  });

  // Finish progress and display duration (only when ANSI is supported)
  progress?.finish(showTiming: true);

  outputFormat.render(
    errors: errors,
    log: log,
  );

  if (fatal) {
    exitCode = 1;
    return;
  }
}

final _locationRelativePath = Expando('locationRelativePath');

/// A helper extension to set/get
/// the working directory relative path of a [Location].
extension LocationRelativePath on Location {
  /// The working directory relative path of this [Location].
  String get relativePath => _locationRelativePath[this]! as String;

  set relativePath(String path) => _locationRelativePath[this] = path;
}
