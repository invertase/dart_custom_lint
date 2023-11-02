import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:cli_util/cli_logging.dart';

/// An enum for the output format.
enum OutputFormatEnum {
  /// The default output format.
  plain._('default'),

  /// Dart SDK like JSON output format.
  json._('json');

  const OutputFormatEnum._(this.name);

  /// The name of the format.
  final String name;

  /// Returns the [OutputFormatEnum] for the given [name].
  static OutputFormatEnum fromName(String name) {
    for (final format in OutputFormatEnum.values) {
      if (format.name == name) {
        return format;
      }
    }
    return plain;
  }
}

/// An abstract class for outputting lints
abstract class OutputFormat {
  /// Renders lints according to the format and flags.
  void render({
    required Iterable<AnalysisError> errors,
    required Logger log,
  });
}
