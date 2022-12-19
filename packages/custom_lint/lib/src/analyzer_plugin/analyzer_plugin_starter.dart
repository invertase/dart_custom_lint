import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:ci/ci.dart' as ci;

// import 'analyzer_plugin.dart';
// import '../analyzer_plugin_isolate_channel.dart';
import '../channels.dart';
// import 'client_isolate_channel.dart';
import '../v2/custom_lint_analyzer_plugin.dart';
import 'plugin_delegate.dart';

/// Connects custom_lint to the analyzer server using the analyzer_plugin protocol
void start(Iterable<String> _, SendPort sendPort) {
  // CustomLintServer? server;

  // runZonedGuarded(
  //   () {
  //     server = CustomLintServer(
  //       delegate: AnalyzerPluginCustomLintDelegate(),
  //       includeBuiltInLints:
  //           // Disable "loading" lints custom_lint is spawned from a terminal command;
  //           // such as when using `dart analyze`
  //           !stdin.hasTerminal &&
  //               // In the CI, hasTerminal is often false. So let's explicitly disable
  //               // "loading" lints for the CI too
  //               !ci.isCI,
  //       // The necessary flags for hot-reload to work aren't set by analyzer_plugin
  //       watchMode: false,
  //       analyzerPluginChannel: AnalyzerPluginIsolateChannel(sendPort),
  //     );
  //   },
  //   (err, stack) => server?.handleUncaughtError(err, stack),
  //   zoneSpecification: ZoneSpecification(
  //     print: (self, parent, zone, line) => server?.handlePrint(line),
  //   ),
  // );

  CustomLintServer? server;

  runZonedGuarded(
    () {
      server = CustomLintServer(
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
        // analyzerPluginChannel: AnalyzerPluginIsolateChannel(sendPort),
        analyzerPluginClientChannel: JsonSendPortChannel(sendPort),
      );
    },
    (err, stack) => server?.handleUncaughtError(err, stack),
    zoneSpecification: ZoneSpecification(
      print: (self, parent, zone, line) => server?.handlePrint(line),
    ),
  );
}
