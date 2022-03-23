// Copyright (c) 2017, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/file_system/overlay_file_system.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:analyzer_plugin/channel/channel.dart';
import 'package:analyzer_plugin/protocol/protocol.dart';
import 'package:analyzer_plugin/protocol/protocol_constants.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';
// ignore: implementation_imports
import 'package:analyzer_plugin/src/protocol/protocol_internal.dart'
    show ResponseResult;
import 'package:pub_semver/pub_semver.dart';

import '../../protocol.dart';
import '../log.dart';

/// The abstract superclass of any class implementing a plugin for the analysis
/// server.
///
/// Clients may not implement or mix-in this class, but are expected to extend
/// it.
abstract class MyServerPlugin {
  /// Initialize a newly created analysis server plugin. If a resource [provider]
  /// is given, then it will be used to access the file system. Otherwise a
  /// resource provider that accesses the physical file system will be used.
  MyServerPlugin(ResourceProvider? provider)
      : resourceProvider = OverlayResourceProvider(
          provider ?? PhysicalResourceProvider.INSTANCE,
        );

  /// A megabyte.
  static const int M = 1024 * 1024;

  /// The communication channel being used to communicate with the analysis
  /// server.
  late PluginCommunicationChannel _channel;

  /// The resource provider used to access the file system.
  final OverlayResourceProvider resourceProvider;

  /// Return the communication channel being used to communicate with the
  /// analysis server, or `null` if the plugin has not been started.
  PluginCommunicationChannel get channel => _channel;

  /// Return the user visible information about how to contact the plugin authors
  /// with any problems that are found, or `null` if there is no contact info.
  String? get contactInfo => null;

  /// Return a list of glob patterns selecting the files that this plugin is
  /// interested in analyzing.
  List<String> get fileGlobsToAnalyze;

  /// Return the user visible name of this plugin.
  String get name;

  /// Return the version number of the plugin spec required by this plugin,
  /// encoded as a string.
  String get version;

  /// Handle an 'analysis.getNavigation' request.
  ///
  /// Throw a [RequestFailure] if the request could not be handled.
  FutureOr<AnalysisGetNavigationResult> handleAnalysisGetNavigation(
    AnalysisGetNavigationParams parameters,
  );

  /// Handle an 'analysis.handleWatchEvents' request.
  ///
  /// Throw a [RequestFailure] if the request could not be handled.
  FutureOr<AnalysisHandleWatchEventsResult> handleAnalysisHandleWatchEvents(
    AnalysisHandleWatchEventsParams parameters,
  );

  /// Handle an 'analysis.setContextRoots' request.
  ///
  /// Throw a [RequestFailure] if the request could not be handled.
  FutureOr<AnalysisSetContextRootsResult> handleAnalysisSetContextRoots(
    AnalysisSetContextRootsParams parameters,
  );

  /// Handle an 'analysis.setPriorityFiles' request.
  ///
  /// Throw a [RequestFailure] if the request could not be handled.
  FutureOr<AnalysisSetPriorityFilesResult> handleAnalysisSetPriorityFiles(
    AnalysisSetPriorityFilesParams parameters,
  );

  /// Handle an 'analysis.setSubscriptions' request.
  ///
  /// Throw a [RequestFailure] if the request could not be handled.
  FutureOr<AnalysisSetSubscriptionsResult> handleAnalysisSetSubscriptions(
    AnalysisSetSubscriptionsParams parameters,
  );

  /// Handle an 'analysis.updateContent' request.
  ///
  /// Throw a [RequestFailure] if the request could not be handled.
  FutureOr<AnalysisUpdateContentResult> handleAnalysisUpdateContent(
    AnalysisUpdateContentParams parameters,
  );

  /// Handle a 'completion.getSuggestions' request.
  ///
  /// Throw a [RequestFailure] if the request could not be handled.
  FutureOr<CompletionGetSuggestionsResult> handleCompletionGetSuggestions(
    CompletionGetSuggestionsParams parameters,
  );

  /// Handle an 'edit.getAssists' request.
  ///
  /// Throw a [RequestFailure] if the request could not be handled.
  FutureOr<EditGetAssistsResult> handleEditGetAssists(
    EditGetAssistsParams parameters,
  );

  /// Handle an 'edit.getAvailableRefactorings' request. Subclasses that override
  /// this method in order to participate in refactorings must also override the
  /// method [handleEditGetRefactoring].
  ///
  /// Throw a [RequestFailure] if the request could not be handled.
  FutureOr<EditGetAvailableRefactoringsResult>
      handleEditGetAvailableRefactorings(
    EditGetAvailableRefactoringsParams parameters,
  );

  /// Handle an 'edit.getFixes' request.
  ///
  /// Throw a [RequestFailure] if the request could not be handled.
  FutureOr<EditGetFixesResult> handleEditGetFixes(
    EditGetFixesParams parameters,
  );

  /// Handle an 'edit.getRefactoring' request.
  ///
  /// Throw a [RequestFailure] if the request could not be handled.
  FutureOr<EditGetRefactoringResult?> handleEditGetRefactoring(
    EditGetRefactoringParams parameters,
  );

  /// Handle a 'kythe.getKytheEntries' request.
  ///
  /// Throw a [RequestFailure] if the request could not be handled.
  FutureOr<KytheGetKytheEntriesResult?> handleKytheGetKytheEntries(
    KytheGetKytheEntriesParams parameters,
  );

  /// Requests lints for specific files
  Future<GetAnalysisErrorResult> handleGetAnalysisErrors(
    GetAnalysisErrorParams parameters,
  );

  /// Handle a 'plugin.shutdown' request. Subclasses can override this method to
  /// perform any required clean-up, but cannot prevent the plugin from shutting
  /// down.
  ///
  /// Throw a [RequestFailure] if the request could not be handled.
  FutureOr<PluginShutdownResult> handlePluginShutdown(
    PluginShutdownParams parameters,
  ) async {
    return PluginShutdownResult();
  }

  /// Handle a 'plugin.versionCheck' request.
  ///
  /// Throw a [RequestFailure] if the request could not be handled.
  FutureOr<PluginVersionCheckResult> handlePluginVersionCheck(
    PluginVersionCheckParams parameters,
  );

  /// Return `true` if this plugin is compatible with an analysis server that is
  /// using the given version of the plugin API.
  bool isCompatibleWith(Version serverVersion) =>
      serverVersion <= Version.parse(version);

  /// The method that is called when the analysis server closes the communication
  /// channel. This method will not be invoked under normal conditions because
  /// the server will send a shutdown request and the plugin will stop listening
  /// to the channel before the server closes the channel.
  void onDone() {}

  /// The method that is called when an error has occurred in the analysis
  /// server. This method will not be invoked under normal conditions.
  void onError(Object exception, StackTrace stackTrace) {}

  /// Start this plugin by listening to the given communication [channel].
  void start(PluginCommunicationChannel channel) {
    _channel = channel;
    _channel.listen(_onRequest, onError: onError, onDone: onDone);
  }

  /// Compute the response that should be returned for the given [request], or
  /// `null` if the response has already been sent.
  Future<Response?> _getResponse(Request request, int requestTime) async {
    ResponseResult? result;
    switch (request.method) {
      case GetAnalysisErrorParams.key:
        final params = GetAnalysisErrorParams.fromRequest(request);
        result = await handleGetAnalysisErrors(params);
        break;
      case ANALYSIS_REQUEST_GET_NAVIGATION:
        final params = AnalysisGetNavigationParams.fromRequest(request);
        result = await handleAnalysisGetNavigation(params);
        break;
      case ANALYSIS_REQUEST_HANDLE_WATCH_EVENTS:
        final params = AnalysisHandleWatchEventsParams.fromRequest(request);
        result = await handleAnalysisHandleWatchEvents(params);
        break;
      case ANALYSIS_REQUEST_SET_CONTEXT_ROOTS:
        final params = AnalysisSetContextRootsParams.fromRequest(request);
        result = await handleAnalysisSetContextRoots(params);
        break;
      case ANALYSIS_REQUEST_SET_PRIORITY_FILES:
        final params = AnalysisSetPriorityFilesParams.fromRequest(request);
        result = await handleAnalysisSetPriorityFiles(params);
        break;
      case ANALYSIS_REQUEST_SET_SUBSCRIPTIONS:
        final params = AnalysisSetSubscriptionsParams.fromRequest(request);
        result = await handleAnalysisSetSubscriptions(params);
        break;
      case ANALYSIS_REQUEST_UPDATE_CONTENT:
        final params = AnalysisUpdateContentParams.fromRequest(request);
        result = await handleAnalysisUpdateContent(params);
        break;
      case COMPLETION_REQUEST_GET_SUGGESTIONS:
        final params = CompletionGetSuggestionsParams.fromRequest(request);
        result = await handleCompletionGetSuggestions(params);
        break;
      case EDIT_REQUEST_GET_ASSISTS:
        final params = EditGetAssistsParams.fromRequest(request);
        result = await handleEditGetAssists(params);
        break;
      case EDIT_REQUEST_GET_AVAILABLE_REFACTORINGS:
        final params = EditGetAvailableRefactoringsParams.fromRequest(request);
        result = await handleEditGetAvailableRefactorings(params);
        break;
      case EDIT_REQUEST_GET_FIXES:
        final params = EditGetFixesParams.fromRequest(request);
        result = await handleEditGetFixes(params);
        break;
      case EDIT_REQUEST_GET_REFACTORING:
        final params = EditGetRefactoringParams.fromRequest(request);
        result = await handleEditGetRefactoring(params);
        break;
      case KYTHE_REQUEST_GET_KYTHE_ENTRIES:
        final params = KytheGetKytheEntriesParams.fromRequest(request);
        result = await handleKytheGetKytheEntries(params);
        break;
      case PLUGIN_REQUEST_SHUTDOWN:
        final params = PluginShutdownParams();
        result = await handlePluginShutdown(params);
        _channel.sendResponse(result.toResponse(request.id, requestTime));
        _channel.close();
        return null;
      case PLUGIN_REQUEST_VERSION_CHECK:
        final params = PluginVersionCheckParams.fromRequest(request);
        result = await handlePluginVersionCheck(params);
        break;
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

  /// The method that is called when a [request] is received from the analysis
  /// server.
  Future<void> _onRequest(Request request) async {
    final requestTime = DateTime.now().millisecondsSinceEpoch;
    final id = request.id;
    Response? response;
    try {
      response = await _getResponse(request, requestTime);
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
      log('error $exception\n$stackTrace');
      Zone.current.handleUncaughtError(exception, stackTrace);
    }
    if (response != null) {
      _channel.sendResponse(response);
    }
  }
}
