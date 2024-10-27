import 'dart:io';

import 'package:custom_lint_core/custom_lint_core.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'create_project.dart';
import 'goldens.dart';
import 'run_plugin.dart';

final fixlessPlugin = createPluginSource([
  TestLintRule(code: 'hello_world', message: 'Hello world'),
]);

final fixedPlugin = createPluginSource([
  TestLintRule(
    code: 'hello_world',
    message: 'Hello world',
    fixes: [TestLintFix(name: 'HelloWorldFix')],
  ),
]);

final noChangeFixPlugin = createPluginSource([
  TestLintRule(
    code: 'hello_world',
    message: 'Hello world',
    fixes: [
      TestLintFix(
        name: 'HelloWorldFix',
        nodeVisitor: '',
      ),
    ],
  ),
]);

final multiChangeFixPlugin = createPluginSource([
  TestLintRule(
    code: 'hello_world',
    message: 'Hello world',
    fixes: [
      TestLintFix(
        name: 'HelloWorldFix',
        nodeVisitor: r'''
      changeBuilder.addDartFileEdit(
        (builder) {
          builder.addSimpleReplacement(node.name.sourceRange, '${node.name}fixed');
        },
      );
      changeBuilder.addDartFileEdit(
        customPath: '${p.dirname(resolver.path)}/src/hello_world.dart',
        (builder) {
          builder.addSimpleReplacement(node.name.sourceRange, '${node.name}fixed');
        },
      );
''',
      ),
    ],
  ),
]);

const ignoreId = '<<ignore>>';

void main() {
  test('Can emit fixes', () async {
    final plugin = createPlugin(
      name: 'test_lint',
      main: fixedPlugin,
    );

    const mainSource = '''
void fn() {}

void fn2() {}
''';
    final app = createLintUsage(
      source: {
        'lib/main.dart': mainSource,
      },
      plugins: {'test_lint': plugin.uri},
      name: 'test_app',
    );
    final mainPath = p.join(app.path, 'lib', 'main.dart');

    final runner = await startRunnerForApp(app);
    await runner.channel.lints.first;

    final fixes = runner.getFixes(mainPath, 6);
    final fixes2 = runner.getFixes(mainPath, 20);

    expectMatchesGoldenFixes(
      [await fixes, await fixes2]
          .expand((e) => e.fixes)
          .expand((e) => e.fixes)
          .where((e) => e.change.id != ignoreId),
      sources: ({'**/*': mainSource}, relativePath: app.path),
      file: Directory.current.file(
        'test',
        'goldens',
        'fixes',
        'fixes.diff',
      ),
    );
  });

  test('Fix-all is not present if a lint only has a single issue', () async {
    final plugin = createPlugin(name: 'test_lint', main: fixedPlugin);

    const mainSource = '''
void fn() {}
''';
    final app = createLintUsage(
      source: {
        'lib/main.dart': mainSource,
      },
      plugins: {'test_lint': plugin.uri},
      name: 'test_app',
    );
    final mainPath = p.join(app.path, 'lib', 'main.dart');

    final runner = await startRunnerForApp(app);
    await runner.channel.lints.first;

    final fixes = await runner.getFixes(mainPath, 6);

    expectMatchesGoldenFixes(
      fixes.fixes.expand((e) => e.fixes).where((e) => e.change.id != ignoreId),
      sources: ({'**/*': mainSource}, relativePath: app.path),
      file: Directory.current.file(
        'test',
        'goldens',
        'fixes',
        'single_fix.diff',
      ),
    );
  });

  test('Fix-all does not apply to silenced lints', () async {
    final plugin = createPlugin(name: 'test_lint', main: fixedPlugin);

    const mainSource = '''
void fn() {}

void fn2() {}

// ignore: hello_world
void fn3() {}

// expect_lint: hello_world
void fn4() {}
''';
    final app = createLintUsage(
      source: {
        'lib/main.dart': mainSource,
      },
      plugins: {'test_lint': plugin.uri},
      name: 'test_app',
    );
    final mainPath = p.join(app.path, 'lib', 'main.dart');

    final runner = await startRunnerForApp(app);
    await runner.channel.lints.first;

    final fixes = await runner.getFixes(mainPath, 6);

    expectMatchesGoldenFixes(
      fixes.fixes.expand((e) => e.fixes).where((e) => e.change.id != ignoreId),
      sources: ({'**/*': mainSource}, relativePath: app.path),
      file: Directory.current.file(
        'test',
        'goldens',
        'fixes',
        'silenced_change.diff',
      ),
    );
  });

  test('Supports fixes with no changes', () async {
    final plugin = createPlugin(name: 'test_lint', main: noChangeFixPlugin);

    const mainSource = '''
void fn() {}

void fn2() {}
''';
    final app = createLintUsage(
      source: {
        'lib/main.dart': mainSource,
      },
      plugins: {'test_lint': plugin.uri},
      name: 'test_app',
    );
    final mainPath = p.join(app.path, 'lib', 'main.dart');

    final runner = await startRunnerForApp(app);
    await runner.channel.lints.first;

    final fixes = runner.getFixes(mainPath, 6);
    final fixes2 = runner.getFixes(mainPath, 20);

    expectMatchesGoldenFixes(
      [await fixes, await fixes2]
          .expand((e) => e.fixes)
          .expand((e) => e.fixes)
          .where((e) => e.change.id != ignoreId),
      sources: ({'**/*': mainSource}, relativePath: app.path),
      file: Directory.current.file(
        'test',
        'goldens',
        'fixes',
        'no_change.diff',
      ),
    );
  });

  test('Supports fixes that emits multiple changes', () async {
    final plugin = createPlugin(name: 'test_lint', main: multiChangeFixPlugin);

    const mainSource = '''
void fn() {}

void fn2() {}
''';
    final app = createLintUsage(
      source: {
        'lib/main.dart': mainSource,
      },
      plugins: {'test_lint': plugin.uri},
      name: 'test_app',
    );
    final mainPath = p.join(app.path, 'lib', 'main.dart');

    final runner = await startRunnerForApp(app);
    await runner.channel.lints.first;

    final fixes = runner.getFixes(mainPath, 6);
    final fixes2 = runner.getFixes(mainPath, 20);

    expectMatchesGoldenFixes(
      [await fixes, await fixes2]
          .expand((e) => e.fixes)
          .expand((e) => e.fixes)
          .where((e) => e.change.id != ignoreId),
      sources: ({'**/*': mainSource}, relativePath: app.path),
      file: Directory.current.file(
        'test',
        'goldens',
        'fixes',
        'multi_change.diff',
      ),
    );
  });

  test('Can add new ignores', () async {
    final plugin = createPlugin(name: 'test_lint', main: fixlessPlugin);

    const mainSource = '''
void fn() {}

void fn2() {}

  void fn3() {}
''';
    final app = createLintUsage(
      source: {
        'lib/main.dart': mainSource,
      },
      plugins: {'test_lint': plugin.uri},
      name: 'test_app',
    );
    final mainPath = p.join(app.path, 'lib', 'main.dart');

    final runner = await startRunnerForApp(app);
    await runner.channel.lints.first;

    final fixes = runner.getFixes(mainPath, 6);
    final fixes2 = runner.getFixes(mainPath, 20);
    final fixes3 = runner.getFixes(mainPath, 37);

    expectMatchesGoldenFixes(
      [await fixes, await fixes2, await fixes3]
          .expand((e) => e.fixes)
          .expand((e) => e.fixes),
      sources: ({'**/*': mainSource}, relativePath: app.path),
      file: Directory.current.file(
        'test',
        'goldens',
        'fixes',
        'add_ignore.diff',
      ),
    );
  });

  test('Can update existing ignores', () async {
    final plugin = createPlugin(name: 'test_lint', main: fixlessPlugin);

    const mainSource = '''
// ignore: hello_world
void fn() {}

// ignore_for_file: foo
// ignore: foo
void fn2() {}
''';
    final app = createLintUsage(
      source: {
        'lib/main.dart': mainSource,
      },
      plugins: {'test_lint': plugin.uri},
      name: 'test_app',
    );
    final mainPath = p.join(app.path, 'lib', 'main.dart');

    final runner = await startRunnerForApp(app);
    await runner.channel.lints.first;

    final fixes = runner.getFixes(mainPath, 30);
    final fixes2 = runner.getFixes(mainPath, 84);

    expectMatchesGoldenFixes(
      [await fixes, await fixes2].expand((e) => e.fixes).expand((e) => e.fixes),
      sources: ({'**/*': mainSource}, relativePath: app.path),
      file: Directory.current.file(
        'test',
        'goldens',
        'fixes',
        'update_ignore.diff',
      ),
    );
  });
}
