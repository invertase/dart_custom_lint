import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

const _providerBaseChecker =
    TypeChecker.fromName('ProviderBase', packageName: 'riverpod');

PluginBase createPlugin() => _RiverpodLint();

class _RiverpodLint extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
        PreferFinalProviders(),
      ];

  @override
  List<Assist> getAssists() => [_ConvertToStreamProvider()];
}

class PreferFinalProviders extends DartLintRule {
  PreferFinalProviders() : super(code: _code);

  static const _code = LintCode(
    name: 'riverpod_final_provider',
    problemMessage: 'Providers should be declared using the `final` keyword.',
  );

  /// Emits lints for a given file.
  ///
  /// [run] will only be invoked with files respecting [filesToAnalyze]
  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addVariableDeclaration((node) {
      final element = node.declaredElement;
      if (element == null ||
          element.isFinal ||
          !_providerBaseChecker.isAssignableFromType(element.type)) {
        return;
      }

      reporter.reportErrorForElement(code, element);
    });
  }

  @override
  List<Fix> getFixes() => [_MakeProviderFinalFix()];
}

class _MakeProviderFinalFix extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addVariableDeclarationList((node) {
      if (!analysisError.sourceRange.intersects(node.sourceRange)) return;

      final changeBuilder = reporter.createChangeBuilder(
        priority: 1,
        message: 'Make provider final',
      );
      changeBuilder.addDartFileEdit((builder) {
        final nodeKeyword = node.keyword;
        final nodeType = node.type;
        if (nodeKeyword != null) {
          // var x = ... => final x = ...
          builder.addSimpleReplacement(
            SourceRange(nodeKeyword.offset, nodeKeyword.length),
            'final',
          );
        } else if (nodeType != null) {
          // Type x = ... => final Type x = ...
          builder.addSimpleInsertion(nodeType.offset, 'final ');
        }
      });
    });
  }
}

class _ConvertToStreamProvider extends DartAssist {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    SourceRange target,
  ) {
    context.registry.addVariableDeclaration((node) {
      // Check that the visited node is under the cursor
      if (!target.intersects(node.sourceRange)) return;

      // verify that the visited node is a provider, to only show the assist on providers
      final element = node.declaredElement;
      if (element == null ||
          element.isFinal ||
          !_providerBaseChecker.isAssignableFromType(element.type)) {
        return;
      }

      final changeBuilder = reporter.createChangeBuilder(
        priority: 1,
        message: 'Convert to StreamProvider',
      );
      changeBuilder.addDartFileEdit((builder) {
        // TODO implement change to refactor the provider
      });
    });
  }
}
