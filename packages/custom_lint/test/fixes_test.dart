import 'package:analyzer_plugin/protocol/protocol_generated.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

import 'create_project.dart';
import 'run_plugin.dart';

final pluginWithFixSource = createPluginSource([
  TestLintRule(
    code: 'hello_world',
    message: 'Hello world',
    fixes: [TestLintFix(name: 'HelloWorldFix')],
  ),
]);

void main() {
  test('Handles fixes`', () async {
    final plugin = createPlugin(name: 'test_lint', main: pluginWithFixSource);

    final app = createLintUsage(
      source: {
        'lib/main.dart': '''
void fn() {}
''',
      },
      plugins: {'test_lint': plugin.uri},
      name: 'test_app',
    );
    final mainPath = join(app.path, 'lib', 'main.dart');

    final runner = await startRunnerForApp(app);

    expect(
      await runner.channel.lints.first,
      isA<AnalysisErrorsParams>()
          .having((e) => e.file, 'file', mainPath)
          .having((e) => e.errors.single.location.offset, 'offset', 5)
          .having((e) => e.errors.single.location.length, 'length', 2),
    );

    final fixesBeforeOffset = runner.getFixes(mainPath, 4);
    final fixesAtStartOffset = runner.getFixes(mainPath, 5);
    final fixesAtMiddleOffset = runner.getFixes(mainPath, 6);
    final fixesAtEndOffset = runner.getFixes(mainPath, 7);
    final fixesAfterOffset = runner.getFixes(mainPath, 8);

    expect(
      await Future.wait([fixesAfterOffset, fixesBeforeOffset]),
      everyElement(
        isA<EditGetFixesResult>().having((e) => e.fixes, 'fixes', isEmpty),
      ),
    );

    expect(
      await Future.wait([
        fixesAtStartOffset,
        fixesAtMiddleOffset,
        fixesAtEndOffset,
      ]),
      everyElement(
        isA<EditGetFixesResult>().having((e) => e.fixes, 'fixes', hasLength(1)),
      ),
    );

    expect(runner.channel.lints, emitsDone);

    // Closing so that previous error matchers relying on stream
    // closing can complete
    await runner.close();

    expect(plugin.log.existsSync(), false);
  });
}
