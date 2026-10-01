// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wikilink_value_object.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WikilinkValueObject {

/// What was written before the `#`, trimmed, never empty.
 String get target;/// What was written after the first `#`, or null when there was none.
 String? get anchor;
/// Create a copy of WikilinkValueObject
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WikilinkValueObjectCopyWith<WikilinkValueObject> get copyWith => _$WikilinkValueObjectCopyWithImpl<WikilinkValueObject>(this as WikilinkValueObject, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WikilinkValueObject&&(identical(other.target, target) || other.target == target)&&(identical(other.anchor, anchor) || other.anchor == anchor));
}


@override
int get hashCode => Object.hash(runtimeType,target,anchor);

@override
String toString() {
  return 'WikilinkValueObject(target: $target, anchor: $anchor)';
}


}

/// @nodoc
abstract mixin class $WikilinkValueObjectCopyWith<$Res>  {
  factory $WikilinkValueObjectCopyWith(WikilinkValueObject value, $Res Function(WikilinkValueObject) _then) = _$WikilinkValueObjectCopyWithImpl;
@useResult
$Res call({
 String target, String? anchor
});




}
/// @nodoc
class _$WikilinkValueObjectCopyWithImpl<$Res>
    implements $WikilinkValueObjectCopyWith<$Res> {
  _$WikilinkValueObjectCopyWithImpl(this._self, this._then);

  final WikilinkValueObject _self;
  final $Res Function(WikilinkValueObject) _then;

/// Create a copy of WikilinkValueObject
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? target = null,Object? anchor = freezed,}) {
  return _then(_self.copyWith(
target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as String,anchor: freezed == anchor ? _self.anchor : anchor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [WikilinkValueObject].
extension WikilinkValueObjectPatterns on WikilinkValueObject {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WikilinkValueObject value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WikilinkValueObject() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WikilinkValueObject value)  $default,){
final _that = this;
switch (_that) {
case _WikilinkValueObject():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WikilinkValueObject value)?  $default,){
final _that = this;
switch (_that) {
case _WikilinkValueObject() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String target,  String? anchor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WikilinkValueObject() when $default != null:
return $default(_that.target,_that.anchor);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String target,  String? anchor)  $default,) {final _that = this;
switch (_that) {
case _WikilinkValueObject():
return $default(_that.target,_that.anchor);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String target,  String? anchor)?  $default,) {final _that = this;
switch (_that) {
case _WikilinkValueObject() when $default != null:
return $default(_that.target,_that.anchor);case _:
  return null;

}
}

}

/// @nodoc


class _WikilinkValueObject extends WikilinkValueObject {
  const _WikilinkValueObject({required this.target, this.anchor}): super._();
  

/// What was written before the `#`, trimmed, never empty.
@override final  String target;
/// What was written after the first `#`, or null when there was none.
@override final  String? anchor;

/// Create a copy of WikilinkValueObject
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WikilinkValueObjectCopyWith<_WikilinkValueObject> get copyWith => __$WikilinkValueObjectCopyWithImpl<_WikilinkValueObject>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WikilinkValueObject&&(identical(other.target, target) || other.target == target)&&(identical(other.anchor, anchor) || other.anchor == anchor));
}


@override
int get hashCode => Object.hash(runtimeType,target,anchor);

@override
String toString() {
  return 'WikilinkValueObject(target: $target, anchor: $anchor)';
}


}

/// @nodoc
abstract mixin class _$WikilinkValueObjectCopyWith<$Res> implements $WikilinkValueObjectCopyWith<$Res> {
  factory _$WikilinkValueObjectCopyWith(_WikilinkValueObject value, $Res Function(_WikilinkValueObject) _then) = __$WikilinkValueObjectCopyWithImpl;
@override @useResult
$Res call({
 String target, String? anchor
});




}
/// @nodoc
class __$WikilinkValueObjectCopyWithImpl<$Res>
    implements _$WikilinkValueObjectCopyWith<$Res> {
  __$WikilinkValueObjectCopyWithImpl(this._self, this._then);

  final _WikilinkValueObject _self;
  final $Res Function(_WikilinkValueObject) _then;

/// Create a copy of WikilinkValueObject
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? target = null,Object? anchor = freezed,}) {
  return _then(_WikilinkValueObject(
target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as String,anchor: freezed == anchor ? _self.anchor : anchor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
