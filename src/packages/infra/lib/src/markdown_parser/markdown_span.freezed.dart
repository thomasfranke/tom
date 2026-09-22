// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'markdown_span.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MarkdownSpan {

/// The first line of the construct, zero-based and inclusive.
 int get startLine;/// The last line of the construct, zero-based and inclusive.
 int get endLine;/// What kind of construct it is.
 MarkdownSpanKind get kind;
/// Create a copy of MarkdownSpan
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MarkdownSpanCopyWith<MarkdownSpan> get copyWith => _$MarkdownSpanCopyWithImpl<MarkdownSpan>(this as MarkdownSpan, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MarkdownSpan&&(identical(other.startLine, startLine) || other.startLine == startLine)&&(identical(other.endLine, endLine) || other.endLine == endLine)&&(identical(other.kind, kind) || other.kind == kind));
}


@override
int get hashCode => Object.hash(runtimeType,startLine,endLine,kind);

@override
String toString() {
  return 'MarkdownSpan(startLine: $startLine, endLine: $endLine, kind: $kind)';
}


}

/// @nodoc
abstract mixin class $MarkdownSpanCopyWith<$Res>  {
  factory $MarkdownSpanCopyWith(MarkdownSpan value, $Res Function(MarkdownSpan) _then) = _$MarkdownSpanCopyWithImpl;
@useResult
$Res call({
 int startLine, int endLine, MarkdownSpanKind kind
});




}
/// @nodoc
class _$MarkdownSpanCopyWithImpl<$Res>
    implements $MarkdownSpanCopyWith<$Res> {
  _$MarkdownSpanCopyWithImpl(this._self, this._then);

  final MarkdownSpan _self;
  final $Res Function(MarkdownSpan) _then;

/// Create a copy of MarkdownSpan
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? startLine = null,Object? endLine = null,Object? kind = null,}) {
  return _then(_self.copyWith(
startLine: null == startLine ? _self.startLine : startLine // ignore: cast_nullable_to_non_nullable
as int,endLine: null == endLine ? _self.endLine : endLine // ignore: cast_nullable_to_non_nullable
as int,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as MarkdownSpanKind,
  ));
}

}


/// Adds pattern-matching-related methods to [MarkdownSpan].
extension MarkdownSpanPatterns on MarkdownSpan {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MarkdownSpan value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MarkdownSpan() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MarkdownSpan value)  $default,){
final _that = this;
switch (_that) {
case _MarkdownSpan():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MarkdownSpan value)?  $default,){
final _that = this;
switch (_that) {
case _MarkdownSpan() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int startLine,  int endLine,  MarkdownSpanKind kind)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MarkdownSpan() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int startLine,  int endLine,  MarkdownSpanKind kind)  $default,) {final _that = this;
switch (_that) {
case _MarkdownSpan():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int startLine,  int endLine,  MarkdownSpanKind kind)?  $default,) {final _that = this;
switch (_that) {
case _MarkdownSpan() when $default != null:
return $default(_that.startLine,_that.endLine,_that.kind);case _:
  return null;

}
}

}

/// @nodoc


class _MarkdownSpan implements MarkdownSpan {
  const _MarkdownSpan({required this.startLine, required this.endLine, required this.kind});
  

/// The first line of the construct, zero-based and inclusive.
@override final  int startLine;
/// The last line of the construct, zero-based and inclusive.
@override final  int endLine;
/// What kind of construct it is.
@override final  MarkdownSpanKind kind;

/// Create a copy of MarkdownSpan
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MarkdownSpanCopyWith<_MarkdownSpan> get copyWith => __$MarkdownSpanCopyWithImpl<_MarkdownSpan>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MarkdownSpan&&(identical(other.startLine, startLine) || other.startLine == startLine)&&(identical(other.endLine, endLine) || other.endLine == endLine)&&(identical(other.kind, kind) || other.kind == kind));
}


@override
int get hashCode => Object.hash(runtimeType,startLine,endLine,kind);

@override
String toString() {
  return 'MarkdownSpan(startLine: $startLine, endLine: $endLine, kind: $kind)';
}


}

/// @nodoc
abstract mixin class _$MarkdownSpanCopyWith<$Res> implements $MarkdownSpanCopyWith<$Res> {
  factory _$MarkdownSpanCopyWith(_MarkdownSpan value, $Res Function(_MarkdownSpan) _then) = __$MarkdownSpanCopyWithImpl;
@override @useResult
$Res call({
 int startLine, int endLine, MarkdownSpanKind kind
});




}
/// @nodoc
class __$MarkdownSpanCopyWithImpl<$Res>
    implements _$MarkdownSpanCopyWith<$Res> {
  __$MarkdownSpanCopyWithImpl(this._self, this._then);

  final _MarkdownSpan _self;
  final $Res Function(_MarkdownSpan) _then;

/// Create a copy of MarkdownSpan
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? startLine = null,Object? endLine = null,Object? kind = null,}) {
  return _then(_MarkdownSpan(
startLine: null == startLine ? _self.startLine : startLine // ignore: cast_nullable_to_non_nullable
as int,endLine: null == endLine ? _self.endLine : endLine // ignore: cast_nullable_to_non_nullable
as int,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as MarkdownSpanKind,
  ));
}


}

// dart format on
