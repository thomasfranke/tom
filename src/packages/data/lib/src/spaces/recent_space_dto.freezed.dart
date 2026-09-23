// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recent_space_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RecentSpaceDto {

/// The absolute path of the space's folder.
 String get root;/// What the folder is called.
 String get name;/// When it was last opened, ISO 8601 in UTC.
 String get lastOpened;
/// Create a copy of RecentSpaceDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecentSpaceDtoCopyWith<RecentSpaceDto> get copyWith => _$RecentSpaceDtoCopyWithImpl<RecentSpaceDto>(this as RecentSpaceDto, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecentSpaceDto&&(identical(other.root, root) || other.root == root)&&(identical(other.name, name) || other.name == name)&&(identical(other.lastOpened, lastOpened) || other.lastOpened == lastOpened));
}


@override
int get hashCode => Object.hash(runtimeType,root,name,lastOpened);

@override
String toString() {
  return 'RecentSpaceDto(root: $root, name: $name, lastOpened: $lastOpened)';
}


}

/// @nodoc
abstract mixin class $RecentSpaceDtoCopyWith<$Res>  {
  factory $RecentSpaceDtoCopyWith(RecentSpaceDto value, $Res Function(RecentSpaceDto) _then) = _$RecentSpaceDtoCopyWithImpl;
@useResult
$Res call({
 String root, String name, String lastOpened
});




}
/// @nodoc
class _$RecentSpaceDtoCopyWithImpl<$Res>
    implements $RecentSpaceDtoCopyWith<$Res> {
  _$RecentSpaceDtoCopyWithImpl(this._self, this._then);

  final RecentSpaceDto _self;
  final $Res Function(RecentSpaceDto) _then;

/// Create a copy of RecentSpaceDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? root = null,Object? name = null,Object? lastOpened = null,}) {
  return _then(_self.copyWith(
root: null == root ? _self.root : root // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,lastOpened: null == lastOpened ? _self.lastOpened : lastOpened // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RecentSpaceDto].
extension RecentSpaceDtoPatterns on RecentSpaceDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecentSpaceDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecentSpaceDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecentSpaceDto value)  $default,){
final _that = this;
switch (_that) {
case _RecentSpaceDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecentSpaceDto value)?  $default,){
final _that = this;
switch (_that) {
case _RecentSpaceDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String root,  String name,  String lastOpened)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecentSpaceDto() when $default != null:
return $default(_that.root,_that.name,_that.lastOpened);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String root,  String name,  String lastOpened)  $default,) {final _that = this;
switch (_that) {
case _RecentSpaceDto():
return $default(_that.root,_that.name,_that.lastOpened);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String root,  String name,  String lastOpened)?  $default,) {final _that = this;
switch (_that) {
case _RecentSpaceDto() when $default != null:
return $default(_that.root,_that.name,_that.lastOpened);case _:
  return null;

}
}

}

/// @nodoc


class _RecentSpaceDto extends RecentSpaceDto {
  const _RecentSpaceDto({required this.root, required this.name, required this.lastOpened}): super._();
  

/// The absolute path of the space's folder.
@override final  String root;
/// What the folder is called.
@override final  String name;
/// When it was last opened, ISO 8601 in UTC.
@override final  String lastOpened;

/// Create a copy of RecentSpaceDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecentSpaceDtoCopyWith<_RecentSpaceDto> get copyWith => __$RecentSpaceDtoCopyWithImpl<_RecentSpaceDto>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecentSpaceDto&&(identical(other.root, root) || other.root == root)&&(identical(other.name, name) || other.name == name)&&(identical(other.lastOpened, lastOpened) || other.lastOpened == lastOpened));
}


@override
int get hashCode => Object.hash(runtimeType,root,name,lastOpened);

@override
String toString() {
  return 'RecentSpaceDto(root: $root, name: $name, lastOpened: $lastOpened)';
}


}

/// @nodoc
abstract mixin class _$RecentSpaceDtoCopyWith<$Res> implements $RecentSpaceDtoCopyWith<$Res> {
  factory _$RecentSpaceDtoCopyWith(_RecentSpaceDto value, $Res Function(_RecentSpaceDto) _then) = __$RecentSpaceDtoCopyWithImpl;
@override @useResult
$Res call({
 String root, String name, String lastOpened
});




}
/// @nodoc
class __$RecentSpaceDtoCopyWithImpl<$Res>
    implements _$RecentSpaceDtoCopyWith<$Res> {
  __$RecentSpaceDtoCopyWithImpl(this._self, this._then);

  final _RecentSpaceDto _self;
  final $Res Function(_RecentSpaceDto) _then;

/// Create a copy of RecentSpaceDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? root = null,Object? name = null,Object? lastOpened = null,}) {
  return _then(_RecentSpaceDto(
root: null == root ? _self.root : root // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,lastOpened: null == lastOpened ? _self.lastOpened : lastOpened // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
