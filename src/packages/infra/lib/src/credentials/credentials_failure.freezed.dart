// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'credentials_failure.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CredentialsFailure {

 AppFailure? get cause;
/// Create a copy of CredentialsFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CredentialsFailureCopyWith<CredentialsFailure> get copyWith => _$CredentialsFailureCopyWithImpl<CredentialsFailure>(this as CredentialsFailure, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CredentialsFailure&&(identical(other.cause, cause) || other.cause == cause));
}


@override
int get hashCode => Object.hash(runtimeType,cause);

@override
String toString() {
  return 'CredentialsFailure(cause: $cause)';
}


}

/// @nodoc
abstract mixin class $CredentialsFailureCopyWith<$Res>  {
  factory $CredentialsFailureCopyWith(CredentialsFailure value, $Res Function(CredentialsFailure) _then) = _$CredentialsFailureCopyWithImpl;
@useResult
$Res call({
 AppFailure? cause
});




}
/// @nodoc
class _$CredentialsFailureCopyWithImpl<$Res>
    implements $CredentialsFailureCopyWith<$Res> {
  _$CredentialsFailureCopyWithImpl(this._self, this._then);

  final CredentialsFailure _self;
  final $Res Function(CredentialsFailure) _then;

/// Create a copy of CredentialsFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? cause = freezed,}) {
  return _then(_self.copyWith(
cause: freezed == cause ? _self.cause : cause // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}

}


/// Adds pattern-matching-related methods to [CredentialsFailure].
extension CredentialsFailurePatterns on CredentialsFailure {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( CredentialsTimedOut value)?  timedOut,TResult Function( CredentialsCommandDenied value)?  commandDenied,TResult Function( CredentialsOperationFailed value)?  operationFailed,required TResult orElse(),}){
final _that = this;
switch (_that) {
case CredentialsTimedOut() when timedOut != null:
return timedOut(_that);case CredentialsCommandDenied() when commandDenied != null:
return commandDenied(_that);case CredentialsOperationFailed() when operationFailed != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( CredentialsTimedOut value)  timedOut,required TResult Function( CredentialsCommandDenied value)  commandDenied,required TResult Function( CredentialsOperationFailed value)  operationFailed,}){
final _that = this;
switch (_that) {
case CredentialsTimedOut():
return timedOut(_that);case CredentialsCommandDenied():
return commandDenied(_that);case CredentialsOperationFailed():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( CredentialsTimedOut value)?  timedOut,TResult? Function( CredentialsCommandDenied value)?  commandDenied,TResult? Function( CredentialsOperationFailed value)?  operationFailed,}){
final _that = this;
switch (_that) {
case CredentialsTimedOut() when timedOut != null:
return timedOut(_that);case CredentialsCommandDenied() when commandDenied != null:
return commandDenied(_that);case CredentialsOperationFailed() when operationFailed != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String program,  AppFailure? cause)?  timedOut,TResult Function( String command,  AppFailure? cause)?  commandDenied,TResult Function( String description,  AppFailure? cause)?  operationFailed,required TResult orElse(),}) {final _that = this;
switch (_that) {
case CredentialsTimedOut() when timedOut != null:
return timedOut(_that.program,_that.cause);case CredentialsCommandDenied() when commandDenied != null:
return commandDenied(_that.command,_that.cause);case CredentialsOperationFailed() when operationFailed != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String program,  AppFailure? cause)  timedOut,required TResult Function( String command,  AppFailure? cause)  commandDenied,required TResult Function( String description,  AppFailure? cause)  operationFailed,}) {final _that = this;
switch (_that) {
case CredentialsTimedOut():
return timedOut(_that.program,_that.cause);case CredentialsCommandDenied():
return commandDenied(_that.command,_that.cause);case CredentialsOperationFailed():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String program,  AppFailure? cause)?  timedOut,TResult? Function( String command,  AppFailure? cause)?  commandDenied,TResult? Function( String description,  AppFailure? cause)?  operationFailed,}) {final _that = this;
switch (_that) {
case CredentialsTimedOut() when timedOut != null:
return timedOut(_that.program,_that.cause);case CredentialsCommandDenied() when commandDenied != null:
return commandDenied(_that.command,_that.cause);case CredentialsOperationFailed() when operationFailed != null:
return operationFailed(_that.description,_that.cause);case _:
  return null;

}
}

}

/// @nodoc


class CredentialsTimedOut implements CredentialsFailure {
  const CredentialsTimedOut(this.program, {this.cause});
  

/// The program that was asked.
 final  String program;
@override final  AppFailure? cause;

/// Create a copy of CredentialsFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CredentialsTimedOutCopyWith<CredentialsTimedOut> get copyWith => _$CredentialsTimedOutCopyWithImpl<CredentialsTimedOut>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CredentialsTimedOut&&(identical(other.program, program) || other.program == program)&&(identical(other.cause, cause) || other.cause == cause));
}


@override
int get hashCode => Object.hash(runtimeType,program,cause);

@override
String toString() {
  return 'CredentialsFailure.timedOut(program: $program, cause: $cause)';
}


}

/// @nodoc
abstract mixin class $CredentialsTimedOutCopyWith<$Res> implements $CredentialsFailureCopyWith<$Res> {
  factory $CredentialsTimedOutCopyWith(CredentialsTimedOut value, $Res Function(CredentialsTimedOut) _then) = _$CredentialsTimedOutCopyWithImpl;
@override @useResult
$Res call({
 String program, AppFailure? cause
});




}
/// @nodoc
class _$CredentialsTimedOutCopyWithImpl<$Res>
    implements $CredentialsTimedOutCopyWith<$Res> {
  _$CredentialsTimedOutCopyWithImpl(this._self, this._then);

  final CredentialsTimedOut _self;
  final $Res Function(CredentialsTimedOut) _then;

/// Create a copy of CredentialsFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? program = null,Object? cause = freezed,}) {
  return _then(CredentialsTimedOut(
null == program ? _self.program : program // ignore: cast_nullable_to_non_nullable
as String,cause: freezed == cause ? _self.cause : cause // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}


}

/// @nodoc


class CredentialsCommandDenied implements CredentialsFailure, CommandDenial {
  const CredentialsCommandDenied(this.command, {this.cause});
  

/// The command as it would have run.
 final  String command;
@override final  AppFailure? cause;

/// Create a copy of CredentialsFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CredentialsCommandDeniedCopyWith<CredentialsCommandDenied> get copyWith => _$CredentialsCommandDeniedCopyWithImpl<CredentialsCommandDenied>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CredentialsCommandDenied&&(identical(other.command, command) || other.command == command)&&(identical(other.cause, cause) || other.cause == cause));
}


@override
int get hashCode => Object.hash(runtimeType,command,cause);

@override
String toString() {
  return 'CredentialsFailure.commandDenied(command: $command, cause: $cause)';
}


}

/// @nodoc
abstract mixin class $CredentialsCommandDeniedCopyWith<$Res> implements $CredentialsFailureCopyWith<$Res> {
  factory $CredentialsCommandDeniedCopyWith(CredentialsCommandDenied value, $Res Function(CredentialsCommandDenied) _then) = _$CredentialsCommandDeniedCopyWithImpl;
@override @useResult
$Res call({
 String command, AppFailure? cause
});




}
/// @nodoc
class _$CredentialsCommandDeniedCopyWithImpl<$Res>
    implements $CredentialsCommandDeniedCopyWith<$Res> {
  _$CredentialsCommandDeniedCopyWithImpl(this._self, this._then);

  final CredentialsCommandDenied _self;
  final $Res Function(CredentialsCommandDenied) _then;

/// Create a copy of CredentialsFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? command = null,Object? cause = freezed,}) {
  return _then(CredentialsCommandDenied(
null == command ? _self.command : command // ignore: cast_nullable_to_non_nullable
as String,cause: freezed == cause ? _self.cause : cause // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}


}

/// @nodoc


class CredentialsOperationFailed implements CredentialsFailure {
  const CredentialsOperationFailed(this.description, {this.cause});
  

/// What it said on its error stream — never what it printed, which may be
/// a secret.
 final  String description;
@override final  AppFailure? cause;

/// Create a copy of CredentialsFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CredentialsOperationFailedCopyWith<CredentialsOperationFailed> get copyWith => _$CredentialsOperationFailedCopyWithImpl<CredentialsOperationFailed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CredentialsOperationFailed&&(identical(other.description, description) || other.description == description)&&(identical(other.cause, cause) || other.cause == cause));
}


@override
int get hashCode => Object.hash(runtimeType,description,cause);

@override
String toString() {
  return 'CredentialsFailure.operationFailed(description: $description, cause: $cause)';
}


}

/// @nodoc
abstract mixin class $CredentialsOperationFailedCopyWith<$Res> implements $CredentialsFailureCopyWith<$Res> {
  factory $CredentialsOperationFailedCopyWith(CredentialsOperationFailed value, $Res Function(CredentialsOperationFailed) _then) = _$CredentialsOperationFailedCopyWithImpl;
@override @useResult
$Res call({
 String description, AppFailure? cause
});




}
/// @nodoc
class _$CredentialsOperationFailedCopyWithImpl<$Res>
    implements $CredentialsOperationFailedCopyWith<$Res> {
  _$CredentialsOperationFailedCopyWithImpl(this._self, this._then);

  final CredentialsOperationFailed _self;
  final $Res Function(CredentialsOperationFailed) _then;

/// Create a copy of CredentialsFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? description = null,Object? cause = freezed,}) {
  return _then(CredentialsOperationFailed(
null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,cause: freezed == cause ? _self.cause : cause // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}


}

// dart format on
