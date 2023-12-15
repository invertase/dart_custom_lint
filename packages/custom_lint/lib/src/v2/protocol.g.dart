// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint

part of 'protocol.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CustomLintRequestAnalyzerPluginRequestImpl
    _$$CustomLintRequestAnalyzerPluginRequestImplFromJson(
            Map<String, dynamic> json) =>
        _$CustomLintRequestAnalyzerPluginRequestImpl(
          Request.fromJson(json['request'] as Map<String, dynamic>),
          id: json['id'] as String,
          $type: json['runtimeType'] as String?,
        );

Map<String, dynamic> _$$CustomLintRequestAnalyzerPluginRequestImplToJson(
        _$CustomLintRequestAnalyzerPluginRequestImpl instance) =>
    <String, dynamic>{
      'request': instance.request,
      'id': instance.id,
      'runtimeType': instance.$type,
    };

_$CustomLintRequestAwaitAnalysisDoneImpl
    _$$CustomLintRequestAwaitAnalysisDoneImplFromJson(
            Map<String, dynamic> json) =>
        _$CustomLintRequestAwaitAnalysisDoneImpl(
          id: json['id'] as String,
          reload: json['reload'] as bool,
          $type: json['runtimeType'] as String?,
        );

Map<String, dynamic> _$$CustomLintRequestAwaitAnalysisDoneImplToJson(
        _$CustomLintRequestAwaitAnalysisDoneImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'reload': instance.reload,
      'runtimeType': instance.$type,
    };

_$CustomLintRequestPingImpl _$$CustomLintRequestPingImplFromJson(
        Map<String, dynamic> json) =>
    _$CustomLintRequestPingImpl(
      id: json['id'] as String,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$CustomLintRequestPingImplToJson(
        _$CustomLintRequestPingImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'runtimeType': instance.$type,
    };

_$CustomLintResponseAnalyzerPluginResponseImpl
    _$$CustomLintResponseAnalyzerPluginResponseImplFromJson(
            Map<String, dynamic> json) =>
        _$CustomLintResponseAnalyzerPluginResponseImpl(
          Response.fromJson(json['response'] as Map<String, dynamic>),
          id: json['id'] as String,
          $type: json['runtimeType'] as String?,
        );

Map<String, dynamic> _$$CustomLintResponseAnalyzerPluginResponseImplToJson(
        _$CustomLintResponseAnalyzerPluginResponseImpl instance) =>
    <String, dynamic>{
      'response': instance.response,
      'id': instance.id,
      'runtimeType': instance.$type,
    };

_$CustomLintResponseAwaitAnalysisDoneImpl
    _$$CustomLintResponseAwaitAnalysisDoneImplFromJson(
            Map<String, dynamic> json) =>
        _$CustomLintResponseAwaitAnalysisDoneImpl(
          id: json['id'] as String,
          $type: json['runtimeType'] as String?,
        );

Map<String, dynamic> _$$CustomLintResponseAwaitAnalysisDoneImplToJson(
        _$CustomLintResponseAwaitAnalysisDoneImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'runtimeType': instance.$type,
    };

_$CustomLintResponsePongImpl _$$CustomLintResponsePongImplFromJson(
        Map<String, dynamic> json) =>
    _$CustomLintResponsePongImpl(
      id: json['id'] as String,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$CustomLintResponsePongImplToJson(
        _$CustomLintResponsePongImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'runtimeType': instance.$type,
    };

_$CustomLintResponseErrorImpl _$$CustomLintResponseErrorImplFromJson(
        Map<String, dynamic> json) =>
    _$CustomLintResponseErrorImpl(
      id: json['id'] as String,
      message: json['message'] as String,
      stackTrace: json['stackTrace'] as String,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$CustomLintResponseErrorImplToJson(
        _$CustomLintResponseErrorImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'message': instance.message,
      'stackTrace': instance.stackTrace,
      'runtimeType': instance.$type,
    };

_$CustomLintMessageEventImpl _$$CustomLintMessageEventImplFromJson(
        Map<String, dynamic> json) =>
    _$CustomLintMessageEventImpl(
      CustomLintEvent.fromJson(json['event'] as Map<String, dynamic>),
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$CustomLintMessageEventImplToJson(
        _$CustomLintMessageEventImpl instance) =>
    <String, dynamic>{
      'event': instance.event,
      'runtimeType': instance.$type,
    };

_$CustomLintMessageResponseImpl _$$CustomLintMessageResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$CustomLintMessageResponseImpl(
      CustomLintResponse.fromJson(json['response'] as Map<String, dynamic>),
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$CustomLintMessageResponseImplToJson(
        _$CustomLintMessageResponseImpl instance) =>
    <String, dynamic>{
      'response': instance.response,
      'runtimeType': instance.$type,
    };

_$CustomLintEventAnalyzerPluginNotificationImpl
    _$$CustomLintEventAnalyzerPluginNotificationImplFromJson(
            Map<String, dynamic> json) =>
        _$CustomLintEventAnalyzerPluginNotificationImpl(
          const NotificationJsonConverter()
              .fromJson(json['notification'] as Map<String, Object?>),
          $type: json['runtimeType'] as String?,
        );

Map<String, dynamic> _$$CustomLintEventAnalyzerPluginNotificationImplToJson(
        _$CustomLintEventAnalyzerPluginNotificationImpl instance) =>
    <String, dynamic>{
      'notification':
          const NotificationJsonConverter().toJson(instance.notification),
      'runtimeType': instance.$type,
    };

_$CustomLintEventErrorImpl _$$CustomLintEventErrorImplFromJson(
        Map<String, dynamic> json) =>
    _$CustomLintEventErrorImpl(
      json['message'] as String,
      json['stackTrace'] as String,
      pluginName: json['pluginName'] as String?,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$CustomLintEventErrorImplToJson(
        _$CustomLintEventErrorImpl instance) =>
    <String, dynamic>{
      'message': instance.message,
      'stackTrace': instance.stackTrace,
      'pluginName': instance.pluginName,
      'runtimeType': instance.$type,
    };

_$CustomLintEventPrintImpl _$$CustomLintEventPrintImplFromJson(
        Map<String, dynamic> json) =>
    _$CustomLintEventPrintImpl(
      json['message'] as String,
      pluginName: json['pluginName'] as String?,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$CustomLintEventPrintImplToJson(
        _$CustomLintEventPrintImpl instance) =>
    <String, dynamic>{
      'message': instance.message,
      'pluginName': instance.pluginName,
      'runtimeType': instance.$type,
    };
