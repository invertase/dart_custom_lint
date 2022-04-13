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
import 'package:source_span/source_span.dart';
import 'package:stack_trace/stack_trace.dart';

import '../../custom_lint_builder.dart';
import '../internal_protocol.dart';
import '../public_protocol.dart';
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
    context.driver.results.listen((analysisResult) {
      if (analysisResult is analyzer.ResolvedUnitResult) {
        if (analysisResult.exists) {
          channel.sendNotification(
            _getAnalysisErrorsForUnit(analysisResult).toNotification(),
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

  analyzer_plugin.AnalysisErrorsParams _getAnalysisErrorsForUnit(
    analyzer.ResolvedUnitResult analysisResult,
  ) {
    final lineInfo = analysisResult.lineInfo;
    final source = analysisResult.content;

    final ignoredCodes = _getAllIgnoredForFileCodes(analysisResult.content);

    try {
      return analyzer_plugin.AnalysisErrorsParams(
        analysisResult.path,
        ignoredCodes.contains('type=lint')
            // No need to run the plugin if lints are disabled in the file
            ? const []
            : plugin
                .getLints(analysisResult.libraryElement)
                .where(
                  (lint) =>
                      !ignoredCodes.contains(lint.code) &&
                      !_isIgnored(lint, lineInfo, source),
                )
                .map((e) => e.encode(lineInfo, analysisResult.path))
                .toList(),
      );
    } catch (err, stack) {
      // Sending the error back to the zone without rethrowing.
      // This allows the server can correctly log the error, and the client to
      // render the error at the top of the inspected file.
      Zone.current.handleUncaughtError(
        GetLintException(
          error: err,
          filePath: analysisResult.path,
        ),
        stack,
      );

      // TODO test and handle all error cases
      final trace = Trace.from(stack);

      final errorOriginFrame = trace.frames.first;

      final file = File.fromUri(errorOriginFrame.uri);
      final sourceFile = SourceFile.fromString(file.readAsStringSync());

      return analyzer_plugin.AnalysisErrorsParams(
        analysisResult.path,
        [
          analyzer_plugin.AnalysisError(
            analyzer_plugin.AnalysisErrorSeverity.ERROR,
            analyzer_plugin.AnalysisErrorType.LINT,
            LintLocation.fromLines(startLine: 0, endLine: 1)
                .encode(lineInfo, analysisResult.path),
            'A lint plugin threw an exception',
            'custom_lint_get_lint_fail',
            contextMessages: [
              analyzer_plugin.DiagnosticMessage(
                err.toString(),
                analyzer_plugin.Location(
                  // '/Users/remirousselet/dev/invertase/custom_lint/packages/example_lint/bin/custom_lint.dart',
                  trace.frames.first.uri.toFilePath(),
                  sourceFile.getOffset(
                    // frame location indices start at 1 not 0 so removing -1
                    (errorOriginFrame.line ?? 1) - 1,
                    (errorOriginFrame.column ?? 1) - 1,
                  ),
                  0,
                  errorOriginFrame.line ?? 1,
                  errorOriginFrame.column ?? 1,
                ),
              ),
            ],
          ),
        ],
      );
    }
  }

  @override
  Future<GetAnalysisErrorResult> handleGetAnalysisErrors(
    GetAnalysisErrorParams parameters,
  ) async {
    return GetAnalysisErrorResult(
      await Stream.fromIterable(parameters.files)
          .asyncMap((file) async {
            final driver = driverForPath(file);
            final unit = await driver?.getResult(file);

            if (unit is analyzer.ResolvedUnitResult) {
              return unit;
            }
            return null;
          })
          .where((e) => e != null)
          .cast<analyzer.ResolvedUnitResult>()
          .asyncMap(_getAnalysisErrorsForUnit)
          // ignore: avoid_types_on_closure_parameters, false positive because of implicit-dynamic
          .handleError((Object err, StackTrace stack) {
            channel.sendNotification(
              analyzer_plugin.PluginErrorParams(
                false,
                err.toString(),
                stack.toString(),
              ).toNotification(),
            );
          })
          .toList(),
    );
  }
}

final _ignoreRegex = RegExp(r'//\s*ignore\s*:(.+)$', multiLine: true);
final _ignoreForFileRegex =
    RegExp(r'//\s*ignore_for_file\s*:(.+)$', multiLine: true);

bool _isIgnored(Lint lint, LineInfo lineInfo, String source) {
  final span = lint.location.getRange(lineInfo);
  // -1 because lines starts at 1 not 0
  final line = span.startLocation.lineNumber - 1;

  if (line == 0) return false;

  final previousLine = source.substring(
    lineInfo.getOffsetOfLine(line - 1),
    span.startOffset - 1,
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
  analyzer_plugin.AnalysisError encode(
    LineInfo lineInfo,
    String filePath,
  ) {
    return analyzer_plugin.AnalysisError(
      severity.encode(),
      analyzer_plugin.AnalysisErrorType.LINT,
      location.encode(lineInfo, filePath),
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
  analyzer_plugin.Location encode(LineInfo lineInfo, String filePath) {
    final span = getRange(lineInfo);

    return analyzer_plugin.Location(
      filePath,
      span.startOffset,
      span.endOffset - span.startOffset,
      // Removing -1 because lineNumber/columnNumber starts at 1 instead of 0
      span.startLocation.lineNumber - 1,
      span.startLocation.columnNumber - 1,
      endLine: span.endLocation.lineNumber - 1,
      endColumn: span.endLocation.columnNumber - 1,
    );
  }
}
