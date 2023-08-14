import 'dart:io';

import 'package:analyzer/error/error.dart';
import 'package:test/test.dart';

import '../bin/custom_lint.dart' as cli;
import 'create_project.dart';
import 'equals_ignoring_ansi.dart';
import 'mock_fs.dart';

final oyPluginSource = createPluginSource([
  TestLintRule(
    code: 'oy',
    message: 'Oy',
  ),
]);

final helloWordPluginSource = createPluginSource([
  TestLintRule(
    code: 'hello_world',
    message: 'Hello world',
  ),
]);

void main() {
  test('exits with 0 when no lint and no error are found', () async {
    final plugin = createPlugin(name: 'test_lint', main: emptyPluginSource);

    final app = createLintUsage(
      source: {'lib/main.dart': 'void fn() {}'},
      plugins: {'test_lint': plugin.uri},
      name: 'test_app',
    );

    await runWithIOOverride(
      (out, err) async {
        await cli.entrypoint();

        expect(exitCode, 0);
        expect(
          out.join(),
          completion('''
No issues found!
'''),
        );
        expect(err, emitsDone);
      },
      currentDirectory: app,
    );
  });

  test('exits with 1 if only an error but no lint are found', () async {
    final plugin = createPlugin(name: 'test_lint', main: 'invalid;');

    final app = createLintUsage(
      source: {'lib/main.dart': 'void fn() {}'},
      plugins: {'test_lint': plugin.uri},
      name: 'test_app',
    );

    await runWithIOOverride(
      (out, err) async {
        await cli.entrypoint();

        expect(exitCode, 1);
        expect(
          err.join(),
          completion(
            allOf([
              matchIgnoringAnsi(contains, '''
/lib/test_lint.dart:1:1: Error: Variables must be declared using the keywords 'const', 'final', 'var' or a type name.
Try adding the name of the type of the variable or the keyword 'var'.
invalid;
^^^^^^^
'''),
              matchIgnoringAnsi(contains, '''
lib/custom_lint_client.dart:13:29: Error: Undefined name 'createPlugin'.
    {'test_lint': test_lint.createPlugin,
                            ^^^^^^^^^^^^
'''),
            ]),
          ),
        );
        expect(out, emitsDone);
      },
      currentDirectory: app,
    );
  });

  test('exits with 0 when pass argument `--no-fatal-infos`', () async {
    final plugin = createPlugin(name: 'test_lint', main: helloWordPluginSource);

    final app = createLintUsage(
      source: {'lib/main.dart': 'void fn() {}'},
      plugins: {'test_lint': plugin.uri},
      name: 'test_app',
    );

    await runWithIOOverride(
      (out, err) async {
        await cli.entrypoint(['--no-fatal-infos']);

        expect(exitCode, 0);
        expect(
          out.join(),
          completion(
            matchIgnoringAnsi(contains, '''
lib/main.dart:1:6 • Hello world • hello_world • INFO
'''),
          ),
        );
        expect(err, emitsDone);
      },
      currentDirectory: app,
    );
  });

  test(
      'exits with 0 when found warning and pass argument `--no-fatal-warnings`',
      () async {
    final plugin = createPlugin(
      name: 'test_lint',
      main: createPluginSource([
        TestLintRule(
          code: 'hello_world',
          message: 'Hello world',
          errorSeverity: ErrorSeverity.WARNING,
        ),
      ]),
    );

    final app = createLintUsage(
      source: {'lib/main.dart': 'void fn() {}'},
      plugins: {'test_lint': plugin.uri},
      name: 'test_app',
    );

    await runWithIOOverride(
      (out, err) async {
        await cli.entrypoint(['--no-fatal-warnings']);

        expect(exitCode, 0);
        expect(
          out.join(),
          completion(
            matchIgnoringAnsi(contains, '''
lib/main.dart:1:6 • Hello world • hello_world • WARNING
'''),
          ),
        );
        expect(err, emitsDone);
      },
      currentDirectory: app,
    );
  });

  test('CLI lists warnings from all plugins and set exit code', () async {
    final plugin = createPlugin(name: 'test_lint', main: helloWordPluginSource);
    final plugin2 = createPlugin(name: 'test_lint2', main: oyPluginSource);

    final app = createLintUsage(
      source: {
        'lib/main.dart': 'void fn() {}',
        'lib/another.dart': 'void fail() {}',
      },
      plugins: {'test_lint': plugin.uri, 'test_lint2': plugin2.uri},
      name: 'test_app',
    );

    await runWithIOOverride(
      (out, err) async {
        await cli.entrypoint();

        expect(err, emitsDone);
        expect(
          out.join(),
          completion('''
  lib/another.dart:1:6 • Hello world • hello_world • INFO
  lib/another.dart:1:6 • Oy • oy • INFO
  lib/main.dart:1:6 • Hello world • hello_world • INFO
  lib/main.dart:1:6 • Oy • oy • INFO
'''),
        );
        expect(exitCode, 1);
      },
      currentDirectory: app,
    );
  });

  test('supports plugins that do not compile', () async {
    final plugin = createPlugin(name: 'test_lint', main: helloWordPluginSource);
    final plugin2 = createPlugin(
      name: 'test_lint2',
      main: "int x = 'oy';",
    );

    final app = createLintUsage(
      source: {
        'lib/main.dart': 'void fn() {}',
        'lib/another.dart': 'void fail() {}',
      },
      plugins: {'test_lint': plugin.uri, 'test_lint2': plugin2.uri},
      name: 'test_app',
    );

    await runWithIOOverride(
      (out, err) async {
        await cli.entrypoint();

        expect(exitCode, 1);
        expect(
          err.join(),
          completion(
            allOf([
              matchIgnoringAnsi(contains, '''
/lib/test_lint2.dart:1:9: Error: A value of type 'String' can't be assigned to a variable of type 'int'.
int x = 'oy';
        ^
'''),
              matchIgnoringAnsi(contains, '''
lib/custom_lint_client.dart:15:26: Error: Undefined name 'createPlugin'.
'test_lint2': test_lint2.createPlugin,
                         ^^^^^^^^^^^^
'''),
            ]),
          ),
        );
        expect(out.join(), completion(isEmpty));
      },
      currentDirectory: app,
    );
  });

  test('Shows prints and exceptions', () async {
    final plugin = createPlugin(
      name: 'test_lint',
      main: createPluginSource([
        TestLintRule(
          code: 'hello_world',
          message: 'Hello world',
          onVariable: r'''
    if (node.name.lexeme == 'fail') {
      print('');
      print(' ');
       print('Hello\nworld');
       throw StateError('fail');
    }
''',
        ),
      ]),
    );

    final plugin2 = createPlugin(name: 'test_lint2', main: oyPluginSource);

    final app = createLintUsage(
      source: {
        'lib/main.dart': 'void fn() {}',
        'lib/another.dart': 'void fail() {}',
      },
      plugins: {'test_lint': plugin.uri, 'test_lint2': plugin2.uri},
      name: 'test_app',
    );

    await runWithIOOverride(
      (out, err) async {
        await cli.entrypoint();

        expect(exitCode, 1);
        expect(
          out.join(),
          completion(
            allOf(
              contains('''
[hello_world]
[hello_world]  
[hello_world] Hello
[hello_world] world
'''),
              endsWith(
                '''
  lib/another.dart:1:6 • Oy • oy • INFO
  lib/main.dart:1:6 • Hello world • hello_world • INFO
  lib/main.dart:1:6 • Oy • oy • INFO
''',
              ),
            ),
          ),
        );
        expect(
          err.join(),
          completion(
            contains('''
Plugin hello_world threw while analyzing ${app.path}/lib/another.dart:
Bad state: fail
#0      hello_world.run.<anonymous closure> (package:test_lint/test_lint.dart:'''),
          ),
        );
      },
      currentDirectory: app,
    );
  });

  test('Sorts lints by line then column the code', () async {
    final plugin = createPlugin(
      name: 'test_lint',
      main: '''
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

PluginBase createPlugin() => _HelloWorldLint();

class _HelloWorldLint extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => const [_Lint()];
}

class _Lint extends DartLintRule {
  const _Lint() : super(code: const LintCode(name: 'a', problemMessage: 'a'));

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    final line2 = resolver.lineInfo.getOffsetOfLine(1);
    reporter.reportErrorForOffset(
      const LintCode(name: 'x2', problemMessage: 'x2'),
      line2 + 1,
      1,
    );
    reporter.reportErrorForOffset(
      const LintCode(name: 'a', problemMessage: 'a'),
      line2 + 1,
      1,
    );
    reporter.reportErrorForOffset(
      const LintCode(name: 'x', problemMessage: 'x'),
      line2 + 1,
      1,
    );
    reporter.reportErrorForOffset(
      const LintCode(name: 'y', problemMessage: 'y'),
      line2,
      1,
    );
    reporter.reportErrorForOffset(
      const LintCode(name: 'z', problemMessage: 'z'),
      0,
      1,
    );
  }
}
''',
    );

    final app = createLintUsage(
      source: {
        'lib/main.dart': '''
void main() {
  print('hello world');
}''',
      },
      plugins: {'test_lint': plugin.uri},
      name: 'test_app',
    );

    await runWithIOOverride(
      (out, err) async {
        await cli.entrypoint();

        expect(exitCode, 1);
        expect(
          err.join(),
          completion(isEmpty),
        );

        expect(
          out.join(),
          completion(
            predicate((value) {
              expect(value, '''
  lib/main.dart:1:1 • z • z • INFO
  lib/main.dart:2:1 • y • y • INFO
  lib/main.dart:2:2 • a • a • INFO
  lib/main.dart:2:2 • x • x • INFO
  lib/main.dart:2:2 • x2 • x2 • INFO
''');
              return true;
            }),
          ),
        );
      },
      currentDirectory: app,
    );
  });
}
