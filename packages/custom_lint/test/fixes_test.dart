import 'dart:io';

import 'package:custom_lint/src/package_utils.dart';
import 'package:path/path.dart';
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

void main() {
  test('Can emit fixes', () async {
    final plugin = createPlugin(name: 'test_lint', main: fixedPlugin);

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
    final mainPath = join(app.path, 'lib', 'main.dart');

    final runner = await startRunnerForApp(app);
    await runner.channel.lints.first;

    final fixes = runner.getFixes(mainPath, 6);
    final fixes2 = runner.getFixes(mainPath, 20);

    saveGoldensFixes(
      [await fixes, await fixes2]
          .expand((e) => e.fixes)
          .expand((e) => e.fixes)
          .where(
            (e) =>
                e.change.id != 'ignore_for_file' &&
                e.change.id != 'ignore_for_line',
          ),
      source: mainSource,
      file: Directory.current.file(
        'test',
        'goldens',
        'fixes',
        'fixes.diff',
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
    final mainPath = join(app.path, 'lib', 'main.dart');

    final runner = await startRunnerForApp(app);
    await runner.channel.lints.first;

    final fixes = runner.getFixes(mainPath, 6);
    final fixes2 = runner.getFixes(mainPath, 20);
    final fixes3 = runner.getFixes(mainPath, 37);

    saveGoldensFixes(
      [await fixes, await fixes2, await fixes3]
          .expand((e) => e.fixes)
          .expand((e) => e.fixes),
      source: mainSource,
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
    final mainPath = join(app.path, 'lib', 'main.dart');

    final runner = await startRunnerForApp(app);
    await runner.channel.lints.first;

    final fixes = runner.getFixes(mainPath, 30);
    final fixes2 = runner.getFixes(mainPath, 84);

    saveGoldensFixes(
      [await fixes, await fixes2].expand((e) => e.fixes).expand((e) => e.fixes),
      source: mainSource,
      file: Directory.current.file(
        'test',
        'goldens',
        'fixes',
        'update_ignore.diff',
      ),
    );
  });
}
