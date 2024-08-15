import 'dart:io';
import 'dart:isolate';

import 'package:ci/ci.dart' as ci;

import 'plugin_delegate.dart';
import 'v2/custom_lint_analyzer_plugin.dart';

/// Connects custom_lint to the analyzer server using the analyzer_plugin protocol
Future<void> start(Iterable<String> _, SendPort sendPort) async {
  final isInCI = ci.isCI;

  await CustomLintServer.start(
    sendPort: sendPort,
    includeBuiltInLints: true,
    // The IDE client should write to files, as what's visible in the editor
    // may not be the same as what's on disk.
    fix: false,
    // "start" may be run by `dart analyze`, in which case we don't want to
    // enable watch mode. There's no way to detect this, but this only matters
    // in the CI. So we disable watch mode if we detect that we're in CI.
    // TODO enable hot-restart only if running plugin from source (excluding pub cache)
    watchMode: isInCI ? false : null,
    delegate: AnalyzerPluginCustomLintDelegate(),
    workingDirectory: Directory.current,
  );
}
