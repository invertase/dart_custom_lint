import 'dart:io' as io;

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';
import 'package:meta/meta.dart';
import 'package:pubspec_parse/pubspec_parse.dart';

import 'change_reporter.dart';
import 'fixes.dart';
import 'lint_rule.dart';
import 'node_lint_visitor.dart';
import 'plugin_base.dart';
import 'resolver.dart';

/// A base class for assists.
///
/// Assists are more typically known as "refactoring". They are changes
/// triggered by the user, without an associated problem. As opposed to a [Fix],
/// which represents a source change but is associated with an issue.
///
/// For creating assists inside Dart files, see [DartAssist].
///
/// Suclassing [Assist] can be helpful if you wish to implement assists for
/// non-Dart files (yaml, json, ...)
///
/// For usage information, see https://github.com/invertase/dart_custom_lint/blob/main/docs/assists.md
@immutable
abstract class Assist {
  /// A list of glob patterns matching the files that [run] cares about.
  ///
  /// This can include Dart files, Yaml files, ...
  List<String> get filesToAnalyze;

  /// Emits lints for a given file.
  ///
  /// [run] will only be invoked with files respecting [filesToAnalyze]
  Future<void> startUp(
    CustomLintResolver resolver,
    CustomLintContext context,
    SourceRange target,
  ) async {}

  /// Emits lints for a given file.
  ///
  /// [run] will only be invoked with files respecting [filesToAnalyze]
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    SourceRange target,
  );
}

/// A base class for creating assists inside Dart files.
///
/// For usage information, see https://github.com/invertase/dart_custom_lint/blob/main/docs/assists.md#Defining-a-dart-assist
@immutable
abstract class DartAssist extends Assist {
  static final _stateKey = Object();

  @override
  List<String> get filesToAnalyze => const ['**.dart'];

  @override
  Future<void> startUp(
    CustomLintResolver resolver,
    CustomLintContext context,
    SourceRange target,
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
  Future<List<PrioritizedSourceChange>> testRun(
    ResolvedUnitResult result,
    SourceRange target, {
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
    final reporter = ChangeReporterImpl(result.session, resolver);

    await startUp(
      resolver,
      context,
      target,
    );

    run(resolver, reporter, context, target);
    runPostRunCallbacks(postRunCallbacks);

    return reporter.waitForCompletion();
  }

  /// Analyze a Dart file and runs this assist in test mode.
  ///
  /// The result will contain all the changes that would have been applied by [run].
  @visibleForTesting
  Future<List<PrioritizedSourceChange>> testAnalyzeAndRun(
    io.File file,
    SourceRange target,
  ) async {
    final result = await resolveFile2(path: file.path);
    result as ResolvedUnitResult;
    return testRun(result, target);
  }
}
