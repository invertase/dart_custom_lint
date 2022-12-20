import 'dart:isolate';

import 'plugin_delegate.dart';

import 'v2/custom_lint_analyzer_plugin.dart';

/// Connects custom_lint to the analyzer server using the analyzer_plugin protocol
void start(Iterable<String> _, SendPort sendPort) {
  final server = CustomLintServer(
    // In the IDE always enable hot-restart
    // TODO enable hot-restart only if running plugin from source (excluding pub cache)
    watchMode: true,
    delegate: AnalyzerPluginCustomLintDelegate(),
  );

  server.start(sendPort);
}
