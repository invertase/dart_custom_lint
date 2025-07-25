import 'dart:io';

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/error/error.dart'
    hide
        // ignore: undefined_hidden_name, Needed to support lower analyzer versions
        LintCode;
import 'package:analyzer_plugin/protocol/protocol_generated.dart';
import 'package:custom_lint_visitor/custom_lint_visitor.dart';
import 'package:meta/meta.dart';
import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:uuid/uuid.dart';

import 'change_reporter.dart';
import 'lint_rule.dart';
import 'plugin_base.dart';
import 'resolver.dart';
import 'runnable.dart';

/// Args for [Fix].
@internal
typedef FixArgs = ({
  ChangeReporter reporter,
  AnalysisError analysisError,
  List<AnalysisError> others,
});

const _uid = Uuid();

/// {@template custom_lint_builder.lint_rule}
/// A base class for defining quick-fixes for a [LintRule]
///
/// For creating assists inside Dart files, see [DartFix].
/// Subclassing [Fix] can be helpful if you wish to implement assists for
/// non-Dart files (yaml, json, ...)
///
/// For usage information, see https://github.com/invertase/dart_custom_lint/blob/main/docs/fixes.md
/// {@endtemplate}
@immutable
abstract class Fix extends Runnable<FixArgs> {
  /// A unique ID for a fix. Must be unique across all fixes of any package.
  ///
  /// This is used to know which fix triggered a change, for batch support.
  late final String id = _uid.v4();

  /// A list of glob patterns matching the files that [run] cares about.
  ///
  /// This can include Dart files, Yaml files, ...
  List<String> get filesToAnalyze;

  /// Emits lints for a given file.
  ///
  /// [run] will only be invoked with files respecting [filesToAnalyze]
  @override
  Future<void> startUp(
    CustomLintResolver resolver,
    CustomLintContext context,
  ) async {}

  @internal
  @override
  void callRun(
    CustomLintResolver resolver,
    CustomLintContext context,
    FixArgs args,
  ) {
    run(
      resolver,
      args.reporter,
      context,
      args.analysisError,
      args.others,
    );
  }

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
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  );
}

/// A base class for defining quick-fixes inside Dart files.
///
/// For usage information, see https://github.com/invertase/dart_custom_lint/blob/main/docs/fixes.md#Defining-dart-fix
@immutable
abstract class DartFix extends Fix {
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

  /// Runs this fix in test mode.
  ///
  /// The result will contain all the changes that would have been applied by [run].
  ///
  /// The parameter [pubspec] can be used to simulate a pubspec file which will
  /// be passed to [CustomLintContext.pubspec].
  /// By default, an empty pubspec with the name `test_project` will be used.
  @visibleForTesting
  Future<List<PrioritizedSourceChange>> testRun(
    ResolvedUnitResult result,
    AnalysisError analysisError,
    List<AnalysisError> others, {
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
      source: result.libraryElement2.firstFragment.source,
    );
    final reporter = ChangeReporterImpl(result.session, resolver);

    await startUp(resolver, context);
    run(resolver, reporter, context, analysisError, others);
    runPostRunCallbacks(postRunCallbacks);

    return reporter.complete();
  }

  /// Analyze a Dart file and runs this fix in test mode.
  ///
  /// The result will contain all the changes that would have been applied by [run].
  @visibleForTesting
  Future<List<PrioritizedSourceChange>> testAnalyzeAndRun(
    File file,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) async {
    final result = await resolveFile2(path: file.path);
    result as ResolvedUnitResult;
    return testRun(result, analysisError, others);
  }
}
