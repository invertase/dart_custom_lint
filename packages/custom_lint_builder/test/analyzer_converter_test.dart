import 'package:analyzer/diagnostic/diagnostic.dart';
import 'package:analyzer/file_system/memory_file_system.dart';
import 'package:analyzer/source/file_source.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:custom_lint_builder/src/custom_analyzer_converter.dart';
import 'package:test/test.dart';

void main() {
  test('Converts LintCode', () {
    final resourceProvider = MemoryResourceProvider();
    final source = FileSource(
      resourceProvider.newFile(
        '/home/user/project/lib/main.dart',
        'void main() {}',
      ),
    );
    final source2 = FileSource(
      resourceProvider.newFile(
        '/home/user/project/lib/main2.dart',
        'void main2() {}',
      ),
    );

    final another = Diagnostic.tmp(
      source: source,
      offset: 11,
      length: 12,
      diagnosticCode: const LintCode(
        name: 'another',
        problemMessage: 'another message',
        url: 'https://dart.dev/diagnostics/another',
      ),
    );

    expect(
      CustomAnalyzerConverter()
          .convertAnalysisError(
            Diagnostic.tmp(
              source: source2,
              offset: 13,
              length: 14,
              diagnosticCode: const LintCode(
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
