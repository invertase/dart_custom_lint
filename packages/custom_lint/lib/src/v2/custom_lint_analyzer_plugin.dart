import 'dart:async';
import 'dart:io';
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
    required this.workingDirectory,
  });

  /// Start the server while also capturing prints and errors.
  static Future<R> run<R>(
    FutureOr<R> Function(CustomLintServer server) cb, {
    required SendPort sendPort,
    required bool watchMode,
    required bool includeBuiltInLints,
    required CustomLintDelegate delegate,
    required Directory workingDirectory,
  }) async {
    late CustomLintServer server;

    return asyncRunZonedGuarded(
      () async {
        server = CustomLintServer._(
          watchMode: watchMode,
          includeBuiltInLints: includeBuiltInLints,
          delegate: delegate,
          workingDirectory: workingDirectory,
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
  }

  /// The directory in which the server is running.
  final Directory workingDirectory;

  /// The object in charge of logging events and possibly rendering events
  /// in the console (if ran from a terminal).
  final CustomLintDelegate delegate;

  /// The interface for discussing with analyzer_plugin
  late final AnalyzerPluginClientChannel _analyzerPluginClientChannel;

  /// Whether plugins should be started in watch mode
  final bool watchMode;

  /// Whether plugins should include lints used for debugging.
  final bool includeBuiltInLints;

  late final StreamSubscription<void> _requestSubscription;
  StreamSubscription<void>? _clientChannelEventsSubscription;
  late PluginVersionCheckParams _pluginVersionCheckParams;

  final _clientChannel =
      BehaviorSubject<SocketCustomLintServerToClientChannel>();
  final _contextRoots = BehaviorSubject<AnalysisSetContextRootsParams>();
  final _runner = PendingOperation();

  void _start(SendPort sendPort) {
    _analyzerPluginClientChannel = JsonSendPortChannel(sendPort);
    _requestSubscription = _analyzerPluginClientChannel.messages
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
      _analyzerPluginClientChannel.sendResponse(
        requestID: request.id,
        requestTime: requestTime,
        data: data,
        error: error,
      );
    }

    try {
      final result = await request.when<FutureOr<ResponseResult?>>(
        handlePluginVersionCheck: _handlePluginVersionCheck,
        handleAnalysisSetContextRoots: _handleAnalysisSetContextRoots,
        handlePluginShutdown: () async {
          try {
            sendResponse(data: PluginShutdownResult());
            return null;
          } finally {
            await close();
          }
        },
        orElse: () async {
          return _runner.run(() async {
            final clientChannel = await _clientChannel.first;
            final response =
                await clientChannel.sendAnalyzerPluginRequest(request);
            _analyzerPluginClientChannel.sendJson(response.toJson());
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
        _analyzerPluginClientChannel.sendJson(
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

  /// A life-cycle for when the server failed to start the plugins.
  Future<void> handlePluginInitializationFail() => _runner.run(() async {
        final contextRoots = await _contextRoots.first;

        delegate.pluginInitializationFail(
          this,
          'Failed to start plugins',
          allContextRoots: contextRoots.roots,
        );

        _analyzerPluginClientChannel.sendJson(
          PluginErrorParams(true, 'Failed to start plugins', '')
              .toNotification()
              .toJson(),
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

  /// Stops the server, closing all channels.
  Future<void> close() async {
    try {
      await Future.wait([
        _contextRoots.close(),
        _clientChannel.first.then((clientChannel) => clientChannel.close()),
        _clientChannel.close(),
        _requestSubscription.cancel(),
        if (_clientChannelEventsSubscription != null)
          _clientChannelEventsSubscription!.cancel(),
        _runner.wait(),
      ]).catchError((_) => const <void>[]);
    } finally {
      _analyzerPluginClientChannel.close();
    }
  }

  PluginVersionCheckResult _handlePluginVersionCheck(
    PluginVersionCheckParams parameters,
  ) {
    _pluginVersionCheckParams = parameters;

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
    // "setContextRoots" is always called after "pluginVersionCheck", so we can
    // safely assume that the version check parameters are set.

    var clientChannel = _clientChannel.valueOrNull;
    if (clientChannel != null) {
      await clientChannel.setContextRoots(parameters);
      return;
    }

    try {
      clientChannel = await SocketCustomLintServerToClientChannel.create(
        this,
        _pluginVersionCheckParams,
        parameters,
        workingDirectory: workingDirectory,
      );
      _clientChannel.add(clientChannel);
    } catch (err, stack) {
      _clientChannel.addError(err, stack);
      rethrow;
    }

    // Listening to event before init, to make sure messages during the init are handled.
    _clientChannelEventsSubscription = clientChannel.events.listen(
      _handleEvent,
    );
    await clientChannel.init();
  }

  Future<void> _handleEvent(CustomLintEvent event) => _runner.run(() async {
        final contextRoots = await _contextRoots.first;
        await event.map(
          analyzerPluginNotification: (event) async {
            _analyzerPluginClientChannel.sendJson(event.notification.toJson());

            final notification = event.notification;
            if (notification.event == PLUGIN_NOTIFICATION_ERROR) {
              final error = PluginErrorParams.fromNotification(notification);
              _analyzerPluginClientChannel
                  .sendJson(error.toNotification().toJson());
              delegate.pluginError(
                this,
                error.message,
                stackTrace: error.stackTrace,
                pluginName: '<unknown plugin>',
                pluginContextRoots: contextRoots.roots,
              );
            }
          },
          error: (event) async {
            _analyzerPluginClientChannel.sendJson(
              PluginErrorParams(false, event.message, event.stackTrace)
                  .toNotification()
                  .toJson(),
            );
            delegate.pluginError(
              this,
              event.message,
              stackTrace: event.stackTrace,
              pluginName: event.pluginName ?? 'custom_lint client',
              pluginContextRoots: contextRoots.roots,
            );
          },
          print: (event) async {
            delegate.pluginMessage(
              this,
              event.message,
              pluginName: event.pluginName ?? 'custom_lint client',
              pluginContextRoots: contextRoots.roots,
            );
          },
        );
      });
}
