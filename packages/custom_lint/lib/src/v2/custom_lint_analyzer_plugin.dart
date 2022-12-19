import 'dart:async';
import 'dart:io';

import 'package:analyzer_plugin/protocol/protocol.dart';
import 'package:analyzer_plugin/protocol/protocol_constants.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';
// ignore: implementation_imports
import 'package:analyzer_plugin/src/protocol/protocol_internal.dart'
    show ResponseResult;
import 'package:path/path.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:rxdart/rxdart.dart';

import '../analyzer_plugin/plugin_delegate.dart';
import '../channels.dart';
import '../request_extension.dart';
import 'protocol.dart';
import 'server_to_client_channel.dart';

class CustomLintServer {
  CustomLintServer({
    required this.delegate,
    required this.includeBuiltInLints,
    required this.watchMode,
    required this.analyzerPluginClientChannel,
  }) {
    _requestSubscription = analyzerPluginClientChannel.messages
        .map((e) => e! as Map<String, Object?>)
        .map(Request.fromJson)
        .listen(_handleRequest);
  }

  final JsonSendPortChannel analyzerPluginClientChannel;

  final CustomLintDelegate delegate;
  final bool includeBuiltInLints;
  final bool watchMode;

  late final StreamSubscription<void> _requestSubscription;
  final _versionCheck = Completer<PluginVersionCheckParams>();

  CustomLintServerToClientChannel? _clientChannel;
  final _contextRoots = BehaviorSubject<AnalysisSetContextRootsParams>();

  Future<void> _handleRequest(Request request) async {
    print('Handle request ${request.id} // ${request.method}');
    final requestTime = DateTime.now().millisecondsSinceEpoch;
    void sendResponse({ResponseResult? data, RequestError? error}) {
      analyzerPluginClientChannel.sendJson(
        Response(
          request.id,
          requestTime,
          result: data?.toJson(),
          error: error,
        ).toJson(),
      );
    }

    try {
      final result = await request.when<FutureOr<ResponseResult?>>(
        handlePluginVersionCheck: _handlePluginVersionCheck,
        handleAnalysisSetContextRoots: _handleAnalysisSetContextRoots,
        handlePluginShutdown: () async {
          try {
            await _handlePluginShutdown();
            sendResponse(data: PluginShutdownResult());
            return null;
          } finally {
            analyzerPluginClientChannel.close();
          }
        },
        orElse: () async {
          final response =
              await _clientChannel!.sendAnalyzerPluginRequest(request);
          analyzerPluginClientChannel.sendJson(response.toJson());
          return null;
        },
      );

      /// A response was already sent, so nothing to do.
      if (result == null) return;

      sendResponse(data: result);
    } catch (err, stack) {
      sendResponse(
        error: RequestError(
          RequestErrorCode.PLUGIN_ERROR,
          err.toString(),
          stackTrace: stack.toString(),
        ),
      );

      await _logError(
        err.toString(),
        stack.toString(),
      );
    }
  }

  /// An uncaught error was detected (unrelated to requests).
  /// Logging the error and notifying the analyzer server
  Future<void> handleUncaughtError(Object error, StackTrace stackTrace) async {
    analyzerPluginClientChannel.sendJson(
      PluginErrorParams(false, error.toString(), stackTrace.toString())
          .toNotification()
          .toJson(),
    );

    await _logError(
      error.toString(),
      stackTrace.toString(),
    );
  }

  /// Write errors in the log files at the root of contextroots.
  Future<void> _logError(
    String error,
    String stackTrace,
  ) async {
    final roots = await _contextRoots.first;

    for (final root in roots.roots) {
      final logFile = File(join(root.root, 'custom_lint.log'));
      logFile.writeAsStringSync(
        '$error\n$stackTrace\n',
        mode: FileMode.append,
      );
    }
  }

  /// A print was detected. This will redirect it to a log file.
  Future<void> handlePrint(String message) async {
    final roots = await _contextRoots.first;

    for (final root in roots.roots) {
      final logFile = File(join(root.root, 'custom_lint.log'));
      logFile.writeAsStringSync('$message\n', mode: FileMode.append);
    }
  }

  Future<void> _handlePluginShutdown() async {
    // TODO send shutdown to process
    print('showDown');

    // The channel will be automatically closed on shutdown.
    // Closing it manually would prevent the follow-up logic to send a
    // response to the shutdown request.

    _clientChannel?.close();
    await _requestSubscription.cancel();
  }

  FutureOr<PluginVersionCheckResult> _handlePluginVersionCheck(
    PluginVersionCheckParams parameters,
  ) {
    // The even should be sent only once. Plugins don't handle multiple
    // version check.
    // So we let "complete" throw by not checking "isCompleted".
    _versionCheck.complete(parameters);

    final versionString = parameters.version;
    final serverVersion = Version.parse(versionString);
    final clientVersion = Version.parse('1.0.0-alpha.0');

    return PluginVersionCheckResult(
      serverVersion <= clientVersion,
      'custom_lint',
      clientVersion.toString(),
      ['*.dart'],
      contactInfo: 'https://github.com/invertase/dart_custom_lint/issues',
    );
  }

  FutureOr<AnalysisSetContextRootsResult> _handleAnalysisSetContextRoots(
    AnalysisSetContextRootsParams parameters,
  ) async {
    _contextRoots.add(parameters);

    await _maybeSpawnCustomLintPlugin(parameters);

    return AnalysisSetContextRootsResult();
  }

  Future<void> _maybeSpawnCustomLintPlugin(
    AnalysisSetContextRootsParams parameters,
  ) async {
    final versionCheck = await _versionCheck.future;

    final clientChannel = _clientChannel;
    if (clientChannel != null) {
      await clientChannel.setContextRoots(parameters);
      return;
    }

    _clientChannel = CustomLintServerToClientChannel.spawn(
      versionCheck,
      parameters,
    );

    // Listening to event before init, to make sure messages during the init are handled.
    _clientChannel!.events.listen(_handleEvent);

    await _clientChannel?.init();
  }

  void _handleEvent(CustomLintEvent event) {
    event.map(
      analyzerPluginNotification: (event) {
        analyzerPluginClientChannel.sendJson(event.notification.toJson());

        final notification = event.notification;
        if (notification.event == PLUGIN_NOTIFICATION_ERROR) {
          final error = PluginErrorParams.fromNotification(notification);
          _logError(
            error.message,
            error.stackTrace,
          );
        }
      },
      error: (event) {
        print('${event.message}\n${event.stackTrace}');
      },
      print: (event) => print(event.message),
    );
  }
}