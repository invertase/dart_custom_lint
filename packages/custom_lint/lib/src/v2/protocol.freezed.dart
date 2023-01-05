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
abstract class _$$_CustomLintRequestAwaitAnalysisDoneCopyWith<$Res>
    implements $CustomLintRequestCopyWith<$Res> {
  factory _$$_CustomLintRequestAwaitAnalysisDoneCopyWith(
          _$_CustomLintRequestAwaitAnalysisDone value,
          $Res Function(_$_CustomLintRequestAwaitAnalysisDone) then) =
      __$$_CustomLintRequestAwaitAnalysisDoneCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, bool reload});
}

/// @nodoc
class __$$_CustomLintRequestAwaitAnalysisDoneCopyWithImpl<$Res>
    extends _$CustomLintRequestCopyWithImpl<$Res,
        _$_CustomLintRequestAwaitAnalysisDone>
    implements _$$_CustomLintRequestAwaitAnalysisDoneCopyWith<$Res> {
  __$$_CustomLintRequestAwaitAnalysisDoneCopyWithImpl(
      _$_CustomLintRequestAwaitAnalysisDone _value,
      $Res Function(_$_CustomLintRequestAwaitAnalysisDone) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? reload = null,
  }) {
    return _then(_$_CustomLintRequestAwaitAnalysisDone(
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
class _$_CustomLintRequestAwaitAnalysisDone
    implements _CustomLintRequestAwaitAnalysisDone {
  _$_CustomLintRequestAwaitAnalysisDone(
      {required this.id, required this.reload, final String? $type})
      : $type = $type ?? 'awaitAnalysisDone';

  factory _$_CustomLintRequestAwaitAnalysisDone.fromJson(
          Map<String, dynamic> json) =>
      _$$_CustomLintRequestAwaitAnalysisDoneFromJson(json);

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
            other is _$_CustomLintRequestAwaitAnalysisDone &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.reload, reload) || other.reload == reload));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, reload);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_CustomLintRequestAwaitAnalysisDoneCopyWith<
          _$_CustomLintRequestAwaitAnalysisDone>
      get copyWith => __$$_CustomLintRequestAwaitAnalysisDoneCopyWithImpl<
          _$_CustomLintRequestAwaitAnalysisDone>(this, _$identity);

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
    return _$$_CustomLintRequestAwaitAnalysisDoneToJson(
      this,
    );
  }
}

abstract class _CustomLintRequestAwaitAnalysisDone
    implements CustomLintRequest {
  factory _CustomLintRequestAwaitAnalysisDone(
      {required final String id,
      required final bool reload}) = _$_CustomLintRequestAwaitAnalysisDone;

  factory _CustomLintRequestAwaitAnalysisDone.fromJson(
          Map<String, dynamic> json) =
      _$_CustomLintRequestAwaitAnalysisDone.fromJson;

  @override
  String get id;
  bool get reload;
  @override
  @JsonKey(ignore: true)
  _$$_CustomLintRequestAwaitAnalysisDoneCopyWith<
          _$_CustomLintRequestAwaitAnalysisDone>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$_CustomLintRequestPingCopyWith<$Res>
    implements $CustomLintRequestCopyWith<$Res> {
  factory _$$_CustomLintRequestPingCopyWith(_$_CustomLintRequestPing value,
          $Res Function(_$_CustomLintRequestPing) then) =
      __$$_CustomLintRequestPingCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id});
}

/// @nodoc
class __$$_CustomLintRequestPingCopyWithImpl<$Res>
    extends _$CustomLintRequestCopyWithImpl<$Res, _$_CustomLintRequestPing>
    implements _$$_CustomLintRequestPingCopyWith<$Res> {
  __$$_CustomLintRequestPingCopyWithImpl(_$_CustomLintRequestPing _value,
      $Res Function(_$_CustomLintRequestPing) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
  }) {
    return _then(_$_CustomLintRequestPing(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_CustomLintRequestPing implements _CustomLintRequestPing {
  _$_CustomLintRequestPing({required this.id, final String? $type})
      : $type = $type ?? 'ping';

  factory _$_CustomLintRequestPing.fromJson(Map<String, dynamic> json) =>
      _$$_CustomLintRequestPingFromJson(json);

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
            other is _$_CustomLintRequestPing &&
            (identical(other.id, id) || other.id == id));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_CustomLintRequestPingCopyWith<_$_CustomLintRequestPing> get copyWith =>
      __$$_CustomLintRequestPingCopyWithImpl<_$_CustomLintRequestPing>(
          this, _$identity);

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
    return _$$_CustomLintRequestPingToJson(
      this,
    );
  }
}

abstract class _CustomLintRequestPing implements CustomLintRequest {
  factory _CustomLintRequestPing({required final String id}) =
      _$_CustomLintRequestPing;

  factory _CustomLintRequestPing.fromJson(Map<String, dynamic> json) =
      _$_CustomLintRequestPing.fromJson;

  @override
  String get id;
  @override
  @JsonKey(ignore: true)
  _$$_CustomLintRequestPingCopyWith<_$_CustomLintRequestPing> get copyWith =>
      throw _privateConstructorUsedError;
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
abstract class _$$_CustomLintResponseAnalyzerPluginResponseCopyWith<$Res>
    implements $CustomLintResponseCopyWith<$Res> {
  factory _$$_CustomLintResponseAnalyzerPluginResponseCopyWith(
          _$_CustomLintResponseAnalyzerPluginResponse value,
          $Res Function(_$_CustomLintResponseAnalyzerPluginResponse) then) =
      __$$_CustomLintResponseAnalyzerPluginResponseCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Response response, String id});
}

/// @nodoc
class __$$_CustomLintResponseAnalyzerPluginResponseCopyWithImpl<$Res>
    extends _$CustomLintResponseCopyWithImpl<$Res,
        _$_CustomLintResponseAnalyzerPluginResponse>
    implements _$$_CustomLintResponseAnalyzerPluginResponseCopyWith<$Res> {
  __$$_CustomLintResponseAnalyzerPluginResponseCopyWithImpl(
      _$_CustomLintResponseAnalyzerPluginResponse _value,
      $Res Function(_$_CustomLintResponseAnalyzerPluginResponse) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? response = null,
    Object? id = null,
  }) {
    return _then(_$_CustomLintResponseAnalyzerPluginResponse(
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
class _$_CustomLintResponseAnalyzerPluginResponse
    implements _CustomLintResponseAnalyzerPluginResponse {
  _$_CustomLintResponseAnalyzerPluginResponse(this.response,
      {required this.id, final String? $type})
      : $type = $type ?? 'analyzerPluginResponse';

  factory _$_CustomLintResponseAnalyzerPluginResponse.fromJson(
          Map<String, dynamic> json) =>
      _$$_CustomLintResponseAnalyzerPluginResponseFromJson(json);

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
            other is _$_CustomLintResponseAnalyzerPluginResponse &&
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
  _$$_CustomLintResponseAnalyzerPluginResponseCopyWith<
          _$_CustomLintResponseAnalyzerPluginResponse>
      get copyWith => __$$_CustomLintResponseAnalyzerPluginResponseCopyWithImpl<
          _$_CustomLintResponseAnalyzerPluginResponse>(this, _$identity);

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
    return _$$_CustomLintResponseAnalyzerPluginResponseToJson(
      this,
    );
  }
}

abstract class _CustomLintResponseAnalyzerPluginResponse
    implements CustomLintResponse {
  factory _CustomLintResponseAnalyzerPluginResponse(final Response response,
      {required final String id}) = _$_CustomLintResponseAnalyzerPluginResponse;

  factory _CustomLintResponseAnalyzerPluginResponse.fromJson(
          Map<String, dynamic> json) =
      _$_CustomLintResponseAnalyzerPluginResponse.fromJson;

  Response get response;
  @override
  String get id;
  @override
  @JsonKey(ignore: true)
  _$$_CustomLintResponseAnalyzerPluginResponseCopyWith<
          _$_CustomLintResponseAnalyzerPluginResponse>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$_CustomLintResponseAwaitAnalysisDoneCopyWith<$Res>
    implements $CustomLintResponseCopyWith<$Res> {
  factory _$$_CustomLintResponseAwaitAnalysisDoneCopyWith(
          _$_CustomLintResponseAwaitAnalysisDone value,
          $Res Function(_$_CustomLintResponseAwaitAnalysisDone) then) =
      __$$_CustomLintResponseAwaitAnalysisDoneCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id});
}

/// @nodoc
class __$$_CustomLintResponseAwaitAnalysisDoneCopyWithImpl<$Res>
    extends _$CustomLintResponseCopyWithImpl<$Res,
        _$_CustomLintResponseAwaitAnalysisDone>
    implements _$$_CustomLintResponseAwaitAnalysisDoneCopyWith<$Res> {
  __$$_CustomLintResponseAwaitAnalysisDoneCopyWithImpl(
      _$_CustomLintResponseAwaitAnalysisDone _value,
      $Res Function(_$_CustomLintResponseAwaitAnalysisDone) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
  }) {
    return _then(_$_CustomLintResponseAwaitAnalysisDone(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_CustomLintResponseAwaitAnalysisDone
    implements _CustomLintResponseAwaitAnalysisDone {
  _$_CustomLintResponseAwaitAnalysisDone(
      {required this.id, final String? $type})
      : $type = $type ?? 'awaitAnalysisDone';

  factory _$_CustomLintResponseAwaitAnalysisDone.fromJson(
          Map<String, dynamic> json) =>
      _$$_CustomLintResponseAwaitAnalysisDoneFromJson(json);

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
            other is _$_CustomLintResponseAwaitAnalysisDone &&
            (identical(other.id, id) || other.id == id));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_CustomLintResponseAwaitAnalysisDoneCopyWith<
          _$_CustomLintResponseAwaitAnalysisDone>
      get copyWith => __$$_CustomLintResponseAwaitAnalysisDoneCopyWithImpl<
          _$_CustomLintResponseAwaitAnalysisDone>(this, _$identity);

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
    return _$$_CustomLintResponseAwaitAnalysisDoneToJson(
      this,
    );
  }
}

abstract class _CustomLintResponseAwaitAnalysisDone
    implements CustomLintResponse {
  factory _CustomLintResponseAwaitAnalysisDone({required final String id}) =
      _$_CustomLintResponseAwaitAnalysisDone;

  factory _CustomLintResponseAwaitAnalysisDone.fromJson(
          Map<String, dynamic> json) =
      _$_CustomLintResponseAwaitAnalysisDone.fromJson;

  @override
  String get id;
  @override
  @JsonKey(ignore: true)
  _$$_CustomLintResponseAwaitAnalysisDoneCopyWith<
          _$_CustomLintResponseAwaitAnalysisDone>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$_CustomLintResponsePongCopyWith<$Res>
    implements $CustomLintResponseCopyWith<$Res> {
  factory _$$_CustomLintResponsePongCopyWith(_$_CustomLintResponsePong value,
          $Res Function(_$_CustomLintResponsePong) then) =
      __$$_CustomLintResponsePongCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id});
}

/// @nodoc
class __$$_CustomLintResponsePongCopyWithImpl<$Res>
    extends _$CustomLintResponseCopyWithImpl<$Res, _$_CustomLintResponsePong>
    implements _$$_CustomLintResponsePongCopyWith<$Res> {
  __$$_CustomLintResponsePongCopyWithImpl(_$_CustomLintResponsePong _value,
      $Res Function(_$_CustomLintResponsePong) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
  }) {
    return _then(_$_CustomLintResponsePong(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_CustomLintResponsePong implements _CustomLintResponsePong {
  _$_CustomLintResponsePong({required this.id, final String? $type})
      : $type = $type ?? 'pong';

  factory _$_CustomLintResponsePong.fromJson(Map<String, dynamic> json) =>
      _$$_CustomLintResponsePongFromJson(json);

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
            other is _$_CustomLintResponsePong &&
            (identical(other.id, id) || other.id == id));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_CustomLintResponsePongCopyWith<_$_CustomLintResponsePong> get copyWith =>
      __$$_CustomLintResponsePongCopyWithImpl<_$_CustomLintResponsePong>(
          this, _$identity);

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
    return _$$_CustomLintResponsePongToJson(
      this,
    );
  }
}

abstract class _CustomLintResponsePong implements CustomLintResponse {
  factory _CustomLintResponsePong({required final String id}) =
      _$_CustomLintResponsePong;

  factory _CustomLintResponsePong.fromJson(Map<String, dynamic> json) =
      _$_CustomLintResponsePong.fromJson;

  @override
  String get id;
  @override
  @JsonKey(ignore: true)
  _$$_CustomLintResponsePongCopyWith<_$_CustomLintResponsePong> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$_CustomLintResponseErrorCopyWith<$Res>
    implements $CustomLintResponseCopyWith<$Res> {
  factory _$$_CustomLintResponseErrorCopyWith(_$_CustomLintResponseError value,
          $Res Function(_$_CustomLintResponseError) then) =
      __$$_CustomLintResponseErrorCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String message, String stackTrace});
}

/// @nodoc
class __$$_CustomLintResponseErrorCopyWithImpl<$Res>
    extends _$CustomLintResponseCopyWithImpl<$Res, _$_CustomLintResponseError>
    implements _$$_CustomLintResponseErrorCopyWith<$Res> {
  __$$_CustomLintResponseErrorCopyWithImpl(_$_CustomLintResponseError _value,
      $Res Function(_$_CustomLintResponseError) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? message = null,
    Object? stackTrace = null,
  }) {
    return _then(_$_CustomLintResponseError(
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
class _$_CustomLintResponseError implements _CustomLintResponseError {
  _$_CustomLintResponseError(
      {required this.id,
      required this.message,
      required this.stackTrace,
      final String? $type})
      : $type = $type ?? 'error';

  factory _$_CustomLintResponseError.fromJson(Map<String, dynamic> json) =>
      _$$_CustomLintResponseErrorFromJson(json);

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
            other is _$_CustomLintResponseError &&
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
  _$$_CustomLintResponseErrorCopyWith<_$_CustomLintResponseError>
      get copyWith =>
          __$$_CustomLintResponseErrorCopyWithImpl<_$_CustomLintResponseError>(
              this, _$identity);

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
    return _$$_CustomLintResponseErrorToJson(
      this,
    );
  }
}

abstract class _CustomLintResponseError implements CustomLintResponse {
  factory _CustomLintResponseError(
      {required final String id,
      required final String message,
      required final String stackTrace}) = _$_CustomLintResponseError;

  factory _CustomLintResponseError.fromJson(Map<String, dynamic> json) =
      _$_CustomLintResponseError.fromJson;

  @override
  String get id;
  String get message;
  String get stackTrace;
  @override
  @JsonKey(ignore: true)
  _$$_CustomLintResponseErrorCopyWith<_$_CustomLintResponseError>
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
abstract class _$$_CustomLintEventAnalyzerPluginNotificationCopyWith<$Res> {
  factory _$$_CustomLintEventAnalyzerPluginNotificationCopyWith(
          _$_CustomLintEventAnalyzerPluginNotification value,
          $Res Function(_$_CustomLintEventAnalyzerPluginNotification) then) =
      __$$_CustomLintEventAnalyzerPluginNotificationCopyWithImpl<$Res>;
  @useResult
  $Res call({@NotificationJsonConverter() Notification notification});
}

/// @nodoc
class __$$_CustomLintEventAnalyzerPluginNotificationCopyWithImpl<$Res>
    extends _$CustomLintEventCopyWithImpl<$Res,
        _$_CustomLintEventAnalyzerPluginNotification>
    implements _$$_CustomLintEventAnalyzerPluginNotificationCopyWith<$Res> {
  __$$_CustomLintEventAnalyzerPluginNotificationCopyWithImpl(
      _$_CustomLintEventAnalyzerPluginNotification _value,
      $Res Function(_$_CustomLintEventAnalyzerPluginNotification) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? notification = null,
  }) {
    return _then(_$_CustomLintEventAnalyzerPluginNotification(
      null == notification
          ? _value.notification
          : notification // ignore: cast_nullable_to_non_nullable
              as Notification,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_CustomLintEventAnalyzerPluginNotification
    implements _CustomLintEventAnalyzerPluginNotification {
  _$_CustomLintEventAnalyzerPluginNotification(
      @NotificationJsonConverter() this.notification,
      {final String? $type})
      : $type = $type ?? 'analyzerPluginNotification';

  factory _$_CustomLintEventAnalyzerPluginNotification.fromJson(
          Map<String, dynamic> json) =>
      _$$_CustomLintEventAnalyzerPluginNotificationFromJson(json);

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
            other is _$_CustomLintEventAnalyzerPluginNotification &&
            (identical(other.notification, notification) ||
                other.notification == notification));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, notification);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_CustomLintEventAnalyzerPluginNotificationCopyWith<
          _$_CustomLintEventAnalyzerPluginNotification>
      get copyWith =>
          __$$_CustomLintEventAnalyzerPluginNotificationCopyWithImpl<
              _$_CustomLintEventAnalyzerPluginNotification>(this, _$identity);

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
    return _$$_CustomLintEventAnalyzerPluginNotificationToJson(
      this,
    );
  }
}

abstract class _CustomLintEventAnalyzerPluginNotification
    implements CustomLintEvent {
  factory _CustomLintEventAnalyzerPluginNotification(
          @NotificationJsonConverter() final Notification notification) =
      _$_CustomLintEventAnalyzerPluginNotification;

  factory _CustomLintEventAnalyzerPluginNotification.fromJson(
          Map<String, dynamic> json) =
      _$_CustomLintEventAnalyzerPluginNotification.fromJson;

  @NotificationJsonConverter()
  Notification get notification;
  @JsonKey(ignore: true)
  _$$_CustomLintEventAnalyzerPluginNotificationCopyWith<
          _$_CustomLintEventAnalyzerPluginNotification>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$_CustomLintEventErrorCopyWith<$Res> {
  factory _$$_CustomLintEventErrorCopyWith(_$_CustomLintEventError value,
          $Res Function(_$_CustomLintEventError) then) =
      __$$_CustomLintEventErrorCopyWithImpl<$Res>;
  @useResult
  $Res call({String message, String stackTrace, String? pluginName});
}

/// @nodoc
class __$$_CustomLintEventErrorCopyWithImpl<$Res>
    extends _$CustomLintEventCopyWithImpl<$Res, _$_CustomLintEventError>
    implements _$$_CustomLintEventErrorCopyWith<$Res> {
  __$$_CustomLintEventErrorCopyWithImpl(_$_CustomLintEventError _value,
      $Res Function(_$_CustomLintEventError) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? stackTrace = null,
    Object? pluginName = freezed,
  }) {
    return _then(_$_CustomLintEventError(
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
class _$_CustomLintEventError implements _CustomLintEventError {
  _$_CustomLintEventError(this.message, this.stackTrace,
      {required this.pluginName, final String? $type})
      : $type = $type ?? 'error';

  factory _$_CustomLintEventError.fromJson(Map<String, dynamic> json) =>
      _$$_CustomLintEventErrorFromJson(json);

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
            other is _$_CustomLintEventError &&
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
  _$$_CustomLintEventErrorCopyWith<_$_CustomLintEventError> get copyWith =>
      __$$_CustomLintEventErrorCopyWithImpl<_$_CustomLintEventError>(
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
    return _$$_CustomLintEventErrorToJson(
      this,
    );
  }
}

abstract class _CustomLintEventError implements CustomLintEvent {
  factory _CustomLintEventError(final String message, final String stackTrace,
      {required final String? pluginName}) = _$_CustomLintEventError;

  factory _CustomLintEventError.fromJson(Map<String, dynamic> json) =
      _$_CustomLintEventError.fromJson;

  String get message;
  String get stackTrace;
  String? get pluginName;
  @JsonKey(ignore: true)
  _$$_CustomLintEventErrorCopyWith<_$_CustomLintEventError> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$_CustomLintEventPrintCopyWith<$Res> {
  factory _$$_CustomLintEventPrintCopyWith(_$_CustomLintEventPrint value,
          $Res Function(_$_CustomLintEventPrint) then) =
      __$$_CustomLintEventPrintCopyWithImpl<$Res>;
  @useResult
  $Res call({String message, String? pluginName});
}

/// @nodoc
class __$$_CustomLintEventPrintCopyWithImpl<$Res>
    extends _$CustomLintEventCopyWithImpl<$Res, _$_CustomLintEventPrint>
    implements _$$_CustomLintEventPrintCopyWith<$Res> {
  __$$_CustomLintEventPrintCopyWithImpl(_$_CustomLintEventPrint _value,
      $Res Function(_$_CustomLintEventPrint) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? pluginName = freezed,
  }) {
    return _then(_$_CustomLintEventPrint(
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
class _$_CustomLintEventPrint implements _CustomLintEventPrint {
  _$_CustomLintEventPrint(this.message,
      {required this.pluginName, final String? $type})
      : $type = $type ?? 'print';

  factory _$_CustomLintEventPrint.fromJson(Map<String, dynamic> json) =>
      _$$_CustomLintEventPrintFromJson(json);

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
            other is _$_CustomLintEventPrint &&
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
  _$$_CustomLintEventPrintCopyWith<_$_CustomLintEventPrint> get copyWith =>
      __$$_CustomLintEventPrintCopyWithImpl<_$_CustomLintEventPrint>(
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
    return _$$_CustomLintEventPrintToJson(
      this,
    );
  }
}

abstract class _CustomLintEventPrint implements CustomLintEvent {
  factory _CustomLintEventPrint(final String message,
      {required final String? pluginName}) = _$_CustomLintEventPrint;

  factory _CustomLintEventPrint.fromJson(Map<String, dynamic> json) =
      _$_CustomLintEventPrint.fromJson;

  String get message;
  String? get pluginName;
  @JsonKey(ignore: true)
  _$$_CustomLintEventPrintCopyWith<_$_CustomLintEventPrint> get copyWith =>
      throw _privateConstructorUsedError;
}
