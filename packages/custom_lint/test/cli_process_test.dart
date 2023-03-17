import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:test_process/test_process.dart';

import 'cli_test.dart';
import 'create_project.dart';

void main() {
  // These tests may take longer than the default timeout
  // due to them being run in separate processes and VMs.
  const timeout = Timeout(Duration(minutes: 1));

  group('Correctly exits with', () {
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

        expect(process.stderr, emitsThrough(emitsDone));
        expect(process.stdout, emitsThrough(emitsDone));
        expect(process.exitCode, completion(0));
      },
      timeout: timeout,
    );

    test(
      'found lints',
      () async {
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

        expect(process.stderr, emitsThrough(emitsDone));
        expect(process.stdout, emitsThrough(emitsDone));
        expect(process.exitCode, completion(1));
      },
      timeout: timeout,
    );

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
          p.join(innerContextRoot.path, '.dart_tool', 'package_config.json'),
        );
        // Potentially resolve the file system link, temp folders are links on macOs into /private/var
        final missingPackageConfig = await packageConfig.resolveSymbolicLinks();
        packageConfig.deleteSync();

        final process = await TestProcess.start(
          'dart',
          [
            'run',
            'custom_lint',
            '.',
          ],
          workingDirectory: app.path,
        );

        expect(process.stdout, emitsDone);
        expect(
          process.stderr,
          emitsThrough(
            emitsInOrder([
              'The request analysis.setContextRoots failed with the following error:',
              'RequestErrorCode.PLUGIN_ERROR',
              'Bad state: No $missingPackageConfig found. Make sure to run `pub get` first.',
            ]),
          ),
        );
        expect(process.exitCode, completion(1));
      },
      timeout: timeout,
    );

    test(
      'dependency conflict',
      () async {
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

        // Create a dependency conflict by manually fetching
        // analyzer and overriding it in pubspec and package config.
        // Fetching is required, otherwise there is no pubspec.yaml available.
        const version = '1.8.0';
        await Process.run(
          'dart',
          ['pub', 'add', 'meta:$version'],
          workingDirectory: innerContextRoot.path,
        );
        final packageConfig = File(
          p.join(innerContextRoot.path, '.dart_tool', 'package_config.json'),
        );
        var contents = packageConfig.readAsStringSync();
        contents = contents.replaceAll(
          RegExp('meta-.*",'),
          'meta-$version",',
        );
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

        expect(process.stdout, emitsDone);
        expect(
          process.stderr,
          emitsThrough(
            emitsInOrder([
              'The request analysis.setContextRoots failed with the following error:',
              'RequestErrorCode.PLUGIN_ERROR',
              'Bad state: Some dependencies with conflicting versions were identified:',
            ]),
          ),
        );
        expect(process.exitCode, completion(1));
      },
      timeout: timeout,
    );
  });
}
