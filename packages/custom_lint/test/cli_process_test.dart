@Timeout.factor(2)
import 'dart:convert';
import 'dart:io';

import 'package:custom_lint/src/output/output_format.dart';
import 'package:custom_lint/src/package_utils.dart';
import 'package:test/test.dart';
import 'package:test_process/test_process.dart';

import 'cli_test.dart';
import 'create_project.dart';
import 'peer_project_meta.dart';
import 'src/workspace_test.dart';

String trimDependencyOverridesWarning(Object? input) {
  final string = input.toString();
  if (string
      .startsWith('Warning: You are using these overridden dependencies:')) {
    return string.split('\n').skip(3).join('\n');
  }
  return string;
}

void main() {
  test('Exposes the Pubspec in CustomLintContext', () async {
    final workspace = createTemporaryDirectory();

    final plugin = createPlugin(
      name: 'test_lint',
      main: createPluginSource([
        TestLintRule(
          code: 'hello_world',
          message: 'Hello world',
          onRun:
              r"print('${context.pubspec.name} ${context.pubspec.dependencies.keys}');",
        ),
      ]),
    );

    createLintUsage(
      parent: workspace,
      source: {'lib/main.dart': 'void fn() {}'},
      plugins: {'test_lint': plugin.uri},
      name: 'test_app',
    );
    createLintUsage(
      parent: workspace,
      source: {'lib/main2.dart': 'void fn() {}'},
      plugins: {'test_lint': plugin.uri},
      name: 'test_app2',
    );

    final process = Process.runSync(
      'dart',
      [customLintBinPath],
      workingDirectory: workspace.path,
      stdoutEncoding: utf8,
      stderrEncoding: utf8,
    );

    expect(trimDependencyOverridesWarning(process.stderr), isEmpty);
    expect(
      process.stdout,
      '''
[hello_world] test_app (analyzer, analyzer_plugin)
[hello_world] test_app2 (analyzer, analyzer_plugin)
Analyzing...

  test_app/lib/main.dart:1:6 • Hello world • hello_world • INFO
  test_app2/lib/main2.dart:1:6 • Hello world • hello_world • INFO

2 issues found.
''',
    );
    expect(process.exitCode, 1);
  });

  group('Correctly exits when', () {
    test('running on a workspace with no plugins', () {
      final app = createLintUsage(name: 'test_app');

      final process = Process.runSync(
        'dart',
        [customLintBinPath],
        workingDirectory: app.path,
        stdoutEncoding: utf8,
        stderrEncoding: utf8,
      );

      expect(trimDependencyOverridesWarning(process.stderr), isEmpty);
      expect(process.stdout, '''
Analyzing...

No issues found!
''');
      expect(process.exitCode, 0);
    });

    test('running on a workspace with no projects', () {
      final dir = createTemporaryDirectory();

      final process = Process.runSync(
        'dart',
        [customLintBinPath],
        workingDirectory: dir.path,
        stdoutEncoding: utf8,
        stderrEncoding: utf8,
      );

      expect(trimDependencyOverridesWarning(process.stderr), isEmpty);
      expect(process.stdout, '''
Analyzing...

No issues found!
''');
      expect(process.exitCode, 0);
    });

    test(
      'no issues found',
      () async {
        final plugin = createPlugin(name: 'test_lint', main: emptyPluginSource);

        final app = createLintUsage(
          name: 'test_app',
          source: {
            'lib/main.dart': 'void fn() {}',
            'lib/another.dart': 'void fail() {}',
          },
          plugins: {'test_lint': plugin.uri},
        );

        final process = await Process.run(
          'dart',
          [customLintBinPath],
          workingDirectory: app.path,
          stdoutEncoding: utf8,
          stderrEncoding: utf8,
        );

        expect(trimDependencyOverridesWarning(process.stderr), isEmpty);
        expect(process.stdout, '''
Analyzing...

No issues found!
''');
        expect(process.exitCode, 0);
      },
    );

    for (final format in OutputFormatEnum.values.map((e) => e.name)) {
      test(
        'found lints format: $format',
        () async {
          final plugin = createPlugin(name: 'test_lint', main: oyPluginSource);

          final app = createLintUsage(
            name: 'test_app',
            source: {
              'lib/main.dart': 'void fn() {}',
              'lib/another.dart': 'void fail() {}',
            },
            plugins: {'test_lint': plugin.uri},
          );

          final process = await Process.run(
            'dart',
            [
              customLintBinPath,
              '--format',
              format,
            ],
            workingDirectory: app.path,
          );

          expect(trimDependencyOverridesWarning(process.stderr), isEmpty);

          if (format == 'json') {
            final dir = Directory(app.path).resolveSymbolicLinksSync();
            final json = jsonEncode({
              'version': 1,
              'diagnostics': [
                {
                  'code': 'oy',
                  'severity': 'INFO',
                  'type': 'LINT',
                  'location': {
                    'file': '$dir/lib/another.dart',
                    'range': {
                      'start': {'offset': 5, 'line': 1, 'column': 6},
                      'end': {'offset': 9, 'line': 1, 'column': 10},
                    },
                  },
                  'problemMessage': 'Oy',
                },
                {
                  'code': 'oy',
                  'severity': 'INFO',
                  'type': 'LINT',
                  'location': {
                    'file': '$dir/lib/main.dart',
                    'range': {
                      'start': {'offset': 5, 'line': 1, 'column': 6},
                      'end': {'offset': 7, 'line': 1, 'column': 8},
                    },
                  },
                  'problemMessage': 'Oy',
                }
              ],
            });
            expect(process.stdout, 'Analyzing...\n\n$json\n');
          } else {
            expect(process.stdout, '''
Analyzing...

  lib/another.dart:1:6 • Oy • oy • INFO
  lib/main.dart:1:6 • Oy • oy • INFO

2 issues found.
''');
          }
          expect(process.exitCode, 1);
        },
      );
    }

    test(
      'missing package_config.json',
      () async {
        final plugin = createPlugin(name: 'test_lint', main: oyPluginSource);

        final app = createLintUsage(
          name: 'test_app',
          source: {
            'lib/main.dart': 'void fn() {}',
            'lib/another.dart': 'void fail() {}',
          },
          plugins: {'test_lint': plugin.uri},
        );

        // Create a child context root
        final innerContextRoot = createLintUsage(
          name: 'test_project_inner',
          source: {
            'lib/main.dart': 'void fn() {}',
            'lib/another.dart': 'void fail() {}',
          },
          parent: app,
        );

        // create error during initialization because of missing package_config.json
        final packageConfig = innerContextRoot.packageConfig;
        // Potentially resolve the file system link, temp folders are links on macOs into /private/var
        final missingPackageConfig =
            await innerContextRoot.resolveSymbolicLinks();
        packageConfig.deleteSync();

        final process = await Process.run(
          'dart',
          [customLintBinPath],
          workingDirectory: app.path,
        );

        expect(process.exitCode, isNot(0));
        expect(
          trimDependencyOverridesWarning(process.stderr),
          startsWith(
            'Failed to decode .dart_tool/package_config.json at $missingPackageConfig. '
            'Make sure to run `pub get` first.\n'
            'PathNotFoundException: Cannot open file, path =',
          ),
        );
        expect(process.stdout, isEmpty);
      },
    );

    test(
      'dependency conflict',
      () async {
        // Create two packages with the same name but different paths
        final workspace = await createSimpleWorkspace(['dep', 'dep']);

        final plugin = createPlugin(
          parent: workspace,
          name: 'test_lint',
          main: oyPluginSource,
          extraDependencies: {'dep': 'any'},
        );

        // We define two projects with different dependencies
        final app = createLintUsage(
          parent: workspace,
          name: 'test_app',
          source: {'lib/main.dart': 'void fn() {}'},
          plugins: {'test_lint': plugin.uri},
          extraPackageConfig: {'dep': workspace.dir('dep').uri},
        );

        createLintUsage(
          // Add the second project inside the first one, such that
          // analyzing the first project analyzes both projects
          parent: app,
          name: 'test_app2',
          source: {'lib/foo.dart': 'void fn() {}'},
          plugins: {'test_lint': plugin.uri},
          extraPackageConfig: {'dep': workspace.dir('dep2').uri},
        );

        final process = await Process.start(
          workingDirectory: app.path,
          'dart',
          [customLintBinPath],
        );

        expect(process.stdout, emitsDone);
        expect(
          await process.stderr
              .map(utf8.decode)
              .map(trimDependencyOverridesWarning)
              .join('\n'),
          startsWith(
            '''
The request analysis.setContextRoots failed with the following error:
RequestErrorCode.PLUGIN_ERROR
Exception: Failed to run "pub get" in the client project:
Resolving dependencies...

Because every version of test_lint from path depends on dep any which doesn't exist (could not find package dep at https://pub.dev), test_lint from path is forbidden.
So, because custom_lint_client depends on test_lint from path, version solving failed.
''',
          ),
        );
        expect(process.exitCode, completion(1));
      },
    );
  });

  group('Watch mode', () {
    group('[q] quits', () {
      test('with exit code 0 when no lints', () async {
        final workspace = createTemporaryDirectory();

        final process = await TestProcess.start(
          'dart',
          [
            customLintBinPath,
            '--watch',
          ],
          workingDirectory: workspace.path,
        );

        expect(await process.stdout.next, 'Analyzing...');
        await process.stdout.skip(1);
        expect(await process.stdout.next, 'No issues found!');

        await process.stdout.skip(3);
        expect(await process.stdout.next, 'q: Quit');

        process.stdin.write('q');

        await expectLater(process.stdout.rest, emitsThrough(emitsDone));
        await process.shouldExit(0);
      });

      test('with exit code 1 when there are lints', () async {
        final workspace = createTemporaryDirectory();

        final plugin = createPlugin(
          name: 'test_lint',
          main: createPluginSource([
            TestLintRule(
              code: 'hello_world',
              message: 'Hello world',
            ),
          ]),
        );

        createLintUsage(
          parent: workspace,
          source: {'lib/main.dart': 'void fn() {}'},
          plugins: {'test_lint': plugin.uri},
          name: 'test_app',
        );

        final process = await TestProcess.start(
          'dart',
          [
            customLintBinPath,
            '--watch',
          ],
          workingDirectory: workspace.path,
        );

        expect(
          await process.stdout.next,
          startsWith('The Dart VM service is listening on'),
        );
        expect(
          await process.stdout.next,
          startsWith('The Dart DevTools debugger and profiler is available at'),
        );
        expect(await process.stdout.next, 'Analyzing...');
        await process.stdout.skip(1);
        expect(
          await process.stdout.next,
          '  test_app/lib/main.dart:1:6 • Hello world • hello_world • INFO',
        );
        await process.stdout.skip(1);
        expect(await process.stdout.next, '1 issue found.');

        await process.stdout.skip(3);
        expect(await process.stdout.next, 'q: Quit');

        process.stdin.write('q');

        await expectLater(process.stdout.rest, emitsThrough(emitsDone));
        await process.shouldExit(1);
      });
    });

    group('[r] reloads', () {
      test('with no lints', () async {
        final workspace = createTemporaryDirectory();

        final process = await TestProcess.start(
          'dart',
          [
            customLintBinPath,
            '--watch',
          ],
          workingDirectory: workspace.path,
        );

        expect(await process.stdout.next, 'Analyzing...');
        await process.stdout.skip(1);
        expect(await process.stdout.next, 'No issues found!');

        await process.stdout.skip(3);
        expect(await process.stdout.next, 'q: Quit');

        process.stdin.write('r');

        // Skip empty lines
        await process.stdout.skip(2);
        expect(await process.stdout.next, 'Manual re-lint...');
        await process.stdout.skip(1);
        expect(await process.stdout.next, 'No issues found!');

        process.stdin.write('q');

        await process.shouldExit(0);
      });

      test('with lints', () async {
        final workspace = createTemporaryDirectory();

        final plugin = createPlugin(
          name: 'test_lint',
          main: createPluginSource([
            TestLintRule(
              code: 'hello_world',
              message: 'Hello world',
            ),
          ]),
        );

        createLintUsage(
          parent: workspace,
          source: {'lib/main.dart': 'void fn() {}'},
          plugins: {'test_lint': plugin.uri},
          name: 'test_app',
        );

        final process = await TestProcess.start(
          'dart',
          [
            customLintBinPath,
            '--watch',
          ],
          workingDirectory: workspace.path,
        );

        expect(
          await process.stdout.next,
          startsWith('The Dart VM service is listening on'),
        );
        expect(
          await process.stdout.next,
          startsWith('The Dart DevTools debugger and profiler is available at'),
        );
        expect(await process.stdout.next, 'Analyzing...');
        await process.stdout.skip(1);
        expect(
          await process.stdout.next,
          '  test_app/lib/main.dart:1:6 • Hello world • hello_world • INFO',
        );
        await process.stdout.skip(1);
        expect(await process.stdout.next, '1 issue found.');
        await process.stdout.skip(3);
        expect(await process.stdout.next, 'q: Quit');

        process.stdin.write('r');

        // Skip empty lines
        await process.stdout.skip(2);
        expect(await process.stdout.next, 'Manual re-lint...');
        await process.stdout.skip(1);
        expect(
          await process.stdout.next,
          '  test_app/lib/main.dart:1:6 • Hello world • hello_world • INFO',
        );
        await process.stdout.skip(1);
        expect(await process.stdout.next, '1 issue found.');

        process.stdin.write('q');

        await process.shouldExit(1);
      });
    });
  });
}
