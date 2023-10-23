import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:cli_util/cli_logging.dart';

/// An abstract class for outputting lints
abstract class OutputFormat {
  /// Renders lints according to the format and flags.
  void render({
    required Iterable<AnalysisError> errors,
    required Logger log,
  });
}
