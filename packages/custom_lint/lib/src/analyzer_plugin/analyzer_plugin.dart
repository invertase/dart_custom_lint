// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'dart:io';

import 'package:analyzer/file_system/file_system.dart' as analyzer;
import 'package:analyzer_plugin/protocol/protocol.dart' as plugin;
import 'package:analyzer_plugin/protocol/protocol_common.dart' as plugin;
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart' as plugin;
import 'package:analyzer_plugin/src/protocol/protocol_internal.dart' as plugin
    show RequestParams;
import 'package:package_config/package_config_types.dart';
import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:riverpod/riverpod.dart';
import 'package:uuid/uuid.dart';

import '../log.dart';
import 'my_server_plugin.dart';
import 'plugin_link.dart';

const _uui = Uuid();

final _activeContextRootsProvider = StateProvider<List<plugin.ContextRoot>>(
  (ref) => [],
);

final _pluginMetasForContextRootProvider = Provider.autoDispose
    .family<List<Package>, plugin.ContextRoot>((ref, contextRoot) {
  Iterable<Package> _getPluginsForContext(
    plugin.ContextRoot contextRoot,
  ) sync* {
    final packagePath = contextRoot.root;
    // TODO if it is a plugin definition, assert that it contains the necessary configs

    // TODO is it safe to assume that there will always be a pubspec at the root?
    // TODO will there be packages nested in this directory, or will analyzer_plugin spawn a new plugin?
    // TODO should we listen to source changes for pubspec change/creation?
    final pubspec = _loadPubspecAt(packagePath);

    log('Got package ${pubspec.name}');

    final packageConfigFile = File(
      p.join(packagePath, '.dart_tool', 'package_config.json'),
    );

    if (!packageConfigFile.existsSync()) {
      // TODO should we listen to source changes for a late pub get and reload?
      throw StateError(
        'No ${packageConfigFile.path} found. Make sure to run `pub get` first.',
      );
    }

    final packageConfig = PackageConfig.parseString(
      packageConfigFile.readAsStringSync(),
      packageConfigFile.uri,
    );

    for (final dependency in {
      ...pubspec.dependencies,
      ...pubspec.devDependencies,
      ...pubspec.dependencyOverrides
    }.entries) {
      final dependencyMeta = packageConfig.packages.firstWhere(
        (package) => package.name == dependency.key,
        orElse: () => throw StateError(
          'Failed to find the source for ${dependency.key}. '
          'Make sure to run `pub get`.',
        ),
      );

      final dependencyPubspec =
          _loadPubspecAt(dependencyMeta.root.toFilePath());

// TODO extract magic value
      if (dependencyPubspec.hasDependency('custom_lint_builder')) {
        yield dependencyMeta;
        log('found plugin for ${dependency.key}:  ${dependencyPubspec.name}');
        // TODO assert that they have the necessary configs

        log('spawning plugin: ${dependencyPubspec.name}');
      }
    }
  }

  return _getPluginsForContext(contextRoot).toList();
});

final _allPluginsProvider = Provider.autoDispose<Map<Uri, PluginLink>>((ref) {
  final contextRoots = ref.watch(_activeContextRootsProvider);

  final plugins = contextRoots.expand(
    (contextRoot) => ref.watch(_pluginMetasForContextRootProvider(contextRoot)),
  );

  return {
    for (final plugin in plugins)
      // TODO catch errors
      plugin.root: ref.watch(pluginLinkProvider(plugin.root)),
  };
});

final _contextRootsForPlugin =
    Provider.autoDispose.family<List<plugin.ContextRoot>, Uri>(
  (ref, packageUri) {
    final contextRoots = ref.watch(_activeContextRootsProvider);

    return contextRoots
        .where(
          (contextRoot) => ref
              .watch(_pluginMetasForContextRootProvider(contextRoot))
              .any((package) => package.root == packageUri),
        )
        .toList();
  },
  cacheTime: const Duration(minutes: 5),
);

class CustomLintPlugin extends MyServerPlugin {
  CustomLintPlugin(analyzer.ResourceProvider provider) : super(provider) {
    _allPluginsSub = _listenPlugins();
  }

  @override
  String get contactInfo => 'https://github.com/invertase/custom_lint/issues';

  @override
  List<String> get fileGlobsToAnalyze => const ['*.dart'];

  @override
  String get name => 'custom_lint';

  @override
  String get version => '1.0.0-alpha.0';

  final _container = ProviderContainer();

  /// An imperative anchor for reading the current list of plugins
  late final ProviderSubscription<Map<Uri, PluginLink>> _allPluginsSub;

  late plugin.PluginVersionCheckParams _versionCheckRequest;
  plugin.AnalysisSetPriorityFilesParams? _lastSetPriorityFilesRequest;

  ProviderSubscription<Map<Uri, PluginLink>> _listenPlugins() {
    return _container.listen<Map<Uri, PluginLink>>(
      _allPluginsProvider,
      (previousPlugins, currentPlugins) async {
        final changedPlugins = {
          for (final entry in currentPlugins.entries)
            if (entry.value != previousPlugins?[entry.key])
              entry.key: entry.value,
        };

        // Initializing new plugins, calling version check + set context roots + initial priority files
        // TODO use Future.wait
        // TODO guard errors
        await Future.wait<void>(
          changedPlugins.entries.map((changedPlugin) async {
            // TODO close subscribption
            changedPlugin.value
              ..messages.listen((event) {
                final file = File('${changedPlugin.key.toFilePath()}/log.txt');
                file.writeAsStringSync(
                  event.message + '\n',
                  mode: FileMode.append,
                );
              })
              ..error.listen((event) {
                final file = File('${changedPlugin.key.toFilePath()}/log.txt');
                file.writeAsStringSync(
                  '${event.message}\n${event.stackTrace}\n',
                  mode: FileMode.append,
                );
              })
              ..notifications.listen((event) {
                _handleNotification(event, changedPlugin.key);
              });

            // TODO what if setContextRoot or priotity files changes while these
            // requests are pending?
            await _requestPlugin(changedPlugin.key, _versionCheckRequest);

            // TODO filter events if the previous/new values are the same
            // Call setContextRoots on the plugin with only the roots that have
            // the plugin enabled
            await _requestPlugin(
              changedPlugin.key,
              plugin.AnalysisSetContextRootsParams(
                _container
                    .read(_activeContextRootsProvider)
                    .where(
                      _container
                          .read(_contextRootsForPlugin(changedPlugin.key))
                          .contains,
                    )
                    .toList(),
              ),
            );

            final priorityFilesParam =
                _priorityFilesForPlugin(changedPlugin.key);
            if (priorityFilesParam != null) {
              await _requestPlugin(changedPlugin.key, priorityFilesParam);
            }
          }),
        );

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
    _container.read(_activeContextRootsProvider.notifier).state =
        parameters.roots;

    // TODO handle context root change on already existing plugins
    // Unused plugins will automatically be disposed thanks to Riverpod
    return plugin.AnalysisSetContextRootsResult();
  }

  void _handleNotification(plugin.Notification notification, Uri pluginKey) {
    // TODO try/catch
    switch (notification.event) {
      case 'analysis.errors':
        final link = _allPluginsSub.read()[pluginKey]!;
        final params =
            plugin.AnalysisErrorsParams.fromNotification(notification);

        if (!p.isAbsolute(params.file)) {
          throw StateError('${params.file} is not an absolute path');
        }

        // TODO why are all files re-analyzed when a single file changes?
        // TODO handle removed files or there is otherwise a memory leak
        link.lintsForLibrary[params.file] = params;

        final lintsForFile = _allPluginsSub
            .read()
            .values
            .expand<plugin.AnalysisError>(
              (link) => link.lintsForLibrary[params.file]?.errors ?? const [],
            )
            .toList();

        log('got lints for ${params.file}: ${lintsForFile.map((e) => e.code)}');

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
  }

  Future<List<plugin.Response>> _requestAllPlugins(
    plugin.RequestParams request,
  ) {
    return Future.wait(
      _allPluginsSub.read().keys.map((key) => _requestPlugin(key, request)),
    );
  }

  Future<plugin.Response> _requestPlugin(
    Uri pluginKey,
    plugin.RequestParams request,
  ) async {
    assert(
      _allPluginsSub.read().containsKey(pluginKey),
      'Bad state, plugin $pluginKey not found',
    );
    final link = _allPluginsSub.read()[pluginKey]!;
    final id = _uui.v4();

    final response = link.responses.firstWhere((message) => message.id == id);
    link.send(request.toRequest(id).toJson());
    return response;
  }

  @override
  Future<plugin.EditGetFixesResult> handleEditGetFixes(
    plugin.EditGetFixesParams parameters,
  ) async {
    final responses = await _requestAllPlugins(parameters);

    return plugin.EditGetFixesResult(
      responses
          .map(plugin.EditGetFixesResult.fromResponse)
          .expand((e) => e.fixes)
          .toList(),
    );
  }

  @override
  FutureOr<plugin.PluginVersionCheckResult> handlePluginVersionCheck(
    plugin.PluginVersionCheckParams parameters,
  ) {
    _versionCheckRequest = parameters;

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

  plugin.AnalysisSetPriorityFilesParams? _priorityFilesForPlugin(
    Uri pluginKey,
  ) {
    final allPriorityFiles = _lastSetPriorityFilesRequest?.files;
    if (allPriorityFiles == null) return null;

    final link = _allPluginsSub.read()[pluginKey];
    if (link == null) {
      throw StateError('Plugin $pluginKey not found');
    }

    final priorityFilesForPlugin = allPriorityFiles.where(
      (priorityFile) {
        return _container.read(_contextRootsForPlugin(pluginKey)).any(
              (contextRoot) => p.isWithin(contextRoot.root, priorityFile),
            );
      },
    ).toList();

    return plugin.AnalysisSetPriorityFilesParams(priorityFilesForPlugin);
  }

  @override
  FutureOr<plugin.AnalysisSetPriorityFilesResult>
      handleAnalysisSetPriorityFiles(
    plugin.AnalysisSetPriorityFilesParams parameters,
  ) async {
    // TODO verify priority files are part of the context roots associated with the plugin
    _lastSetPriorityFilesRequest = parameters;

    await Future.wait(
      _allPluginsSub.read().entries.map(
            (entry) =>
                // TODO filter request if previous/new values are the same
                _requestPlugin(entry.key, _priorityFilesForPlugin(entry.key)!),
          ),
    );

    return plugin.AnalysisSetPriorityFilesResult();
  }

  @override
  FutureOr<plugin.AnalysisSetSubscriptionsResult>
      handleAnalysisSetSubscriptions(
    plugin.AnalysisSetSubscriptionsParams parameters,
  ) async {
    await _requestAllPlugins(parameters);
    return plugin.AnalysisSetSubscriptionsResult();
  }

  @override
  FutureOr<plugin.AnalysisUpdateContentResult> handleAnalysisUpdateContent(
    plugin.AnalysisUpdateContentParams parameters,
  ) async {
    await _requestAllPlugins(parameters);
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
      await _requestAllPlugins(parameters);
      return plugin.PluginShutdownResult();
    } finally {
      _container.dispose();
    }
  }
}

Pubspec _loadPubspecAt(String packagePath) {
  final pubspecFile = File(p.join(packagePath, 'pubspec.yaml'));
  if (!pubspecFile.existsSync()) {
    throw StateError('No pubspec.yaml found at $packagePath.');
  }

  return Pubspec.parse(
    pubspecFile.readAsStringSync(),
    sourceUrl: pubspecFile.uri,
  );
}

extension on Pubspec {
  bool hasDependency(String name) {
    return dependencies.containsKey(name) ||
        devDependencies.containsKey(name) ||
        dependencyOverrides.containsKey(name);
  }
}
