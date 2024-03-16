import 'dart:io';

import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';
import 'package:custom_lint_core/custom_lint_core.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

import 'create_project.dart';
import 'goldens.dart';
import 'run_plugin.dart';

final source = createPluginSource([
  TestLintRule(
    code: 'hello_world',
    message: 'Hello world',
  ),
  TestLintRule(
    code: 'foo',
    message: 'Foo',
  ),
]);

void main() {
  test('Emits ignore/ignore_for_file quick-fixes', () async {
    final plugin = createPlugin(
      name: 'test_lint',
      main: source,
    );

    final app = createLintUsage(
      name: 'test_app',
      plugins: {'test_lint': plugin.uri},
      source: {
        'lib/main.dart': '''
void fn() {}
void fn2() {}
''',
      },
    );

    final runner = await startRunnerForApp(app);
    await runner.getLints(reload: false);
    final fixes = await runner
        .getFixes(app.file('lib', 'main.dart').path, 6)
        .then((e) => e.fixes);

    expect(fixes, hasLength(2));

    expect(fixes[0].fixes, hasLength(2));
    expect(fixes[0].error.code, 'hello_world');
    expect(
      fixes[0].fixes.map((e) => e.change.message),
      unorderedEquals(
        ['Ignore "hello_world" for line', 'Ignore "hello_world" for file'],
      ),
    );

    expect(fixes[1].fixes, hasLength(2));
    expect(fixes[1].error.code, 'foo');
    expect(
      fixes[1].fixes.map((e) => e.change.message),
      unorderedEquals(['Ignore "foo" for line', 'Ignore "foo" for file']),
    );

    expectMatchesGoldenFixes(
      fixes.expand((e) => e.fixes),
      file: Directory.current.file('test', 'goldens', 'ignore_quick_fix.json'),
    );
  });

  test('Emits indented ignore quick-fix', () async {
    final plugin = createPlugin(
      name: 'test_lint',
      main: source,
    );

    final app = createLintUsage(
      name: 'test_app',
      plugins: {'test_lint': plugin.uri},
      source: {
        'lib/main.dart': '''
    void fn() {}
''',
      },
    );

    final runner = await startRunnerForApp(app);
    await runner.getLints(reload: false);
    final fixes = await runner
        .getFixes(app.file('lib', 'main.dart').path, 10)
        .then((e) => e.fixes);

    expect(
      fixes[0].fixes[0].change.edits[0].edits[0].replacement,
      startsWith('${' ' * 4}// ignore: hello_world'),
    );
  });

  test('supports `// ignore: code`', () async {
    final plugin = createPlugin(
      name: 'test_lint',
      main: source,
    );

    final app = createLintUsage(
      source: {
        'lib/main.dart': '''
void fn() {}

// ignore: hello_world, This is some comment foo
void fn2() {}

// ignore: foo, hello_world
void fn3() {}

// ignore: type=lint, some comment
void fn3() {}
''',
      },
      plugins: {'test_lint': plugin.uri},
      name: 'test_app',
    );

    final runner = await startRunnerForApp(app);

    expect(
      await runner.channel.lints.first,
      predicate<AnalysisErrorsParams>((value) {
        expect(value.file, join(app.path, 'lib', 'main.dart'));
        expect(value.errors.length, 3);

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
          Location(value.file, 68, 3, 4, 6, endColumn: 9, endLine: 4),
        );
        return true;
      }),
    );

    expect(runner.channel.lints, emitsDone);

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

    final app = createLintUsage(
      source: {
        'lib/main.dart': '''
// ignore_for_file: foo, some comment

void fn() {}

// ignore: hello_world
void fn2() {}

// ignore: foo
void fn3() {}
''',
      },
      plugins: {'test_lint': plugin.uri},
      name: 'test_app',
    );

    final runner = await startRunnerForApp(app);

    expect(
      await runner.channel.lints.first,
      predicate<AnalysisErrorsParams>((value) {
        expect(value.file, join(app.path, 'lib', 'main.dart'));
        expect(value.errors.length, 2);

        expect(value.errors.first.code, 'hello_world');
        expect(
          value.errors.first.location,
          Location(value.file, 44, 2, 3, 6, endColumn: 8, endLine: 3),
        );

        expect(value.errors[1].code, 'hello_world');
        expect(
          value.errors[1].location,
          Location(value.file, 111, 3, 9, 6, endColumn: 9, endLine: 9),
        );
        return true;
      }),
    );

    expect(runner.channel.lints, emitsDone);

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

    final app = createLintUsage(
      source: {
        'lib/main.dart': '''
// ignore_for_file: type=lint, some comment

void fn() {}

// ignore: hello_world
void fn2() {}

// ignore: foo
void fn3() {}
''',
      },
      plugins: {'test_lint': plugin.uri},
      name: 'test_app',
    );

    final runner = await startRunnerForApp(app);
    await runner.initialize;

    expect(runner.channel.lints, emitsDone);

    // Closing so that previous error matchers relying on stream
    // closing can complete
    await runner.close();

    expect(plugin.log.existsSync(), false);
  });
}
