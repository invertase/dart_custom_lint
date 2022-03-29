// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'dart:io';

import 'package:analyzer/file_system/file_system.dart' as analyzer;
import 'package:analyzer_plugin/channel/channel.dart';
import 'package:analyzer_plugin/protocol/protocol.dart' as plugin;
import 'package:analyzer_plugin/protocol/protocol_common.dart' as plugin;
import 'package:analyzer_plugin/protocol/protocol_generated.dart' as plugin;
// ignore: implementation_imports
import 'package:analyzer_plugin/src/protocol/protocol_internal.dart' as plugin
    show RequestParams;
import 'package:collection/collection.dart';
import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:riverpod/riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../protocol.dart';
import '../log.dart';
import 'my_server_plugin.dart';
import 'plugin_link.dart';

final _allPluginsProvider =
    FutureProvider.autoDispose<Map<Uri, PluginLink>>((ref) async {
  final contextRoots = ref.watch(activeContextRootsProvider);

  final plugins = contextRoots.expand(
    (contextRoot) => ref.watch(pluginMetasForContextRootProvider(contextRoot)),
  );

  final links = await Future.wait([
    for (final plugin in plugins)
      // TODO catch errors
      ref.watch(pluginLinkProvider(plugin.root).future),
  ]);

  return {
    for (final link in links) link.key: link,
  };
});

class CustomLintPlugin extends ServerPlugin {
  CustomLintPlugin({
    analyzer.ResourceProvider? resourceProvider,
  }) : super(resourceProvider);

  @override
  String get contactInfo => 'https://github.com/invertase/custom_lint/issues';

  @override
  List<String> get fileGlobsToAnalyze => const ['*.dart'];

  @override
  String get name => 'custom_lint';

  @override
  String get version => '1.0.0-alpha.0';

  late final ProviderContainer _container;

  /// An imperative anchor for reading the current list of plugins
  late final ProviderSubscription<Future<Map<Uri, PluginLink>>> _allPluginsSub;

  @override
  void start(PluginCommunicationChannel channel) {
    super.start(channel);
    _container = ProviderContainer();
    _allPluginsSub = _container.listen(
      _allPluginsProvider.future,
      (previousPlugins, currentPlugins) async {
        final previousLinks = await previousPlugins;
        final links = await currentPlugins;
        for (final link in links.values) {
          if (link == previousLinks?[link.key]) continue;

          void pluginLog(String message) {
            final file = File('${link.key.toFilePath()}/log.txt');
            file.writeAsStringSync('$message\n', mode: FileMode.append);
          }

          // Initializing new plugins, calling version check + set context roots + initial priority files
          // TODO use Future.wait
          // TODO guard errors
          // TODO close subscribption
          link.channel
            ..messages.listen((event) => pluginLog(event.message))
            ..pluginErrors.listen(
              (event) => pluginLog('${event.message}\n${event.stackTrace}'),
            )
            ..responseErrors.listen(
              (event) => pluginLog('${event.message}\n${event.stackTrace}'),
            )
            ..notifications.listen((notification) async {
              // TODO try/catch
              switch (notification.event) {
                case 'analysis.errors':
                  final params = plugin.AnalysisErrorsParams.fromNotification(
                      notification);

                  if (!p.isAbsolute(params.file)) {
                    throw StateError('${params.file} is not an absolute path');
                  }

                  // TODO why are all files re-analyzed when a single file changes?
                  // TODO handle removed files or there is otherwise a memory leak
                  // TODO extract to a StateProvider?
                  link.lintsForLibrary[params.file] = params;

                  final lintsForFile = links.values
                      .expand<plugin.AnalysisError>(
                        (link) =>
                            link.lintsForLibrary[params.file]?.errors ??
                            const [],
                      )
                      .toList();

                  pluginLog(
                    'got lints for ${params.file}: ${lintsForFile.map((e) => e.code)}',
                  );

                  channel.sendNotification(
                    plugin.AnalysisErrorsParams(
                      params.file,
                      lintsForFile,
                    ).toNotification(),
                  );
                  break;
                default:
                  channel.sendNotification(notification);
                  break;
              }
            });
        }

        // TODO refresh lints, such that we don't see previous lints while plugins are rebuilding
      },
      fireImmediately: true,
      onError: (err, stack) {
        // TODO on error send plugin error message
        log('Failed to start plugins2:\n$err\n$stack\n\n');
        channel.sendNotification(
          plugin.PluginErrorParams(
            true,
            err.toString(),
            stack.toString(),
          ).toNotification(),
        );
      },
    );
  }

  @override
  Future<plugin.AnalysisSetContextRootsResult> handleAnalysisSetContextRoots(
    plugin.AnalysisSetContextRootsParams parameters,
  ) async {
    _container.read(activeContextRootsProvider.notifier).state =
        parameters.roots;

    // _allPluginsSub.read();

    // TODO handle context root change on already existing plugins
    // Unused plugins will automatically be disposed thanks to Riverpod
    return plugin.AnalysisSetContextRootsResult();
  }

  Future<List<plugin.Response>> _requestAllPlugins(
    plugin.RequestParams request,
  ) async {
    final links = await _allPluginsSub.read();

    return Stream<plugin.Response>.fromFutures(
      links.keys.map((key) =>
          _requestPlugin(key, request).onError<Object>((error, stackTrace) {
            channel.sendNotification(
              plugin.PluginErrorParams(
                false,
                'The plugin $key failed with the error:\n$error',
                stackTrace.toString(),
              ).toNotification(),
            );

            // ignore: only_throw_errors
            throw error;
          })),
    ).handleError((Object err, StackTrace stack) {}).toList();
  }

  Future<plugin.Response> _requestPlugin(
    Uri pluginKey,
    plugin.RequestParams request,
  ) async {
    final links = await _allPluginsSub.read();

    assert(
      links.containsKey(pluginKey),
      'Bad state, plugin $pluginKey not found',
    );
    final link = links[pluginKey]!;
    return link.channel.sendRequest(request);
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

    log(parameters);
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

    // TODO verify priority files are part of the context roots associated with the plugin

    // _allPluginsSub.read();

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
    for (final link in links.values) {
      final files = Map.fromEntries(
        parameters.files.entries.where(
          (entry) => _container
              .read(contextRootsForPlugin(link.key))
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
      final links = await _allPluginsSub.read();
      final id = const Uuid().v4();
      for (final link in links.values) {
        // Voluntarily don't await for the response because the connection may
        // get closed before response is received
        await link.channel.sendJson(parameters.toRequest(id).toJson());
      }

      return plugin.PluginShutdownResult();
    } finally {
      _container.dispose();
    }
  }
}
