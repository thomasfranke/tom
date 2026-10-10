// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'clone_progress_value_object.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CloneProgressValueObject {

/// Which stage the clone is in.
 CloneStageEnum get stage;/// How far through [stage], 0 to 100, or null when git gives no
/// fraction — the remote counting what it has, for one.
 int? get percent;
/// Create a copy of CloneProgressValueObject
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CloneProgressValueObjectCopyWith<CloneProgressValueObject> get copyWith => _$CloneProgressValueObjectCopyWithImpl<CloneProgressValueObject>(this as CloneProgressValueObject, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CloneProgressValueObject&&(identical(other.stage, stage) || other.stage == stage)&&(identical(other.percent, percent) || other.percent == percent));
}


@override
int get hashCode => Object.hash(runtimeType,stage,percent);

@override
String toString() {
  return 'CloneProgressValueObject(stage: $stage, percent: $percent)';
}


}

/// @nodoc
abstract mixin class $CloneProgressValueObjectCopyWith<$Res>  {
  factory $CloneProgressValueObjectCopyWith(CloneProgressValueObject value, $Res Function(CloneProgressValueObject) _then) = _$CloneProgressValueObjectCopyWithImpl;
@useResult
$Res call({
 CloneStageEnum stage, int? percent
});




}
/// @nodoc
class _$CloneProgressValueObjectCopyWithImpl<$Res>
    implements $CloneProgressValueObjectCopyWith<$Res> {
  _$CloneProgressValueObjectCopyWithImpl(this._self, this._then);

  final CloneProgressValueObject _self;
  final $Res Function(CloneProgressValueObject) _then;

/// Create a copy of CloneProgressValueObject
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? stage = null,Object? percent = freezed,}) {
  return _then(_self.copyWith(
stage: null == stage ? _self.stage : stage // ignore: cast_nullable_to_non_nullable
as CloneStageEnum,percent: freezed == percent ? _self.percent : percent // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [CloneProgressValueObject].
extension CloneProgressValueObjectPatterns on CloneProgressValueObject {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CloneProgressValueObject value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CloneProgressValueObject() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CloneProgressValueObject value)  $default,){
final _that = this;
switch (_that) {
case _CloneProgressValueObject():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CloneProgressValueObject value)?  $default,){
final _that = this;
switch (_that) {
case _CloneProgressValueObject() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CloneStageEnum stage,  int? percent)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CloneProgressValueObject() when $default != null:
return $default(_that.stage,_that.percent);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CloneStageEnum stage,  int? percent)  $default,) {final _that = this;
switch (_that) {
case _CloneProgressValueObject():
return $default(_that.stage,_that.percent);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CloneStageEnum stage,  int? percent)?  $default,) {final _that = this;
switch (_that) {
case _CloneProgressValueObject() when $default != null:
return $default(_that.stage,_that.percent);case _:
  return null;

}
}

}

/// @nodoc


class _CloneProgressValueObject implements CloneProgressValueObject {
  const _CloneProgressValueObject({required this.stage, this.percent}): assert(percent == null || (percent >= 0 && percent <= 100));
  

/// Which stage the clone is in.
@override final  CloneStageEnum stage;
/// How far through [stage], 0 to 100, or null when git gives no
/// fraction — the remote counting what it has, for one.
@override final  int? percent;

/// Create a copy of CloneProgressValueObject
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CloneProgressValueObjectCopyWith<_CloneProgressValueObject> get copyWith => __$CloneProgressValueObjectCopyWithImpl<_CloneProgressValueObject>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CloneProgressValueObject&&(identical(other.stage, stage) || other.stage == stage)&&(identical(other.percent, percent) || other.percent == percent));
}


@override
int get hashCode => Object.hash(runtimeType,stage,percent);

@override
String toString() {
  return 'CloneProgressValueObject(stage: $stage, percent: $percent)';
}


}

/// @nodoc
abstract mixin class _$CloneProgressValueObjectCopyWith<$Res> implements $CloneProgressValueObjectCopyWith<$Res> {
  factory _$CloneProgressValueObjectCopyWith(_CloneProgressValueObject value, $Res Function(_CloneProgressValueObject) _then) = __$CloneProgressValueObjectCopyWithImpl;
@override @useResult
$Res call({
 CloneStageEnum stage, int? percent
});




}
/// @nodoc
class __$CloneProgressValueObjectCopyWithImpl<$Res>
    implements _$CloneProgressValueObjectCopyWith<$Res> {
  __$CloneProgressValueObjectCopyWithImpl(this._self, this._then);

  final _CloneProgressValueObject _self;
  final $Res Function(_CloneProgressValueObject) _then;

/// Create a copy of CloneProgressValueObject
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? stage = null,Object? percent = freezed,}) {
  return _then(_CloneProgressValueObject(
stage: null == stage ? _self.stage : stage // ignore: cast_nullable_to_non_nullable
as CloneStageEnum,percent: freezed == percent ? _self.percent : percent // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
