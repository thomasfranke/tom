// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'release_value_object.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ReleaseValueObject {

 AppVersionValueObject get version;/// The release's page, where its notes are.
 String get notesUrl;
/// Create a copy of ReleaseValueObject
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReleaseValueObjectCopyWith<ReleaseValueObject> get copyWith => _$ReleaseValueObjectCopyWithImpl<ReleaseValueObject>(this as ReleaseValueObject, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReleaseValueObject&&(identical(other.version, version) || other.version == version)&&(identical(other.notesUrl, notesUrl) || other.notesUrl == notesUrl));
}


@override
int get hashCode => Object.hash(runtimeType,version,notesUrl);

@override
String toString() {
  return 'ReleaseValueObject(version: $version, notesUrl: $notesUrl)';
}


}

/// @nodoc
abstract mixin class $ReleaseValueObjectCopyWith<$Res>  {
  factory $ReleaseValueObjectCopyWith(ReleaseValueObject value, $Res Function(ReleaseValueObject) _then) = _$ReleaseValueObjectCopyWithImpl;
@useResult
$Res call({
 AppVersionValueObject version, String notesUrl
});


$AppVersionValueObjectCopyWith<$Res> get version;

}
/// @nodoc
class _$ReleaseValueObjectCopyWithImpl<$Res>
    implements $ReleaseValueObjectCopyWith<$Res> {
  _$ReleaseValueObjectCopyWithImpl(this._self, this._then);

  final ReleaseValueObject _self;
  final $Res Function(ReleaseValueObject) _then;

/// Create a copy of ReleaseValueObject
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? version = null,Object? notesUrl = null,}) {
  return _then(_self.copyWith(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as AppVersionValueObject,notesUrl: null == notesUrl ? _self.notesUrl : notesUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of ReleaseValueObject
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppVersionValueObjectCopyWith<$Res> get version {
  
  return $AppVersionValueObjectCopyWith<$Res>(_self.version, (value) {
    return _then(_self.copyWith(version: value));
  });
}
}


/// Adds pattern-matching-related methods to [ReleaseValueObject].
extension ReleaseValueObjectPatterns on ReleaseValueObject {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReleaseValueObject value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReleaseValueObject() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReleaseValueObject value)  $default,){
final _that = this;
switch (_that) {
case _ReleaseValueObject():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReleaseValueObject value)?  $default,){
final _that = this;
switch (_that) {
case _ReleaseValueObject() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AppVersionValueObject version,  String notesUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReleaseValueObject() when $default != null:
return $default(_that.version,_that.notesUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AppVersionValueObject version,  String notesUrl)  $default,) {final _that = this;
switch (_that) {
case _ReleaseValueObject():
return $default(_that.version,_that.notesUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AppVersionValueObject version,  String notesUrl)?  $default,) {final _that = this;
switch (_that) {
case _ReleaseValueObject() when $default != null:
return $default(_that.version,_that.notesUrl);case _:
  return null;

}
}

}

/// @nodoc


class _ReleaseValueObject implements ReleaseValueObject {
  const _ReleaseValueObject({required this.version, required this.notesUrl});
  

@override final  AppVersionValueObject version;
/// The release's page, where its notes are.
@override final  String notesUrl;

/// Create a copy of ReleaseValueObject
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReleaseValueObjectCopyWith<_ReleaseValueObject> get copyWith => __$ReleaseValueObjectCopyWithImpl<_ReleaseValueObject>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReleaseValueObject&&(identical(other.version, version) || other.version == version)&&(identical(other.notesUrl, notesUrl) || other.notesUrl == notesUrl));
}


@override
int get hashCode => Object.hash(runtimeType,version,notesUrl);

@override
String toString() {
  return 'ReleaseValueObject(version: $version, notesUrl: $notesUrl)';
}


}

/// @nodoc
abstract mixin class _$ReleaseValueObjectCopyWith<$Res> implements $ReleaseValueObjectCopyWith<$Res> {
  factory _$ReleaseValueObjectCopyWith(_ReleaseValueObject value, $Res Function(_ReleaseValueObject) _then) = __$ReleaseValueObjectCopyWithImpl;
@override @useResult
$Res call({
 AppVersionValueObject version, String notesUrl
});


@override $AppVersionValueObjectCopyWith<$Res> get version;

}
/// @nodoc
class __$ReleaseValueObjectCopyWithImpl<$Res>
    implements _$ReleaseValueObjectCopyWith<$Res> {
  __$ReleaseValueObjectCopyWithImpl(this._self, this._then);

  final _ReleaseValueObject _self;
  final $Res Function(_ReleaseValueObject) _then;

/// Create a copy of ReleaseValueObject
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? version = null,Object? notesUrl = null,}) {
  return _then(_ReleaseValueObject(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as AppVersionValueObject,notesUrl: null == notesUrl ? _self.notesUrl : notesUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of ReleaseValueObject
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppVersionValueObjectCopyWith<$Res> get version {
  
  return $AppVersionValueObjectCopyWith<$Res>(_self.version, (value) {
    return _then(_self.copyWith(version: value));
  });
}
}

// dart format on
