// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'block_value_object.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BlockValueObject {

/// The first line of the block, zero-based and inclusive.
 int get startLine;/// The last line of the block, zero-based and inclusive.
 int get endLine;/// The document's own lines for that span, newline-joined.
///
/// A slice of the document rather than a second copy of it: raw text and
/// structure without duplicated state.
 String get source;/// What kind of block it is.
 BlockKindEnum get kind;
/// Create a copy of BlockValueObject
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BlockValueObjectCopyWith<BlockValueObject> get copyWith => _$BlockValueObjectCopyWithImpl<BlockValueObject>(this as BlockValueObject, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BlockValueObject&&(identical(other.startLine, startLine) || other.startLine == startLine)&&(identical(other.endLine, endLine) || other.endLine == endLine)&&(identical(other.source, source) || other.source == source)&&(identical(other.kind, kind) || other.kind == kind));
}


@override
int get hashCode => Object.hash(runtimeType,startLine,endLine,source,kind);

@override
String toString() {
  return 'BlockValueObject(startLine: $startLine, endLine: $endLine, source: $source, kind: $kind)';
}


}

/// @nodoc
abstract mixin class $BlockValueObjectCopyWith<$Res>  {
  factory $BlockValueObjectCopyWith(BlockValueObject value, $Res Function(BlockValueObject) _then) = _$BlockValueObjectCopyWithImpl;
@useResult
$Res call({
 int startLine, int endLine, String source, BlockKindEnum kind
});




}
/// @nodoc
class _$BlockValueObjectCopyWithImpl<$Res>
    implements $BlockValueObjectCopyWith<$Res> {
  _$BlockValueObjectCopyWithImpl(this._self, this._then);

  final BlockValueObject _self;
  final $Res Function(BlockValueObject) _then;

/// Create a copy of BlockValueObject
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? startLine = null,Object? endLine = null,Object? source = null,Object? kind = null,}) {
  return _then(_self.copyWith(
startLine: null == startLine ? _self.startLine : startLine // ignore: cast_nullable_to_non_nullable
as int,endLine: null == endLine ? _self.endLine : endLine // ignore: cast_nullable_to_non_nullable
as int,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as BlockKindEnum,
  ));
}

}


/// Adds pattern-matching-related methods to [BlockValueObject].
extension BlockValueObjectPatterns on BlockValueObject {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BlockValueObject value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BlockValueObject() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BlockValueObject value)  $default,){
final _that = this;
switch (_that) {
case _BlockValueObject():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BlockValueObject value)?  $default,){
final _that = this;
switch (_that) {
case _BlockValueObject() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int startLine,  int endLine,  String source,  BlockKindEnum kind)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BlockValueObject() when $default != null:
return $default(_that.startLine,_that.endLine,_that.source,_that.kind);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int startLine,  int endLine,  String source,  BlockKindEnum kind)  $default,) {final _that = this;
switch (_that) {
case _BlockValueObject():
return $default(_that.startLine,_that.endLine,_that.source,_that.kind);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int startLine,  int endLine,  String source,  BlockKindEnum kind)?  $default,) {final _that = this;
switch (_that) {
case _BlockValueObject() when $default != null:
return $default(_that.startLine,_that.endLine,_that.source,_that.kind);case _:
  return null;

}
}

}

/// @nodoc


class _BlockValueObject extends BlockValueObject {
  const _BlockValueObject({required this.startLine, required this.endLine, required this.source, required this.kind}): super._();
  

/// The first line of the block, zero-based and inclusive.
@override final  int startLine;
/// The last line of the block, zero-based and inclusive.
@override final  int endLine;
/// The document's own lines for that span, newline-joined.
///
/// A slice of the document rather than a second copy of it: raw text and
/// structure without duplicated state.
@override final  String source;
/// What kind of block it is.
@override final  BlockKindEnum kind;

/// Create a copy of BlockValueObject
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BlockValueObjectCopyWith<_BlockValueObject> get copyWith => __$BlockValueObjectCopyWithImpl<_BlockValueObject>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BlockValueObject&&(identical(other.startLine, startLine) || other.startLine == startLine)&&(identical(other.endLine, endLine) || other.endLine == endLine)&&(identical(other.source, source) || other.source == source)&&(identical(other.kind, kind) || other.kind == kind));
}


@override
int get hashCode => Object.hash(runtimeType,startLine,endLine,source,kind);

@override
String toString() {
  return 'BlockValueObject(startLine: $startLine, endLine: $endLine, source: $source, kind: $kind)';
}


}

/// @nodoc
abstract mixin class _$BlockValueObjectCopyWith<$Res> implements $BlockValueObjectCopyWith<$Res> {
  factory _$BlockValueObjectCopyWith(_BlockValueObject value, $Res Function(_BlockValueObject) _then) = __$BlockValueObjectCopyWithImpl;
@override @useResult
$Res call({
 int startLine, int endLine, String source, BlockKindEnum kind
});




}
/// @nodoc
class __$BlockValueObjectCopyWithImpl<$Res>
    implements _$BlockValueObjectCopyWith<$Res> {
  __$BlockValueObjectCopyWithImpl(this._self, this._then);

  final _BlockValueObject _self;
  final $Res Function(_BlockValueObject) _then;

/// Create a copy of BlockValueObject
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? startLine = null,Object? endLine = null,Object? source = null,Object? kind = null,}) {
  return _then(_BlockValueObject(
startLine: null == startLine ? _self.startLine : startLine // ignore: cast_nullable_to_non_nullable
as int,endLine: null == endLine ? _self.endLine : endLine // ignore: cast_nullable_to_non_nullable
as int,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as BlockKindEnum,
  ));
}


}

// dart format on
