import 'dart:convert';
import 'dart:io';

import 'package:custom_lint/src/package_utils.dart';
import 'package:test/test.dart';

import 'cli_process_test.dart';
import 'create_project.dart';
import 'peer_project_meta.dart';

void main() {
  group('Reports errors', () {
    test('inside LintRule.startUp', () {
      final plugin = createPlugin(
        name: 'test_lint',
        main: createPluginSource([
          TestLintRule(
            code: 'hello_world',
            message: 'Hello world',
            startUp: "throw StateError('hello');",
          ),
        ]),
      );

      final app = createLintUsage(
        name: 'test_app',
        plugins: {'test_lint': plugin.uri},
        source: {'lib/main.dart': 'void fn() {}'},
      );

      final process = Process.runSync(
        'dart',
        [customLintBinPath],
        workingDirectory: app.path,
        stdoutEncoding: utf8,
        stderrEncoding: utf8,
      );

      expect(
        trimDependencyOverridesWarning(process.stderr),
        startsWith('''
Plugin hello_world threw while analyzing ${app.file('lib', 'main.dart').resolveSymbolicLinksSync()}:
Bad state: hello
#0      hello_world.startUp (package:test_lint/test_lint.dart:'''),
      );
      expect(process.stdout, isEmpty);
      expect(process.exitCode, 1);
    });

    test('inside post-run callbacks', () {
      final plugin = createPlugin(
        name: 'test_lint',
        main: createPluginSource([
          TestLintRule(
            code: 'hello_world',
            message: 'Hello world',
            startUp: '''
              context.addPostRunCallback(() {
                throw StateError('hello');
              });
              context.addPostRunCallback(() {
                throw StateError('hello2');
              });
              return super.startUp(resolver, context);
            ''',
          ),
        ]),
      );

      final app = createLintUsage(
        name: 'test_app',
        plugins: {'test_lint': plugin.uri},
        source: {'lib/main.dart': 'void fn() {}'},
      );

      final process = Process.runSync(
        'dart',
        [customLintBinPath],
        workingDirectory: app.path,
        stdoutEncoding: utf8,
        stderrEncoding: utf8,
      );

      expect(
        trimDependencyOverridesWarning(process.stderr),
        allOf(
          contains(
            '''
Bad state: hello
#0      hello_world.startUp.<anonymous closure> (package:test_lint/test_lint.dart:''',
          ),
          contains(
            '''
Bad state: hello2
#0      hello_world.startUp.<anonymous closure> (package:test_lint/test_lint.dart:''',
          ),
        ),
      );
      expect(process.stdout, '''
Analyzing...

  lib/main.dart:1:6 • Hello world • hello_world • INFO

1 issue found.
''');
      expect(process.exitCode, 1);
    });
  });
}
