import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart'
    as analyzer_plugin;

import '../custom_lint_builder.dart';

/// A base class for custom analyzer plugins
///
/// If a print is emitted or an exception is uncaught,
abstract class PluginBase {
  /// Returns a list of warning/infos/errors for a Dart file.
  Stream<Lint> getLints(ResolvedUnitResult resolvedUnitResult) {
    return const Stream.empty();
  }

  /// Obtains the list of fixes for the given offset.
  ///
  /// Defaults to reading [getLints] and obtaining their respective fixes.
  Future<analyzer_plugin.EditGetFixesResult> handleEditGetFixes(
    ResolvedUnitResult resolvedUnitResult,
    int offset,
  ) async {
    return analyzer_plugin.EditGetFixesResult(
      await getLints(resolvedUnitResult)
          // Silence getLints errors. They should already be logged separately
          .where((lint) =>
              offset >= lint.location.offset &&
              offset <= lint.location.offset + lint.location.length)
          .handleError((_) {})
          .asyncExpand((lint) => lint.handleGetAnalysisErrorFixes())
          .toList(),
    );
  }

  /// Obtains the list of assists for a given selected text.
  ///
  /// Defaults to returning an empty list of assists.
  Future<analyzer_plugin.EditGetAssistsResult> handleGetAssists(
    ResolvedUnitResult resolvedUnitResult, {
    required int offset,
    required int length,
  }) async {
    return analyzer_plugin.EditGetAssistsResult([]);
  }
}
