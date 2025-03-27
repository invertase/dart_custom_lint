import 'package:analyzer/error/error.dart'
    hide
        // ignore: undefined_hidden_name, Needed to support lower analyzer versions
        LintCode;
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

  test('Respects configSeverities when converting errors', () {
    final resourceProvider = MemoryResourceProvider();
    final source = FileSource(
      resourceProvider.newFile(
        '/home/user/project/lib/main.dart',
        'void main() {}',
      ),
    );

    // Create an analysis error with INFO severity
    final error = AnalysisError.tmp(
      source: source,
      offset: 0,
      length: 4,
      errorCode: const LintCode(
        name: 'rule_name_1',
        problemMessage: 'This is a lint',
      ),
    );

    // Create config severities map that changes rule_name_1 to ERROR
    final configSeverities = <String, ErrorSeverity>{
      'rule_name_1': ErrorSeverity.ERROR,
      'rule_name_2': ErrorSeverity.WARNING,
    };

    final converter = CustomAnalyzerConverter();

    // Convert the error without config severities - should be INFO
    final defaultResult = converter.convertAnalysisError(error);
    expect(defaultResult.severity.name, 'INFO');

    // Convert the error with direct severity override
    final withSeverityParam = converter.convertAnalysisError(
      error,
      severity: ErrorSeverity.ERROR,
    );
    expect(withSeverityParam.severity.name, 'ERROR');

    // Convert the error with config severities through convertAnalysisErrors
    final withConfigSeverities = converter.convertAnalysisErrors(
      [error],
      configSeverities: configSeverities,
    ).single;

    // Config severities should have overridden the default severity
    expect(withConfigSeverities.severity.name, 'ERROR');

    // Create an error with a rule name that doesn't have a config severity
    final errorWithoutConfigSeverity = AnalysisError.tmp(
      source: source,
      offset: 0,
      length: 4,
      errorCode: const LintCode(
        name: 'no_config_rule',
        problemMessage: 'This is another lint',
      ),
    );

    final noConfigResult = converter.convertAnalysisErrors(
      [errorWithoutConfigSeverity],
      configSeverities: configSeverities,
    ).single;

    // Should use default severity when not in config
    expect(noConfigResult.severity.name, 'INFO');
  });
}
