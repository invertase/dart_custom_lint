import 'dart:io';
import 'dart:isolate';

import 'package:ci/ci.dart' as ci;

import 'plugin_delegate.dart';
import 'v2/custom_lint_analyzer_plugin.dart';

/// Connects custom_lint to the analyzer server using the analyzer_plugin protocol
void start(Iterable<String> _, SendPort sendPort) {
  final isInCI = ci.isCI;

  CustomLintServer.start(
    sendPort: sendPort,
    includeBuiltInLints: true,
    // "start" may be run by `dart analyze`, in which case we don't want to
    // enable watch mode. There's no way to detect this, but this only matters
    // in the CI. So we disble watch mode if we detect that we're in CI.
    // TODO enable hot-restart only if running plugin from source (excluding pub cache)
    watchMode: !isInCI,
    delegate: AnalyzerPluginCustomLintDelegate(),
    workingDirectory: Directory.current,
  );
}
