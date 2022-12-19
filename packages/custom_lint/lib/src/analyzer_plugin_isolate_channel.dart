import 'dart:async';
import 'dart:isolate';

import 'package:analyzer_plugin/protocol/protocol.dart';
import 'package:analyzer_plugin/protocol/protocol_constants.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';
// ignore: implementation_imports
import 'package:analyzer_plugin/src/protocol/protocol_internal.dart'
    show ResponseResult;

import 'protocol/internal_protocol.dart';

/// Handle an 'analysis.getNavigation' request.
///
/// Throw a [RequestFailure] if the request could not be handled.
typedef HandleAnalysisGetNavigation = FutureOr<AnalysisGetNavigationResult>
    Function(
  AnalysisGetNavigationParams parameters,
);

/// Handle an 'analysis.handleWatchEvents' request.
///
/// Throw a [RequestFailure] if the request could not be handled.
typedef HandleAnalysisHandleWatchEvents
    = FutureOr<AnalysisHandleWatchEventsResult> Function(
  AnalysisHandleWatchEventsParams parameters,
);

/// Handle an 'analysis.setContextRoots' request.
///
/// Throw a [RequestFailure] if the request could not be handled.
typedef HandleAnalysisSetContextRoots = FutureOr<AnalysisSetContextRootsResult>
    Function(
  AnalysisSetContextRootsParams parameters,
);

/// Handle an 'analysis.setPriorityFiles' request.
///
/// Throw a [RequestFailure] if the request could not be handled.
typedef HandleAnalysisSetPriorityFiles
    = FutureOr<AnalysisSetPriorityFilesResult> Function(
  AnalysisSetPriorityFilesParams parameters,
);

/// Handle an 'analysis.setSubscriptions' request.
///
/// Throw a [RequestFailure] if the request could not be handled.
typedef HandleAnalysisSetSubscriptions
    = FutureOr<AnalysisSetSubscriptionsResult> Function(
  AnalysisSetSubscriptionsParams parameters,
);

/// Handle an 'analysis.updateContent' request.
///
/// Throw a [RequestFailure] if the request could not be handled.
typedef HandleAnalysisUpdateContent = FutureOr<AnalysisUpdateContentResult>
    Function(
  AnalysisUpdateContentParams parameters,
);

/// Handle a 'completion.getSuggestions' request.
///
/// Throw a [RequestFailure] if the request could not be handled.
typedef HandleCompletionGetSuggestions
    = FutureOr<CompletionGetSuggestionsResult> Function(
  CompletionGetSuggestionsParams parameters,
);

/// Handle an 'edit.getAssists' request.
///
/// Throw a [RequestFailure] if the request could not be handled.
typedef HandleEditGetAssists = FutureOr<EditGetAssistsResult> Function(
  EditGetAssistsParams parameters,
);

/// Handle an 'edit.getAvailableRefactorings' request. Subclasses that override
/// this method in order to participate in refactorings must also override the
/// method [HandleEditGetRefactoring].
///
/// Throw a [RequestFailure] if the request could not be handled.
typedef HandleEditGetAvailableRefactorings
    = FutureOr<EditGetAvailableRefactoringsResult> Function(
  EditGetAvailableRefactoringsParams parameters,
);

/// Handle an 'edit.getFixes' request.
///
/// Throw a [RequestFailure] if the request could not be handled.
typedef HandleEditGetFixes = FutureOr<EditGetFixesResult> Function(
  EditGetFixesParams parameters,
);

/// Handle an 'edit.getRefactoring' request.
///
/// Throw a [RequestFailure] if the request could not be handled.
typedef HandleEditGetRefactoring = FutureOr<EditGetRefactoringResult?> Function(
  EditGetRefactoringParams parameters,
);

/// Handle a 'kythe.getKytheEntries' request.
///
/// Throw a [RequestFailure] if the request could not be handled.
typedef HandleKytheGetKytheEntries = FutureOr<KytheGetKytheEntriesResult?>
    Function(
  KytheGetKytheEntriesParams parameters,
);

/// Requests lints for specific files
typedef HandleAwaitAnalysisDone = FutureOr<AwaitAnalysisDoneResult> Function(
  AwaitAnalysisDoneParams parameters,
);

/// Handle a 'plugin.shutdown' request. Subclasses can override this method to
/// perform clean-up, but cannot prevent the plugin from shutting
/// down.
///
/// Throw a if the request could not be handled.
typedef HandlePluginShutdown = FutureOr<void> Function();

/// Handle a 'plugin.versionCheck' request.
///
/// Throw a [RequestFailure] if the request could not be handled.
typedef HandlePluginVersionCheck = FutureOr<PluginVersionCheckResult> Function(
  PluginVersionCheckParams parameters,
);

/// A channel used to communicate with the analyzer server using the
/// analyzer_plugin protocol
class AnalyzerPluginIsolateChannel {
  /// Initialize a newly created channel to communicate with the server.
  AnalyzerPluginIsolateChannel(this._sendPort) {
    _receivePort = ReceivePort();
    _sendPort.send(_receivePort.sendPort);
  }

  /// The port used to send notifications and responses to the server.
  final SendPort _sendPort;

  /// The port used to receive requests from the server.
  late final ReceivePort _receivePort;

  /// Emits a spontaneous event, not necesserily related to a [Request].
  void sendNotification(Notification notification) {
    final json = notification.toJson();
    _sendPort.send(json);
  }

  /// Closes the connection.
  ///
  /// After close, no more responses/notifications can be sent.
  /// Will be automatically closed on plugin shutdown.
  void close() => _receivePort.close();

  /// Subscribes to requests from the analyzer server
  StreamSubscription<void> listenRequests({
    HandleAnalysisGetNavigation? handleAnalysisGetNavigation,
    HandleAnalysisHandleWatchEvents? handleAnalysisHandleWatchEvents,
    HandleAnalysisSetContextRoots? handleAnalysisSetContextRoots,
    HandleAnalysisSetPriorityFiles? handleAnalysisSetPriorityFiles,
    HandleAnalysisSetSubscriptions? handleAnalysisSetSubscriptions,
    HandleAnalysisUpdateContent? handleAnalysisUpdateContent,
    HandleCompletionGetSuggestions? handleCompletionGetSuggestions,
    HandleEditGetAssists? handleEditGetAssists,
    HandleEditGetAvailableRefactorings? handleEditGetAvailableRefactorings,
    HandleEditGetFixes? handleEditGetFixes,
    HandleEditGetRefactoring? handleEditGetRefactoring,
    HandleKytheGetKytheEntries? handleKytheGetKytheEntries,
    HandleAwaitAnalysisDone? handleAwaitAnalysisDone,
    HandlePluginVersionCheck? handlePluginVersionCheck,
    required HandlePluginShutdown handlePluginShutdown,
    required FutureOr<Response?> Function(Request request, int requestTime)
        orElse,
  }) {
    final requests =
        _receivePort.cast<Map<String, Object?>>().map(Request.fromJson);

    /// Compute the response that should be returned for the given [request], or
    /// `null` if the response has already been sent.
    Future<Response?> _getResponse(Request request, int requestTime) async {
      ResponseResult? result;
      switch (request.method) {
        case AwaitAnalysisDoneParams.key:
          final params = AwaitAnalysisDoneParams.fromRequest(request);
          result = await handleAwaitAnalysisDone?.call(params);
          break;
        case ANALYSIS_REQUEST_GET_NAVIGATION:
          final params = AnalysisGetNavigationParams.fromRequest(request);
          result = await handleAnalysisGetNavigation?.call(params);
          break;
        case ANALYSIS_REQUEST_HANDLE_WATCH_EVENTS:
          final params = AnalysisHandleWatchEventsParams.fromRequest(request);
          result = await handleAnalysisHandleWatchEvents?.call(params);
          break;
        case ANALYSIS_REQUEST_SET_CONTEXT_ROOTS:
          final params = AnalysisSetContextRootsParams.fromRequest(request);
          result = await handleAnalysisSetContextRoots?.call(params);
          break;
        case ANALYSIS_REQUEST_SET_PRIORITY_FILES:
          final params = AnalysisSetPriorityFilesParams.fromRequest(request);
          result = await handleAnalysisSetPriorityFiles?.call(params);
          break;
        case ANALYSIS_REQUEST_SET_SUBSCRIPTIONS:
          final params = AnalysisSetSubscriptionsParams.fromRequest(request);
          result = await handleAnalysisSetSubscriptions?.call(params);
          break;
        case ANALYSIS_REQUEST_UPDATE_CONTENT:
          final params = AnalysisUpdateContentParams.fromRequest(request);
          result = await handleAnalysisUpdateContent?.call(params);
          break;
        case COMPLETION_REQUEST_GET_SUGGESTIONS:
          final params = CompletionGetSuggestionsParams.fromRequest(request);
          result = await handleCompletionGetSuggestions?.call(params);
          break;
        case EDIT_REQUEST_GET_ASSISTS:
          final params = EditGetAssistsParams.fromRequest(request);
          result = await handleEditGetAssists?.call(params);
          break;
        case EDIT_REQUEST_GET_AVAILABLE_REFACTORINGS:
          final params =
              EditGetAvailableRefactoringsParams.fromRequest(request);
          result = await handleEditGetAvailableRefactorings?.call(params);
          break;
        case EDIT_REQUEST_GET_FIXES:
          final params = EditGetFixesParams.fromRequest(request);
          result = await handleEditGetFixes?.call(params);
          break;
        case EDIT_REQUEST_GET_REFACTORING:
          final params = EditGetRefactoringParams.fromRequest(request);
          result = await handleEditGetRefactoring?.call(params);
          break;
        case KYTHE_REQUEST_GET_KYTHE_ENTRIES:
          final params = KytheGetKytheEntriesParams.fromRequest(request);
          result = await handleKytheGetKytheEntries?.call(params);
          break;
        case PLUGIN_REQUEST_SHUTDOWN:
          try {
            await handlePluginShutdown();
          } catch (err) {
            // No matter if it fails, we still want to close the channel and send a reply.
            // We can't use "finally" though, as otherwise the follow-up logic
            // would try to send an error response.
          }
          _sendResponse(
            PluginShutdownResult().toResponse(request.id, requestTime),
          );
          close();
          return null;
        case PLUGIN_REQUEST_VERSION_CHECK:
          final params = PluginVersionCheckParams.fromRequest(request);
          result = await handlePluginVersionCheck?.call(params);
          break;
      }
      if (result == null) {
        final response = await orElse(request, requestTime);
        if (response != null) return response;
      }

      if (result == null) {
        return Response(
          request.id,
          requestTime,
          error: RequestErrorFactory.unknownRequest(request.method),
        );
      }
      return result.toResponse(request.id, requestTime);
    }

    return requests.listen((request) => _onRequest(request, _getResponse));
  }

  /// The method that is called when a [request] is received from the analysis
  /// server.
  Future<void> _onRequest(
    Request request,
    FutureOr<Response?> Function(Request, int requestTime) requestHandler,
  ) async {
    final requestTime = DateTime.now().millisecondsSinceEpoch;
    final id = request.id;
    Response? response;
    try {
      response = await requestHandler(request, requestTime);
    } on RequestFailure catch (exception) {
      response = Response(id, requestTime, error: exception.error);
    } catch (exception, stackTrace) {
      response = Response(
        id,
        requestTime,
        error: RequestError(
          RequestErrorCode.PLUGIN_ERROR,
          exception.toString(),
          stackTrace: stackTrace.toString(),
        ),
      );
      // Reporting the error to the zone will log potential uncaught errors.
      Zone.current.handleUncaughtError(exception, stackTrace);
    }
    if (response != null) _sendResponse(response);
  }

  void _sendResponse(Response response) {
    _sendPort.send(response.toJson());
  }
}
