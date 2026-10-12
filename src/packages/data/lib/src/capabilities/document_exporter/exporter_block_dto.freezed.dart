// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exporter_block_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ExporterBlockDto {

/// The document's own lines for the block, newline-joined.
 String get source;/// What kind of block it is.
 ExporterBlockKindEnum get kind;
/// Create a copy of ExporterBlockDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExporterBlockDtoCopyWith<ExporterBlockDto> get copyWith => _$ExporterBlockDtoCopyWithImpl<ExporterBlockDto>(this as ExporterBlockDto, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExporterBlockDto&&(identical(other.source, source) || other.source == source)&&(identical(other.kind, kind) || other.kind == kind));
}


@override
int get hashCode => Object.hash(runtimeType,source,kind);

@override
String toString() {
  return 'ExporterBlockDto(source: $source, kind: $kind)';
}


}

/// @nodoc
abstract mixin class $ExporterBlockDtoCopyWith<$Res>  {
  factory $ExporterBlockDtoCopyWith(ExporterBlockDto value, $Res Function(ExporterBlockDto) _then) = _$ExporterBlockDtoCopyWithImpl;
@useResult
$Res call({
 String source, ExporterBlockKindEnum kind
});




}
/// @nodoc
class _$ExporterBlockDtoCopyWithImpl<$Res>
    implements $ExporterBlockDtoCopyWith<$Res> {
  _$ExporterBlockDtoCopyWithImpl(this._self, this._then);

  final ExporterBlockDto _self;
  final $Res Function(ExporterBlockDto) _then;

/// Create a copy of ExporterBlockDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? source = null,Object? kind = null,}) {
  return _then(_self.copyWith(
source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ExporterBlockKindEnum,
  ));
}

}


/// Adds pattern-matching-related methods to [ExporterBlockDto].
extension ExporterBlockDtoPatterns on ExporterBlockDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExporterBlockDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExporterBlockDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExporterBlockDto value)  $default,){
final _that = this;
switch (_that) {
case _ExporterBlockDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExporterBlockDto value)?  $default,){
final _that = this;
switch (_that) {
case _ExporterBlockDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String source,  ExporterBlockKindEnum kind)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExporterBlockDto() when $default != null:
return $default(_that.source,_that.kind);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String source,  ExporterBlockKindEnum kind)  $default,) {final _that = this;
switch (_that) {
case _ExporterBlockDto():
return $default(_that.source,_that.kind);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String source,  ExporterBlockKindEnum kind)?  $default,) {final _that = this;
switch (_that) {
case _ExporterBlockDto() when $default != null:
return $default(_that.source,_that.kind);case _:
  return null;

}
}

}

/// @nodoc


class _ExporterBlockDto implements ExporterBlockDto {
  const _ExporterBlockDto({required this.source, required this.kind});
  

/// The document's own lines for the block, newline-joined.
@override final  String source;
/// What kind of block it is.
@override final  ExporterBlockKindEnum kind;

/// Create a copy of ExporterBlockDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExporterBlockDtoCopyWith<_ExporterBlockDto> get copyWith => __$ExporterBlockDtoCopyWithImpl<_ExporterBlockDto>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExporterBlockDto&&(identical(other.source, source) || other.source == source)&&(identical(other.kind, kind) || other.kind == kind));
}


@override
int get hashCode => Object.hash(runtimeType,source,kind);

@override
String toString() {
  return 'ExporterBlockDto(source: $source, kind: $kind)';
}


}

/// @nodoc
abstract mixin class _$ExporterBlockDtoCopyWith<$Res> implements $ExporterBlockDtoCopyWith<$Res> {
  factory _$ExporterBlockDtoCopyWith(_ExporterBlockDto value, $Res Function(_ExporterBlockDto) _then) = __$ExporterBlockDtoCopyWithImpl;
@override @useResult
$Res call({
 String source, ExporterBlockKindEnum kind
});




}
/// @nodoc
class __$ExporterBlockDtoCopyWithImpl<$Res>
    implements _$ExporterBlockDtoCopyWith<$Res> {
  __$ExporterBlockDtoCopyWithImpl(this._self, this._then);

  final _ExporterBlockDto _self;
  final $Res Function(_ExporterBlockDto) _then;

/// Create a copy of ExporterBlockDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? source = null,Object? kind = null,}) {
  return _then(_ExporterBlockDto(
source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ExporterBlockKindEnum,
  ));
}


}

// dart format on
