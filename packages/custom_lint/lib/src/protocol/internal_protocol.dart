/// A list of custom requests/notifications that are not part of analyzer_plugin
/// but that custom_lint defines
library custom_protocol;

import 'dart:convert' show json;

import 'package:analyzer_plugin/protocol/protocol.dart';
// ignore: implementation_imports
import 'package:analyzer_plugin/src/protocol/protocol_internal.dart';
import 'package:meta/meta.dart';

/// {@template custom_lint.protocol.get_analysis_error_params}
/// Asks the client to notify the server when it is done analysing files for
/// the moment.
/// {@endtemplate}
class AwaitAnalysisDoneParams implements RequestParams {
  /// {@macro custom_lint.protocol.get_analysis_error_params}
  const AwaitAnalysisDoneParams({required this.reload});

  /// Decodes a [AwaitAnalysisDoneParams] from a [Request].
  factory AwaitAnalysisDoneParams.fromRequest(Request request) {
    assert(
      request.method == key,
      'Notification is not a $key notification',
    );

    return AwaitAnalysisDoneParams(reload: request.params['reload']! as bool);
  }

  /// The unique [Request.method] for a [AwaitAnalysisDoneParams].
  static const key = 'custom_lint.await_analysis_done';

  /// Whether to invalidate / rerun the linting process due to reload
  final bool reload;

  @override
  Map<String, Object> toJson() => {'reload': reload};

  @override
  Request toRequest(String id) => Request(id, key, toJson());
}

/// Signals the server that the plugin is currently done analyzing.
@immutable
class AwaitAnalysisDoneResult implements ResponseResult {
  /// Signals the server that the plugin is currently done analyzing.
  const AwaitAnalysisDoneResult();

  /// Decodes a [AwaitAnalysisDoneResult] from a [Response].
  factory AwaitAnalysisDoneResult.fromResponse(Response response) {
    assert(response.result!.isEmpty, 'Response.result should be an empty map');
    return const AwaitAnalysisDoneResult();
  }

  @override
  Map<String, Object> toJson() => {};

  @override
  Response toResponse(String id, int requestTime) {
    return Response(id, requestTime, result: toJson());
  }

  @override
  String toString() => json.encode(toJson());

  @override
  bool operator ==(Object? other) => runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}
