import 'dart:async';
import 'dart:io';

import 'package:analyzer/dart/analysis/context_locator.dart' as analyzer;
import 'package:analyzer/dart/analysis/context_root.dart' as analyzer;
import 'package:analyzer/dart/analysis/results.dart' as analyzer;
import 'package:analyzer/file_system/file_system.dart' as analyzer;
import 'package:analyzer/source/line_info.dart';
// ignore: implementation_imports
import 'package:analyzer/src/dart/analysis/context_builder.dart' as analyzer;
// ignore: implementation_imports
import 'package:analyzer/src/dart/analysis/driver.dart' as analyzer;
import 'package:analyzer_plugin/protocol/protocol_common.dart'
    as analyzer_plugin;
import 'package:analyzer_plugin/protocol/protocol_generated.dart'
    as analyzer_plugin;
import 'package:collection/collection.dart';
import 'package:source_span/source_span.dart';
import 'package:stack_trace/stack_trace.dart';

import '../../custom_lint_builder.dart';
import '../internal_protocol.dart';
import 'plugin_client.dart';

/// An exception thrown during [PluginBase.getLints].
class GetLintException implements Exception {
  /// An exception thrown during [PluginBase.getLints].
  GetLintException({required this.error, required this.filePath});

  /// The thrown exception by [PluginBase.getLints].
  final Object error;

  /// The while that was being analyzed
  final String filePath;

  @override
  String toString() {
    return 'The following exception was thrown while trying to obtain lints for $filePath:\n'
        '$error';
  }
}

/// An internal client for connecting a custom_lint plugin to the server
/// using the analyzer_plugin protocol
class Client extends ClientPlugin {
  /// An internal client for connecting a custom_lint plugin to the server
  /// using the analyzer_plugin protocol
  Client(this.plugin, [analyzer.ResourceProvider? provider]) : super(provider);

  /// The plugin that will be connected to the analyzer server
  final PluginBase plugin;

  late bool _includeBuiltInLints;

  @override
  List<String> get fileGlobsToAnalyze => ['*.dart'];

  @override
  String get name => 'custom_lint_client';

  @override
  String get version => '1.0.0-alpha.0';

  @override
  analyzer.AnalysisDriver createAnalysisDriver(
    analyzer_plugin.ContextRoot contextRoot,
  ) {
    final analyzerContextRoot = contextRoot.asAnalayzerContextRoot(
      resourceProvider: resourceProvider,
    );

    final builder = analyzer.ContextBuilderImpl(
      resourceProvider: resourceProvider,
    );
    final context = builder.createContext(contextRoot: analyzerContextRoot);

// TODO cancel sub
    context.driver.results.listen((analysisResult) async {
      if (analysisResult is analyzer.ResolvedUnitResult) {
        if (analysisResult.exists) {
          channel.sendNotification(
            await _getAnalysisErrorsForUnit(analysisResult)
                .then((e) => e.toNotification()),
          );
        }
      } else if (analysisResult is analyzer.ErrorsResult) {
        // TODO handle
      } else {
        throw UnsupportedError('Unknown result type $analysisResult');
      }
    });

    return context.driver;
  }

  Future<analyzer_plugin.AnalysisErrorsParams> _getAnalysisErrorsForUnit(
    analyzer.ResolvedUnitResult analysisResult,
  ) async {
    final lineInfo = analysisResult.lineInfo;
    final source = analysisResult.content;

    final ignoredCodes = _getAllIgnoredForFileCodes(analysisResult.content);

    try {
      return analyzer_plugin.AnalysisErrorsParams(
        analysisResult.path,
        ignoredCodes.contains('type=lint')
            // No need to run the plugin if lints are disabled in the file
            ? const []
            : await plugin
                // TODO support cases where getLints is called again while the previous getLints is still pending
                .getLints(analysisResult)
                .where(
                  (lint) =>
                      !ignoredCodes.contains(lint.code) &&
                      !_isIgnored(lint, lineInfo, source),
                )
                .map((e) => e.encode())
                .toList(),
      );
    } catch (err, stack) {
      final rethrownError = GetLintException(
        error: err,
        filePath: analysisResult.path,
      );

      if (!_includeBuiltInLints) {
        Error.throwWithStackTrace(rethrownError, stack);
      }

      // TODO test and handle all error cases
      final trace = Trace.from(stack);

      final firstFileFrame = trace.frames.firstWhereOrNull(
        (frame) => frame.uri.scheme == 'file',
      );

      if (firstFileFrame == null) {
        Error.throwWithStackTrace(rethrownError, stack);
      }

      // Sending the error back to the zone without rethrowing.
      // This allows the server can correctly log the error, and the client to
      // render the error at the top of the inspected file.
      Zone.current.handleUncaughtError(rethrownError, stack);

      final file = File.fromUri(firstFileFrame.uri);
      final sourceFile = SourceFile.fromString(file.readAsStringSync());

      return analyzer_plugin.AnalysisErrorsParams(
        analysisResult.path,
        [
          analyzer_plugin.AnalysisError(
            analyzer_plugin.AnalysisErrorSeverity.ERROR,
            analyzer_plugin.AnalysisErrorType.LINT,
            analysisResult
                .lintLocationFromLines(startLine: 1, endLine: 2)
                .encode(),
            'A lint plugin threw an exception',
            'custom_lint_get_lint_fail',
            contextMessages: [
              analyzer_plugin.DiagnosticMessage(
                err.toString(),
                analyzer_plugin.Location(
                  firstFileFrame.library,
                  sourceFile.getOffset(
                    // frame location indices start at 1 not 0 so removing -1
                    (firstFileFrame.line ?? 1) - 1,
                    (firstFileFrame.column ?? 1) - 1,
                  ),
                  0,
                  firstFileFrame.line ?? 1,
                  firstFileFrame.column ?? 1,
                ),
              ),
            ],
          ),
        ],
      );
    }
  }

  @override
  Future<AwaitAnalysisDoneResult> handleAwaitAnalysisDone(
    AwaitAnalysisDoneParams parameters,
  ) async {
    bool hasPendingDriver() {
      return driverMap.values.any((driver) => driver.hasFilesToAnalyze);
    }

    while (hasPendingDriver()) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }

    return const AwaitAnalysisDoneResult();
  }

  @override
  Future<SetConfigResult> handleSetConfig(SetConfigParams params) async {
    _includeBuiltInLints = params.includeBuiltInLints;
    return const SetConfigResult();
  }
}

final _ignoreRegex = RegExp(r'//\s*ignore\s*:(.+)$', multiLine: true);
final _ignoreForFileRegex =
    RegExp(r'//\s*ignore_for_file\s*:(.+)$', multiLine: true);

bool _isIgnored(Lint lint, LineInfo lineInfo, String source) {
  // -1 because lines starts at 1 not 0
  final line = lint.location.startLine - 1;

  if (line == 0) return false;

  final previousLine = source.substring(
    lineInfo.getOffsetOfLine(line - 1),
    lint.location.offset - 1,
  );

  final codeContent = _ignoreRegex.firstMatch(previousLine)?.group(1);
  if (codeContent == null) return false;

  final codes = codeContent.split(',').map((e) => e.trim()).toSet();

  return codes.contains(lint.code) || codes.contains('type=lint');
}

Set<String> _getAllIgnoredForFileCodes(String source) {
  return _ignoreForFileRegex
      .allMatches(source)
      .map((e) => e.group(1)!)
      .expand((e) => e.split(','))
      .map((e) => e.trim())
      .toSet();
}

extension on analyzer_plugin.ContextRoot {
  analyzer.ContextRoot asAnalayzerContextRoot({
    required analyzer.ResourceProvider resourceProvider,
  }) {
    final locator =
        analyzer.ContextLocator(resourceProvider: resourceProvider).locateRoots(
      includedPaths: [root],
      excludedPaths: exclude,
      optionsFile: optionsFile,
    );

    return locator.single;
  }
}

extension on Lint {
  analyzer_plugin.AnalysisError encode() {
    return analyzer_plugin.AnalysisError(
      severity.encode(),
      analyzer_plugin.AnalysisErrorType.LINT,
      location.encode(),
      message,
      code,
      correction: correction,
      url: url,
      // TODO contextMessages & hasFix
    );
  }
}

extension on LintSeverity {
  analyzer_plugin.AnalysisErrorSeverity encode() {
    switch (this) {
      case LintSeverity.error:
        return analyzer_plugin.AnalysisErrorSeverity.ERROR;
      case LintSeverity.warning:
        return analyzer_plugin.AnalysisErrorSeverity.WARNING;
      case LintSeverity.info:
        return analyzer_plugin.AnalysisErrorSeverity.INFO;
    }
  }
}

extension on LintLocation {
  analyzer_plugin.Location encode() {
    return analyzer_plugin.Location(
      filePath,
      offset,
      length,
      startLine,
      startColumn,
      endLine: endLine,
      endColumn: endColumn,
    );
  }
}
