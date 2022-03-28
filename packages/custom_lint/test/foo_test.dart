import 'dart:io';

import 'package:test/test.dart';

import 'create_project.dart';
import 'peer_project_meta.dart';

void main() {
  test('hey', () {
    final meta = PeerProjectMeta.current;

    final dir = createPlugin(
      name: 'test_lint',
      main: '''
import 'dart:isolate';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart' hide Element;
import 'package:custom_lint_builder/custom_lint_builder.dart';

void main(List<String> args, SendPort sendPort) {
  startPlugin(sendPort, _HelloWorldLint());
}

class _HelloWorldLint extends PluginBase {
  @override
  Iterable<AnalysisError> getLints(LibraryElement library) sync* {
    final libraryPath = library.source.fullName;

    for (final variable in library.topLevelElements) {
      yield AnalysisError(
        // TODO use plugin.Type
        AnalysisErrorSeverity.WARNING,
        AnalysisErrorType.LINT,
        Location(libraryPath, variable.nameOffset, variable.nameLength, 0, 0),
        'Hello world',
        'hello_world',
      );
    }
  }
}
''',
    );

    creatLintUsage(
      source: {
        'lib/main.dart': '''
var count = 42;

void fn() {}
''',
      },
      plugins: {'test_lint': dir.uri},
      name: 'test_app',
    );

    print('Oy ${meta.customLintPath} ${meta.exampleAppPath}');
  });
}
