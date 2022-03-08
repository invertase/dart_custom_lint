import 'dart:isolate';

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:recase/recase.dart';
import 'package:path/path.dart' as path;
import 'package:analyzer/dart/element/element.dart';

void main(List<String> args, SendPort sendPort) {
  startPlugin(sendPort, _TargetLint());
}

class _TargetLint extends PluginBase {
  @override
  Iterable<AnalysisError> getLints(LibraryElement library) sync* {
    final libraryPath = library.source.fullName;
    final fileName = path.basenameWithoutExtension(libraryPath);

    final expectedName = ReCase(fileName).pascalCase;

    final hasElementWithExpectedName = library.topLevelElements
        .every((element) => element.name != expectedName);

    if (hasElementWithExpectedName) {
      yield AnalysisError(
        AnalysisErrorSeverity.WARNING,
        AnalysisErrorType.LINT,
        Location(libraryPath, 0, 100, 0, 0),
        'must contain a class named $expectedName',
        'target_controller',
      );
    }
  }
}
