import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io' as io;

import 'package:analyzer/dart/analysis/analysis_context.dart';
import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/session.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:analyzer/source/line_info.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/plugin/plugin.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';
import 'package:analyzer_plugin/starter.dart';
import 'package:analyzer_plugin/utilities/analyzer_converter.dart';
import 'package:collection/collection.dart';
// ignore: implementation_imports
import 'package:custom_lint/src/v2/protocol.dart';
import 'package:glob/glob.dart';
import 'package:hotreloader/hotreloader.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart';
import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:rxdart/subjects.dart';

import 'assist.dart';
import 'change_reporter.dart';
import 'channel.dart';
import 'configs.dart';
import 'expect_lint.dart';
import 'fixes.dart';
import 'lint_codes.dart';
import 'lint_rule.dart';
import 'node_lint_visitor.dart';
import 'plugin_base.dart';
import 'resolver.dart';

/// Runs a list of "postRun" callbacks.
///
/// Errors are caught to ensure all callbacks are executed.
@internal
void runPostRunCallbacks(List<void Function()> postRunCallbacks) {
  for (final postCallback in postRunCallbacks) {
    try {
      postCallback();
    } catch (err) {
      // TODO should errors be reported?
      // All postCallbacks should execute even if one throw
    }
  }
}

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

/// The custom_lint client
class CustomLintPluginClient {
  /// The custom_lint client
  CustomLintPluginClient(
    this._channel, {
    required this.watchMode,
    required this.includeBuiltInLints,
  }) {
    _analyzerPlugin = _ClientAnalyzerPlugin(
      _channel,
      this,
      resourceProvider: PhysicalResourceProvider.INSTANCE,
    );
    _hotReloader = watchMode ? _maybeStartHotLoad() : Future.value();
    final starter = ServerPluginStarter(_analyzerPlugin);
    starter.start(_channel.sendPort);

    _channelInputSub = _channel.input.listen(_handleCustomLintRequest);
  }

  /// Whether the client should perform a hot-reload when the source of plugins changes.
  final bool watchMode;

  /// Whether
  final bool includeBuiltInLints;
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
          analysisContext.contextRoot.root.path == contextRootForPlugin.root,
    );
  }

  Future<void> _handleCustomLintRequest(CustomLintRequest request) async {
    try {
      final response = await request.map<FutureOr<CustomLintResponse?>>(
        // Analayzer_plugin requests are handles by the _analyzer_plugin client
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

  Future<void> _handleSetContextRoots(
    AnalysisSetContextRootsParams params,
  ) async {
    _contextRootsForPlugin = {};

    for (final contextRoot in params.roots) {
      final pubspecFile = io.File(join(contextRoot.root, 'pubspec.yaml'));
      if (!pubspecFile.existsSync()) {
        continue;
      }

      final pubspec = Pubspec.parse(
        pubspecFile.readAsStringSync(),
        sourceUrl: pubspecFile.uri,
      );

      for (final pluginName in _channel.registeredPlugins.keys) {
        final isPluginEnabledInContext =
            pubspec.dependencies.containsKey(pluginName) ||
                pubspec.devDependencies.containsKey(pluginName) ||
                pubspec.dependencyOverrides.containsKey(pluginName);

        if (isPluginEnabledInContext) {
          final contextRootsForPlugin =
              _contextRootsForPlugin[pluginName] ??= [];
          contextRootsForPlugin.add(contextRoot);
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

  Future<void> _handlePlugingShutdown() async {
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
  );

  factory _CustomLintAnalysisConfigs.from(
    AnalysisContext analysisContext,
    CustomLintPluginClient client,
  ) {
    final configs =
        CustomLintConfigs.parse(analysisContext.contextRoot.optionsFile);

    final activePluginsForContext = Map.fromEntries(
      client._channel.registeredPlugins.entries.where(
        (plugin) => client._isPluginActiveForContextRoot(
          analysisContext,
          pluginName: plugin.key,
        ),
      ),
    );

    final rules = _lintRulesForContext(activePluginsForContext, configs);
    final fixes = _fixesForRules(rules);
    final assists =
        _assistsForContext(activePluginsForContext, configs, client);

    return _CustomLintAnalysisConfigs(
      configs,
      rules,
      fixes,
      assists,
      analysisContext,
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

  static Map<LintCode, List<Fix>> _fixesForRules(List<LintRule> rules) {
    return {
      for (final rule in rules) rule.code: rule.getFixes(),
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

class _ClientAnalyzerPlugin extends ServerPlugin {
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
      <_AnalysisErrorsKey, Set<AnalysisError>>{};

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
  Future<AnalysisSetContextRootsResult> handleAnalysisSetContextRoots(
    AnalysisSetContextRootsParams params,
  ) {
    return _runOperation(() async {
      await _client._handleSetContextRoots(params);
      return super.handleAnalysisSetContextRoots(params);
    });
  }

  @override
  Future<void> afterNewContextCollection({
    required AnalysisContextCollection contextCollection,
  }) {
    _contextCollection.add(contextCollection);
    return _runOperation(() {
      // Clear lints as we got a new context collection
      _analysisErrorsForAnalysisContexts.removeWhere(
        (key, value) =>
            contextCollection.contexts.contains(key.analysisContext),
      );
      _customLintConfigsForAnalysisContexts = {
        for (final analysisContext in contextCollection.contexts)
          analysisContext:
              _CustomLintAnalysisConfigs.from(analysisContext, _client),
      };

      return super.afterNewContextCollection(
        contextCollection: contextCollection,
      );
    });
  }

  @override
  Future<EditGetAssistsResult> handleEditGetAssists(
    EditGetAssistsParams parameters,
  ) async {
    // TODO test
    final contextCollection = await _contextCollection.first;
    final analysisContext = contextCollection.contextFor(parameters.file);
    final assists =
        _customLintConfigsForAnalysisContexts[analysisContext]?.assists;

    final resolver = analysisContext.createResolverForFile(
      resourceProvider.getFile(parameters.file),
    );
    if (resolver == null || assists == null || assists.isEmpty) {
      return EditGetAssistsResult([]);
    }

    final configs = _customLintConfigsForAnalysisContexts[analysisContext];
    if (configs == null) {
      return EditGetAssistsResult([]);
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
          ),
          target,
        ),
    ]);
    for (final assist in configs.assists) {
      _runAssistRun(
        resolver,
        assist,
        CustomLintContext(
          LintRuleNodeRegistry(registry, assist.runtimeType.toString()),
          postRunCallbacks.add,
          sharedState,
        ),
        changeReporter,
        target,
      );
    }

    runPostRunCallbacks(postRunCallbacks);

    return EditGetAssistsResult(await changeReporter.waitForCompletion());
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

  void _runAssistRun(
    CustomLintResolver resolver,
    Assist assist,
    CustomLintContext context,
    ChangeReporter changeReporter,
    SourceRange target,
  ) {
    return _runLintZoned(
      resolver,
      () => assist.run(resolver, changeReporter, context, target),
      name: assist.runtimeType.toString(),
    );
  }

  @override
  Future<EditGetFixesResult> handleEditGetFixes(
    EditGetFixesParams parameters,
  ) async {
    // TODO test
    final contextCollection = await _contextCollection.first;
    final analysisContext = contextCollection.contextFor(parameters.file);
    final resolver = analysisContext.createResolverForFile(
      resourceProvider.getFile(parameters.file),
    );
    if (resolver == null) return EditGetFixesResult([]);

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
              parameters.offset < error.offset + error.length,
        )
        .toList();

    if (errorsAtOffset.isEmpty || configs == null) {
      return EditGetFixesResult([]);
    }

    final analysisErrorFixes = await Future.wait([
      for (final error in errorsAtOffset)
        _handlesFixesForError(
          error,
          analysisErrorsForContext,
          configs,
          resolver,
          parameters,
        ),
    ]);

    return EditGetFixesResult(analysisErrorFixes.whereNotNull().toList());
  }

  Future<AnalysisErrorFixes?> _handlesFixesForError(
    AnalysisError analysisError,
    Set<AnalysisError> allErrors,
    _CustomLintAnalysisConfigs configs,
    CustomLintResolver resolver,
    EditGetFixesParams parameters,
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
          ),
        ),
    ]);
    for (final fix in fixesForError) {
      _runFixRun(
        resolver,
        fix,
        CustomLintContext(
          LintRuleNodeRegistry(registry, fix.runtimeType.toString()),
          postRunCallbacks.add,
          sharedState,
        ),
        changeReporter,
        analysisError,
        otherErrors,
      );
    }

    runPostRunCallbacks(postRunCallbacks);

    return AnalysisErrorFixes(
      AnalyzerConverter().convertAnalysisError(
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

  void _runFixRun(
    CustomLintResolver resolver,
    Fix fix,
    CustomLintContext context,
    ChangeReporter changeReporter,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    return _runLintZoned(
      resolver,
      () => fix.run(resolver, changeReporter, context, analysisError, others),
      name: fix.runtimeType.toString(),
    );
  }

  @override
  Future<AnalysisHandleWatchEventsResult> handleAnalysisHandleWatchEvents(
    AnalysisHandleWatchEventsParams parameters,
  ) async {
    final contextCollection = await _contextCollection.first;

    for (final event in parameters.events) {
      switch (event.type) {
        case WatchEventType.REMOVE:

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
    // analyzeFiles reanalizes all files even if nothing changed by default.
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
      if (isWithin(contextRoot.root, path)) {
        final isExcluded = contextRoot.exclude
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
    /// is something we want to analize
    if (!_ownsPath(path)) return;

    final configs = _customLintConfigsForAnalysisContexts[analysisContext];
    if (configs == null) return;

    var fileIgnoredCodes = <String>{};
    if (path.endsWith('.dart')) {
      final source = resourceProvider.getFile(path).createSource();
      fileIgnoredCodes = _getAllIgnoredForFileCodes(source.contents.data);
      // Lints are disabled for the entire file, so no point in executing lints
      if (fileIgnoredCodes.contains('type=lint')) return;
    }

    final fileName = basename(path);
    final activeLintRules = configs.rules
        .where(
          (lintRule) => lintRule.filesToAnalyze
              .any((glob) => Glob(glob).matches(fileName)),
        )
        // Removing lints disabled for the file. No need to call LintRule.run
        // if they are going to immediately get ignored
        .where((e) => !fileIgnoredCodes.contains(e.code.name))
        .toList();

    // Even if the list of lints is empty, we keep going for dart files. Because
    // the analyzed file might have some expect-lints comments
    if (activeLintRules.isEmpty && !path.endsWith('.dart')) {
      // The file is guaranteed to have no analysis error. Therefore we
      // abort early to avoid sending a pointless notification
      return;
    }

    final resolver =
        analysisContext.createResolverForFile(resourceProvider.getFile(path));
    if (resolver == null) return;

    final lints = <AnalysisError>[];
    final reporterBeforeExpectLint = ErrorReporter(
      // TODO assert that a LintRule only emits lints with a code matching LintRule.code
      // TODO asserts lintRules can only emit lints in the analyzed file
      _AnalysisErrorListenerDelegate((lint) {
        if (!_isIgnored(lint, resolver)) {
          lints.add(lint);
        }
      }),
      resolver.source,
      isNonNullableByDefault: false,
    );

    // TODO: cancel getLints if analyzeFile is reinvoked for path while
    // the previous Stream is still pending.
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
            ),
          ),
      ]);
      for (final lintRule in activeLintRules) {
        _runLintRule(
          lintRule,
          resolver,
          reporterBeforeExpectLint,
          CustomLintContext(
            LintRuleNodeRegistry(registry, lintRule.code.name),
            postRunCallbacks.add,
            sharedState,
          ),
        );
      }

      runPostRunCallbacks(postRunCallbacks);

      final allAnalysisErrors = <AnalysisError>[];
      final analyzerPluginReporter = ErrorReporter(
        // TODO assert that a LintRule only emits lints with a code matching LintRule.code
        // TODO asserts lintRules can only emit lints in the analyzed file
        _AnalysisErrorListenerDelegate(allAnalysisErrors.add),
        resolver.source,
        isNonNullableByDefault: false,
      );

      ExpectLint(lints).run(resolver, analyzerPluginReporter);

      final key =
          _AnalysisErrorsKey(filePath: path, analysisContext: analysisContext);
      _analysisErrorsForAnalysisContexts[key] = {
        // Combining lints before/after applying expect_error
        // This is to enable fixes to access both
        ...allAnalysisErrors,
        ...lints,
      };

      _channel.sendEvent(
        CustomLintEvent.analyzerPluginNotification(
          AnalysisErrorsParams(
            path,
            AnalyzerConverter().convertAnalysisErrors(
              allAnalysisErrors,
              lineInfo: resolver.lineInfo,
              options: analysisContext.analysisOptions,
            ),
          ).toNotification(),
        ),
      );
    });
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
    final contextCollection = await _contextCollection.first;
    if (reload) {
      await afterNewContextCollection(contextCollection: contextCollection);
    }
    while (_pendingOperations.isNotEmpty) {
      await Future.wait([..._pendingOperations]);
    }
  }

  R? _runLintZoned<R>(
    CustomLintResolver resolver,
    R Function() cb, {
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

    return runZonedGuarded(
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

  void _runLintRule(
    LintRule lintRule,
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext lintContext,
  ) {
    _runLintZoned(
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
  Future<PluginShutdownResult> handlePluginShutdown(
    PluginShutdownParams parameters,
  ) async {
    await _client._handlePlugingShutdown();
    return super.handlePluginShutdown(parameters);
  }
}

class _AnalysisErrorListenerDelegate implements AnalysisErrorListener {
  _AnalysisErrorListenerDelegate(this._onError);

  final void Function(AnalysisError error) _onError;

  @override
  void onError(AnalysisError error) => _onError(error);
}

final _ignoreRegex = RegExp(r'//\s*ignore\s*:(.+)$', multiLine: true);

bool _isIgnored(AnalysisError lint, CustomLintResolver resolver) {
  final line = resolver.lineInfo.getLocation(lint.offset).lineNumber - 1;

  if (line <= 0) return false;

  final previousLine = resolver.source.contents.data.substring(
    resolver.lineInfo.getOffsetOfLine(line - 1),
    lint.offset - 1,
  );

  final codeContent = _ignoreRegex.firstMatch(previousLine)?.group(1);
  if (codeContent == null) return false;

  final codes = codeContent.split(',').map((e) => e.trim()).toSet();

  return codes.contains(lint.errorCode.name) || codes.contains('type=lint');
}

final _ignoreForFileRegex =
    RegExp(r'//\s*ignore_for_file\s*:(.+)$', multiLine: true);

Set<String> _getAllIgnoredForFileCodes(String source) {
  return _ignoreForFileRegex
      .allMatches(source)
      .map((e) => e.group(1)!)
      .expand((e) => e.split(','))
      .map((e) => e.trim())
      .toSet();
}
