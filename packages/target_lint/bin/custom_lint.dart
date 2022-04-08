import 'dart:isolate';

import 'package:analyzer/dart/element/element.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:path/path.dart' as path;
import 'package:recase/recase.dart';

void main(List<String> args, SendPort sendPort) {
  startPlugin(sendPort, _TargetLint());
}

class _TargetLint extends PluginBase {
  @override
  Iterable<Lint> getLints(LibraryElement library) sync* {
    final libraryPath = library.source.fullName;
    final fileName = path.basenameWithoutExtension(libraryPath);

    final expectedName = ReCase(fileName).pascalCase;

    final hasElementWithExpectedName = library.topLevelElements
        .every((element) => element.name != expectedName);

    if (hasElementWithExpectedName) {
      yield Lint(
        code: 'target_controller',
        message: 'must contain a class named $expectedName',
        location: LintLocation.fromOffsets(
          offset: library.topLevelElements.first.nameOffset,
          length: library.topLevelElements.first.nameLength,
        ),
      );
    }
  }
}
