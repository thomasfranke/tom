// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'indexed_document_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$IndexedDocumentDto {

/// What the caller calls it; unique, and echoed back by every hit.
 String get key;/// Everything about it that can be searched for.
 String get text;
/// Create a copy of IndexedDocumentDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IndexedDocumentDtoCopyWith<IndexedDocumentDto> get copyWith => _$IndexedDocumentDtoCopyWithImpl<IndexedDocumentDto>(this as IndexedDocumentDto, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IndexedDocumentDto&&(identical(other.key, key) || other.key == key)&&(identical(other.text, text) || other.text == text));
}


@override
int get hashCode => Object.hash(runtimeType,key,text);

@override
String toString() {
  return 'IndexedDocumentDto(key: $key, text: $text)';
}


}

/// @nodoc
abstract mixin class $IndexedDocumentDtoCopyWith<$Res>  {
  factory $IndexedDocumentDtoCopyWith(IndexedDocumentDto value, $Res Function(IndexedDocumentDto) _then) = _$IndexedDocumentDtoCopyWithImpl;
@useResult
$Res call({
 String key, String text
});




}
/// @nodoc
class _$IndexedDocumentDtoCopyWithImpl<$Res>
    implements $IndexedDocumentDtoCopyWith<$Res> {
  _$IndexedDocumentDtoCopyWithImpl(this._self, this._then);

  final IndexedDocumentDto _self;
  final $Res Function(IndexedDocumentDto) _then;

/// Create a copy of IndexedDocumentDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? key = null,Object? text = null,}) {
  return _then(_self.copyWith(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [IndexedDocumentDto].
extension IndexedDocumentDtoPatterns on IndexedDocumentDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IndexedDocumentDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IndexedDocumentDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IndexedDocumentDto value)  $default,){
final _that = this;
switch (_that) {
case _IndexedDocumentDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IndexedDocumentDto value)?  $default,){
final _that = this;
switch (_that) {
case _IndexedDocumentDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String key,  String text)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IndexedDocumentDto() when $default != null:
return $default(_that.key,_that.text);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String key,  String text)  $default,) {final _that = this;
switch (_that) {
case _IndexedDocumentDto():
return $default(_that.key,_that.text);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String key,  String text)?  $default,) {final _that = this;
switch (_that) {
case _IndexedDocumentDto() when $default != null:
return $default(_that.key,_that.text);case _:
  return null;

}
}

}

/// @nodoc


class _IndexedDocumentDto implements IndexedDocumentDto {
  const _IndexedDocumentDto({required this.key, required this.text});
  

/// What the caller calls it; unique, and echoed back by every hit.
@override final  String key;
/// Everything about it that can be searched for.
@override final  String text;

/// Create a copy of IndexedDocumentDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IndexedDocumentDtoCopyWith<_IndexedDocumentDto> get copyWith => __$IndexedDocumentDtoCopyWithImpl<_IndexedDocumentDto>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IndexedDocumentDto&&(identical(other.key, key) || other.key == key)&&(identical(other.text, text) || other.text == text));
}


@override
int get hashCode => Object.hash(runtimeType,key,text);

@override
String toString() {
  return 'IndexedDocumentDto(key: $key, text: $text)';
}


}

/// @nodoc
abstract mixin class _$IndexedDocumentDtoCopyWith<$Res> implements $IndexedDocumentDtoCopyWith<$Res> {
  factory _$IndexedDocumentDtoCopyWith(_IndexedDocumentDto value, $Res Function(_IndexedDocumentDto) _then) = __$IndexedDocumentDtoCopyWithImpl;
@override @useResult
$Res call({
 String key, String text
});




}
/// @nodoc
class __$IndexedDocumentDtoCopyWithImpl<$Res>
    implements _$IndexedDocumentDtoCopyWith<$Res> {
  __$IndexedDocumentDtoCopyWithImpl(this._self, this._then);

  final _IndexedDocumentDto _self;
  final $Res Function(_IndexedDocumentDto) _then;

/// Create a copy of IndexedDocumentDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? key = null,Object? text = null,}) {
  return _then(_IndexedDocumentDto(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
