import 'dart:async';
import 'dart:io';

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:meta/meta.dart';
import 'package:pubspec_parse/pubspec_parse.dart';
import '../custom_lint_core.dart';
import 'node_lint_visitor.dart';
import 'plugin_base.dart';
import 'resolver.dart';

/// An object for state shared between multiple [LintRule]/[Assist]/[Fix]...
class CustomLintContext {
  /// Create a [CustomLintContext].
  @internal
  CustomLintContext(
    this.registry,
    this._addPostRunCallback,
    this.sharedState,
    Pubspec? pubspec,
  ) : pubspec = pubspec ?? Pubspec('test_project');

  /// An object used to listen to the analysis of a Dart file.
  ///
  /// Using [registry], we can add listeners to specific [AstNode]s.
  /// The listeners will be executed after the `run` function has ended.
  final LintRuleNodeRegistry registry;

  /// An object shared with all lint rules/fixes/assits running.
  final Map<Object, Object?> sharedState;

  /// The pubspec of the analyzed project.
  ///
  /// This can be used to disable a lint rule based on the presence/absence of a dependency.
  final Pubspec pubspec;

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
  List<String> get filesToAnalyze => const ['**.dart'];

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

  /// Runs this assist in test mode.
  ///
  /// The result will contain all the changes that would have been applied by [run].
  ///
  /// The parameter [pubspec] can be used to simulate a pubspec file which will
  /// be passed to [CustomLintContext.pubspec].
  /// By default, an empty pubspec with the name `test_project` will be used.
  @visibleForTesting
  Future<List<AnalysisError>> testRun(
    ResolvedUnitResult result, {
    Pubspec? pubspec,
  }) async {
    final registry = LintRuleNodeRegistry(
      NodeLintRegistry(LintRegistry(), enableTiming: false),
      'unknown',
    );
    final postRunCallbacks = <void Function()>[];
    final context = CustomLintContext(
      registry,
      postRunCallbacks.add,
      {},
      pubspec,
    );
    final resolver = CustomLintResolverImpl(
      () => Future.value(result),
      lineInfo: result.lineInfo,
      path: result.path,
      source: result.libraryElement.source,
    );

    final listener = RecordingErrorListener();
    final reporter = ErrorReporter(
      listener,
      result.libraryElement.source,
      isNonNullableByDefault: false,
    );

    await startUp(resolver, context);

    run(resolver, reporter, context);
    runPostRunCallbacks(postRunCallbacks);

    return listener.errors;
  }

  /// Analyze a Dart file and runs this assist in test mode.
  ///
  /// The result will contain all the changes that would have been applied by [run].
  @visibleForTesting
  Future<List<AnalysisError>> testAnalyzeAndRun(File file) async {
    final result = await resolveFile2(path: file.path);
    result as ResolvedUnitResult;
    return testRun(result);
  }
}
