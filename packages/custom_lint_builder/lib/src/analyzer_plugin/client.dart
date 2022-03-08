import 'package:analyzer/dart/analysis/context_locator.dart' as analyzer;
import 'package:analyzer/dart/analysis/context_root.dart' as analyzer;
import 'package:analyzer/dart/analysis/results.dart' as analyzer;
import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/file_system/file_system.dart' as analyzer;
// ignore: implementation_imports
import 'package:analyzer/src/dart/analysis/context_builder.dart' as analyzer;
// ignore: implementation_imports
import 'package:analyzer/src/dart/analysis/driver.dart';
import 'package:analyzer_plugin/protocol/protocol.dart' as analyzer_plugin;
import 'package:analyzer_plugin/protocol/protocol_common.dart'
    as analyzer_plugin;
import 'package:analyzer_plugin/protocol/protocol_generated.dart'
    as analyzer_plugin;

import '../plugin_base.dart';
import 'plugin_client.dart';

class Client extends ClientPlugin {
  Client(this.plugin, [ResourceProvider? provider]) : super(provider);

  final PluginBase plugin;

  @override
  List<String> get fileGlobsToAnalyze => ['*.g.dart'];

  @override
  String get name => 'foo';

  @override
  String get version => '1.0.0-alpha.0';

  @override
  AnalysisDriver createAnalysisDriver(
    analyzer_plugin.ContextRoot pluginContextRoot,
  ) {
    print('createAnalysisDriver');
    final contextRoot = pluginContextRoot.asAnalayzerContextRoot(
      resourceProvider: resourceProvider,
    );

    final builder = analyzer.ContextBuilderImpl(
      resourceProvider: resourceProvider,
    );
    final context = builder.createContext(contextRoot: contextRoot);

// TODO cancel sub
    context.driver.results.listen((analysisResult) {
      if (analysisResult is analyzer.ResolvedUnitResult) {
        print('result: ${analysisResult.path} for ${pluginContextRoot.root}');

        if (analysisResult.exists) {
          channel.sendNotification(
            analyzer_plugin.AnalysisErrorsParams(
              analysisResult.path,
              // TODO handle error
              plugin.getLints(analysisResult.libraryElement).toList(),
            ).toNotification(),
          );
        }
      } else if (analysisResult is analyzer.ErrorsResult) {
        print('error at ${analysisResult.path} for ${pluginContextRoot.root}');
      } else {
        print('StateError $analysisResult');
      }
    });

    return context.driver;
  }

  @override
  Future<analyzer_plugin.EditGetFixesResult> handleEditGetFixes(
    analyzer_plugin.EditGetFixesParams parameters,
  ) async {
    final result =
        await (this.driverForPath(parameters.file) as AnalysisDriver?)
            ?.getResult(parameters.file);
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
