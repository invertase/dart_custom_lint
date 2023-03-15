import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:test_process/test_process.dart';

import 'cli_test.dart';
import 'create_project.dart';

void main() {
  group('Correctly exits with', () {
    test('no issues found', () async {
      final plugin = createPlugin(name: 'test_lint', main: emptyPluginSource);

      final app = createLintUsage(
        name: 'test_app',
        source: {
          'lib/main.dart': 'void fn() {}',
          'lib/another.dart': 'void fail() {}',
        },
        plugins: {'test_lint': plugin.uri},
        createDependencyOverrides: true,
      );

      final process = await TestProcess.start(
        'dart',
        [
          'run',
          'custom_lint',
          '.',
        ],
        workingDirectory: app.path,
      );

      // Skipping the pub get warnings about overridden dependencies here
      await process.stderr.skip(3);

      expect(process.stderr, emitsDone);
      expect(
        process.stdout,
        emitsInOrder(
          [
            'No issues found!',
            emitsDone,
          ],
        ),
      );
      expect(process.exitCode, completion(0));
    });

    test('found lints', () async {
      final plugin = createPlugin(name: 'test_lint', main: oyPluginSource);

      final app = createLintUsage(
        name: 'test_app',
        source: {
          'lib/main.dart': 'void fn() {}',
          'lib/another.dart': 'void fail() {}',
        },
        plugins: {'test_lint': plugin.uri},
        createDependencyOverrides: true,
      );

      final process = await TestProcess.start(
        'dart',
        [
          'run',
          'custom_lint',
          '.',
        ],
        workingDirectory: app.path,
      );

      // Skipping the pub get warnings about overridden dependencies here
      await process.stderr.skip(3);

      expect(process.stderr, emitsDone);
      expect(
        process.stdout,
        emitsInOrder(
          [
            '  lib/another.dart:1:6 • Oy • oy',
            '  lib/main.dart:1:6 • Oy • oy',
            emitsDone,
          ],
        ),
      );
      expect(process.exitCode, completion(1));
    });

    test('missing package_config.json', () async {
      final plugin = createPlugin(name: 'test_lint', main: oyPluginSource);

      final app = createLintUsage(
        name: 'test_app',
        source: {
          'lib/main.dart': 'void fn() {}',
          'lib/another.dart': 'void fail() {}',
        },
        plugins: {'test_lint': plugin.uri},
        createDependencyOverrides: true,
      );

      // Create a child context root
      final innerContextRoot = createLintUsage(
        name: 'test_project_inner',
        source: {
          'lib/main.dart': 'void fn() {}',
          'lib/another.dart': 'void fail() {}',
        },
        parent: app,
        createDependencyOverrides: true,
      );

      // create error during initialization because of missing package_config.json
      final packageConfig = File(
          p.join(innerContextRoot.path, '.dart_tool', 'package_config.json'));
      // Potentially resolve the file system link, temp folders are links on macOs into /private/var
      final missingPackageConfig = await packageConfig.resolveSymbolicLinks();
      packageConfig.deleteSync(recursive: true);

      final process = await TestProcess.start(
        'dart',
        [
          'run',
          'custom_lint',
          '.',
        ],
        workingDirectory: app.path,
      );

      // Skipping the pub get warnings about overridden dependencies here
      await process.stderr.skip(3);

      expect(process.stdout, emitsDone);
      expect(
        process.stderr,
        emitsThrough(
          emitsInOrder(
            [
              'The request analysis.setContextRoots failed with the following error:',
              'RequestErrorCode.PLUGIN_ERROR',
              'Bad state: No $missingPackageConfig found. Make sure to run `pub get` first.',
            ],
          ),
        ),
      );
      expect(process.exitCode, completion(1));
    });

    test('dependency conflict', () async {
      final plugin = createPlugin(name: 'test_lint', main: oyPluginSource);

      final app = createLintUsage(
        name: 'test_app',
        source: {
          'lib/main.dart': 'void fn() {}',
          'lib/another.dart': 'void fail() {}',
        },
        plugins: {'test_lint': plugin.uri},
        createDependencyOverrides: true,
      );

      // Create a child context root
      final innerContextRoot = createLintUsage(
        name: 'test_project_inner',
        source: {
          'lib/main.dart': 'void fn() {}',
          'lib/another.dart': 'void fail() {}',
        },
        parent: app,
        createDependencyOverrides: true,
      );

      // a hacky way to create a dependency conflict
      final packageConfig = File(
          p.join(innerContextRoot.path, '.dart_tool', 'package_config.json'));
      var contents = packageConfig.readAsStringSync();
      contents = contents.replaceAll('analyzer-.*",', 'analyzer-5.0.0",');
      packageConfig.writeAsStringSync(contents);

      final process = await TestProcess.start(
        'dart',
        [
          'run',
          'custom_lint',
          '.',
        ],
        workingDirectory: app.path,
      );

      // Skipping the pub get warnings about overridden dependencies here
      await process.stderr.skip(3);

      expect(process.stdout, emitsDone);
      expect(
        process.stderr,
        emitsThrough(
          emitsInOrder(
            [
              'The request analysis.setContextRoots failed with the following error:',
              'RequestErrorCode.PLUGIN_ERROR',
              'Bad state: Some dependencies with conflicting versions were identified:',
            ],
          ),
        ),
      );
      expect(process.exitCode, completion(1));
    });
  });
}
