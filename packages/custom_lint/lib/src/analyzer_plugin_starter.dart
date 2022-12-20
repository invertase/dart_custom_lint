import 'dart:isolate';

import 'plugin_delegate.dart';

import 'v2/custom_lint_analyzer_plugin.dart';

/// Connects custom_lint to the analyzer server using the analyzer_plugin protocol
void start(Iterable<String> _, SendPort sendPort) {
  CustomLintServer.run(
    // The necessary flags for hot-reload to work aren't set by analyzer_plugin
    watchMode: false,
    delegate: AnalyzerPluginCustomLintDelegate(),
  );
}
