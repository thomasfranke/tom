// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'markdown_span_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MarkdownSpanDto {

/// The first line of the construct, zero-based and inclusive.
 int get startLine;/// The last line of the construct, zero-based and inclusive.
 int get endLine;/// What kind of construct it is.
 MarkdownSpanKindEnum get kind;
/// Create a copy of MarkdownSpanDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MarkdownSpanDtoCopyWith<MarkdownSpanDto> get copyWith => _$MarkdownSpanDtoCopyWithImpl<MarkdownSpanDto>(this as MarkdownSpanDto, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MarkdownSpanDto&&(identical(other.startLine, startLine) || other.startLine == startLine)&&(identical(other.endLine, endLine) || other.endLine == endLine)&&(identical(other.kind, kind) || other.kind == kind));
}


@override
int get hashCode => Object.hash(runtimeType,startLine,endLine,kind);

@override
String toString() {
  return 'MarkdownSpanDto(startLine: $startLine, endLine: $endLine, kind: $kind)';
}


}

/// @nodoc
abstract mixin class $MarkdownSpanDtoCopyWith<$Res>  {
  factory $MarkdownSpanDtoCopyWith(MarkdownSpanDto value, $Res Function(MarkdownSpanDto) _then) = _$MarkdownSpanDtoCopyWithImpl;
@useResult
$Res call({
 int startLine, int endLine, MarkdownSpanKindEnum kind
});




}
/// @nodoc
class _$MarkdownSpanDtoCopyWithImpl<$Res>
    implements $MarkdownSpanDtoCopyWith<$Res> {
  _$MarkdownSpanDtoCopyWithImpl(this._self, this._then);

  final MarkdownSpanDto _self;
  final $Res Function(MarkdownSpanDto) _then;

/// Create a copy of MarkdownSpanDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? startLine = null,Object? endLine = null,Object? kind = null,}) {
  return _then(_self.copyWith(
startLine: null == startLine ? _self.startLine : startLine // ignore: cast_nullable_to_non_nullable
as int,endLine: null == endLine ? _self.endLine : endLine // ignore: cast_nullable_to_non_nullable
as int,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as MarkdownSpanKindEnum,
  ));
}

}


/// Adds pattern-matching-related methods to [MarkdownSpanDto].
extension MarkdownSpanDtoPatterns on MarkdownSpanDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MarkdownSpanDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MarkdownSpanDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MarkdownSpanDto value)  $default,){
final _that = this;
switch (_that) {
case _MarkdownSpanDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MarkdownSpanDto value)?  $default,){
final _that = this;
switch (_that) {
case _MarkdownSpanDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int startLine,  int endLine,  MarkdownSpanKindEnum kind)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MarkdownSpanDto() when $default != null:
return $default(_that.startLine,_that.endLine,_that.kind);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int startLine,  int endLine,  MarkdownSpanKindEnum kind)  $default,) {final _that = this;
switch (_that) {
case _MarkdownSpanDto():
return $default(_that.startLine,_that.endLine,_that.kind);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int startLine,  int endLine,  MarkdownSpanKindEnum kind)?  $default,) {final _that = this;
switch (_that) {
case _MarkdownSpanDto() when $default != null:
return $default(_that.startLine,_that.endLine,_that.kind);case _:
  return null;

}
}

}

/// @nodoc


class _MarkdownSpanDto implements MarkdownSpanDto {
  const _MarkdownSpanDto({required this.startLine, required this.endLine, required this.kind});
  

/// The first line of the construct, zero-based and inclusive.
@override final  int startLine;
/// The last line of the construct, zero-based and inclusive.
@override final  int endLine;
/// What kind of construct it is.
@override final  MarkdownSpanKindEnum kind;

/// Create a copy of MarkdownSpanDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MarkdownSpanDtoCopyWith<_MarkdownSpanDto> get copyWith => __$MarkdownSpanDtoCopyWithImpl<_MarkdownSpanDto>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MarkdownSpanDto&&(identical(other.startLine, startLine) || other.startLine == startLine)&&(identical(other.endLine, endLine) || other.endLine == endLine)&&(identical(other.kind, kind) || other.kind == kind));
}


@override
int get hashCode => Object.hash(runtimeType,startLine,endLine,kind);

@override
String toString() {
  return 'MarkdownSpanDto(startLine: $startLine, endLine: $endLine, kind: $kind)';
}


}

/// @nodoc
abstract mixin class _$MarkdownSpanDtoCopyWith<$Res> implements $MarkdownSpanDtoCopyWith<$Res> {
  factory _$MarkdownSpanDtoCopyWith(_MarkdownSpanDto value, $Res Function(_MarkdownSpanDto) _then) = __$MarkdownSpanDtoCopyWithImpl;
@override @useResult
$Res call({
 int startLine, int endLine, MarkdownSpanKindEnum kind
});




}
/// @nodoc
class __$MarkdownSpanDtoCopyWithImpl<$Res>
    implements _$MarkdownSpanDtoCopyWith<$Res> {
  __$MarkdownSpanDtoCopyWithImpl(this._self, this._then);

  final _MarkdownSpanDto _self;
  final $Res Function(_MarkdownSpanDto) _then;

/// Create a copy of MarkdownSpanDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? startLine = null,Object? endLine = null,Object? kind = null,}) {
  return _then(_MarkdownSpanDto(
startLine: null == startLine ? _self.startLine : startLine // ignore: cast_nullable_to_non_nullable
as int,endLine: null == endLine ? _self.endLine : endLine // ignore: cast_nullable_to_non_nullable
as int,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as MarkdownSpanKindEnum,
  ));
}


}

// dart format on
