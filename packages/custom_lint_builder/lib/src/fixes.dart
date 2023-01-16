import 'package:analyzer/error/error.dart';
import 'package:meta/meta.dart';

import 'change_reporter.dart';
import 'lint_rule.dart';
import 'node_lint_visitor.dart';
import 'resolver.dart';

@immutable
abstract class Fix {
  /// A list of glob patterns matching the files that [run] cares about.
  ///
  /// This can include Dart files, Yaml files, ...
  List<String> get filesToAnalyze;

  /// Emits lints for a given file.
  ///
  /// [run] will only be invoked with files respecting [filesToAnalyze]
  Future<void> startUp(
    CustomLintResolver resolver,
    LintContext context,
  ) async {}

  /// Emits lints for a given file.
  ///
  /// [run] will only be invoked with files respecting [filesToAnalyze]
  /// Emits source changes for a given error.
  ///
  /// Optionally [others] can be specified with a list of similar errors within
  /// the same file.
  /// This can be used to provide an option for fixing multiple errors at once.
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    LintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  );
}

@immutable
abstract class DartFix extends Fix {
  static final _stateKey = Object();

  @override
  List<String> get filesToAnalyze => const ['*.dart'];

  @override
  Future<void> startUp(
    CustomLintResolver resolver,
    LintContext context,
  ) async {
    // Relying on shared state to execute all linters in a single AstVisitor
    if (context.sharedState.containsKey(_stateKey)) return;
    context.sharedState[_stateKey] = Object();

    final unit = await resolver.getResolvedUnitResult();

    context.addPostRunCallback(() {
      final linterVisitor = LinterVisitor(context.registry.nodeLintRegistry);

      unit.unit.accept(linterVisitor);
    });
  }
}
