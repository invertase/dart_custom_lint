import 'package:analyzer/dart/analysis/context_locator.dart' as analyzer;
import 'package:analyzer/dart/analysis/context_root.dart' as analyzer;
import 'package:analyzer/dart/analysis/results.dart' as analyzer;
import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/file_system/file_system.dart' as analyzer;
// ignore: implementation_imports
import 'package:analyzer/src/dart/analysis/context_builder.dart' as analyzer;
// ignore: implementation_imports
import 'package:analyzer/src/dart/analysis/driver.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart'
    as analyzer_plugin;
import 'package:custom_lint/protocol.dart';

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
    print('createAnalysisDriver');
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
        print('result: ${analysisResult.path} for ${contextRoot.root}');

        if (analysisResult.exists) {
          channel.sendNotification(
            _getAnalysisErrorsForUnit(analysisResult).toNotification(),
          );
        }
      } else if (analysisResult is analyzer.ErrorsResult) {
        print('error at ${analysisResult.path} for ${contextRoot.root}');
      } else {
        print('StateError $analysisResult');
      }
    });

    return context.driver;
  }

  analyzer_plugin.AnalysisErrorsParams _getAnalysisErrorsForUnit(
    analyzer.ResolvedUnitResult analysisResult,
  ) {
    return analyzer_plugin.AnalysisErrorsParams(
      analysisResult.path,
      // TODO handle error
      plugin.getLints(analysisResult.libraryElement).toList(),
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

  @override
  Future<analyzer_plugin.EditGetFixesResult> handleEditGetFixes(
    analyzer_plugin.EditGetFixesParams parameters,
  ) async {
    final result =
        await driverForPath(parameters.file)?.getResult(parameters.file);
    if (result != null && result is analyzer.ResolvedUnitResult) {
      return analyzer_plugin.EditGetFixesResult(
        plugin
            .getFixes(
              result.libraryElement,
              parameters.offset,
            )
            .toList(),
      );
    }
    return super.handleEditGetFixes(parameters);
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
