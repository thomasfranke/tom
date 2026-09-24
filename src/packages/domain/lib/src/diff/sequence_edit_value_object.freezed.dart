// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sequence_edit_value_object.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SequenceEditValueObject {

/// What happened to the entry.
 SequenceEditKindEnum get kind;/// Where it sat in the old sequence, or null when it is an addition.
 int? get beforeIndex;/// Where it sits in the new sequence, or null when it was removed.
 int? get afterIndex;
/// Create a copy of SequenceEditValueObject
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SequenceEditValueObjectCopyWith<SequenceEditValueObject> get copyWith => _$SequenceEditValueObjectCopyWithImpl<SequenceEditValueObject>(this as SequenceEditValueObject, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SequenceEditValueObject&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.beforeIndex, beforeIndex) || other.beforeIndex == beforeIndex)&&(identical(other.afterIndex, afterIndex) || other.afterIndex == afterIndex));
}


@override
int get hashCode => Object.hash(runtimeType,kind,beforeIndex,afterIndex);

@override
String toString() {
  return 'SequenceEditValueObject(kind: $kind, beforeIndex: $beforeIndex, afterIndex: $afterIndex)';
}


}

/// @nodoc
abstract mixin class $SequenceEditValueObjectCopyWith<$Res>  {
  factory $SequenceEditValueObjectCopyWith(SequenceEditValueObject value, $Res Function(SequenceEditValueObject) _then) = _$SequenceEditValueObjectCopyWithImpl;
@useResult
$Res call({
 SequenceEditKindEnum kind, int? beforeIndex, int? afterIndex
});




}
/// @nodoc
class _$SequenceEditValueObjectCopyWithImpl<$Res>
    implements $SequenceEditValueObjectCopyWith<$Res> {
  _$SequenceEditValueObjectCopyWithImpl(this._self, this._then);

  final SequenceEditValueObject _self;
  final $Res Function(SequenceEditValueObject) _then;

/// Create a copy of SequenceEditValueObject
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? kind = null,Object? beforeIndex = freezed,Object? afterIndex = freezed,}) {
  return _then(_self.copyWith(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as SequenceEditKindEnum,beforeIndex: freezed == beforeIndex ? _self.beforeIndex : beforeIndex // ignore: cast_nullable_to_non_nullable
as int?,afterIndex: freezed == afterIndex ? _self.afterIndex : afterIndex // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [SequenceEditValueObject].
extension SequenceEditValueObjectPatterns on SequenceEditValueObject {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SequenceEditValueObject value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SequenceEditValueObject() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SequenceEditValueObject value)  $default,){
final _that = this;
switch (_that) {
case _SequenceEditValueObject():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SequenceEditValueObject value)?  $default,){
final _that = this;
switch (_that) {
case _SequenceEditValueObject() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SequenceEditKindEnum kind,  int? beforeIndex,  int? afterIndex)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SequenceEditValueObject() when $default != null:
return $default(_that.kind,_that.beforeIndex,_that.afterIndex);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SequenceEditKindEnum kind,  int? beforeIndex,  int? afterIndex)  $default,) {final _that = this;
switch (_that) {
case _SequenceEditValueObject():
return $default(_that.kind,_that.beforeIndex,_that.afterIndex);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SequenceEditKindEnum kind,  int? beforeIndex,  int? afterIndex)?  $default,) {final _that = this;
switch (_that) {
case _SequenceEditValueObject() when $default != null:
return $default(_that.kind,_that.beforeIndex,_that.afterIndex);case _:
  return null;

}
}

}

/// @nodoc


class _SequenceEditValueObject implements SequenceEditValueObject {
  const _SequenceEditValueObject({required this.kind, this.beforeIndex, this.afterIndex});
  

/// What happened to the entry.
@override final  SequenceEditKindEnum kind;
/// Where it sat in the old sequence, or null when it is an addition.
@override final  int? beforeIndex;
/// Where it sits in the new sequence, or null when it was removed.
@override final  int? afterIndex;

/// Create a copy of SequenceEditValueObject
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SequenceEditValueObjectCopyWith<_SequenceEditValueObject> get copyWith => __$SequenceEditValueObjectCopyWithImpl<_SequenceEditValueObject>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SequenceEditValueObject&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.beforeIndex, beforeIndex) || other.beforeIndex == beforeIndex)&&(identical(other.afterIndex, afterIndex) || other.afterIndex == afterIndex));
}


@override
int get hashCode => Object.hash(runtimeType,kind,beforeIndex,afterIndex);

@override
String toString() {
  return 'SequenceEditValueObject(kind: $kind, beforeIndex: $beforeIndex, afterIndex: $afterIndex)';
}


}

/// @nodoc
abstract mixin class _$SequenceEditValueObjectCopyWith<$Res> implements $SequenceEditValueObjectCopyWith<$Res> {
  factory _$SequenceEditValueObjectCopyWith(_SequenceEditValueObject value, $Res Function(_SequenceEditValueObject) _then) = __$SequenceEditValueObjectCopyWithImpl;
@override @useResult
$Res call({
 SequenceEditKindEnum kind, int? beforeIndex, int? afterIndex
});




}
/// @nodoc
class __$SequenceEditValueObjectCopyWithImpl<$Res>
    implements _$SequenceEditValueObjectCopyWith<$Res> {
  __$SequenceEditValueObjectCopyWithImpl(this._self, this._then);

  final _SequenceEditValueObject _self;
  final $Res Function(_SequenceEditValueObject) _then;

/// Create a copy of SequenceEditValueObject
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? kind = null,Object? beforeIndex = freezed,Object? afterIndex = freezed,}) {
  return _then(_SequenceEditValueObject(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as SequenceEditKindEnum,beforeIndex: freezed == beforeIndex ? _self.beforeIndex : beforeIndex // ignore: cast_nullable_to_non_nullable
as int?,afterIndex: freezed == afterIndex ? _self.afterIndex : afterIndex // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
