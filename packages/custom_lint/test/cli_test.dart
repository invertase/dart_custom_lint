import 'dart:io';

import 'package:test/test.dart';

import '../bin/custom_lint.dart' as cli;
import 'create_project.dart';
import 'equals_ignoring_ansi.dart';
import 'mock_fs.dart';

const oyPluginSource = '''
import 'dart:isolate';
import 'package:analyzer/dart/element/element.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:analyzer/dart/analysis/results.dart';

void main(List<String> args, SendPort sendPort) {
  startPlugin(sendPort, _AnotherLint());
}

class _AnotherLint extends PluginBase {
  @override
  Stream<Lint> getLints(ResolvedUnitResult resolvedUnitResult) async* {
    final library = resolvedUnitResult.libraryElement;
    yield Lint(
      code: 'oy',
      message: 'Oy',
      location: resolvedUnitResult.lintLocationFromOffset(
        library.topLevelElements.first.nameOffset,
        length: library.topLevelElements.first.nameLength,
      ),
    );
  }
}
''';

const helloWordPluginSource = '''
import 'dart:isolate';
import 'package:analyzer/dart/element/element.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:analyzer/dart/analysis/results.dart';

void main(List<String> args, SendPort sendPort) {
  startPlugin(sendPort, _HelloWorldLint());
}

class _HelloWorldLint extends PluginBase {
  @override
  Stream<Lint> getLints(ResolvedUnitResult resolvedUnitResult) async* {
    final library = resolvedUnitResult.libraryElement;
    yield Lint(
      code: 'hello_world',
      message: 'Hello world',
      location: resolvedUnitResult.lintLocationFromOffset(
        library.topLevelElements.first.nameOffset,
        length: library.topLevelElements.first.nameLength,
      ),
    );
  }
}
''';

void main() {
  test('exits with 0 when no lint and no error are found', () async {
    final plugin = createPlugin(
      name: 'test_lint',
      main: '''
import 'dart:isolate';
import 'package:analyzer/dart/element/element.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:analyzer/dart/analysis/results.dart';

void main(List<String> args, SendPort sendPort) {
  startPlugin(sendPort, _AnotherLint());
}

class _AnotherLint extends PluginBase {
  @override
  Stream<Lint> getLints(ResolvedUnitResult resolvedUnitResult) async* {}
}
''',
    );

    final app = createLintUsage(
      source: {'lib/main.dart': 'void fn() {}'},
      plugins: {'test_lint': plugin.uri},
      name: 'test_app',
    );

    await runWithIOOverride(
      (out, err) async {
        await cli.main();

        expect(exitCode, 0);
        expect(out.join(), completion('''
No issues found!
'''));
        expect(err, emitsDone);
      },
      currentDirectory: app,
    );
  });

  test('exits with -1 if only an error but no lint are found', () async {
    final plugin = createPlugin(name: 'test_lint', main: 'invalid;');

    final app = createLintUsage(
      source: {'lib/main.dart': 'void fn() {}'},
      plugins: {'test_lint': plugin.uri},
      name: 'test_app',
    );

    await runWithIOOverride(
      (out, err) async {
        await cli.main();

        expect(exitCode, -1);
        expect(err.join(), completion(equalsIgnoringAnsi('''
IsolateSpawnException: Unable to spawn isolate: ${plugin.path}/bin/custom_lint.dart:1:1: Error: Variables must be declared using the keywords 'const', 'final', 'var' or a type name.
Try adding the name of the type of the variable or the keyword 'var'.
invalid;
^^^^^^^

''')));
        expect(out, emitsDone);
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
        await cli.main();

        expect(exitCode, -1);
        expect(out.join(), completion('''
  lib/another.dart:1:6 • Hello world • hello_world
  lib/another.dart:1:6 • Oy • oy
  lib/main.dart:1:6 • Hello world • hello_world
  lib/main.dart:1:6 • Oy • oy
'''));
        expect(err, emitsDone);
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
        await cli.main();

        expect(exitCode, -1);
        expect(
          err.join(),
          completion(
            equalsIgnoringAnsi(
              '''
IsolateSpawnException: Unable to spawn isolate: ${plugin2.path}/bin/custom_lint.dart:1:9: Error: A value of type 'String' can't be assigned to a variable of type 'int'.
int x = 'oy';
        ^

''',
            ),
          ),
        );
        expect(out.join(), completion('''
  lib/another.dart:1:6 • Hello world • hello_world
  lib/main.dart:1:6 • Hello world • hello_world
'''));
      },
      currentDirectory: app,
    );
  });

  test('Shows prints and exceptions', () async {
    final plugin = createPlugin(
      name: 'test_lint',
      main: r'''
import 'dart:isolate';
import 'package:analyzer/dart/element/element.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:analyzer/dart/analysis/results.dart';

void main(List<String> args, SendPort sendPort) {
  startPlugin(sendPort, _HelloWorldLint());
}

class _HelloWorldLint extends PluginBase {
  @override
  Stream<Lint> getLints(ResolvedUnitResult resolvedUnitResult) async* {
    final library = resolvedUnitResult.libraryElement;
    print('Oy');
    if (library.topLevelElements.single.name == 'fail') {
      print('');
      print(' ');
       print('Hello\nworld');
       throw StateError('fail');
    }
    yield Lint(
      message: 'Hello world',
      code: 'hello_world',
      location: resolvedUnitResult.lintLocationFromOffset(0, length: 5),
    );
  }
}
''',
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
        await cli.main();

        expect(exitCode, -1);
        expect(
          out.join(),
          completion(
            allOf(
              contains('''
[test_lint]
[test_lint]  
[test_lint] Hello
[test_lint] world
'''),
              endsWith(
                '''
  lib/another.dart:1:6 • Oy • oy
  lib/main.dart:1:1 • Hello world • hello_world
  lib/main.dart:1:6 • Oy • oy
''',
              ),
            ),
          ),
        );
        expect(
          err.join(),
          completion(
            contains('''
Bad state: fail
#0      _HelloWorldLint.getLints (file://${plugin.path}/bin/custom_lint.dart:19:8)
'''),
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
import 'dart:isolate';
import 'package:analyzer/dart/element/element.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:analyzer/dart/analysis/results.dart';

void main(List<String> args, SendPort sendPort) {
  startPlugin(sendPort, _HelloWorldLint());
}

class _HelloWorldLint extends PluginBase {
  @override
  Stream<Lint> getLints(ResolvedUnitResult resolvedUnitResult) async* {
    yield Lint(
      message: 'x2',
      code: 'x2',
      location: resolvedUnitResult.lintLocationFromLines(
        startLine: 2,
        endLine: 2,
        startColumn: 2,
        endColumn: 3,
      ),
    );
    yield Lint(
      message: 'a',
      code: 'a',
      location: resolvedUnitResult.lintLocationFromLines(
        startLine: 2,
        endLine: 2,
        startColumn: 2,
        endColumn: 3,
      ),
    );
    yield Lint(
      message: 'x',
      code: 'x',
      location: resolvedUnitResult.lintLocationFromLines(
        startLine: 2,
        endLine: 2,
        startColumn: 2,
        endColumn: 3,
      ),
    );
    yield Lint(
      message: 'y',
      code: 'y',
      location: resolvedUnitResult.lintLocationFromLines(
        startLine: 2,
        endLine: 2,
        startColumn: 1,
        endColumn: 2,
      ),
    );
    yield Lint(
      message: 'z',
      code: 'z',
      location: resolvedUnitResult.lintLocationFromLines(
        startLine: 1,
        endLine: 1,
        startColumn: 1,
        endColumn: 2,
      ),
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
        await cli.main();

        expect(exitCode, -1);
        expect(
          err.join(),
          completion(isEmpty),
        );

        expect(
          out.join(),
          completion(
            predicate((value) {
              expect(value, '''
  lib/main.dart:1:1 • z • z
  lib/main.dart:2:1 • y • y
  lib/main.dart:2:2 • a • a
  lib/main.dart:2:2 • x • x
  lib/main.dart:2:2 • x2 • x2
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
