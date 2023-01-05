import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context.dart';
import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:analyzer/source/line_info.dart';
import 'package:analyzer_plugin/plugin/plugin.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';
import 'package:analyzer_plugin/starter.dart';
import 'package:collection/collection.dart';
// ignore: implementation_imports
import 'package:custom_lint/src/v2/protocol.dart';
import 'package:hotreloader/hotreloader.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart';
import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:rxdart/subjects.dart';

import '../../custom_lint_builder.dart';
import 'channel.dart';

Future<bool> _isVmServiceEnabled() async {
  final serviceInfo = await dev.Service.getInfo();
  return serviceInfo.serverUri != null;
}

class CustomLintPluginClient {
  CustomLintPluginClient(this._channel, {required this.watchMode}) {
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

  final bool watchMode;
  late final StreamSubscription<void> _channelInputSub;
  late final Future<HotReloader?> _hotReloader;
  final CustomLintClientChannel _channel;
  late final _ClientAnalyzerPlugin _analyzerPlugin;

  var _contextRootsForPlugin = <String, List<ContextRoot>>{};

  Future<HotReloader?> _maybeStartHotLoad() async {
    if (!await _isVmServiceEnabled()) return null;
    return HotReloader.create(
      onAfterReload: (_) {
        _analyzerPlugin.reAnalyze();
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
      final pubspecFile = File(join(contextRoot.root, 'pubspec.yaml'));
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

  void handleError(Object error, StackTrace stackTrace) {
    _channel.sendEvent(
      CustomLintEvent.error(
        error.toString(),
        stackTrace.toString(),
        pluginName: null,
      ),
    );
  }

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

  @override
  List<String> get fileGlobsToAnalyze => ['*.dart'];

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
      return super.afterNewContextCollection(
        contextCollection: contextCollection,
      );
    });
  }

  @override
  Future<void> analyzeFile({
    required AnalysisContext analysisContext,
    required String path,
  }) async {
    if (!path.endsWith('.dart') ||
        !analysisContext.contextRoot.isAnalyzed(path)) {
      return;
    }

    await _runOperation(() async {
      final unit = await getResolvedUnitResult(path);

      final fileIgnoredCodes = _getAllIgnoredForFileCodes(unit.content);
      // Lints are disabled for the entire file, so no point to even execute `getLints`
      if (fileIgnoredCodes.contains('type=lint')) return;

      // TODO: cancel getLints if analyzeFile is reinvoked for path while
      // the previous Stream is still pending.
      final lints = await Future.wait([
        for (final plugin in _channel.registeredPlugins.entries)
          if (_client._isPluginActiveForContextRoot(analysisContext,
              pluginName: plugin.key))
            _getLintsForPlugin(plugin.value, unit, pluginName: plugin.key),
      ]);

      _channel.sendEvent(
        CustomLintEvent.analyzerPluginNotification(
          AnalysisErrorsParams(
            path,
            lints.flattened
                // Applying ignore_for_file
                .where((lint) => !fileIgnoredCodes.contains(lint.code))
                .where((lint) => !_isIgnored(lint, unit))
                // Applying `// expect_lint` after ignores, such that if a lint
                // is ignored, expect_lint will fail
                ._applyExpectLint(unit)
                .map((e) => e.asAnalysisError())
                .toList(),
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

  /// Execute [PluginBase.getLints], catching errors and redirecting logs.
  Future<List<Lint>> _getLintsForPlugin(
    PluginBase plugin,
    ResolvedUnitResult unit, {
    required String pluginName,
  }) async {
    final _errorLints = <Lint>[];
    void pluginError(Object error, StackTrace stackTrace) {
      final errorLint = _handleGetLintsError(
        unit,
        error,
        stackTrace,
        pluginName: pluginName,
        path: unit.path,
      );
      _errorLints.add(errorLint);
    }

    void pluginLog(String message) {
      _channel.sendEvent(
        CustomLintEvent.print(message, pluginName: pluginName),
      );
    }

    return await runZoned(
      zoneSpecification: ZoneSpecification(
        print: (self, parent, zone, line) => pluginLog(line),
      ),
      () async {
        final result =
            await plugin.getLints(unit).handleError(pluginError).toList();

        return [
          ..._errorLints,
          ...result,
        ];
      },
    );
  }

  /// Re-maps uncaught errors by [PluginBase.getLints] and, if in the IDE,
  /// shows a synthetic lint at the top of the file corresponding to the error.
  Lint _handleGetLintsError(
    ResolvedUnitResult analysisResult,
    Object error,
    StackTrace stackTrace, {
    required String path,
    required String pluginName,
  }) {
    _channel.sendEvent(
      CustomLintEvent.error(
        'Plugin $pluginName threw while analyzing $path:\n$error',
        stackTrace.toString(),
        pluginName: pluginName,
      ),
    );

    // TODO add context message that points to the fir line of the stacktrace
    // This involves knowing where a package points to, as a file path is needed

    return Lint(
      severity: LintSeverity.error,
      location: analysisResult.lintLocationFromLines(startLine: 1, endLine: 1),
      message: 'A lint plugin threw an exception',
      code: 'custom_lint_get_lint_fail',
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

extension on Iterable<Lint> {
  /// Applies `// expect_lint` specifically
  List<Lint> _applyExpectLint(ResolvedUnitResult analysisResult) {
    final expectLints = _getAllExpectedLints(
      analysisResult.content,
      analysisResult.lineInfo,
      filePath: analysisResult.path,
    );

    final allExpectedLints = expectLints
        .map((e) => _ComparableExpectLintMeta(e.line, e.code))
        .toSet();

    // The list of all the expect_lints codes that don't have a matching lint.
    final unfulfilledExpectedLints = expectLints.toList();

    final lintsExcludingExpectedLints = where((lint) {
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

    return [
      ...lintsExcludingExpectedLints,
      for (final unfulfilledExpectedLint in unfulfilledExpectedLints)
        Lint(
          severity: LintSeverity.error,
          message:
              'Expected to find the lint ${unfulfilledExpectedLint.code} on next line but none found.',
          code: 'unfulfilled_expect_lint',
          correction:
              'Either update the code such that it emits the lint ${unfulfilledExpectedLint.code} '
              'or update the expect_lint clause to not include the code ${unfulfilledExpectedLint.code}.',
          location: unfulfilledExpectedLint.location,
        )
    ];
  }
}

/// Information about an `// expect_lint: code` clause
@immutable
class _ExpectLintMeta {
  /// Information about an `// expect_lint: code` clause
  const _ExpectLintMeta({
    required this.line,
    required this.code,
    required this.location,
  }) : assert(line >= 0, 'line must be positive');

  /// A 0-based offset of the line having the expect_lint clause.
  final int line;

  /// The code expected.
  final String code;

  /// The location of the expected code.
  final LintLocation location;
}

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

final _ignoreRegex = RegExp(r'//\s*ignore\s*:(.+)$', multiLine: true);

bool _isIgnored(Lint lint, ResolvedUnitResult unit) {
  // -1 because lines starts at 1 not 0
  final line = lint.location.startLine - 1;

  if (line == 0) return false;

  final previousLine = unit.content.substring(
    unit.lineInfo.getOffsetOfLine(line - 1),
    lint.location.offset - 1,
  );

  final codeContent = _ignoreRegex.firstMatch(previousLine)?.group(1);
  if (codeContent == null) return false;

  final codes = codeContent.split(',').map((e) => e.trim()).toSet();

  return codes.contains(lint.code) || codes.contains('type=lint');
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

final _expectLintRegex = RegExp(r'//\s*expect_lint\s*:(.+)$', multiLine: true);

List<_ExpectLintMeta> _getAllExpectedLints(
  String source,
  LineInfo lineInfo, {
  required String filePath,
}) {
  final expectLints = _expectLintRegex.allMatches(source);

  return expectLints.expand((expectLint) {
    final lineNumber = lineInfo.getLocation(expectLint.start).lineNumber - 1;
    final codesStartOffset = source.indexOf(':', expectLint.start) + 1;

    final codes = expectLint.group(1)!.split(',');
    var codeOffsetAcc = codesStartOffset;

    return codes.map((rawCode) {
      final codeOffset =
          codeOffsetAcc + (rawCode.length - rawCode.trimLeft().length);
      codeOffsetAcc += rawCode.length + 1;

      final code = rawCode.trim();
      final start = lineInfo.getLocation(codeOffset);
      final end = lineInfo.getLocation(codeOffset + code.length);

      return _ExpectLintMeta(
        line: lineNumber,
        code: code,
        location: LintLocation(
          filePath: filePath,
          offset: codeOffset,
          startLine: start.lineNumber,
          startColumn: start.columnNumber,
          endLine: end.lineNumber,
          endColumn: end.columnNumber,
          length: code.length,
        ),
      );
    });
  }).toList();
}
