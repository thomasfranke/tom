// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'github_api_failure.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GithubApiFailure {

 AppFailure? get cause;
/// Create a copy of GithubApiFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GithubApiFailureCopyWith<GithubApiFailure> get copyWith => _$GithubApiFailureCopyWithImpl<GithubApiFailure>(this as GithubApiFailure, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GithubApiFailure&&(identical(other.cause, cause) || other.cause == cause));
}


@override
int get hashCode => Object.hash(runtimeType,cause);

@override
String toString() {
  return 'GithubApiFailure(cause: $cause)';
}


}

/// @nodoc
abstract mixin class $GithubApiFailureCopyWith<$Res>  {
  factory $GithubApiFailureCopyWith(GithubApiFailure value, $Res Function(GithubApiFailure) _then) = _$GithubApiFailureCopyWithImpl;
@useResult
$Res call({
 AppFailure? cause
});




}
/// @nodoc
class _$GithubApiFailureCopyWithImpl<$Res>
    implements $GithubApiFailureCopyWith<$Res> {
  _$GithubApiFailureCopyWithImpl(this._self, this._then);

  final GithubApiFailure _self;
  final $Res Function(GithubApiFailure) _then;

/// Create a copy of GithubApiFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? cause = freezed,}) {
  return _then(_self.copyWith(
cause: freezed == cause ? _self.cause : cause // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}

}


/// Adds pattern-matching-related methods to [GithubApiFailure].
extension GithubApiFailurePatterns on GithubApiFailure {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( GithubApiUnavailable value)?  unavailable,TResult Function( GithubApiUnreachable value)?  unreachable,TResult Function( GithubApiRefused value)?  refused,TResult Function( GithubApiNotFound value)?  notFound,TResult Function( GithubApiPullRequestExists value)?  pullRequestExists,TResult Function( GithubApiCommandDenied value)?  commandDenied,TResult Function( GithubApiOperationFailed value)?  operationFailed,required TResult orElse(),}){
final _that = this;
switch (_that) {
case GithubApiUnavailable() when unavailable != null:
return unavailable(_that);case GithubApiUnreachable() when unreachable != null:
return unreachable(_that);case GithubApiRefused() when refused != null:
return refused(_that);case GithubApiNotFound() when notFound != null:
return notFound(_that);case GithubApiPullRequestExists() when pullRequestExists != null:
return pullRequestExists(_that);case GithubApiCommandDenied() when commandDenied != null:
return commandDenied(_that);case GithubApiOperationFailed() when operationFailed != null:
return operationFailed(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( GithubApiUnavailable value)  unavailable,required TResult Function( GithubApiUnreachable value)  unreachable,required TResult Function( GithubApiRefused value)  refused,required TResult Function( GithubApiNotFound value)  notFound,required TResult Function( GithubApiPullRequestExists value)  pullRequestExists,required TResult Function( GithubApiCommandDenied value)  commandDenied,required TResult Function( GithubApiOperationFailed value)  operationFailed,}){
final _that = this;
switch (_that) {
case GithubApiUnavailable():
return unavailable(_that);case GithubApiUnreachable():
return unreachable(_that);case GithubApiRefused():
return refused(_that);case GithubApiNotFound():
return notFound(_that);case GithubApiPullRequestExists():
return pullRequestExists(_that);case GithubApiCommandDenied():
return commandDenied(_that);case GithubApiOperationFailed():
return operationFailed(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( GithubApiUnavailable value)?  unavailable,TResult? Function( GithubApiUnreachable value)?  unreachable,TResult? Function( GithubApiRefused value)?  refused,TResult? Function( GithubApiNotFound value)?  notFound,TResult? Function( GithubApiPullRequestExists value)?  pullRequestExists,TResult? Function( GithubApiCommandDenied value)?  commandDenied,TResult? Function( GithubApiOperationFailed value)?  operationFailed,}){
final _that = this;
switch (_that) {
case GithubApiUnavailable() when unavailable != null:
return unavailable(_that);case GithubApiUnreachable() when unreachable != null:
return unreachable(_that);case GithubApiRefused() when refused != null:
return refused(_that);case GithubApiNotFound() when notFound != null:
return notFound(_that);case GithubApiPullRequestExists() when pullRequestExists != null:
return pullRequestExists(_that);case GithubApiCommandDenied() when commandDenied != null:
return commandDenied(_that);case GithubApiOperationFailed() when operationFailed != null:
return operationFailed(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String program,  AppFailure? cause)?  unavailable,TResult Function( String description,  AppFailure? cause)?  unreachable,TResult Function( int status,  AppFailure? cause)?  refused,TResult Function( AppFailure? cause)?  notFound,TResult Function( String address,  AppFailure? cause)?  pullRequestExists,TResult Function( String command,  AppFailure? cause)?  commandDenied,TResult Function( String description,  AppFailure? cause)?  operationFailed,required TResult orElse(),}) {final _that = this;
switch (_that) {
case GithubApiUnavailable() when unavailable != null:
return unavailable(_that.program,_that.cause);case GithubApiUnreachable() when unreachable != null:
return unreachable(_that.description,_that.cause);case GithubApiRefused() when refused != null:
return refused(_that.status,_that.cause);case GithubApiNotFound() when notFound != null:
return notFound(_that.cause);case GithubApiPullRequestExists() when pullRequestExists != null:
return pullRequestExists(_that.address,_that.cause);case GithubApiCommandDenied() when commandDenied != null:
return commandDenied(_that.command,_that.cause);case GithubApiOperationFailed() when operationFailed != null:
return operationFailed(_that.description,_that.cause);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String program,  AppFailure? cause)  unavailable,required TResult Function( String description,  AppFailure? cause)  unreachable,required TResult Function( int status,  AppFailure? cause)  refused,required TResult Function( AppFailure? cause)  notFound,required TResult Function( String address,  AppFailure? cause)  pullRequestExists,required TResult Function( String command,  AppFailure? cause)  commandDenied,required TResult Function( String description,  AppFailure? cause)  operationFailed,}) {final _that = this;
switch (_that) {
case GithubApiUnavailable():
return unavailable(_that.program,_that.cause);case GithubApiUnreachable():
return unreachable(_that.description,_that.cause);case GithubApiRefused():
return refused(_that.status,_that.cause);case GithubApiNotFound():
return notFound(_that.cause);case GithubApiPullRequestExists():
return pullRequestExists(_that.address,_that.cause);case GithubApiCommandDenied():
return commandDenied(_that.command,_that.cause);case GithubApiOperationFailed():
return operationFailed(_that.description,_that.cause);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String program,  AppFailure? cause)?  unavailable,TResult? Function( String description,  AppFailure? cause)?  unreachable,TResult? Function( int status,  AppFailure? cause)?  refused,TResult? Function( AppFailure? cause)?  notFound,TResult? Function( String address,  AppFailure? cause)?  pullRequestExists,TResult? Function( String command,  AppFailure? cause)?  commandDenied,TResult? Function( String description,  AppFailure? cause)?  operationFailed,}) {final _that = this;
switch (_that) {
case GithubApiUnavailable() when unavailable != null:
return unavailable(_that.program,_that.cause);case GithubApiUnreachable() when unreachable != null:
return unreachable(_that.description,_that.cause);case GithubApiRefused() when refused != null:
return refused(_that.status,_that.cause);case GithubApiNotFound() when notFound != null:
return notFound(_that.cause);case GithubApiPullRequestExists() when pullRequestExists != null:
return pullRequestExists(_that.address,_that.cause);case GithubApiCommandDenied() when commandDenied != null:
return commandDenied(_that.command,_that.cause);case GithubApiOperationFailed() when operationFailed != null:
return operationFailed(_that.description,_that.cause);case _:
  return null;

}
}

}

/// @nodoc


class GithubApiUnavailable implements GithubApiFailure {
  const GithubApiUnavailable(this.program, {this.cause});
  

/// The program that was looked for.
 final  String program;
@override final  AppFailure? cause;

/// Create a copy of GithubApiFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GithubApiUnavailableCopyWith<GithubApiUnavailable> get copyWith => _$GithubApiUnavailableCopyWithImpl<GithubApiUnavailable>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GithubApiUnavailable&&(identical(other.program, program) || other.program == program)&&(identical(other.cause, cause) || other.cause == cause));
}


@override
int get hashCode => Object.hash(runtimeType,program,cause);

@override
String toString() {
  return 'GithubApiFailure.unavailable(program: $program, cause: $cause)';
}


}

/// @nodoc
abstract mixin class $GithubApiUnavailableCopyWith<$Res> implements $GithubApiFailureCopyWith<$Res> {
  factory $GithubApiUnavailableCopyWith(GithubApiUnavailable value, $Res Function(GithubApiUnavailable) _then) = _$GithubApiUnavailableCopyWithImpl;
@override @useResult
$Res call({
 String program, AppFailure? cause
});




}
/// @nodoc
class _$GithubApiUnavailableCopyWithImpl<$Res>
    implements $GithubApiUnavailableCopyWith<$Res> {
  _$GithubApiUnavailableCopyWithImpl(this._self, this._then);

  final GithubApiUnavailable _self;
  final $Res Function(GithubApiUnavailable) _then;

/// Create a copy of GithubApiFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? program = null,Object? cause = freezed,}) {
  return _then(GithubApiUnavailable(
null == program ? _self.program : program // ignore: cast_nullable_to_non_nullable
as String,cause: freezed == cause ? _self.cause : cause // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}


}

/// @nodoc


class GithubApiUnreachable implements GithubApiFailure {
  const GithubApiUnreachable(this.description, {this.cause});
  

/// What was said about the connection. For diagnostics — never parsed.
 final  String description;
@override final  AppFailure? cause;

/// Create a copy of GithubApiFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GithubApiUnreachableCopyWith<GithubApiUnreachable> get copyWith => _$GithubApiUnreachableCopyWithImpl<GithubApiUnreachable>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GithubApiUnreachable&&(identical(other.description, description) || other.description == description)&&(identical(other.cause, cause) || other.cause == cause));
}


@override
int get hashCode => Object.hash(runtimeType,description,cause);

@override
String toString() {
  return 'GithubApiFailure.unreachable(description: $description, cause: $cause)';
}


}

/// @nodoc
abstract mixin class $GithubApiUnreachableCopyWith<$Res> implements $GithubApiFailureCopyWith<$Res> {
  factory $GithubApiUnreachableCopyWith(GithubApiUnreachable value, $Res Function(GithubApiUnreachable) _then) = _$GithubApiUnreachableCopyWithImpl;
@override @useResult
$Res call({
 String description, AppFailure? cause
});




}
/// @nodoc
class _$GithubApiUnreachableCopyWithImpl<$Res>
    implements $GithubApiUnreachableCopyWith<$Res> {
  _$GithubApiUnreachableCopyWithImpl(this._self, this._then);

  final GithubApiUnreachable _self;
  final $Res Function(GithubApiUnreachable) _then;

/// Create a copy of GithubApiFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? description = null,Object? cause = freezed,}) {
  return _then(GithubApiUnreachable(
null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,cause: freezed == cause ? _self.cause : cause // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}


}

/// @nodoc


class GithubApiRefused implements GithubApiFailure {
  const GithubApiRefused(this.status, {this.cause});
  

/// The status it answered.
 final  int status;
@override final  AppFailure? cause;

/// Create a copy of GithubApiFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GithubApiRefusedCopyWith<GithubApiRefused> get copyWith => _$GithubApiRefusedCopyWithImpl<GithubApiRefused>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GithubApiRefused&&(identical(other.status, status) || other.status == status)&&(identical(other.cause, cause) || other.cause == cause));
}


@override
int get hashCode => Object.hash(runtimeType,status,cause);

@override
String toString() {
  return 'GithubApiFailure.refused(status: $status, cause: $cause)';
}


}

/// @nodoc
abstract mixin class $GithubApiRefusedCopyWith<$Res> implements $GithubApiFailureCopyWith<$Res> {
  factory $GithubApiRefusedCopyWith(GithubApiRefused value, $Res Function(GithubApiRefused) _then) = _$GithubApiRefusedCopyWithImpl;
@override @useResult
$Res call({
 int status, AppFailure? cause
});




}
/// @nodoc
class _$GithubApiRefusedCopyWithImpl<$Res>
    implements $GithubApiRefusedCopyWith<$Res> {
  _$GithubApiRefusedCopyWithImpl(this._self, this._then);

  final GithubApiRefused _self;
  final $Res Function(GithubApiRefused) _then;

/// Create a copy of GithubApiFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? cause = freezed,}) {
  return _then(GithubApiRefused(
null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int,cause: freezed == cause ? _self.cause : cause // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}


}

/// @nodoc


class GithubApiNotFound implements GithubApiFailure {
  const GithubApiNotFound({this.cause});
  

@override final  AppFailure? cause;

/// Create a copy of GithubApiFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GithubApiNotFoundCopyWith<GithubApiNotFound> get copyWith => _$GithubApiNotFoundCopyWithImpl<GithubApiNotFound>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GithubApiNotFound&&(identical(other.cause, cause) || other.cause == cause));
}


@override
int get hashCode => Object.hash(runtimeType,cause);

@override
String toString() {
  return 'GithubApiFailure.notFound(cause: $cause)';
}


}

/// @nodoc
abstract mixin class $GithubApiNotFoundCopyWith<$Res> implements $GithubApiFailureCopyWith<$Res> {
  factory $GithubApiNotFoundCopyWith(GithubApiNotFound value, $Res Function(GithubApiNotFound) _then) = _$GithubApiNotFoundCopyWithImpl;
@override @useResult
$Res call({
 AppFailure? cause
});




}
/// @nodoc
class _$GithubApiNotFoundCopyWithImpl<$Res>
    implements $GithubApiNotFoundCopyWith<$Res> {
  _$GithubApiNotFoundCopyWithImpl(this._self, this._then);

  final GithubApiNotFound _self;
  final $Res Function(GithubApiNotFound) _then;

/// Create a copy of GithubApiFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? cause = freezed,}) {
  return _then(GithubApiNotFound(
cause: freezed == cause ? _self.cause : cause // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}


}

/// @nodoc


class GithubApiPullRequestExists implements GithubApiFailure {
  const GithubApiPullRequestExists(this.address, {this.cause});
  

/// The open pull request's page, as GitHub printed it.
 final  String address;
@override final  AppFailure? cause;

/// Create a copy of GithubApiFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GithubApiPullRequestExistsCopyWith<GithubApiPullRequestExists> get copyWith => _$GithubApiPullRequestExistsCopyWithImpl<GithubApiPullRequestExists>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GithubApiPullRequestExists&&(identical(other.address, address) || other.address == address)&&(identical(other.cause, cause) || other.cause == cause));
}


@override
int get hashCode => Object.hash(runtimeType,address,cause);

@override
String toString() {
  return 'GithubApiFailure.pullRequestExists(address: $address, cause: $cause)';
}


}

/// @nodoc
abstract mixin class $GithubApiPullRequestExistsCopyWith<$Res> implements $GithubApiFailureCopyWith<$Res> {
  factory $GithubApiPullRequestExistsCopyWith(GithubApiPullRequestExists value, $Res Function(GithubApiPullRequestExists) _then) = _$GithubApiPullRequestExistsCopyWithImpl;
@override @useResult
$Res call({
 String address, AppFailure? cause
});




}
/// @nodoc
class _$GithubApiPullRequestExistsCopyWithImpl<$Res>
    implements $GithubApiPullRequestExistsCopyWith<$Res> {
  _$GithubApiPullRequestExistsCopyWithImpl(this._self, this._then);

  final GithubApiPullRequestExists _self;
  final $Res Function(GithubApiPullRequestExists) _then;

/// Create a copy of GithubApiFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? address = null,Object? cause = freezed,}) {
  return _then(GithubApiPullRequestExists(
null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,cause: freezed == cause ? _self.cause : cause // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}


}

/// @nodoc


class GithubApiCommandDenied implements GithubApiFailure, CommandDenial {
  const GithubApiCommandDenied(this.command, {this.cause});
  

/// The command as it would have run.
 final  String command;
@override final  AppFailure? cause;

/// Create a copy of GithubApiFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GithubApiCommandDeniedCopyWith<GithubApiCommandDenied> get copyWith => _$GithubApiCommandDeniedCopyWithImpl<GithubApiCommandDenied>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GithubApiCommandDenied&&(identical(other.command, command) || other.command == command)&&(identical(other.cause, cause) || other.cause == cause));
}


@override
int get hashCode => Object.hash(runtimeType,command,cause);

@override
String toString() {
  return 'GithubApiFailure.commandDenied(command: $command, cause: $cause)';
}


}

/// @nodoc
abstract mixin class $GithubApiCommandDeniedCopyWith<$Res> implements $GithubApiFailureCopyWith<$Res> {
  factory $GithubApiCommandDeniedCopyWith(GithubApiCommandDenied value, $Res Function(GithubApiCommandDenied) _then) = _$GithubApiCommandDeniedCopyWithImpl;
@override @useResult
$Res call({
 String command, AppFailure? cause
});




}
/// @nodoc
class _$GithubApiCommandDeniedCopyWithImpl<$Res>
    implements $GithubApiCommandDeniedCopyWith<$Res> {
  _$GithubApiCommandDeniedCopyWithImpl(this._self, this._then);

  final GithubApiCommandDenied _self;
  final $Res Function(GithubApiCommandDenied) _then;

/// Create a copy of GithubApiFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? command = null,Object? cause = freezed,}) {
  return _then(GithubApiCommandDenied(
null == command ? _self.command : command // ignore: cast_nullable_to_non_nullable
as String,cause: freezed == cause ? _self.cause : cause // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}


}

/// @nodoc


class GithubApiOperationFailed implements GithubApiFailure {
  const GithubApiOperationFailed(this.description, {this.cause});
  

/// What was said on the error stream, and nothing of the body.
 final  String description;
@override final  AppFailure? cause;

/// Create a copy of GithubApiFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GithubApiOperationFailedCopyWith<GithubApiOperationFailed> get copyWith => _$GithubApiOperationFailedCopyWithImpl<GithubApiOperationFailed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GithubApiOperationFailed&&(identical(other.description, description) || other.description == description)&&(identical(other.cause, cause) || other.cause == cause));
}


@override
int get hashCode => Object.hash(runtimeType,description,cause);

@override
String toString() {
  return 'GithubApiFailure.operationFailed(description: $description, cause: $cause)';
}


}

/// @nodoc
abstract mixin class $GithubApiOperationFailedCopyWith<$Res> implements $GithubApiFailureCopyWith<$Res> {
  factory $GithubApiOperationFailedCopyWith(GithubApiOperationFailed value, $Res Function(GithubApiOperationFailed) _then) = _$GithubApiOperationFailedCopyWithImpl;
@override @useResult
$Res call({
 String description, AppFailure? cause
});




}
/// @nodoc
class _$GithubApiOperationFailedCopyWithImpl<$Res>
    implements $GithubApiOperationFailedCopyWith<$Res> {
  _$GithubApiOperationFailedCopyWithImpl(this._self, this._then);

  final GithubApiOperationFailed _self;
  final $Res Function(GithubApiOperationFailed) _then;

/// Create a copy of GithubApiFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? description = null,Object? cause = freezed,}) {
  return _then(GithubApiOperationFailed(
null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,cause: freezed == cause ? _self.cause : cause // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}


}

// dart format on
