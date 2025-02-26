import 'package:analyzer_plugin/protocol/protocol.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'protocol.g.dart';
part 'protocol.freezed.dart';

/// A base class shared between all custom_lint requests
@freezed
sealed class CustomLintRequest with _$CustomLintRequest {
  /// A request using the analyzer_plugin protocol
  factory CustomLintRequest.analyzerPluginRequest(
    Request request, {
    required String id,
  }) = CustomLintRequestAnalyzerPluginRequest;

  /// Requests to wait for the client to complete its analysis
  factory CustomLintRequest.awaitAnalysisDone({
    required String id,
    required bool reload,
  }) = CustomLintRequestAwaitAnalysisDone;

  /// Sends a meaningless message to the client, waiting for a response.
  factory CustomLintRequest.ping({required String id}) = CustomLintRequestPing;

  /// Decode a custom_lint request from JSON
  factory CustomLintRequest.fromJson(Map<String, Object?> json) =>
      _$CustomLintRequestFromJson(json);

  /// The unique request ID
  @override
  String get id;
}

/// The base class for all responses to a custom_lint request.
@freezed
sealed class CustomLintResponse with _$CustomLintResponse {
  /// The response for an analyzer_plugin request
  factory CustomLintResponse.analyzerPluginResponse(
    Response response, {
    required String id,
  }) = CustomLintResponseAnalyzerPluginResponse;

  /// The message sent when the client has completed its analysis
  factory CustomLintResponse.awaitAnalysisDone({required String id}) =
      CustomLintResponseAwaitAnalysisDone;

  /// The reply to a ping request
  factory CustomLintResponse.pong({required String id}) =
      CustomLintResponsePong;

  /// A request failed
  factory CustomLintResponse.error({
    required String id,
    required String message,
    required String stackTrace,
  }) = CustomLintResponseError;

  /// Decode a response from JSON
  factory CustomLintResponse.fromJson(Map<String, Object?> json) =>
      _$CustomLintResponseFromJson(json);

  @override
  String get id;
}

/// A base class between all messages from the client, be it request responses,
/// or spontaneous events.
@Freezed(copyWith: false)
abstract class CustomLintMessage with _$CustomLintMessage {
  /// A spontaneous event, not associated with a request
  factory CustomLintMessage.event(CustomLintEvent event) =
      CustomLintMessageEvent;

  /// A response to a request
  factory CustomLintMessage.response(CustomLintResponse response) =
      CustomLintMessageResponse;

  /// Decode a message from JSONs
  factory CustomLintMessage.fromJson(Map<String, Object?> json) =>
      _$CustomLintMessageFromJson(json);
}

/// A class for decoding a [Notification].
class NotificationJsonConverter
    extends JsonConverter<Notification, Map<String, Object?>> {
  /// A class for decoding a [Notification].
  const NotificationJsonConverter();

  @override
  Notification fromJson(Map<String, Object?> json) {
    return Notification(
      json[Notification.EVENT]! as String,
      Map.from(json[Notification.PARAMS]! as Map),
    );
  }

  @override
  Map<String, Object?> toJson(Notification object) {
    return object.toJson();
  }
}

/// A base class for all custom_lint events
@freezed
sealed class CustomLintEvent with _$CustomLintEvent {
  /// The client sent a [Notification] using the analyzer_plugin protocol
  factory CustomLintEvent.analyzerPluginNotification(
    @NotificationJsonConverter() Notification notification,
  ) = CustomLintEventAnalyzerPluginNotification;
  // TODO add source change event?

  /// A spontaneous error, unrelated to a request
  factory CustomLintEvent.error(
    String message,
    String stackTrace, {
    required String? pluginName,
  }) = CustomLintEventError;

  /// A log output
  factory CustomLintEvent.print(
    String message, {
    required String? pluginName,
  }) = CustomLintEventPrint;

  /// Decode an event from JSON
  factory CustomLintEvent.fromJson(Map<String, Object?> json) =>
      _$CustomLintEventFromJson(json);
}
