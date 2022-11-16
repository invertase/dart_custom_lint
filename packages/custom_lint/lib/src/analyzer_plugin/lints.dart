import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:analyzer_plugin/protocol/protocol_common.dart' as plugin;
import 'package:analyzer_plugin/protocol/protocol_generated.dart' as plugin;
import 'package:path/path.dart' as p;
import 'package:riverpod/riverpod.dart';
import 'package:yaml/yaml.dart';

import '../riverpod_utils.dart';
import 'plugin_link.dart';

/// The plugin status on whether it successfully started or not
final _pluginNotStartedLintProvider = Provider.autoDispose
    .family<Map<String, plugin.AnalysisErrorsParams>, PluginKey>(
        (ref, linkKey) {
  ref.cache5();

  // unwrapPrevious to simplify the logic
  final link = ref.watch(pluginLinkProvider(linkKey)).unwrapPrevious();

  // The plugin has successfully started, so no lint.
  if (link.hasValue) return {};

  final pluginName = ref.watch(
    pluginMetaProvider(linkKey).select((value) => value.name),
  );
  final rootsForPlugin = ref.watch(contextRootsForPluginProvider(linkKey));

  final errors = <String, plugin.AnalysisErrorsParams>{};

  for (final contextRoot in rootsForPlugin) {
    final pubSpecFile = File(
      p.join(contextRoot.root, 'pubspec.yaml'),
    );
    final pubSpecString = pubSpecFile.readAsStringSync();

    final pubSpec = loadYamlNode(pubSpecString) as YamlMap;
    final allDependencies = <YamlMap>[
      if (pubSpec.nodes.containsKey('dependencies'))
        pubSpec.nodes['dependencies']! as YamlMap,
      if (pubSpec.nodes.containsKey('dev_dependencies'))
        pubSpec.nodes['dev_dependencies']! as YamlMap,
      if (pubSpec.nodes.containsKey('dependency_overrides'))
        pubSpec.nodes['dependency_overrides']! as YamlMap,
    ];

    final pluginDependencyNode = allDependencies
        .expand((map) => map.nodes.entries)
        .firstWhere(
          // keys may be a YamlScalar, so we strinfigy it instead
          (entry) => entry.key.toString() == pluginName,
        )
        .key as YamlScalar;

    final pluginLocationInsidePubspec = plugin.Location(
      pubSpecFile.path,
      pluginDependencyNode.span.start.offset,
      pluginDependencyNode.span.length,
      pluginDependencyNode.span.start.line,
      pluginDependencyNode.span.start.column,
      endLine: pluginDependencyNode.span.end.line,
      endColumn: pluginDependencyNode.span.end.column,
    );

    final errorForContext = plugin.AnalysisErrorsParams(
      pubSpecFile.path,
      [
        if (link.isLoading)
          plugin.AnalysisError(
            plugin.AnalysisErrorSeverity.WARNING,
            plugin.AnalysisErrorType.LINT,
            pluginLocationInsidePubspec,
            'The plugin is currently starting',
            'custom_lint_plugin_loading',
          )
        else if (link.hasError)
          plugin.AnalysisError(
            plugin.AnalysisErrorSeverity.ERROR,
            plugin.AnalysisErrorType.LINT,
            pluginLocationInsidePubspec,
            'Failed to start plugin',
            'custom_lint_plugin_error',
            contextMessages: [
              // Add informations on the error
              plugin.DiagnosticMessage(
                link.error.toString(),
                plugin.Location(
                  p.join(
                    linkKey.uri.toFilePath(),
                    'bin',
                    'custom_lint.dart',
                  ),
                  0,
                  0,
                  1,
                  1,
                ),
              ),
            ],
          ),
      ],
    );

    errors[errorForContext.file] = errorForContext;
  }

  return errors;
});

/// Causes the lint providers to recompute when the plugin has been hot-reloaded
final invalidateLintsProvider =
    Provider.autoDispose((ref) => Random().nextDouble());

/// The list of lints per Dart Library emitted by a plugin, including
/// built-in lints such as whether the plugin as started or not.
final lintsForPluginProvider = StreamProvider.autoDispose
    .family<Map<String, plugin.AnalysisErrorsParams>, PluginKey>(
        (ref, linkKey) async* {
  ref.watch(invalidateLintsProvider);
  ref.cache5();
  if (ref.watch(includeBuiltInLintsProvider)) {
    final pluginNotStartedLint =
        ref.watch(_pluginNotStartedLintProvider(linkKey));

    if (pluginNotStartedLint.isNotEmpty) {
      yield* Stream.value(pluginNotStartedLint);
      // if somehow the plugin failed to start, there is no way the plugin will have lints
      return;
    }
  }

  final link = await ref.watch(pluginLinkProvider(linkKey).future);

  // TODO why are all files re-analyzed when a single file changes?
  // TODO handle removed files or there is otherwise a memory leak

  var lints = <String, plugin.AnalysisErrorsParams>{};

  await for (final lint in link.channel.lints) {
    if (lint.errors.isEmpty) {
      // TODO is this enough to handle when files are deleted?
      lints = Map.from(lints)..remove(lint.file);
    } else {
      lints = {...lints, lint.file: lint};
    }

    yield lints;
  }
});

/// The combination of all lints emitted by the currently active plugins
final allLintsProvider =
    Provider.autoDispose<Map<String, plugin.AnalysisErrorsParams>>((ref) {
  ref.cache5();
  final linkKeys = ref.watch(allPluginLinkKeysProvider);

  ref.state = {};

  // Manually watching individual plugin lints to have the map
  // only update changed keys instead of recreating all map values.
  for (final linkKey in linkKeys) {
    ref.listen<AsyncValue<Map<String, plugin.AnalysisErrorsParams>>>(
      lintsForPluginProvider(linkKey),
      (previous, next) {
        final previousLints = previous?.asData?.value;
        // We voluntarily treat "loading" as null, to clear lints during
        // plugin restart
        final lints = next.isRefreshing ||
                next.isLoading ||
                (previous?.isRefreshing ?? false)
            ? null
            : next.asData?.value;
        final allFiles = {...?lints?.keys, ...?previousLints?.keys};

        for (final fileToUpdate in allFiles) {
          if (previousLints?[fileToUpdate] == lints?[fileToUpdate]) continue;

          final lintsForFile = linkKeys.expand<plugin.AnalysisError>(
            (link) {
              final lintsForLink = ref.read(lintsForPluginProvider(link));

              if (lintsForLink.isLoading) return const [];

              return lintsForLink.asData?.value[fileToUpdate]?.errors ??
                  const [];
            },
          ).toList();

          ref.state = {
            ...ref.state,
            fileToUpdate:
                plugin.AnalysisErrorsParams(fileToUpdate, lintsForFile),
          };
        }
      },
      // Needed to build the initial value
      fireImmediately: true,
    );
  }

  return ref.state;
});
