import 'dart:io';

import 'package:analyzer_plugin/protocol/protocol.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart';

import 'v2/custom_lint_analyzer_plugin.dart';

/// A delegate for handling certain events based on the platform
abstract class CustomLintDelegate {
  /// The server threw an error
  void serverError(
    CustomLintServer serverPlugin,
    Object error,
    StackTrace stackTrace, {
    required List<ContextRoot> allContextRoots,
  });

  /// A plugin failed to start
  void pluginInitializationFail(
    CustomLintServer serverPlugin,
    Object err,
    StackTrace stackTrace, {
    required String pluginName,
    required List<ContextRoot> pluginContextRoots,
  });

  /// The server emitted a message
  void serverMessage(
    CustomLintServer serverPlugin,
    String message, {
    required List<ContextRoot> allContextRoots,
  });

  /// A plugin emitted a message
  void pluginMessage(
    CustomLintServer serverPlugin,
    String message, {
    required String pluginName,
    required List<ContextRoot> pluginContextRoots,
  });

  /// A plugin threw outside of a request
  void pluginError(
    CustomLintServer serverPlugin,
    String err,
    String stackTrace, {
    required String pluginName,
    required List<ContextRoot> pluginContextRoots,
  });

  /// A plugin threw during a request
  void requestError(
    CustomLintServer serverPlugin,
    Request request,
    RequestError requestError, {
    required List<ContextRoot> allContextRoots,
  });
}

/// Sends the output of some events into a log file
mixin LogCustomLintDelegate implements CustomLintDelegate {
  void _log(
    List<ContextRoot> contextRoots,
    String message, {
    required String? pluginName,
  }) {
    final now = DateTime.now();
    final label = '[$pluginName] ${now.toIso8601String()}';

    final msg = message
        .split('\n')
        .map((e) => e.isEmpty ? '$label\n' : '$label $e\n')
        .join();

    for (final contextRoot in contextRoots) {
      final file = File(join(contextRoot.root, 'custom_lint.log'));

      file
        ..createSync(recursive: true)
        ..writeAsStringSync(msg, mode: FileMode.append);
    }
  }

  @override
  void serverError(
    CustomLintServer serverPlugin,
    Object error,
    StackTrace stackTrace, {
    required List<ContextRoot> allContextRoots,
  }) {
    _log(allContextRoots, '$error\n$stackTrace', pluginName: 'custom_lint');
  }

  @override
  void pluginInitializationFail(
    CustomLintServer serverPlugin,
    Object err,
    StackTrace stackTrace, {
    required String pluginName,
    required List<ContextRoot> pluginContextRoots,
  }) {
    _log(
      pluginContextRoots,
      '$err\n$stackTrace',
      pluginName: pluginName,
    );
  }

  @override
  @mustCallSuper
  void serverMessage(
    CustomLintServer serverPlugin,
    String message, {
    required List<ContextRoot> allContextRoots,
  }) {
    _log(
      allContextRoots,
      message,
      pluginName: null,
    );
  }

  @override
  @mustCallSuper
  void pluginMessage(
    CustomLintServer serverPlugin,
    String message, {
    required String pluginName,
    required List<ContextRoot> pluginContextRoots,
  }) {
    _log(
      pluginContextRoots,
      message,
      pluginName: pluginName,
    );
  }

  @override
  void requestError(
    CustomLintServer serverPlugin,
    Request request,
    RequestError requestError, {
    required List<ContextRoot> allContextRoots,
  }) {
    _log(
      allContextRoots,
      pluginName: null,
      '''
The request ${request.method} failed with the following error:
${requestError.code}
${requestError.message}
at:
${requestError.stackTrace}
''',
    );
  }

  @override
  void pluginError(
    CustomLintServer serverPlugin,
    String err,
    String stackTrace, {
    required String pluginName,
    required List<ContextRoot> pluginContextRoots,
  }) {
    _log(
      pluginContextRoots,
      '$err\n$stackTrace',
      pluginName: pluginName,
    );
  }
}

/// Redirects events to the analyzer server
class AnalyzerPluginCustomLintDelegate
    with LogCustomLintDelegate
    implements CustomLintDelegate {}

/// Maps events to the console
class CommandCustomLintDelegate
    with LogCustomLintDelegate
    implements CustomLintDelegate {
  @override
  void pluginMessage(
    CustomLintServer serverPlugin,
    String message, {
    required String pluginName,
    required List<ContextRoot> pluginContextRoots,
  }) {
    super.pluginMessage(
      serverPlugin,
      message,
      pluginName: pluginName,
      pluginContextRoots: pluginContextRoots,
    );

    final label = '[$pluginName]';

    final msg = message
        .split('\n')
        .map((e) => e.isEmpty ? '$label\n' : '$label $e\n')
        .join();

    stdout.write(msg);
  }

  @override
  void serverError(
    CustomLintServer serverPlugin,
    Object error,
    StackTrace stackTrace, {
    required List<ContextRoot> allContextRoots,
  }) {
    super.serverError(
      serverPlugin,
      error,
      stackTrace,
      allContextRoots: allContextRoots,
    );
    stderr.writeln('$error\n$stackTrace');
  }

  @override
  void pluginInitializationFail(
    CustomLintServer serverPlugin,
    Object err,
    StackTrace stackTrace, {
    required String pluginName,
    required List<ContextRoot> pluginContextRoots,
  }) {
    super.pluginInitializationFail(
      serverPlugin,
      err,
      stackTrace,
      pluginName: pluginName,
      pluginContextRoots: pluginContextRoots,
    );
    stderr.writeln('$err\n$stackTrace');
  }

  @override
  void pluginError(
    CustomLintServer serverPlugin,
    String err,
    String stackTrace, {
    required String pluginName,
    required List<ContextRoot> pluginContextRoots,
  }) {
    super.pluginError(
      serverPlugin,
      err,
      stackTrace,
      pluginName: pluginName,
      pluginContextRoots: pluginContextRoots,
    );
    stderr.writeln('$err\n$stackTrace');
  }

  @override
  void requestError(
    CustomLintServer serverPlugin,
    Request request,
    RequestError requestError, {
    required List<ContextRoot> allContextRoots,
  }) {
    super.requestError(
      serverPlugin,
      request,
      requestError,
      allContextRoots: allContextRoots,
    );
    stderr.writeln(
      '''
The request ${request.method} failed with the following error:
${requestError.code}
${requestError.message}
at:
${requestError.stackTrace}''',
    );
  }
}
