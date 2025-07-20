import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:analyzer_plugin/protocol/protocol.dart';
import 'package:analyzer_plugin/protocol/protocol_constants.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';
// ignore: implementation_imports, not exported
import 'package:analyzer_plugin/src/protocol/protocol_internal.dart'
    show ResponseResult;
import 'package:async/async.dart';
import 'package:custom_lint_core/custom_lint_core.dart';
import 'package:package_config/package_config.dart';
import 'package:path/path.dart' as p;
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
    required this.fix,
  });

  /// Start the server while also capturing prints and errors.
  ///
  /// Logic after the [start] should be wrapped in a [runZoned] to make sure
  /// errors and prints continue to be captured.
  static Future<CustomLintServer> start({
    required SendPort sendPort,
    required bool? watchMode,
    required bool includeBuiltInLints,
    required bool fix,
    required CustomLintDelegate delegate,
    required Directory workingDirectory,
  }) {
    late CustomLintServer server;

    return runZoned(
      () => server,
      () {
        server = CustomLintServer._(
          watchMode: watchMode,
          fix: fix,
          includeBuiltInLints: includeBuiltInLints,
          delegate: delegate,
          workingDirectory: workingDirectory,
        );
        server._start(sendPort);

        return server;
      },
    );
  }

  /// Run the given [body] in a zone that captures errors and prints and
  /// sends them to the server for handling.
  ///
  /// Do not close the server within [runZoned], as this could cause a race condition
  /// on errors/prints handling, where an error/print happens after the server is closed,
  /// causing the event to be silenced.
  static Future<R> runZoned<R>(
    CustomLintServer Function() server,
    FutureOr<R> Function() body,
  ) {
    return asyncRunZonedGuarded(
      () => body(),
      (err, stack) {
        unawaited(server().handleUncaughtError(err, stack));
      },
      zoneSpecification: ZoneSpecification(
        print: (self, parent, zone, line) {
          unawaited(
            server().handlePrint(
              line,
              isClientMessage: false,
            ),
          );
        },
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
  final bool? watchMode;

  /// If enabled, attempt to fix all issues found before reporting them.
  /// Can only be enabled in the CLI.
  final bool fix;

  /// Whether plugins should include lints used for debugging.
  final bool includeBuiltInLints;

  late final StreamSubscription<void> _requestSubscription;
  StreamSubscription<void>? _clientChannelEventsSubscription;
  late PluginVersionCheckParams _pluginVersionCheckParams;

  final _clientChannel =
      BehaviorSubject<SocketCustomLintServerToClientChannel?>();
  final _contextRoots = BehaviorSubject<AnalysisSetContextRootsParams>();
  final _runner = PendingOperation();

  /// A shorthand for accessing the current list of context roots.
  Future<List<ContextRoot>?> get _allContextRoots {
    return _contextRoots.firstOrNull.then((value) => value?.roots);
  }

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
        final clientChannel = await _clientChannel.safeFirst;
        if (clientChannel == null) return;

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
    Future<void> sendResponse({
      ResponseResult? data,
      RequestError? error,
    }) async {
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
            await sendResponse(data: PluginShutdownResult());
            return null;
          } finally {
            await close();
          }
        },
        orElse: () async {
          return _runner.run(() async {
            final clientChannel = await _clientChannel.safeFirst;
            if (clientChannel == null) return null;

            final response =
                await clientChannel.sendAnalyzerPluginRequest(request);
            _analyzerPluginClientChannel.sendJson(response.toJson());
            return null;
          });
        },
      );

      /// A response was already sent, so nothing to do.
      if (result == null) return;

      await sendResponse(data: result);
    } catch (err, stack) {
      await sendResponse(
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
        allContextRoots:
            await _contextRoots.safeFirst.then((value) => value.roots),
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
          allContextRoots: await _allContextRoots,
        );
      });

  /// A life-cycle for when the server failed to start the plugins.
  Future<void> handlePluginInitializationFail() => _runner.run(() async {
        final contextRoots = await _allContextRoots;

        delegate.pluginInitializationFail(
          this,
          'Failed to start plugins',
          allContextRoots: contextRoots,
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
        final roots = await _contextRoots.safeFirst;

        if (!isClientMessage) {
          delegate.serverMessage(
            this,
            '$message\n',
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

  Future<void>? _closeFuture;

  /// Stops the server, closing all channels.
  Future<void> close() async {
    // Already stopped the server before. No need to run things again.
    if (_closeFuture != null) return _closeFuture;

    return _closeFuture = Future(() async {
      // Cancel pending operations
      await _contextRoots.close();

      // Flushes logs before stopping server.
      await _runner.wait();

      try {
        await Future.wait([
          _clientChannel.safeFirst
              .then((clientChannel) => clientChannel?.close()),
          _clientChannel.close(),
          _requestSubscription.cancel(),
          if (_clientChannelEventsSubscription != null)
            _clientChannelEventsSubscription!.cancel(),
        ])
            // Close the connection after previous disposals are done, to make sure
            // the shutdown request (if any) receives a response
            .whenComplete(_analyzerPluginClientChannel.close);
      } finally {
        // Wait for remaining operations to complete
        await _runner.wait();
      }
    })
        // Make sure "close" never throws, so that follow-up dispose logic can continue.
        .catchError((_) {});
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
      ['*'],
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

    if (_clientChannel.hasValue) {
      await _clientChannel.value?.setContextRoots(parameters);
      return;
    }

    SocketCustomLintServerToClientChannel? clientChannel;

    try {
      clientChannel = await SocketCustomLintServerToClientChannel.create(
        this,
        _pluginVersionCheckParams,
        parameters,
        workingDirectory: workingDirectory,
      );
      _clientChannel.add(clientChannel);
      if (clientChannel == null) return;
    } catch (err, stack) {
      _clientChannel.addError(err, stack);
      rethrow;
    }

    // Listening to event before init, to make sure messages during the init are handled.
    _clientChannelEventsSubscription = clientChannel.events.listen(
      _handleEvent,
    );

    final configs = await Future.wait(
      parameters.roots.map(
        (e) async {
          final packageConfig = await findPackageConfig(Directory(e.root));
          if (packageConfig == null) return null;

          return CustomLintConfigs.parse(
            PhysicalResourceProvider.INSTANCE.getFile(
              p.join(e.root, 'analysis_options.yaml'),
            ),
            packageConfig,
          );
        },
      ),
    );

    await clientChannel.init(
      debug: configs.any((e) => e != null && e.debug),
    );
  }

  Future<void> _handleEvent(CustomLintEvent event) => _runner.run(() async {
        switch (event) {
          case CustomLintEventAnalyzerPluginNotification():
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
                pluginContextRoots: await _allContextRoots,
              );
            }
          case CustomLintEventError():
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
              pluginContextRoots: await _allContextRoots,
            );
          case CustomLintEventPrint():
            delegate.pluginMessage(
              this,
              event.message,
              pluginName: event.pluginName ?? 'custom_lint client',
              pluginContextRoots: await _allContextRoots,
            );
        }
      });
}
