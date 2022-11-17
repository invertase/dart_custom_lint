import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:ci/ci.dart' as ci;

import 'analyzer_plugin.dart';
import 'client_isolate_channel.dart';
import 'plugin_delegate.dart';

/// Connects custom_lint to the analyzer server using the analyzer_plugin protocol
void start(Iterable<String> _, SendPort sendPort) {
  CustomLintPlugin? server;

  runZonedGuarded(
    () {
      final channel = ClientIsolateChannel(sendPort);
      server = CustomLintPlugin(
        delegate: AnalyzerPluginCustomLintDelegate(),
        includeBuiltInLints:
            // Disable "loading" lints custom_lint is spawned from a terminal command;
            // such as when using `dart analyze`
            !stdin.hasTerminal &&
                // In the CI, hasTerminal is often false. So let's explicitly disable
                // "loading" lints for the CI too
                !ci.isCI,
        // The necessary flags for hot-reload to work aren't set by analyzer_plugin
        watchMode: false,
      );
      server!.start(channel);
    },
    (err, stack) => server?.handleUncaughtError(err, stack),
  );
}
