import 'dart:async';

import 'package:analyzer/error/listener.dart';
import 'package:meta/meta.dart';
import '../custom_lint_builder.dart';
import 'node_lint_visitor.dart';

class LintContext {
  LintContext(this.registry, this._addPostRunCallback, this.sharedState);

  final LintRuleNodeRegistry registry;
  final Map<Object, Object?> sharedState;
  final void Function(void Function() cb) _addPostRunCallback;

  void addPostRunCallback(void Function() cb) {
    _addPostRunCallback(Zone.current.bindCallback(cb));
  }
}

@immutable
abstract class LintRule {
  const LintRule({required this.code});

  final LintCode code;

  /// Whether the lint rule is on or off by default in an empty analysis_options.yaml
  bool get enabledByDefault => true;

  /// A list of glob patterns matching the files that [run] cares about.
  ///
  /// This can include Dart files, Yaml files, ...
  List<String> get filesToAnalyze;

  bool isEnabled(CustomLintConfigs configs) {
    return configs.rules[code.name]?.enabled ??
        configs.enableAllLintRules ??
        enabledByDefault;
  }

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
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    LintContext context,
  );

  List<Fix> getFixes() => const [];
}

@immutable
abstract class DartLintRule extends LintRule {
  const DartLintRule({required super.code});

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
