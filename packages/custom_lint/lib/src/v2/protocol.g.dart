// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint

part of 'protocol.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CustomLintRequestAnalyzerPluginRequest
    _$$CustomLintRequestAnalyzerPluginRequestFromJson(
            Map<String, dynamic> json) =>
        _$CustomLintRequestAnalyzerPluginRequest(
          Request.fromJson(json['request'] as Map<String, dynamic>),
          id: json['id'] as String,
          $type: json['runtimeType'] as String?,
        );

Map<String, dynamic> _$$CustomLintRequestAnalyzerPluginRequestToJson(
        _$CustomLintRequestAnalyzerPluginRequest instance) =>
    <String, dynamic>{
      'request': instance.request,
      'id': instance.id,
      'runtimeType': instance.$type,
    };

_$_CustomLintRequestAwaitAnalysisDone
    _$$_CustomLintRequestAwaitAnalysisDoneFromJson(Map<String, dynamic> json) =>
        _$_CustomLintRequestAwaitAnalysisDone(
          id: json['id'] as String,
          reload: json['reload'] as bool,
          $type: json['runtimeType'] as String?,
        );

Map<String, dynamic> _$$_CustomLintRequestAwaitAnalysisDoneToJson(
        _$_CustomLintRequestAwaitAnalysisDone instance) =>
    <String, dynamic>{
      'id': instance.id,
      'reload': instance.reload,
      'runtimeType': instance.$type,
    };

_$_CustomLintRequestPing _$$_CustomLintRequestPingFromJson(
        Map<String, dynamic> json) =>
    _$_CustomLintRequestPing(
      id: json['id'] as String,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$_CustomLintRequestPingToJson(
        _$_CustomLintRequestPing instance) =>
    <String, dynamic>{
      'id': instance.id,
      'runtimeType': instance.$type,
    };

_$_CustomLintResponseAnalyzerPluginResponse
    _$$_CustomLintResponseAnalyzerPluginResponseFromJson(
            Map<String, dynamic> json) =>
        _$_CustomLintResponseAnalyzerPluginResponse(
          Response.fromJson(json['response'] as Map<String, dynamic>),
          id: json['id'] as String,
          $type: json['runtimeType'] as String?,
        );

Map<String, dynamic> _$$_CustomLintResponseAnalyzerPluginResponseToJson(
        _$_CustomLintResponseAnalyzerPluginResponse instance) =>
    <String, dynamic>{
      'response': instance.response,
      'id': instance.id,
      'runtimeType': instance.$type,
    };

_$_CustomLintResponseAwaitAnalysisDone
    _$$_CustomLintResponseAwaitAnalysisDoneFromJson(
            Map<String, dynamic> json) =>
        _$_CustomLintResponseAwaitAnalysisDone(
          id: json['id'] as String,
          $type: json['runtimeType'] as String?,
        );

Map<String, dynamic> _$$_CustomLintResponseAwaitAnalysisDoneToJson(
        _$_CustomLintResponseAwaitAnalysisDone instance) =>
    <String, dynamic>{
      'id': instance.id,
      'runtimeType': instance.$type,
    };

_$_CustomLintResponsePong _$$_CustomLintResponsePongFromJson(
        Map<String, dynamic> json) =>
    _$_CustomLintResponsePong(
      id: json['id'] as String,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$_CustomLintResponsePongToJson(
        _$_CustomLintResponsePong instance) =>
    <String, dynamic>{
      'id': instance.id,
      'runtimeType': instance.$type,
    };

_$_CustomLintResponseError _$$_CustomLintResponseErrorFromJson(
        Map<String, dynamic> json) =>
    _$_CustomLintResponseError(
      id: json['id'] as String,
      message: json['message'] as String,
      stackTrace: json['stackTrace'] as String,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$_CustomLintResponseErrorToJson(
        _$_CustomLintResponseError instance) =>
    <String, dynamic>{
      'id': instance.id,
      'message': instance.message,
      'stackTrace': instance.stackTrace,
      'runtimeType': instance.$type,
    };

_$CustomLintMessageEvent _$$CustomLintMessageEventFromJson(
        Map<String, dynamic> json) =>
    _$CustomLintMessageEvent(
      CustomLintEvent.fromJson(json['event'] as Map<String, dynamic>),
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$CustomLintMessageEventToJson(
        _$CustomLintMessageEvent instance) =>
    <String, dynamic>{
      'event': instance.event,
      'runtimeType': instance.$type,
    };

_$CustomLintMessageResponse _$$CustomLintMessageResponseFromJson(
        Map<String, dynamic> json) =>
    _$CustomLintMessageResponse(
      CustomLintResponse.fromJson(json['response'] as Map<String, dynamic>),
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$CustomLintMessageResponseToJson(
        _$CustomLintMessageResponse instance) =>
    <String, dynamic>{
      'response': instance.response,
      'runtimeType': instance.$type,
    };

_$_CustomLintEventAnalyzerPluginNotification
    _$$_CustomLintEventAnalyzerPluginNotificationFromJson(
            Map<String, dynamic> json) =>
        _$_CustomLintEventAnalyzerPluginNotification(
          const NotificationJsonConverter()
              .fromJson(json['notification'] as Map<String, Object?>),
          $type: json['runtimeType'] as String?,
        );

Map<String, dynamic> _$$_CustomLintEventAnalyzerPluginNotificationToJson(
        _$_CustomLintEventAnalyzerPluginNotification instance) =>
    <String, dynamic>{
      'notification':
          const NotificationJsonConverter().toJson(instance.notification),
      'runtimeType': instance.$type,
    };

_$_CustomLintEventError _$$_CustomLintEventErrorFromJson(
        Map<String, dynamic> json) =>
    _$_CustomLintEventError(
      json['message'] as String,
      json['stackTrace'] as String,
      pluginName: json['pluginName'] as String?,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$_CustomLintEventErrorToJson(
        _$_CustomLintEventError instance) =>
    <String, dynamic>{
      'message': instance.message,
      'stackTrace': instance.stackTrace,
      'pluginName': instance.pluginName,
      'runtimeType': instance.$type,
    };

_$_CustomLintEventPrint _$$_CustomLintEventPrintFromJson(
        Map<String, dynamic> json) =>
    _$_CustomLintEventPrint(
      json['message'] as String,
      pluginName: json['pluginName'] as String?,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$_CustomLintEventPrintToJson(
        _$_CustomLintEventPrint instance) =>
    <String, dynamic>{
      'message': instance.message,
      'pluginName': instance.pluginName,
      'runtimeType': instance.$type,
    };
