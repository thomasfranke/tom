// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'update_failure.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UpdateFailure {

 AppFailure? get cause;
/// Create a copy of UpdateFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateFailureCopyWith<UpdateFailure> get copyWith => _$UpdateFailureCopyWithImpl<UpdateFailure>(this as UpdateFailure, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateFailure&&(identical(other.cause, cause) || other.cause == cause));
}


@override
int get hashCode => Object.hash(runtimeType,cause);

@override
String toString() {
  return 'UpdateFailure(cause: $cause)';
}


}

/// @nodoc
abstract mixin class $UpdateFailureCopyWith<$Res>  {
  factory $UpdateFailureCopyWith(UpdateFailure value, $Res Function(UpdateFailure) _then) = _$UpdateFailureCopyWithImpl;
@useResult
$Res call({
 AppFailure? cause
});




}
/// @nodoc
class _$UpdateFailureCopyWithImpl<$Res>
    implements $UpdateFailureCopyWith<$Res> {
  _$UpdateFailureCopyWithImpl(this._self, this._then);

  final UpdateFailure _self;
  final $Res Function(UpdateFailure) _then;

/// Create a copy of UpdateFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? cause = freezed,}) {
  return _then(_self.copyWith(
cause: freezed == cause ? _self.cause : cause // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateFailure].
extension UpdateFailurePatterns on UpdateFailure {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( UpdateUnreachable value)?  unreachable,required TResult orElse(),}){
final _that = this;
switch (_that) {
case UpdateUnreachable() when unreachable != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( UpdateUnreachable value)  unreachable,}){
final _that = this;
switch (_that) {
case UpdateUnreachable():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( UpdateUnreachable value)?  unreachable,}){
final _that = this;
switch (_that) {
case UpdateUnreachable() when unreachable != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( AppFailure? cause)?  unreachable,required TResult orElse(),}) {final _that = this;
switch (_that) {
case UpdateUnreachable() when unreachable != null:
return unreachable(_that.cause);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( AppFailure? cause)  unreachable,}) {final _that = this;
switch (_that) {
case UpdateUnreachable():
return unreachable(_that.cause);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( AppFailure? cause)?  unreachable,}) {final _that = this;
switch (_that) {
case UpdateUnreachable() when unreachable != null:
return unreachable(_that.cause);case _:
  return null;

}
}

}

/// @nodoc


class UpdateUnreachable implements UpdateFailure {
  const UpdateUnreachable({this.cause});
  

@override final  AppFailure? cause;

/// Create a copy of UpdateFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateUnreachableCopyWith<UpdateUnreachable> get copyWith => _$UpdateUnreachableCopyWithImpl<UpdateUnreachable>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateUnreachable&&(identical(other.cause, cause) || other.cause == cause));
}


@override
int get hashCode => Object.hash(runtimeType,cause);

@override
String toString() {
  return 'UpdateFailure.unreachable(cause: $cause)';
}


}

/// @nodoc
abstract mixin class $UpdateUnreachableCopyWith<$Res> implements $UpdateFailureCopyWith<$Res> {
  factory $UpdateUnreachableCopyWith(UpdateUnreachable value, $Res Function(UpdateUnreachable) _then) = _$UpdateUnreachableCopyWithImpl;
@override @useResult
$Res call({
 AppFailure? cause
});




}
/// @nodoc
class _$UpdateUnreachableCopyWithImpl<$Res>
    implements $UpdateUnreachableCopyWith<$Res> {
  _$UpdateUnreachableCopyWithImpl(this._self, this._then);

  final UpdateUnreachable _self;
  final $Res Function(UpdateUnreachable) _then;

/// Create a copy of UpdateFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? cause = freezed,}) {
  return _then(UpdateUnreachable(
cause: freezed == cause ? _self.cause : cause // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}


}

// dart format on
