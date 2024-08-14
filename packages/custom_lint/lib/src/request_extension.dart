import 'package:analyzer_plugin/protocol/protocol.dart';
import 'package:analyzer_plugin/protocol/protocol_constants.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';

/// Handle an 'analysis.getNavigation' request.
///
/// Throw a [RequestFailure] if the request could not be handled.
typedef HandleAnalysisGetNavigation<R> = R Function(
  AnalysisGetNavigationParams parameters,
);

/// Handle an 'analysis.handleWatchEvents' request.
///
/// Throw a [RequestFailure] if the request could not be handled.
typedef HandleAnalysisHandleWatchEvents<R> = R Function(
  AnalysisHandleWatchEventsParams parameters,
);

/// Handle an 'analysis.setContextRoots' request.
///
/// Throw a [RequestFailure] if the request could not be handled.
typedef HandleAnalysisSetContextRoots<R> = R Function(
  AnalysisSetContextRootsParams parameters,
);

/// Handle an 'analysis.setPriorityFiles' request.
///
/// Throw a [RequestFailure] if the request could not be handled.
typedef HandleAnalysisSetPriorityFiles<R> = R Function(
  AnalysisSetPriorityFilesParams parameters,
);

/// Handle an 'analysis.setSubscriptions' request.
///
/// Throw a [RequestFailure] if the request could not be handled.
typedef HandleAnalysisSetSubscriptions<R> = R Function(
  AnalysisSetSubscriptionsParams parameters,
);

/// Handle an 'analysis.updateContent' request.
///
/// Throw a [RequestFailure] if the request could not be handled.
typedef HandleAnalysisUpdateContent<R> = R Function(
  AnalysisUpdateContentParams parameters,
);

/// Handle a 'completion.getSuggestions' request.
///
/// Throw a [RequestFailure] if the request could not be handled.
typedef HandleCompletionGetSuggestions<R> = R Function(
  CompletionGetSuggestionsParams parameters,
);

/// Handle an 'edit.getAssists' request.
///
/// Throw a [RequestFailure] if the request could not be handled.
typedef HandleEditGetAssists<R> = R Function(
  EditGetAssistsParams parameters,
);

/// Handle an 'edit.getAvailableRefactorings' request. Subclasses that override
/// this method in order to participate in refactorings must also override the
/// method [HandleEditGetRefactoring].
///
/// Throw a [RequestFailure] if the request could not be handled.
typedef HandleEditGetAvailableRefactorings<R> = R Function(
  EditGetAvailableRefactoringsParams parameters,
);

/// Handle an 'edit.getFixes' request.
///
/// Throw a [RequestFailure] if the request could not be handled.
typedef HandleEditGetFixes<R> = R Function(
  EditGetFixesParams parameters,
);

/// Handle an 'edit.getRefactoring' request.
///
/// Throw a [RequestFailure] if the request could not be handled.
typedef HandleEditGetRefactoring<R> = R Function(
  EditGetRefactoringParams parameters,
);

/// Handle a 'plugin.shutdown' request. Subclasses can override this method to
/// perform clean-up, but cannot prevent the plugin from shutting
/// down.
///
/// Throw a if the request could not be handled.
typedef HandlePluginShutdown<R> = R Function();

/// Handle a 'plugin.versionCheck' request.
///
/// Throw a [RequestFailure] if the request could not be handled.
typedef HandlePluginVersionCheck<R> = R Function(
  PluginVersionCheckParams parameters,
);

/// A channel used to communicate with the analyzer server using the
/// analyzer_plugin protocol
extension RequestX on Request {
  /// Subscribes to requests from the analyzer server
  R when<R>({
    HandleAnalysisGetNavigation<R>? handleAnalysisGetNavigation,
    HandleAnalysisHandleWatchEvents<R>? handleAnalysisHandleWatchEvents,
    HandleAnalysisSetContextRoots<R>? handleAnalysisSetContextRoots,
    HandleAnalysisSetPriorityFiles<R>? handleAnalysisSetPriorityFiles,
    HandleAnalysisSetSubscriptions<R>? handleAnalysisSetSubscriptions,
    HandleAnalysisUpdateContent<R>? handleAnalysisUpdateContent,
    HandleCompletionGetSuggestions<R>? handleCompletionGetSuggestions,
    HandleEditGetAssists<R>? handleEditGetAssists,
    HandleEditGetAvailableRefactorings<R>? handleEditGetAvailableRefactorings,
    HandleEditGetFixes<R>? handleEditGetFixes,
    HandleEditGetRefactoring<R>? handleEditGetRefactoring,
    HandlePluginVersionCheck<R>? handlePluginVersionCheck,
    HandlePluginShutdown<R>? handlePluginShutdown,
    required R Function() orElse,
  }) {
    switch (method) {
      case ANALYSIS_REQUEST_GET_NAVIGATION:
        if (handleAnalysisGetNavigation != null) {
          final params = AnalysisGetNavigationParams.fromRequest(this);
          return handleAnalysisGetNavigation(params);
        }

      case ANALYSIS_REQUEST_HANDLE_WATCH_EVENTS:
        if (handleAnalysisHandleWatchEvents != null) {
          final params = AnalysisHandleWatchEventsParams.fromRequest(this);
          return handleAnalysisHandleWatchEvents(params);
        }

      case ANALYSIS_REQUEST_SET_CONTEXT_ROOTS:
        if (handleAnalysisSetContextRoots != null) {
          final params = AnalysisSetContextRootsParams.fromRequest(this);
          return handleAnalysisSetContextRoots(params);
        }

      case ANALYSIS_REQUEST_SET_PRIORITY_FILES:
        if (handleAnalysisSetPriorityFiles != null) {
          final params = AnalysisSetPriorityFilesParams.fromRequest(this);
          return handleAnalysisSetPriorityFiles(params);
        }

      case ANALYSIS_REQUEST_SET_SUBSCRIPTIONS:
        if (handleAnalysisSetSubscriptions != null) {
          final params = AnalysisSetSubscriptionsParams.fromRequest(this);
          return handleAnalysisSetSubscriptions(params);
        }

      case ANALYSIS_REQUEST_UPDATE_CONTENT:
        if (handleAnalysisUpdateContent != null) {
          final params = AnalysisUpdateContentParams.fromRequest(this);
          return handleAnalysisUpdateContent(params);
        }

      case COMPLETION_REQUEST_GET_SUGGESTIONS:
        if (handleCompletionGetSuggestions != null) {
          final params = CompletionGetSuggestionsParams.fromRequest(this);
          return handleCompletionGetSuggestions(params);
        }

      case EDIT_REQUEST_GET_ASSISTS:
        if (handleEditGetAssists != null) {
          final params = EditGetAssistsParams.fromRequest(this);
          return handleEditGetAssists(params);
        }

      case EDIT_REQUEST_GET_AVAILABLE_REFACTORINGS:
        final params = EditGetAvailableRefactoringsParams.fromRequest(this);
        if (handleEditGetAvailableRefactorings != null) {
          return handleEditGetAvailableRefactorings(params);
        }

      case EDIT_REQUEST_GET_FIXES:
        if (handleEditGetFixes != null) {
          final params = EditGetFixesParams.fromRequest(this);
          return handleEditGetFixes(params);
        }

      case EDIT_REQUEST_GET_REFACTORING:
        if (handleEditGetRefactoring != null) {
          final params = EditGetRefactoringParams.fromRequest(this);
          return handleEditGetRefactoring(params);
        }

      case PLUGIN_REQUEST_SHUTDOWN:
        if (handlePluginShutdown != null) {
          return handlePluginShutdown();
        }

      case PLUGIN_REQUEST_VERSION_CHECK:
        final params = PluginVersionCheckParams.fromRequest(this);
        if (handlePluginVersionCheck != null) {
          return handlePluginVersionCheck(params);
        }
    }

    return orElse();
  }
}
