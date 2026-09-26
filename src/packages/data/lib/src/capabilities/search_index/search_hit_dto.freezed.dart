// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_hit_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SearchHitDto {

/// The key the document was indexed under.
 String get key;/// The matching stretch of the text, with `…` where it was cut.
 String get excerpt;
/// Create a copy of SearchHitDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchHitDtoCopyWith<SearchHitDto> get copyWith => _$SearchHitDtoCopyWithImpl<SearchHitDto>(this as SearchHitDto, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchHitDto&&(identical(other.key, key) || other.key == key)&&(identical(other.excerpt, excerpt) || other.excerpt == excerpt));
}


@override
int get hashCode => Object.hash(runtimeType,key,excerpt);

@override
String toString() {
  return 'SearchHitDto(key: $key, excerpt: $excerpt)';
}


}

/// @nodoc
abstract mixin class $SearchHitDtoCopyWith<$Res>  {
  factory $SearchHitDtoCopyWith(SearchHitDto value, $Res Function(SearchHitDto) _then) = _$SearchHitDtoCopyWithImpl;
@useResult
$Res call({
 String key, String excerpt
});




}
/// @nodoc
class _$SearchHitDtoCopyWithImpl<$Res>
    implements $SearchHitDtoCopyWith<$Res> {
  _$SearchHitDtoCopyWithImpl(this._self, this._then);

  final SearchHitDto _self;
  final $Res Function(SearchHitDto) _then;

/// Create a copy of SearchHitDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? key = null,Object? excerpt = null,}) {
  return _then(_self.copyWith(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,excerpt: null == excerpt ? _self.excerpt : excerpt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SearchHitDto].
extension SearchHitDtoPatterns on SearchHitDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SearchHitDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SearchHitDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SearchHitDto value)  $default,){
final _that = this;
switch (_that) {
case _SearchHitDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SearchHitDto value)?  $default,){
final _that = this;
switch (_that) {
case _SearchHitDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String key,  String excerpt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SearchHitDto() when $default != null:
return $default(_that.key,_that.excerpt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String key,  String excerpt)  $default,) {final _that = this;
switch (_that) {
case _SearchHitDto():
return $default(_that.key,_that.excerpt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String key,  String excerpt)?  $default,) {final _that = this;
switch (_that) {
case _SearchHitDto() when $default != null:
return $default(_that.key,_that.excerpt);case _:
  return null;

}
}

}

/// @nodoc


class _SearchHitDto implements SearchHitDto {
  const _SearchHitDto({required this.key, required this.excerpt});
  

/// The key the document was indexed under.
@override final  String key;
/// The matching stretch of the text, with `…` where it was cut.
@override final  String excerpt;

/// Create a copy of SearchHitDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SearchHitDtoCopyWith<_SearchHitDto> get copyWith => __$SearchHitDtoCopyWithImpl<_SearchHitDto>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SearchHitDto&&(identical(other.key, key) || other.key == key)&&(identical(other.excerpt, excerpt) || other.excerpt == excerpt));
}


@override
int get hashCode => Object.hash(runtimeType,key,excerpt);

@override
String toString() {
  return 'SearchHitDto(key: $key, excerpt: $excerpt)';
}


}

/// @nodoc
abstract mixin class _$SearchHitDtoCopyWith<$Res> implements $SearchHitDtoCopyWith<$Res> {
  factory _$SearchHitDtoCopyWith(_SearchHitDto value, $Res Function(_SearchHitDto) _then) = __$SearchHitDtoCopyWithImpl;
@override @useResult
$Res call({
 String key, String excerpt
});




}
/// @nodoc
class __$SearchHitDtoCopyWithImpl<$Res>
    implements _$SearchHitDtoCopyWith<$Res> {
  __$SearchHitDtoCopyWithImpl(this._self, this._then);

  final _SearchHitDto _self;
  final $Res Function(_SearchHitDto) _then;

/// Create a copy of SearchHitDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? key = null,Object? excerpt = null,}) {
  return _then(_SearchHitDto(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,excerpt: null == excerpt ? _self.excerpt : excerpt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
