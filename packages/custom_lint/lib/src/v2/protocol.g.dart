// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint

part of 'protocol.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomLintRequestAnalyzerPluginRequest
    _$CustomLintRequestAnalyzerPluginRequestFromJson(
            Map<String, dynamic> json) =>
        CustomLintRequestAnalyzerPluginRequest(
          Request.fromJson(json['request'] as Map<String, dynamic>),
          id: json['id'] as String,
          $type: json['runtimeType'] as String?,
        );

Map<String, dynamic> _$CustomLintRequestAnalyzerPluginRequestToJson(
        CustomLintRequestAnalyzerPluginRequest instance) =>
    <String, dynamic>{
      'request': instance.request,
      'id': instance.id,
      'runtimeType': instance.$type,
    };

CustomLintRequestAwaitAnalysisDone _$CustomLintRequestAwaitAnalysisDoneFromJson(
        Map<String, dynamic> json) =>
    CustomLintRequestAwaitAnalysisDone(
      id: json['id'] as String,
      reload: json['reload'] as bool,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$CustomLintRequestAwaitAnalysisDoneToJson(
        CustomLintRequestAwaitAnalysisDone instance) =>
    <String, dynamic>{
      'id': instance.id,
      'reload': instance.reload,
      'runtimeType': instance.$type,
    };

CustomLintRequestPing _$CustomLintRequestPingFromJson(
        Map<String, dynamic> json) =>
    CustomLintRequestPing(
      id: json['id'] as String,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$CustomLintRequestPingToJson(
        CustomLintRequestPing instance) =>
    <String, dynamic>{
      'id': instance.id,
      'runtimeType': instance.$type,
    };

CustomLintResponseAnalyzerPluginResponse
    _$CustomLintResponseAnalyzerPluginResponseFromJson(
            Map<String, dynamic> json) =>
        CustomLintResponseAnalyzerPluginResponse(
          Response.fromJson(json['response'] as Map<String, dynamic>),
          id: json['id'] as String,
          $type: json['runtimeType'] as String?,
        );

Map<String, dynamic> _$CustomLintResponseAnalyzerPluginResponseToJson(
        CustomLintResponseAnalyzerPluginResponse instance) =>
    <String, dynamic>{
      'response': instance.response,
      'id': instance.id,
      'runtimeType': instance.$type,
    };

CustomLintResponseAwaitAnalysisDone
    _$CustomLintResponseAwaitAnalysisDoneFromJson(Map<String, dynamic> json) =>
        CustomLintResponseAwaitAnalysisDone(
          id: json['id'] as String,
          $type: json['runtimeType'] as String?,
        );

Map<String, dynamic> _$CustomLintResponseAwaitAnalysisDoneToJson(
        CustomLintResponseAwaitAnalysisDone instance) =>
    <String, dynamic>{
      'id': instance.id,
      'runtimeType': instance.$type,
    };

CustomLintResponsePong _$CustomLintResponsePongFromJson(
        Map<String, dynamic> json) =>
    CustomLintResponsePong(
      id: json['id'] as String,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$CustomLintResponsePongToJson(
        CustomLintResponsePong instance) =>
    <String, dynamic>{
      'id': instance.id,
      'runtimeType': instance.$type,
    };

CustomLintResponseError _$CustomLintResponseErrorFromJson(
        Map<String, dynamic> json) =>
    CustomLintResponseError(
      id: json['id'] as String,
      message: json['message'] as String,
      stackTrace: json['stackTrace'] as String,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$CustomLintResponseErrorToJson(
        CustomLintResponseError instance) =>
    <String, dynamic>{
      'id': instance.id,
      'message': instance.message,
      'stackTrace': instance.stackTrace,
      'runtimeType': instance.$type,
    };

CustomLintMessageEvent _$CustomLintMessageEventFromJson(
        Map<String, dynamic> json) =>
    CustomLintMessageEvent(
      CustomLintEvent.fromJson(json['event'] as Map<String, dynamic>),
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$CustomLintMessageEventToJson(
        CustomLintMessageEvent instance) =>
    <String, dynamic>{
      'event': instance.event,
      'runtimeType': instance.$type,
    };

CustomLintMessageResponse _$CustomLintMessageResponseFromJson(
        Map<String, dynamic> json) =>
    CustomLintMessageResponse(
      CustomLintResponse.fromJson(json['response'] as Map<String, dynamic>),
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$CustomLintMessageResponseToJson(
        CustomLintMessageResponse instance) =>
    <String, dynamic>{
      'response': instance.response,
      'runtimeType': instance.$type,
    };

CustomLintEventAnalyzerPluginNotification
    _$CustomLintEventAnalyzerPluginNotificationFromJson(
            Map<String, dynamic> json) =>
        CustomLintEventAnalyzerPluginNotification(
          const NotificationJsonConverter()
              .fromJson(json['notification'] as Map<String, Object?>),
          $type: json['runtimeType'] as String?,
        );

Map<String, dynamic> _$CustomLintEventAnalyzerPluginNotificationToJson(
        CustomLintEventAnalyzerPluginNotification instance) =>
    <String, dynamic>{
      'notification':
          const NotificationJsonConverter().toJson(instance.notification),
      'runtimeType': instance.$type,
    };

CustomLintEventError _$CustomLintEventErrorFromJson(
        Map<String, dynamic> json) =>
    CustomLintEventError(
      json['message'] as String,
      json['stackTrace'] as String,
      pluginName: json['pluginName'] as String?,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$CustomLintEventErrorToJson(
        CustomLintEventError instance) =>
    <String, dynamic>{
      'message': instance.message,
      'stackTrace': instance.stackTrace,
      'pluginName': instance.pluginName,
      'runtimeType': instance.$type,
    };

CustomLintEventPrint _$CustomLintEventPrintFromJson(
        Map<String, dynamic> json) =>
    CustomLintEventPrint(
      json['message'] as String,
      pluginName: json['pluginName'] as String?,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$CustomLintEventPrintToJson(
        CustomLintEventPrint instance) =>
    <String, dynamic>{
      'message': instance.message,
      'pluginName': instance.pluginName,
      'runtimeType': instance.$type,
    };
