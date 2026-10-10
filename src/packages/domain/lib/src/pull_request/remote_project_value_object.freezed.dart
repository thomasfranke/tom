// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'remote_project_value_object.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RemoteProjectValueObject {

/// Where it lives.
 RemoteHostEnum get host;/// Its path on [host], without `.git`: `owner/repo`, or `group/sub/repo`
/// on GitLab.
 String get path;
/// Create a copy of RemoteProjectValueObject
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RemoteProjectValueObjectCopyWith<RemoteProjectValueObject> get copyWith => _$RemoteProjectValueObjectCopyWithImpl<RemoteProjectValueObject>(this as RemoteProjectValueObject, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RemoteProjectValueObject&&(identical(other.host, host) || other.host == host)&&(identical(other.path, path) || other.path == path));
}


@override
int get hashCode => Object.hash(runtimeType,host,path);

@override
String toString() {
  return 'RemoteProjectValueObject(host: $host, path: $path)';
}


}

/// @nodoc
abstract mixin class $RemoteProjectValueObjectCopyWith<$Res>  {
  factory $RemoteProjectValueObjectCopyWith(RemoteProjectValueObject value, $Res Function(RemoteProjectValueObject) _then) = _$RemoteProjectValueObjectCopyWithImpl;
@useResult
$Res call({
 RemoteHostEnum host, String path
});




}
/// @nodoc
class _$RemoteProjectValueObjectCopyWithImpl<$Res>
    implements $RemoteProjectValueObjectCopyWith<$Res> {
  _$RemoteProjectValueObjectCopyWithImpl(this._self, this._then);

  final RemoteProjectValueObject _self;
  final $Res Function(RemoteProjectValueObject) _then;

/// Create a copy of RemoteProjectValueObject
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? host = null,Object? path = null,}) {
  return _then(_self.copyWith(
host: null == host ? _self.host : host // ignore: cast_nullable_to_non_nullable
as RemoteHostEnum,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RemoteProjectValueObject].
extension RemoteProjectValueObjectPatterns on RemoteProjectValueObject {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RemoteProjectValueObject value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RemoteProjectValueObject() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RemoteProjectValueObject value)  $default,){
final _that = this;
switch (_that) {
case _RemoteProjectValueObject():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RemoteProjectValueObject value)?  $default,){
final _that = this;
switch (_that) {
case _RemoteProjectValueObject() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( RemoteHostEnum host,  String path)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RemoteProjectValueObject() when $default != null:
return $default(_that.host,_that.path);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( RemoteHostEnum host,  String path)  $default,) {final _that = this;
switch (_that) {
case _RemoteProjectValueObject():
return $default(_that.host,_that.path);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( RemoteHostEnum host,  String path)?  $default,) {final _that = this;
switch (_that) {
case _RemoteProjectValueObject() when $default != null:
return $default(_that.host,_that.path);case _:
  return null;

}
}

}

/// @nodoc


class _RemoteProjectValueObject extends RemoteProjectValueObject {
  const _RemoteProjectValueObject({required this.host, required this.path}): super._();
  

/// Where it lives.
@override final  RemoteHostEnum host;
/// Its path on [host], without `.git`: `owner/repo`, or `group/sub/repo`
/// on GitLab.
@override final  String path;

/// Create a copy of RemoteProjectValueObject
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RemoteProjectValueObjectCopyWith<_RemoteProjectValueObject> get copyWith => __$RemoteProjectValueObjectCopyWithImpl<_RemoteProjectValueObject>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RemoteProjectValueObject&&(identical(other.host, host) || other.host == host)&&(identical(other.path, path) || other.path == path));
}


@override
int get hashCode => Object.hash(runtimeType,host,path);

@override
String toString() {
  return 'RemoteProjectValueObject(host: $host, path: $path)';
}


}

/// @nodoc
abstract mixin class _$RemoteProjectValueObjectCopyWith<$Res> implements $RemoteProjectValueObjectCopyWith<$Res> {
  factory _$RemoteProjectValueObjectCopyWith(_RemoteProjectValueObject value, $Res Function(_RemoteProjectValueObject) _then) = __$RemoteProjectValueObjectCopyWithImpl;
@override @useResult
$Res call({
 RemoteHostEnum host, String path
});




}
/// @nodoc
class __$RemoteProjectValueObjectCopyWithImpl<$Res>
    implements _$RemoteProjectValueObjectCopyWith<$Res> {
  __$RemoteProjectValueObjectCopyWithImpl(this._self, this._then);

  final _RemoteProjectValueObject _self;
  final $Res Function(_RemoteProjectValueObject) _then;

/// Create a copy of RemoteProjectValueObject
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? host = null,Object? path = null,}) {
  return _then(_RemoteProjectValueObject(
host: null == host ? _self.host : host // ignore: cast_nullable_to_non_nullable
as RemoteHostEnum,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
