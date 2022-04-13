import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

import 'create_project.dart';
import 'run_plugin.dart';

const source = '''
import 'dart:isolate';
import 'package:analyzer/dart/element/element.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

void main(List<String> args, SendPort sendPort) {
  startPlugin(sendPort, _HelloWorldLint());
}

class _HelloWorldLint extends PluginBase {
  @override
  Iterable<Lint> getLints(LibraryElement library) sync* {
    for (final variable in library.topLevelElements) {
      yield Lint(
        code: 'hello_world',
        message: 'Hello world',
        location: LintLocation.fromOffsets(
          offset: variable.nameOffset,
          length: variable.nameLength,
        ),
      );
      yield Lint(
        code: 'foo',
        message: 'Foo',
        location: LintLocation.fromOffsets(
          offset: variable.nameOffset,
          length: variable.nameLength,
        ),
      );
    }
  }
}
''';

void main() {
  test('supports `// ignore: code`', () async {
    final plugin = createPlugin(
      name: 'test_lint',
      main: source,
    );

    final app = creatLintUsage(
      source: {
        'lib/main.dart': '''
void fn() {}

// ignore: hello_world, This is some comment foo
void fn2() {}

// ignore: foo, hello_world
void fn3() {}

// ignore: type=lint, some comment
void fn3() {}
'''
      },
      plugins: {'test_lint': plugin.uri},
      name: 'test_app',
    );

    final runner = await startRunnerForApp(app);

    expect(
      await runner.channel.lintsExcludingBuiltIn.first,
      predicate<AnalysisErrorsParams>((value) {
        expect(value.file, join(app.path, 'lib', 'main.dart'));
        expect(value.errors.length, 3);

        expect(value.errors.first.code, 'hello_world');
        expect(
          value.errors.first.location,
          Location(value.file, 5, 2, 0, 5, endColumn: 7, endLine: 0),
        );

        expect(value.errors[1].code, 'foo');
        expect(
          value.errors[1].location,
          Location(value.file, 5, 2, 0, 5, endColumn: 7, endLine: 0),
        );

        expect(value.errors[2].code, 'foo');
        expect(
          value.errors[2].location,
          Location(value.file, 68, 3, 3, 5, endColumn: 8, endLine: 3),
        );
        return true;
      }),
    );

    expect(runner.channel.lintsExcludingBuiltIn, emitsDone);

    // Closing so that previous error matchers relying on stream
    // closing can complete
    await runner.close();

    expect(plugin.log.existsSync(), false);
  });

  test('supports `// ignore_for_file: code`', () async {
    final plugin = createPlugin(
      name: 'test_lint',
      main: source,
    );

    final app = creatLintUsage(
      source: {
        'lib/main.dart': '''
// ignore_for_file: foo, some comment

void fn() {}

// ignore: hello_world
void fn2() {}

// ignore: foo
void fn3() {}
'''
      },
      plugins: {'test_lint': plugin.uri},
      name: 'test_app',
    );

    final runner = await startRunnerForApp(app);

    expect(
      await runner.channel.lintsExcludingBuiltIn.first,
      predicate<AnalysisErrorsParams>((value) {
        expect(value.file, join(app.path, 'lib', 'main.dart'));
        expect(value.errors.length, 2);

        expect(value.errors.first.code, 'hello_world');
        expect(
          value.errors.first.location,
          Location(value.file, 44, 2, 2, 5, endColumn: 7, endLine: 2),
        );

        expect(value.errors[1].code, 'hello_world');
        expect(
          value.errors[1].location,
          Location(value.file, 111, 3, 8, 5, endColumn: 8, endLine: 8),
        );
        return true;
      }),
    );

    expect(runner.channel.lintsExcludingBuiltIn, emitsDone);

    // Closing so that previous error matchers relying on stream
    // closing can complete
    await runner.close();

    expect(plugin.log.existsSync(), false);
  });

  test('supports `// ignore_for_file: type=lint`', () async {
    final plugin = createPlugin(
      name: 'test_lint',
      main: source,
    );

    final app = creatLintUsage(
      source: {
        'lib/main.dart': '''
// ignore_for_file: type=lint, some comment

void fn() {}

// ignore: hello_world
void fn2() {}

// ignore: foo
void fn3() {}
'''
      },
      plugins: {'test_lint': plugin.uri},
      name: 'test_app',
    );

    final runner = await startRunnerForApp(app);

    expect(runner.channel.lintsExcludingBuiltIn, emitsDone);

    // Closing so that previous error matchers relying on stream
    // closing can complete
    await runner.close();

    expect(plugin.log.existsSync(), false);
  });
}
