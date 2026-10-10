// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exporter_footnote_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ExporterFootnoteDto {

/// What the author called it — `a` in `[^a]`.
 String get label;/// Which one it is, counting from one in citation order.
 int get number;/// What it says, as markdown.
 String get text;
/// Create a copy of ExporterFootnoteDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExporterFootnoteDtoCopyWith<ExporterFootnoteDto> get copyWith => _$ExporterFootnoteDtoCopyWithImpl<ExporterFootnoteDto>(this as ExporterFootnoteDto, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExporterFootnoteDto&&(identical(other.label, label) || other.label == label)&&(identical(other.number, number) || other.number == number)&&(identical(other.text, text) || other.text == text));
}


@override
int get hashCode => Object.hash(runtimeType,label,number,text);

@override
String toString() {
  return 'ExporterFootnoteDto(label: $label, number: $number, text: $text)';
}


}

/// @nodoc
abstract mixin class $ExporterFootnoteDtoCopyWith<$Res>  {
  factory $ExporterFootnoteDtoCopyWith(ExporterFootnoteDto value, $Res Function(ExporterFootnoteDto) _then) = _$ExporterFootnoteDtoCopyWithImpl;
@useResult
$Res call({
 String label, int number, String text
});




}
/// @nodoc
class _$ExporterFootnoteDtoCopyWithImpl<$Res>
    implements $ExporterFootnoteDtoCopyWith<$Res> {
  _$ExporterFootnoteDtoCopyWithImpl(this._self, this._then);

  final ExporterFootnoteDto _self;
  final $Res Function(ExporterFootnoteDto) _then;

/// Create a copy of ExporterFootnoteDto
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


/// Adds pattern-matching-related methods to [ExporterFootnoteDto].
extension ExporterFootnoteDtoPatterns on ExporterFootnoteDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExporterFootnoteDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExporterFootnoteDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExporterFootnoteDto value)  $default,){
final _that = this;
switch (_that) {
case _ExporterFootnoteDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExporterFootnoteDto value)?  $default,){
final _that = this;
switch (_that) {
case _ExporterFootnoteDto() when $default != null:
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
case _ExporterFootnoteDto() when $default != null:
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
case _ExporterFootnoteDto():
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
case _ExporterFootnoteDto() when $default != null:
return $default(_that.label,_that.number,_that.text);case _:
  return null;

}
}

}

/// @nodoc


class _ExporterFootnoteDto implements ExporterFootnoteDto {
  const _ExporterFootnoteDto({required this.label, required this.number, required this.text});
  

/// What the author called it — `a` in `[^a]`.
@override final  String label;
/// Which one it is, counting from one in citation order.
@override final  int number;
/// What it says, as markdown.
@override final  String text;

/// Create a copy of ExporterFootnoteDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExporterFootnoteDtoCopyWith<_ExporterFootnoteDto> get copyWith => __$ExporterFootnoteDtoCopyWithImpl<_ExporterFootnoteDto>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExporterFootnoteDto&&(identical(other.label, label) || other.label == label)&&(identical(other.number, number) || other.number == number)&&(identical(other.text, text) || other.text == text));
}


@override
int get hashCode => Object.hash(runtimeType,label,number,text);

@override
String toString() {
  return 'ExporterFootnoteDto(label: $label, number: $number, text: $text)';
}


}

/// @nodoc
abstract mixin class _$ExporterFootnoteDtoCopyWith<$Res> implements $ExporterFootnoteDtoCopyWith<$Res> {
  factory _$ExporterFootnoteDtoCopyWith(_ExporterFootnoteDto value, $Res Function(_ExporterFootnoteDto) _then) = __$ExporterFootnoteDtoCopyWithImpl;
@override @useResult
$Res call({
 String label, int number, String text
});




}
/// @nodoc
class __$ExporterFootnoteDtoCopyWithImpl<$Res>
    implements _$ExporterFootnoteDtoCopyWith<$Res> {
  __$ExporterFootnoteDtoCopyWithImpl(this._self, this._then);

  final _ExporterFootnoteDto _self;
  final $Res Function(_ExporterFootnoteDto) _then;

/// Create a copy of ExporterFootnoteDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? label = null,Object? number = null,Object? text = null,}) {
  return _then(_ExporterFootnoteDto(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
