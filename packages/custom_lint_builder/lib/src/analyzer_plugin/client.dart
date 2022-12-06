import 'dart:async';
import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context.dart';
import 'package:analyzer/dart/analysis/results.dart' as analyzer;
import 'package:analyzer/file_system/file_system.dart' as analyzer;
import 'package:analyzer/file_system/physical_file_system.dart' as analyzer;
import 'package:analyzer/source/line_info.dart';
// ignore: implementation_imports
import 'package:analyzer_plugin/protocol/protocol.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart'
    as analyzer_plugin;
import 'package:analyzer_plugin/protocol/protocol_generated.dart'
    as analyzer_plugin;
// ignore: implementation_imports
import 'package:analyzer_plugin/src/protocol/protocol_internal.dart';
import 'package:collection/collection.dart';
import 'package:hotreloader/hotreloader.dart';
import 'package:source_span/source_span.dart';
import 'package:stack_trace/stack_trace.dart';

import '../../custom_lint_builder.dart';
import '../internal_protocol.dart';
import 'plugin_client.dart';

/// An exception thrown during [PluginBase.getLints].
class GetLintException implements Exception {
  /// An exception thrown during [PluginBase.getLints].
  GetLintException({required this.error, required this.filePath});

  /// The thrown exception by [PluginBase.getLints].
  final Object error;

  /// The while that was being analyzed
  final String filePath;

  @override
  String toString() {
    return 'The following exception was thrown while trying to obtain lints for $filePath:\n'
        '$error';
  }
}

/// An internal client for connecting a custom_lint plugin to the server
/// using the analyzer_plugin protocol
class Client extends ServerPlugin {
  /// An internal client for connecting a custom_lint plugin to the server
  /// using the analyzer_plugin protocol
  Client(this.plugin, [analyzer.ResourceProvider? provider])
      : super(
          resourceProvider:
              provider ?? analyzer.PhysicalResourceProvider.INSTANCE,
        );

  Future<HotReloader>? _hotReloader;

  /// The plugin that will be connected to the analyzer server
  final PluginBase plugin;

  late bool _includeBuiltInLints;

  @override
  List<String> get fileGlobsToAnalyze => ['*.dart'];

  @override
  String get name => 'custom_lint_client';

  @override
  String get version => '1.0.0-alpha.0';

  final List<Future<void>> _pendingAnalyzeFilesFutures = [];

  final _pendingGetLintsSubscriptions = <String, StreamSubscription>{};

  /// Calls [PluginBase.getLints], applies `// ignore` & error handling,
  /// and encode them.
  ///
  /// Using `async*` such that we can "cancel" the subscription to [PluginBase.getLints]
  Stream<CustomAnalysisNotification> _getAnalysisErrors(
    analyzer.ResolvedUnitResult analysisResult,
  ) {
    final lineInfo = analysisResult.lineInfo;
    final source = analysisResult.content;
    final fileIgnoredCodes = _getAllIgnoredForFileCodes(analysisResult.content);
    final expectLints = _getAllExpectedLints(
      analysisResult.content,
      lineInfo,
      filePath: analysisResult.path,
    );

    // Lints are disabled for the entire file, so no point to even execute `getLints`
    if (fileIgnoredCodes.contains('type=lint')) return const Stream.empty();

    final analysisErrors = plugin
        .getLints(analysisResult)
        .where(
          (lint) =>
              !fileIgnoredCodes.contains(lint.code) &&
              !_isIgnored(lint, lineInfo, source),
        )
        .map<analyzer_plugin.AnalysisError?>((e) => e.asAnalysisError())
        // ignore: avoid_types_on_closure_parameters
        .handleError((Object error, StackTrace stackTrace) =>
            _handleGetLintsError(analysisResult, error, stackTrace))
        .where((e) => e != null)
        .cast<analyzer_plugin.AnalysisError>();

    return analysisErrors.toListStream().map((event) {
      return CustomAnalysisNotification(
        analyzer_plugin.AnalysisErrorsParams(analysisResult.path, event),
        expectLints,
      );
    });
  }

  /// Re-maps uncaught errors by [PluginBase.getLints] and, if in the IDE,
  /// shows a synthetic lint at the top of the file corresponding to the error.
  analyzer_plugin.AnalysisError? _handleGetLintsError(
    analyzer.ResolvedUnitResult analysisResult,
    Object error,
    StackTrace stackTrace,
  ) {
    final rethrownError = GetLintException(
      error: error,
      filePath: analysisResult.path,
    );

    // Sending the error back to the zone without rethrowing.
    // This allows the server can correctly log the error, and the client to
    // render the error at the top of the inspected file.
    Zone.current.handleUncaughtError(rethrownError, stackTrace);

    if (!_includeBuiltInLints) return null;

    // TODO test and handle all error cases
    final trace = Trace.from(stackTrace);

    final firstFileFrame = trace.frames.firstWhereOrNull(
      (frame) => frame.uri.scheme == 'file',
    );

    if (firstFileFrame == null) return null;

    final file = File.fromUri(firstFileFrame.uri);
    final sourceFile = SourceFile.fromString(file.readAsStringSync());

    return analyzer_plugin.AnalysisError(
      analyzer_plugin.AnalysisErrorSeverity.ERROR,
      analyzer_plugin.AnalysisErrorType.LINT,
      analysisResult
          .lintLocationFromLines(startLine: 1, endLine: 2)
          .asLocation(),
      'A lint plugin threw an exception',
      'custom_lint_get_lint_fail',
      contextMessages: [
        analyzer_plugin.DiagnosticMessage(
          error.toString(),
          analyzer_plugin.Location(
            firstFileFrame.library,
            sourceFile.getOffset(
              // frame location indices start at 1 not 0 so removing -1
              (firstFileFrame.line ?? 1) - 1,
              (firstFileFrame.column ?? 1) - 1,
            ),
            0,
            firstFileFrame.line ?? 1,
            firstFileFrame.column ?? 1,
          ),
        ),
      ],
    );
  }

  @override
  Future<analyzer_plugin.EditGetFixesResult> handleEditGetFixes(
    analyzer_plugin.EditGetFixesParams parameters,
  ) async {
    if (!_ownsPath(parameters.file)) {
      return analyzer_plugin.EditGetFixesResult([]);
    }

    final result = await getResolvedUnitResult(parameters.file);

    return plugin.handleEditGetFixes(result, parameters.offset);
  }

  Future<AwaitAnalysisDoneResult> _handleAwaitAnalysisDone(
    AwaitAnalysisDoneParams parameters,
  ) async {
    if (parameters.reload) _forcePluginRerun();

    while (_pendingAnalyzeFilesFutures.isNotEmpty ||
        _pendingGetLintsSubscriptions.isNotEmpty) {
      await Future.wait(_pendingAnalyzeFilesFutures.toList());
    }
    return const AwaitAnalysisDoneResult();
  }

  Future<SetConfigResult> _handleSetConfig(SetConfigParams params) async {
    _includeBuiltInLints = params.includeBuiltInLints;
    return const SetConfigResult();
  }

  /// A function for requesting the linters to re-execute on analyzed files.
  void _forcePluginRerun() {
    final contextCollection = this.contextCollection;
    if (contextCollection != null) {
      afterNewContextCollection(contextCollection: contextCollection);
    }
  }

  @override
  FutureOr<ResponseResult?> handleCustomRequest(
    Request request,
    int requestTime,
  ) async {
    switch (request.method) {
      case AwaitAnalysisDoneParams.key:
        final params = AwaitAnalysisDoneParams.fromRequest(request);
        return _handleAwaitAnalysisDone(params);
      case SetConfigParams.key:
        final params = SetConfigParams.fromRequest(request);
        _handleWatchModeConfig(watchMode: params.watchMode);
        return _handleSetConfig(params);
    }
    return null;
  }

  bool _ownsPath(String path) {
    if (!path.endsWith('.dart')) return false;

    final context = contextCollection?.contextFor(path);
    if (context == null) return false;

    return context.contextRoot.isAnalyzed(path);
  }

  @override
  Future<void> analyzeFile({
    required AnalysisContext analysisContext,
    required String path,
  }) async {
    if (!_ownsPath(path)) return;

    // TODO test that getLints stops being listened if a new Result is emitted
    // before the previous getLints completes
    unawaited(_pendingGetLintsSubscriptions[path]?.cancel());

    final resolvedUnitResult = await getResolvedUnitResult(path);

    // ignore: cancel_subscriptions, the subscription is stored in the object and cancelled later
    final sub = _getAnalysisErrors(resolvedUnitResult).listen(
      (event) => channel.sendNotification(event.toNotification()),
      onDone: () => _pendingGetLintsSubscriptions.remove(path),
    );
    _pendingGetLintsSubscriptions[path] = sub;
  }

  void _handleWatchModeConfig({required bool watchMode}) {
    // On config change, cancel the previous reloader
    unawaited(
      _hotReloader?.then(
        (value) => value.stop(),
        // ignore: avoid_types_on_closure_parameters, false positive
        onError: (Object err, StackTrace stack) {},
      ),
    );
    _hotReloader = null;

    if (watchMode) {
      _hotReloader = HotReloader.create(
        onBeforeReload: (c) {
          channel.sendNotification(
            const PrintNotification('Source change detected, hot-reloading...')
                .toNotification(),
          );
          // Allow hot-reload to be performed
          return true;
        },
        onAfterReload: (c) {
          if (c.result == HotReloadResult.Succeeded) {
            channel.sendNotification(
              const DidHotReloadNotification().toNotification(),
            );
          }
        },
      );
    }
  }

  @override
  Future<void> analyzeFiles({
    required AnalysisContext analysisContext,
    required List<String> paths,
  }) async {
    // We override "analyzeFiles" to keep track of the pending analysis.

    // Encapsulating super.analyzeFiles in a future to make sure it doesn't
    // synchronously throw. This shouldn't be necessary but we're not supposed to
    // know what the implementation is.
    final analyzeFilesFuture = Future(
      () => super.analyzeFiles(analysisContext: analysisContext, paths: paths),
    );

    try {
      _pendingAnalyzeFilesFutures.add(analyzeFilesFuture);
      await analyzeFilesFuture;
    } finally {
      _pendingAnalyzeFilesFutures.remove(analyzeFilesFuture);
    }
  }
}

extension<T> on Stream<T> {
  /// Creates a [Stream] that emits a single event containing a list of all the
  /// events from the passed stream.
  ///
  /// This is different from [Stream.toList] in that the returned [Stream]
  /// supports pausing/cancelling.
  /// In particular, if the returned stream stops being listened before the inner
  /// stream completes, then the subscription to the inner stream will be closed.
  Stream<List<T>> toListStream() {
    late StreamSubscription<T> sub;

    final controller = StreamController<List<T>>();
    controller.onListen = () {
      final ints = <T>[];
      sub = listen(
        ints.add,
        onError: controller.addError,
        onDone: () {
          controller.add(ints);
          controller.onCancel!();
        },
      );
    };
    controller.onPause = () => sub.pause();
    controller.onResume = () => sub.resume();
    controller.onCancel = () {
      sub.cancel();
      controller.close();
    };

    return controller.stream;
  }
}

final _ignoreRegex = RegExp(r'//\s*ignore\s*:(.+)$', multiLine: true);

bool _isIgnored(Lint lint, LineInfo lineInfo, String source) {
  // -1 because lines starts at 1 not 0
  final line = lint.location.startLine - 1;

  if (line == 0) return false;

  final previousLine = source.substring(
    lineInfo.getOffsetOfLine(line - 1),
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

List<ExpectLintMeta> _getAllExpectedLints(
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

      return ExpectLintMeta(
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
