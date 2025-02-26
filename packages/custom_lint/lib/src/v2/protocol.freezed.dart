// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'protocol.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
CustomLintRequest _$CustomLintRequestFromJson(Map<String, dynamic> json) {
  switch (json['runtimeType']) {
    case 'analyzerPluginRequest':
      return CustomLintRequestAnalyzerPluginRequest.fromJson(json);
    case 'awaitAnalysisDone':
      return CustomLintRequestAwaitAnalysisDone.fromJson(json);
    case 'ping':
      return CustomLintRequestPing.fromJson(json);

    default:
      throw CheckedFromJsonException(json, 'runtimeType', 'CustomLintRequest',
          'Invalid union type "${json['runtimeType']}"!');
  }
}

/// @nodoc
mixin _$CustomLintRequest {
  String get id;

  /// Create a copy of CustomLintRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CustomLintRequestCopyWith<CustomLintRequest> get copyWith =>
      _$CustomLintRequestCopyWithImpl<CustomLintRequest>(
          this as CustomLintRequest, _$identity);

  /// Serializes this CustomLintRequest to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CustomLintRequest &&
            (identical(other.id, id) || other.id == id));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id);

  @override
  String toString() {
    return 'CustomLintRequest(id: $id)';
  }
}

/// @nodoc
abstract mixin class $CustomLintRequestCopyWith<$Res> {
  factory $CustomLintRequestCopyWith(
          CustomLintRequest value, $Res Function(CustomLintRequest) _then) =
      _$CustomLintRequestCopyWithImpl;
  @useResult
  $Res call({String id});
}

/// @nodoc
class _$CustomLintRequestCopyWithImpl<$Res>
    implements $CustomLintRequestCopyWith<$Res> {
  _$CustomLintRequestCopyWithImpl(this._self, this._then);

  final CustomLintRequest _self;
  final $Res Function(CustomLintRequest) _then;

  /// Create a copy of CustomLintRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class CustomLintRequestAnalyzerPluginRequest implements CustomLintRequest {
  CustomLintRequestAnalyzerPluginRequest(this.request,
      {required this.id, final String? $type})
      : $type = $type ?? 'analyzerPluginRequest';
  factory CustomLintRequestAnalyzerPluginRequest.fromJson(
          Map<String, dynamic> json) =>
      _$CustomLintRequestAnalyzerPluginRequestFromJson(json);

  final Request request;
  @override
  final String id;

  @JsonKey(name: 'runtimeType')
  final String $type;

  /// Create a copy of CustomLintRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CustomLintRequestAnalyzerPluginRequestCopyWith<
          CustomLintRequestAnalyzerPluginRequest>
      get copyWith => _$CustomLintRequestAnalyzerPluginRequestCopyWithImpl<
          CustomLintRequestAnalyzerPluginRequest>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$CustomLintRequestAnalyzerPluginRequestToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CustomLintRequestAnalyzerPluginRequest &&
            (identical(other.request, request) || other.request == request) &&
            (identical(other.id, id) || other.id == id));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, request, id);

  @override
  String toString() {
    return 'CustomLintRequest.analyzerPluginRequest(request: $request, id: $id)';
  }
}

/// @nodoc
abstract mixin class $CustomLintRequestAnalyzerPluginRequestCopyWith<$Res>
    implements $CustomLintRequestCopyWith<$Res> {
  factory $CustomLintRequestAnalyzerPluginRequestCopyWith(
          CustomLintRequestAnalyzerPluginRequest value,
          $Res Function(CustomLintRequestAnalyzerPluginRequest) _then) =
      _$CustomLintRequestAnalyzerPluginRequestCopyWithImpl;
  @override
  @useResult
  $Res call({Request request, String id});
}

/// @nodoc
class _$CustomLintRequestAnalyzerPluginRequestCopyWithImpl<$Res>
    implements $CustomLintRequestAnalyzerPluginRequestCopyWith<$Res> {
  _$CustomLintRequestAnalyzerPluginRequestCopyWithImpl(this._self, this._then);

  final CustomLintRequestAnalyzerPluginRequest _self;
  final $Res Function(CustomLintRequestAnalyzerPluginRequest) _then;

  /// Create a copy of CustomLintRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? request = null,
    Object? id = null,
  }) {
    return _then(CustomLintRequestAnalyzerPluginRequest(
      null == request
          ? _self.request
          : request // ignore: cast_nullable_to_non_nullable
              as Request,
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class CustomLintRequestAwaitAnalysisDone implements CustomLintRequest {
  CustomLintRequestAwaitAnalysisDone(
      {required this.id, required this.reload, final String? $type})
      : $type = $type ?? 'awaitAnalysisDone';
  factory CustomLintRequestAwaitAnalysisDone.fromJson(
          Map<String, dynamic> json) =>
      _$CustomLintRequestAwaitAnalysisDoneFromJson(json);

  @override
  final String id;
  final bool reload;

  @JsonKey(name: 'runtimeType')
  final String $type;

  /// Create a copy of CustomLintRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CustomLintRequestAwaitAnalysisDoneCopyWith<
          CustomLintRequestAwaitAnalysisDone>
      get copyWith => _$CustomLintRequestAwaitAnalysisDoneCopyWithImpl<
          CustomLintRequestAwaitAnalysisDone>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$CustomLintRequestAwaitAnalysisDoneToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CustomLintRequestAwaitAnalysisDone &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.reload, reload) || other.reload == reload));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, reload);

  @override
  String toString() {
    return 'CustomLintRequest.awaitAnalysisDone(id: $id, reload: $reload)';
  }
}

/// @nodoc
abstract mixin class $CustomLintRequestAwaitAnalysisDoneCopyWith<$Res>
    implements $CustomLintRequestCopyWith<$Res> {
  factory $CustomLintRequestAwaitAnalysisDoneCopyWith(
          CustomLintRequestAwaitAnalysisDone value,
          $Res Function(CustomLintRequestAwaitAnalysisDone) _then) =
      _$CustomLintRequestAwaitAnalysisDoneCopyWithImpl;
  @override
  @useResult
  $Res call({String id, bool reload});
}

/// @nodoc
class _$CustomLintRequestAwaitAnalysisDoneCopyWithImpl<$Res>
    implements $CustomLintRequestAwaitAnalysisDoneCopyWith<$Res> {
  _$CustomLintRequestAwaitAnalysisDoneCopyWithImpl(this._self, this._then);

  final CustomLintRequestAwaitAnalysisDone _self;
  final $Res Function(CustomLintRequestAwaitAnalysisDone) _then;

  /// Create a copy of CustomLintRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? reload = null,
  }) {
    return _then(CustomLintRequestAwaitAnalysisDone(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      reload: null == reload
          ? _self.reload
          : reload // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class CustomLintRequestPing implements CustomLintRequest {
  CustomLintRequestPing({required this.id, final String? $type})
      : $type = $type ?? 'ping';
  factory CustomLintRequestPing.fromJson(Map<String, dynamic> json) =>
      _$CustomLintRequestPingFromJson(json);

  @override
  final String id;

  @JsonKey(name: 'runtimeType')
  final String $type;

  /// Create a copy of CustomLintRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CustomLintRequestPingCopyWith<CustomLintRequestPing> get copyWith =>
      _$CustomLintRequestPingCopyWithImpl<CustomLintRequestPing>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$CustomLintRequestPingToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CustomLintRequestPing &&
            (identical(other.id, id) || other.id == id));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id);

  @override
  String toString() {
    return 'CustomLintRequest.ping(id: $id)';
  }
}

/// @nodoc
abstract mixin class $CustomLintRequestPingCopyWith<$Res>
    implements $CustomLintRequestCopyWith<$Res> {
  factory $CustomLintRequestPingCopyWith(CustomLintRequestPing value,
          $Res Function(CustomLintRequestPing) _then) =
      _$CustomLintRequestPingCopyWithImpl;
  @override
  @useResult
  $Res call({String id});
}

/// @nodoc
class _$CustomLintRequestPingCopyWithImpl<$Res>
    implements $CustomLintRequestPingCopyWith<$Res> {
  _$CustomLintRequestPingCopyWithImpl(this._self, this._then);

  final CustomLintRequestPing _self;
  final $Res Function(CustomLintRequestPing) _then;

  /// Create a copy of CustomLintRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
  }) {
    return _then(CustomLintRequestPing(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

CustomLintResponse _$CustomLintResponseFromJson(Map<String, dynamic> json) {
  switch (json['runtimeType']) {
    case 'analyzerPluginResponse':
      return CustomLintResponseAnalyzerPluginResponse.fromJson(json);
    case 'awaitAnalysisDone':
      return CustomLintResponseAwaitAnalysisDone.fromJson(json);
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
  String get id;

  /// Create a copy of CustomLintResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CustomLintResponseCopyWith<CustomLintResponse> get copyWith =>
      _$CustomLintResponseCopyWithImpl<CustomLintResponse>(
          this as CustomLintResponse, _$identity);

  /// Serializes this CustomLintResponse to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CustomLintResponse &&
            (identical(other.id, id) || other.id == id));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id);

  @override
  String toString() {
    return 'CustomLintResponse(id: $id)';
  }
}

/// @nodoc
abstract mixin class $CustomLintResponseCopyWith<$Res> {
  factory $CustomLintResponseCopyWith(
          CustomLintResponse value, $Res Function(CustomLintResponse) _then) =
      _$CustomLintResponseCopyWithImpl;
  @useResult
  $Res call({String id});
}

/// @nodoc
class _$CustomLintResponseCopyWithImpl<$Res>
    implements $CustomLintResponseCopyWith<$Res> {
  _$CustomLintResponseCopyWithImpl(this._self, this._then);

  final CustomLintResponse _self;
  final $Res Function(CustomLintResponse) _then;

  /// Create a copy of CustomLintResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class CustomLintResponseAnalyzerPluginResponse implements CustomLintResponse {
  CustomLintResponseAnalyzerPluginResponse(this.response,
      {required this.id, final String? $type})
      : $type = $type ?? 'analyzerPluginResponse';
  factory CustomLintResponseAnalyzerPluginResponse.fromJson(
          Map<String, dynamic> json) =>
      _$CustomLintResponseAnalyzerPluginResponseFromJson(json);

  final Response response;
  @override
  final String id;

  @JsonKey(name: 'runtimeType')
  final String $type;

  /// Create a copy of CustomLintResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CustomLintResponseAnalyzerPluginResponseCopyWith<
          CustomLintResponseAnalyzerPluginResponse>
      get copyWith => _$CustomLintResponseAnalyzerPluginResponseCopyWithImpl<
          CustomLintResponseAnalyzerPluginResponse>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$CustomLintResponseAnalyzerPluginResponseToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CustomLintResponseAnalyzerPluginResponse &&
            (identical(other.response, response) ||
                other.response == response) &&
            (identical(other.id, id) || other.id == id));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, response, id);

  @override
  String toString() {
    return 'CustomLintResponse.analyzerPluginResponse(response: $response, id: $id)';
  }
}

/// @nodoc
abstract mixin class $CustomLintResponseAnalyzerPluginResponseCopyWith<$Res>
    implements $CustomLintResponseCopyWith<$Res> {
  factory $CustomLintResponseAnalyzerPluginResponseCopyWith(
          CustomLintResponseAnalyzerPluginResponse value,
          $Res Function(CustomLintResponseAnalyzerPluginResponse) _then) =
      _$CustomLintResponseAnalyzerPluginResponseCopyWithImpl;
  @override
  @useResult
  $Res call({Response response, String id});
}

/// @nodoc
class _$CustomLintResponseAnalyzerPluginResponseCopyWithImpl<$Res>
    implements $CustomLintResponseAnalyzerPluginResponseCopyWith<$Res> {
  _$CustomLintResponseAnalyzerPluginResponseCopyWithImpl(
      this._self, this._then);

  final CustomLintResponseAnalyzerPluginResponse _self;
  final $Res Function(CustomLintResponseAnalyzerPluginResponse) _then;

  /// Create a copy of CustomLintResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? response = null,
    Object? id = null,
  }) {
    return _then(CustomLintResponseAnalyzerPluginResponse(
      null == response
          ? _self.response
          : response // ignore: cast_nullable_to_non_nullable
              as Response,
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class CustomLintResponseAwaitAnalysisDone implements CustomLintResponse {
  CustomLintResponseAwaitAnalysisDone({required this.id, final String? $type})
      : $type = $type ?? 'awaitAnalysisDone';
  factory CustomLintResponseAwaitAnalysisDone.fromJson(
          Map<String, dynamic> json) =>
      _$CustomLintResponseAwaitAnalysisDoneFromJson(json);

  @override
  final String id;

  @JsonKey(name: 'runtimeType')
  final String $type;

  /// Create a copy of CustomLintResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CustomLintResponseAwaitAnalysisDoneCopyWith<
          CustomLintResponseAwaitAnalysisDone>
      get copyWith => _$CustomLintResponseAwaitAnalysisDoneCopyWithImpl<
          CustomLintResponseAwaitAnalysisDone>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$CustomLintResponseAwaitAnalysisDoneToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CustomLintResponseAwaitAnalysisDone &&
            (identical(other.id, id) || other.id == id));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id);

  @override
  String toString() {
    return 'CustomLintResponse.awaitAnalysisDone(id: $id)';
  }
}

/// @nodoc
abstract mixin class $CustomLintResponseAwaitAnalysisDoneCopyWith<$Res>
    implements $CustomLintResponseCopyWith<$Res> {
  factory $CustomLintResponseAwaitAnalysisDoneCopyWith(
          CustomLintResponseAwaitAnalysisDone value,
          $Res Function(CustomLintResponseAwaitAnalysisDone) _then) =
      _$CustomLintResponseAwaitAnalysisDoneCopyWithImpl;
  @override
  @useResult
  $Res call({String id});
}

/// @nodoc
class _$CustomLintResponseAwaitAnalysisDoneCopyWithImpl<$Res>
    implements $CustomLintResponseAwaitAnalysisDoneCopyWith<$Res> {
  _$CustomLintResponseAwaitAnalysisDoneCopyWithImpl(this._self, this._then);

  final CustomLintResponseAwaitAnalysisDone _self;
  final $Res Function(CustomLintResponseAwaitAnalysisDone) _then;

  /// Create a copy of CustomLintResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
  }) {
    return _then(CustomLintResponseAwaitAnalysisDone(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class CustomLintResponsePong implements CustomLintResponse {
  CustomLintResponsePong({required this.id, final String? $type})
      : $type = $type ?? 'pong';
  factory CustomLintResponsePong.fromJson(Map<String, dynamic> json) =>
      _$CustomLintResponsePongFromJson(json);

  @override
  final String id;

  @JsonKey(name: 'runtimeType')
  final String $type;

  /// Create a copy of CustomLintResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CustomLintResponsePongCopyWith<CustomLintResponsePong> get copyWith =>
      _$CustomLintResponsePongCopyWithImpl<CustomLintResponsePong>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$CustomLintResponsePongToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CustomLintResponsePong &&
            (identical(other.id, id) || other.id == id));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id);

  @override
  String toString() {
    return 'CustomLintResponse.pong(id: $id)';
  }
}

/// @nodoc
abstract mixin class $CustomLintResponsePongCopyWith<$Res>
    implements $CustomLintResponseCopyWith<$Res> {
  factory $CustomLintResponsePongCopyWith(CustomLintResponsePong value,
          $Res Function(CustomLintResponsePong) _then) =
      _$CustomLintResponsePongCopyWithImpl;
  @override
  @useResult
  $Res call({String id});
}

/// @nodoc
class _$CustomLintResponsePongCopyWithImpl<$Res>
    implements $CustomLintResponsePongCopyWith<$Res> {
  _$CustomLintResponsePongCopyWithImpl(this._self, this._then);

  final CustomLintResponsePong _self;
  final $Res Function(CustomLintResponsePong) _then;

  /// Create a copy of CustomLintResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
  }) {
    return _then(CustomLintResponsePong(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class CustomLintResponseError implements CustomLintResponse {
  CustomLintResponseError(
      {required this.id,
      required this.message,
      required this.stackTrace,
      final String? $type})
      : $type = $type ?? 'error';
  factory CustomLintResponseError.fromJson(Map<String, dynamic> json) =>
      _$CustomLintResponseErrorFromJson(json);

  @override
  final String id;
  final String message;
  final String stackTrace;

  @JsonKey(name: 'runtimeType')
  final String $type;

  /// Create a copy of CustomLintResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CustomLintResponseErrorCopyWith<CustomLintResponseError> get copyWith =>
      _$CustomLintResponseErrorCopyWithImpl<CustomLintResponseError>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$CustomLintResponseErrorToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CustomLintResponseError &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.stackTrace, stackTrace) ||
                other.stackTrace == stackTrace));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, message, stackTrace);

  @override
  String toString() {
    return 'CustomLintResponse.error(id: $id, message: $message, stackTrace: $stackTrace)';
  }
}

/// @nodoc
abstract mixin class $CustomLintResponseErrorCopyWith<$Res>
    implements $CustomLintResponseCopyWith<$Res> {
  factory $CustomLintResponseErrorCopyWith(CustomLintResponseError value,
          $Res Function(CustomLintResponseError) _then) =
      _$CustomLintResponseErrorCopyWithImpl;
  @override
  @useResult
  $Res call({String id, String message, String stackTrace});
}

/// @nodoc
class _$CustomLintResponseErrorCopyWithImpl<$Res>
    implements $CustomLintResponseErrorCopyWith<$Res> {
  _$CustomLintResponseErrorCopyWithImpl(this._self, this._then);

  final CustomLintResponseError _self;
  final $Res Function(CustomLintResponseError) _then;

  /// Create a copy of CustomLintResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? message = null,
    Object? stackTrace = null,
  }) {
    return _then(CustomLintResponseError(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      stackTrace: null == stackTrace
          ? _self.stackTrace
          : stackTrace // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
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
  /// Serializes this CustomLintMessage to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is CustomLintMessage);
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'CustomLintMessage()';
  }
}

/// @nodoc
@JsonSerializable()
class CustomLintMessageEvent implements CustomLintMessage {
  CustomLintMessageEvent(this.event, {final String? $type})
      : $type = $type ?? 'event';
  factory CustomLintMessageEvent.fromJson(Map<String, dynamic> json) =>
      _$CustomLintMessageEventFromJson(json);

  final CustomLintEvent event;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  Map<String, dynamic> toJson() {
    return _$CustomLintMessageEventToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CustomLintMessageEvent &&
            (identical(other.event, event) || other.event == event));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, event);

  @override
  String toString() {
    return 'CustomLintMessage.event(event: $event)';
  }
}

/// @nodoc
@JsonSerializable()
class CustomLintMessageResponse implements CustomLintMessage {
  CustomLintMessageResponse(this.response, {final String? $type})
      : $type = $type ?? 'response';
  factory CustomLintMessageResponse.fromJson(Map<String, dynamic> json) =>
      _$CustomLintMessageResponseFromJson(json);

  final CustomLintResponse response;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  Map<String, dynamic> toJson() {
    return _$CustomLintMessageResponseToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CustomLintMessageResponse &&
            (identical(other.response, response) ||
                other.response == response));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, response);

  @override
  String toString() {
    return 'CustomLintMessage.response(response: $response)';
  }
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
  /// Serializes this CustomLintEvent to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is CustomLintEvent);
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'CustomLintEvent()';
  }
}

/// @nodoc
@JsonSerializable()
class CustomLintEventAnalyzerPluginNotification implements CustomLintEvent {
  CustomLintEventAnalyzerPluginNotification(
      @NotificationJsonConverter() this.notification,
      {final String? $type})
      : $type = $type ?? 'analyzerPluginNotification';
  factory CustomLintEventAnalyzerPluginNotification.fromJson(
          Map<String, dynamic> json) =>
      _$CustomLintEventAnalyzerPluginNotificationFromJson(json);

  @NotificationJsonConverter()
  final Notification notification;

  @JsonKey(name: 'runtimeType')
  final String $type;

  /// Create a copy of CustomLintEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CustomLintEventAnalyzerPluginNotificationCopyWith<
          CustomLintEventAnalyzerPluginNotification>
      get copyWith => _$CustomLintEventAnalyzerPluginNotificationCopyWithImpl<
          CustomLintEventAnalyzerPluginNotification>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$CustomLintEventAnalyzerPluginNotificationToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CustomLintEventAnalyzerPluginNotification &&
            (identical(other.notification, notification) ||
                other.notification == notification));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, notification);

  @override
  String toString() {
    return 'CustomLintEvent.analyzerPluginNotification(notification: $notification)';
  }
}

/// @nodoc
abstract mixin class $CustomLintEventAnalyzerPluginNotificationCopyWith<$Res> {
  factory $CustomLintEventAnalyzerPluginNotificationCopyWith(
          CustomLintEventAnalyzerPluginNotification value,
          $Res Function(CustomLintEventAnalyzerPluginNotification) _then) =
      _$CustomLintEventAnalyzerPluginNotificationCopyWithImpl;
  @useResult
  $Res call({@NotificationJsonConverter() Notification notification});
}

/// @nodoc
class _$CustomLintEventAnalyzerPluginNotificationCopyWithImpl<$Res>
    implements $CustomLintEventAnalyzerPluginNotificationCopyWith<$Res> {
  _$CustomLintEventAnalyzerPluginNotificationCopyWithImpl(
      this._self, this._then);

  final CustomLintEventAnalyzerPluginNotification _self;
  final $Res Function(CustomLintEventAnalyzerPluginNotification) _then;

  /// Create a copy of CustomLintEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? notification = null,
  }) {
    return _then(CustomLintEventAnalyzerPluginNotification(
      null == notification
          ? _self.notification
          : notification // ignore: cast_nullable_to_non_nullable
              as Notification,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class CustomLintEventError implements CustomLintEvent {
  CustomLintEventError(this.message, this.stackTrace,
      {required this.pluginName, final String? $type})
      : $type = $type ?? 'error';
  factory CustomLintEventError.fromJson(Map<String, dynamic> json) =>
      _$CustomLintEventErrorFromJson(json);

  final String message;
  final String stackTrace;
  final String? pluginName;

  @JsonKey(name: 'runtimeType')
  final String $type;

  /// Create a copy of CustomLintEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CustomLintEventErrorCopyWith<CustomLintEventError> get copyWith =>
      _$CustomLintEventErrorCopyWithImpl<CustomLintEventError>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$CustomLintEventErrorToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CustomLintEventError &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.stackTrace, stackTrace) ||
                other.stackTrace == stackTrace) &&
            (identical(other.pluginName, pluginName) ||
                other.pluginName == pluginName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, message, stackTrace, pluginName);

  @override
  String toString() {
    return 'CustomLintEvent.error(message: $message, stackTrace: $stackTrace, pluginName: $pluginName)';
  }
}

/// @nodoc
abstract mixin class $CustomLintEventErrorCopyWith<$Res> {
  factory $CustomLintEventErrorCopyWith(CustomLintEventError value,
          $Res Function(CustomLintEventError) _then) =
      _$CustomLintEventErrorCopyWithImpl;
  @useResult
  $Res call({String message, String stackTrace, String? pluginName});
}

/// @nodoc
class _$CustomLintEventErrorCopyWithImpl<$Res>
    implements $CustomLintEventErrorCopyWith<$Res> {
  _$CustomLintEventErrorCopyWithImpl(this._self, this._then);

  final CustomLintEventError _self;
  final $Res Function(CustomLintEventError) _then;

  /// Create a copy of CustomLintEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? message = null,
    Object? stackTrace = null,
    Object? pluginName = freezed,
  }) {
    return _then(CustomLintEventError(
      null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      null == stackTrace
          ? _self.stackTrace
          : stackTrace // ignore: cast_nullable_to_non_nullable
              as String,
      pluginName: freezed == pluginName
          ? _self.pluginName
          : pluginName // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class CustomLintEventPrint implements CustomLintEvent {
  CustomLintEventPrint(this.message,
      {required this.pluginName, final String? $type})
      : $type = $type ?? 'print';
  factory CustomLintEventPrint.fromJson(Map<String, dynamic> json) =>
      _$CustomLintEventPrintFromJson(json);

  final String message;
  final String? pluginName;

  @JsonKey(name: 'runtimeType')
  final String $type;

  /// Create a copy of CustomLintEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CustomLintEventPrintCopyWith<CustomLintEventPrint> get copyWith =>
      _$CustomLintEventPrintCopyWithImpl<CustomLintEventPrint>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$CustomLintEventPrintToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CustomLintEventPrint &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.pluginName, pluginName) ||
                other.pluginName == pluginName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, message, pluginName);

  @override
  String toString() {
    return 'CustomLintEvent.print(message: $message, pluginName: $pluginName)';
  }
}

/// @nodoc
abstract mixin class $CustomLintEventPrintCopyWith<$Res> {
  factory $CustomLintEventPrintCopyWith(CustomLintEventPrint value,
          $Res Function(CustomLintEventPrint) _then) =
      _$CustomLintEventPrintCopyWithImpl;
  @useResult
  $Res call({String message, String? pluginName});
}

/// @nodoc
class _$CustomLintEventPrintCopyWithImpl<$Res>
    implements $CustomLintEventPrintCopyWith<$Res> {
  _$CustomLintEventPrintCopyWithImpl(this._self, this._then);

  final CustomLintEventPrint _self;
  final $Res Function(CustomLintEventPrint) _then;

  /// Create a copy of CustomLintEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? message = null,
    Object? pluginName = freezed,
  }) {
    return _then(CustomLintEventPrint(
      null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      pluginName: freezed == pluginName
          ? _self.pluginName
          : pluginName // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
