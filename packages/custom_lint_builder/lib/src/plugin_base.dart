import 'package:analyzer/dart/analysis/results.dart';

import '../custom_lint_builder.dart';

/// A base class for custom analyzer plugins
///
/// If a print is emitted or an exception is uncaught,
abstract class PluginBase {
  /// Returns a list of warning/infos/errors for a Dart file.
  Stream<Lint> getLints(ResolvedUnitResult resolvedUnitResult) {
    return const Stream.empty();
  }
}
