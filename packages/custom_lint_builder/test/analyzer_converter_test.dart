import 'package:analyzer/error/error.dart';
import 'package:analyzer/file_system/memory_file_system.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:custom_lint_builder/src/custom_analyzer_converter.dart';
import 'package:test/test.dart';

void main() {
  test('Converts LintCode', () {
    final resourceProvider = MemoryResourceProvider();
    final source = resourceProvider
        .newFile('/home/user/project/lib/main.dart', 'void main() {}')
        .createSource();

    final another = AnalysisError(
      source,
      42,
      10,
      const LintCode(name: 'another', problemMessage: 'another message'),
    );

    expect(
      CustomAnalyzerConverter()
          .convertAnalysisError(
            AnalysisError(
              source,
              42,
              10,
              const LintCode(name: 'foo', problemMessage: 'bar'),
              [],
              [another.problemMessage],
            ),
          )
          .toJson(),
      {
        'severity': 'INFO',
        'type': 'LINT',
        'location': {
          'file': '/home/user/project/lib/main.dart',
          'offset': 42,
          'length': 10,
          'startLine': -1,
          'startColumn': -1,
          'endLine': -1,
          'endColumn': -1
        },
        'message': 'bar',
        'code': 'foo',
        'url': 'https://dart.dev/diagnostics/foo',
        'contextMessages': [
          {
            'message': 'another message',
            'location': {
              'file': '/home/user/project/lib/main.dart',
              'offset': 42,
              'length': 10,
              'startLine': -1,
              'startColumn': -1,
              'endLine': -1,
              'endColumn': -1
            }
          }
        ],
      },
    );
  });
}
