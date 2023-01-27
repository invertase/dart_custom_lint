// GENERATED CODE - DO NOT MODIFY BY HAND

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

_$CustomLintRequestAwaitAnalysisDone
    _$$CustomLintRequestAwaitAnalysisDoneFromJson(Map<String, dynamic> json) =>
        _$CustomLintRequestAwaitAnalysisDone(
          id: json['id'] as String,
          reload: json['reload'] as bool,
          $type: json['runtimeType'] as String?,
        );

Map<String, dynamic> _$$CustomLintRequestAwaitAnalysisDoneToJson(
        _$CustomLintRequestAwaitAnalysisDone instance) =>
    <String, dynamic>{
      'id': instance.id,
      'reload': instance.reload,
      'runtimeType': instance.$type,
    };

_$CustomLintRequestLintRules _$$CustomLintRequestLintRulesFromJson(
        Map<String, dynamic> json) =>
    _$CustomLintRequestLintRules(
      id: json['id'] as String,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$CustomLintRequestLintRulesToJson(
        _$CustomLintRequestLintRules instance) =>
    <String, dynamic>{
      'id': instance.id,
      'runtimeType': instance.$type,
    };

_$CustomLintRequestPing _$$CustomLintRequestPingFromJson(
        Map<String, dynamic> json) =>
    _$CustomLintRequestPing(
      id: json['id'] as String,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$CustomLintRequestPingToJson(
        _$CustomLintRequestPing instance) =>
    <String, dynamic>{
      'id': instance.id,
      'runtimeType': instance.$type,
    };

_$_LintRuleMeta _$$_LintRuleMetaFromJson(Map<String, dynamic> json) =>
    _$_LintRuleMeta(
      pluginName: json['plugin_name'] as String,
      code: json['code'] as String,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$$_LintRuleMetaToJson(_$_LintRuleMeta instance) =>
    <String, dynamic>{
      'plugin_name': instance.pluginName,
      'code': instance.code,
      'description': instance.description,
    };

_$CustomLintResponseAnalyzerPluginResponse
    _$$CustomLintResponseAnalyzerPluginResponseFromJson(
            Map<String, dynamic> json) =>
        _$CustomLintResponseAnalyzerPluginResponse(
          Response.fromJson(json['response'] as Map<String, dynamic>),
          id: json['id'] as String,
          $type: json['runtimeType'] as String?,
        );

Map<String, dynamic> _$$CustomLintResponseAnalyzerPluginResponseToJson(
        _$CustomLintResponseAnalyzerPluginResponse instance) =>
    <String, dynamic>{
      'response': instance.response,
      'id': instance.id,
      'runtimeType': instance.$type,
    };

_$CustomLintResponseAwaitAnalysisDone
    _$$CustomLintResponseAwaitAnalysisDoneFromJson(Map<String, dynamic> json) =>
        _$CustomLintResponseAwaitAnalysisDone(
          id: json['id'] as String,
          $type: json['runtimeType'] as String?,
        );

Map<String, dynamic> _$$CustomLintResponseAwaitAnalysisDoneToJson(
        _$CustomLintResponseAwaitAnalysisDone instance) =>
    <String, dynamic>{
      'id': instance.id,
      'runtimeType': instance.$type,
    };

_$CustomLintResponseLintRules _$$CustomLintResponseLintRulesFromJson(
        Map<String, dynamic> json) =>
    _$CustomLintResponseLintRules(
      id: json['id'] as String,
      lintRules: (json['lint_rules'] as List<dynamic>)
          .map((e) => LintRuleMeta.fromJson(e as Map<String, dynamic>))
          .toList(),
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$CustomLintResponseLintRulesToJson(
        _$CustomLintResponseLintRules instance) =>
    <String, dynamic>{
      'id': instance.id,
      'lint_rules': instance.lintRules,
      'runtimeType': instance.$type,
    };

_$CustomLintResponsePong _$$CustomLintResponsePongFromJson(
        Map<String, dynamic> json) =>
    _$CustomLintResponsePong(
      id: json['id'] as String,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$CustomLintResponsePongToJson(
        _$CustomLintResponsePong instance) =>
    <String, dynamic>{
      'id': instance.id,
      'runtimeType': instance.$type,
    };

_$CustomLintResponseError _$$CustomLintResponseErrorFromJson(
        Map<String, dynamic> json) =>
    _$CustomLintResponseError(
      id: json['id'] as String,
      message: json['message'] as String,
      stackTrace: json['stack_trace'] as String,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$CustomLintResponseErrorToJson(
        _$CustomLintResponseError instance) =>
    <String, dynamic>{
      'id': instance.id,
      'message': instance.message,
      'stack_trace': instance.stackTrace,
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

_$CustomLintEventAnalyzerPluginNotification
    _$$CustomLintEventAnalyzerPluginNotificationFromJson(
            Map<String, dynamic> json) =>
        _$CustomLintEventAnalyzerPluginNotification(
          const NotificationJsonConverter()
              .fromJson(json['notification'] as Map<String, Object?>),
          $type: json['runtimeType'] as String?,
        );

Map<String, dynamic> _$$CustomLintEventAnalyzerPluginNotificationToJson(
        _$CustomLintEventAnalyzerPluginNotification instance) =>
    <String, dynamic>{
      'notification':
          const NotificationJsonConverter().toJson(instance.notification),
      'runtimeType': instance.$type,
    };

_$CustomLintEventError _$$CustomLintEventErrorFromJson(
        Map<String, dynamic> json) =>
    _$CustomLintEventError(
      json['message'] as String,
      json['stack_trace'] as String,
      pluginName: json['plugin_name'] as String?,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$CustomLintEventErrorToJson(
        _$CustomLintEventError instance) =>
    <String, dynamic>{
      'message': instance.message,
      'stack_trace': instance.stackTrace,
      'plugin_name': instance.pluginName,
      'runtimeType': instance.$type,
    };

_$CustomLintEventPrint _$$CustomLintEventPrintFromJson(
        Map<String, dynamic> json) =>
    _$CustomLintEventPrint(
      json['message'] as String,
      pluginName: json['plugin_name'] as String?,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$CustomLintEventPrintToJson(
        _$CustomLintEventPrint instance) =>
    <String, dynamic>{
      'message': instance.message,
      'plugin_name': instance.pluginName,
      'runtimeType': instance.$type,
    };
