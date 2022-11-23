import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

import 'cli_test.dart';
import 'create_project.dart';
import 'equals_ignoring_ansi.dart';
import 'matchers.dart';
import 'mock_fs.dart';
import 'run_plugin.dart';

void main() {
  test('List warnings for all files combined', () async {
    final plugin = createPlugin(
      name: 'test_lint',
      main: '''
import 'dart:isolate';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart' hide Element;
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:analyzer/dart/analysis/results.dart';

void main(List<String> args, SendPort sendPort) {
  startPlugin(sendPort, _HelloWorldLint());
}

class _HelloWorldLint extends PluginBase {
  @override
  Stream<Lint> getLints(ResolvedUnitResult resolvedUnitResult) async* {
    final library = resolvedUnitResult.libraryElement;
    for (final variable in library.topLevelElements) {
      yield Lint(
        code: 'hello_world',
        message: 'Hello world',
        location: resolvedUnitResult.lintLocationFromOffset(
          variable.nameOffset,
          length: variable.nameLength,
        ),
      );
    }
  }
}
''',
    );

    final app = createLintUsage(
      source: {
        'lib/main.dart': '''
void fn() {}

void fn2() {}
''',
        'lib/another.dart': 'void fn() {}\n',
      },
      plugins: {'test_lint': plugin.uri},
      name: 'test_app',
    );

    final lints = await runServerInCliModeForApp(app);

    expect(
      lints.map((e) => e.file),
      [
        join(app.path, 'lib', 'another.dart'),
        join(app.path, 'lib', 'main.dart'),
      ],
    );

    expect(
      lints.first.errors,
      [
        isA<AnalysisError>()
            .having((e) => e.code, 'code', 'hello_world')
            .having(
              (e) => e.location,
              'location',
              Location(
                join(app.path, 'lib', 'another.dart'),
                5,
                2,
                1,
                6,
                endLine: 1,
                endColumn: 8,
              ),
            )
            .having((e) => e.message, 'message', 'Hello world'),
      ],
    );
    expect(
      lints.last.errors,
      [
        isA<AnalysisError>()
            .having((e) => e.code, 'code', 'hello_world')
            .having(
              (e) => e.location,
              'location',
              Location(
                join(app.path, 'lib', 'main.dart'),
                5,
                2,
                1,
                6,
                endLine: 1,
                endColumn: 8,
              ),
            )
            .having((e) => e.message, 'message', 'Hello world'),
        isA<AnalysisError>()
            .having((e) => e.code, 'code', 'hello_world')
            .having(
              (e) => e.location,
              'location',
              Location(
                join(app.path, 'lib', 'main.dart'),
                19,
                3,
                3,
                6,
                endLine: 3,
                endColumn: 9,
              ),
            )
            .having((e) => e.message, 'message', 'Hello world'),
      ],
    );
  });

  test('supports running multiple plugins at once', () async {
    final plugin = createPlugin(name: 'test_lint', main: helloWordPluginSource);
    final plugin2 = createPlugin(name: 'test_lint2', main: oyPluginSource);

    final app = createLintUsage(
      source: {
        'lib/main.dart': '''


void fn() {}''',
        'lib/another.dart': '''


void fn2() {}''',
      },
      plugins: {'test_lint': plugin.uri, 'test_lint2': plugin2.uri},
      name: 'test_app',
    );

    final lints = await runServerInCliModeForApp(app);

    expect(
      lints.map((e) => e.file),
      [
        join(app.path, 'lib', 'another.dart'),
        join(app.path, 'lib', 'main.dart'),
      ],
    );

    expect(
      lints.first.errors.map((e) => e.code),
      unorderedEquals(<Object?>['hello_world', 'oy']),
    );
    expect(
      lints.last.errors.map((e) => e.code),
      unorderedEquals(<Object?>['hello_world', 'oy']),
    );
  });

  test('supports plugins without .package_config.json', () async {
    final plugin = createPlugin(
      name: 'test_lint',
      main: helloWordPluginSource,
      omitPackageConfig: true,
    );
    final plugin2 = createPlugin(
      name: 'test_lint2',
      main: oyPluginSource,
      omitPackageConfig: true,
    );

    final app = createLintUsage(
      source: {
        'lib/main.dart': '''


void fn() {}''',
        'lib/another.dart': '''


void fn2() {}''',
      },
      plugins: {'test_lint': plugin.uri, 'test_lint2': plugin2.uri},
      name: 'test_app',
    );

    final lints = await runServerInCliModeForApp(app);

    expect(
      lints.map((e) => e.file),
      [
        join(app.path, 'lib', 'another.dart'),
        join(app.path, 'lib', 'main.dart'),
      ],
    );

    expect(
      lints.first.errors.map((e) => e.code),
      unorderedEquals(<Object?>['hello_world', 'oy']),
    );
    expect(
      lints.last.errors.map((e) => e.code),
      unorderedEquals(<Object?>['hello_world', 'oy']),
    );
  });

  test('redirect prints and errors to log files', () async {
    final plugin = createPlugin(
      name: 'test_lint',
      main: '''
import 'dart:isolate';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart' hide Element;
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:analyzer/dart/analysis/results.dart';

void main(List<String> args, SendPort sendPort) {
  startPlugin(sendPort, _HelloWorldLint());
}

class _HelloWorldLint extends PluginBase {
  @override
  Stream<Lint> getLints(ResolvedUnitResult resolvedUnitResult) async* {
    final library = resolvedUnitResult.libraryElement;
    if (library.topLevelElements.single.name == 'fail') {
       print('Hello world');
       throw StateError('fail');
    }
    yield Lint(
      code: 'hello_world',
      message: 'Hello world',
      location: resolvedUnitResult.lintLocationFromOffset(0, length: 1),
    );
  }
}
''',
    );
    final plugin2 = createPlugin(name: 'test_lint2', main: oyPluginSource);

    final app = createLintUsage(
      source: {
        'lib/main.dart': 'void fn() {}\n',
        'lib/another.dart': 'void fail() {}\n',
      },
      plugins: {'test_lint': plugin.uri, 'test_lint2': plugin2.uri},
      name: 'test_app',
    );

    await runWithIOOverride((out, err) async {
      final runner = await startRunnerForApp(
        app,
        // Ignoring errors as we are handling them later
        ignoreErrors: true,
      );

      // Plugin errors will be emitted as notifications, not as part of the response
      expect(runner.channel.responseErrors, emitsDone);

      // The error in our plugin will be reported as PluginErrorParams
      expect(
        runner.channel.pluginErrors.toList(),
        completion([
          predicate<PluginErrorParams>((value) {
            expect(
              value.message,
              'The following exception was thrown while trying to obtain lints for ${app.path}/lib/another.dart:\n'
              'Bad state: fail',
            );
            return true;
          }),
        ]),
      );

      final lints = await runner.getLints(reload: false);

      expect(
        lints.map((e) => e.file),
        [
          join(app.path, 'lib', 'another.dart'),
          join(app.path, 'lib', 'main.dart'),
        ],
      );

      expect(
        lints.first.errors.map((e) => e.code),
        unorderedEquals(<Object?>['oy']),
      );
      expect(
        lints.last.errors.map((e) => e.code),
        unorderedEquals(<Object?>['hello_world', 'oy']),
      );
      // uncomment when the golden needs update
      // saveLogGoldens(
      //   File('test/goldens/server_test/redirect_logs.golden'),
      //   app.log.readAsStringSync(),
      //   paths: {plugin.uri: 'plugin', app.uri: 'app'},
      // );
      // await runner.close();
      // return;

      expect(
        app.log,
        matchesLogGolden(
          'test/goldens/server_test/redirect_logs.golden',
          paths: {plugin.uri: 'plugin', app.uri: 'app'},
        ),
      );
      expect(
        app.log,
        matchesLogGolden(
          'test/goldens/server_test/redirect_logs.golden',
          paths: {plugin.uri: 'plugin', app.uri: 'app'},
        ),
      );

      // Closing so that previous error matchers relying on stream
      // closing can complete
      await runner.close();
    });
  });

  group('hot-restart', () {
    test('handles the source change of one plugin and restart it', () async {
      final plugin = createPlugin(
        name: 'test_lint',
        main: helloWordPluginSource,
      );
      final plugin2 = createPlugin(name: 'test_lint2', main: oyPluginSource);

      final app = createLintUsage(
        source: {'lib/main.dart': 'void fn() {}\n'},
        plugins: {'test_lint': plugin.uri, 'test_lint2': plugin2.uri},
        name: 'test_app',
      );

      final runner = await startRunnerForApp(app);

      await expectLater(
        runner.channel.lints,
        // Using emitsThrough as depending on how fast lints are emitted,
        // the 2 lints can be received accross two events instead of one.
        emitsThrough(
          isA<AnalysisErrorsParams>()
              .having(
                (e) => e.file,
                'file',
                join(app.path, 'lib', 'main.dart'),
              )
              .having(
                (e) => e.errors.map((e) => e.code),
                'errors',
                unorderedEquals(<Object?>['hello_world', 'oy']),
              ),
        ),
      );

      plugin.pluginMain.writeAsStringSync('''
import 'dart:isolate';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart' hide Element;
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:analyzer/dart/analysis/results.dart';

void main(List<String> args, SendPort sendPort) {
  startPlugin(sendPort, _ReloaddLint());
}

class _ReloaddLint extends PluginBase {
  @override
  Stream<Lint> getLints(ResolvedUnitResult resolvedUnitResult) async* {
    final library = resolvedUnitResult.libraryElement;
    yield Lint(
      code: 'hello_reload',
      message: 'Hello reload',
      location: resolvedUnitResult.lintLocationFromOffset(
        library.topLevelElements.first.nameOffset,
        length: library.topLevelElements.first.nameLength,
      ),
    );
  }
}
''');

      await expectLater(
        runner.channel.lints,
        emitsInOrder(<Object?>[
          predicate<AnalysisErrorsParams>((value) {
            expect(value.file, join(app.path, 'lib', 'main.dart'));
            // Clears lints previously emitted by the reloaded plugin
            expect(value.errors.single.code, 'oy');
            return true;
          }),
          predicate<AnalysisErrorsParams>((value) {
            expect(value.file, join(app.path, 'lib', 'main.dart'));
            expect(
              value.errors.map((e) => e.code),
              unorderedEquals(<Object?>['hello_reload', 'oy']),
            );
            return true;
          }),
        ]),
      );

      expect(runner.channel.lints, emitsDone);

      // Closing so that previous error matchers relying on stream
      // closing can complete
      await runner.close();

      expect(plugin.log.existsSync(), false);
      expect(plugin2.log.existsSync(), false);
    });

    test('supports reloading a working plugin into one that fails', () async {
      final plugin = createPlugin(
        name: 'test_lint',
        main: helloWordPluginSource,
      );
      final plugin2 = createPlugin(name: 'test_lint2', main: oyPluginSource);

      final app = createLintUsage(
        source: {'lib/main.dart': 'void fn() {}\n'},
        plugins: {'test_lint': plugin.uri, 'test_lint2': plugin2.uri},
        name: 'test_app',
      );

      await runWithIOOverride((out, err) async {
        final runner = await startRunnerForApp(app, ignoreErrors: true);

        await expectLater(
          runner.channel.lints,
          // Using emitsThrough as depending on how fast lints are emitted,
          // the 2 lints can be received accross two events instead of one.
          emitsThrough(
            isA<AnalysisErrorsParams>()
                .having(
                  (e) => e.file,
                  'file',
                  join(app.path, 'lib', 'main.dart'),
                )
                .having(
                  (e) => e.errors.map((e) => e.code),
                  'errors',
                  unorderedEquals(<Object?>['hello_world', 'oy']),
                ),
          ),
        );

        expect(plugin.log.existsSync(), false);
        expect(plugin2.log.existsSync(), false);

        plugin.pluginMain.writeAsStringSync('''
invalid;
''');

        // Plugin errors will be emitted as notifications, not as part of the response
        expect(runner.channel.responseErrors, emitsDone);

        // The error in our plugin will be reported as PluginErrorParams
        // We don't immediately await it, as we could otherwise miss the lint update

        final awaitError = expectLater(
          runner.channel.pluginErrors,
          emits(
            isA<PluginErrorParams>().having(
              (e) => e.message,
              'message',
              equalsIgnoringAnsi('''
IsolateSpawnException: Unable to spawn isolate: ${plugin.path}/bin/custom_lint.dart:1:1: Error: Variables must be declared using the keywords 'const', 'final', 'var' or a type name.
Try adding the name of the type of the variable or the keyword 'var'.
invalid;
^^^^^^^'''),
            ),
          ),
        );
        await expectLater(
          runner.channel.lints,
          emits(
            predicate<AnalysisErrorsParams>((value) {
              expect(value.file, join(app.path, 'lib', 'main.dart'));
              // Clears lints previously emitted by the reloaded plugin
              expect(value.errors.single.code, 'oy');
              return true;
            }),
          ),
        );

        await awaitError;

        expect(runner.channel.pluginErrors, emitsDone);
        expect(runner.channel.lints, emitsDone);

        // Closing so that previous error matchers relying on stream
        // closing can complete
        await runner.close();

        expect(plugin.log.existsSync(), false);
        expect(plugin2.log.existsSync(), false);
      });
    });
  });
}
