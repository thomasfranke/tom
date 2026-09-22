// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'commit_date_value_object.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CommitDateValueObject {

/// The instant, in UTC. Comparing two commits in time uses this.
 DateTime get utc;/// How far the author's clock stood from UTC, as git recorded it.
///
/// Zero is a real answer — the author was on UTC — not a missing one.
 Duration get offset;
/// Create a copy of CommitDateValueObject
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommitDateValueObjectCopyWith<CommitDateValueObject> get copyWith => _$CommitDateValueObjectCopyWithImpl<CommitDateValueObject>(this as CommitDateValueObject, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommitDateValueObject&&(identical(other.utc, utc) || other.utc == utc)&&(identical(other.offset, offset) || other.offset == offset));
}


@override
int get hashCode => Object.hash(runtimeType,utc,offset);

@override
String toString() {
  return 'CommitDateValueObject(utc: $utc, offset: $offset)';
}


}

/// @nodoc
abstract mixin class $CommitDateValueObjectCopyWith<$Res>  {
  factory $CommitDateValueObjectCopyWith(CommitDateValueObject value, $Res Function(CommitDateValueObject) _then) = _$CommitDateValueObjectCopyWithImpl;
@useResult
$Res call({
 DateTime utc, Duration offset
});




}
/// @nodoc
class _$CommitDateValueObjectCopyWithImpl<$Res>
    implements $CommitDateValueObjectCopyWith<$Res> {
  _$CommitDateValueObjectCopyWithImpl(this._self, this._then);

  final CommitDateValueObject _self;
  final $Res Function(CommitDateValueObject) _then;

/// Create a copy of CommitDateValueObject
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? utc = null,Object? offset = null,}) {
  return _then(_self.copyWith(
utc: null == utc ? _self.utc : utc // ignore: cast_nullable_to_non_nullable
as DateTime,offset: null == offset ? _self.offset : offset // ignore: cast_nullable_to_non_nullable
as Duration,
  ));
}

}


/// Adds pattern-matching-related methods to [CommitDateValueObject].
extension CommitDateValueObjectPatterns on CommitDateValueObject {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CommitDateValueObject value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CommitDateValueObject() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CommitDateValueObject value)  $default,){
final _that = this;
switch (_that) {
case _CommitDateValueObject():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CommitDateValueObject value)?  $default,){
final _that = this;
switch (_that) {
case _CommitDateValueObject() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime utc,  Duration offset)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CommitDateValueObject() when $default != null:
return $default(_that.utc,_that.offset);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime utc,  Duration offset)  $default,) {final _that = this;
switch (_that) {
case _CommitDateValueObject():
return $default(_that.utc,_that.offset);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime utc,  Duration offset)?  $default,) {final _that = this;
switch (_that) {
case _CommitDateValueObject() when $default != null:
return $default(_that.utc,_that.offset);case _:
  return null;

}
}

}

/// @nodoc


class _CommitDateValueObject extends CommitDateValueObject {
  const _CommitDateValueObject({required this.utc, required this.offset}): super._();
  

/// The instant, in UTC. Comparing two commits in time uses this.
@override final  DateTime utc;
/// How far the author's clock stood from UTC, as git recorded it.
///
/// Zero is a real answer — the author was on UTC — not a missing one.
@override final  Duration offset;

/// Create a copy of CommitDateValueObject
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommitDateValueObjectCopyWith<_CommitDateValueObject> get copyWith => __$CommitDateValueObjectCopyWithImpl<_CommitDateValueObject>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommitDateValueObject&&(identical(other.utc, utc) || other.utc == utc)&&(identical(other.offset, offset) || other.offset == offset));
}


@override
int get hashCode => Object.hash(runtimeType,utc,offset);

@override
String toString() {
  return 'CommitDateValueObject(utc: $utc, offset: $offset)';
}


}

/// @nodoc
abstract mixin class _$CommitDateValueObjectCopyWith<$Res> implements $CommitDateValueObjectCopyWith<$Res> {
  factory _$CommitDateValueObjectCopyWith(_CommitDateValueObject value, $Res Function(_CommitDateValueObject) _then) = __$CommitDateValueObjectCopyWithImpl;
@override @useResult
$Res call({
 DateTime utc, Duration offset
});




}
/// @nodoc
class __$CommitDateValueObjectCopyWithImpl<$Res>
    implements _$CommitDateValueObjectCopyWith<$Res> {
  __$CommitDateValueObjectCopyWithImpl(this._self, this._then);

  final _CommitDateValueObject _self;
  final $Res Function(_CommitDateValueObject) _then;

/// Create a copy of CommitDateValueObject
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? utc = null,Object? offset = null,}) {
  return _then(_CommitDateValueObject(
utc: null == utc ? _self.utc : utc // ignore: cast_nullable_to_non_nullable
as DateTime,offset: null == offset ? _self.offset : offset // ignore: cast_nullable_to_non_nullable
as Duration,
  ));
}


}

// dart format on
