// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dart_io_failure.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DartIoFailure {

/// The message `dart:io` put on the exception.
 String get message;/// The path it named, when it named one.
 String? get path;/// The OS error code, when there was one.
///
/// POSIX `errno` on Unix and a Win32 code on Windows — the same number
/// means different things on the two, which is exactly why nothing
/// switches on it and it is only ever read by a human.
 int? get osErrorCode;/// The OS error message, when there was one.
 String? get osErrorMessage;/// Nothing: this is the bottom of a chain by construction.
 AppFailure? get cause;
/// Create a copy of DartIoFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DartIoFailureCopyWith<DartIoFailure> get copyWith => _$DartIoFailureCopyWithImpl<DartIoFailure>(this as DartIoFailure, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DartIoFailure&&(identical(other.message, message) || other.message == message)&&(identical(other.path, path) || other.path == path)&&(identical(other.osErrorCode, osErrorCode) || other.osErrorCode == osErrorCode)&&(identical(other.osErrorMessage, osErrorMessage) || other.osErrorMessage == osErrorMessage)&&(identical(other.cause, cause) || other.cause == cause));
}


@override
int get hashCode => Object.hash(runtimeType,message,path,osErrorCode,osErrorMessage,cause);

@override
String toString() {
  return 'DartIoFailure(message: $message, path: $path, osErrorCode: $osErrorCode, osErrorMessage: $osErrorMessage, cause: $cause)';
}


}

/// @nodoc
abstract mixin class $DartIoFailureCopyWith<$Res>  {
  factory $DartIoFailureCopyWith(DartIoFailure value, $Res Function(DartIoFailure) _then) = _$DartIoFailureCopyWithImpl;
@useResult
$Res call({
 String message, String? path, int? osErrorCode, String? osErrorMessage, AppFailure? cause
});




}
/// @nodoc
class _$DartIoFailureCopyWithImpl<$Res>
    implements $DartIoFailureCopyWith<$Res> {
  _$DartIoFailureCopyWithImpl(this._self, this._then);

  final DartIoFailure _self;
  final $Res Function(DartIoFailure) _then;

/// Create a copy of DartIoFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? message = null,Object? path = freezed,Object? osErrorCode = freezed,Object? osErrorMessage = freezed,Object? cause = freezed,}) {
  return _then(_self.copyWith(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,path: freezed == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String?,osErrorCode: freezed == osErrorCode ? _self.osErrorCode : osErrorCode // ignore: cast_nullable_to_non_nullable
as int?,osErrorMessage: freezed == osErrorMessage ? _self.osErrorMessage : osErrorMessage // ignore: cast_nullable_to_non_nullable
as String?,cause: freezed == cause ? _self.cause : cause // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}

}


/// Adds pattern-matching-related methods to [DartIoFailure].
extension DartIoFailurePatterns on DartIoFailure {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DartIoFailure value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DartIoFailure() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DartIoFailure value)  $default,){
final _that = this;
switch (_that) {
case _DartIoFailure():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DartIoFailure value)?  $default,){
final _that = this;
switch (_that) {
case _DartIoFailure() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String message,  String? path,  int? osErrorCode,  String? osErrorMessage,  AppFailure? cause)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DartIoFailure() when $default != null:
return $default(_that.message,_that.path,_that.osErrorCode,_that.osErrorMessage,_that.cause);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String message,  String? path,  int? osErrorCode,  String? osErrorMessage,  AppFailure? cause)  $default,) {final _that = this;
switch (_that) {
case _DartIoFailure():
return $default(_that.message,_that.path,_that.osErrorCode,_that.osErrorMessage,_that.cause);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String message,  String? path,  int? osErrorCode,  String? osErrorMessage,  AppFailure? cause)?  $default,) {final _that = this;
switch (_that) {
case _DartIoFailure() when $default != null:
return $default(_that.message,_that.path,_that.osErrorCode,_that.osErrorMessage,_that.cause);case _:
  return null;

}
}

}

/// @nodoc


class _DartIoFailure implements DartIoFailure {
  const _DartIoFailure({required this.message, this.path, this.osErrorCode, this.osErrorMessage, this.cause});
  

/// The message `dart:io` put on the exception.
@override final  String message;
/// The path it named, when it named one.
@override final  String? path;
/// The OS error code, when there was one.
///
/// POSIX `errno` on Unix and a Win32 code on Windows — the same number
/// means different things on the two, which is exactly why nothing
/// switches on it and it is only ever read by a human.
@override final  int? osErrorCode;
/// The OS error message, when there was one.
@override final  String? osErrorMessage;
/// Nothing: this is the bottom of a chain by construction.
@override final  AppFailure? cause;

/// Create a copy of DartIoFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DartIoFailureCopyWith<_DartIoFailure> get copyWith => __$DartIoFailureCopyWithImpl<_DartIoFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DartIoFailure&&(identical(other.message, message) || other.message == message)&&(identical(other.path, path) || other.path == path)&&(identical(other.osErrorCode, osErrorCode) || other.osErrorCode == osErrorCode)&&(identical(other.osErrorMessage, osErrorMessage) || other.osErrorMessage == osErrorMessage)&&(identical(other.cause, cause) || other.cause == cause));
}


@override
int get hashCode => Object.hash(runtimeType,message,path,osErrorCode,osErrorMessage,cause);

@override
String toString() {
  return 'DartIoFailure(message: $message, path: $path, osErrorCode: $osErrorCode, osErrorMessage: $osErrorMessage, cause: $cause)';
}


}

/// @nodoc
abstract mixin class _$DartIoFailureCopyWith<$Res> implements $DartIoFailureCopyWith<$Res> {
  factory _$DartIoFailureCopyWith(_DartIoFailure value, $Res Function(_DartIoFailure) _then) = __$DartIoFailureCopyWithImpl;
@override @useResult
$Res call({
 String message, String? path, int? osErrorCode, String? osErrorMessage, AppFailure? cause
});




}
/// @nodoc
class __$DartIoFailureCopyWithImpl<$Res>
    implements _$DartIoFailureCopyWith<$Res> {
  __$DartIoFailureCopyWithImpl(this._self, this._then);

  final _DartIoFailure _self;
  final $Res Function(_DartIoFailure) _then;

/// Create a copy of DartIoFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,Object? path = freezed,Object? osErrorCode = freezed,Object? osErrorMessage = freezed,Object? cause = freezed,}) {
  return _then(_DartIoFailure(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,path: freezed == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String?,osErrorCode: freezed == osErrorCode ? _self.osErrorCode : osErrorCode // ignore: cast_nullable_to_non_nullable
as int?,osErrorMessage: freezed == osErrorMessage ? _self.osErrorMessage : osErrorMessage // ignore: cast_nullable_to_non_nullable
as String?,cause: freezed == cause ? _self.cause : cause // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}


}

// dart format on
