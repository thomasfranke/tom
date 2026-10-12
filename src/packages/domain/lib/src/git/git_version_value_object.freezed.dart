// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'git_version_value_object.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GitVersionValueObject {

 int get major; int get minor; int get patch;
/// Create a copy of GitVersionValueObject
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GitVersionValueObjectCopyWith<GitVersionValueObject> get copyWith => _$GitVersionValueObjectCopyWithImpl<GitVersionValueObject>(this as GitVersionValueObject, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GitVersionValueObject&&(identical(other.major, major) || other.major == major)&&(identical(other.minor, minor) || other.minor == minor)&&(identical(other.patch, patch) || other.patch == patch));
}


@override
int get hashCode => Object.hash(runtimeType,major,minor,patch);

@override
String toString() {
  return 'GitVersionValueObject(major: $major, minor: $minor, patch: $patch)';
}


}

/// @nodoc
abstract mixin class $GitVersionValueObjectCopyWith<$Res>  {
  factory $GitVersionValueObjectCopyWith(GitVersionValueObject value, $Res Function(GitVersionValueObject) _then) = _$GitVersionValueObjectCopyWithImpl;
@useResult
$Res call({
 int major, int minor, int patch
});




}
/// @nodoc
class _$GitVersionValueObjectCopyWithImpl<$Res>
    implements $GitVersionValueObjectCopyWith<$Res> {
  _$GitVersionValueObjectCopyWithImpl(this._self, this._then);

  final GitVersionValueObject _self;
  final $Res Function(GitVersionValueObject) _then;

/// Create a copy of GitVersionValueObject
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? major = null,Object? minor = null,Object? patch = null,}) {
  return _then(_self.copyWith(
major: null == major ? _self.major : major // ignore: cast_nullable_to_non_nullable
as int,minor: null == minor ? _self.minor : minor // ignore: cast_nullable_to_non_nullable
as int,patch: null == patch ? _self.patch : patch // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [GitVersionValueObject].
extension GitVersionValueObjectPatterns on GitVersionValueObject {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GitVersionValueObject value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GitVersionValueObject() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GitVersionValueObject value)  $default,){
final _that = this;
switch (_that) {
case _GitVersionValueObject():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GitVersionValueObject value)?  $default,){
final _that = this;
switch (_that) {
case _GitVersionValueObject() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int major,  int minor,  int patch)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GitVersionValueObject() when $default != null:
return $default(_that.major,_that.minor,_that.patch);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int major,  int minor,  int patch)  $default,) {final _that = this;
switch (_that) {
case _GitVersionValueObject():
return $default(_that.major,_that.minor,_that.patch);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int major,  int minor,  int patch)?  $default,) {final _that = this;
switch (_that) {
case _GitVersionValueObject() when $default != null:
return $default(_that.major,_that.minor,_that.patch);case _:
  return null;

}
}

}

/// @nodoc


class _GitVersionValueObject extends GitVersionValueObject {
  const _GitVersionValueObject({required this.major, required this.minor, this.patch = 0}): super._();
  

@override final  int major;
@override final  int minor;
@override@JsonKey() final  int patch;

/// Create a copy of GitVersionValueObject
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GitVersionValueObjectCopyWith<_GitVersionValueObject> get copyWith => __$GitVersionValueObjectCopyWithImpl<_GitVersionValueObject>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GitVersionValueObject&&(identical(other.major, major) || other.major == major)&&(identical(other.minor, minor) || other.minor == minor)&&(identical(other.patch, patch) || other.patch == patch));
}


@override
int get hashCode => Object.hash(runtimeType,major,minor,patch);

@override
String toString() {
  return 'GitVersionValueObject(major: $major, minor: $minor, patch: $patch)';
}


}

/// @nodoc
abstract mixin class _$GitVersionValueObjectCopyWith<$Res> implements $GitVersionValueObjectCopyWith<$Res> {
  factory _$GitVersionValueObjectCopyWith(_GitVersionValueObject value, $Res Function(_GitVersionValueObject) _then) = __$GitVersionValueObjectCopyWithImpl;
@override @useResult
$Res call({
 int major, int minor, int patch
});




}
/// @nodoc
class __$GitVersionValueObjectCopyWithImpl<$Res>
    implements _$GitVersionValueObjectCopyWith<$Res> {
  __$GitVersionValueObjectCopyWithImpl(this._self, this._then);

  final _GitVersionValueObject _self;
  final $Res Function(_GitVersionValueObject) _then;

/// Create a copy of GitVersionValueObject
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? major = null,Object? minor = null,Object? patch = null,}) {
  return _then(_GitVersionValueObject(
major: null == major ? _self.major : major // ignore: cast_nullable_to_non_nullable
as int,minor: null == minor ? _self.minor : minor // ignore: cast_nullable_to_non_nullable
as int,patch: null == patch ? _self.patch : patch // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
