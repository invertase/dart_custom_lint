import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:cli_util/cli_logging.dart';

/// An abstract class for outputting lints
abstract class OutputFormat {
  /// Whether the lints should be sorted before being rendered.
  bool get sorted => false;

  /// Renders lints according to the format and flags.
  void render({
    required Iterable<AnalysisError> errors,
    required Logger log,
  });
}
