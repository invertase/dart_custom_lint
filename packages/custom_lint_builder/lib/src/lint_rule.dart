import 'dart:async';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:meta/meta.dart';
import '../custom_lint_builder.dart';
import 'node_lint_visitor.dart';

/// An object for state shared between multiple [LintRule]/[Assist]/[Fix]...
class CustomLintContext {
  /// Create a [CustomLintContext].
  @internal
  CustomLintContext(this.registry, this._addPostRunCallback, this.sharedState);

  /// An object used to listen to the analysis of a Dart file.
  ///
  /// Using [registry], we can add listeners to specific [AstNode]s.
  /// The listeners will be executed after the `run` function has ended.
  final LintRuleNodeRegistry registry;

  /// An object shared with all lint rules/fixes/assits running.
  final Map<Object, Object?> sharedState;

  final void Function(void Function() cb) _addPostRunCallback;

  /// Registers a function that will be executed after all [LintRule.run]
  /// (or [Assist.run]/[Fix.run] if associated to an assist/fix).
  void addPostRunCallback(void Function() cb) {
    _addPostRunCallback(Zone.current.bindCallback(cb));
  }
}

/// {@macro custom_lint_builder.lint_rule}
@immutable
abstract class LintRule {
  /// {@template custom_lint_builder.lint_rule}
  /// A base class for plugins to define emit warnings/errors/infos.
  ///
  /// For creating assists inside Dart files, see [DartLintRule].
  /// Suclassing [LintRule] can be helpful if you wish to implement assists for
  /// non-Dart files (yaml, json, ...)
  ///
  /// For usage information, see https://github.com/invertase/dart_custom_lint/blob/main/docs/lints.md
  /// {@endtemplate}
  const LintRule({required this.code});

  /// The [LintCode] that this [LintRule] may emit.
  ///
  /// [LintRule]s should avoid emitting lints that use a code different that [code].
  final LintCode code;

  /// An optional description about the lint rule, written in markdown.
  ///
  /// This information might be displayed in various places, such as:
  /// - a website listing all the lint rules implemented by a plugin
  /// - by the IDE during auto-completion in the `analysis_options.yaml`
  String? get description => null;

  /// Whether the lint rule is on or off by default in an empty analysis_options.yaml
  bool get enabledByDefault => true;

  /// A list of glob patterns matching the files that [run] cares about.
  ///
  /// This can include Dart files, Yaml files, ...
  List<String> get filesToAnalyze;

  /// Checks whether this lint rule is enabled in a configuration file.
  ///
  /// If a lint is neither enabled nor disabled by a configuration file,
  /// [enabledByDefault] will be checked.
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
    CustomLintContext context,
  ) async {}

  /// Emits lints for a given file.
  ///
  /// [run] will only be invoked with files respecting [filesToAnalyze]
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  );

  /// Obtains the list of [Fix] associated with this [LintRule].
  List<Fix> getFixes() => const [];
}

/// A base class for emitting warnings/errors/infos inside Dart files.
///
/// For usage information, see https://github.com/invertase/dart_custom_lint/blob/main/docs/lints.md#Defining-dart-lints
@immutable
abstract class DartLintRule extends LintRule {
  /// A base class for emitting warnings/errors/infos inside Dart files.
  ///
  /// For usage information, see https://github.com/invertase/dart_custom_lint/blob/main/docs/lints.md#Defining-dart-lints
  const DartLintRule({required super.code});

  static final _stateKey = Object();

  @override
  List<String> get filesToAnalyze => const ['*.dart'];

  @override
  Future<void> startUp(
    CustomLintResolver resolver,
    CustomLintContext context,
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
