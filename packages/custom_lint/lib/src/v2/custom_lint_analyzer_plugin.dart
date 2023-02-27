import 'dart:async';
import 'dart:isolate';

import 'package:analyzer_plugin/protocol/protocol.dart';
import 'package:analyzer_plugin/protocol/protocol_constants.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';
// ignore: implementation_imports
import 'package:analyzer_plugin/src/protocol/protocol_internal.dart'
    show ResponseResult;
import 'package:pub_semver/pub_semver.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

import '../async_operation.dart';
import '../channels.dart';
import '../plugin_delegate.dart';
import '../request_extension.dart';
import 'protocol.dart';
import 'server_to_client_channel.dart';

/// The custom_lint server, in charge of interacting with analyzer_plugin
/// and starting custom_lint plugins
class CustomLintServer {
  CustomLintServer._({
    required this.watchMode,
    required this.includeBuiltInLints,
    required this.delegate,
  });

  /// Start the server while also capturing prints and errors.
  static R? run<R>(
    R Function(CustomLintServer server) cb, {
    required SendPort sendPort,
    required bool watchMode,
    required bool includeBuiltInLints,
    required CustomLintDelegate delegate,
  }) {
    late CustomLintServer server;
    final result = runZonedGuarded(
      () {
        server = CustomLintServer._(
          watchMode: watchMode,
          includeBuiltInLints: includeBuiltInLints,
          delegate: delegate,
        );
        server._start(sendPort);

        return cb(server);
      },
      (err, stack) => server.handleUncaughtError(err, stack),
      zoneSpecification: ZoneSpecification(
        print: (self, parent, zone, line) => server.handlePrint(
          line,
          isClientMessage: false,
        ),
      ),
    );

    return result;
  }

  /// The object in charge of logging events and possibly rendering events
  /// in the console (if ran from a terminal).
  final CustomLintDelegate delegate;

  /// The interface for discussing with analyzer_plugin
  late final AnalyzerPluginClientChannel analyzerPluginClientChannel;

  /// Whether plugins should be started in watch mode
  final bool watchMode;

  /// Whether plugins should include lints used for debugging.
  final bool includeBuiltInLints;

  late final StreamSubscription<void> _requestSubscription;
  final _versionCheck = Completer<PluginVersionCheckParams>();

  final _clientChannel = BehaviorSubject<CustomLintServerToClientChannel>();
  final _contextRoots = BehaviorSubject<AnalysisSetContextRootsParams>();
  final _runner = PendingOperation();

  void _start(SendPort sendPort) {
    analyzerPluginClientChannel = JsonSendPortChannel(sendPort);
    _requestSubscription = analyzerPluginClientChannel.messages
        .map((e) => e! as Map<String, Object?>)
        .map(Request.fromJson)
        .listen(_handleRequest);
  }

  /// Waits for the plugins to complete their analysis
  Future<void> awaitAnalysisDone({
    required bool reload,
  }) =>
      _runner.run(() async {
        final clientChannel = await _clientChannel.first;

        await clientChannel.sendCustomLintRequest(
          CustomLintRequest.awaitAnalysisDone(
            id: const Uuid().v4(),
            reload: reload,
          ),
        );

        // Pinging the client to flush events. This should ensure notifications are handled
        await clientChannel.sendCustomLintRequest(
          CustomLintRequest.ping(id: const Uuid().v4()),
        );
      });

  Future<void> _handleRequest(Request request) async {
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
          return _runner.run(() async {
            final clientChannel = await _clientChannel.first;
            final response =
                await clientChannel.sendAnalyzerPluginRequest(request);
            analyzerPluginClientChannel.sendJson(response.toJson());
            return null;
          });
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
      delegate.requestError(
        this,
        request,
        RequestError(
          RequestErrorCode.PLUGIN_ERROR,
          err.toString(),
          stackTrace: stack.toString(),
        ),
        allContextRoots: await _contextRoots.first.then((value) => value.roots),
      );
    }
  }

  /// An uncaught error was detected (unrelated to requests).
  /// Logging the error and notifying the analyzer server
  Future<void> handleUncaughtError(Object error, StackTrace stackTrace) =>
      _runner.run(() async {
        analyzerPluginClientChannel.sendJson(
          PluginErrorParams(false, error.toString(), stackTrace.toString())
              .toNotification()
              .toJson(),
        );

        delegate.serverError(
          this,
          error,
          stackTrace,
          allContextRoots:
              await _contextRoots.first.then((value) => value.roots),
        );
      });

  /// A print was detected. This will redirect it to a log file.
  Future<void> handlePrint(
    String message, {
    required bool isClientMessage,
  }) =>
      _runner.run(() async {
        final roots = await _contextRoots.first;

        if (!isClientMessage) {
          delegate.serverMessage(
            this,
            message,
            allContextRoots: roots.roots,
          );
        } else {
          delegate.pluginMessage(
            this,
            message,
            pluginName: null,
            pluginContextRoots: roots.roots,
          );
        }
      });

  Future<void> _handlePluginShutdown() async {
    // TODO send shutdown to process

    // Waiting for context root to complete, otherwise some async operation
    // might still be pending after the shutdown
    await _contextRoots.first;

    await _runner.wait();

    // The channel will be automatically closed on shutdown.
    // Closing it manually would prevent the follow-up logic to send a
    // response to the shutdown request.
    await _clientChannel.first.then((clientChannel) => clientChannel.close());

    await Future.wait([
      _clientChannel.close(),
      _requestSubscription.cancel(),
    ]);

    await _runner.wait();
  }

  PluginVersionCheckResult _handlePluginVersionCheck(
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

  Future<AnalysisSetContextRootsResult> _handleAnalysisSetContextRoots(
    AnalysisSetContextRootsParams parameters,
  ) =>
      _runner.run(() async {
        _contextRoots.add(parameters);

        await _maybeSpawnCustomLintPlugin(parameters);

        return AnalysisSetContextRootsResult();
      });

  Future<void> _maybeSpawnCustomLintPlugin(
    AnalysisSetContextRootsParams parameters,
  ) async {
    final versionCheck = await _versionCheck.future;

    var clientChannel = _clientChannel.valueOrNull;
    if (clientChannel != null) {
      await clientChannel.setContextRoots(parameters);
      return;
    }

    clientChannel = CustomLintServerToClientChannel.spawn(
      this,
      versionCheck,
      parameters,
    );
    _clientChannel.add(clientChannel);

    // Listening to event before init, to make sure messages during the init are handled.
    clientChannel.events.listen(_handleEvent);
    await clientChannel.init();
  }

  void _handleEvent(CustomLintEvent event) {
    event.map(
      analyzerPluginNotification: (event) async {
        analyzerPluginClientChannel.sendJson(event.notification.toJson());

        final notification = event.notification;
        if (notification.event == PLUGIN_NOTIFICATION_ERROR) {
          final error = PluginErrorParams.fromNotification(notification);
          analyzerPluginClientChannel.sendJson(error.toNotification().toJson());
          delegate.pluginError(
            this,
            error.message,
            stackTrace: error.stackTrace,
            pluginName: '<unknown plugin>',
            pluginContextRoots:
                await _contextRoots.first.then((value) => value.roots),
          );
        }
      },
      error: (event) async {
        analyzerPluginClientChannel.sendJson(
          PluginErrorParams(false, event.message, event.stackTrace)
              .toNotification()
              .toJson(),
        );
        delegate.pluginError(
          this,
          event.message,
          stackTrace: event.stackTrace,
          pluginName: event.pluginName ?? 'custom_lint client',
          pluginContextRoots:
              await _contextRoots.first.then((value) => value.roots),
        );
      },
      print: (event) async {
        delegate.pluginMessage(
          this,
          event.message,
          pluginName: event.pluginName ?? 'custom_lint client',
          pluginContextRoots:
              await _contextRoots.first.then((value) => value.roots),
        );
      },
    );
  }
}
