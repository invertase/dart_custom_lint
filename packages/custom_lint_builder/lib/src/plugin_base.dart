import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';

abstract class PluginBase {
  Iterable<AnalysisError> getLints(LibraryElement library);

  Iterable<AnalysisErrorFixes> getFixes(LibraryElement library, int offset) {
    return const [];
  }
}
