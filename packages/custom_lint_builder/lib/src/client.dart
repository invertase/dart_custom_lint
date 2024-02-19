// ignore_for_file: invalid_use_of_internal_member

import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io' as io;

import 'package:analyzer/dart/analysis/analysis_context.dart';
import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/context_root.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/session.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:analyzer/source/line_info.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/plugin/plugin.dart' as analyzer_plugin;
import 'package:analyzer_plugin/protocol/protocol_common.dart'
    as analyzer_plugin;
import 'package:analyzer_plugin/protocol/protocol_generated.dart'
    as analyzer_plugin;
import 'package:analyzer_plugin/starter.dart' as analyzer_plugin;
import 'package:collection/collection.dart';
// ignore: implementation_imports
import 'package:custom_lint/src/async_operation.dart';
// ignore: implementation_imports
import 'package:custom_lint/src/package_utils.dart';
// ignore: implementation_imports
import 'package:custom_lint/src/v2/protocol.dart';
// ignore: implementation_imports
import 'package:custom_lint_core/src/change_reporter.dart';
// ignore: implementation_imports
import 'package:custom_lint_core/src/node_lint_visitor.dart';
// ignore: implementation_imports
import 'package:custom_lint_core/src/plugin_base.dart';
// ignore: implementation_imports
import 'package:custom_lint_core/src/resolver.dart';
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
    final source = file.createSource();
    final lineInfo = LineInfo.fromContent(source.contents.data);

    return CustomLintResolverImpl(
      () => safeGetResolvedUnitResult(file.path),
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
  bool canBatchFix(String filePath) {
    final fixesExcludingIgnores =
        fixes.where((change) => !change.isIgnoreChange).toList();

    return fixesExcludingIgnores.length == 1 &&
        fixesExcludingIgnores.single.canBatchFix(filePath);
  }
}

extension on analyzer_plugin.PrioritizedSourceChange {
  bool canBatchFix(String filePath) {
    return change.edits.every((element) => element.file == filePath);
  }

  bool get isIgnoreChange {
    return change.id == IgnoreCode.ignoreForFileCode ||
        change.id == IgnoreCode.ignoreForLineCode;
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
    _hotReloader = _maybeStartHotLoad();
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
            break;
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
      final response = await request.map<FutureOr<CustomLintResponse?>>(
        // Analyzer_plugin requests are handles by the _analyzer_plugin client
        analyzerPluginRequest: (_) => null,
        ping: (param) => CustomLintResponse.pong(id: request.id),
        awaitAnalysisDone: (param) async {
          await _analyzerPlugin._awaitAnalysisDone(reload: param.reload);
          return CustomLintResponse.awaitAnalysisDone(id: request.id);
        },
      );

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
      <_AnalysisErrorsKey, Iterable<AnalysisError>>{};

  @override
  List<String> get fileGlobsToAnalyze => ['*'];

  @override
  String get name => 'custom_lint_client';

  @override
  String get version => '1.0.0-alpha.0';

  void reAnalyze() {
    final contextCollection = _contextCollection.valueOrNull;
    if (contextCollection != null) {
      afterNewContextCollection(contextCollection: contextCollection);
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
      await changeReporter.waitForCompletion(),
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
    final contextCollection = await _contextCollection.safeFirst;
    final analysisContext = contextCollection.contextFor(parameters.file);
    final resolver = analysisContext.createResolverForFile(
      resourceProvider.getFile(parameters.file),
    );
    if (resolver == null) return analyzer_plugin.EditGetFixesResult([]);

    final key = _AnalysisErrorsKey(
      filePath: parameters.file,
      analysisContext: analysisContext,
    );
    final configs = _customLintConfigsForAnalysisContexts[analysisContext];

    final analysisErrorsForContext =
        _analysisErrorsForAnalysisContexts[key] ?? const {};
    final errorsAtOffset = analysisErrorsForContext
        .where(
          (error) =>
              parameters.offset >= error.offset &&
              parameters.offset <= error.offset + error.length,
        )
        .toList();

    if (errorsAtOffset.isEmpty || configs == null) {
      return analyzer_plugin.EditGetFixesResult([]);
    }

    final allAnalysisErrorFixes = await Future.wait([
      for (final error in analysisErrorsForContext)
        _handlesFixesForError(
          error,
          analysisErrorsForContext,
          configs,
          resolver,
          parameters,
        ),
    ]);

    final analysisErrorFixesForOffset = allAnalysisErrorFixes
        .whereNotNull()
        .where(
          (fix) =>
              parameters.offset >= fix.error.location.offset &&
              parameters.offset <=
                  fix.error.location.offset + fix.error.location.length,
        )
        .toList();

    final fixAll = <String, analyzer_plugin.AnalysisErrorFixes?>{};
    for (final fix in allAnalysisErrorFixes) {
      if (fix == null) continue;

      final errorCode = fix.error.code;
      fixAll.putIfAbsent(errorCode, () {
        final analysisErrorsWithCode = allAnalysisErrorFixes
            .whereNotNull()
            .where((fix) => fix.error.code == errorCode)
            .toList();

        // Don't show "fix-all" unless at least two errors have the same code.
        if (analysisErrorsWithCode.length < 2) return null;

        final fixesWithCode = analysisErrorsWithCode
            .where((e) => e.canBatchFix(parameters.file))
            // Ignoring "ignore" fixes
            .map((e) {
          final fixesExcludingIgnores =
              e.fixes.where((change) => !change.isIgnoreChange).toList();

          return (fixes: fixesExcludingIgnores, error: e.error);
        }).sorted(
          (a, b) => b.error.location.offset - a.error.location.offset,
        );

        // Don't show fix-all if there's no good fix.
        if (fixesWithCode.isEmpty) return null;

        final priority = fixesWithCode
                .expand((e) => e.fixes)
                .map((e) => e.priority - 1)
                .firstOrNull ??
            0;

        return analyzer_plugin.AnalysisErrorFixes(
          fix.error,
          fixes: [
            analyzer_plugin.PrioritizedSourceChange(
              priority,
              analyzer_plugin.SourceChange(
                'Fix all "$errorCode"',
                edits: fixesWithCode
                    .expand((e) => e.fixes)
                    .expand((e) => e.change.edits)
                    .toList(),
              ),
            ),
          ],
        );
      });
    }

    return analyzer_plugin.EditGetFixesResult([
      ...analysisErrorFixesForOffset,
      ...fixAll.values.whereNotNull(),
    ]);
  }

  Future<analyzer_plugin.AnalysisErrorFixes?> _handlesFixesForError(
    AnalysisError analysisError,
    Iterable<AnalysisError> allErrors,
    _CustomLintAnalysisConfigs configs,
    CustomLintResolver resolver,
    analyzer_plugin.EditGetFixesParams parameters,
  ) async {
    final fixesForError = configs.fixes[analysisError.errorCode];
    if (fixesForError == null || fixesForError.isEmpty) {
      return null;
    }

    final otherErrors = allErrors
        .where(
          (element) =>
              element != analysisError &&
              element.errorCode == analysisError.errorCode,
        )
        .toList();

    final postRunCallbacks = <void Function()>[];
    // TODO implement verbose mode to log lint duration
    final registry = NodeLintRegistry(LintRegistry(), enableTiming: false);
    final sharedState = <Object, Object?>{};

    final changeReporter = ChangeReporterImpl(
      configs.analysisContext.currentSession,
      resolver,
    );

    await Future.wait([
      for (final fix in fixesForError)
        _runFixStartup(
          resolver,
          fix,
          CustomLintContext(
            LintRuleNodeRegistry(registry, fix.runtimeType.toString()),
            postRunCallbacks.add,
            sharedState,
            configs.pubspec,
          ),
        ),
    ]);
    await Future.wait([
      for (final fix in fixesForError)
        _runFixRun(
          resolver,
          fix,
          CustomLintContext(
            LintRuleNodeRegistry(registry, fix.runtimeType.toString()),
            postRunCallbacks.add,
            sharedState,
            configs.pubspec,
          ),
          changeReporter,
          analysisError,
          otherErrors,
        ),
    ]);

    runPostRunCallbacks(postRunCallbacks);

    return analyzer_plugin.AnalysisErrorFixes(
      CustomAnalyzerConverter().convertAnalysisError(
        analysisError,
        lineInfo: resolver.lineInfo,
        severity: analysisError.errorCode.errorSeverity,
      ),
      fixes: await changeReporter.waitForCompletion(),
    );
  }

  Future<void> _runFixStartup(
    CustomLintResolver resolver,
    Fix fix,
    CustomLintContext context,
  ) async {
    return _runLintZoned(
      resolver,
      () => fix.startUp(resolver, context),
      name: fix.runtimeType.toString(),
    );
  }

  Future<void> _runFixRun(
    CustomLintResolver resolver,
    Fix fix,
    CustomLintContext context,
    ChangeReporter changeReporter,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) async {
    return _runLintZoned(
      resolver,
      () => fix.run(resolver, changeReporter, context, analysisError, others),
      name: fix.runtimeType.toString(),
    );
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
          break;
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
      final source = resourceProvider.getFile(path).createSource();
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
      isNonNullableByDefault: false,
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
        isNonNullableByDefault: false,
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

    final allFixes = await _computeFixes(
      allAnalysisErrors,
      resolver,
      configs,
      fixedCodes,
      path: path,
    ).toList();

    if (allFixes.isEmpty) return false;

    final source = resolver.source.contents.data;
    final firstFixCode = allFixes.first.analysisError.errorCode;
    final didApplyAllFixes =
        allFixes.every((e) => e.analysisError.errorCode == firstFixCode);

    try {
      // Apply fixes from top to bottom.
      allFixes.sort(
        (a, b) => b.analysisError.offset - a.analysisError.offset,
      );

      final editedSource = analyzer_plugin.SourceEdit.applySequence(
        source,
        // We apply fixes only once at a time, to avoid conflicts.
        // To do so, we take the first fixed lint code, and apply fixes
        // only for that code.
        allFixes
            .where((e) => e.analysisError.errorCode == firstFixCode)
            .expand((e) => e.edits),
      );

      if (didApplyAllFixes) {
        // Apply fixes to the file
        io.File(path).writeAsStringSync(editedSource);
      }

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
          #_fixedCodes: {...fixedCodes, firstFixCode.name},
        },
      );
    } catch (e) {
      // Something failed. We report the original lints
      io.stderr.writeln('Failed to apply fixes for $path.\n$e');
      return false;
    }
  }

  Stream<
      ({
        AnalysisError analysisError,
        Iterable<analyzer_plugin.SourceEdit> edits,
      })> _computeFixes(
    List<AnalysisError> allAnalysisErrors,
    CustomLintResolver resolver,
    _CustomLintAnalysisConfigs configs,
    Set<String> fixedCodes, {
    required String path,
  }) async* {
    if (!_client.fix) return;

    for (final analysisError in allAnalysisErrors) {
      if (fixedCodes.contains(analysisError.errorCode.name)) continue;

      final fixesForLint = await _handlesFixesForError(
        analysisError,
        allAnalysisErrors.toSet(),
        configs,
        resolver,
        analyzer_plugin.EditGetFixesParams(path, analysisError.offset),
      );

      if (fixesForLint == null || !fixesForLint.canBatchFix(resolver.path)) {
        continue;
      }

      yield (
        analysisError: analysisError,
        edits: fixesForLint.fixes.single.change.edits.expand((e) => e.edits),
      );
    }
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

    reporter.reportErrorForOffset(
      code,
      startOffset,
      endOffset - startOffset,
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
