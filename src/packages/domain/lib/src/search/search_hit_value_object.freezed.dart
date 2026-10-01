// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_hit_value_object.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SearchHitValueObject {

/// Where the document is, relative to the space root.
 SpaceRelativePathValueObject get path;/// The matching stretch of its text, with `…` where it was cut.
 String get excerpt;
/// Create a copy of SearchHitValueObject
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchHitValueObjectCopyWith<SearchHitValueObject> get copyWith => _$SearchHitValueObjectCopyWithImpl<SearchHitValueObject>(this as SearchHitValueObject, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchHitValueObject&&(identical(other.path, path) || other.path == path)&&(identical(other.excerpt, excerpt) || other.excerpt == excerpt));
}


@override
int get hashCode => Object.hash(runtimeType,path,excerpt);

@override
String toString() {
  return 'SearchHitValueObject(path: $path, excerpt: $excerpt)';
}


}

/// @nodoc
abstract mixin class $SearchHitValueObjectCopyWith<$Res>  {
  factory $SearchHitValueObjectCopyWith(SearchHitValueObject value, $Res Function(SearchHitValueObject) _then) = _$SearchHitValueObjectCopyWithImpl;
@useResult
$Res call({
 SpaceRelativePathValueObject path, String excerpt
});




}
/// @nodoc
class _$SearchHitValueObjectCopyWithImpl<$Res>
    implements $SearchHitValueObjectCopyWith<$Res> {
  _$SearchHitValueObjectCopyWithImpl(this._self, this._then);

  final SearchHitValueObject _self;
  final $Res Function(SearchHitValueObject) _then;

/// Create a copy of SearchHitValueObject
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? path = null,Object? excerpt = null,}) {
  return _then(_self.copyWith(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as SpaceRelativePathValueObject,excerpt: null == excerpt ? _self.excerpt : excerpt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SearchHitValueObject].
extension SearchHitValueObjectPatterns on SearchHitValueObject {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SearchHitValueObject value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SearchHitValueObject() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SearchHitValueObject value)  $default,){
final _that = this;
switch (_that) {
case _SearchHitValueObject():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SearchHitValueObject value)?  $default,){
final _that = this;
switch (_that) {
case _SearchHitValueObject() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SpaceRelativePathValueObject path,  String excerpt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SearchHitValueObject() when $default != null:
return $default(_that.path,_that.excerpt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SpaceRelativePathValueObject path,  String excerpt)  $default,) {final _that = this;
switch (_that) {
case _SearchHitValueObject():
return $default(_that.path,_that.excerpt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SpaceRelativePathValueObject path,  String excerpt)?  $default,) {final _that = this;
switch (_that) {
case _SearchHitValueObject() when $default != null:
return $default(_that.path,_that.excerpt);case _:
  return null;

}
}

}

/// @nodoc


class _SearchHitValueObject extends SearchHitValueObject {
  const _SearchHitValueObject({required this.path, required this.excerpt}): super._();
  

/// Where the document is, relative to the space root.
@override final  SpaceRelativePathValueObject path;
/// The matching stretch of its text, with `…` where it was cut.
@override final  String excerpt;

/// Create a copy of SearchHitValueObject
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SearchHitValueObjectCopyWith<_SearchHitValueObject> get copyWith => __$SearchHitValueObjectCopyWithImpl<_SearchHitValueObject>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SearchHitValueObject&&(identical(other.path, path) || other.path == path)&&(identical(other.excerpt, excerpt) || other.excerpt == excerpt));
}


@override
int get hashCode => Object.hash(runtimeType,path,excerpt);

@override
String toString() {
  return 'SearchHitValueObject(path: $path, excerpt: $excerpt)';
}


}

/// @nodoc
abstract mixin class _$SearchHitValueObjectCopyWith<$Res> implements $SearchHitValueObjectCopyWith<$Res> {
  factory _$SearchHitValueObjectCopyWith(_SearchHitValueObject value, $Res Function(_SearchHitValueObject) _then) = __$SearchHitValueObjectCopyWithImpl;
@override @useResult
$Res call({
 SpaceRelativePathValueObject path, String excerpt
});




}
/// @nodoc
class __$SearchHitValueObjectCopyWithImpl<$Res>
    implements _$SearchHitValueObjectCopyWith<$Res> {
  __$SearchHitValueObjectCopyWithImpl(this._self, this._then);

  final _SearchHitValueObject _self;
  final $Res Function(_SearchHitValueObject) _then;

/// Create a copy of SearchHitValueObject
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? path = null,Object? excerpt = null,}) {
  return _then(_SearchHitValueObject(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as SpaceRelativePathValueObject,excerpt: null == excerpt ? _self.excerpt : excerpt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
