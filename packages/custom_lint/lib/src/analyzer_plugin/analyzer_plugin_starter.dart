import 'dart:async';
import 'dart:isolate';

import 'analyzer_plugin.dart';
import 'client_isolate_channel.dart';
import 'plugin_delegate.dart';

/// Connects custom_lint to the analyzer server using the analyzer_plugin protocol
void start(Iterable<String> _, SendPort sendPort) {
  CustomLintPlugin? server;

  runZonedGuarded(
    () {
      final channel = ClientIsolateChannel(sendPort);
      server = CustomLintPlugin(delegate: AnalyzerPluginCustomLintDelegate());
      server!.start(channel);
    },
    (err, stack) => server?.handleUncaughtError(err, stack),
  );
}
