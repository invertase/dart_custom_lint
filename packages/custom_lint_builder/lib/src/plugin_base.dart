import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';

/// A base class for custom analyzer plugins
///
/// If a print is emitted or an exception is uncaught,
abstract class PluginBase {
  /// Returns a list of warning/infos/errors for a Dart file.
  Iterable<AnalysisError> getLints(LibraryElement library);

  /// Return the list of fixes for lints emitted by [getLints].
  Iterable<AnalysisErrorFixes> getFixes(LibraryElement library, int offset) {
    return const [];
  }
}
