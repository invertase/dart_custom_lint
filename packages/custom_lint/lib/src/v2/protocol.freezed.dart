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
      return _CustomLintRequestAwaitAnalysisDone.fromJson(json);
    case 'ping':
      return _CustomLintRequestPing.fromJson(json);

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
    required TResult Function(String id) ping,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Request request, String id)? analyzerPluginRequest,
    TResult? Function(String id, bool reload)? awaitAnalysisDone,
    TResult? Function(String id)? ping,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Request request, String id)? analyzerPluginRequest,
    TResult Function(String id, bool reload)? awaitAnalysisDone,
    TResult Function(String id)? ping,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(CustomLintRequestAnalyzerPluginRequest value)
        analyzerPluginRequest,
    required TResult Function(_CustomLintRequestAwaitAnalysisDone value)
        awaitAnalysisDone,
    required TResult Function(_CustomLintRequestPing value) ping,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(CustomLintRequestAnalyzerPluginRequest value)?
        analyzerPluginRequest,
    TResult? Function(_CustomLintRequestAwaitAnalysisDone value)?
        awaitAnalysisDone,
    TResult? Function(_CustomLintRequestPing value)? ping,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(CustomLintRequestAnalyzerPluginRequest value)?
        analyzerPluginRequest,
    TResult Function(_CustomLintRequestAwaitAnalysisDone value)?
        awaitAnalysisDone,
    TResult Function(_CustomLintRequestPing value)? ping,
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
abstract class _$$CustomLintRequestAnalyzerPluginRequestImplCopyWith<$Res>
    implements $CustomLintRequestCopyWith<$Res> {
  factory _$$CustomLintRequestAnalyzerPluginRequestImplCopyWith(
          _$CustomLintRequestAnalyzerPluginRequestImpl value,
          $Res Function(_$CustomLintRequestAnalyzerPluginRequestImpl) then) =
      __$$CustomLintRequestAnalyzerPluginRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Request request, String id});
}

/// @nodoc
class __$$CustomLintRequestAnalyzerPluginRequestImplCopyWithImpl<$Res>
    extends _$CustomLintRequestCopyWithImpl<$Res,
        _$CustomLintRequestAnalyzerPluginRequestImpl>
    implements _$$CustomLintRequestAnalyzerPluginRequestImplCopyWith<$Res> {
  __$$CustomLintRequestAnalyzerPluginRequestImplCopyWithImpl(
      _$CustomLintRequestAnalyzerPluginRequestImpl _value,
      $Res Function(_$CustomLintRequestAnalyzerPluginRequestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? request = null,
    Object? id = null,
  }) {
    return _then(_$CustomLintRequestAnalyzerPluginRequestImpl(
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
class _$CustomLintRequestAnalyzerPluginRequestImpl
    implements CustomLintRequestAnalyzerPluginRequest {
  _$CustomLintRequestAnalyzerPluginRequestImpl(this.request,
      {required this.id, final String? $type})
      : $type = $type ?? 'analyzerPluginRequest';

  factory _$CustomLintRequestAnalyzerPluginRequestImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$CustomLintRequestAnalyzerPluginRequestImplFromJson(json);

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
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomLintRequestAnalyzerPluginRequestImpl &&
            (identical(other.request, request) || other.request == request) &&
            (identical(other.id, id) || other.id == id));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, request, id);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CustomLintRequestAnalyzerPluginRequestImplCopyWith<
          _$CustomLintRequestAnalyzerPluginRequestImpl>
      get copyWith =>
          __$$CustomLintRequestAnalyzerPluginRequestImplCopyWithImpl<
              _$CustomLintRequestAnalyzerPluginRequestImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Request request, String id) analyzerPluginRequest,
    required TResult Function(String id, bool reload) awaitAnalysisDone,
    required TResult Function(String id) ping,
  }) {
    return analyzerPluginRequest(request, id);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Request request, String id)? analyzerPluginRequest,
    TResult? Function(String id, bool reload)? awaitAnalysisDone,
    TResult? Function(String id)? ping,
  }) {
    return analyzerPluginRequest?.call(request, id);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Request request, String id)? analyzerPluginRequest,
    TResult Function(String id, bool reload)? awaitAnalysisDone,
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
    required TResult Function(_CustomLintRequestAwaitAnalysisDone value)
        awaitAnalysisDone,
    required TResult Function(_CustomLintRequestPing value) ping,
  }) {
    return analyzerPluginRequest(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(CustomLintRequestAnalyzerPluginRequest value)?
        analyzerPluginRequest,
    TResult? Function(_CustomLintRequestAwaitAnalysisDone value)?
        awaitAnalysisDone,
    TResult? Function(_CustomLintRequestPing value)? ping,
  }) {
    return analyzerPluginRequest?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(CustomLintRequestAnalyzerPluginRequest value)?
        analyzerPluginRequest,
    TResult Function(_CustomLintRequestAwaitAnalysisDone value)?
        awaitAnalysisDone,
    TResult Function(_CustomLintRequestPing value)? ping,
    required TResult orElse(),
  }) {
    if (analyzerPluginRequest != null) {
      return analyzerPluginRequest(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$CustomLintRequestAnalyzerPluginRequestImplToJson(
      this,
    );
  }
}

abstract class CustomLintRequestAnalyzerPluginRequest
    implements CustomLintRequest {
  factory CustomLintRequestAnalyzerPluginRequest(final Request request,
          {required final String id}) =
      _$CustomLintRequestAnalyzerPluginRequestImpl;

  factory CustomLintRequestAnalyzerPluginRequest.fromJson(
          Map<String, dynamic> json) =
      _$CustomLintRequestAnalyzerPluginRequestImpl.fromJson;

  Request get request;
  @override
  String get id;
  @override
  @JsonKey(ignore: true)
  _$$CustomLintRequestAnalyzerPluginRequestImplCopyWith<
          _$CustomLintRequestAnalyzerPluginRequestImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$CustomLintRequestAwaitAnalysisDoneImplCopyWith<$Res>
    implements $CustomLintRequestCopyWith<$Res> {
  factory _$$CustomLintRequestAwaitAnalysisDoneImplCopyWith(
          _$CustomLintRequestAwaitAnalysisDoneImpl value,
          $Res Function(_$CustomLintRequestAwaitAnalysisDoneImpl) then) =
      __$$CustomLintRequestAwaitAnalysisDoneImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, bool reload});
}

/// @nodoc
class __$$CustomLintRequestAwaitAnalysisDoneImplCopyWithImpl<$Res>
    extends _$CustomLintRequestCopyWithImpl<$Res,
        _$CustomLintRequestAwaitAnalysisDoneImpl>
    implements _$$CustomLintRequestAwaitAnalysisDoneImplCopyWith<$Res> {
  __$$CustomLintRequestAwaitAnalysisDoneImplCopyWithImpl(
      _$CustomLintRequestAwaitAnalysisDoneImpl _value,
      $Res Function(_$CustomLintRequestAwaitAnalysisDoneImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? reload = null,
  }) {
    return _then(_$CustomLintRequestAwaitAnalysisDoneImpl(
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
class _$CustomLintRequestAwaitAnalysisDoneImpl
    implements _CustomLintRequestAwaitAnalysisDone {
  _$CustomLintRequestAwaitAnalysisDoneImpl(
      {required this.id, required this.reload, final String? $type})
      : $type = $type ?? 'awaitAnalysisDone';

  factory _$CustomLintRequestAwaitAnalysisDoneImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$CustomLintRequestAwaitAnalysisDoneImplFromJson(json);

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
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomLintRequestAwaitAnalysisDoneImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.reload, reload) || other.reload == reload));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, reload);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CustomLintRequestAwaitAnalysisDoneImplCopyWith<
          _$CustomLintRequestAwaitAnalysisDoneImpl>
      get copyWith => __$$CustomLintRequestAwaitAnalysisDoneImplCopyWithImpl<
          _$CustomLintRequestAwaitAnalysisDoneImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Request request, String id) analyzerPluginRequest,
    required TResult Function(String id, bool reload) awaitAnalysisDone,
    required TResult Function(String id) ping,
  }) {
    return awaitAnalysisDone(id, reload);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Request request, String id)? analyzerPluginRequest,
    TResult? Function(String id, bool reload)? awaitAnalysisDone,
    TResult? Function(String id)? ping,
  }) {
    return awaitAnalysisDone?.call(id, reload);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Request request, String id)? analyzerPluginRequest,
    TResult Function(String id, bool reload)? awaitAnalysisDone,
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
    required TResult Function(_CustomLintRequestAwaitAnalysisDone value)
        awaitAnalysisDone,
    required TResult Function(_CustomLintRequestPing value) ping,
  }) {
    return awaitAnalysisDone(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(CustomLintRequestAnalyzerPluginRequest value)?
        analyzerPluginRequest,
    TResult? Function(_CustomLintRequestAwaitAnalysisDone value)?
        awaitAnalysisDone,
    TResult? Function(_CustomLintRequestPing value)? ping,
  }) {
    return awaitAnalysisDone?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(CustomLintRequestAnalyzerPluginRequest value)?
        analyzerPluginRequest,
    TResult Function(_CustomLintRequestAwaitAnalysisDone value)?
        awaitAnalysisDone,
    TResult Function(_CustomLintRequestPing value)? ping,
    required TResult orElse(),
  }) {
    if (awaitAnalysisDone != null) {
      return awaitAnalysisDone(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$CustomLintRequestAwaitAnalysisDoneImplToJson(
      this,
    );
  }
}

abstract class _CustomLintRequestAwaitAnalysisDone
    implements CustomLintRequest {
  factory _CustomLintRequestAwaitAnalysisDone(
      {required final String id,
      required final bool reload}) = _$CustomLintRequestAwaitAnalysisDoneImpl;

  factory _CustomLintRequestAwaitAnalysisDone.fromJson(
          Map<String, dynamic> json) =
      _$CustomLintRequestAwaitAnalysisDoneImpl.fromJson;

  @override
  String get id;
  bool get reload;
  @override
  @JsonKey(ignore: true)
  _$$CustomLintRequestAwaitAnalysisDoneImplCopyWith<
          _$CustomLintRequestAwaitAnalysisDoneImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$CustomLintRequestPingImplCopyWith<$Res>
    implements $CustomLintRequestCopyWith<$Res> {
  factory _$$CustomLintRequestPingImplCopyWith(
          _$CustomLintRequestPingImpl value,
          $Res Function(_$CustomLintRequestPingImpl) then) =
      __$$CustomLintRequestPingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id});
}

/// @nodoc
class __$$CustomLintRequestPingImplCopyWithImpl<$Res>
    extends _$CustomLintRequestCopyWithImpl<$Res, _$CustomLintRequestPingImpl>
    implements _$$CustomLintRequestPingImplCopyWith<$Res> {
  __$$CustomLintRequestPingImplCopyWithImpl(_$CustomLintRequestPingImpl _value,
      $Res Function(_$CustomLintRequestPingImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
  }) {
    return _then(_$CustomLintRequestPingImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CustomLintRequestPingImpl implements _CustomLintRequestPing {
  _$CustomLintRequestPingImpl({required this.id, final String? $type})
      : $type = $type ?? 'ping';

  factory _$CustomLintRequestPingImpl.fromJson(Map<String, dynamic> json) =>
      _$$CustomLintRequestPingImplFromJson(json);

  @override
  final String id;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'CustomLintRequest.ping(id: $id)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomLintRequestPingImpl &&
            (identical(other.id, id) || other.id == id));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CustomLintRequestPingImplCopyWith<_$CustomLintRequestPingImpl>
      get copyWith => __$$CustomLintRequestPingImplCopyWithImpl<
          _$CustomLintRequestPingImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Request request, String id) analyzerPluginRequest,
    required TResult Function(String id, bool reload) awaitAnalysisDone,
    required TResult Function(String id) ping,
  }) {
    return ping(id);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Request request, String id)? analyzerPluginRequest,
    TResult? Function(String id, bool reload)? awaitAnalysisDone,
    TResult? Function(String id)? ping,
  }) {
    return ping?.call(id);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Request request, String id)? analyzerPluginRequest,
    TResult Function(String id, bool reload)? awaitAnalysisDone,
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
    required TResult Function(_CustomLintRequestAwaitAnalysisDone value)
        awaitAnalysisDone,
    required TResult Function(_CustomLintRequestPing value) ping,
  }) {
    return ping(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(CustomLintRequestAnalyzerPluginRequest value)?
        analyzerPluginRequest,
    TResult? Function(_CustomLintRequestAwaitAnalysisDone value)?
        awaitAnalysisDone,
    TResult? Function(_CustomLintRequestPing value)? ping,
  }) {
    return ping?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(CustomLintRequestAnalyzerPluginRequest value)?
        analyzerPluginRequest,
    TResult Function(_CustomLintRequestAwaitAnalysisDone value)?
        awaitAnalysisDone,
    TResult Function(_CustomLintRequestPing value)? ping,
    required TResult orElse(),
  }) {
    if (ping != null) {
      return ping(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$CustomLintRequestPingImplToJson(
      this,
    );
  }
}

abstract class _CustomLintRequestPing implements CustomLintRequest {
  factory _CustomLintRequestPing({required final String id}) =
      _$CustomLintRequestPingImpl;

  factory _CustomLintRequestPing.fromJson(Map<String, dynamic> json) =
      _$CustomLintRequestPingImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(ignore: true)
  _$$CustomLintRequestPingImplCopyWith<_$CustomLintRequestPingImpl>
      get copyWith => throw _privateConstructorUsedError;
}

CustomLintResponse _$CustomLintResponseFromJson(Map<String, dynamic> json) {
  switch (json['runtimeType']) {
    case 'analyzerPluginResponse':
      return _CustomLintResponseAnalyzerPluginResponse.fromJson(json);
    case 'awaitAnalysisDone':
      return _CustomLintResponseAwaitAnalysisDone.fromJson(json);
    case 'pong':
      return _CustomLintResponsePong.fromJson(json);
    case 'error':
      return _CustomLintResponseError.fromJson(json);

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
    required TResult Function(String id) pong,
    required TResult Function(String id, String message, String stackTrace)
        error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Response response, String id)? analyzerPluginResponse,
    TResult? Function(String id)? awaitAnalysisDone,
    TResult? Function(String id)? pong,
    TResult? Function(String id, String message, String stackTrace)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Response response, String id)? analyzerPluginResponse,
    TResult Function(String id)? awaitAnalysisDone,
    TResult Function(String id)? pong,
    TResult Function(String id, String message, String stackTrace)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_CustomLintResponseAnalyzerPluginResponse value)
        analyzerPluginResponse,
    required TResult Function(_CustomLintResponseAwaitAnalysisDone value)
        awaitAnalysisDone,
    required TResult Function(_CustomLintResponsePong value) pong,
    required TResult Function(_CustomLintResponseError value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_CustomLintResponseAnalyzerPluginResponse value)?
        analyzerPluginResponse,
    TResult? Function(_CustomLintResponseAwaitAnalysisDone value)?
        awaitAnalysisDone,
    TResult? Function(_CustomLintResponsePong value)? pong,
    TResult? Function(_CustomLintResponseError value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_CustomLintResponseAnalyzerPluginResponse value)?
        analyzerPluginResponse,
    TResult Function(_CustomLintResponseAwaitAnalysisDone value)?
        awaitAnalysisDone,
    TResult Function(_CustomLintResponsePong value)? pong,
    TResult Function(_CustomLintResponseError value)? error,
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
abstract class _$$CustomLintResponseAnalyzerPluginResponseImplCopyWith<$Res>
    implements $CustomLintResponseCopyWith<$Res> {
  factory _$$CustomLintResponseAnalyzerPluginResponseImplCopyWith(
          _$CustomLintResponseAnalyzerPluginResponseImpl value,
          $Res Function(_$CustomLintResponseAnalyzerPluginResponseImpl) then) =
      __$$CustomLintResponseAnalyzerPluginResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Response response, String id});
}

/// @nodoc
class __$$CustomLintResponseAnalyzerPluginResponseImplCopyWithImpl<$Res>
    extends _$CustomLintResponseCopyWithImpl<$Res,
        _$CustomLintResponseAnalyzerPluginResponseImpl>
    implements _$$CustomLintResponseAnalyzerPluginResponseImplCopyWith<$Res> {
  __$$CustomLintResponseAnalyzerPluginResponseImplCopyWithImpl(
      _$CustomLintResponseAnalyzerPluginResponseImpl _value,
      $Res Function(_$CustomLintResponseAnalyzerPluginResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? response = null,
    Object? id = null,
  }) {
    return _then(_$CustomLintResponseAnalyzerPluginResponseImpl(
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
class _$CustomLintResponseAnalyzerPluginResponseImpl
    implements _CustomLintResponseAnalyzerPluginResponse {
  _$CustomLintResponseAnalyzerPluginResponseImpl(this.response,
      {required this.id, final String? $type})
      : $type = $type ?? 'analyzerPluginResponse';

  factory _$CustomLintResponseAnalyzerPluginResponseImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$CustomLintResponseAnalyzerPluginResponseImplFromJson(json);

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
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomLintResponseAnalyzerPluginResponseImpl &&
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
  _$$CustomLintResponseAnalyzerPluginResponseImplCopyWith<
          _$CustomLintResponseAnalyzerPluginResponseImpl>
      get copyWith =>
          __$$CustomLintResponseAnalyzerPluginResponseImplCopyWithImpl<
              _$CustomLintResponseAnalyzerPluginResponseImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Response response, String id)
        analyzerPluginResponse,
    required TResult Function(String id) awaitAnalysisDone,
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
    required TResult Function(_CustomLintResponseAnalyzerPluginResponse value)
        analyzerPluginResponse,
    required TResult Function(_CustomLintResponseAwaitAnalysisDone value)
        awaitAnalysisDone,
    required TResult Function(_CustomLintResponsePong value) pong,
    required TResult Function(_CustomLintResponseError value) error,
  }) {
    return analyzerPluginResponse(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_CustomLintResponseAnalyzerPluginResponse value)?
        analyzerPluginResponse,
    TResult? Function(_CustomLintResponseAwaitAnalysisDone value)?
        awaitAnalysisDone,
    TResult? Function(_CustomLintResponsePong value)? pong,
    TResult? Function(_CustomLintResponseError value)? error,
  }) {
    return analyzerPluginResponse?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_CustomLintResponseAnalyzerPluginResponse value)?
        analyzerPluginResponse,
    TResult Function(_CustomLintResponseAwaitAnalysisDone value)?
        awaitAnalysisDone,
    TResult Function(_CustomLintResponsePong value)? pong,
    TResult Function(_CustomLintResponseError value)? error,
    required TResult orElse(),
  }) {
    if (analyzerPluginResponse != null) {
      return analyzerPluginResponse(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$CustomLintResponseAnalyzerPluginResponseImplToJson(
      this,
    );
  }
}

abstract class _CustomLintResponseAnalyzerPluginResponse
    implements CustomLintResponse {
  factory _CustomLintResponseAnalyzerPluginResponse(final Response response,
          {required final String id}) =
      _$CustomLintResponseAnalyzerPluginResponseImpl;

  factory _CustomLintResponseAnalyzerPluginResponse.fromJson(
          Map<String, dynamic> json) =
      _$CustomLintResponseAnalyzerPluginResponseImpl.fromJson;

  Response get response;
  @override
  String get id;
  @override
  @JsonKey(ignore: true)
  _$$CustomLintResponseAnalyzerPluginResponseImplCopyWith<
          _$CustomLintResponseAnalyzerPluginResponseImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$CustomLintResponseAwaitAnalysisDoneImplCopyWith<$Res>
    implements $CustomLintResponseCopyWith<$Res> {
  factory _$$CustomLintResponseAwaitAnalysisDoneImplCopyWith(
          _$CustomLintResponseAwaitAnalysisDoneImpl value,
          $Res Function(_$CustomLintResponseAwaitAnalysisDoneImpl) then) =
      __$$CustomLintResponseAwaitAnalysisDoneImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id});
}

/// @nodoc
class __$$CustomLintResponseAwaitAnalysisDoneImplCopyWithImpl<$Res>
    extends _$CustomLintResponseCopyWithImpl<$Res,
        _$CustomLintResponseAwaitAnalysisDoneImpl>
    implements _$$CustomLintResponseAwaitAnalysisDoneImplCopyWith<$Res> {
  __$$CustomLintResponseAwaitAnalysisDoneImplCopyWithImpl(
      _$CustomLintResponseAwaitAnalysisDoneImpl _value,
      $Res Function(_$CustomLintResponseAwaitAnalysisDoneImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
  }) {
    return _then(_$CustomLintResponseAwaitAnalysisDoneImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CustomLintResponseAwaitAnalysisDoneImpl
    implements _CustomLintResponseAwaitAnalysisDone {
  _$CustomLintResponseAwaitAnalysisDoneImpl(
      {required this.id, final String? $type})
      : $type = $type ?? 'awaitAnalysisDone';

  factory _$CustomLintResponseAwaitAnalysisDoneImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$CustomLintResponseAwaitAnalysisDoneImplFromJson(json);

  @override
  final String id;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'CustomLintResponse.awaitAnalysisDone(id: $id)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomLintResponseAwaitAnalysisDoneImpl &&
            (identical(other.id, id) || other.id == id));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CustomLintResponseAwaitAnalysisDoneImplCopyWith<
          _$CustomLintResponseAwaitAnalysisDoneImpl>
      get copyWith => __$$CustomLintResponseAwaitAnalysisDoneImplCopyWithImpl<
          _$CustomLintResponseAwaitAnalysisDoneImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Response response, String id)
        analyzerPluginResponse,
    required TResult Function(String id) awaitAnalysisDone,
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
    required TResult Function(_CustomLintResponseAnalyzerPluginResponse value)
        analyzerPluginResponse,
    required TResult Function(_CustomLintResponseAwaitAnalysisDone value)
        awaitAnalysisDone,
    required TResult Function(_CustomLintResponsePong value) pong,
    required TResult Function(_CustomLintResponseError value) error,
  }) {
    return awaitAnalysisDone(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_CustomLintResponseAnalyzerPluginResponse value)?
        analyzerPluginResponse,
    TResult? Function(_CustomLintResponseAwaitAnalysisDone value)?
        awaitAnalysisDone,
    TResult? Function(_CustomLintResponsePong value)? pong,
    TResult? Function(_CustomLintResponseError value)? error,
  }) {
    return awaitAnalysisDone?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_CustomLintResponseAnalyzerPluginResponse value)?
        analyzerPluginResponse,
    TResult Function(_CustomLintResponseAwaitAnalysisDone value)?
        awaitAnalysisDone,
    TResult Function(_CustomLintResponsePong value)? pong,
    TResult Function(_CustomLintResponseError value)? error,
    required TResult orElse(),
  }) {
    if (awaitAnalysisDone != null) {
      return awaitAnalysisDone(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$CustomLintResponseAwaitAnalysisDoneImplToJson(
      this,
    );
  }
}

abstract class _CustomLintResponseAwaitAnalysisDone
    implements CustomLintResponse {
  factory _CustomLintResponseAwaitAnalysisDone({required final String id}) =
      _$CustomLintResponseAwaitAnalysisDoneImpl;

  factory _CustomLintResponseAwaitAnalysisDone.fromJson(
          Map<String, dynamic> json) =
      _$CustomLintResponseAwaitAnalysisDoneImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(ignore: true)
  _$$CustomLintResponseAwaitAnalysisDoneImplCopyWith<
          _$CustomLintResponseAwaitAnalysisDoneImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$CustomLintResponsePongImplCopyWith<$Res>
    implements $CustomLintResponseCopyWith<$Res> {
  factory _$$CustomLintResponsePongImplCopyWith(
          _$CustomLintResponsePongImpl value,
          $Res Function(_$CustomLintResponsePongImpl) then) =
      __$$CustomLintResponsePongImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id});
}

/// @nodoc
class __$$CustomLintResponsePongImplCopyWithImpl<$Res>
    extends _$CustomLintResponseCopyWithImpl<$Res, _$CustomLintResponsePongImpl>
    implements _$$CustomLintResponsePongImplCopyWith<$Res> {
  __$$CustomLintResponsePongImplCopyWithImpl(
      _$CustomLintResponsePongImpl _value,
      $Res Function(_$CustomLintResponsePongImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
  }) {
    return _then(_$CustomLintResponsePongImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CustomLintResponsePongImpl implements _CustomLintResponsePong {
  _$CustomLintResponsePongImpl({required this.id, final String? $type})
      : $type = $type ?? 'pong';

  factory _$CustomLintResponsePongImpl.fromJson(Map<String, dynamic> json) =>
      _$$CustomLintResponsePongImplFromJson(json);

  @override
  final String id;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'CustomLintResponse.pong(id: $id)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomLintResponsePongImpl &&
            (identical(other.id, id) || other.id == id));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CustomLintResponsePongImplCopyWith<_$CustomLintResponsePongImpl>
      get copyWith => __$$CustomLintResponsePongImplCopyWithImpl<
          _$CustomLintResponsePongImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Response response, String id)
        analyzerPluginResponse,
    required TResult Function(String id) awaitAnalysisDone,
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
    required TResult Function(_CustomLintResponseAnalyzerPluginResponse value)
        analyzerPluginResponse,
    required TResult Function(_CustomLintResponseAwaitAnalysisDone value)
        awaitAnalysisDone,
    required TResult Function(_CustomLintResponsePong value) pong,
    required TResult Function(_CustomLintResponseError value) error,
  }) {
    return pong(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_CustomLintResponseAnalyzerPluginResponse value)?
        analyzerPluginResponse,
    TResult? Function(_CustomLintResponseAwaitAnalysisDone value)?
        awaitAnalysisDone,
    TResult? Function(_CustomLintResponsePong value)? pong,
    TResult? Function(_CustomLintResponseError value)? error,
  }) {
    return pong?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_CustomLintResponseAnalyzerPluginResponse value)?
        analyzerPluginResponse,
    TResult Function(_CustomLintResponseAwaitAnalysisDone value)?
        awaitAnalysisDone,
    TResult Function(_CustomLintResponsePong value)? pong,
    TResult Function(_CustomLintResponseError value)? error,
    required TResult orElse(),
  }) {
    if (pong != null) {
      return pong(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$CustomLintResponsePongImplToJson(
      this,
    );
  }
}

abstract class _CustomLintResponsePong implements CustomLintResponse {
  factory _CustomLintResponsePong({required final String id}) =
      _$CustomLintResponsePongImpl;

  factory _CustomLintResponsePong.fromJson(Map<String, dynamic> json) =
      _$CustomLintResponsePongImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(ignore: true)
  _$$CustomLintResponsePongImplCopyWith<_$CustomLintResponsePongImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$CustomLintResponseErrorImplCopyWith<$Res>
    implements $CustomLintResponseCopyWith<$Res> {
  factory _$$CustomLintResponseErrorImplCopyWith(
          _$CustomLintResponseErrorImpl value,
          $Res Function(_$CustomLintResponseErrorImpl) then) =
      __$$CustomLintResponseErrorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String message, String stackTrace});
}

/// @nodoc
class __$$CustomLintResponseErrorImplCopyWithImpl<$Res>
    extends _$CustomLintResponseCopyWithImpl<$Res,
        _$CustomLintResponseErrorImpl>
    implements _$$CustomLintResponseErrorImplCopyWith<$Res> {
  __$$CustomLintResponseErrorImplCopyWithImpl(
      _$CustomLintResponseErrorImpl _value,
      $Res Function(_$CustomLintResponseErrorImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? message = null,
    Object? stackTrace = null,
  }) {
    return _then(_$CustomLintResponseErrorImpl(
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
class _$CustomLintResponseErrorImpl implements _CustomLintResponseError {
  _$CustomLintResponseErrorImpl(
      {required this.id,
      required this.message,
      required this.stackTrace,
      final String? $type})
      : $type = $type ?? 'error';

  factory _$CustomLintResponseErrorImpl.fromJson(Map<String, dynamic> json) =>
      _$$CustomLintResponseErrorImplFromJson(json);

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
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomLintResponseErrorImpl &&
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
  _$$CustomLintResponseErrorImplCopyWith<_$CustomLintResponseErrorImpl>
      get copyWith => __$$CustomLintResponseErrorImplCopyWithImpl<
          _$CustomLintResponseErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Response response, String id)
        analyzerPluginResponse,
    required TResult Function(String id) awaitAnalysisDone,
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
    required TResult Function(_CustomLintResponseAnalyzerPluginResponse value)
        analyzerPluginResponse,
    required TResult Function(_CustomLintResponseAwaitAnalysisDone value)
        awaitAnalysisDone,
    required TResult Function(_CustomLintResponsePong value) pong,
    required TResult Function(_CustomLintResponseError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_CustomLintResponseAnalyzerPluginResponse value)?
        analyzerPluginResponse,
    TResult? Function(_CustomLintResponseAwaitAnalysisDone value)?
        awaitAnalysisDone,
    TResult? Function(_CustomLintResponsePong value)? pong,
    TResult? Function(_CustomLintResponseError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_CustomLintResponseAnalyzerPluginResponse value)?
        analyzerPluginResponse,
    TResult Function(_CustomLintResponseAwaitAnalysisDone value)?
        awaitAnalysisDone,
    TResult Function(_CustomLintResponsePong value)? pong,
    TResult Function(_CustomLintResponseError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$CustomLintResponseErrorImplToJson(
      this,
    );
  }
}

abstract class _CustomLintResponseError implements CustomLintResponse {
  factory _CustomLintResponseError(
      {required final String id,
      required final String message,
      required final String stackTrace}) = _$CustomLintResponseErrorImpl;

  factory _CustomLintResponseError.fromJson(Map<String, dynamic> json) =
      _$CustomLintResponseErrorImpl.fromJson;

  @override
  String get id;
  String get message;
  String get stackTrace;
  @override
  @JsonKey(ignore: true)
  _$$CustomLintResponseErrorImplCopyWith<_$CustomLintResponseErrorImpl>
      get copyWith => throw _privateConstructorUsedError;
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
abstract class _$$CustomLintMessageEventImplCopyWith<$Res> {
  factory _$$CustomLintMessageEventImplCopyWith(
          _$CustomLintMessageEventImpl value,
          $Res Function(_$CustomLintMessageEventImpl) then) =
      __$$CustomLintMessageEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call({CustomLintEvent event});

  $CustomLintEventCopyWith<$Res> get event;
}

/// @nodoc
class __$$CustomLintMessageEventImplCopyWithImpl<$Res>
    extends _$CustomLintMessageCopyWithImpl<$Res, _$CustomLintMessageEventImpl>
    implements _$$CustomLintMessageEventImplCopyWith<$Res> {
  __$$CustomLintMessageEventImplCopyWithImpl(
      _$CustomLintMessageEventImpl _value,
      $Res Function(_$CustomLintMessageEventImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? event = null,
  }) {
    return _then(_$CustomLintMessageEventImpl(
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
class _$CustomLintMessageEventImpl implements CustomLintMessageEvent {
  _$CustomLintMessageEventImpl(this.event, {final String? $type})
      : $type = $type ?? 'event';

  factory _$CustomLintMessageEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$CustomLintMessageEventImplFromJson(json);

  @override
  final CustomLintEvent event;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'CustomLintMessage.event(event: $event)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomLintMessageEventImpl &&
            (identical(other.event, event) || other.event == event));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, event);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CustomLintMessageEventImplCopyWith<_$CustomLintMessageEventImpl>
      get copyWith => __$$CustomLintMessageEventImplCopyWithImpl<
          _$CustomLintMessageEventImpl>(this, _$identity);

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
    return _$$CustomLintMessageEventImplToJson(
      this,
    );
  }
}

abstract class CustomLintMessageEvent implements CustomLintMessage {
  factory CustomLintMessageEvent(final CustomLintEvent event) =
      _$CustomLintMessageEventImpl;

  factory CustomLintMessageEvent.fromJson(Map<String, dynamic> json) =
      _$CustomLintMessageEventImpl.fromJson;

  CustomLintEvent get event;
  @JsonKey(ignore: true)
  _$$CustomLintMessageEventImplCopyWith<_$CustomLintMessageEventImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$CustomLintMessageResponseImplCopyWith<$Res> {
  factory _$$CustomLintMessageResponseImplCopyWith(
          _$CustomLintMessageResponseImpl value,
          $Res Function(_$CustomLintMessageResponseImpl) then) =
      __$$CustomLintMessageResponseImplCopyWithImpl<$Res>;
  @useResult
  $Res call({CustomLintResponse response});

  $CustomLintResponseCopyWith<$Res> get response;
}

/// @nodoc
class __$$CustomLintMessageResponseImplCopyWithImpl<$Res>
    extends _$CustomLintMessageCopyWithImpl<$Res,
        _$CustomLintMessageResponseImpl>
    implements _$$CustomLintMessageResponseImplCopyWith<$Res> {
  __$$CustomLintMessageResponseImplCopyWithImpl(
      _$CustomLintMessageResponseImpl _value,
      $Res Function(_$CustomLintMessageResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? response = null,
  }) {
    return _then(_$CustomLintMessageResponseImpl(
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
class _$CustomLintMessageResponseImpl implements CustomLintMessageResponse {
  _$CustomLintMessageResponseImpl(this.response, {final String? $type})
      : $type = $type ?? 'response';

  factory _$CustomLintMessageResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$CustomLintMessageResponseImplFromJson(json);

  @override
  final CustomLintResponse response;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'CustomLintMessage.response(response: $response)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomLintMessageResponseImpl &&
            (identical(other.response, response) ||
                other.response == response));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, response);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CustomLintMessageResponseImplCopyWith<_$CustomLintMessageResponseImpl>
      get copyWith => __$$CustomLintMessageResponseImplCopyWithImpl<
          _$CustomLintMessageResponseImpl>(this, _$identity);

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
    return _$$CustomLintMessageResponseImplToJson(
      this,
    );
  }
}

abstract class CustomLintMessageResponse implements CustomLintMessage {
  factory CustomLintMessageResponse(final CustomLintResponse response) =
      _$CustomLintMessageResponseImpl;

  factory CustomLintMessageResponse.fromJson(Map<String, dynamic> json) =
      _$CustomLintMessageResponseImpl.fromJson;

  CustomLintResponse get response;
  @JsonKey(ignore: true)
  _$$CustomLintMessageResponseImplCopyWith<_$CustomLintMessageResponseImpl>
      get copyWith => throw _privateConstructorUsedError;
}

CustomLintEvent _$CustomLintEventFromJson(Map<String, dynamic> json) {
  switch (json['runtimeType']) {
    case 'analyzerPluginNotification':
      return _CustomLintEventAnalyzerPluginNotification.fromJson(json);
    case 'error':
      return _CustomLintEventError.fromJson(json);
    case 'print':
      return _CustomLintEventPrint.fromJson(json);

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
    required TResult Function(_CustomLintEventAnalyzerPluginNotification value)
        analyzerPluginNotification,
    required TResult Function(_CustomLintEventError value) error,
    required TResult Function(_CustomLintEventPrint value) print,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_CustomLintEventAnalyzerPluginNotification value)?
        analyzerPluginNotification,
    TResult? Function(_CustomLintEventError value)? error,
    TResult? Function(_CustomLintEventPrint value)? print,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_CustomLintEventAnalyzerPluginNotification value)?
        analyzerPluginNotification,
    TResult Function(_CustomLintEventError value)? error,
    TResult Function(_CustomLintEventPrint value)? print,
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
abstract class _$$CustomLintEventAnalyzerPluginNotificationImplCopyWith<$Res> {
  factory _$$CustomLintEventAnalyzerPluginNotificationImplCopyWith(
          _$CustomLintEventAnalyzerPluginNotificationImpl value,
          $Res Function(_$CustomLintEventAnalyzerPluginNotificationImpl) then) =
      __$$CustomLintEventAnalyzerPluginNotificationImplCopyWithImpl<$Res>;
  @useResult
  $Res call({@NotificationJsonConverter() Notification notification});
}

/// @nodoc
class __$$CustomLintEventAnalyzerPluginNotificationImplCopyWithImpl<$Res>
    extends _$CustomLintEventCopyWithImpl<$Res,
        _$CustomLintEventAnalyzerPluginNotificationImpl>
    implements _$$CustomLintEventAnalyzerPluginNotificationImplCopyWith<$Res> {
  __$$CustomLintEventAnalyzerPluginNotificationImplCopyWithImpl(
      _$CustomLintEventAnalyzerPluginNotificationImpl _value,
      $Res Function(_$CustomLintEventAnalyzerPluginNotificationImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? notification = null,
  }) {
    return _then(_$CustomLintEventAnalyzerPluginNotificationImpl(
      null == notification
          ? _value.notification
          : notification // ignore: cast_nullable_to_non_nullable
              as Notification,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CustomLintEventAnalyzerPluginNotificationImpl
    implements _CustomLintEventAnalyzerPluginNotification {
  _$CustomLintEventAnalyzerPluginNotificationImpl(
      @NotificationJsonConverter() this.notification,
      {final String? $type})
      : $type = $type ?? 'analyzerPluginNotification';

  factory _$CustomLintEventAnalyzerPluginNotificationImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$CustomLintEventAnalyzerPluginNotificationImplFromJson(json);

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
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomLintEventAnalyzerPluginNotificationImpl &&
            (identical(other.notification, notification) ||
                other.notification == notification));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, notification);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CustomLintEventAnalyzerPluginNotificationImplCopyWith<
          _$CustomLintEventAnalyzerPluginNotificationImpl>
      get copyWith =>
          __$$CustomLintEventAnalyzerPluginNotificationImplCopyWithImpl<
                  _$CustomLintEventAnalyzerPluginNotificationImpl>(
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
    required TResult Function(_CustomLintEventAnalyzerPluginNotification value)
        analyzerPluginNotification,
    required TResult Function(_CustomLintEventError value) error,
    required TResult Function(_CustomLintEventPrint value) print,
  }) {
    return analyzerPluginNotification(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_CustomLintEventAnalyzerPluginNotification value)?
        analyzerPluginNotification,
    TResult? Function(_CustomLintEventError value)? error,
    TResult? Function(_CustomLintEventPrint value)? print,
  }) {
    return analyzerPluginNotification?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_CustomLintEventAnalyzerPluginNotification value)?
        analyzerPluginNotification,
    TResult Function(_CustomLintEventError value)? error,
    TResult Function(_CustomLintEventPrint value)? print,
    required TResult orElse(),
  }) {
    if (analyzerPluginNotification != null) {
      return analyzerPluginNotification(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$CustomLintEventAnalyzerPluginNotificationImplToJson(
      this,
    );
  }
}

abstract class _CustomLintEventAnalyzerPluginNotification
    implements CustomLintEvent {
  factory _CustomLintEventAnalyzerPluginNotification(
          @NotificationJsonConverter() final Notification notification) =
      _$CustomLintEventAnalyzerPluginNotificationImpl;

  factory _CustomLintEventAnalyzerPluginNotification.fromJson(
          Map<String, dynamic> json) =
      _$CustomLintEventAnalyzerPluginNotificationImpl.fromJson;

  @NotificationJsonConverter()
  Notification get notification;
  @JsonKey(ignore: true)
  _$$CustomLintEventAnalyzerPluginNotificationImplCopyWith<
          _$CustomLintEventAnalyzerPluginNotificationImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$CustomLintEventErrorImplCopyWith<$Res> {
  factory _$$CustomLintEventErrorImplCopyWith(_$CustomLintEventErrorImpl value,
          $Res Function(_$CustomLintEventErrorImpl) then) =
      __$$CustomLintEventErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message, String stackTrace, String? pluginName});
}

/// @nodoc
class __$$CustomLintEventErrorImplCopyWithImpl<$Res>
    extends _$CustomLintEventCopyWithImpl<$Res, _$CustomLintEventErrorImpl>
    implements _$$CustomLintEventErrorImplCopyWith<$Res> {
  __$$CustomLintEventErrorImplCopyWithImpl(_$CustomLintEventErrorImpl _value,
      $Res Function(_$CustomLintEventErrorImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? stackTrace = null,
    Object? pluginName = freezed,
  }) {
    return _then(_$CustomLintEventErrorImpl(
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
class _$CustomLintEventErrorImpl implements _CustomLintEventError {
  _$CustomLintEventErrorImpl(this.message, this.stackTrace,
      {required this.pluginName, final String? $type})
      : $type = $type ?? 'error';

  factory _$CustomLintEventErrorImpl.fromJson(Map<String, dynamic> json) =>
      _$$CustomLintEventErrorImplFromJson(json);

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
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomLintEventErrorImpl &&
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
  _$$CustomLintEventErrorImplCopyWith<_$CustomLintEventErrorImpl>
      get copyWith =>
          __$$CustomLintEventErrorImplCopyWithImpl<_$CustomLintEventErrorImpl>(
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
    required TResult Function(_CustomLintEventAnalyzerPluginNotification value)
        analyzerPluginNotification,
    required TResult Function(_CustomLintEventError value) error,
    required TResult Function(_CustomLintEventPrint value) print,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_CustomLintEventAnalyzerPluginNotification value)?
        analyzerPluginNotification,
    TResult? Function(_CustomLintEventError value)? error,
    TResult? Function(_CustomLintEventPrint value)? print,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_CustomLintEventAnalyzerPluginNotification value)?
        analyzerPluginNotification,
    TResult Function(_CustomLintEventError value)? error,
    TResult Function(_CustomLintEventPrint value)? print,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$CustomLintEventErrorImplToJson(
      this,
    );
  }
}

abstract class _CustomLintEventError implements CustomLintEvent {
  factory _CustomLintEventError(final String message, final String stackTrace,
      {required final String? pluginName}) = _$CustomLintEventErrorImpl;

  factory _CustomLintEventError.fromJson(Map<String, dynamic> json) =
      _$CustomLintEventErrorImpl.fromJson;

  String get message;
  String get stackTrace;
  String? get pluginName;
  @JsonKey(ignore: true)
  _$$CustomLintEventErrorImplCopyWith<_$CustomLintEventErrorImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$CustomLintEventPrintImplCopyWith<$Res> {
  factory _$$CustomLintEventPrintImplCopyWith(_$CustomLintEventPrintImpl value,
          $Res Function(_$CustomLintEventPrintImpl) then) =
      __$$CustomLintEventPrintImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message, String? pluginName});
}

/// @nodoc
class __$$CustomLintEventPrintImplCopyWithImpl<$Res>
    extends _$CustomLintEventCopyWithImpl<$Res, _$CustomLintEventPrintImpl>
    implements _$$CustomLintEventPrintImplCopyWith<$Res> {
  __$$CustomLintEventPrintImplCopyWithImpl(_$CustomLintEventPrintImpl _value,
      $Res Function(_$CustomLintEventPrintImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? pluginName = freezed,
  }) {
    return _then(_$CustomLintEventPrintImpl(
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
class _$CustomLintEventPrintImpl implements _CustomLintEventPrint {
  _$CustomLintEventPrintImpl(this.message,
      {required this.pluginName, final String? $type})
      : $type = $type ?? 'print';

  factory _$CustomLintEventPrintImpl.fromJson(Map<String, dynamic> json) =>
      _$$CustomLintEventPrintImplFromJson(json);

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
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomLintEventPrintImpl &&
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
  _$$CustomLintEventPrintImplCopyWith<_$CustomLintEventPrintImpl>
      get copyWith =>
          __$$CustomLintEventPrintImplCopyWithImpl<_$CustomLintEventPrintImpl>(
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
    required TResult Function(_CustomLintEventAnalyzerPluginNotification value)
        analyzerPluginNotification,
    required TResult Function(_CustomLintEventError value) error,
    required TResult Function(_CustomLintEventPrint value) print,
  }) {
    return print(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_CustomLintEventAnalyzerPluginNotification value)?
        analyzerPluginNotification,
    TResult? Function(_CustomLintEventError value)? error,
    TResult? Function(_CustomLintEventPrint value)? print,
  }) {
    return print?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_CustomLintEventAnalyzerPluginNotification value)?
        analyzerPluginNotification,
    TResult Function(_CustomLintEventError value)? error,
    TResult Function(_CustomLintEventPrint value)? print,
    required TResult orElse(),
  }) {
    if (print != null) {
      return print(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$CustomLintEventPrintImplToJson(
      this,
    );
  }
}

abstract class _CustomLintEventPrint implements CustomLintEvent {
  factory _CustomLintEventPrint(final String message,
      {required final String? pluginName}) = _$CustomLintEventPrintImpl;

  factory _CustomLintEventPrint.fromJson(Map<String, dynamic> json) =
      _$CustomLintEventPrintImpl.fromJson;

  String get message;
  String? get pluginName;
  @JsonKey(ignore: true)
  _$$CustomLintEventPrintImplCopyWith<_$CustomLintEventPrintImpl>
      get copyWith => throw _privateConstructorUsedError;
}
