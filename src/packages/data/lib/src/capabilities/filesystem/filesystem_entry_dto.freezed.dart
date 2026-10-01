// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'filesystem_entry_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FilesystemEntryDto {

/// The absolute path of the entry.
 String get path;/// What the entry is.
 FilesystemEntryTypeEnum get type;
/// Create a copy of FilesystemEntryDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FilesystemEntryDtoCopyWith<FilesystemEntryDto> get copyWith => _$FilesystemEntryDtoCopyWithImpl<FilesystemEntryDto>(this as FilesystemEntryDto, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FilesystemEntryDto&&(identical(other.path, path) || other.path == path)&&(identical(other.type, type) || other.type == type));
}


@override
int get hashCode => Object.hash(runtimeType,path,type);

@override
String toString() {
  return 'FilesystemEntryDto(path: $path, type: $type)';
}


}

/// @nodoc
abstract mixin class $FilesystemEntryDtoCopyWith<$Res>  {
  factory $FilesystemEntryDtoCopyWith(FilesystemEntryDto value, $Res Function(FilesystemEntryDto) _then) = _$FilesystemEntryDtoCopyWithImpl;
@useResult
$Res call({
 String path, FilesystemEntryTypeEnum type
});




}
/// @nodoc
class _$FilesystemEntryDtoCopyWithImpl<$Res>
    implements $FilesystemEntryDtoCopyWith<$Res> {
  _$FilesystemEntryDtoCopyWithImpl(this._self, this._then);

  final FilesystemEntryDto _self;
  final $Res Function(FilesystemEntryDto) _then;

/// Create a copy of FilesystemEntryDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? path = null,Object? type = null,}) {
  return _then(_self.copyWith(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as FilesystemEntryTypeEnum,
  ));
}

}


/// Adds pattern-matching-related methods to [FilesystemEntryDto].
extension FilesystemEntryDtoPatterns on FilesystemEntryDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FilesystemEntryDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FilesystemEntryDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FilesystemEntryDto value)  $default,){
final _that = this;
switch (_that) {
case _FilesystemEntryDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FilesystemEntryDto value)?  $default,){
final _that = this;
switch (_that) {
case _FilesystemEntryDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String path,  FilesystemEntryTypeEnum type)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FilesystemEntryDto() when $default != null:
return $default(_that.path,_that.type);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String path,  FilesystemEntryTypeEnum type)  $default,) {final _that = this;
switch (_that) {
case _FilesystemEntryDto():
return $default(_that.path,_that.type);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String path,  FilesystemEntryTypeEnum type)?  $default,) {final _that = this;
switch (_that) {
case _FilesystemEntryDto() when $default != null:
return $default(_that.path,_that.type);case _:
  return null;

}
}

}

/// @nodoc


class _FilesystemEntryDto implements FilesystemEntryDto {
  const _FilesystemEntryDto({required this.path, required this.type});
  

/// The absolute path of the entry.
@override final  String path;
/// What the entry is.
@override final  FilesystemEntryTypeEnum type;

/// Create a copy of FilesystemEntryDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FilesystemEntryDtoCopyWith<_FilesystemEntryDto> get copyWith => __$FilesystemEntryDtoCopyWithImpl<_FilesystemEntryDto>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FilesystemEntryDto&&(identical(other.path, path) || other.path == path)&&(identical(other.type, type) || other.type == type));
}


@override
int get hashCode => Object.hash(runtimeType,path,type);

@override
String toString() {
  return 'FilesystemEntryDto(path: $path, type: $type)';
}


}

/// @nodoc
abstract mixin class _$FilesystemEntryDtoCopyWith<$Res> implements $FilesystemEntryDtoCopyWith<$Res> {
  factory _$FilesystemEntryDtoCopyWith(_FilesystemEntryDto value, $Res Function(_FilesystemEntryDto) _then) = __$FilesystemEntryDtoCopyWithImpl;
@override @useResult
$Res call({
 String path, FilesystemEntryTypeEnum type
});




}
/// @nodoc
class __$FilesystemEntryDtoCopyWithImpl<$Res>
    implements _$FilesystemEntryDtoCopyWith<$Res> {
  __$FilesystemEntryDtoCopyWithImpl(this._self, this._then);

  final _FilesystemEntryDto _self;
  final $Res Function(_FilesystemEntryDto) _then;

/// Create a copy of FilesystemEntryDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? path = null,Object? type = null,}) {
  return _then(_FilesystemEntryDto(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as FilesystemEntryTypeEnum,
  ));
}


}

// dart format on
