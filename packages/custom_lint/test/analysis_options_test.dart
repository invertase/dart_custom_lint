import 'dart:convert';
import 'dart:io';

import 'package:analyzer/error/error.dart';
import 'package:test/test.dart';

import 'cli_process_test.dart';
import 'create_project.dart';
import 'peer_project_meta.dart';

void main() {
  group('Errors severities override', () {
    Future<ProcessResult> runProcess(String workingDirectoryPath) async =>
        Process.run(
          'dart',
          [customLintBinPath],
          workingDirectory: workingDirectoryPath,
          stdoutEncoding: utf8,
          stderrEncoding: utf8,
        );

    Directory createLintUsageWith({
      required Uri pluginUri,
      required String analysisOptions,
    }) =>
        createLintUsage(
          name: 'test_app',
          source: {'lib/main.dart': 'void fn() {}'},
          plugins: {'test_lint': pluginUri},
          analysisOptions: analysisOptions,
        );

    Directory createTestPlugin({
      ErrorSeverity errorSeverity = ErrorSeverity.INFO,
    }) =>
        createPlugin(
          name: 'test_lint',
          main: createPluginSource([
            TestLintRule(
              code: 'test_lint',
              message: 'Test lint message',
              errorSeverity: errorSeverity,
            ),
          ]),
        );
    test('correctly applies error severity from analysis_options.yaml',
        () async {
      final plugin = createTestPlugin(errorSeverity: ErrorSeverity.ERROR);

      final app = createLintUsageWith(
        pluginUri: plugin.uri,
        analysisOptions: '''
custom_lint:
  errors:
    test_lint: error
''',
      );

      final process = await runProcess(app.path);

      expect(trimDependencyOverridesWarning(process.stderr), isEmpty);
      expect(process.stdout, '''
Analyzing...

  lib/main.dart:1:6 • Test lint message • test_lint • ERROR

1 issue found.
''');
      expect(process.exitCode, 1);
    });

    test('correctly applies warning severity from analysis_options.yaml',
        () async {
      final plugin = createTestPlugin();

      final app = createLintUsageWith(
        pluginUri: plugin.uri,
        analysisOptions: '''
custom_lint:
  errors:
    test_lint: warning
''',
      );

      final process = await runProcess(app.path);

      expect(trimDependencyOverridesWarning(process.stderr), isEmpty);
      expect(process.stdout, '''
Analyzing...

  lib/main.dart:1:6 • Test lint message • test_lint • WARNING

1 issue found.
''');
      expect(process.exitCode, 1);
    });

    test('correctly applies info severity from analysis_options.yaml',
        () async {
      final plugin = createTestPlugin();

      final app = createLintUsageWith(
        pluginUri: plugin.uri,
        analysisOptions: '''
custom_lint:
  errors:
    test_lint: info
''',
      );

      final process = await runProcess(app.path);

      expect(trimDependencyOverridesWarning(process.stderr), isEmpty);
      expect(process.stdout, '''
Analyzing...

  lib/main.dart:1:6 • Test lint message • test_lint • INFO

1 issue found.
''');
      expect(process.exitCode, 1);
    });

    test('correctly applies none severity from analysis_options.yaml',
        () async {
      final plugin = createTestPlugin();

      final app = createLintUsageWith(
        pluginUri: plugin.uri,
        analysisOptions: '''
custom_lint:
  errors:
    test_lint: none
''',
      );

      final process = await runProcess(app.path);

      expect(trimDependencyOverridesWarning(process.stderr), isEmpty);
      expect(process.stdout, '''
Analyzing...

No issues found!
''');
      expect(process.exitCode, 0);
    });
  });
}
