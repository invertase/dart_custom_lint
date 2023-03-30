import 'dart:convert';
import 'dart:io';

import 'package:custom_lint/src/package_utils.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'cli_test.dart';
import 'create_project.dart';
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
  // These tests may take longer than the default timeout
  // due to them being run in separate processes and VMs.
  const timeout = Timeout(Duration(minutes: 1));

  group('Correctly exits with', () {
    test(
      'no issues found',
      timeout: timeout,
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

        final process = await Process.run(
          'dart',
          ['run', 'custom_lint', '.'],
          workingDirectory: app.path,
          stdoutEncoding: utf8,
          stderrEncoding: utf8,
        );

        expect(trimDependencyOverridesWarning(process.stderr), isEmpty);
        expect(process.stdout, 'No issues found!\n');
        expect(process.exitCode, 0);
      },
    );

    test(
      'found lints',
      timeout: timeout,
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

        final process = await Process.run(
          'dart',
          ['run', 'custom_lint', '.'],
          workingDirectory: app.path,
        );

        expect(trimDependencyOverridesWarning(process.stderr), isEmpty);
        expect(process.stdout, '''
  lib/another.dart:1:6 • Oy • oy
  lib/main.dart:1:6 • Oy • oy
''');
        expect(process.exitCode, 1);
      },
    );

    test(
      'missing package_config.json',
      timeout: timeout,
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
        final packageConfig = innerContextRoot.packageConfig;
        // Potentially resolve the file system link, temp folders are links on macOs into /private/var
        final missingPackageConfig =
            await innerContextRoot.resolveSymbolicLinks();
        packageConfig.deleteSync();

        final process = await Process.run(
          'dart',
          ['run', 'custom_lint', '.'],
          workingDirectory: app.path,
        );

        expect(process.stdout, isEmpty);
        expect(
          trimDependencyOverridesWarning(process.stderr),
          startsWith(
            '''
The request analysis.setContextRoots failed with the following error:
RequestErrorCode.PLUGIN_ERROR
No .dart_tool/package_config.json found at $missingPackageConfig. Make sure to run `pub get` first.''',
          ),
        );
        expect(process.exitCode, 1);
      },
    );

    test(
      'dependency conflict',
      timeout: timeout,
      () async {
        // Create two packages with the same name but different paths
        final workspace = await createSimpleWorkspace(['dep', 'dep']);

        final plugin = createPlugin(
          parent: workspace,
          name: 'test_lint',
          main: oyPluginSource,
          extraDependencies: {
            'dep': '{"path": "${workspace.dir('dep').path}"}'
          },
        );

        // We define two projects with different dependencies
        final app = createLintUsage(
          parent: workspace,
          name: 'test_app',
          source: {'lib/main.dart': 'void fn() {}'},
          plugins: {'test_lint': plugin.uri},
          createDependencyOverrides: true,
          // Adding "dep" to app's package_config is redundant because
          // "dart run" unfortunately runs "pub get", which will override
          // the manually written package_config.json file.
          extraPackageConfig: {'dep': workspace.dir('dep').uri},
        );

        final app2 = createLintUsage(
          // Add the second project inside the first one, such that
          // analyzing the first project analyzes both projects
          parent: app,
          name: 'test_app2',
          source: {'lib/foo.dart': 'void fn() {}'},
          createDependencyOverrides: true,
          plugins: {'test_lint': plugin.uri},
          // Override the shared dependency to cause a conflict
          extraDependencyOverrides: {
            'dep': '{"path": "${workspace.dir('dep2').path}"}'
          },
          extraPackageConfig: {'dep': workspace.dir('dep2').uri},
        );

        final process = await Process.run(
          workingDirectory: app.path,
          'dart',
          ['run', 'custom_lint', '.'],
        );

        expect(process.stdout, isEmpty);
        expect(
          trimDependencyOverridesWarning(process.stderr),
          '''
PackageVersionConflictError – Some dependencies with conflicting versions were identified:

Package dep:
- Hosted with version constraint: any
  Resolved with ${workspace.dir('transitive_dep').path}/
  Used by plugin "test_lint" at ${plugin.path} in the project "test_app" at ${app.path}
- Hosted with version constraint: any
  Resolved with ${workspace.dir('transitive_dep2').path}/
  Used by plugin "test_lint" at ${plugin.path} in the project "test_app2" at ${app2.path}

$conflictExplanation
You could run the following commands to try fixing this:

cd ${app.path}
dart pub upgrade dep
cd ${app2.path}
dart pub upgrade dep
''',
        );
        expect(process.exitCode, 1);
      },
    );
  });
}
