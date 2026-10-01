// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'markdown_footnote_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MarkdownFootnoteDto {

/// What the author called it — `a` in `[^a]`.
 String get label;/// Which one it is, counting from one in citation order.
 int get number;/// What it says, without the `[^label]:` that introduced it.
 String get text;
/// Create a copy of MarkdownFootnoteDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MarkdownFootnoteDtoCopyWith<MarkdownFootnoteDto> get copyWith => _$MarkdownFootnoteDtoCopyWithImpl<MarkdownFootnoteDto>(this as MarkdownFootnoteDto, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MarkdownFootnoteDto&&(identical(other.label, label) || other.label == label)&&(identical(other.number, number) || other.number == number)&&(identical(other.text, text) || other.text == text));
}


@override
int get hashCode => Object.hash(runtimeType,label,number,text);

@override
String toString() {
  return 'MarkdownFootnoteDto(label: $label, number: $number, text: $text)';
}


}

/// @nodoc
abstract mixin class $MarkdownFootnoteDtoCopyWith<$Res>  {
  factory $MarkdownFootnoteDtoCopyWith(MarkdownFootnoteDto value, $Res Function(MarkdownFootnoteDto) _then) = _$MarkdownFootnoteDtoCopyWithImpl;
@useResult
$Res call({
 String label, int number, String text
});




}
/// @nodoc
class _$MarkdownFootnoteDtoCopyWithImpl<$Res>
    implements $MarkdownFootnoteDtoCopyWith<$Res> {
  _$MarkdownFootnoteDtoCopyWithImpl(this._self, this._then);

  final MarkdownFootnoteDto _self;
  final $Res Function(MarkdownFootnoteDto) _then;

/// Create a copy of MarkdownFootnoteDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? label = null,Object? number = null,Object? text = null,}) {
  return _then(_self.copyWith(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MarkdownFootnoteDto].
extension MarkdownFootnoteDtoPatterns on MarkdownFootnoteDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MarkdownFootnoteDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MarkdownFootnoteDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MarkdownFootnoteDto value)  $default,){
final _that = this;
switch (_that) {
case _MarkdownFootnoteDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MarkdownFootnoteDto value)?  $default,){
final _that = this;
switch (_that) {
case _MarkdownFootnoteDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String label,  int number,  String text)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MarkdownFootnoteDto() when $default != null:
return $default(_that.label,_that.number,_that.text);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String label,  int number,  String text)  $default,) {final _that = this;
switch (_that) {
case _MarkdownFootnoteDto():
return $default(_that.label,_that.number,_that.text);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String label,  int number,  String text)?  $default,) {final _that = this;
switch (_that) {
case _MarkdownFootnoteDto() when $default != null:
return $default(_that.label,_that.number,_that.text);case _:
  return null;

}
}

}

/// @nodoc


class _MarkdownFootnoteDto implements MarkdownFootnoteDto {
  const _MarkdownFootnoteDto({required this.label, required this.number, required this.text});
  

/// What the author called it — `a` in `[^a]`.
@override final  String label;
/// Which one it is, counting from one in citation order.
@override final  int number;
/// What it says, without the `[^label]:` that introduced it.
@override final  String text;

/// Create a copy of MarkdownFootnoteDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MarkdownFootnoteDtoCopyWith<_MarkdownFootnoteDto> get copyWith => __$MarkdownFootnoteDtoCopyWithImpl<_MarkdownFootnoteDto>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MarkdownFootnoteDto&&(identical(other.label, label) || other.label == label)&&(identical(other.number, number) || other.number == number)&&(identical(other.text, text) || other.text == text));
}


@override
int get hashCode => Object.hash(runtimeType,label,number,text);

@override
String toString() {
  return 'MarkdownFootnoteDto(label: $label, number: $number, text: $text)';
}


}

/// @nodoc
abstract mixin class _$MarkdownFootnoteDtoCopyWith<$Res> implements $MarkdownFootnoteDtoCopyWith<$Res> {
  factory _$MarkdownFootnoteDtoCopyWith(_MarkdownFootnoteDto value, $Res Function(_MarkdownFootnoteDto) _then) = __$MarkdownFootnoteDtoCopyWithImpl;
@override @useResult
$Res call({
 String label, int number, String text
});




}
/// @nodoc
class __$MarkdownFootnoteDtoCopyWithImpl<$Res>
    implements _$MarkdownFootnoteDtoCopyWith<$Res> {
  __$MarkdownFootnoteDtoCopyWithImpl(this._self, this._then);

  final _MarkdownFootnoteDto _self;
  final $Res Function(_MarkdownFootnoteDto) _then;

/// Create a copy of MarkdownFootnoteDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? label = null,Object? number = null,Object? text = null,}) {
  return _then(_MarkdownFootnoteDto(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
