import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

bool _isProvider(DartType type) {
  final element = type.element;
  if (element is! ClassElement) return false;
  final source = element.librarySource.uri;

  final isProviderBase = source.scheme == 'package' &&
      source.pathSegments.first == 'riverpod' &&
      element.name == 'ProviderBase';

  return isProviderBase || element.allSupertypes.any(_isProvider);
}

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
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    LintContext context,
  ) {
    context.registry.addVariableDeclaration((node) {
      final element = node.declaredElement;
      if (element == null || element.isFinal || !_isProvider(element.type)) {
        return;
      }

      reporter.reportErrorForElement(PreferFinalProviders._code, element);
    });
  }

  @override
  List<Fix> getFixes() => [_MakrProviderFinalFix()];
}

class _MakrProviderFinalFix extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    LintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    final changeBuilder = reporter.createChangeBuilder(
      priority: 1,
      message: 'Make provider final',
    );
  }
}

class _ConvertToStreamProvider extends DartAssist {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    LintContext context,
    SourceRange target,
  ) {
    context.registry.addVariableDeclaration((node) {
      if (!target.intersects(SourceRange(node.offset, node.length))) {
        return;
      }

      final element = node.declaredElement;
      if (element == null || element.isFinal || !_isProvider(element.type)) {
        return;
      }

      final changeBuilder = reporter.createChangeBuilder(
        priority: 1,
        message: 'Convert to StreamProvider',
      );
    });
  }
}
