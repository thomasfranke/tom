// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'desktop_shell_failure.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DesktopShellFailure {

 AppFailure? get cause;
/// Create a copy of DesktopShellFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DesktopShellFailureCopyWith<DesktopShellFailure> get copyWith => _$DesktopShellFailureCopyWithImpl<DesktopShellFailure>(this as DesktopShellFailure, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DesktopShellFailure&&(identical(other.cause, cause) || other.cause == cause));
}


@override
int get hashCode => Object.hash(runtimeType,cause);

@override
String toString() {
  return 'DesktopShellFailure(cause: $cause)';
}


}

/// @nodoc
abstract mixin class $DesktopShellFailureCopyWith<$Res>  {
  factory $DesktopShellFailureCopyWith(DesktopShellFailure value, $Res Function(DesktopShellFailure) _then) = _$DesktopShellFailureCopyWithImpl;
@useResult
$Res call({
 AppFailure? cause
});




}
/// @nodoc
class _$DesktopShellFailureCopyWithImpl<$Res>
    implements $DesktopShellFailureCopyWith<$Res> {
  _$DesktopShellFailureCopyWithImpl(this._self, this._then);

  final DesktopShellFailure _self;
  final $Res Function(DesktopShellFailure) _then;

/// Create a copy of DesktopShellFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? cause = freezed,}) {
  return _then(_self.copyWith(
cause: freezed == cause ? _self.cause : cause // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}

}


/// Adds pattern-matching-related methods to [DesktopShellFailure].
extension DesktopShellFailurePatterns on DesktopShellFailure {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( DesktopShellUnavailable value)?  unavailable,TResult Function( DesktopShellOperationFailed value)?  operationFailed,required TResult orElse(),}){
final _that = this;
switch (_that) {
case DesktopShellUnavailable() when unavailable != null:
return unavailable(_that);case DesktopShellOperationFailed() when operationFailed != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( DesktopShellUnavailable value)  unavailable,required TResult Function( DesktopShellOperationFailed value)  operationFailed,}){
final _that = this;
switch (_that) {
case DesktopShellUnavailable():
return unavailable(_that);case DesktopShellOperationFailed():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( DesktopShellUnavailable value)?  unavailable,TResult? Function( DesktopShellOperationFailed value)?  operationFailed,}){
final _that = this;
switch (_that) {
case DesktopShellUnavailable() when unavailable != null:
return unavailable(_that);case DesktopShellOperationFailed() when operationFailed != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String program,  AppFailure? cause)?  unavailable,TResult Function( String description,  AppFailure? cause)?  operationFailed,required TResult orElse(),}) {final _that = this;
switch (_that) {
case DesktopShellUnavailable() when unavailable != null:
return unavailable(_that.program,_that.cause);case DesktopShellOperationFailed() when operationFailed != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String program,  AppFailure? cause)  unavailable,required TResult Function( String description,  AppFailure? cause)  operationFailed,}) {final _that = this;
switch (_that) {
case DesktopShellUnavailable():
return unavailable(_that.program,_that.cause);case DesktopShellOperationFailed():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String program,  AppFailure? cause)?  unavailable,TResult? Function( String description,  AppFailure? cause)?  operationFailed,}) {final _that = this;
switch (_that) {
case DesktopShellUnavailable() when unavailable != null:
return unavailable(_that.program,_that.cause);case DesktopShellOperationFailed() when operationFailed != null:
return operationFailed(_that.description,_that.cause);case _:
  return null;

}
}

}

/// @nodoc


class DesktopShellUnavailable implements DesktopShellFailure {
  const DesktopShellUnavailable(this.program, {this.cause});
  

/// The program that was looked for.
 final  String program;
@override final  AppFailure? cause;

/// Create a copy of DesktopShellFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DesktopShellUnavailableCopyWith<DesktopShellUnavailable> get copyWith => _$DesktopShellUnavailableCopyWithImpl<DesktopShellUnavailable>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DesktopShellUnavailable&&(identical(other.program, program) || other.program == program)&&(identical(other.cause, cause) || other.cause == cause));
}


@override
int get hashCode => Object.hash(runtimeType,program,cause);

@override
String toString() {
  return 'DesktopShellFailure.unavailable(program: $program, cause: $cause)';
}


}

/// @nodoc
abstract mixin class $DesktopShellUnavailableCopyWith<$Res> implements $DesktopShellFailureCopyWith<$Res> {
  factory $DesktopShellUnavailableCopyWith(DesktopShellUnavailable value, $Res Function(DesktopShellUnavailable) _then) = _$DesktopShellUnavailableCopyWithImpl;
@override @useResult
$Res call({
 String program, AppFailure? cause
});




}
/// @nodoc
class _$DesktopShellUnavailableCopyWithImpl<$Res>
    implements $DesktopShellUnavailableCopyWith<$Res> {
  _$DesktopShellUnavailableCopyWithImpl(this._self, this._then);

  final DesktopShellUnavailable _self;
  final $Res Function(DesktopShellUnavailable) _then;

/// Create a copy of DesktopShellFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? program = null,Object? cause = freezed,}) {
  return _then(DesktopShellUnavailable(
null == program ? _self.program : program // ignore: cast_nullable_to_non_nullable
as String,cause: freezed == cause ? _self.cause : cause // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}


}

/// @nodoc


class DesktopShellOperationFailed implements DesktopShellFailure {
  const DesktopShellOperationFailed(this.description, {this.cause});
  

/// What it said, verbatim. For diagnostics — never parsed.
 final  String description;
@override final  AppFailure? cause;

/// Create a copy of DesktopShellFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DesktopShellOperationFailedCopyWith<DesktopShellOperationFailed> get copyWith => _$DesktopShellOperationFailedCopyWithImpl<DesktopShellOperationFailed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DesktopShellOperationFailed&&(identical(other.description, description) || other.description == description)&&(identical(other.cause, cause) || other.cause == cause));
}


@override
int get hashCode => Object.hash(runtimeType,description,cause);

@override
String toString() {
  return 'DesktopShellFailure.operationFailed(description: $description, cause: $cause)';
}


}

/// @nodoc
abstract mixin class $DesktopShellOperationFailedCopyWith<$Res> implements $DesktopShellFailureCopyWith<$Res> {
  factory $DesktopShellOperationFailedCopyWith(DesktopShellOperationFailed value, $Res Function(DesktopShellOperationFailed) _then) = _$DesktopShellOperationFailedCopyWithImpl;
@override @useResult
$Res call({
 String description, AppFailure? cause
});




}
/// @nodoc
class _$DesktopShellOperationFailedCopyWithImpl<$Res>
    implements $DesktopShellOperationFailedCopyWith<$Res> {
  _$DesktopShellOperationFailedCopyWithImpl(this._self, this._then);

  final DesktopShellOperationFailed _self;
  final $Res Function(DesktopShellOperationFailed) _then;

/// Create a copy of DesktopShellFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? description = null,Object? cause = freezed,}) {
  return _then(DesktopShellOperationFailed(
null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,cause: freezed == cause ? _self.cause : cause // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}


}

// dart format on
