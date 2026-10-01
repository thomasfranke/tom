// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'footnote_value_object.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FootnoteValueObject {

/// What the author called it — `a` in `[^a]`.
///
/// Never shown: it is how the two halves find each other, and a reader
/// sees [number] instead, which is what every markdown renderer draws.
 String get label;/// Which one it is, counting from one in citation order.
 int get number;/// What the note says, as markdown, without the `[^label]:` that
/// introduced it.
 String get text;
/// Create a copy of FootnoteValueObject
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FootnoteValueObjectCopyWith<FootnoteValueObject> get copyWith => _$FootnoteValueObjectCopyWithImpl<FootnoteValueObject>(this as FootnoteValueObject, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FootnoteValueObject&&(identical(other.label, label) || other.label == label)&&(identical(other.number, number) || other.number == number)&&(identical(other.text, text) || other.text == text));
}


@override
int get hashCode => Object.hash(runtimeType,label,number,text);

@override
String toString() {
  return 'FootnoteValueObject(label: $label, number: $number, text: $text)';
}


}

/// @nodoc
abstract mixin class $FootnoteValueObjectCopyWith<$Res>  {
  factory $FootnoteValueObjectCopyWith(FootnoteValueObject value, $Res Function(FootnoteValueObject) _then) = _$FootnoteValueObjectCopyWithImpl;
@useResult
$Res call({
 String label, int number, String text
});




}
/// @nodoc
class _$FootnoteValueObjectCopyWithImpl<$Res>
    implements $FootnoteValueObjectCopyWith<$Res> {
  _$FootnoteValueObjectCopyWithImpl(this._self, this._then);

  final FootnoteValueObject _self;
  final $Res Function(FootnoteValueObject) _then;

/// Create a copy of FootnoteValueObject
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


/// Adds pattern-matching-related methods to [FootnoteValueObject].
extension FootnoteValueObjectPatterns on FootnoteValueObject {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FootnoteValueObject value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FootnoteValueObject() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FootnoteValueObject value)  $default,){
final _that = this;
switch (_that) {
case _FootnoteValueObject():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FootnoteValueObject value)?  $default,){
final _that = this;
switch (_that) {
case _FootnoteValueObject() when $default != null:
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
case _FootnoteValueObject() when $default != null:
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
case _FootnoteValueObject():
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
case _FootnoteValueObject() when $default != null:
return $default(_that.label,_that.number,_that.text);case _:
  return null;

}
}

}

/// @nodoc


class _FootnoteValueObject extends FootnoteValueObject {
  const _FootnoteValueObject({required this.label, required this.number, required this.text}): super._();
  

/// What the author called it — `a` in `[^a]`.
///
/// Never shown: it is how the two halves find each other, and a reader
/// sees [number] instead, which is what every markdown renderer draws.
@override final  String label;
/// Which one it is, counting from one in citation order.
@override final  int number;
/// What the note says, as markdown, without the `[^label]:` that
/// introduced it.
@override final  String text;

/// Create a copy of FootnoteValueObject
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FootnoteValueObjectCopyWith<_FootnoteValueObject> get copyWith => __$FootnoteValueObjectCopyWithImpl<_FootnoteValueObject>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FootnoteValueObject&&(identical(other.label, label) || other.label == label)&&(identical(other.number, number) || other.number == number)&&(identical(other.text, text) || other.text == text));
}


@override
int get hashCode => Object.hash(runtimeType,label,number,text);

@override
String toString() {
  return 'FootnoteValueObject(label: $label, number: $number, text: $text)';
}


}

/// @nodoc
abstract mixin class _$FootnoteValueObjectCopyWith<$Res> implements $FootnoteValueObjectCopyWith<$Res> {
  factory _$FootnoteValueObjectCopyWith(_FootnoteValueObject value, $Res Function(_FootnoteValueObject) _then) = __$FootnoteValueObjectCopyWithImpl;
@override @useResult
$Res call({
 String label, int number, String text
});




}
/// @nodoc
class __$FootnoteValueObjectCopyWithImpl<$Res>
    implements _$FootnoteValueObjectCopyWith<$Res> {
  __$FootnoteValueObjectCopyWithImpl(this._self, this._then);

  final _FootnoteValueObject _self;
  final $Res Function(_FootnoteValueObject) _then;

/// Create a copy of FootnoteValueObject
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? label = null,Object? number = null,Object? text = null,}) {
  return _then(_FootnoteValueObject(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
