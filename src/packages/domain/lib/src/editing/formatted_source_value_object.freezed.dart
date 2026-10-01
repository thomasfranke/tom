// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'formatted_source_value_object.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FormattedSourceValueObject {

/// The whole source, not the changed part.
 String get text;/// Where the selection begins, as an offset into [text].
 int get start;/// Where it ends, exclusive; equal to [start] for a caret.
 int get end;
/// Create a copy of FormattedSourceValueObject
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FormattedSourceValueObjectCopyWith<FormattedSourceValueObject> get copyWith => _$FormattedSourceValueObjectCopyWithImpl<FormattedSourceValueObject>(this as FormattedSourceValueObject, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FormattedSourceValueObject&&(identical(other.text, text) || other.text == text)&&(identical(other.start, start) || other.start == start)&&(identical(other.end, end) || other.end == end));
}


@override
int get hashCode => Object.hash(runtimeType,text,start,end);

@override
String toString() {
  return 'FormattedSourceValueObject(text: $text, start: $start, end: $end)';
}


}

/// @nodoc
abstract mixin class $FormattedSourceValueObjectCopyWith<$Res>  {
  factory $FormattedSourceValueObjectCopyWith(FormattedSourceValueObject value, $Res Function(FormattedSourceValueObject) _then) = _$FormattedSourceValueObjectCopyWithImpl;
@useResult
$Res call({
 String text, int start, int end
});




}
/// @nodoc
class _$FormattedSourceValueObjectCopyWithImpl<$Res>
    implements $FormattedSourceValueObjectCopyWith<$Res> {
  _$FormattedSourceValueObjectCopyWithImpl(this._self, this._then);

  final FormattedSourceValueObject _self;
  final $Res Function(FormattedSourceValueObject) _then;

/// Create a copy of FormattedSourceValueObject
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? text = null,Object? start = null,Object? end = null,}) {
  return _then(_self.copyWith(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as int,end: null == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [FormattedSourceValueObject].
extension FormattedSourceValueObjectPatterns on FormattedSourceValueObject {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FormattedSourceValueObject value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FormattedSourceValueObject() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FormattedSourceValueObject value)  $default,){
final _that = this;
switch (_that) {
case _FormattedSourceValueObject():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FormattedSourceValueObject value)?  $default,){
final _that = this;
switch (_that) {
case _FormattedSourceValueObject() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String text,  int start,  int end)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FormattedSourceValueObject() when $default != null:
return $default(_that.text,_that.start,_that.end);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String text,  int start,  int end)  $default,) {final _that = this;
switch (_that) {
case _FormattedSourceValueObject():
return $default(_that.text,_that.start,_that.end);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String text,  int start,  int end)?  $default,) {final _that = this;
switch (_that) {
case _FormattedSourceValueObject() when $default != null:
return $default(_that.text,_that.start,_that.end);case _:
  return null;

}
}

}

/// @nodoc


class _FormattedSourceValueObject extends FormattedSourceValueObject {
  const _FormattedSourceValueObject({required this.text, required this.start, required this.end}): super._();
  

/// The whole source, not the changed part.
@override final  String text;
/// Where the selection begins, as an offset into [text].
@override final  int start;
/// Where it ends, exclusive; equal to [start] for a caret.
@override final  int end;

/// Create a copy of FormattedSourceValueObject
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FormattedSourceValueObjectCopyWith<_FormattedSourceValueObject> get copyWith => __$FormattedSourceValueObjectCopyWithImpl<_FormattedSourceValueObject>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FormattedSourceValueObject&&(identical(other.text, text) || other.text == text)&&(identical(other.start, start) || other.start == start)&&(identical(other.end, end) || other.end == end));
}


@override
int get hashCode => Object.hash(runtimeType,text,start,end);

@override
String toString() {
  return 'FormattedSourceValueObject(text: $text, start: $start, end: $end)';
}


}

/// @nodoc
abstract mixin class _$FormattedSourceValueObjectCopyWith<$Res> implements $FormattedSourceValueObjectCopyWith<$Res> {
  factory _$FormattedSourceValueObjectCopyWith(_FormattedSourceValueObject value, $Res Function(_FormattedSourceValueObject) _then) = __$FormattedSourceValueObjectCopyWithImpl;
@override @useResult
$Res call({
 String text, int start, int end
});




}
/// @nodoc
class __$FormattedSourceValueObjectCopyWithImpl<$Res>
    implements _$FormattedSourceValueObjectCopyWith<$Res> {
  __$FormattedSourceValueObjectCopyWithImpl(this._self, this._then);

  final _FormattedSourceValueObject _self;
  final $Res Function(_FormattedSourceValueObject) _then;

/// Create a copy of FormattedSourceValueObject
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? text = null,Object? start = null,Object? end = null,}) {
  return _then(_FormattedSourceValueObject(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as int,end: null == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
