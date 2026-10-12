// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_updates_failure.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AppUpdatesFailure {

/// What went wrong, for diagnostics — never shown.
 String get reason; AppFailure? get cause;
/// Create a copy of AppUpdatesFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppUpdatesFailureCopyWith<AppUpdatesFailure> get copyWith => _$AppUpdatesFailureCopyWithImpl<AppUpdatesFailure>(this as AppUpdatesFailure, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppUpdatesFailure&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.cause, cause) || other.cause == cause));
}


@override
int get hashCode => Object.hash(runtimeType,reason,cause);

@override
String toString() {
  return 'AppUpdatesFailure(reason: $reason, cause: $cause)';
}


}

/// @nodoc
abstract mixin class $AppUpdatesFailureCopyWith<$Res>  {
  factory $AppUpdatesFailureCopyWith(AppUpdatesFailure value, $Res Function(AppUpdatesFailure) _then) = _$AppUpdatesFailureCopyWithImpl;
@useResult
$Res call({
 String reason, AppFailure? cause
});




}
/// @nodoc
class _$AppUpdatesFailureCopyWithImpl<$Res>
    implements $AppUpdatesFailureCopyWith<$Res> {
  _$AppUpdatesFailureCopyWithImpl(this._self, this._then);

  final AppUpdatesFailure _self;
  final $Res Function(AppUpdatesFailure) _then;

/// Create a copy of AppUpdatesFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? reason = null,Object? cause = freezed,}) {
  return _then(_self.copyWith(
reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,cause: freezed == cause ? _self.cause : cause // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}

}


/// Adds pattern-matching-related methods to [AppUpdatesFailure].
extension AppUpdatesFailurePatterns on AppUpdatesFailure {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( AppUpdatesUnreachable value)?  unreachable,required TResult orElse(),}){
final _that = this;
switch (_that) {
case AppUpdatesUnreachable() when unreachable != null:
return unreachable(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( AppUpdatesUnreachable value)  unreachable,}){
final _that = this;
switch (_that) {
case AppUpdatesUnreachable():
return unreachable(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( AppUpdatesUnreachable value)?  unreachable,}){
final _that = this;
switch (_that) {
case AppUpdatesUnreachable() when unreachable != null:
return unreachable(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String reason,  AppFailure? cause)?  unreachable,required TResult orElse(),}) {final _that = this;
switch (_that) {
case AppUpdatesUnreachable() when unreachable != null:
return unreachable(_that.reason,_that.cause);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String reason,  AppFailure? cause)  unreachable,}) {final _that = this;
switch (_that) {
case AppUpdatesUnreachable():
return unreachable(_that.reason,_that.cause);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String reason,  AppFailure? cause)?  unreachable,}) {final _that = this;
switch (_that) {
case AppUpdatesUnreachable() when unreachable != null:
return unreachable(_that.reason,_that.cause);case _:
  return null;

}
}

}

/// @nodoc


class AppUpdatesUnreachable implements AppUpdatesFailure {
  const AppUpdatesUnreachable(this.reason, {this.cause});
  

/// What went wrong, for diagnostics — never shown.
@override final  String reason;
@override final  AppFailure? cause;

/// Create a copy of AppUpdatesFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppUpdatesUnreachableCopyWith<AppUpdatesUnreachable> get copyWith => _$AppUpdatesUnreachableCopyWithImpl<AppUpdatesUnreachable>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppUpdatesUnreachable&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.cause, cause) || other.cause == cause));
}


@override
int get hashCode => Object.hash(runtimeType,reason,cause);

@override
String toString() {
  return 'AppUpdatesFailure.unreachable(reason: $reason, cause: $cause)';
}


}

/// @nodoc
abstract mixin class $AppUpdatesUnreachableCopyWith<$Res> implements $AppUpdatesFailureCopyWith<$Res> {
  factory $AppUpdatesUnreachableCopyWith(AppUpdatesUnreachable value, $Res Function(AppUpdatesUnreachable) _then) = _$AppUpdatesUnreachableCopyWithImpl;
@override @useResult
$Res call({
 String reason, AppFailure? cause
});




}
/// @nodoc
class _$AppUpdatesUnreachableCopyWithImpl<$Res>
    implements $AppUpdatesUnreachableCopyWith<$Res> {
  _$AppUpdatesUnreachableCopyWithImpl(this._self, this._then);

  final AppUpdatesUnreachable _self;
  final $Res Function(AppUpdatesUnreachable) _then;

/// Create a copy of AppUpdatesFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? reason = null,Object? cause = freezed,}) {
  return _then(AppUpdatesUnreachable(
null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,cause: freezed == cause ? _self.cause : cause // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}


}

// dart format on
