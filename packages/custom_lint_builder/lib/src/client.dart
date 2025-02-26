// ignore_for_file: invalid_use_of_internal_member, using custom_lint_core utils

import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io' as io;

import 'package:analyzer/dart/analysis/analysis_context.dart';
import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/context_root.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/session.dart';
import 'package:analyzer/error/error.dart'
    hide
        // ignore: undefined_hidden_name, Needed to support lower analyzer versions
        LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:analyzer/source/file_source.dart';
import 'package:analyzer/source/line_info.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/plugin/plugin.dart' as analyzer_plugin;
import 'package:analyzer_plugin/protocol/protocol_common.dart'
    as analyzer_plugin;
import 'package:analyzer_plugin/protocol/protocol_generated.dart'
    as analyzer_plugin;
import 'package:analyzer_plugin/starter.dart' as analyzer_plugin;
import 'package:collection/collection.dart';
// ignore: implementation_imports, tight versioning
import 'package:custom_lint/src/async_operation.dart';
// ignore: implementation_imports, tight versioning
import 'package:custom_lint/src/v2/protocol.dart';
// ignore: implementation_imports, tight versioning
import 'package:custom_lint_core/src/change_reporter.dart';
// ignore: implementation_imports, tight versioning
import 'package:custom_lint_core/src/fixes.dart';
// ignore: implementation_imports, tight versioning
import 'package:custom_lint_core/src/plugin_base.dart';
// ignore: implementation_imports, tight versioning
import 'package:custom_lint_core/src/resolver.dart';
// ignore: implementation_imports, tight versioning
import 'package:custom_lint_core/src/runnable.dart';
import 'package:custom_lint_visitor/custom_lint_visitor.dart';
import 'package:glob/glob.dart';
import 'package:hotreloader/hotreloader.dart';
import 'package:meta/meta.dart';
import 'package:package_config/package_config.dart' show PackageConfig;
import 'package:path/path.dart';
import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';

import '../custom_lint_builder.dart';
import 'channel.dart';
import 'custom_analyzer_converter.dart';
import 'expect_lint.dart';
import 'ignore.dart';

/// Analysis utilities for custom_lint
extension AnalysisSessionUtils on AnalysisContext {
  /// Create a [CustomLintResolverImpl] for a file.
  @internal
  CustomLintResolverImpl? createResolverForFile(File file) {
    if (!file.exists) return null;
    final source = FileSource(file);
    final lineInfo = LineInfo.fromContent(source.contents.data);

    return CustomLintResolverImpl(
      () async => safeGetResolvedUnitResult(file.path),
      lineInfo: lineInfo,
      source: source,
      path: file.path,
    );
  }
}

extension on AnalysisContext {
  /// Obtains a [ResolvedUnitResult] for the given [path], while catching [InconsistentAnalysisException] and retrying.
  @internal
  Future<ResolvedUnitResult> safeGetResolvedUnitResult(String path) async {
    for (var i = 0; i < 5; i++) {
      try {
        final result = await currentSession.getResolvedUnit(path);
        return result as ResolvedUnitResult;
      } on InconsistentAnalysisException {
        // Retry analysis on InconsistentAnalysisException
        await applyPendingFileChanges();
      }
    }
    throw StateError('Failed to get resolved unit result for $path');
  }
}

Future<bool> _isVmServiceEnabled() async {
  final serviceInfo = await dev.Service.getInfo();
  return serviceInfo.serverUri != null;
}

extension on analyzer_plugin.AnalysisErrorFixes {
  ({String id, int priority})? findBatchFix(String filePath) {
    final fixToBatch = fixes
        .where((change) => change.canBatchFix(filePath))
        // Only a single fix at a time can be batched.
        .singleOrNull;
    if (fixToBatch == null) return null;
    final id = fixToBatch.change.id;
    if (id == null) return null;

    return (
      id: id,
      priority: fixToBatch.priority,
    );
  }
}

extension on analyzer_plugin.PrioritizedSourceChange {
  bool canBatchFix(String filePath) {
    return !isIgnoreChange &&
        change.edits.every((element) => element.file == filePath);
  }

  bool get isIgnoreChange {
    return change.id == IgnoreCode.ignoreId;
  }
}

/// The custom_lint client
class CustomLintPluginClient {
  /// The custom_lint client
  CustomLintPluginClient(
    this._channel, {
    required this.includeBuiltInLints,
    required this.fix,
  }) {
    _analyzerPlugin = _ClientAnalyzerPlugin(
      _channel,
      this,
      resourceProvider: PhysicalResourceProvider.INSTANCE,
    );
    _hotReloader = Future(_maybeStartHotLoad);
    final starter = analyzer_plugin.ServerPluginStarter(_analyzerPlugin);
    starter.start(_channel.sendPort);

    _channelInputSub = _channel.input.listen(_handleCustomLintRequest);
  }

  /// Whether to include lints automatically by custom_lint.
  /// This includes:
  /// - Errors at the top of the file when a lint threw
  final bool includeBuiltInLints;

  /// Whether to attempt fixing analysis issues before reporting them.
  final bool fix;
  late final StreamSubscription<void> _channelInputSub;
  late final Future<HotReloader?> _hotReloader;
  final CustomLintClientChannel _channel;
  late final _ClientAnalyzerPlugin _analyzerPlugin;

  var _contextRootsForPlugin = <String, List<ContextRoot>>{};

  Future<HotReloader?> _maybeStartHotLoad() async {
    if (!await _isVmServiceEnabled()) return null;
    return HotReloader.create(
      onAfterReload: (value) {
        switch (value.result) {
          case HotReloadResult.Succeeded:
          case HotReloadResult.PartiallySucceeded:
            _analyzerPlugin.reAnalyze();
          default:
        }
      },
    );
  }

  bool _isPluginActiveForContextRoot(
    AnalysisContext analysisContext, {
    required String pluginName,
  }) {
    final contextRootsForPlugin = _contextRootsForPlugin[pluginName];
    if (contextRootsForPlugin == null) {
      return false;
    }

    return contextRootsForPlugin.any(
      (contextRootForPlugin) =>
          analysisContext.contextRoot.root == contextRootForPlugin.root,
    );
  }

  Future<void> _handleCustomLintRequest(CustomLintRequest request) async {
    try {
      // Analyzer_plugin requests are handles by the _analyzer_plugin client
      final CustomLintResponse? response;
      switch (request) {
        case CustomLintRequestAnalyzerPluginRequest():
          response = null;
        case CustomLintRequestAwaitAnalysisDone(:final reload):
          await _analyzerPlugin._awaitAnalysisDone(reload: reload);
          response = CustomLintResponse.awaitAnalysisDone(id: request.id);
        case CustomLintRequestPing():
          response = CustomLintResponse.pong(id: request.id);
      }

      if (response != null) {
        _channel.sendResponse(response);
      }
    } catch (err, stack) {
      _channel.sendResponse(
        CustomLintResponse.error(
          id: request.id,
          message: err.toString(),
          stackTrace: stack.toString(),
        ),
      );
    }
  }

  Future<void> _updateActivePluginList(
    AnalysisContextCollection analysisContextCollection,
    Map<AnalysisContext, Future<Pubspec>> pubspecs,
  ) async {
    _contextRootsForPlugin = {};

    for (final analysisContext in analysisContextCollection.contexts) {
      final pubspec = await pubspecs[analysisContext]!;

      for (final pluginName in _channel.registeredPlugins.keys) {
        final isPluginEnabledInContext =
            pubspec.dependencies.containsKey(pluginName) ||
                pubspec.devDependencies.containsKey(pluginName) ||
                pubspec.dependencyOverrides.containsKey(pluginName);

        if (isPluginEnabledInContext) {
          final contextRootsForPlugin =
              _contextRootsForPlugin[pluginName] ??= [];
          contextRootsForPlugin.add(analysisContext.contextRoot);
        }
      }
    }
  }

  /// An event handler for uncaught errors.
  ///
  /// This method will be invoked for errors that are not associated with a lint/fix/assist.
  void handleError(Object error, StackTrace stackTrace) {
    _channel.sendEvent(
      CustomLintEvent.error(
        error.toString(),
        stackTrace.toString(),
        pluginName: null,
      ),
    );
  }

  /// An event handler for invocations to [print] in the client.
  ///
  /// This method will be invoked for prints that are not associated with a lint/fix/assist.
  void handlePrint(String message) {
    _channel.sendEvent(CustomLintEvent.print(message, pluginName: null));
  }

  Future<void> _handlePluginShutdown() async {
    await Future.wait<void>([
      _channelInputSub.cancel(),
      _hotReloader.catchError((_) => null).then((value) => value?.stop()),
    ]);
  }
}

class _CustomLintAnalysisConfigs {
  _CustomLintAnalysisConfigs(
    this.configs,
    this.rules,
    this.fixes,
    this.assists,
    this.analysisContext,
    this.pubspec,
  );

  factory _CustomLintAnalysisConfigs.from(
    Pubspec pubspecForContext,
    PackageConfig packageConfig,
    AnalysisContext analysisContext,
    CustomLintPluginClient client,
  ) {
    final configs = CustomLintConfigs.parse(
      analysisContext.contextRoot.optionsFile,
      packageConfig,
    );

    final activePluginsForContext = Map.fromEntries(
      client._channel.registeredPlugins.entries.where(
        (plugin) => client._isPluginActiveForContextRoot(
          analysisContext,
          pluginName: plugin.key,
        ),
      ),
    );

    final rules = _lintRulesForContext(activePluginsForContext, configs);
    final fixes = _fixesForRules(
      rules,
      includeBuiltInLints: client.includeBuiltInLints,
    );
    final assists = _assistsForContext(
      activePluginsForContext,
      configs,
      client,
    );

    return _CustomLintAnalysisConfigs(
      configs,
      rules,
      fixes,
      assists,
      analysisContext,
      pubspecForContext,
    );
  }

  static List<LintRule> _lintRulesForContext(
    Map<String, PluginBase> activePluginsForContext,
    CustomLintConfigs configs,
  ) {
    return activePluginsForContext.entries
        .expand((plugin) => plugin.value.getLintRules(configs))
        .where((lintRule) => lintRule.isEnabled(configs))
        .toList();
  }

  static Map<LintCode, List<Fix>> _fixesForRules(
    List<LintRule> rules, {
    required bool includeBuiltInLints,
  }) {
    return {
      for (final rule in rules)
        rule.code: [
          ...rule.getFixes(),
          if (includeBuiltInLints) IgnoreCode(),
        ],
    };
  }

  static List<Assist> _assistsForContext(
    Map<String, PluginBase> activePluginsForContext,
    CustomLintConfigs configs,
    CustomLintPluginClient client,
  ) {
    return activePluginsForContext.entries
        .expand((plugin) => plugin.value.getAssists())
        .toList();
  }

  final CustomLintConfigs configs;
  final List<LintRule> rules;
  final Map<LintCode, List<Fix>> fixes;
  final List<Assist> assists;
  final Pubspec pubspec;
  final AnalysisContext analysisContext;
}

@immutable
class _AnalysisErrorsKey {
  const _AnalysisErrorsKey({
    required this.filePath,
    required this.analysisContext,
  });

  final String filePath;
  final AnalysisContext analysisContext;

  @override
  bool operator ==(Object other) =>
      other is _AnalysisErrorsKey &&
      other.filePath == filePath &&
      other.analysisContext == analysisContext;

  @override
  int get hashCode => Object.hash(filePath, analysisContext);
}

class _FileContext {
  _FileContext({
    required this.resolver,
    required this.analysisContext,
    required this.contextCollection,
    required this.path,
    required this.configs,
  }) : key = _AnalysisErrorsKey(
          filePath: path,
          analysisContext: analysisContext,
        );

  final String path;
  final _AnalysisErrorsKey key;
  final CustomLintResolverImpl resolver;
  final AnalysisContext analysisContext;
  final AnalysisContextCollection contextCollection;
  final _CustomLintAnalysisConfigs configs;
}

class _ClientAnalyzerPlugin extends analyzer_plugin.ServerPlugin {
  _ClientAnalyzerPlugin(
    this._channel,
    this._client, {
    required super.resourceProvider,
  });

  final CustomLintClientChannel _channel;
  final CustomLintPluginClient _client;
  final _contextCollection = BehaviorSubject<AnalysisContextCollection>();
  final _pendingOperations = <Future<void>>[];
  var _customLintConfigsForAnalysisContexts =
      <AnalysisContext, _CustomLintAnalysisConfigs>{};
  final _analysisErrorsForAnalysisContexts =
      <_AnalysisErrorsKey, List<AnalysisError>>{};

  @override
  List<String> get fileGlobsToAnalyze => ['*'];

  @override
  String get name => 'custom_lint_client';

  @override
  String get version => '1.0.0-alpha.0';

  Future<_FileContext?> _fileContext(String path) async {
    final contextCollection = await _contextCollection.safeFirst;
    final analysisContext = contextCollection.contextFor(path);
    final resolver = analysisContext.createResolverForFile(
      resourceProvider.getFile(path),
    );

    if (resolver == null) return null;

    final configs = _customLintConfigsForAnalysisContexts[analysisContext];
    if (configs == null) return null;

    return _FileContext(
      path: path,
      resolver: resolver,
      analysisContext: analysisContext,
      contextCollection: contextCollection,
      configs: configs,
    );
  }

  Future<void> reAnalyze() async {
    final contextCollection = _contextCollection.valueOrNull;
    if (contextCollection != null) {
      await afterNewContextCollection(contextCollection: contextCollection);
    }
  }

  @override
  Future<void> afterNewContextCollection({
    required AnalysisContextCollection contextCollection,
  }) {
    _contextCollection.add(contextCollection);
    return _runOperation(() async {
      // Clear lints as we got a new context collection
      _analysisErrorsForAnalysisContexts.removeWhere(
        (key, value) =>
            contextCollection.contexts.contains(key.analysisContext),
      );

      // Wait for hot reload to start.
      // Otherwise tests may miss the first hot reload.
      await _client._hotReloader;

      final pubspecs = <AnalysisContext, Future<Pubspec>>{};

      for (final context in contextCollection.contexts) {
        final pubspec = tryFindProjectDirectory(
          io.Directory(context.contextRoot.root.path),
        );

        if (pubspec != null) {
          pubspecs[context] = parsePubspec(pubspec);
        }
      }

      // Running before updating the configs as the config parsing depends
      // on this operation.
      await _client._updateActivePluginList(contextCollection, pubspecs);

      _customLintConfigsForAnalysisContexts = {
        for (final pubspecEntry in pubspecs.entries)
          pubspecEntry.key: _CustomLintAnalysisConfigs.from(
            await pubspecEntry.value,
            await parsePackageConfig(io.Directory.current),
            pubspecEntry.key,
            _client,
          ),
      };

      return super.afterNewContextCollection(
        contextCollection: contextCollection,
      );
    });
  }

  @override
  Future<analyzer_plugin.EditGetAssistsResult> handleEditGetAssists(
    analyzer_plugin.EditGetAssistsParams parameters,
  ) async {
    // TODO test
    final contextCollection = await _contextCollection.safeFirst;
    final analysisContext = contextCollection.contextFor(parameters.file);
    final assists =
        _customLintConfigsForAnalysisContexts[analysisContext]?.assists;

    final resolver = analysisContext.createResolverForFile(
      resourceProvider.getFile(parameters.file),
    );
    if (resolver == null || assists == null || assists.isEmpty) {
      return analyzer_plugin.EditGetAssistsResult([]);
    }

    final configs = _customLintConfigsForAnalysisContexts[analysisContext];
    if (configs == null) {
      return analyzer_plugin.EditGetAssistsResult([]);
    }

    final target = SourceRange(parameters.offset, parameters.length);
    final postRunCallbacks = <void Function()>[];
    // TODO implement verbose mode to log lint duration
    final registry = NodeLintRegistry(LintRegistry(), enableTiming: false);
    final sharedState = <Object, Object?>{};

    final changeReporter = ChangeReporterImpl(
      configs.analysisContext.currentSession,
      resolver,
    );

    await Future.wait([
      for (final assist in configs.assists)
        _runAssistStartup(
          resolver,
          assist,
          CustomLintContext(
            LintRuleNodeRegistry(registry, assist.runtimeType.toString()),
            postRunCallbacks.add,
            sharedState,
            configs.pubspec,
          ),
          target,
        ),
    ]);
    await Future.wait([
      for (final assist in configs.assists)
        _runAssistRun(
          resolver,
          assist,
          CustomLintContext(
            LintRuleNodeRegistry(registry, assist.runtimeType.toString()),
            postRunCallbacks.add,
            sharedState,
            configs.pubspec,
          ),
          changeReporter,
          target,
        ),
    ]);

    runPostRunCallbacks(postRunCallbacks);

    return analyzer_plugin.EditGetAssistsResult(
      await changeReporter.complete(),
    );
  }

  Future<void> _runAssistStartup(
    CustomLintResolver resolver,
    Assist assist,
    CustomLintContext context,
    SourceRange target,
  ) async {
    return _runLintZoned(
      resolver,
      () => assist.startUp(resolver, context, target),
      name: assist.runtimeType.toString(),
    );
  }

  Future<void> _runAssistRun(
    CustomLintResolver resolver,
    Assist assist,
    CustomLintContext context,
    ChangeReporter changeReporter,
    SourceRange target,
  ) async {
    return _runLintZoned(
      resolver,
      () => assist.run(resolver, changeReporter, context, target),
      name: assist.runtimeType.toString(),
    );
  }

  @override
  Future<analyzer_plugin.EditGetFixesResult> handleEditGetFixes(
    analyzer_plugin.EditGetFixesParams parameters,
  ) async {
    final context = await _fileContext(parameters.file);
    if (context == null) return analyzer_plugin.EditGetFixesResult([]);

    final analysisErrorsForContext =
        _analysisErrorsForAnalysisContexts[context.key] ?? const [];

    final fixes = await _computeFixes(
      analysisErrorsForContext
          .where((error) => error.sourceRange.contains(parameters.offset))
          .toList(),
      context,
      analysisErrorsForContext,
    );

    return analyzer_plugin.EditGetFixesResult(
      fixes.expand<analyzer_plugin.AnalysisErrorFixes>((fixes) {
        return [
          fixes.fix,
          if (fixes.batchFixes case final batchFixes?) batchFixes,
        ];
      }).toList(),
    );
  }

  Future<
      List<
          ({
            analyzer_plugin.AnalysisErrorFixes? batchFixes,
            analyzer_plugin.AnalysisErrorFixes fix
          })>> _computeFixes(
    List<AnalysisError> errorsToFix,
    _FileContext context,
    List<AnalysisError> analysisErrorsForContext,
  ) async {
    return Future.wait(
      errorsToFix.map((error) async {
        final toBatch = analysisErrorsForContext
            .where((e) => e.errorCode == error.errorCode)
            .toList();

        final changeReporterBuilder = ChangeReporterBuilderImpl(
          context.resolver,
          context.configs.analysisContext.currentSession,
        );

        await _runFixes(
          context,
          error,
          analysisErrorsForContext,
          changeReporterBuilder: changeReporterBuilder,
        );
        final fix = await changeReporterBuilder.completeAsFixes(
          error,
          context,
        );

        final batchFix = fix.findBatchFix(context.path);
        if (batchFix == null || toBatch.length <= 1) {
          return (
            fix: fix,
            batchFixes: null,
          );
        }

        final batchReporter = ChangeReporterImpl(
          context.configs.analysisContext.currentSession,
          context.resolver,
        );

        final batchReporterBuilder = BatchChangeReporterBuilder(
          batchReporter.createChangeBuilder(
            message: 'Fix all "${error.errorCode}"',
            priority: batchFix.priority - 1,
          ),
        );

        // Compute batch in sequential mode because ChangeBuilder requires it.
        for (final toBatchError in toBatch) {
          await _runFixes(
            where: (fix) => fix.id == batchFix.id,
            context,
            toBatchError,
            analysisErrorsForContext,
            changeReporterBuilder: batchReporterBuilder,
            sequential: true,
          );
        }

        final batchFixes =
            await batchReporterBuilder.completeAsFixes(error, context);

        return (
          fix: fix,
          batchFixes: batchFixes,
        );
      }),
    );
  }

  Future<void> _runFixes(
    _FileContext context,
    AnalysisError analysisError,
    List<AnalysisError> allErrors, {
    required ChangeReporterBuilder changeReporterBuilder,
    bool sequential = false,
    bool Function(Fix fix)? where,
  }) async {
    Iterable<Fix>? fixesForError =
        context.configs.fixes[analysisError.errorCode];
    if (fixesForError == null) return;

    if (where != null) {
      fixesForError = fixesForError.where(where);
    }

    final otherErrors = allErrors
        .where(
          (element) =>
              element != analysisError &&
              element.errorCode == analysisError.errorCode,
        )
        .toList();

    await _run<FixArgs>(
      context,
      fixesForError.map((fix) {
        return (
          runnable: fix,
          args: (
            reporter: changeReporterBuilder.createChangeReporter(id: fix.id),
            analysisError: analysisError,
            others: otherErrors,
          )
        );
      }),
      sequential: sequential,
    );

    await changeReporterBuilder.waitForCompletion();
  }

  Future<void> _run<ArgsT>(
    _FileContext context,
    Iterable<({Runnable<ArgsT> runnable, ArgsT args})> allRunnables, {
    bool sequential = false,
  }) async {
    // TODO implement verbose mode to log lint duration

    final bundledRunnables =
        sequential ? allRunnables.map((e) => [e]).toList() : [allRunnables];

    for (final runnableBundle in bundledRunnables) {
      final registry = NodeLintRegistry(LintRegistry(), enableTiming: false);
      final postRunCallbacks = <void Function()>[];
      final sharedState = <Object, Object?>{};

      await Future.wait([
        for (final (:runnable, args: _) in runnableBundle)
          _runLintZoned(
            context.resolver,
            () => runnable.startUp(
              context.resolver,
              CustomLintContext(
                LintRuleNodeRegistry(registry, runnable.runtimeType.toString()),
                postRunCallbacks.add,
                sharedState,
                context.configs.pubspec,
              ),
            ),
            name: runnable.runtimeType.toString(),
          ),
      ]);

      await Future.wait([
        for (final (:runnable, :args) in runnableBundle)
          _runLintZoned(
            context.resolver,
            () => runnable.callRun(
              context.resolver,
              CustomLintContext(
                LintRuleNodeRegistry(registry, runnable.runtimeType.toString()),
                postRunCallbacks.add,
                sharedState,
                context.configs.pubspec,
              ),
              args,
            ),
            name: runnable.runtimeType.toString(),
          ),
      ]);

      runPostRunCallbacks(postRunCallbacks);
    }
  }

  @override
  Future<analyzer_plugin.AnalysisHandleWatchEventsResult>
      handleAnalysisHandleWatchEvents(
    analyzer_plugin.AnalysisHandleWatchEventsParams parameters,
  ) async {
    final contextCollection = await _contextCollection.safeFirst;

    for (final event in parameters.events) {
      switch (event.type) {
        case analyzer_plugin.WatchEventType.REMOVE:

          /// The file was deleted. Let's release associated resources.
          final analysisContext = contextCollection.contextFor(event.path);
          final key = _AnalysisErrorsKey(
            filePath: event.path,
            analysisContext: analysisContext,
          );

          _analysisErrorsForAnalysisContexts.remove(key);
        default:
          // Ignore unhandled watch event types.
          break;
      }
    }

    return super.handleAnalysisHandleWatchEvents(parameters);
  }

  @override
  Future<void> analyzeFiles({
    required AnalysisContext analysisContext,
    required List<String> paths,
  }) {
    // analyzeFiles reanalyzes all files even if nothing changed by default.
    // We customize the behavior to optimize analysis to be performed only
    // if something changed
    if (paths.isEmpty) return Future.value();

    return super.analyzeFiles(
      analysisContext: analysisContext,
      paths: paths,
    );
  }

  bool _ownsPath(String path) {
    for (final contextRoot
        in _client._contextRootsForPlugin.values.expand((e) => e)) {
      if (isWithin(contextRoot.root.path, path)) {
        final isExcluded = contextRoot.excludedPaths
            .any((excludedPath) => isWithin(excludedPath, path));
        if (!isExcluded) return true;
      }
    }
    return false;
  }

  @override
  Future<void> analyzeFile({
    required AnalysisContext analysisContext,
    required String path,
  }) async {
    if (!analysisContext.contextRoot.isAnalyzed(path)) {
      return;
    }

    /// analyzeFile might be invoked with an analysisContext that's not
    /// part of the enabled context roots. So we separately check that `path`
    /// is something we want to analyze
    if (!_ownsPath(path)) return;

    final configs = _customLintConfigsForAnalysisContexts[analysisContext];
    if (configs == null) return;

    var ignoreForFiles = <IgnoreMetadata>[];
    if (path.endsWith('.dart')) {
      final source = FileSource(resourceProvider.getFile(path));
      if (!source.exists()) return;
      ignoreForFiles = parseIgnoreForFile(source.contents.data);
      // Lints are disabled for the entire file, so no point in executing lints
      if (ignoreForFiles.any((e) => e.disablesAllLints)) return;
    }

    final activeLintRules = configs.rules
        .where(
          (lintRule) => lintRule.filesToAnalyze.any(
            (glob) => Glob(
              glob,
              context: Context(
                style: resourceProvider.pathContext.style,
                // workaround to: https://github.com/dart-lang/glob/issues/72
                current: analysisContext.contextRoot.root.path,
              ),
            ).matches(path),
          ),
        )
        // Removing lints disabled for the file. No need to call LintRule.run
        // if they are going to immediately get ignored
        .where(
          (rule) => !ignoreForFiles.any(
            (ignore) => ignore.isIgnored(rule.code.name),
          ),
        )
        .toList();

    // Even if the list of lints is empty, we keep going for dart files. Because
    // the analyzed file might have some expect-lints comments
    if (activeLintRules.isEmpty && !path.endsWith('.dart')) {
      // The file is guaranteed to have no analysis error. Therefore we
      // abort early to avoid sending a pointless notification
      return;
    }

    final file = resourceProvider.getFile(path);
    final resolver = analysisContext.createResolverForFile(file);
    if (resolver == null) return;

    final lintsBeforeExpectLint = <AnalysisError>[];
    final reporterBeforeExpectLint = ErrorReporter(
      // TODO assert that a LintRule only emits lints with a code matching LintRule.code
      // TODO asserts lintRules can only emit lints in the analyzed file
      _AnalysisErrorListenerDelegate((analysisError) async {
        final ignoreForLine =
            parseIgnoreForLine(analysisError.offset, resolver);

        if (!ignoreForLine.isIgnored(analysisError.errorCode.name)) {
          lintsBeforeExpectLint.add(analysisError);
        }
      }),
      resolver.source,
    );

    // TODO: cancel pending analysis if a new analysis is requested on the same file
    await _runOperation(() async {
      final postRunCallbacks = <void Function()>[];
      // TODO implement verbose mode to log lint duration
      final registry = NodeLintRegistry(LintRegistry(), enableTiming: false);
      final sharedState = <Object, Object?>{};

      await Future.wait([
        for (final lintRule in activeLintRules)
          _startUpLintRule(
            lintRule,
            resolver,
            reporterBeforeExpectLint,
            CustomLintContext(
              LintRuleNodeRegistry(registry, lintRule.code.name),
              postRunCallbacks.add,
              sharedState,
              configs.pubspec,
            ),
          ),
      ]);

      await Future.wait([
        for (final lintRule in activeLintRules)
          _runLintRule(
            lintRule,
            resolver,
            reporterBeforeExpectLint,
            CustomLintContext(
              LintRuleNodeRegistry(registry, lintRule.code.name),
              postRunCallbacks.add,
              sharedState,
              configs.pubspec,
            ),
          ),
      ]);

      runPostRunCallbacks(postRunCallbacks);

      final allAnalysisErrors = <AnalysisError>[];
      final analyzerPluginReporter = ErrorReporter(
        // TODO assert that a LintRule only emits lints with a code matching LintRule.code
        // TODO asserts lintRules can only emit lints in the analyzed file
        _AnalysisErrorListenerDelegate(allAnalysisErrors.add),
        resolver.source,
      );

      ExpectLint(lintsBeforeExpectLint).run(resolver, analyzerPluginReporter);

      if (await _applyFixes(allAnalysisErrors, resolver, configs, path: path)) {
        // Applying fixes re-runs analysis, so lints should've already been sent.
        return;
      }

      final key = _AnalysisErrorsKey(
        filePath: path,
        analysisContext: analysisContext,
      );
      _analysisErrorsForAnalysisContexts[key] = allAnalysisErrors;

      _channel.sendEvent(
        CustomLintEvent.analyzerPluginNotification(
          analyzer_plugin.AnalysisErrorsParams(
            path,
            CustomAnalyzerConverter().convertAnalysisErrors(
              allAnalysisErrors,
              lineInfo: resolver.lineInfo,
              options: analysisContext.getAnalysisOptionsForFile(file),
            ),
          ).toNotification(),
        ),
      );
    });
  }

  Future<bool> _applyFixes(
    List<AnalysisError> allAnalysisErrors,
    CustomLintResolver resolver,
    _CustomLintAnalysisConfigs configs, {
    required String path,
  }) async {
    // The list of already fixed codes, to avoid trying to re-fix a lint
    // that should've been fixed before.
    final fixedCodes =
        (Zone.current[#_fixedCodes] as Set<String>?) ?? <String>{};

    final context = await _fileContext(path);
    if (context == null) return false;

    final allFixes = await _computeFistBatchFixes(
      allAnalysisErrors,
      context,
      fixedCodes,
      path: path,
    );

    if (allFixes.isEmpty) return false;

    final source = resolver.source.contents.data;

    try {
      final editedSource = analyzer_plugin.SourceEdit.applySequence(
        source,
        allFixes
            .expand((e) => e.fixes)
            .expand((e) => e.change.edits)
            .expand((e) => e.edits),
      );

      io.File(path).writeAsStringSync(editedSource);

      // Update in-memory file content before re-running analysis.
      resourceProvider.setOverlay(
        path,
        content: editedSource,
        modificationStamp: DateTime.now().millisecondsSinceEpoch,
      );

      // Re-run analysis to recompute lints
      return runZoned(
        () async {
          await contentChanged([path]);
          return true;
        },
        zoneValues: {
          // We update the list of fixed codes to avoid re-fixing the same lint
          #_fixedCodes: {...fixedCodes, ...allFixes.map((e) => e.error.code)},
        },
      );
    } catch (e) {
      // Something failed. We report the original lints
      io.stderr.writeln('Failed to apply fixes for $path.\n$e');
      return false;
    }
  }

  Future<List<analyzer_plugin.AnalysisErrorFixes>> _computeFistBatchFixes(
    List<AnalysisError> allAnalysisErrors,
    _FileContext context,
    Set<String> fixedCodes, {
    required String path,
  }) async {
    if (!_client.fix) return [];

    final errorToFix = allAnalysisErrors
        .where((e) => !fixedCodes.contains(e.errorCode.name))
        .firstOrNull;
    if (errorToFix == null) return [];

    final fixes = await _computeFixes(
      [errorToFix],
      context,
      allAnalysisErrors,
    );

    return fixes.map((e) => e.batchFixes ?? e.fix).toList();
  }

  /// Queue an operation to be awaited by [_awaitAnalysisDone]
  Future<T> _runOperation<T>(FutureOr<T> Function() cb) async {
    final future = Future(cb);
    _pendingOperations.add(future);

    try {
      return await future;
    } finally {
      _pendingOperations.remove(future);
    }
  }

  Future<void> _awaitAnalysisDone({required bool reload}) async {
    /// First, we wait for the plugin to be initialized. Otherwise there's
    /// obviously no pending operation
    final contextCollection = await _contextCollection.safeFirst;
    if (reload) {
      await afterNewContextCollection(contextCollection: contextCollection);
    }
    while (_pendingOperations.isNotEmpty) {
      await Future.wait([..._pendingOperations]);
    }
  }

  Future<R> _runLintZoned<R>(
    CustomLintResolver resolver,
    FutureOr<R> Function() cb, {
    ErrorReporter? reporter,
    required String name,
  }) {
    void onLog(String message) {
      _channel.sendEvent(
        CustomLintEvent.print(message, pluginName: name),
      );
    }

    void onError(Object error, StackTrace stackTrace) {
      _handleGetLintsError(
        resolver,
        error,
        stackTrace,
        reporter: reporter,
        pluginName: name,
      );
    }

    return asyncRunZonedGuarded(
      zoneSpecification: ZoneSpecification(
        print: (self, parent, zone, line) => onLog(line),
      ),
      cb,
      onError,
    );
  }

  Future<void> _startUpLintRule(
    LintRule lintRule,
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext lintContext,
  ) async {
    await _runLintZoned(
      resolver,
      () => lintRule.startUp(resolver, lintContext),
      reporter: reporter,
      name: lintRule.code.name,
    );
  }

  Future<void> _runLintRule(
    LintRule lintRule,
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext lintContext,
  ) async {
    await _runLintZoned(
      resolver,
      () => lintRule.run(resolver, reporter, lintContext),
      reporter: reporter,
      name: lintRule.code.name,
    );
  }

  /// Re-maps uncaught errors by [LintRule] and, if in the IDE,
  /// shows a synthetic lint at the top of the file corresponding to the error.
  void _handleGetLintsError(
    CustomLintResolver resolver,
    Object error,
    StackTrace stackTrace, {
    ErrorReporter? reporter,
    required String pluginName,
  }) {
    _channel.sendEvent(
      CustomLintEvent.error(
        'Plugin $pluginName threw while analyzing ${resolver.path}:\n$error',
        stackTrace.toString(),
        pluginName: pluginName,
      ),
    );

    if (reporter == null || !_client.includeBuiltInLints) return;

    const code = LintCode(
      name: 'custom_lint_get_lint_fail',
      problemMessage: 'A lint plugin threw an exception',
      errorSeverity: ErrorSeverity.ERROR,
    );

    // TODO add context message that points to the fir line of the stacktrace
    // This involves knowing where a package points to, as a file path is needed

    final startOffset = resolver.lineInfo.lineStarts.firstOrNull ?? 0;
    final endOffset =
        resolver.lineInfo.lineStarts.elementAtOrNull(1) ?? startOffset;

    reporter.atOffset(
      errorCode: code,
      offset: startOffset,
      length: endOffset - startOffset,
    );
  }

  @override
  Future<analyzer_plugin.PluginShutdownResult> handlePluginShutdown(
    analyzer_plugin.PluginShutdownParams parameters,
  ) async {
    await _client._handlePluginShutdown();
    return super.handlePluginShutdown(parameters);
  }
}

class _AnalysisErrorListenerDelegate implements AnalysisErrorListener {
  _AnalysisErrorListenerDelegate(this._onError);

  final void Function(AnalysisError error) _onError;

  @override
  void onError(AnalysisError error) => _onError(error);
}

extension on ChangeReporterBuilder {
  Future<analyzer_plugin.AnalysisErrorFixes> completeAsFixes(
    AnalysisError analysisError,
    _FileContext context,
  ) async {
    return analyzer_plugin.AnalysisErrorFixes(
      CustomAnalyzerConverter().convertAnalysisError(
        analysisError,
        lineInfo: context.resolver.lineInfo,
        severity: analysisError.errorCode.errorSeverity,
      ),
      fixes: await complete(),
    );
  }
}
