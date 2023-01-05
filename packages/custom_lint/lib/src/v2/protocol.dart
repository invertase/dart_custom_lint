import 'package:analyzer_plugin/protocol/protocol.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'protocol.g.dart';
part 'protocol.freezed.dart';

@freezed
class CustomLintRequest with _$CustomLintRequest {
  factory CustomLintRequest.analyzerPluginRequest(
    Request request, {
    required String id,
  }) = CustomLintRequestAnalyzerPluginRequest;

  factory CustomLintRequest.awaitAnalysisDone({
    required String id,
    required bool reload,
  }) = _CustomLintRequestAwaitAnalysisDone;

  factory CustomLintRequest.ping({required String id}) = _CustomLintRequestPing;

  factory CustomLintRequest.fromJson(Map<String, Object?> json) =>
      _$CustomLintRequestFromJson(json);

  @override
  String get id;
}

@freezed
class CustomLintResponse with _$CustomLintResponse {
  factory CustomLintResponse.analyzerPluginResponse(
    Response response, {
    required String id,
  }) = _CustomLintResponseAnalyzerPluginResponse;

  factory CustomLintResponse.awaitAnalysisDone({required String id}) =
      _CustomLintResponseAwaitAnalysisDone;

  factory CustomLintResponse.pong({required String id}) =
      _CustomLintResponsePong;

  factory CustomLintResponse.error({
    required String id,
    required String message,
    required String stackTrace,
  }) = _CustomLintResponseError;

  factory CustomLintResponse.fromJson(Map<String, Object?> json) =>
      _$CustomLintResponseFromJson(json);

  @override
  String get id;
}

@freezed
class CustomLintMessage with _$CustomLintMessage {
  factory CustomLintMessage.event(CustomLintEvent event) =
      CustomLintMessageEvent;
  factory CustomLintMessage.response(CustomLintResponse response) =
      CustomLintMessageResponse;

  factory CustomLintMessage.fromJson(Map<String, Object?> json) =>
      _$CustomLintMessageFromJson(json);
}

class NotificationJsonConverter
    extends JsonConverter<Notification, Map<String, Object?>> {
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

@freezed
class CustomLintEvent with _$CustomLintEvent {
  factory CustomLintEvent.analyzerPluginNotification(
    @NotificationJsonConverter() Notification notification,
  ) = _CustomLintEventAnalyzerPluginNotification;
  // TOOD add source change event?

  /// A spontaneous error, unrelated to a request
  factory CustomLintEvent.error(
    String message,
    String stackTrace, {
    required String? pluginName,
  }) = _CustomLintEventError;

  /// A log output
  factory CustomLintEvent.print(
    String message, {
    required String? pluginName,
  }) = _CustomLintEventPrint;

  factory CustomLintEvent.fromJson(Map<String, Object?> json) =>
      _$CustomLintEventFromJson(json);
}
