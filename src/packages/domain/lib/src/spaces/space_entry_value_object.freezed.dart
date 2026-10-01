// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'space_entry_value_object.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SpaceEntryValueObject {

/// Where it is, relative to the space root.
 SpaceRelativePathValueObject get path;/// What it is.
 SpaceEntryTypeEnum get type;
/// Create a copy of SpaceEntryValueObject
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SpaceEntryValueObjectCopyWith<SpaceEntryValueObject> get copyWith => _$SpaceEntryValueObjectCopyWithImpl<SpaceEntryValueObject>(this as SpaceEntryValueObject, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SpaceEntryValueObject&&(identical(other.path, path) || other.path == path)&&(identical(other.type, type) || other.type == type));
}


@override
int get hashCode => Object.hash(runtimeType,path,type);

@override
String toString() {
  return 'SpaceEntryValueObject(path: $path, type: $type)';
}


}

/// @nodoc
abstract mixin class $SpaceEntryValueObjectCopyWith<$Res>  {
  factory $SpaceEntryValueObjectCopyWith(SpaceEntryValueObject value, $Res Function(SpaceEntryValueObject) _then) = _$SpaceEntryValueObjectCopyWithImpl;
@useResult
$Res call({
 SpaceRelativePathValueObject path, SpaceEntryTypeEnum type
});




}
/// @nodoc
class _$SpaceEntryValueObjectCopyWithImpl<$Res>
    implements $SpaceEntryValueObjectCopyWith<$Res> {
  _$SpaceEntryValueObjectCopyWithImpl(this._self, this._then);

  final SpaceEntryValueObject _self;
  final $Res Function(SpaceEntryValueObject) _then;

/// Create a copy of SpaceEntryValueObject
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? path = null,Object? type = null,}) {
  return _then(_self.copyWith(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as SpaceRelativePathValueObject,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as SpaceEntryTypeEnum,
  ));
}

}


/// Adds pattern-matching-related methods to [SpaceEntryValueObject].
extension SpaceEntryValueObjectPatterns on SpaceEntryValueObject {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SpaceEntryValueObject value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SpaceEntryValueObject() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SpaceEntryValueObject value)  $default,){
final _that = this;
switch (_that) {
case _SpaceEntryValueObject():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SpaceEntryValueObject value)?  $default,){
final _that = this;
switch (_that) {
case _SpaceEntryValueObject() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SpaceRelativePathValueObject path,  SpaceEntryTypeEnum type)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SpaceEntryValueObject() when $default != null:
return $default(_that.path,_that.type);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SpaceRelativePathValueObject path,  SpaceEntryTypeEnum type)  $default,) {final _that = this;
switch (_that) {
case _SpaceEntryValueObject():
return $default(_that.path,_that.type);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SpaceRelativePathValueObject path,  SpaceEntryTypeEnum type)?  $default,) {final _that = this;
switch (_that) {
case _SpaceEntryValueObject() when $default != null:
return $default(_that.path,_that.type);case _:
  return null;

}
}

}

/// @nodoc


class _SpaceEntryValueObject extends SpaceEntryValueObject {
  const _SpaceEntryValueObject({required this.path, required this.type}): super._();
  

/// Where it is, relative to the space root.
@override final  SpaceRelativePathValueObject path;
/// What it is.
@override final  SpaceEntryTypeEnum type;

/// Create a copy of SpaceEntryValueObject
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SpaceEntryValueObjectCopyWith<_SpaceEntryValueObject> get copyWith => __$SpaceEntryValueObjectCopyWithImpl<_SpaceEntryValueObject>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SpaceEntryValueObject&&(identical(other.path, path) || other.path == path)&&(identical(other.type, type) || other.type == type));
}


@override
int get hashCode => Object.hash(runtimeType,path,type);

@override
String toString() {
  return 'SpaceEntryValueObject(path: $path, type: $type)';
}


}

/// @nodoc
abstract mixin class _$SpaceEntryValueObjectCopyWith<$Res> implements $SpaceEntryValueObjectCopyWith<$Res> {
  factory _$SpaceEntryValueObjectCopyWith(_SpaceEntryValueObject value, $Res Function(_SpaceEntryValueObject) _then) = __$SpaceEntryValueObjectCopyWithImpl;
@override @useResult
$Res call({
 SpaceRelativePathValueObject path, SpaceEntryTypeEnum type
});




}
/// @nodoc
class __$SpaceEntryValueObjectCopyWithImpl<$Res>
    implements _$SpaceEntryValueObjectCopyWith<$Res> {
  __$SpaceEntryValueObjectCopyWithImpl(this._self, this._then);

  final _SpaceEntryValueObject _self;
  final $Res Function(_SpaceEntryValueObject) _then;

/// Create a copy of SpaceEntryValueObject
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? path = null,Object? type = null,}) {
  return _then(_SpaceEntryValueObject(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as SpaceRelativePathValueObject,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as SpaceEntryTypeEnum,
  ));
}


}

// dart format on
