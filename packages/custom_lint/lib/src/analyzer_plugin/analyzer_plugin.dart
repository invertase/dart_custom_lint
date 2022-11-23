import 'dart:async';

import 'package:analyzer/file_system/file_system.dart' as analyzer;
import 'package:analyzer_plugin/channel/channel.dart';
import 'package:analyzer_plugin/protocol/protocol.dart' as plugin;
import 'package:analyzer_plugin/protocol/protocol_common.dart' as plugin;
import 'package:analyzer_plugin/protocol/protocol_generated.dart' as plugin;
// ignore: implementation_imports
import 'package:analyzer_plugin/src/protocol/protocol_internal.dart' as plugin
    show RequestParams;
import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:riverpod/riverpod.dart';

import '../protocol/internal_protocol.dart';
import 'lints.dart';
import 'plugin_delegate.dart';
import 'plugin_link.dart';
import 'result.dart';
import 'server_plugin.dart';

/// An analyzer_plugin server that manages the various custom lint plugins
class CustomLintPlugin extends ServerPlugin {
  /// An analyzer_plugin server that manages the various custom lint plugins
  CustomLintPlugin({
    analyzer.ResourceProvider? resourceProvider,
    required this.delegate,
    required this.includeBuiltInLints,
    required this.watchMode,
  }) : super(resourceProvider);

  /// The delegate for handling events in a platform-specific way.
  final CustomLintDelegate delegate;

  /// Whether to include lints made by custom_lint about the status of a plugin.
  final bool includeBuiltInLints;

  /// Whether to hot-restart plugins when their source changes.
  final bool watchMode;

  @override
  String get contactInfo =>
      'https://github.com/invertase/dart_custom_lint/issues';

  @override
  List<String> get fileGlobsToAnalyze => const ['*.dart'];

  @override
  String get name => 'custom_lint';

  @override
  String get version => '1.0.0-alpha.0';

  final _overlays = <String, String>{};

  late final ProviderContainer _container;

  /// An imperative anchor for reading the current list of plugins
  late final ProviderSubscription<Future<Map<PluginKey, Result<PluginLink>>>>
      _allPluginsSub;
  @override
  void start(PluginCommunicationChannel channel) {
    super.start(channel);
    _container = ProviderContainer(
      overrides: [
        includeBuiltInLintsProvider.overrideWithValue(includeBuiltInLints),
        watchModeProvider.overrideWithValue(watchMode),
      ],
    );

    _container.listen<Map<String, plugin.AnalysisErrorsParams>>(
        allLintsProvider, (previous, next) {
      final changedFiles = {...next.keys, ...?previous?.keys};

      for (final changedFile in changedFiles) {
        if (previous?[changedFile] != next[changedFile]) {
          channel.sendNotification(
            plugin.AnalysisErrorsParams(
              changedFile,
              next[changedFile]?.errors ?? const [],
            ).toNotification(),
          );
        }
      }
    });

    _allPluginsSub = _container.listen(
      allPluginLinksProvider.future,
      (previousPlugins, currentPlugins) async {
        final previousLinks = await previousPlugins;
        final links = await currentPlugins;

        for (final linkEntry in links.entries) {
          final previousLinkResult = previousLinks?[linkEntry.key];
          final linkResult = linkEntry.value;

          if (linkResult == previousLinkResult) continue;

          // TODO test initialization error into valid initialization (hot-restart)
          if (linkResult.hasError) {
            channel.sendNotification(
              plugin.PluginErrorParams(
                false,
                linkResult.error.toString(),
                linkResult.stackTrace.toString(),
              ).toNotification(),
            );
            delegate.pluginInitializationFail(
              this,
              _getPluginDetails(linkEntry.key),
              linkResult.error!,
              linkResult.stackTrace!,
            );
            continue;
          }

          final link = linkResult.value;
          // TODO do we need to close subscriptions if a plugin re-initialize?
          link.channel
            ..messages.listen((event) {
              delegate.pluginMessage(
                this,
                _getPluginDetails(linkEntry.key),
                event.message,
              );
            })
            ..pluginErrors.listen((event) {
              delegate.pluginError(
                this,
                _getPluginDetails(linkEntry.key),
                event.message,
                event.stackTrace,
              );
            })
            ..notifications.listen((notification) {
              switch (notification.event) {
                // Events handled separately
                case PrintNotification.key:
                case 'analysis.errors':
                  break;
                default:
                  channel.sendNotification(notification);
                  break;
              }
            });
        }
      },
      fireImmediately: true,
      // No need for an onError since it'd never be reached as errors are caught by FutureProvider
    );
  }

  @override
  Future<plugin.AnalysisSetContextRootsResult> handleAnalysisSetContextRoots(
    plugin.AnalysisSetContextRootsParams parameters,
  ) async {
    // Unused plugins will automatically be disposed thanks to Riverpod

    _container.read(activeContextRootsProvider.notifier).state =
        parameters.roots;

    await _allPluginsSub.read();

    return plugin.AnalysisSetContextRootsResult();
  }

  Future<List<plugin.Response>> _requestAllPlugins(
    plugin.RequestParams request,
  ) async {
    final links = await _allPluginsSub.read();

    return Stream<plugin.Response>.fromFutures(
      links.entries
          // Don't request plugins that are known to be failing
          .where((link) => link.value.hasValue)
          .map((link) => _requestPlugin(link.key, request)),
    )
        // ignore: avoid_types_on_closure_parameters, see https://github.com/dart-lang/linter/issues/3330
        .handleError((Object err, StackTrace stack) {})
        .toList();
  }

  PluginDetails _getPluginDetails(PluginKey linkKey) {
    return PluginDetails(
      name: _container.read(pluginMetaProvider(linkKey)).name,
      root: linkKey,
      contextRoots: _container.read(contextRootsForPluginProvider(linkKey)),
    );
  }

  Future<plugin.Response> _requestPlugin(
    PluginKey pluginKey,
    plugin.RequestParams request,
  ) async {
    try {
      final links = await _allPluginsSub.read();

      assert(
        links.containsKey(pluginKey),
        'Bad state, plugin $pluginKey not found',
      );
      final link = links[pluginKey]!;
      return link.value.channel.sendRequest(request);
    } on plugin.RequestFailure catch (err) {
      delegate.requestError(
        this,
        _getPluginDetails(pluginKey),
        request,
        err.error,
      );
      rethrow;
    }
  }

  /// An uncaught error was detected.
  ///
  /// This notify the analyzer_plugin server and log the error inside
  /// active context roots.
  void handleUncaughtError(Object err, StackTrace stackTrace) {
    channel.sendNotification(
      plugin.PluginErrorParams(
        false,
        err.toString(),
        stackTrace.toString(),
      ).toNotification(),
    );

    delegate.serverError(
      this,
      _container.read(activeContextRootsProvider),
      err,
      stackTrace,
    );
  }

  @override
  Future<plugin.EditGetFixesResult> handleEditGetFixes(
    plugin.EditGetFixesParams parameters,
  ) async {
    final responses = await _requestAllPlugins(parameters);

    return plugin.EditGetFixesResult(
      // TODO any error handling necessary?
      responses
          .map(plugin.EditGetFixesResult.fromResponse)
          .expand((e) => e.fixes)
          .toList(),
    );
  }

  @override
  FutureOr<plugin.PluginVersionCheckResult> handlePluginVersionCheck(
    plugin.PluginVersionCheckParams parameters,
  ) async {
    // TODO: parameters.bytePathStorePath should be unique to the plugin
    _container.read(versionCheckProvider.notifier).update((state) {
      if (state != null) {
        throw StateError('handlePluginVersionCheck received multiple times');
      }
      return parameters;
    });

    final versionString = parameters.version;
    final serverVersion = Version.parse(versionString);

    await _allPluginsSub.read();

    return plugin.PluginVersionCheckResult(
      isCompatibleWith(serverVersion),
      name,
      version,
      fileGlobsToAnalyze,
      contactInfo: contactInfo,
    );
  }

  @override
  FutureOr<plugin.AnalysisHandleWatchEventsResult>
      handleAnalysisHandleWatchEvents(
    plugin.AnalysisHandleWatchEventsParams parameters,
  ) async {
    await _requestAllPlugins(parameters);
    return plugin.AnalysisHandleWatchEventsResult();
  }

  @override
  FutureOr<plugin.AnalysisSetPriorityFilesResult>
      handleAnalysisSetPriorityFiles(
    plugin.AnalysisSetPriorityFilesParams parameters,
  ) async {
    _container.read(priorityFilesProvider.notifier).state = parameters;
    await _allPluginsSub.read();

    return plugin.AnalysisSetPriorityFilesResult();
  }

  @override
  FutureOr<plugin.AnalysisSetSubscriptionsResult>
      handleAnalysisSetSubscriptions(
    plugin.AnalysisSetSubscriptionsParams parameters,
  ) async {
    // TODO filter plugins based on the subscription parameter
    await _requestAllPlugins(parameters);
    return plugin.AnalysisSetSubscriptionsResult();
  }

  @override
  FutureOr<plugin.AnalysisUpdateContentResult> handleAnalysisUpdateContent(
    plugin.AnalysisUpdateContentParams parameters,
  ) async {
    // TODO why lints are emitted twice on file change?

    // TODO write test for this (maybe send fake Overlay events?)
    /// Imported from analyzer_plugin but stores the overlay result
    /// locally instead of in the analyzer API.
    /// We're computing the overlays on the server and caching the result
    /// because plugins can unmount/remount at any time, so they need to
    /// have access to the latest overlays.
    parameters.files.forEach((filePath, overlay) {
      // Prepare the old overlay contents.

      // Prepare the new contents.
      String? newContents;
      if (overlay is plugin.AddContentOverlay) {
        newContents = overlay.content;
      } else if (overlay is plugin.ChangeContentOverlay) {
        final oldContents = _overlays[filePath];
        if (oldContents == null) {
          // The server should only send a ChangeContentOverlay if there is
          // already an existing overlay for the source.
          throw plugin.RequestFailure(
            plugin.RequestErrorFactory.invalidOverlayChangeNoContent(),
          );
        }
        try {
          newContents =
              plugin.SourceEdit.applySequence(oldContents, overlay.edits);
          // ignore: avoid_catching_errors
        } on RangeError {
          throw plugin.RequestFailure(
            plugin.RequestErrorFactory.invalidOverlayChangeInvalidEdit(),
          );
        }
      } else if (overlay is plugin.RemoveContentOverlay) {
        newContents = null;
      }

      if (newContents != null) {
        _overlays[filePath] = newContents;
      } else {
        _overlays.remove(filePath);
      }
    });

    final links = await _allPluginsSub.read();
    for (final link in links.entries) {
      // TODO test
      if (link.value.hasError) continue;

      final files = Map.fromEntries(
        parameters.files.keys
            // TODO test
            .where(
          (filePath) => _container
              .read(contextRootsForPluginProvider(link.key))
              .any((contextRoot) => p.isWithin(contextRoot.root, filePath)),
        )
            .map((filePath) {
          final content = _overlays[filePath];
          final message = content == null
              ? plugin.RemoveContentOverlay()
              : plugin.AddContentOverlay(content);

          return MapEntry(filePath, message);
        }),
      );

      // TODO is the "isNotEmpty" correct? Do we want to send empty arrays too?
      if (files.isNotEmpty) {
        await _requestPlugin(
          link.key,
          plugin.AnalysisUpdateContentParams(files),
        );
      }
    }

    return plugin.AnalysisUpdateContentResult();
  }

  @override
  FutureOr<plugin.CompletionGetSuggestionsResult>
      handleCompletionGetSuggestions(
    plugin.CompletionGetSuggestionsParams parameters,
  ) async {
    await _requestAllPlugins(parameters);
    return plugin.CompletionGetSuggestionsResult(
      -1,
      -1,
      const <plugin.CompletionSuggestion>[],
    );
  }

  /// Requests lints for specific files
  @override
  Future<AwaitAnalysisDoneResult> handleAwaitAnalysisDone(
    AwaitAnalysisDoneParams parameters,
  ) async {
    if (parameters.reload) {
      _container.invalidate(invalidateLintsProvider);
    }
    await _requestAllPlugins(parameters);
    return const AwaitAnalysisDoneResult();
  }

  @override
  FutureOr<plugin.EditGetAssistsResult> handleEditGetAssists(
    plugin.EditGetAssistsParams parameters,
  ) async {
    await _requestAllPlugins(parameters);
    return plugin.EditGetAssistsResult(
      const <plugin.PrioritizedSourceChange>[],
    );
  }

  @override
  FutureOr<plugin.EditGetAvailableRefactoringsResult>
      handleEditGetAvailableRefactorings(
    plugin.EditGetAvailableRefactoringsParams parameters,
  ) async {
    await _requestAllPlugins(parameters);
    return plugin.EditGetAvailableRefactoringsResult(
      const <plugin.RefactoringKind>[],
    );
  }

  @override
  FutureOr<plugin.EditGetRefactoringResult?> handleEditGetRefactoring(
    plugin.EditGetRefactoringParams parameters,
  ) async {
    await _requestAllPlugins(parameters);
    return null;
  }

  @override
  Future<plugin.AnalysisGetNavigationResult> handleAnalysisGetNavigation(
    plugin.AnalysisGetNavigationParams parameters,
  ) async {
    await _requestAllPlugins(parameters);
    return plugin.AnalysisGetNavigationResult(
      <String>[],
      <plugin.NavigationTarget>[],
      <plugin.NavigationRegion>[],
    );
  }

  @override
  FutureOr<plugin.KytheGetKytheEntriesResult?> handleKytheGetKytheEntries(
    plugin.KytheGetKytheEntriesParams parameters,
  ) async {
    await _requestAllPlugins(parameters);
    return null;
  }

  @override
  FutureOr<plugin.PluginShutdownResult> handlePluginShutdown(
    plugin.PluginShutdownParams parameters,
  ) async {
    try {
      // TODO what if a plugin initialized, then context root changed and is now failing
      await _requestAllPlugins(parameters);
      return plugin.PluginShutdownResult();
    } finally {
      _container.dispose();
    }
  }
}
