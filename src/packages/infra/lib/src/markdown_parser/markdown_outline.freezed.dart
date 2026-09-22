// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'markdown_outline.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MarkdownOutline {

/// The spans, in the order they appear, never overlapping.
///
/// Handed over unmodifiable, never copied.
 List<MarkdownSpan> get spans;/// Every link reference definition, as its own lines, newline-joined.
///
/// Empty when the text declares none. The lines are the text's own, so
/// appending them to any fragment of it parses the same way.
 String get linkDefinitions;
/// Create a copy of MarkdownOutline
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MarkdownOutlineCopyWith<MarkdownOutline> get copyWith => _$MarkdownOutlineCopyWithImpl<MarkdownOutline>(this as MarkdownOutline, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MarkdownOutline&&const DeepCollectionEquality().equals(other.spans, spans)&&(identical(other.linkDefinitions, linkDefinitions) || other.linkDefinitions == linkDefinitions));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(spans),linkDefinitions);

@override
String toString() {
  return 'MarkdownOutline(spans: $spans, linkDefinitions: $linkDefinitions)';
}


}

/// @nodoc
abstract mixin class $MarkdownOutlineCopyWith<$Res>  {
  factory $MarkdownOutlineCopyWith(MarkdownOutline value, $Res Function(MarkdownOutline) _then) = _$MarkdownOutlineCopyWithImpl;
@useResult
$Res call({
 List<MarkdownSpan> spans, String linkDefinitions
});




}
/// @nodoc
class _$MarkdownOutlineCopyWithImpl<$Res>
    implements $MarkdownOutlineCopyWith<$Res> {
  _$MarkdownOutlineCopyWithImpl(this._self, this._then);

  final MarkdownOutline _self;
  final $Res Function(MarkdownOutline) _then;

/// Create a copy of MarkdownOutline
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? spans = null,Object? linkDefinitions = null,}) {
  return _then(_self.copyWith(
spans: null == spans ? _self.spans : spans // ignore: cast_nullable_to_non_nullable
as List<MarkdownSpan>,linkDefinitions: null == linkDefinitions ? _self.linkDefinitions : linkDefinitions // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MarkdownOutline].
extension MarkdownOutlinePatterns on MarkdownOutline {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MarkdownOutline value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MarkdownOutline() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MarkdownOutline value)  $default,){
final _that = this;
switch (_that) {
case _MarkdownOutline():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MarkdownOutline value)?  $default,){
final _that = this;
switch (_that) {
case _MarkdownOutline() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<MarkdownSpan> spans,  String linkDefinitions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MarkdownOutline() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<MarkdownSpan> spans,  String linkDefinitions)  $default,) {final _that = this;
switch (_that) {
case _MarkdownOutline():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<MarkdownSpan> spans,  String linkDefinitions)?  $default,) {final _that = this;
switch (_that) {
case _MarkdownOutline() when $default != null:
return $default(_that.spans,_that.linkDefinitions);case _:
  return null;

}
}

}

/// @nodoc


class _MarkdownOutline implements MarkdownOutline {
  const _MarkdownOutline({required final  List<MarkdownSpan> spans, required this.linkDefinitions}): _spans = spans;
  

/// The spans, in the order they appear, never overlapping.
///
/// Handed over unmodifiable, never copied.
 final  List<MarkdownSpan> _spans;
/// The spans, in the order they appear, never overlapping.
///
/// Handed over unmodifiable, never copied.
@override List<MarkdownSpan> get spans {
  if (_spans is EqualUnmodifiableListView) return _spans;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_spans);
}

/// Every link reference definition, as its own lines, newline-joined.
///
/// Empty when the text declares none. The lines are the text's own, so
/// appending them to any fragment of it parses the same way.
@override final  String linkDefinitions;

/// Create a copy of MarkdownOutline
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MarkdownOutlineCopyWith<_MarkdownOutline> get copyWith => __$MarkdownOutlineCopyWithImpl<_MarkdownOutline>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MarkdownOutline&&const DeepCollectionEquality().equals(other._spans, _spans)&&(identical(other.linkDefinitions, linkDefinitions) || other.linkDefinitions == linkDefinitions));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_spans),linkDefinitions);

@override
String toString() {
  return 'MarkdownOutline(spans: $spans, linkDefinitions: $linkDefinitions)';
}


}

/// @nodoc
abstract mixin class _$MarkdownOutlineCopyWith<$Res> implements $MarkdownOutlineCopyWith<$Res> {
  factory _$MarkdownOutlineCopyWith(_MarkdownOutline value, $Res Function(_MarkdownOutline) _then) = __$MarkdownOutlineCopyWithImpl;
@override @useResult
$Res call({
 List<MarkdownSpan> spans, String linkDefinitions
});




}
/// @nodoc
class __$MarkdownOutlineCopyWithImpl<$Res>
    implements _$MarkdownOutlineCopyWith<$Res> {
  __$MarkdownOutlineCopyWithImpl(this._self, this._then);

  final _MarkdownOutline _self;
  final $Res Function(_MarkdownOutline) _then;

/// Create a copy of MarkdownOutline
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? spans = null,Object? linkDefinitions = null,}) {
  return _then(_MarkdownOutline(
spans: null == spans ? _self._spans : spans // ignore: cast_nullable_to_non_nullable
as List<MarkdownSpan>,linkDefinitions: null == linkDefinitions ? _self.linkDefinitions : linkDefinitions // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
