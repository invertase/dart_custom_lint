// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'protocol.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

CustomLintRequest _$CustomLintRequestFromJson(Map<String, dynamic> json) {
  switch (json['runtimeType']) {
    case 'analyzerPluginRequest':
      return CustomLintRequestAnalyzerPluginRequest.fromJson(json);
    case 'awaitAnalysisDone':
      return CustomLintRequestAwaitAnalysisDone.fromJson(json);
    case 'listLintRules':
      return CustomLintRequestLintRules.fromJson(json);
    case 'ping':
      return CustomLintRequestPing.fromJson(json);

    default:
      throw CheckedFromJsonException(json, 'runtimeType', 'CustomLintRequest',
          'Invalid union type "${json['runtimeType']}"!');
  }
}

/// @nodoc
mixin _$CustomLintRequest {
  String get id => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Request request, String id) analyzerPluginRequest,
    required TResult Function(String id, bool reload) awaitAnalysisDone,
    required TResult Function(String id) listLintRules,
    required TResult Function(String id) ping,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Request request, String id)? analyzerPluginRequest,
    TResult? Function(String id, bool reload)? awaitAnalysisDone,
    TResult? Function(String id)? listLintRules,
    TResult? Function(String id)? ping,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Request request, String id)? analyzerPluginRequest,
    TResult Function(String id, bool reload)? awaitAnalysisDone,
    TResult Function(String id)? listLintRules,
    TResult Function(String id)? ping,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(CustomLintRequestAnalyzerPluginRequest value)
        analyzerPluginRequest,
    required TResult Function(CustomLintRequestAwaitAnalysisDone value)
        awaitAnalysisDone,
    required TResult Function(CustomLintRequestLintRules value) listLintRules,
    required TResult Function(CustomLintRequestPing value) ping,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(CustomLintRequestAnalyzerPluginRequest value)?
        analyzerPluginRequest,
    TResult? Function(CustomLintRequestAwaitAnalysisDone value)?
        awaitAnalysisDone,
    TResult? Function(CustomLintRequestLintRules value)? listLintRules,
    TResult? Function(CustomLintRequestPing value)? ping,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(CustomLintRequestAnalyzerPluginRequest value)?
        analyzerPluginRequest,
    TResult Function(CustomLintRequestAwaitAnalysisDone value)?
        awaitAnalysisDone,
    TResult Function(CustomLintRequestLintRules value)? listLintRules,
    TResult Function(CustomLintRequestPing value)? ping,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CustomLintRequestCopyWith<CustomLintRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CustomLintRequestCopyWith<$Res> {
  factory $CustomLintRequestCopyWith(
          CustomLintRequest value, $Res Function(CustomLintRequest) then) =
      _$CustomLintRequestCopyWithImpl<$Res, CustomLintRequest>;
  @useResult
  $Res call({String id});
}

/// @nodoc
class _$CustomLintRequestCopyWithImpl<$Res, $Val extends CustomLintRequest>
    implements $CustomLintRequestCopyWith<$Res> {
  _$CustomLintRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CustomLintRequestAnalyzerPluginRequestCopyWith<$Res>
    implements $CustomLintRequestCopyWith<$Res> {
  factory _$$CustomLintRequestAnalyzerPluginRequestCopyWith(
          _$CustomLintRequestAnalyzerPluginRequest value,
          $Res Function(_$CustomLintRequestAnalyzerPluginRequest) then) =
      __$$CustomLintRequestAnalyzerPluginRequestCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Request request, String id});
}

/// @nodoc
class __$$CustomLintRequestAnalyzerPluginRequestCopyWithImpl<$Res>
    extends _$CustomLintRequestCopyWithImpl<$Res,
        _$CustomLintRequestAnalyzerPluginRequest>
    implements _$$CustomLintRequestAnalyzerPluginRequestCopyWith<$Res> {
  __$$CustomLintRequestAnalyzerPluginRequestCopyWithImpl(
      _$CustomLintRequestAnalyzerPluginRequest _value,
      $Res Function(_$CustomLintRequestAnalyzerPluginRequest) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? request = null,
    Object? id = null,
  }) {
    return _then(_$CustomLintRequestAnalyzerPluginRequest(
      null == request
          ? _value.request
          : request // ignore: cast_nullable_to_non_nullable
              as Request,
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CustomLintRequestAnalyzerPluginRequest
    implements CustomLintRequestAnalyzerPluginRequest {
  _$CustomLintRequestAnalyzerPluginRequest(this.request,
      {required this.id, final String? $type})
      : $type = $type ?? 'analyzerPluginRequest';

  factory _$CustomLintRequestAnalyzerPluginRequest.fromJson(
          Map<String, dynamic> json) =>
      _$$CustomLintRequestAnalyzerPluginRequestFromJson(json);

  @override
  final Request request;
  @override
  final String id;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'CustomLintRequest.analyzerPluginRequest(request: $request, id: $id)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomLintRequestAnalyzerPluginRequest &&
            (identical(other.request, request) || other.request == request) &&
            (identical(other.id, id) || other.id == id));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, request, id);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CustomLintRequestAnalyzerPluginRequestCopyWith<
          _$CustomLintRequestAnalyzerPluginRequest>
      get copyWith => __$$CustomLintRequestAnalyzerPluginRequestCopyWithImpl<
          _$CustomLintRequestAnalyzerPluginRequest>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Request request, String id) analyzerPluginRequest,
    required TResult Function(String id, bool reload) awaitAnalysisDone,
    required TResult Function(String id) listLintRules,
    required TResult Function(String id) ping,
  }) {
    return analyzerPluginRequest(request, id);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Request request, String id)? analyzerPluginRequest,
    TResult? Function(String id, bool reload)? awaitAnalysisDone,
    TResult? Function(String id)? listLintRules,
    TResult? Function(String id)? ping,
  }) {
    return analyzerPluginRequest?.call(request, id);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Request request, String id)? analyzerPluginRequest,
    TResult Function(String id, bool reload)? awaitAnalysisDone,
    TResult Function(String id)? listLintRules,
    TResult Function(String id)? ping,
    required TResult orElse(),
  }) {
    if (analyzerPluginRequest != null) {
      return analyzerPluginRequest(request, id);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(CustomLintRequestAnalyzerPluginRequest value)
        analyzerPluginRequest,
    required TResult Function(CustomLintRequestAwaitAnalysisDone value)
        awaitAnalysisDone,
    required TResult Function(CustomLintRequestLintRules value) listLintRules,
    required TResult Function(CustomLintRequestPing value) ping,
  }) {
    return analyzerPluginRequest(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(CustomLintRequestAnalyzerPluginRequest value)?
        analyzerPluginRequest,
    TResult? Function(CustomLintRequestAwaitAnalysisDone value)?
        awaitAnalysisDone,
    TResult? Function(CustomLintRequestLintRules value)? listLintRules,
    TResult? Function(CustomLintRequestPing value)? ping,
  }) {
    return analyzerPluginRequest?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(CustomLintRequestAnalyzerPluginRequest value)?
        analyzerPluginRequest,
    TResult Function(CustomLintRequestAwaitAnalysisDone value)?
        awaitAnalysisDone,
    TResult Function(CustomLintRequestLintRules value)? listLintRules,
    TResult Function(CustomLintRequestPing value)? ping,
    required TResult orElse(),
  }) {
    if (analyzerPluginRequest != null) {
      return analyzerPluginRequest(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$CustomLintRequestAnalyzerPluginRequestToJson(
      this,
    );
  }
}

abstract class CustomLintRequestAnalyzerPluginRequest
    implements CustomLintRequest {
  factory CustomLintRequestAnalyzerPluginRequest(final Request request,
      {required final String id}) = _$CustomLintRequestAnalyzerPluginRequest;

  factory CustomLintRequestAnalyzerPluginRequest.fromJson(
          Map<String, dynamic> json) =
      _$CustomLintRequestAnalyzerPluginRequest.fromJson;

  Request get request;
  @override
  String get id;
  @override
  @JsonKey(ignore: true)
  _$$CustomLintRequestAnalyzerPluginRequestCopyWith<
          _$CustomLintRequestAnalyzerPluginRequest>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$CustomLintRequestAwaitAnalysisDoneCopyWith<$Res>
    implements $CustomLintRequestCopyWith<$Res> {
  factory _$$CustomLintRequestAwaitAnalysisDoneCopyWith(
          _$CustomLintRequestAwaitAnalysisDone value,
          $Res Function(_$CustomLintRequestAwaitAnalysisDone) then) =
      __$$CustomLintRequestAwaitAnalysisDoneCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, bool reload});
}

/// @nodoc
class __$$CustomLintRequestAwaitAnalysisDoneCopyWithImpl<$Res>
    extends _$CustomLintRequestCopyWithImpl<$Res,
        _$CustomLintRequestAwaitAnalysisDone>
    implements _$$CustomLintRequestAwaitAnalysisDoneCopyWith<$Res> {
  __$$CustomLintRequestAwaitAnalysisDoneCopyWithImpl(
      _$CustomLintRequestAwaitAnalysisDone _value,
      $Res Function(_$CustomLintRequestAwaitAnalysisDone) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? reload = null,
  }) {
    return _then(_$CustomLintRequestAwaitAnalysisDone(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      reload: null == reload
          ? _value.reload
          : reload // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CustomLintRequestAwaitAnalysisDone
    implements CustomLintRequestAwaitAnalysisDone {
  _$CustomLintRequestAwaitAnalysisDone(
      {required this.id, required this.reload, final String? $type})
      : $type = $type ?? 'awaitAnalysisDone';

  factory _$CustomLintRequestAwaitAnalysisDone.fromJson(
          Map<String, dynamic> json) =>
      _$$CustomLintRequestAwaitAnalysisDoneFromJson(json);

  @override
  final String id;
  @override
  final bool reload;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'CustomLintRequest.awaitAnalysisDone(id: $id, reload: $reload)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomLintRequestAwaitAnalysisDone &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.reload, reload) || other.reload == reload));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, reload);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CustomLintRequestAwaitAnalysisDoneCopyWith<
          _$CustomLintRequestAwaitAnalysisDone>
      get copyWith => __$$CustomLintRequestAwaitAnalysisDoneCopyWithImpl<
          _$CustomLintRequestAwaitAnalysisDone>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Request request, String id) analyzerPluginRequest,
    required TResult Function(String id, bool reload) awaitAnalysisDone,
    required TResult Function(String id) listLintRules,
    required TResult Function(String id) ping,
  }) {
    return awaitAnalysisDone(id, reload);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Request request, String id)? analyzerPluginRequest,
    TResult? Function(String id, bool reload)? awaitAnalysisDone,
    TResult? Function(String id)? listLintRules,
    TResult? Function(String id)? ping,
  }) {
    return awaitAnalysisDone?.call(id, reload);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Request request, String id)? analyzerPluginRequest,
    TResult Function(String id, bool reload)? awaitAnalysisDone,
    TResult Function(String id)? listLintRules,
    TResult Function(String id)? ping,
    required TResult orElse(),
  }) {
    if (awaitAnalysisDone != null) {
      return awaitAnalysisDone(id, reload);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(CustomLintRequestAnalyzerPluginRequest value)
        analyzerPluginRequest,
    required TResult Function(CustomLintRequestAwaitAnalysisDone value)
        awaitAnalysisDone,
    required TResult Function(CustomLintRequestLintRules value) listLintRules,
    required TResult Function(CustomLintRequestPing value) ping,
  }) {
    return awaitAnalysisDone(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(CustomLintRequestAnalyzerPluginRequest value)?
        analyzerPluginRequest,
    TResult? Function(CustomLintRequestAwaitAnalysisDone value)?
        awaitAnalysisDone,
    TResult? Function(CustomLintRequestLintRules value)? listLintRules,
    TResult? Function(CustomLintRequestPing value)? ping,
  }) {
    return awaitAnalysisDone?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(CustomLintRequestAnalyzerPluginRequest value)?
        analyzerPluginRequest,
    TResult Function(CustomLintRequestAwaitAnalysisDone value)?
        awaitAnalysisDone,
    TResult Function(CustomLintRequestLintRules value)? listLintRules,
    TResult Function(CustomLintRequestPing value)? ping,
    required TResult orElse(),
  }) {
    if (awaitAnalysisDone != null) {
      return awaitAnalysisDone(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$CustomLintRequestAwaitAnalysisDoneToJson(
      this,
    );
  }
}

abstract class CustomLintRequestAwaitAnalysisDone implements CustomLintRequest {
  factory CustomLintRequestAwaitAnalysisDone(
      {required final String id,
      required final bool reload}) = _$CustomLintRequestAwaitAnalysisDone;

  factory CustomLintRequestAwaitAnalysisDone.fromJson(
          Map<String, dynamic> json) =
      _$CustomLintRequestAwaitAnalysisDone.fromJson;

  @override
  String get id;
  bool get reload;
  @override
  @JsonKey(ignore: true)
  _$$CustomLintRequestAwaitAnalysisDoneCopyWith<
          _$CustomLintRequestAwaitAnalysisDone>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$CustomLintRequestLintRulesCopyWith<$Res>
    implements $CustomLintRequestCopyWith<$Res> {
  factory _$$CustomLintRequestLintRulesCopyWith(
          _$CustomLintRequestLintRules value,
          $Res Function(_$CustomLintRequestLintRules) then) =
      __$$CustomLintRequestLintRulesCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id});
}

/// @nodoc
class __$$CustomLintRequestLintRulesCopyWithImpl<$Res>
    extends _$CustomLintRequestCopyWithImpl<$Res, _$CustomLintRequestLintRules>
    implements _$$CustomLintRequestLintRulesCopyWith<$Res> {
  __$$CustomLintRequestLintRulesCopyWithImpl(
      _$CustomLintRequestLintRules _value,
      $Res Function(_$CustomLintRequestLintRules) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
  }) {
    return _then(_$CustomLintRequestLintRules(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CustomLintRequestLintRules implements CustomLintRequestLintRules {
  _$CustomLintRequestLintRules({required this.id, final String? $type})
      : $type = $type ?? 'listLintRules';

  factory _$CustomLintRequestLintRules.fromJson(Map<String, dynamic> json) =>
      _$$CustomLintRequestLintRulesFromJson(json);

  @override
  final String id;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'CustomLintRequest.listLintRules(id: $id)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomLintRequestLintRules &&
            (identical(other.id, id) || other.id == id));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CustomLintRequestLintRulesCopyWith<_$CustomLintRequestLintRules>
      get copyWith => __$$CustomLintRequestLintRulesCopyWithImpl<
          _$CustomLintRequestLintRules>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Request request, String id) analyzerPluginRequest,
    required TResult Function(String id, bool reload) awaitAnalysisDone,
    required TResult Function(String id) listLintRules,
    required TResult Function(String id) ping,
  }) {
    return listLintRules(id);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Request request, String id)? analyzerPluginRequest,
    TResult? Function(String id, bool reload)? awaitAnalysisDone,
    TResult? Function(String id)? listLintRules,
    TResult? Function(String id)? ping,
  }) {
    return listLintRules?.call(id);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Request request, String id)? analyzerPluginRequest,
    TResult Function(String id, bool reload)? awaitAnalysisDone,
    TResult Function(String id)? listLintRules,
    TResult Function(String id)? ping,
    required TResult orElse(),
  }) {
    if (listLintRules != null) {
      return listLintRules(id);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(CustomLintRequestAnalyzerPluginRequest value)
        analyzerPluginRequest,
    required TResult Function(CustomLintRequestAwaitAnalysisDone value)
        awaitAnalysisDone,
    required TResult Function(CustomLintRequestLintRules value) listLintRules,
    required TResult Function(CustomLintRequestPing value) ping,
  }) {
    return listLintRules(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(CustomLintRequestAnalyzerPluginRequest value)?
        analyzerPluginRequest,
    TResult? Function(CustomLintRequestAwaitAnalysisDone value)?
        awaitAnalysisDone,
    TResult? Function(CustomLintRequestLintRules value)? listLintRules,
    TResult? Function(CustomLintRequestPing value)? ping,
  }) {
    return listLintRules?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(CustomLintRequestAnalyzerPluginRequest value)?
        analyzerPluginRequest,
    TResult Function(CustomLintRequestAwaitAnalysisDone value)?
        awaitAnalysisDone,
    TResult Function(CustomLintRequestLintRules value)? listLintRules,
    TResult Function(CustomLintRequestPing value)? ping,
    required TResult orElse(),
  }) {
    if (listLintRules != null) {
      return listLintRules(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$CustomLintRequestLintRulesToJson(
      this,
    );
  }
}

abstract class CustomLintRequestLintRules implements CustomLintRequest {
  factory CustomLintRequestLintRules({required final String id}) =
      _$CustomLintRequestLintRules;

  factory CustomLintRequestLintRules.fromJson(Map<String, dynamic> json) =
      _$CustomLintRequestLintRules.fromJson;

  @override
  String get id;
  @override
  @JsonKey(ignore: true)
  _$$CustomLintRequestLintRulesCopyWith<_$CustomLintRequestLintRules>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$CustomLintRequestPingCopyWith<$Res>
    implements $CustomLintRequestCopyWith<$Res> {
  factory _$$CustomLintRequestPingCopyWith(_$CustomLintRequestPing value,
          $Res Function(_$CustomLintRequestPing) then) =
      __$$CustomLintRequestPingCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id});
}

/// @nodoc
class __$$CustomLintRequestPingCopyWithImpl<$Res>
    extends _$CustomLintRequestCopyWithImpl<$Res, _$CustomLintRequestPing>
    implements _$$CustomLintRequestPingCopyWith<$Res> {
  __$$CustomLintRequestPingCopyWithImpl(_$CustomLintRequestPing _value,
      $Res Function(_$CustomLintRequestPing) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
  }) {
    return _then(_$CustomLintRequestPing(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CustomLintRequestPing implements CustomLintRequestPing {
  _$CustomLintRequestPing({required this.id, final String? $type})
      : $type = $type ?? 'ping';

  factory _$CustomLintRequestPing.fromJson(Map<String, dynamic> json) =>
      _$$CustomLintRequestPingFromJson(json);

  @override
  final String id;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'CustomLintRequest.ping(id: $id)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomLintRequestPing &&
            (identical(other.id, id) || other.id == id));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CustomLintRequestPingCopyWith<_$CustomLintRequestPing> get copyWith =>
      __$$CustomLintRequestPingCopyWithImpl<_$CustomLintRequestPing>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Request request, String id) analyzerPluginRequest,
    required TResult Function(String id, bool reload) awaitAnalysisDone,
    required TResult Function(String id) listLintRules,
    required TResult Function(String id) ping,
  }) {
    return ping(id);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Request request, String id)? analyzerPluginRequest,
    TResult? Function(String id, bool reload)? awaitAnalysisDone,
    TResult? Function(String id)? listLintRules,
    TResult? Function(String id)? ping,
  }) {
    return ping?.call(id);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Request request, String id)? analyzerPluginRequest,
    TResult Function(String id, bool reload)? awaitAnalysisDone,
    TResult Function(String id)? listLintRules,
    TResult Function(String id)? ping,
    required TResult orElse(),
  }) {
    if (ping != null) {
      return ping(id);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(CustomLintRequestAnalyzerPluginRequest value)
        analyzerPluginRequest,
    required TResult Function(CustomLintRequestAwaitAnalysisDone value)
        awaitAnalysisDone,
    required TResult Function(CustomLintRequestLintRules value) listLintRules,
    required TResult Function(CustomLintRequestPing value) ping,
  }) {
    return ping(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(CustomLintRequestAnalyzerPluginRequest value)?
        analyzerPluginRequest,
    TResult? Function(CustomLintRequestAwaitAnalysisDone value)?
        awaitAnalysisDone,
    TResult? Function(CustomLintRequestLintRules value)? listLintRules,
    TResult? Function(CustomLintRequestPing value)? ping,
  }) {
    return ping?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(CustomLintRequestAnalyzerPluginRequest value)?
        analyzerPluginRequest,
    TResult Function(CustomLintRequestAwaitAnalysisDone value)?
        awaitAnalysisDone,
    TResult Function(CustomLintRequestLintRules value)? listLintRules,
    TResult Function(CustomLintRequestPing value)? ping,
    required TResult orElse(),
  }) {
    if (ping != null) {
      return ping(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$CustomLintRequestPingToJson(
      this,
    );
  }
}

abstract class CustomLintRequestPing implements CustomLintRequest {
  factory CustomLintRequestPing({required final String id}) =
      _$CustomLintRequestPing;

  factory CustomLintRequestPing.fromJson(Map<String, dynamic> json) =
      _$CustomLintRequestPing.fromJson;

  @override
  String get id;
  @override
  @JsonKey(ignore: true)
  _$$CustomLintRequestPingCopyWith<_$CustomLintRequestPing> get copyWith =>
      throw _privateConstructorUsedError;
}

LintRuleMeta _$LintRuleMetaFromJson(Map<String, dynamic> json) {
  return _LintRuleMeta.fromJson(json);
}

/// @nodoc
mixin _$LintRuleMeta {
  /// The name of the plugin that defined this lint rule.
  String get pluginName => throw _privateConstructorUsedError;

  /// The error code that the lint rule might emit.
  String get code => throw _privateConstructorUsedError;

  /// General information about the lint rule.
  String? get description => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $LintRuleMetaCopyWith<LintRuleMeta> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LintRuleMetaCopyWith<$Res> {
  factory $LintRuleMetaCopyWith(
          LintRuleMeta value, $Res Function(LintRuleMeta) then) =
      _$LintRuleMetaCopyWithImpl<$Res, LintRuleMeta>;
  @useResult
  $Res call({String pluginName, String code, String? description});
}

/// @nodoc
class _$LintRuleMetaCopyWithImpl<$Res, $Val extends LintRuleMeta>
    implements $LintRuleMetaCopyWith<$Res> {
  _$LintRuleMetaCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pluginName = null,
    Object? code = null,
    Object? description = freezed,
  }) {
    return _then(_value.copyWith(
      pluginName: null == pluginName
          ? _value.pluginName
          : pluginName // ignore: cast_nullable_to_non_nullable
              as String,
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_LintRuleMetaCopyWith<$Res>
    implements $LintRuleMetaCopyWith<$Res> {
  factory _$$_LintRuleMetaCopyWith(
          _$_LintRuleMeta value, $Res Function(_$_LintRuleMeta) then) =
      __$$_LintRuleMetaCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String pluginName, String code, String? description});
}

/// @nodoc
class __$$_LintRuleMetaCopyWithImpl<$Res>
    extends _$LintRuleMetaCopyWithImpl<$Res, _$_LintRuleMeta>
    implements _$$_LintRuleMetaCopyWith<$Res> {
  __$$_LintRuleMetaCopyWithImpl(
      _$_LintRuleMeta _value, $Res Function(_$_LintRuleMeta) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pluginName = null,
    Object? code = null,
    Object? description = freezed,
  }) {
    return _then(_$_LintRuleMeta(
      pluginName: null == pluginName
          ? _value.pluginName
          : pluginName // ignore: cast_nullable_to_non_nullable
              as String,
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_LintRuleMeta implements _LintRuleMeta {
  _$_LintRuleMeta(
      {required this.pluginName,
      required this.code,
      required this.description});

  factory _$_LintRuleMeta.fromJson(Map<String, dynamic> json) =>
      _$$_LintRuleMetaFromJson(json);

  /// The name of the plugin that defined this lint rule.
  @override
  final String pluginName;

  /// The error code that the lint rule might emit.
  @override
  final String code;

  /// General information about the lint rule.
  @override
  final String? description;

  @override
  String toString() {
    return 'LintRuleMeta(pluginName: $pluginName, code: $code, description: $description)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_LintRuleMeta &&
            (identical(other.pluginName, pluginName) ||
                other.pluginName == pluginName) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, pluginName, code, description);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_LintRuleMetaCopyWith<_$_LintRuleMeta> get copyWith =>
      __$$_LintRuleMetaCopyWithImpl<_$_LintRuleMeta>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_LintRuleMetaToJson(
      this,
    );
  }
}

abstract class _LintRuleMeta implements LintRuleMeta {
  factory _LintRuleMeta(
      {required final String pluginName,
      required final String code,
      required final String? description}) = _$_LintRuleMeta;

  factory _LintRuleMeta.fromJson(Map<String, dynamic> json) =
      _$_LintRuleMeta.fromJson;

  @override

  /// The name of the plugin that defined this lint rule.
  String get pluginName;
  @override

  /// The error code that the lint rule might emit.
  String get code;
  @override

  /// General information about the lint rule.
  String? get description;
  @override
  @JsonKey(ignore: true)
  _$$_LintRuleMetaCopyWith<_$_LintRuleMeta> get copyWith =>
      throw _privateConstructorUsedError;
}

CustomLintResponse _$CustomLintResponseFromJson(Map<String, dynamic> json) {
  switch (json['runtimeType']) {
    case 'analyzerPluginResponse':
      return CustomLintResponseAnalyzerPluginResponse.fromJson(json);
    case 'awaitAnalysisDone':
      return CustomLintResponseAwaitAnalysisDone.fromJson(json);
    case 'listLintRules':
      return CustomLintResponseLintRules.fromJson(json);
    case 'pong':
      return CustomLintResponsePong.fromJson(json);
    case 'error':
      return CustomLintResponseError.fromJson(json);

    default:
      throw CheckedFromJsonException(json, 'runtimeType', 'CustomLintResponse',
          'Invalid union type "${json['runtimeType']}"!');
  }
}

/// @nodoc
mixin _$CustomLintResponse {
  String get id => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Response response, String id)
        analyzerPluginResponse,
    required TResult Function(String id) awaitAnalysisDone,
    required TResult Function(String id, List<LintRuleMeta> lintRules)
        listLintRules,
    required TResult Function(String id) pong,
    required TResult Function(String id, String message, String stackTrace)
        error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Response response, String id)? analyzerPluginResponse,
    TResult? Function(String id)? awaitAnalysisDone,
    TResult? Function(String id, List<LintRuleMeta> lintRules)? listLintRules,
    TResult? Function(String id)? pong,
    TResult? Function(String id, String message, String stackTrace)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Response response, String id)? analyzerPluginResponse,
    TResult Function(String id)? awaitAnalysisDone,
    TResult Function(String id, List<LintRuleMeta> lintRules)? listLintRules,
    TResult Function(String id)? pong,
    TResult Function(String id, String message, String stackTrace)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(CustomLintResponseAnalyzerPluginResponse value)
        analyzerPluginResponse,
    required TResult Function(CustomLintResponseAwaitAnalysisDone value)
        awaitAnalysisDone,
    required TResult Function(CustomLintResponseLintRules value) listLintRules,
    required TResult Function(CustomLintResponsePong value) pong,
    required TResult Function(CustomLintResponseError value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(CustomLintResponseAnalyzerPluginResponse value)?
        analyzerPluginResponse,
    TResult? Function(CustomLintResponseAwaitAnalysisDone value)?
        awaitAnalysisDone,
    TResult? Function(CustomLintResponseLintRules value)? listLintRules,
    TResult? Function(CustomLintResponsePong value)? pong,
    TResult? Function(CustomLintResponseError value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(CustomLintResponseAnalyzerPluginResponse value)?
        analyzerPluginResponse,
    TResult Function(CustomLintResponseAwaitAnalysisDone value)?
        awaitAnalysisDone,
    TResult Function(CustomLintResponseLintRules value)? listLintRules,
    TResult Function(CustomLintResponsePong value)? pong,
    TResult Function(CustomLintResponseError value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CustomLintResponseCopyWith<CustomLintResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CustomLintResponseCopyWith<$Res> {
  factory $CustomLintResponseCopyWith(
          CustomLintResponse value, $Res Function(CustomLintResponse) then) =
      _$CustomLintResponseCopyWithImpl<$Res, CustomLintResponse>;
  @useResult
  $Res call({String id});
}

/// @nodoc
class _$CustomLintResponseCopyWithImpl<$Res, $Val extends CustomLintResponse>
    implements $CustomLintResponseCopyWith<$Res> {
  _$CustomLintResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CustomLintResponseAnalyzerPluginResponseCopyWith<$Res>
    implements $CustomLintResponseCopyWith<$Res> {
  factory _$$CustomLintResponseAnalyzerPluginResponseCopyWith(
          _$CustomLintResponseAnalyzerPluginResponse value,
          $Res Function(_$CustomLintResponseAnalyzerPluginResponse) then) =
      __$$CustomLintResponseAnalyzerPluginResponseCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Response response, String id});
}

/// @nodoc
class __$$CustomLintResponseAnalyzerPluginResponseCopyWithImpl<$Res>
    extends _$CustomLintResponseCopyWithImpl<$Res,
        _$CustomLintResponseAnalyzerPluginResponse>
    implements _$$CustomLintResponseAnalyzerPluginResponseCopyWith<$Res> {
  __$$CustomLintResponseAnalyzerPluginResponseCopyWithImpl(
      _$CustomLintResponseAnalyzerPluginResponse _value,
      $Res Function(_$CustomLintResponseAnalyzerPluginResponse) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? response = null,
    Object? id = null,
  }) {
    return _then(_$CustomLintResponseAnalyzerPluginResponse(
      null == response
          ? _value.response
          : response // ignore: cast_nullable_to_non_nullable
              as Response,
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CustomLintResponseAnalyzerPluginResponse
    implements CustomLintResponseAnalyzerPluginResponse {
  _$CustomLintResponseAnalyzerPluginResponse(this.response,
      {required this.id, final String? $type})
      : $type = $type ?? 'analyzerPluginResponse';

  factory _$CustomLintResponseAnalyzerPluginResponse.fromJson(
          Map<String, dynamic> json) =>
      _$$CustomLintResponseAnalyzerPluginResponseFromJson(json);

  @override
  final Response response;
  @override
  final String id;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'CustomLintResponse.analyzerPluginResponse(response: $response, id: $id)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomLintResponseAnalyzerPluginResponse &&
            (identical(other.response, response) ||
                other.response == response) &&
            (identical(other.id, id) || other.id == id));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, response, id);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CustomLintResponseAnalyzerPluginResponseCopyWith<
          _$CustomLintResponseAnalyzerPluginResponse>
      get copyWith => __$$CustomLintResponseAnalyzerPluginResponseCopyWithImpl<
          _$CustomLintResponseAnalyzerPluginResponse>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Response response, String id)
        analyzerPluginResponse,
    required TResult Function(String id) awaitAnalysisDone,
    required TResult Function(String id, List<LintRuleMeta> lintRules)
        listLintRules,
    required TResult Function(String id) pong,
    required TResult Function(String id, String message, String stackTrace)
        error,
  }) {
    return analyzerPluginResponse(response, id);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Response response, String id)? analyzerPluginResponse,
    TResult? Function(String id)? awaitAnalysisDone,
    TResult? Function(String id, List<LintRuleMeta> lintRules)? listLintRules,
    TResult? Function(String id)? pong,
    TResult? Function(String id, String message, String stackTrace)? error,
  }) {
    return analyzerPluginResponse?.call(response, id);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Response response, String id)? analyzerPluginResponse,
    TResult Function(String id)? awaitAnalysisDone,
    TResult Function(String id, List<LintRuleMeta> lintRules)? listLintRules,
    TResult Function(String id)? pong,
    TResult Function(String id, String message, String stackTrace)? error,
    required TResult orElse(),
  }) {
    if (analyzerPluginResponse != null) {
      return analyzerPluginResponse(response, id);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(CustomLintResponseAnalyzerPluginResponse value)
        analyzerPluginResponse,
    required TResult Function(CustomLintResponseAwaitAnalysisDone value)
        awaitAnalysisDone,
    required TResult Function(CustomLintResponseLintRules value) listLintRules,
    required TResult Function(CustomLintResponsePong value) pong,
    required TResult Function(CustomLintResponseError value) error,
  }) {
    return analyzerPluginResponse(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(CustomLintResponseAnalyzerPluginResponse value)?
        analyzerPluginResponse,
    TResult? Function(CustomLintResponseAwaitAnalysisDone value)?
        awaitAnalysisDone,
    TResult? Function(CustomLintResponseLintRules value)? listLintRules,
    TResult? Function(CustomLintResponsePong value)? pong,
    TResult? Function(CustomLintResponseError value)? error,
  }) {
    return analyzerPluginResponse?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(CustomLintResponseAnalyzerPluginResponse value)?
        analyzerPluginResponse,
    TResult Function(CustomLintResponseAwaitAnalysisDone value)?
        awaitAnalysisDone,
    TResult Function(CustomLintResponseLintRules value)? listLintRules,
    TResult Function(CustomLintResponsePong value)? pong,
    TResult Function(CustomLintResponseError value)? error,
    required TResult orElse(),
  }) {
    if (analyzerPluginResponse != null) {
      return analyzerPluginResponse(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$CustomLintResponseAnalyzerPluginResponseToJson(
      this,
    );
  }
}

abstract class CustomLintResponseAnalyzerPluginResponse
    implements CustomLintResponse {
  factory CustomLintResponseAnalyzerPluginResponse(final Response response,
      {required final String id}) = _$CustomLintResponseAnalyzerPluginResponse;

  factory CustomLintResponseAnalyzerPluginResponse.fromJson(
          Map<String, dynamic> json) =
      _$CustomLintResponseAnalyzerPluginResponse.fromJson;

  Response get response;
  @override
  String get id;
  @override
  @JsonKey(ignore: true)
  _$$CustomLintResponseAnalyzerPluginResponseCopyWith<
          _$CustomLintResponseAnalyzerPluginResponse>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$CustomLintResponseAwaitAnalysisDoneCopyWith<$Res>
    implements $CustomLintResponseCopyWith<$Res> {
  factory _$$CustomLintResponseAwaitAnalysisDoneCopyWith(
          _$CustomLintResponseAwaitAnalysisDone value,
          $Res Function(_$CustomLintResponseAwaitAnalysisDone) then) =
      __$$CustomLintResponseAwaitAnalysisDoneCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id});
}

/// @nodoc
class __$$CustomLintResponseAwaitAnalysisDoneCopyWithImpl<$Res>
    extends _$CustomLintResponseCopyWithImpl<$Res,
        _$CustomLintResponseAwaitAnalysisDone>
    implements _$$CustomLintResponseAwaitAnalysisDoneCopyWith<$Res> {
  __$$CustomLintResponseAwaitAnalysisDoneCopyWithImpl(
      _$CustomLintResponseAwaitAnalysisDone _value,
      $Res Function(_$CustomLintResponseAwaitAnalysisDone) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
  }) {
    return _then(_$CustomLintResponseAwaitAnalysisDone(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CustomLintResponseAwaitAnalysisDone
    implements CustomLintResponseAwaitAnalysisDone {
  _$CustomLintResponseAwaitAnalysisDone({required this.id, final String? $type})
      : $type = $type ?? 'awaitAnalysisDone';

  factory _$CustomLintResponseAwaitAnalysisDone.fromJson(
          Map<String, dynamic> json) =>
      _$$CustomLintResponseAwaitAnalysisDoneFromJson(json);

  @override
  final String id;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'CustomLintResponse.awaitAnalysisDone(id: $id)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomLintResponseAwaitAnalysisDone &&
            (identical(other.id, id) || other.id == id));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CustomLintResponseAwaitAnalysisDoneCopyWith<
          _$CustomLintResponseAwaitAnalysisDone>
      get copyWith => __$$CustomLintResponseAwaitAnalysisDoneCopyWithImpl<
          _$CustomLintResponseAwaitAnalysisDone>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Response response, String id)
        analyzerPluginResponse,
    required TResult Function(String id) awaitAnalysisDone,
    required TResult Function(String id, List<LintRuleMeta> lintRules)
        listLintRules,
    required TResult Function(String id) pong,
    required TResult Function(String id, String message, String stackTrace)
        error,
  }) {
    return awaitAnalysisDone(id);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Response response, String id)? analyzerPluginResponse,
    TResult? Function(String id)? awaitAnalysisDone,
    TResult? Function(String id, List<LintRuleMeta> lintRules)? listLintRules,
    TResult? Function(String id)? pong,
    TResult? Function(String id, String message, String stackTrace)? error,
  }) {
    return awaitAnalysisDone?.call(id);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Response response, String id)? analyzerPluginResponse,
    TResult Function(String id)? awaitAnalysisDone,
    TResult Function(String id, List<LintRuleMeta> lintRules)? listLintRules,
    TResult Function(String id)? pong,
    TResult Function(String id, String message, String stackTrace)? error,
    required TResult orElse(),
  }) {
    if (awaitAnalysisDone != null) {
      return awaitAnalysisDone(id);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(CustomLintResponseAnalyzerPluginResponse value)
        analyzerPluginResponse,
    required TResult Function(CustomLintResponseAwaitAnalysisDone value)
        awaitAnalysisDone,
    required TResult Function(CustomLintResponseLintRules value) listLintRules,
    required TResult Function(CustomLintResponsePong value) pong,
    required TResult Function(CustomLintResponseError value) error,
  }) {
    return awaitAnalysisDone(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(CustomLintResponseAnalyzerPluginResponse value)?
        analyzerPluginResponse,
    TResult? Function(CustomLintResponseAwaitAnalysisDone value)?
        awaitAnalysisDone,
    TResult? Function(CustomLintResponseLintRules value)? listLintRules,
    TResult? Function(CustomLintResponsePong value)? pong,
    TResult? Function(CustomLintResponseError value)? error,
  }) {
    return awaitAnalysisDone?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(CustomLintResponseAnalyzerPluginResponse value)?
        analyzerPluginResponse,
    TResult Function(CustomLintResponseAwaitAnalysisDone value)?
        awaitAnalysisDone,
    TResult Function(CustomLintResponseLintRules value)? listLintRules,
    TResult Function(CustomLintResponsePong value)? pong,
    TResult Function(CustomLintResponseError value)? error,
    required TResult orElse(),
  }) {
    if (awaitAnalysisDone != null) {
      return awaitAnalysisDone(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$CustomLintResponseAwaitAnalysisDoneToJson(
      this,
    );
  }
}

abstract class CustomLintResponseAwaitAnalysisDone
    implements CustomLintResponse {
  factory CustomLintResponseAwaitAnalysisDone({required final String id}) =
      _$CustomLintResponseAwaitAnalysisDone;

  factory CustomLintResponseAwaitAnalysisDone.fromJson(
          Map<String, dynamic> json) =
      _$CustomLintResponseAwaitAnalysisDone.fromJson;

  @override
  String get id;
  @override
  @JsonKey(ignore: true)
  _$$CustomLintResponseAwaitAnalysisDoneCopyWith<
          _$CustomLintResponseAwaitAnalysisDone>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$CustomLintResponseLintRulesCopyWith<$Res>
    implements $CustomLintResponseCopyWith<$Res> {
  factory _$$CustomLintResponseLintRulesCopyWith(
          _$CustomLintResponseLintRules value,
          $Res Function(_$CustomLintResponseLintRules) then) =
      __$$CustomLintResponseLintRulesCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, List<LintRuleMeta> lintRules});
}

/// @nodoc
class __$$CustomLintResponseLintRulesCopyWithImpl<$Res>
    extends _$CustomLintResponseCopyWithImpl<$Res,
        _$CustomLintResponseLintRules>
    implements _$$CustomLintResponseLintRulesCopyWith<$Res> {
  __$$CustomLintResponseLintRulesCopyWithImpl(
      _$CustomLintResponseLintRules _value,
      $Res Function(_$CustomLintResponseLintRules) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? lintRules = null,
  }) {
    return _then(_$CustomLintResponseLintRules(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      lintRules: null == lintRules
          ? _value._lintRules
          : lintRules // ignore: cast_nullable_to_non_nullable
              as List<LintRuleMeta>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CustomLintResponseLintRules implements CustomLintResponseLintRules {
  _$CustomLintResponseLintRules(
      {required this.id,
      required final List<LintRuleMeta> lintRules,
      final String? $type})
      : _lintRules = lintRules,
        $type = $type ?? 'listLintRules';

  factory _$CustomLintResponseLintRules.fromJson(Map<String, dynamic> json) =>
      _$$CustomLintResponseLintRulesFromJson(json);

  @override
  final String id;
  final List<LintRuleMeta> _lintRules;
  @override
  List<LintRuleMeta> get lintRules {
    if (_lintRules is EqualUnmodifiableListView) return _lintRules;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_lintRules);
  }

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'CustomLintResponse.listLintRules(id: $id, lintRules: $lintRules)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomLintResponseLintRules &&
            (identical(other.id, id) || other.id == id) &&
            const DeepCollectionEquality()
                .equals(other._lintRules, _lintRules));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, const DeepCollectionEquality().hash(_lintRules));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CustomLintResponseLintRulesCopyWith<_$CustomLintResponseLintRules>
      get copyWith => __$$CustomLintResponseLintRulesCopyWithImpl<
          _$CustomLintResponseLintRules>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Response response, String id)
        analyzerPluginResponse,
    required TResult Function(String id) awaitAnalysisDone,
    required TResult Function(String id, List<LintRuleMeta> lintRules)
        listLintRules,
    required TResult Function(String id) pong,
    required TResult Function(String id, String message, String stackTrace)
        error,
  }) {
    return listLintRules(id, lintRules);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Response response, String id)? analyzerPluginResponse,
    TResult? Function(String id)? awaitAnalysisDone,
    TResult? Function(String id, List<LintRuleMeta> lintRules)? listLintRules,
    TResult? Function(String id)? pong,
    TResult? Function(String id, String message, String stackTrace)? error,
  }) {
    return listLintRules?.call(id, lintRules);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Response response, String id)? analyzerPluginResponse,
    TResult Function(String id)? awaitAnalysisDone,
    TResult Function(String id, List<LintRuleMeta> lintRules)? listLintRules,
    TResult Function(String id)? pong,
    TResult Function(String id, String message, String stackTrace)? error,
    required TResult orElse(),
  }) {
    if (listLintRules != null) {
      return listLintRules(id, lintRules);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(CustomLintResponseAnalyzerPluginResponse value)
        analyzerPluginResponse,
    required TResult Function(CustomLintResponseAwaitAnalysisDone value)
        awaitAnalysisDone,
    required TResult Function(CustomLintResponseLintRules value) listLintRules,
    required TResult Function(CustomLintResponsePong value) pong,
    required TResult Function(CustomLintResponseError value) error,
  }) {
    return listLintRules(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(CustomLintResponseAnalyzerPluginResponse value)?
        analyzerPluginResponse,
    TResult? Function(CustomLintResponseAwaitAnalysisDone value)?
        awaitAnalysisDone,
    TResult? Function(CustomLintResponseLintRules value)? listLintRules,
    TResult? Function(CustomLintResponsePong value)? pong,
    TResult? Function(CustomLintResponseError value)? error,
  }) {
    return listLintRules?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(CustomLintResponseAnalyzerPluginResponse value)?
        analyzerPluginResponse,
    TResult Function(CustomLintResponseAwaitAnalysisDone value)?
        awaitAnalysisDone,
    TResult Function(CustomLintResponseLintRules value)? listLintRules,
    TResult Function(CustomLintResponsePong value)? pong,
    TResult Function(CustomLintResponseError value)? error,
    required TResult orElse(),
  }) {
    if (listLintRules != null) {
      return listLintRules(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$CustomLintResponseLintRulesToJson(
      this,
    );
  }
}

abstract class CustomLintResponseLintRules implements CustomLintResponse {
  factory CustomLintResponseLintRules(
          {required final String id,
          required final List<LintRuleMeta> lintRules}) =
      _$CustomLintResponseLintRules;

  factory CustomLintResponseLintRules.fromJson(Map<String, dynamic> json) =
      _$CustomLintResponseLintRules.fromJson;

  @override
  String get id;
  List<LintRuleMeta> get lintRules;
  @override
  @JsonKey(ignore: true)
  _$$CustomLintResponseLintRulesCopyWith<_$CustomLintResponseLintRules>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$CustomLintResponsePongCopyWith<$Res>
    implements $CustomLintResponseCopyWith<$Res> {
  factory _$$CustomLintResponsePongCopyWith(_$CustomLintResponsePong value,
          $Res Function(_$CustomLintResponsePong) then) =
      __$$CustomLintResponsePongCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id});
}

/// @nodoc
class __$$CustomLintResponsePongCopyWithImpl<$Res>
    extends _$CustomLintResponseCopyWithImpl<$Res, _$CustomLintResponsePong>
    implements _$$CustomLintResponsePongCopyWith<$Res> {
  __$$CustomLintResponsePongCopyWithImpl(_$CustomLintResponsePong _value,
      $Res Function(_$CustomLintResponsePong) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
  }) {
    return _then(_$CustomLintResponsePong(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CustomLintResponsePong implements CustomLintResponsePong {
  _$CustomLintResponsePong({required this.id, final String? $type})
      : $type = $type ?? 'pong';

  factory _$CustomLintResponsePong.fromJson(Map<String, dynamic> json) =>
      _$$CustomLintResponsePongFromJson(json);

  @override
  final String id;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'CustomLintResponse.pong(id: $id)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomLintResponsePong &&
            (identical(other.id, id) || other.id == id));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CustomLintResponsePongCopyWith<_$CustomLintResponsePong> get copyWith =>
      __$$CustomLintResponsePongCopyWithImpl<_$CustomLintResponsePong>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Response response, String id)
        analyzerPluginResponse,
    required TResult Function(String id) awaitAnalysisDone,
    required TResult Function(String id, List<LintRuleMeta> lintRules)
        listLintRules,
    required TResult Function(String id) pong,
    required TResult Function(String id, String message, String stackTrace)
        error,
  }) {
    return pong(id);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Response response, String id)? analyzerPluginResponse,
    TResult? Function(String id)? awaitAnalysisDone,
    TResult? Function(String id, List<LintRuleMeta> lintRules)? listLintRules,
    TResult? Function(String id)? pong,
    TResult? Function(String id, String message, String stackTrace)? error,
  }) {
    return pong?.call(id);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Response response, String id)? analyzerPluginResponse,
    TResult Function(String id)? awaitAnalysisDone,
    TResult Function(String id, List<LintRuleMeta> lintRules)? listLintRules,
    TResult Function(String id)? pong,
    TResult Function(String id, String message, String stackTrace)? error,
    required TResult orElse(),
  }) {
    if (pong != null) {
      return pong(id);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(CustomLintResponseAnalyzerPluginResponse value)
        analyzerPluginResponse,
    required TResult Function(CustomLintResponseAwaitAnalysisDone value)
        awaitAnalysisDone,
    required TResult Function(CustomLintResponseLintRules value) listLintRules,
    required TResult Function(CustomLintResponsePong value) pong,
    required TResult Function(CustomLintResponseError value) error,
  }) {
    return pong(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(CustomLintResponseAnalyzerPluginResponse value)?
        analyzerPluginResponse,
    TResult? Function(CustomLintResponseAwaitAnalysisDone value)?
        awaitAnalysisDone,
    TResult? Function(CustomLintResponseLintRules value)? listLintRules,
    TResult? Function(CustomLintResponsePong value)? pong,
    TResult? Function(CustomLintResponseError value)? error,
  }) {
    return pong?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(CustomLintResponseAnalyzerPluginResponse value)?
        analyzerPluginResponse,
    TResult Function(CustomLintResponseAwaitAnalysisDone value)?
        awaitAnalysisDone,
    TResult Function(CustomLintResponseLintRules value)? listLintRules,
    TResult Function(CustomLintResponsePong value)? pong,
    TResult Function(CustomLintResponseError value)? error,
    required TResult orElse(),
  }) {
    if (pong != null) {
      return pong(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$CustomLintResponsePongToJson(
      this,
    );
  }
}

abstract class CustomLintResponsePong implements CustomLintResponse {
  factory CustomLintResponsePong({required final String id}) =
      _$CustomLintResponsePong;

  factory CustomLintResponsePong.fromJson(Map<String, dynamic> json) =
      _$CustomLintResponsePong.fromJson;

  @override
  String get id;
  @override
  @JsonKey(ignore: true)
  _$$CustomLintResponsePongCopyWith<_$CustomLintResponsePong> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$CustomLintResponseErrorCopyWith<$Res>
    implements $CustomLintResponseCopyWith<$Res> {
  factory _$$CustomLintResponseErrorCopyWith(_$CustomLintResponseError value,
          $Res Function(_$CustomLintResponseError) then) =
      __$$CustomLintResponseErrorCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String message, String stackTrace});
}

/// @nodoc
class __$$CustomLintResponseErrorCopyWithImpl<$Res>
    extends _$CustomLintResponseCopyWithImpl<$Res, _$CustomLintResponseError>
    implements _$$CustomLintResponseErrorCopyWith<$Res> {
  __$$CustomLintResponseErrorCopyWithImpl(_$CustomLintResponseError _value,
      $Res Function(_$CustomLintResponseError) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? message = null,
    Object? stackTrace = null,
  }) {
    return _then(_$CustomLintResponseError(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      stackTrace: null == stackTrace
          ? _value.stackTrace
          : stackTrace // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CustomLintResponseError implements CustomLintResponseError {
  _$CustomLintResponseError(
      {required this.id,
      required this.message,
      required this.stackTrace,
      final String? $type})
      : $type = $type ?? 'error';

  factory _$CustomLintResponseError.fromJson(Map<String, dynamic> json) =>
      _$$CustomLintResponseErrorFromJson(json);

  @override
  final String id;
  @override
  final String message;
  @override
  final String stackTrace;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'CustomLintResponse.error(id: $id, message: $message, stackTrace: $stackTrace)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomLintResponseError &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.stackTrace, stackTrace) ||
                other.stackTrace == stackTrace));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, message, stackTrace);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CustomLintResponseErrorCopyWith<_$CustomLintResponseError> get copyWith =>
      __$$CustomLintResponseErrorCopyWithImpl<_$CustomLintResponseError>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Response response, String id)
        analyzerPluginResponse,
    required TResult Function(String id) awaitAnalysisDone,
    required TResult Function(String id, List<LintRuleMeta> lintRules)
        listLintRules,
    required TResult Function(String id) pong,
    required TResult Function(String id, String message, String stackTrace)
        error,
  }) {
    return error(id, message, stackTrace);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Response response, String id)? analyzerPluginResponse,
    TResult? Function(String id)? awaitAnalysisDone,
    TResult? Function(String id, List<LintRuleMeta> lintRules)? listLintRules,
    TResult? Function(String id)? pong,
    TResult? Function(String id, String message, String stackTrace)? error,
  }) {
    return error?.call(id, message, stackTrace);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Response response, String id)? analyzerPluginResponse,
    TResult Function(String id)? awaitAnalysisDone,
    TResult Function(String id, List<LintRuleMeta> lintRules)? listLintRules,
    TResult Function(String id)? pong,
    TResult Function(String id, String message, String stackTrace)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(id, message, stackTrace);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(CustomLintResponseAnalyzerPluginResponse value)
        analyzerPluginResponse,
    required TResult Function(CustomLintResponseAwaitAnalysisDone value)
        awaitAnalysisDone,
    required TResult Function(CustomLintResponseLintRules value) listLintRules,
    required TResult Function(CustomLintResponsePong value) pong,
    required TResult Function(CustomLintResponseError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(CustomLintResponseAnalyzerPluginResponse value)?
        analyzerPluginResponse,
    TResult? Function(CustomLintResponseAwaitAnalysisDone value)?
        awaitAnalysisDone,
    TResult? Function(CustomLintResponseLintRules value)? listLintRules,
    TResult? Function(CustomLintResponsePong value)? pong,
    TResult? Function(CustomLintResponseError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(CustomLintResponseAnalyzerPluginResponse value)?
        analyzerPluginResponse,
    TResult Function(CustomLintResponseAwaitAnalysisDone value)?
        awaitAnalysisDone,
    TResult Function(CustomLintResponseLintRules value)? listLintRules,
    TResult Function(CustomLintResponsePong value)? pong,
    TResult Function(CustomLintResponseError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$CustomLintResponseErrorToJson(
      this,
    );
  }
}

abstract class CustomLintResponseError implements CustomLintResponse {
  factory CustomLintResponseError(
      {required final String id,
      required final String message,
      required final String stackTrace}) = _$CustomLintResponseError;

  factory CustomLintResponseError.fromJson(Map<String, dynamic> json) =
      _$CustomLintResponseError.fromJson;

  @override
  String get id;
  String get message;
  String get stackTrace;
  @override
  @JsonKey(ignore: true)
  _$$CustomLintResponseErrorCopyWith<_$CustomLintResponseError> get copyWith =>
      throw _privateConstructorUsedError;
}

CustomLintMessage _$CustomLintMessageFromJson(Map<String, dynamic> json) {
  switch (json['runtimeType']) {
    case 'event':
      return CustomLintMessageEvent.fromJson(json);
    case 'response':
      return CustomLintMessageResponse.fromJson(json);

    default:
      throw CheckedFromJsonException(json, 'runtimeType', 'CustomLintMessage',
          'Invalid union type "${json['runtimeType']}"!');
  }
}

/// @nodoc
mixin _$CustomLintMessage {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(CustomLintEvent event) event,
    required TResult Function(CustomLintResponse response) response,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(CustomLintEvent event)? event,
    TResult? Function(CustomLintResponse response)? response,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(CustomLintEvent event)? event,
    TResult Function(CustomLintResponse response)? response,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(CustomLintMessageEvent value) event,
    required TResult Function(CustomLintMessageResponse value) response,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(CustomLintMessageEvent value)? event,
    TResult? Function(CustomLintMessageResponse value)? response,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(CustomLintMessageEvent value)? event,
    TResult Function(CustomLintMessageResponse value)? response,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CustomLintMessageCopyWith<$Res> {
  factory $CustomLintMessageCopyWith(
          CustomLintMessage value, $Res Function(CustomLintMessage) then) =
      _$CustomLintMessageCopyWithImpl<$Res, CustomLintMessage>;
}

/// @nodoc
class _$CustomLintMessageCopyWithImpl<$Res, $Val extends CustomLintMessage>
    implements $CustomLintMessageCopyWith<$Res> {
  _$CustomLintMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$CustomLintMessageEventCopyWith<$Res> {
  factory _$$CustomLintMessageEventCopyWith(_$CustomLintMessageEvent value,
          $Res Function(_$CustomLintMessageEvent) then) =
      __$$CustomLintMessageEventCopyWithImpl<$Res>;
  @useResult
  $Res call({CustomLintEvent event});

  $CustomLintEventCopyWith<$Res> get event;
}

/// @nodoc
class __$$CustomLintMessageEventCopyWithImpl<$Res>
    extends _$CustomLintMessageCopyWithImpl<$Res, _$CustomLintMessageEvent>
    implements _$$CustomLintMessageEventCopyWith<$Res> {
  __$$CustomLintMessageEventCopyWithImpl(_$CustomLintMessageEvent _value,
      $Res Function(_$CustomLintMessageEvent) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? event = null,
  }) {
    return _then(_$CustomLintMessageEvent(
      null == event
          ? _value.event
          : event // ignore: cast_nullable_to_non_nullable
              as CustomLintEvent,
    ));
  }

  @override
  @pragma('vm:prefer-inline')
  $CustomLintEventCopyWith<$Res> get event {
    return $CustomLintEventCopyWith<$Res>(_value.event, (value) {
      return _then(_value.copyWith(event: value));
    });
  }
}

/// @nodoc
@JsonSerializable()
class _$CustomLintMessageEvent implements CustomLintMessageEvent {
  _$CustomLintMessageEvent(this.event, {final String? $type})
      : $type = $type ?? 'event';

  factory _$CustomLintMessageEvent.fromJson(Map<String, dynamic> json) =>
      _$$CustomLintMessageEventFromJson(json);

  @override
  final CustomLintEvent event;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'CustomLintMessage.event(event: $event)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomLintMessageEvent &&
            (identical(other.event, event) || other.event == event));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, event);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CustomLintMessageEventCopyWith<_$CustomLintMessageEvent> get copyWith =>
      __$$CustomLintMessageEventCopyWithImpl<_$CustomLintMessageEvent>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(CustomLintEvent event) event,
    required TResult Function(CustomLintResponse response) response,
  }) {
    return event(this.event);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(CustomLintEvent event)? event,
    TResult? Function(CustomLintResponse response)? response,
  }) {
    return event?.call(this.event);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(CustomLintEvent event)? event,
    TResult Function(CustomLintResponse response)? response,
    required TResult orElse(),
  }) {
    if (event != null) {
      return event(this.event);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(CustomLintMessageEvent value) event,
    required TResult Function(CustomLintMessageResponse value) response,
  }) {
    return event(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(CustomLintMessageEvent value)? event,
    TResult? Function(CustomLintMessageResponse value)? response,
  }) {
    return event?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(CustomLintMessageEvent value)? event,
    TResult Function(CustomLintMessageResponse value)? response,
    required TResult orElse(),
  }) {
    if (event != null) {
      return event(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$CustomLintMessageEventToJson(
      this,
    );
  }
}

abstract class CustomLintMessageEvent implements CustomLintMessage {
  factory CustomLintMessageEvent(final CustomLintEvent event) =
      _$CustomLintMessageEvent;

  factory CustomLintMessageEvent.fromJson(Map<String, dynamic> json) =
      _$CustomLintMessageEvent.fromJson;

  CustomLintEvent get event;
  @JsonKey(ignore: true)
  _$$CustomLintMessageEventCopyWith<_$CustomLintMessageEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$CustomLintMessageResponseCopyWith<$Res> {
  factory _$$CustomLintMessageResponseCopyWith(
          _$CustomLintMessageResponse value,
          $Res Function(_$CustomLintMessageResponse) then) =
      __$$CustomLintMessageResponseCopyWithImpl<$Res>;
  @useResult
  $Res call({CustomLintResponse response});

  $CustomLintResponseCopyWith<$Res> get response;
}

/// @nodoc
class __$$CustomLintMessageResponseCopyWithImpl<$Res>
    extends _$CustomLintMessageCopyWithImpl<$Res, _$CustomLintMessageResponse>
    implements _$$CustomLintMessageResponseCopyWith<$Res> {
  __$$CustomLintMessageResponseCopyWithImpl(_$CustomLintMessageResponse _value,
      $Res Function(_$CustomLintMessageResponse) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? response = null,
  }) {
    return _then(_$CustomLintMessageResponse(
      null == response
          ? _value.response
          : response // ignore: cast_nullable_to_non_nullable
              as CustomLintResponse,
    ));
  }

  @override
  @pragma('vm:prefer-inline')
  $CustomLintResponseCopyWith<$Res> get response {
    return $CustomLintResponseCopyWith<$Res>(_value.response, (value) {
      return _then(_value.copyWith(response: value));
    });
  }
}

/// @nodoc
@JsonSerializable()
class _$CustomLintMessageResponse implements CustomLintMessageResponse {
  _$CustomLintMessageResponse(this.response, {final String? $type})
      : $type = $type ?? 'response';

  factory _$CustomLintMessageResponse.fromJson(Map<String, dynamic> json) =>
      _$$CustomLintMessageResponseFromJson(json);

  @override
  final CustomLintResponse response;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'CustomLintMessage.response(response: $response)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomLintMessageResponse &&
            (identical(other.response, response) ||
                other.response == response));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, response);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CustomLintMessageResponseCopyWith<_$CustomLintMessageResponse>
      get copyWith => __$$CustomLintMessageResponseCopyWithImpl<
          _$CustomLintMessageResponse>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(CustomLintEvent event) event,
    required TResult Function(CustomLintResponse response) response,
  }) {
    return response(this.response);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(CustomLintEvent event)? event,
    TResult? Function(CustomLintResponse response)? response,
  }) {
    return response?.call(this.response);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(CustomLintEvent event)? event,
    TResult Function(CustomLintResponse response)? response,
    required TResult orElse(),
  }) {
    if (response != null) {
      return response(this.response);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(CustomLintMessageEvent value) event,
    required TResult Function(CustomLintMessageResponse value) response,
  }) {
    return response(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(CustomLintMessageEvent value)? event,
    TResult? Function(CustomLintMessageResponse value)? response,
  }) {
    return response?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(CustomLintMessageEvent value)? event,
    TResult Function(CustomLintMessageResponse value)? response,
    required TResult orElse(),
  }) {
    if (response != null) {
      return response(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$CustomLintMessageResponseToJson(
      this,
    );
  }
}

abstract class CustomLintMessageResponse implements CustomLintMessage {
  factory CustomLintMessageResponse(final CustomLintResponse response) =
      _$CustomLintMessageResponse;

  factory CustomLintMessageResponse.fromJson(Map<String, dynamic> json) =
      _$CustomLintMessageResponse.fromJson;

  CustomLintResponse get response;
  @JsonKey(ignore: true)
  _$$CustomLintMessageResponseCopyWith<_$CustomLintMessageResponse>
      get copyWith => throw _privateConstructorUsedError;
}

CustomLintEvent _$CustomLintEventFromJson(Map<String, dynamic> json) {
  switch (json['runtimeType']) {
    case 'analyzerPluginNotification':
      return CustomLintEventAnalyzerPluginNotification.fromJson(json);
    case 'error':
      return CustomLintEventError.fromJson(json);
    case 'print':
      return CustomLintEventPrint.fromJson(json);

    default:
      throw CheckedFromJsonException(json, 'runtimeType', 'CustomLintEvent',
          'Invalid union type "${json['runtimeType']}"!');
  }
}

/// @nodoc
mixin _$CustomLintEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            @NotificationJsonConverter() Notification notification)
        analyzerPluginNotification,
    required TResult Function(
            String message, String stackTrace, String? pluginName)
        error,
    required TResult Function(String message, String? pluginName) print,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(@NotificationJsonConverter() Notification notification)?
        analyzerPluginNotification,
    TResult? Function(String message, String stackTrace, String? pluginName)?
        error,
    TResult? Function(String message, String? pluginName)? print,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(@NotificationJsonConverter() Notification notification)?
        analyzerPluginNotification,
    TResult Function(String message, String stackTrace, String? pluginName)?
        error,
    TResult Function(String message, String? pluginName)? print,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(CustomLintEventAnalyzerPluginNotification value)
        analyzerPluginNotification,
    required TResult Function(CustomLintEventError value) error,
    required TResult Function(CustomLintEventPrint value) print,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(CustomLintEventAnalyzerPluginNotification value)?
        analyzerPluginNotification,
    TResult? Function(CustomLintEventError value)? error,
    TResult? Function(CustomLintEventPrint value)? print,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(CustomLintEventAnalyzerPluginNotification value)?
        analyzerPluginNotification,
    TResult Function(CustomLintEventError value)? error,
    TResult Function(CustomLintEventPrint value)? print,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CustomLintEventCopyWith<$Res> {
  factory $CustomLintEventCopyWith(
          CustomLintEvent value, $Res Function(CustomLintEvent) then) =
      _$CustomLintEventCopyWithImpl<$Res, CustomLintEvent>;
}

/// @nodoc
class _$CustomLintEventCopyWithImpl<$Res, $Val extends CustomLintEvent>
    implements $CustomLintEventCopyWith<$Res> {
  _$CustomLintEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$CustomLintEventAnalyzerPluginNotificationCopyWith<$Res> {
  factory _$$CustomLintEventAnalyzerPluginNotificationCopyWith(
          _$CustomLintEventAnalyzerPluginNotification value,
          $Res Function(_$CustomLintEventAnalyzerPluginNotification) then) =
      __$$CustomLintEventAnalyzerPluginNotificationCopyWithImpl<$Res>;
  @useResult
  $Res call({@NotificationJsonConverter() Notification notification});
}

/// @nodoc
class __$$CustomLintEventAnalyzerPluginNotificationCopyWithImpl<$Res>
    extends _$CustomLintEventCopyWithImpl<$Res,
        _$CustomLintEventAnalyzerPluginNotification>
    implements _$$CustomLintEventAnalyzerPluginNotificationCopyWith<$Res> {
  __$$CustomLintEventAnalyzerPluginNotificationCopyWithImpl(
      _$CustomLintEventAnalyzerPluginNotification _value,
      $Res Function(_$CustomLintEventAnalyzerPluginNotification) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? notification = null,
  }) {
    return _then(_$CustomLintEventAnalyzerPluginNotification(
      null == notification
          ? _value.notification
          : notification // ignore: cast_nullable_to_non_nullable
              as Notification,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CustomLintEventAnalyzerPluginNotification
    implements CustomLintEventAnalyzerPluginNotification {
  _$CustomLintEventAnalyzerPluginNotification(
      @NotificationJsonConverter() this.notification,
      {final String? $type})
      : $type = $type ?? 'analyzerPluginNotification';

  factory _$CustomLintEventAnalyzerPluginNotification.fromJson(
          Map<String, dynamic> json) =>
      _$$CustomLintEventAnalyzerPluginNotificationFromJson(json);

  @override
  @NotificationJsonConverter()
  final Notification notification;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'CustomLintEvent.analyzerPluginNotification(notification: $notification)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomLintEventAnalyzerPluginNotification &&
            (identical(other.notification, notification) ||
                other.notification == notification));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, notification);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CustomLintEventAnalyzerPluginNotificationCopyWith<
          _$CustomLintEventAnalyzerPluginNotification>
      get copyWith => __$$CustomLintEventAnalyzerPluginNotificationCopyWithImpl<
          _$CustomLintEventAnalyzerPluginNotification>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            @NotificationJsonConverter() Notification notification)
        analyzerPluginNotification,
    required TResult Function(
            String message, String stackTrace, String? pluginName)
        error,
    required TResult Function(String message, String? pluginName) print,
  }) {
    return analyzerPluginNotification(notification);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(@NotificationJsonConverter() Notification notification)?
        analyzerPluginNotification,
    TResult? Function(String message, String stackTrace, String? pluginName)?
        error,
    TResult? Function(String message, String? pluginName)? print,
  }) {
    return analyzerPluginNotification?.call(notification);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(@NotificationJsonConverter() Notification notification)?
        analyzerPluginNotification,
    TResult Function(String message, String stackTrace, String? pluginName)?
        error,
    TResult Function(String message, String? pluginName)? print,
    required TResult orElse(),
  }) {
    if (analyzerPluginNotification != null) {
      return analyzerPluginNotification(notification);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(CustomLintEventAnalyzerPluginNotification value)
        analyzerPluginNotification,
    required TResult Function(CustomLintEventError value) error,
    required TResult Function(CustomLintEventPrint value) print,
  }) {
    return analyzerPluginNotification(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(CustomLintEventAnalyzerPluginNotification value)?
        analyzerPluginNotification,
    TResult? Function(CustomLintEventError value)? error,
    TResult? Function(CustomLintEventPrint value)? print,
  }) {
    return analyzerPluginNotification?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(CustomLintEventAnalyzerPluginNotification value)?
        analyzerPluginNotification,
    TResult Function(CustomLintEventError value)? error,
    TResult Function(CustomLintEventPrint value)? print,
    required TResult orElse(),
  }) {
    if (analyzerPluginNotification != null) {
      return analyzerPluginNotification(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$CustomLintEventAnalyzerPluginNotificationToJson(
      this,
    );
  }
}

abstract class CustomLintEventAnalyzerPluginNotification
    implements CustomLintEvent {
  factory CustomLintEventAnalyzerPluginNotification(
          @NotificationJsonConverter() final Notification notification) =
      _$CustomLintEventAnalyzerPluginNotification;

  factory CustomLintEventAnalyzerPluginNotification.fromJson(
          Map<String, dynamic> json) =
      _$CustomLintEventAnalyzerPluginNotification.fromJson;

  @NotificationJsonConverter()
  Notification get notification;
  @JsonKey(ignore: true)
  _$$CustomLintEventAnalyzerPluginNotificationCopyWith<
          _$CustomLintEventAnalyzerPluginNotification>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$CustomLintEventErrorCopyWith<$Res> {
  factory _$$CustomLintEventErrorCopyWith(_$CustomLintEventError value,
          $Res Function(_$CustomLintEventError) then) =
      __$$CustomLintEventErrorCopyWithImpl<$Res>;
  @useResult
  $Res call({String message, String stackTrace, String? pluginName});
}

/// @nodoc
class __$$CustomLintEventErrorCopyWithImpl<$Res>
    extends _$CustomLintEventCopyWithImpl<$Res, _$CustomLintEventError>
    implements _$$CustomLintEventErrorCopyWith<$Res> {
  __$$CustomLintEventErrorCopyWithImpl(_$CustomLintEventError _value,
      $Res Function(_$CustomLintEventError) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? stackTrace = null,
    Object? pluginName = freezed,
  }) {
    return _then(_$CustomLintEventError(
      null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      null == stackTrace
          ? _value.stackTrace
          : stackTrace // ignore: cast_nullable_to_non_nullable
              as String,
      pluginName: freezed == pluginName
          ? _value.pluginName
          : pluginName // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CustomLintEventError implements CustomLintEventError {
  _$CustomLintEventError(this.message, this.stackTrace,
      {required this.pluginName, final String? $type})
      : $type = $type ?? 'error';

  factory _$CustomLintEventError.fromJson(Map<String, dynamic> json) =>
      _$$CustomLintEventErrorFromJson(json);

  @override
  final String message;
  @override
  final String stackTrace;
  @override
  final String? pluginName;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'CustomLintEvent.error(message: $message, stackTrace: $stackTrace, pluginName: $pluginName)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomLintEventError &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.stackTrace, stackTrace) ||
                other.stackTrace == stackTrace) &&
            (identical(other.pluginName, pluginName) ||
                other.pluginName == pluginName));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, message, stackTrace, pluginName);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CustomLintEventErrorCopyWith<_$CustomLintEventError> get copyWith =>
      __$$CustomLintEventErrorCopyWithImpl<_$CustomLintEventError>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            @NotificationJsonConverter() Notification notification)
        analyzerPluginNotification,
    required TResult Function(
            String message, String stackTrace, String? pluginName)
        error,
    required TResult Function(String message, String? pluginName) print,
  }) {
    return error(message, stackTrace, pluginName);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(@NotificationJsonConverter() Notification notification)?
        analyzerPluginNotification,
    TResult? Function(String message, String stackTrace, String? pluginName)?
        error,
    TResult? Function(String message, String? pluginName)? print,
  }) {
    return error?.call(message, stackTrace, pluginName);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(@NotificationJsonConverter() Notification notification)?
        analyzerPluginNotification,
    TResult Function(String message, String stackTrace, String? pluginName)?
        error,
    TResult Function(String message, String? pluginName)? print,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(message, stackTrace, pluginName);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(CustomLintEventAnalyzerPluginNotification value)
        analyzerPluginNotification,
    required TResult Function(CustomLintEventError value) error,
    required TResult Function(CustomLintEventPrint value) print,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(CustomLintEventAnalyzerPluginNotification value)?
        analyzerPluginNotification,
    TResult? Function(CustomLintEventError value)? error,
    TResult? Function(CustomLintEventPrint value)? print,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(CustomLintEventAnalyzerPluginNotification value)?
        analyzerPluginNotification,
    TResult Function(CustomLintEventError value)? error,
    TResult Function(CustomLintEventPrint value)? print,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$CustomLintEventErrorToJson(
      this,
    );
  }
}

abstract class CustomLintEventError implements CustomLintEvent {
  factory CustomLintEventError(final String message, final String stackTrace,
      {required final String? pluginName}) = _$CustomLintEventError;

  factory CustomLintEventError.fromJson(Map<String, dynamic> json) =
      _$CustomLintEventError.fromJson;

  String get message;
  String get stackTrace;
  String? get pluginName;
  @JsonKey(ignore: true)
  _$$CustomLintEventErrorCopyWith<_$CustomLintEventError> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$CustomLintEventPrintCopyWith<$Res> {
  factory _$$CustomLintEventPrintCopyWith(_$CustomLintEventPrint value,
          $Res Function(_$CustomLintEventPrint) then) =
      __$$CustomLintEventPrintCopyWithImpl<$Res>;
  @useResult
  $Res call({String message, String? pluginName});
}

/// @nodoc
class __$$CustomLintEventPrintCopyWithImpl<$Res>
    extends _$CustomLintEventCopyWithImpl<$Res, _$CustomLintEventPrint>
    implements _$$CustomLintEventPrintCopyWith<$Res> {
  __$$CustomLintEventPrintCopyWithImpl(_$CustomLintEventPrint _value,
      $Res Function(_$CustomLintEventPrint) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? pluginName = freezed,
  }) {
    return _then(_$CustomLintEventPrint(
      null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      pluginName: freezed == pluginName
          ? _value.pluginName
          : pluginName // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CustomLintEventPrint implements CustomLintEventPrint {
  _$CustomLintEventPrint(this.message,
      {required this.pluginName, final String? $type})
      : $type = $type ?? 'print';

  factory _$CustomLintEventPrint.fromJson(Map<String, dynamic> json) =>
      _$$CustomLintEventPrintFromJson(json);

  @override
  final String message;
  @override
  final String? pluginName;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'CustomLintEvent.print(message: $message, pluginName: $pluginName)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomLintEventPrint &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.pluginName, pluginName) ||
                other.pluginName == pluginName));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, message, pluginName);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CustomLintEventPrintCopyWith<_$CustomLintEventPrint> get copyWith =>
      __$$CustomLintEventPrintCopyWithImpl<_$CustomLintEventPrint>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            @NotificationJsonConverter() Notification notification)
        analyzerPluginNotification,
    required TResult Function(
            String message, String stackTrace, String? pluginName)
        error,
    required TResult Function(String message, String? pluginName) print,
  }) {
    return print(message, pluginName);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(@NotificationJsonConverter() Notification notification)?
        analyzerPluginNotification,
    TResult? Function(String message, String stackTrace, String? pluginName)?
        error,
    TResult? Function(String message, String? pluginName)? print,
  }) {
    return print?.call(message, pluginName);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(@NotificationJsonConverter() Notification notification)?
        analyzerPluginNotification,
    TResult Function(String message, String stackTrace, String? pluginName)?
        error,
    TResult Function(String message, String? pluginName)? print,
    required TResult orElse(),
  }) {
    if (print != null) {
      return print(message, pluginName);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(CustomLintEventAnalyzerPluginNotification value)
        analyzerPluginNotification,
    required TResult Function(CustomLintEventError value) error,
    required TResult Function(CustomLintEventPrint value) print,
  }) {
    return print(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(CustomLintEventAnalyzerPluginNotification value)?
        analyzerPluginNotification,
    TResult? Function(CustomLintEventError value)? error,
    TResult? Function(CustomLintEventPrint value)? print,
  }) {
    return print?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(CustomLintEventAnalyzerPluginNotification value)?
        analyzerPluginNotification,
    TResult Function(CustomLintEventError value)? error,
    TResult Function(CustomLintEventPrint value)? print,
    required TResult orElse(),
  }) {
    if (print != null) {
      return print(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$CustomLintEventPrintToJson(
      this,
    );
  }
}

abstract class CustomLintEventPrint implements CustomLintEvent {
  factory CustomLintEventPrint(final String message,
      {required final String? pluginName}) = _$CustomLintEventPrint;

  factory CustomLintEventPrint.fromJson(Map<String, dynamic> json) =
      _$CustomLintEventPrint.fromJson;

  String get message;
  String? get pluginName;
  @JsonKey(ignore: true)
  _$$CustomLintEventPrintCopyWith<_$CustomLintEventPrint> get copyWith =>
      throw _privateConstructorUsedError;
}
