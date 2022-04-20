import 'package:test/test.dart';

import '../bin/custom_lint.dart' as cli;
import 'create_project.dart';
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
  Iterable<Lint> getLints(ResolvedUnitResult resolvedUnitResult) sync* {
    final library = resolvedUnitResult.libraryElement;
    yield Lint(
      code: 'oy',
      message: 'Oy',
      location: LintLocation.fromOffsets(
        offset: library.topLevelElements.first.nameOffset,
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
  Iterable<Lint> getLints(ResolvedUnitResult resolvedUnitResult) sync* {
    final library = resolvedUnitResult.libraryElement;
    yield Lint(
      code: 'hello_world',
      message: 'Hello world',
      location: LintLocation.fromOffsets(
        offset: library.topLevelElements.first.nameOffset,
        length: library.topLevelElements.first.nameLength,
      ),
    );
  }
}
''';

void main() {
  // TODO move plugin main to bin/custom_lint.dart

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
  Iterable<Lint> getLints(ResolvedUnitResult resolvedUnitResult) sync* {}
}
''',
    );

    final app = creatLintUsage(
      source: {'lib/main.dart': 'void fn() {}'},
      plugins: {'test_lint': plugin.uri},
      name: 'test_app',
    );

    await runWithIOOverride(
      (out, err) async {
        final code = await cli.main();

        expect(code, 0);
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

    final app = creatLintUsage(
      source: {'lib/main.dart': 'void fn() {}'},
      plugins: {'test_lint': plugin.uri},
      name: 'test_app',
    );

    await runWithIOOverride(
      (out, err) async {
        final code = await cli.main();

        expect(code, -1);
        expect(err.join(), completion('''
IsolateSpawnException: Unable to spawn isolate: ${plugin.path}/bin/custom_lint.dart:1:1: \x1B[31mError: Variables must be declared using the keywords 'const', 'final', 'var' or a type name.
Try adding the name of the type of the variable or the keyword 'var'.\x1B[39;49m
invalid;
^^^^^^^

'''));
        expect(out, emitsDone);
      },
      currentDirectory: app,
    );
  });

  test('CLI lists warnings from all plugins and set exit code', () async {
    final plugin = createPlugin(name: 'test_lint', main: helloWordPluginSource);
    final plugin2 = createPlugin(name: 'test_lint2', main: oyPluginSource);

    final app = creatLintUsage(
      source: {
        'lib/main.dart': 'void fn() {}',
        'lib/another.dart': 'void fail() {}',
      },
      plugins: {'test_lint': plugin.uri, 'test_lint2': plugin2.uri},
      name: 'test_app',
    );

    await runWithIOOverride(
      (out, err) async {
        final code = await cli.main();

        expect(code, -1);
        expect(out.join(), completion('''
  lib/another.dart:0:5 • Hello world • hello_world
  lib/another.dart:0:5 • Oy • oy
  lib/main.dart:0:5 • Hello world • hello_world
  lib/main.dart:0:5 • Oy • oy
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

    final app = creatLintUsage(
      source: {
        'lib/main.dart': 'void fn() {}',
        'lib/another.dart': 'void fail() {}',
      },
      plugins: {'test_lint': plugin.uri, 'test_lint2': plugin2.uri},
      name: 'test_app',
    );

    await runWithIOOverride(
      (out, err) async {
        final code = await cli.main();

        expect(code, -1);
        expect(
          err.join(),
          completion(
            '''
IsolateSpawnException: Unable to spawn isolate: ${plugin2.path}/bin/custom_lint.dart:1:9: \x1B[31mError: A value of type 'String' can't be assigned to a variable of type 'int'.\x1B[39;49m
int x = 'oy';
        ^

''',
          ),
        );
        expect(out.join(), completion('''
  lib/another.dart:0:5 • Hello world • hello_world
  lib/main.dart:0:5 • Hello world • hello_world
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
  Iterable<Lint> getLints(ResolvedUnitResult resolvedUnitResult) sync* {
    final library = resolvedUnitResult.libraryElement;
    if (library.topLevelElements.single.name == 'fail') {
      print('');
      print(' ');
       print('Hello\nworld');
       throw StateError('fail');
    }
    yield Lint(
      message: 'Hello world',
      code: 'hello_world',
      location: LintLocation.fromOffsets(offset: 0, length: 5),
    );
  }
}
''',
    );

    final plugin2 = createPlugin(name: 'test_lint2', main: oyPluginSource);

    final app = creatLintUsage(
      source: {
        'lib/main.dart': 'void fn() {}',
        'lib/another.dart': 'void fail() {}',
      },
      plugins: {'test_lint': plugin.uri, 'test_lint2': plugin2.uri},
      name: 'test_app',
    );

    await runWithIOOverride(
      (out, err) async {
        final code = await cli.main();

        expect(code, -1);
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
  lib/another.dart:0:5 • Oy • oy
  lib/main.dart:0:0 • Hello world • hello_world
  lib/main.dart:0:5 • Oy • oy
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
#0      _HelloWorldLint.getLints (file://${plugin.path}/bin/custom_lint.dart:18:8)
'''),
          ),
        );
      },
      currentDirectory: app,
    );
  });
}
