import 'dart:async';
import 'dart:io';

import 'package:analyzer_plugin/protocol/protocol_common.dart' as plugin;
import 'package:analyzer_plugin/protocol/protocol_generated.dart' as plugin;
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;
import 'package:riverpod/riverpod.dart';
import 'package:yaml/yaml.dart';

import '../protocol/internal_protocol.dart';
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

/// A provider used to forcifly refresh the lints, by refreshing this provider.
final invalidateLintsProvider = Provider.autoDispose((ref) => Object());

/// The list of lints per Dart Library emitted by a plugin, including
/// built-in lints such as whether the plugin as started or not.
final lintsForPluginProvider = StreamProvider.autoDispose
    .family<Map<String, CustomAnalysisNotification>, PluginKey>(
        (ref, linkKey) async* {
  ref.watch(invalidateLintsProvider);
  ref.cache5();
  if (ref.watch(includeBuiltInLintsProvider)) {
    final pluginNotStartedLint =
        ref.watch(_pluginNotStartedLintProvider(linkKey));

    if (pluginNotStartedLint.isNotEmpty) {
      yield* Stream.value({
        for (final entry in pluginNotStartedLint.entries)
          entry.key: CustomAnalysisNotification(entry.value, []),
      });
      // if somehow the plugin failed to start, there is no way the plugin will have lints
      return;
    }
  }

  final link = await ref.watch(pluginLinkProvider(linkKey).future);

  // TODO why are all files re-analyzed when a single file changes?
  // TODO handle removed files or there is otherwise a memory leak

  var lints = <String, CustomAnalysisNotification>{};

  await for (final lint in link.channel.lints) {
    if (lint.lints.errors.isEmpty && lint.expectLints.isEmpty) {
      // TODO is this enough to handle when files are deleted?
      lints = Map.from(lints)..remove(lint.lints.file);
    } else {
      lints = {...lints, lint.lints.file: lint};
    }

    yield lints;
  }
});

@immutable
class _ComparableExpectLintMeta {
  const _ComparableExpectLintMeta(this.line, this.code);

  final int line;
  final String code;

  @override
  int get hashCode => Object.hash(line, code);

  @override
  bool operator ==(Object other) {
    return other is _ComparableExpectLintMeta &&
        other.code == code &&
        other.line == line;
  }
}

plugin.AnalysisErrorsParams _applyExpectLint(
  List<CustomAnalysisNotification?> lintsForFile, {
  required String filePath,
}) {
  final allExpectedLints = lintsForFile
      .whereNotNull()
      .expand((e) => e.expectLints)
      .map((e) => _ComparableExpectLintMeta(e.line, e.code))
      .toSet();

  // The list of all the expect_lints codes that don't have a matching lint.
  final unfulfilledExpectedLints =
      lintsForFile.whereNotNull().expand((e) => e.expectLints).toList();

  final lintsExcludingExpectedLints =
      lintsForFile.whereNotNull().expand((e) => e.lints.errors).where((lint) {
    final matchingExpectLintMeta = _ComparableExpectLintMeta(
      // Lints use 1-based offsets but expectLints use 0-based offsets. So
      // we remove 1 to have them on the same unit. Then we remove 1 again
      // to access the line before the lint.
      lint.location.startLine - 2,
      lint.code,
    );

    if (allExpectedLints.contains(matchingExpectLintMeta)) {
      // The lint has a matching expect_lint. Let's ignore the lint and mark
      // the associated expect_lint as fulfilled.
      unfulfilledExpectedLints.removeWhere(
        (e) =>
            e.line == matchingExpectLintMeta.line &&
            e.code == matchingExpectLintMeta.code,
      );
      return false;
    }
    return true;
  });

  return plugin.AnalysisErrorsParams(filePath, [
    ...lintsExcludingExpectedLints,
    for (final unfulfilledExpectedLint in unfulfilledExpectedLints)
      plugin.AnalysisError(
        plugin.AnalysisErrorSeverity.INFO,
        plugin.AnalysisErrorType.LINT,
        unfulfilledExpectedLint.location.asLocation(),
        'Expected to find the lint ${unfulfilledExpectedLint.code} on next line but none found.',
        'unfulfilled_expect_lint',
        correction:
            'Either update the code such that it emits the lint ${unfulfilledExpectedLint.code} '
            'or update the expect_lint clause to not include the code ${unfulfilledExpectedLint.code}.',
      )
  ]);
}

/// The combination of all lints emitted by the currently active plugins
final allLintsProvider =
    Provider.autoDispose<Map<String, plugin.AnalysisErrorsParams>>((ref) {
  ref.cache5();
  final linkKeys = ref.watch(allPluginLinkKeysProvider);

  ref.state = {};

  // Manually watching individual plugin lints to have the map
  // only update changed keys instead of recreating all map values.
  for (final linkKey in linkKeys) {
    ref.listen<AsyncValue<Map<String, CustomAnalysisNotification>>>(
      lintsForPluginProvider(linkKey),
      (previous, next) {
        final previousLints = previous?.asData?.value;
        // We voluntarily treat "loading" as null, to clear lints during
        // plugin restart
        final lints = next.isLoading ? null : next.asData?.value;
        final allFiles = {...?lints?.keys, ...?previousLints?.keys};

        for (final fileToUpdate in allFiles) {
          if (previousLints?[fileToUpdate] == lints?[fileToUpdate]) continue;

          final unfilteredLintsForFile = linkKeys
              .map(
                (link) => ref
                    .read(lintsForPluginProvider(link))
                    .asData
                    ?.value[fileToUpdate],
              )
              .toList();

          final filteredLintsForFile = _applyExpectLint(
            unfilteredLintsForFile,
            filePath: fileToUpdate,
          );

          ref.state = {...ref.state, fileToUpdate: filteredLintsForFile};
        }
      },
      // Needed to build the initial value
      fireImmediately: true,
    );
  }

  return ref.state;
});
