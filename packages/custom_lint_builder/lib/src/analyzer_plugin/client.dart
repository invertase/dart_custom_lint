import 'package:analyzer/dart/analysis/context_locator.dart' as analyzer;
import 'package:analyzer/dart/analysis/context_root.dart' as analyzer;
import 'package:analyzer/dart/analysis/results.dart' as analyzer;
import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/file_system/file_system.dart' as analyzer;
// ignore: implementation_imports
import 'package:analyzer/src/dart/analysis/context_builder.dart' as analyzer;
// ignore: implementation_imports
import 'package:analyzer/src/dart/analysis/driver.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart'
    as analyzer_plugin;
import 'package:analyzer_plugin/protocol/protocol_generated.dart'
    as analyzer_plugin;
import 'package:source_span/source_span.dart' as source_span;

import '../../protocol.dart';
import '../internal_protocol.dart';
import '../plugin_base.dart';
import 'plugin_client.dart';

/// An internal client for connecting a custom_lint plugin to the server
/// using the analyzer_plugin protocol
class Client extends ClientPlugin {
  /// An internal client for connecting a custom_lint plugin to the server
  /// using the analyzer_plugin protocol
  Client(this.plugin, [ResourceProvider? provider]) : super(provider);

  /// The plugin that will be connected to the analyzer server
  final PluginBase plugin;

  @override
  List<String> get fileGlobsToAnalyze => ['*.g.dart'];

  @override
  String get name => 'foo';

  @override
  String get version => '1.0.0-alpha.0';

  @override
  AnalysisDriver createAnalysisDriver(
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
    final sourceFile =
        source_span.SourceFile.fromString(analysisResult.content);

    return analyzer_plugin.AnalysisErrorsParams(
      analysisResult.path,
      plugin
          // TODO handle error
          .getLints(analysisResult.libraryElement)
          .map((e) => e.encode(sourceFile, analysisResult.path))
          .toList(),
    );
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
    source_span.SourceFile sourceFileForLibrary,
    String filePath,
  ) {
    return analyzer_plugin.AnalysisError(
      severity.encode(),
      analyzer_plugin.AnalysisErrorType.LINT,
      location.encode(sourceFileForLibrary, filePath),
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
  analyzer_plugin.Location encode(
    source_span.SourceFile sourceFile,
    String filePath,
  ) {
    final span = toSourceSpan(sourceFile);

    return analyzer_plugin.Location(
      filePath,
      span.start.offset,
      span.length,
      span.start.line,
      span.start.column,
      endLine: span.end.line,
      endColumn: span.end.column,
    );
  }
}
