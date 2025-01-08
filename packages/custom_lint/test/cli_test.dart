import 'dart:convert';
import 'dart:io';

import 'package:analyzer/error/error.dart'
    hide
        // ignore: undefined_hidden_name, Needed to support lower analyzer versions
        LintCode;
import 'package:custom_lint/src/output/output_format.dart';
import 'package:test/test.dart';

import 'create_project.dart';
import 'equals_ignoring_ansi.dart';
import 'peer_project_meta.dart';

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

String jsonLints(String dir) {
  return jsonEncode({
    'version': 1,
    'diagnostics': [
      {
        'code': 'hello_world',
        'severity': 'INFO',
        'type': 'LINT',
        'location': {
          'file': '$dir/lib/another.dart',
          'range': {
            'start': {
              'offset': 5,
              'line': 1,
              'column': 6,
            },
            'end': {
              'offset': 9,
              'line': 1,
              'column': 10,
            },
          },
        },
        'problemMessage': 'Hello world',
      },
      {
        'code': 'oy',
        'severity': 'INFO',
        'type': 'LINT',
        'location': {
          'file': '$dir/lib/another.dart',
          'range': {
            'start': {
              'offset': 5,
              'line': 1,
              'column': 6,
            },
            'end': {
              'offset': 9,
              'line': 1,
              'column': 10,
            },
          },
        },
        'problemMessage': 'Oy',
      },
      {
        'code': 'hello_world',
        'severity': 'INFO',
        'type': 'LINT',
        'location': {
          'file': '$dir/lib/main.dart',
          'range': {
            'start': {
              'offset': 5,
              'line': 1,
              'column': 6,
            },
            'end': {
              'offset': 7,
              'line': 1,
              'column': 8,
            },
          },
        },
        'problemMessage': 'Hello world',
      },
      {
        'code': 'oy',
        'severity': 'INFO',
        'type': 'LINT',
        'location': {
          'file': '$dir/lib/main.dart',
          'range': {
            'start': {
              'offset': 5,
              'line': 1,
              'column': 6,
            },
            'end': {
              'offset': 7,
              'line': 1,
              'column': 8,
            },
          },
        },
        'problemMessage': 'Oy',
      }
    ],
  });
}

void main() {
  // Run 2 tests, one with ANSI escapes and one without
  // One test has no lints, the other has some, this should be enough.
  for (final ansi in [true, false]) {
    for (final format in OutputFormatEnum.values.map((e) => e.name)) {
      group('With ANSI: $ansi and format: $format', () {
        test('exits with 0 when no lint and no error are found', () async {
          final plugin = createPlugin(
            name: 'test_lint',
            main: emptyPluginSource,
          );

          final app = createLintUsage(
            source: {'lib/main.dart': 'void fn() {}'},
            plugins: {'test_lint': plugin.uri},
            name: 'test_app',
          );

          final process = Process.runSync(
            'dart',
            [
              customLintBinPath,
              '--format',
              format,
            ],
            workingDirectory: app.path,
            stderrEncoding: utf8,
            stdoutEncoding: utf8,
          );

          if (format == 'json') {
            expect(process.stdout, '''
{"version":1,"diagnostics":[]}
''');
          } else {
            expect(
              process.stdout,
              '''
Analyzing...

No issues found!
''',
            );
          }

          expect(process.stderr, isEmpty);
          expect(process.exitCode, 0);
        });

        for (final installAsDevDependency in [false, true]) {
          test(
              'CLI lists warnings from all plugins and set exit code installAsDevDependency: $installAsDevDependency',
              () async {
            final plugin =
                createPlugin(name: 'test_lint', main: helloWordPluginSource);
            final plugin2 =
                createPlugin(name: 'test_lint2', main: oyPluginSource);

            final app = createLintUsage(
              source: {
                'lib/main.dart': 'void fn() {}',
                'lib/another.dart': 'void fail() {}',
              },
              plugins: {'test_lint': plugin.uri, 'test_lint2': plugin2.uri},
              name: 'test_app',
              installAsDevDependency: installAsDevDependency,
            );

            final process = await Process.start(
              'dart',
              [
                customLintBinPath,
                '--format',
                format,
              ],
              workingDirectory: app.path,
            );

            final out = process.stdout.map(utf8.decode);
            final err = process.stderr.map(utf8.decode);

            expect(err, emitsDone);

            if (format == 'json') {
              expect(
                out.join(),
                completion(
                  equals('${jsonLints(app.resolveSymbolicLinksSync())}\n'),
                ),
              );
            } else {
              expect(
                out.join(),
                completion(
                  allOf(
                    startsWith('Analyzing...'),
                    endsWith('''
  lib/another.dart:1:6 • Hello world • hello_world • INFO
  lib/another.dart:1:6 • Oy • oy • INFO
  lib/main.dart:1:6 • Hello world • hello_world • INFO
  lib/main.dart:1:6 • Oy • oy • INFO

4 issues found.
'''),
                  ),
                ),
              );
            }
            expect(await process.exitCode, 1);
          });
        }
      });
    }
  }

  test('exits with 1 if only an error but no lint are found', () async {
    final plugin = createPlugin(name: 'test_lint', main: 'invalid;');

    final app = createLintUsage(
      source: {'lib/main.dart': 'void fn() {}'},
      plugins: {'test_lint': plugin.uri},
      name: 'test_app',
    );

    final process = await Process.start(
      'dart',
      [customLintBinPath],
      workingDirectory: app.path,
    );

    final out = process.stdout.map(utf8.decode);
    final err = process.stderr.map(utf8.decode);

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
lib/custom_lint_client.dart:16:29: Error: Undefined name 'createPlugin'.
    {'test_lint': test_lint.createPlugin,
                            ^^^^^^^^^^^^
'''),
        ]),
      ),
    );
    expect(out, emitsDone);
    expect(await process.exitCode, 1);
  });

  test('exits with 0 when pass argument `--no-fatal-infos`', () async {
    final plugin = createPlugin(name: 'test_lint', main: helloWordPluginSource);

    final app = createLintUsage(
      source: {'lib/main.dart': 'void fn() {}'},
      plugins: {'test_lint': plugin.uri},
      name: 'test_app',
    );

    final process = await Process.start(
      'dart',
      [customLintBinPath, '--no-fatal-infos'],
      workingDirectory: app.path,
    );
    final out = process.stdout.map(utf8.decode);
    final err = process.stderr.map(utf8.decode);

    expect(
      out.join(),
      completion(
        matchIgnoringAnsi(contains, '''
Analyzing...

  lib/main.dart:1:6 • Hello world • hello_world • INFO

1 issue found.
'''),
      ),
    );
    expect(err, emitsDone);
    expect(await process.exitCode, 0);
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

    final process = await Process.start(
      'dart',
      [customLintBinPath, '--no-fatal-warnings'],
      workingDirectory: app.path,
    );
    final out = process.stdout.map(utf8.decode);
    final err = process.stderr.map(utf8.decode);

    expect(
      out.join(),
      completion(
        matchIgnoringAnsi(contains, '''
Analyzing...

  lib/main.dart:1:6 • Hello world • hello_world • WARNING

1 issue found.
'''),
      ),
    );
    expect(err, emitsDone);
    expect(await process.exitCode, 0);
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

    final process = await Process.start(
      'dart',
      [customLintBinPath],
      workingDirectory: app.path,
    );
    final out = process.stdout.map(utf8.decode);
    final err = process.stderr.map(utf8.decode);

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
lib/custom_lint_client.dart:18:26: Error: Undefined name 'createPlugin'.
'test_lint2': test_lint2.createPlugin,
                         ^^^^^^^^^^^^
'''),
        ]),
      ),
    );
    expect(out.join(), completion(isEmpty));
    expect(await process.exitCode, 1);
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

    final process = await Process.start(
      'dart',
      [customLintBinPath],
      workingDirectory: app.path,
    );
    final out = process.stdout.map(utf8.decode);
    final err = process.stderr.map(utf8.decode);

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
Analyzing...

  lib/another.dart:1:6 • Oy • oy • INFO
  lib/main.dart:1:6 • Hello world • hello_world • INFO
  lib/main.dart:1:6 • Oy • oy • INFO

3 issues found.
''',
          ),
        ),
      ),
    );
    expect(
      err.join(),
      completion(
        contains('''
Plugin hello_world threw while analyzing ${app.resolveSymbolicLinksSync()}/lib/another.dart:
Bad state: fail
#0      hello_world.run.<anonymous closure> (package:test_lint/test_lint.dart:'''),
      ),
    );
    expect(await process.exitCode, 1);
  });

  test('Sorts lints by line then column the code', () async {
    final plugin = createPlugin(
      name: 'test_lint',
      main: '''
import 'package:analyzer/error/error.dart' hide LintCode;
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
    reporter.atOffset(
      errorCode: const LintCode(name: 'x2', problemMessage: 'x2'),
      offset: line2 + 1,
      length: 1,
    );
    reporter.atOffset(
      errorCode: const LintCode(name: 'a', problemMessage: 'a'),
      offset: line2 + 1,
      length: 1,
    );
    reporter.atOffset(
      errorCode: const LintCode(name: 'x', problemMessage: 'x'),
      offset: line2 + 1,
      length: 1,
    );
    reporter.atOffset(
      errorCode: const LintCode(name: 'y', problemMessage: 'y'),
      offset: line2,
      length: 1,
    );
    reporter.atOffset(
      errorCode: const LintCode(name: 'z', problemMessage: 'z'),
      offset: 0,
      length: 1,
    );
    reporter.atOffset(
      errorCode: const LintCode(name: 'w', problemMessage: 'w', errorSeverity: ErrorSeverity.WARNING),
      offset: 0,
      length: 1,
    );
    reporter.atOffset(
      errorCode: const LintCode(name: 'e', problemMessage: 'e', errorSeverity: ErrorSeverity.ERROR),
      offset: 0,
      length: 1,
    );
    reporter.atOffset(
      errorCode: const LintCode(name: 's', problemMessage: 's', errorSeverity: ErrorSeverity.ERROR),
      offset: 1,
      length: 2,
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
        'lib/other.dart': '''
void other() {
  print('hello other world');
}''',
      },
      plugins: {'test_lint': plugin.uri},
      name: 'test_app',
    );

    final process = await Process.start(
      'dart',
      [customLintBinPath],
      workingDirectory: app.path,
    );
    final out = process.stdout.map(utf8.decode);
    final err = process.stderr.map(utf8.decode);

    expect(
      err.join(),
      completion(isEmpty),
    );

    expect(
      out.join(),
      completion('''
Analyzing...

  lib/main.dart:1:1 • e • e • ERROR
  lib/main.dart:1:2 • s • s • ERROR
  lib/other.dart:1:1 • e • e • ERROR
  lib/other.dart:1:2 • s • s • ERROR
  lib/main.dart:1:1 • w • w • WARNING
  lib/other.dart:1:1 • w • w • WARNING
  lib/main.dart:1:1 • z • z • INFO
  lib/main.dart:2:1 • y • y • INFO
  lib/main.dart:2:2 • a • a • INFO
  lib/main.dart:2:2 • x • x • INFO
  lib/main.dart:2:2 • x2 • x2 • INFO
  lib/other.dart:1:1 • z • z • INFO
  lib/other.dart:2:1 • y • y • INFO
  lib/other.dart:2:2 • a • a • INFO
  lib/other.dart:2:2 • x • x • INFO
  lib/other.dart:2:2 • x2 • x2 • INFO

16 issues found.
'''),
    );
    expect(await process.exitCode, 1);
  });
}
