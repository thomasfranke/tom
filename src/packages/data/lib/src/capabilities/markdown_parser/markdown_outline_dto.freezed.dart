// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'markdown_outline_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MarkdownOutlineDto {

/// The spans, in the order they appear, never overlapping.
///
/// Handed over unmodifiable, never copied.
 List<MarkdownSpanDto> get spans;/// Every link reference definition, as its own lines, newline-joined.
///
/// Empty when the text declares none. The lines are the text's own, so
/// appending them to any fragment of it parses the same way.
 String get linkDefinitions;
/// Create a copy of MarkdownOutlineDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MarkdownOutlineDtoCopyWith<MarkdownOutlineDto> get copyWith => _$MarkdownOutlineDtoCopyWithImpl<MarkdownOutlineDto>(this as MarkdownOutlineDto, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MarkdownOutlineDto&&const DeepCollectionEquality().equals(other.spans, spans)&&(identical(other.linkDefinitions, linkDefinitions) || other.linkDefinitions == linkDefinitions));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(spans),linkDefinitions);

@override
String toString() {
  return 'MarkdownOutlineDto(spans: $spans, linkDefinitions: $linkDefinitions)';
}


}

/// @nodoc
abstract mixin class $MarkdownOutlineDtoCopyWith<$Res>  {
  factory $MarkdownOutlineDtoCopyWith(MarkdownOutlineDto value, $Res Function(MarkdownOutlineDto) _then) = _$MarkdownOutlineDtoCopyWithImpl;
@useResult
$Res call({
 List<MarkdownSpanDto> spans, String linkDefinitions
});




}
/// @nodoc
class _$MarkdownOutlineDtoCopyWithImpl<$Res>
    implements $MarkdownOutlineDtoCopyWith<$Res> {
  _$MarkdownOutlineDtoCopyWithImpl(this._self, this._then);

  final MarkdownOutlineDto _self;
  final $Res Function(MarkdownOutlineDto) _then;

/// Create a copy of MarkdownOutlineDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? spans = null,Object? linkDefinitions = null,}) {
  return _then(_self.copyWith(
spans: null == spans ? _self.spans : spans // ignore: cast_nullable_to_non_nullable
as List<MarkdownSpanDto>,linkDefinitions: null == linkDefinitions ? _self.linkDefinitions : linkDefinitions // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MarkdownOutlineDto].
extension MarkdownOutlineDtoPatterns on MarkdownOutlineDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MarkdownOutlineDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MarkdownOutlineDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MarkdownOutlineDto value)  $default,){
final _that = this;
switch (_that) {
case _MarkdownOutlineDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MarkdownOutlineDto value)?  $default,){
final _that = this;
switch (_that) {
case _MarkdownOutlineDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<MarkdownSpanDto> spans,  String linkDefinitions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MarkdownOutlineDto() when $default != null:
return $default(_that.spans,_that.linkDefinitions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<MarkdownSpanDto> spans,  String linkDefinitions)  $default,) {final _that = this;
switch (_that) {
case _MarkdownOutlineDto():
return $default(_that.spans,_that.linkDefinitions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<MarkdownSpanDto> spans,  String linkDefinitions)?  $default,) {final _that = this;
switch (_that) {
case _MarkdownOutlineDto() when $default != null:
return $default(_that.spans,_that.linkDefinitions);case _:
  return null;

}
}

}

/// @nodoc


class _MarkdownOutlineDto implements MarkdownOutlineDto {
  const _MarkdownOutlineDto({required final  List<MarkdownSpanDto> spans, required this.linkDefinitions}): _spans = spans;
  

/// The spans, in the order they appear, never overlapping.
///
/// Handed over unmodifiable, never copied.
 final  List<MarkdownSpanDto> _spans;
/// The spans, in the order they appear, never overlapping.
///
/// Handed over unmodifiable, never copied.
@override List<MarkdownSpanDto> get spans {
  if (_spans is EqualUnmodifiableListView) return _spans;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_spans);
}

/// Every link reference definition, as its own lines, newline-joined.
///
/// Empty when the text declares none. The lines are the text's own, so
/// appending them to any fragment of it parses the same way.
@override final  String linkDefinitions;

/// Create a copy of MarkdownOutlineDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MarkdownOutlineDtoCopyWith<_MarkdownOutlineDto> get copyWith => __$MarkdownOutlineDtoCopyWithImpl<_MarkdownOutlineDto>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MarkdownOutlineDto&&const DeepCollectionEquality().equals(other._spans, _spans)&&(identical(other.linkDefinitions, linkDefinitions) || other.linkDefinitions == linkDefinitions));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_spans),linkDefinitions);

@override
String toString() {
  return 'MarkdownOutlineDto(spans: $spans, linkDefinitions: $linkDefinitions)';
}


}

/// @nodoc
abstract mixin class _$MarkdownOutlineDtoCopyWith<$Res> implements $MarkdownOutlineDtoCopyWith<$Res> {
  factory _$MarkdownOutlineDtoCopyWith(_MarkdownOutlineDto value, $Res Function(_MarkdownOutlineDto) _then) = __$MarkdownOutlineDtoCopyWithImpl;
@override @useResult
$Res call({
 List<MarkdownSpanDto> spans, String linkDefinitions
});




}
/// @nodoc
class __$MarkdownOutlineDtoCopyWithImpl<$Res>
    implements _$MarkdownOutlineDtoCopyWith<$Res> {
  __$MarkdownOutlineDtoCopyWithImpl(this._self, this._then);

  final _MarkdownOutlineDto _self;
  final $Res Function(_MarkdownOutlineDto) _then;

/// Create a copy of MarkdownOutlineDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? spans = null,Object? linkDefinitions = null,}) {
  return _then(_MarkdownOutlineDto(
spans: null == spans ? _self._spans : spans // ignore: cast_nullable_to_non_nullable
as List<MarkdownSpanDto>,linkDefinitions: null == linkDefinitions ? _self.linkDefinitions : linkDefinitions // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
