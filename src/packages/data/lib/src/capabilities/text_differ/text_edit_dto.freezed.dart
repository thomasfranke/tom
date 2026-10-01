// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'text_edit_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TextEditDto {

/// What happened to the entry.
 TextEditKindEnum get kind;/// Where it sat in the old sequence, or null when it is an addition.
 int? get beforeIndex;/// Where it sits in the new sequence, or null when it was removed.
 int? get afterIndex;
/// Create a copy of TextEditDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TextEditDtoCopyWith<TextEditDto> get copyWith => _$TextEditDtoCopyWithImpl<TextEditDto>(this as TextEditDto, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TextEditDto&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.beforeIndex, beforeIndex) || other.beforeIndex == beforeIndex)&&(identical(other.afterIndex, afterIndex) || other.afterIndex == afterIndex));
}


@override
int get hashCode => Object.hash(runtimeType,kind,beforeIndex,afterIndex);

@override
String toString() {
  return 'TextEditDto(kind: $kind, beforeIndex: $beforeIndex, afterIndex: $afterIndex)';
}


}

/// @nodoc
abstract mixin class $TextEditDtoCopyWith<$Res>  {
  factory $TextEditDtoCopyWith(TextEditDto value, $Res Function(TextEditDto) _then) = _$TextEditDtoCopyWithImpl;
@useResult
$Res call({
 TextEditKindEnum kind, int? beforeIndex, int? afterIndex
});




}
/// @nodoc
class _$TextEditDtoCopyWithImpl<$Res>
    implements $TextEditDtoCopyWith<$Res> {
  _$TextEditDtoCopyWithImpl(this._self, this._then);

  final TextEditDto _self;
  final $Res Function(TextEditDto) _then;

/// Create a copy of TextEditDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? kind = null,Object? beforeIndex = freezed,Object? afterIndex = freezed,}) {
  return _then(_self.copyWith(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as TextEditKindEnum,beforeIndex: freezed == beforeIndex ? _self.beforeIndex : beforeIndex // ignore: cast_nullable_to_non_nullable
as int?,afterIndex: freezed == afterIndex ? _self.afterIndex : afterIndex // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [TextEditDto].
extension TextEditDtoPatterns on TextEditDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TextEditDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TextEditDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TextEditDto value)  $default,){
final _that = this;
switch (_that) {
case _TextEditDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TextEditDto value)?  $default,){
final _that = this;
switch (_that) {
case _TextEditDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( TextEditKindEnum kind,  int? beforeIndex,  int? afterIndex)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TextEditDto() when $default != null:
return $default(_that.kind,_that.beforeIndex,_that.afterIndex);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( TextEditKindEnum kind,  int? beforeIndex,  int? afterIndex)  $default,) {final _that = this;
switch (_that) {
case _TextEditDto():
return $default(_that.kind,_that.beforeIndex,_that.afterIndex);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( TextEditKindEnum kind,  int? beforeIndex,  int? afterIndex)?  $default,) {final _that = this;
switch (_that) {
case _TextEditDto() when $default != null:
return $default(_that.kind,_that.beforeIndex,_that.afterIndex);case _:
  return null;

}
}

}

/// @nodoc


class _TextEditDto implements TextEditDto {
  const _TextEditDto({required this.kind, this.beforeIndex, this.afterIndex});
  

/// What happened to the entry.
@override final  TextEditKindEnum kind;
/// Where it sat in the old sequence, or null when it is an addition.
@override final  int? beforeIndex;
/// Where it sits in the new sequence, or null when it was removed.
@override final  int? afterIndex;

/// Create a copy of TextEditDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TextEditDtoCopyWith<_TextEditDto> get copyWith => __$TextEditDtoCopyWithImpl<_TextEditDto>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TextEditDto&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.beforeIndex, beforeIndex) || other.beforeIndex == beforeIndex)&&(identical(other.afterIndex, afterIndex) || other.afterIndex == afterIndex));
}


@override
int get hashCode => Object.hash(runtimeType,kind,beforeIndex,afterIndex);

@override
String toString() {
  return 'TextEditDto(kind: $kind, beforeIndex: $beforeIndex, afterIndex: $afterIndex)';
}


}

/// @nodoc
abstract mixin class _$TextEditDtoCopyWith<$Res> implements $TextEditDtoCopyWith<$Res> {
  factory _$TextEditDtoCopyWith(_TextEditDto value, $Res Function(_TextEditDto) _then) = __$TextEditDtoCopyWithImpl;
@override @useResult
$Res call({
 TextEditKindEnum kind, int? beforeIndex, int? afterIndex
});




}
/// @nodoc
class __$TextEditDtoCopyWithImpl<$Res>
    implements _$TextEditDtoCopyWith<$Res> {
  __$TextEditDtoCopyWithImpl(this._self, this._then);

  final _TextEditDto _self;
  final $Res Function(_TextEditDto) _then;

/// Create a copy of TextEditDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? kind = null,Object? beforeIndex = freezed,Object? afterIndex = freezed,}) {
  return _then(_TextEditDto(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as TextEditKindEnum,beforeIndex: freezed == beforeIndex ? _self.beforeIndex : beforeIndex // ignore: cast_nullable_to_non_nullable
as int?,afterIndex: freezed == afterIndex ? _self.afterIndex : afterIndex // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
