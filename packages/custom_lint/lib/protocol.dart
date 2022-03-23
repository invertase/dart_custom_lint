import 'dart:convert';

import 'package:analyzer_plugin/protocol/protocol.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';
// ignore: implementation_imports
import 'package:analyzer_plugin/src/protocol/protocol_internal.dart'
    show
        REQUEST_ID_REFACTORING_KINDS,
        RequestParams,
        ResponseDecoder,
        ResponseResult;
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

/// Notification for when a plugin invokes [print].
@immutable
class PrintNotification {
  /// Notification for when a plugin invokes [print].
  const PrintNotification(this.message);

  /// Decodes a [PrintNotification] from a [Notification].
  factory PrintNotification.fromNotification(Notification notification) {
    assert(
      notification.event == key,
      'Notification is not a $key notification',
    );

    return PrintNotification(notification.params!['message']! as String);
  }

  /// The unique [Notification.event] key for [PrintNotification].
  static const key = 'custom_lint.print';

  /// The string that was passed to [print].
  final String message;

  /// Converts [PrintNotification] to a [Notification].
  Notification toNotification() {
    return Notification(key, {'message': message});
  }
}

/// {@template custom_lint.protocol.get_analysis_error_params}
/// The request parameter for obtaining lints on a few specific files in
/// a way that can be awaited by the manager of all plugins.
///
/// This request is used in particular when using the command line,
/// to explicitly request lints for the known Dart files.
/// {@endtemplate}
class GetAnalysisErrorParams implements RequestParams {
  /// {@macro custom_lint.protocol.get_analysis_error_params}
  GetAnalysisErrorParams(this.files);

  /// Decodes a [GetAnalysisErrorParams] from a [Request].
  factory GetAnalysisErrorParams.fromRequest(Request request) {
    assert(
      request.method == key,
      'Notification is not a $key notification',
    );

    return GetAnalysisErrorParams(
      List.from(request.params['files']! as List),
    );
  }

  /// The unique [Request.method] for a [GetAnalysisErrorParams].
  static const key = 'custom_lint.get_analysis_errors';

  /// The files for which the plugin client should return the list of lints.
  final List<String> files;

  @override
  Map<String, Object> toJson() => {'files': files};

  @override
  Request toRequest(String id) => Request(id, key, toJson());
}

/// The response to a [GetAnalysisErrorParams] containing the list of lints
/// for the requested files.
@immutable
class GetAnalysisErrorResult implements ResponseResult {
  /// The response to a [GetAnalysisErrorParams] containing the list of lints
  /// for the requested files.
  const GetAnalysisErrorResult(this.lints);

  /// Decodes a [GetAnalysisErrorResult] from a [Response].
  factory GetAnalysisErrorResult.fromResponse(Response response) {
    final lints =
        response.result?['lints'] as List<Object?>? ?? const <String>[];

    final decoder =
        ResponseDecoder(REQUEST_ID_REFACTORING_KINDS.remove(response.id));

    final errors = decoder.decodeList(
      'lints',
      lints,
      (jsonPath, json) =>
          AnalysisErrorsParams.fromJson(decoder, jsonPath, json),
    );

    return GetAnalysisErrorResult(errors);
  }

  /// The lints associated to the requested files.
  final List<AnalysisErrorsParams> lints;

  @override
  Map<String, Object> toJson() {
    return {
      'lints': lints.map((e) => e.toJson()).toList(),
    };
  }

  @override
  Response toResponse(String id, int requestTime) {
    return Response(id, requestTime, result: toJson());
  }

  @override
  String toString() => json.encode(toJson());

  @override
  bool operator ==(Object? other) {
    return other is GetAnalysisErrorResult &&
        runtimeType == other.runtimeType &&
        const DeepCollectionEquality().equals(lints, other.lints);
  }

  @override
  int get hashCode => Object.hash(
        runtimeType,
        const DeepCollectionEquality().hash(lints),
      );
}
