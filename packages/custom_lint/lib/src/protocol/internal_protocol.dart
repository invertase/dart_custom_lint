/// A list of custom requests/notifications that are not part of analyzer_plugin
/// but that custom_lint defines
library custom_protocol;

import 'dart:convert';

import 'package:analyzer_plugin/protocol/protocol.dart';
// ignore: implementation_imports
import 'package:analyzer_plugin/src/protocol/protocol_internal.dart'
    show RequestParams, ResponseResult;
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

/// {@template custom_lint.protocol.set_config_params}
/// The request for initializing configs of a plugin.
/// {@endtemplate}
class SetConfigParams implements RequestParams {
  /// {@macro custom_lint.protocol.set_config_params}
  SetConfigParams({
    required this.includeBuiltInLints,
    required this.watchMode,
  });

  /// Decodes a [SetConfigParams] from a [Request].
  factory SetConfigParams.fromRequest(Request request) {
    assert(
      request.method == key,
      'Notification is not a $key notification',
    );

    return SetConfigParams(
      includeBuiltInLints: request.params['include_built_in_lints']! as bool,
      watchMode: request.params['watch_mode']! as bool,
    );
  }

  /// The unique [Request.method] for a [SetConfigParams].
  static const key = 'custom_lint.set_config';

  /// Whether to include custom_lint meta lints about the status of a plugin
  final bool includeBuiltInLints;

  /// Whether the plugin was started in watch mode, and therefore should use hot-reload
  final bool watchMode;

  @override
  Map<String, Object> toJson() {
    return {
      'include_built_in_lints': includeBuiltInLints,
      'watch_mode': watchMode,
    };
  }

  @override
  Request toRequest(String id) => Request(id, key, toJson());
}

/// The response to a [SetConfigParams].
@immutable
class SetConfigResult implements ResponseResult {
  /// The response to a [SetConfigParams].
  const SetConfigResult();

  /// Decodes a [SetConfigResult] from a [Response].
  // ignore: avoid_unused_constructor_parameters
  factory SetConfigResult.fromResponse(Response response) =>
      const SetConfigResult();

  @override
  Map<String, Object> toJson() => const {};

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

/// Notifies the server that the linter code has changed.
@immutable
class DidHotReloadNotification {
  /// Notifies the server that the linter code has changed.
  const DidHotReloadNotification();

  /// Decodes a [PrintNotification] from a [Notification].
  factory DidHotReloadNotification.fromNotification(Notification notification) {
    assert(
      notification.event == key,
      'Notification is not a $key notification',
    );

    return const DidHotReloadNotification();
  }

  /// The unique [Notification.event] key for [DidHotReloadNotification].
  static const key = 'custom_lint.did_hot_reload';

  /// Converts [DidHotReloadNotification] to a [Notification].
  Notification toNotification() {
    return Notification(key, {});
  }
}
