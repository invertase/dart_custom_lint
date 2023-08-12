import 'dart:io';

import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';
import 'package:async/async.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import 'create_project.dart';
import 'run_plugin.dart';

final source = createPluginSource([
  TestLintRule(
    code: 'hello_world',
    message: 'Hello world',
    onVariable: 'if (node.name.lexeme == "ignore") return;',
  ),
  TestLintRule(
    code: 'foo',
    message: 'Foo',
    onVariable: 'if (node.name.lexeme == "ignore") return;',
  ),
]);

void main() {
  test('supports `// expect_lint: code`', () async {
    final plugin = createPlugin(
      name: 'test_lint',
      main: source,
    );

    final app = createLintUsage(
      source: {
        'lib/empty.dart': '''
// a file with no lint in it

// expect_lint: some_lint
void ignore() {}
''',
        'lib/main.dart': '''
void fn() {}

// expect_lint: hello_world, foo, unknown
void fn2() {}

// expect_lint: hello_world
void fn3() {}
''',
      },
      plugins: {'test_lint': plugin.uri},
      name: 'test_app',
    );

    final runner = await startRunnerForApp(app);
    final lints = await runner.getLints(reload: false).then((lints) {
      final result = <String, AnalysisErrorsParams>{};
      for (final lint in lints) {
        final key = path.basename(lint.file);
        expect(result[key], isNull);
        result[key] = lint;
      }
      return result;
    });

    expect(lints.length, 2);

    expect(
      lints['main.dart'],
      predicate<AnalysisErrorsParams>((value) {
        expect(value.file, path.join(app.path, 'lib', 'main.dart'));
        expect(value.errors.length, 4);

        expect(value.errors.first.code, 'hello_world');
        expect(
          value.errors.first.location,
          Location(value.file, 5, 2, 1, 6, endColumn: 8, endLine: 1),
        );

        expect(value.errors[1].code, 'foo');
        expect(
          value.errors[1].location,
          Location(value.file, 5, 2, 1, 6, endColumn: 8, endLine: 1),
        );

        expect(value.errors[2].code, 'foo');
        expect(
          value.errors[2].location,
          Location(value.file, 104, 3, 7, 6, endColumn: 9, endLine: 7),
        );

        expect(value.errors[3].code, 'unfulfilled_expect_lint');
        expect(
          value.errors[3].message,
          'Expected to find the lint unknown on next line but none found.',
        );
        expect(
          value.errors[3].location,
          Location(value.file, 48, 7, 3, 35, endColumn: 42, endLine: 3),
        );

        return true;
      }),
    );

    expect(
      lints['empty.dart'],
      predicate<AnalysisErrorsParams>((value) {
        expect(value.file, path.join(app.path, 'lib', 'empty.dart'));
        expect(value.errors.length, 1);

        expect(value.errors[0].code, 'unfulfilled_expect_lint');
        expect(
          value.errors[0].message,
          'Expected to find the lint some_lint on next line but none found.',
        );
        expect(
          value.errors[0].location,
          Location(value.file, 46, 9, 3, 17, endColumn: 26, endLine: 3),
        );

        return true;
      }),
    );

    // Closing so that previous error matchers relying on stream
    // closing can complete
    await runner.close();

    expect(plugin.log.existsSync(), false);
  });

  test('// expect_lint update when the source code changes', () async {
    final plugin = createPlugin(
      name: 'test_lint',
      main: source,
    );

    final app = createLintUsage(
      source: {
        'lib/empty.dart': '''
// expect_lint: some_lint
void ignore() {}
''',
      },
      plugins: {'test_lint': plugin.uri},
      name: 'test_app',
    );

    final runner = await startRunnerForApp(app);
    final lints = StreamQueue(runner.channel.lints);

    expect(
      await lints.next,
      predicate<AnalysisErrorsParams>((value) {
        expect(value.file, path.join(app.path, 'lib', 'empty.dart'));
        expect(value.errors.length, 1);

        expect(value.errors[0].code, 'unfulfilled_expect_lint');
        expect(
          value.errors[0].message,
          'Expected to find the lint some_lint on next line but none found.',
        );
        expect(
          value.errors[0].location,
          Location(value.file, 16, 9, 1, 17, endColumn: 26, endLine: 1),
        );

        return true;
      }),
    );

    final sourceFile = File(path.join(app.path, 'lib', 'empty.dart'));

    sourceFile.writeAsStringSync('''
// Let's push the expect_lint a bit further down the file

// expect_lint: some_lint
void ignore() {}
''');
    await runner.channel.sendRequest(
      AnalysisHandleWatchEventsParams([
        WatchEvent(WatchEventType.MODIFY, sourceFile.path),
      ]),
    );

    expect(
      await lints.next,
      predicate<AnalysisErrorsParams>((value) {
        expect(value.file, path.join(app.path, 'lib', 'empty.dart'));
        expect(value.errors.length, 1);

        expect(value.errors[0].code, 'unfulfilled_expect_lint');
        expect(
          value.errors[0].message,
          'Expected to find the lint some_lint on next line but none found.',
        );
        expect(
          value.errors[0].location,
          Location(value.file, 75, 9, 3, 17, endColumn: 26, endLine: 3),
        );

        return true;
      }),
    );

    expect(lints.rest, emitsDone);

    // Closing so that previous error matchers relying on stream
    // closing can complete
    await runner.close();

    expect(plugin.log.existsSync(), false);
  });
}
