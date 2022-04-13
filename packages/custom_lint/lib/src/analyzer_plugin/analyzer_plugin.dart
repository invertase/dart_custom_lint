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
  }) : super(resourceProvider);

  /// The delegate for handling events in a platform-specific way.
  final CustomLintDelegate delegate;

  @override
  String get contactInfo =>
      'https://github.com/invertase/dart_custom_lint/issues';

  @override
  List<String> get fileGlobsToAnalyze => const ['*.dart'];

  @override
  String get name => 'custom_lint';

  @override
  String get version => '1.0.0-alpha.0';

  late final ProviderContainer _container;

  /// An imperative anchor for reading the current list of plugins
  late final ProviderSubscription<Future<Map<Uri, Result<PluginLink>>>>
      _allPluginsSub;

  @override
  void start(PluginCommunicationChannel channel) {
    super.start(channel);
    _container = ProviderContainer(cacheTime: const Duration(minutes: 5));

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
            ..notifications.listen(channel.sendNotification);
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

  PluginDetails _getPluginDetails(Uri linkKey) {
    return PluginDetails(
      name: _container.read(pluginMetaProvider(linkKey)).name,
      root: linkKey,
      contextRoots: _container.read(contextRootsForPluginProvider(linkKey)),
    );
  }

  Future<plugin.Response> _requestPlugin(
    Uri pluginKey,
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
    _container.read(versionCheckProvider.notifier).state = parameters;

    final versionString = parameters.version;
    final serverVersion = Version.parse(versionString);

    // TODO does this needs to be deferred to plugins?
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
    // TODO only update plugins that are enabled for the changed files
    // TODO why lints are emitted twice on file change?

    final links = await _allPluginsSub.read();
    for (final link in links.entries) {
      // TODO
      if (link.value.hasError) continue;

      final files = Map.fromEntries(
        parameters.files.entries.where(
          (entry) => _container
              .read(contextRootsForPluginProvider(link.key))
              .any((contextRoot) => p.isWithin(contextRoot.root, entry.key)),
        ),
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
  Future<GetAnalysisErrorResult> handleGetAnalysisErrors(
    GetAnalysisErrorParams parameters,
  ) async {
    final response = await _requestAllPlugins(parameters);

    return GetAnalysisErrorResult(
      // TODO do we want to show failing plugins as "error" in the file?
      response
          .map(GetAnalysisErrorResult.fromResponse)
          .expand((element) => element.lints)
          // Merge plugin results if two plugins emit lints on the same file
          .fold<Map<String, plugin.AnalysisErrorsParams>>({}, (acc, element) {
            final params = acc[element.file] ??=
                plugin.AnalysisErrorsParams(element.file, []);
            params.errors.addAll(element.errors);
            return acc;
          })
          .values
          .toList(),
    );
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
