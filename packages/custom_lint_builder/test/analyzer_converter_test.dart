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
    final source2 = resourceProvider
        .newFile('/home/user/project/lib/main2.dart', 'void main2() {}')
        .createSource();

    final another = AnalysisError.tmp(
      source: source,
      offset: 11,
      length: 12,
      errorCode: const LintCode(
        name: 'another',
        problemMessage: 'another message',
        url: 'https://dart.dev/diagnostics/another',
      ),
    );

    expect(
      CustomAnalyzerConverter()
          .convertAnalysisError(
            AnalysisError.tmp(
              source: source2,
              offset: 13,
              length: 14,
              errorCode: const LintCode(
                name: 'foo',
                problemMessage: 'bar',
                url: 'https://google.com/diagnostics/foo',
              ),
              contextMessages: [another.problemMessage],
            ),
          )
          .toJson(),
      {
        'severity': 'INFO',
        'type': 'LINT',
        'location': {
          'file': '/home/user/project/lib/main2.dart',
          'offset': 13,
          'length': 14,
          'startLine': -1,
          'startColumn': -1,
          'endLine': -1,
          'endColumn': -1,
        },
        'message': 'bar',
        'code': 'foo',
        'url': 'https://google.com/diagnostics/foo',
        'contextMessages': [
          {
            'message': 'another message',
            'location': {
              'file': '/home/user/project/lib/main.dart',
              'offset': 11,
              'length': 12,
              'startLine': -1,
              'startColumn': -1,
              'endLine': -1,
              'endColumn': -1,
            },
          }
        ],
      },
    );
  });
}
