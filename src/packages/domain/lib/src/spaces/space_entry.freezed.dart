// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'space_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SpaceEntry {

/// Where it is, relative to the space root.
 SpaceRelativePath get path;/// What it is.
 SpaceEntryType get type;
/// Create a copy of SpaceEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SpaceEntryCopyWith<SpaceEntry> get copyWith => _$SpaceEntryCopyWithImpl<SpaceEntry>(this as SpaceEntry, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SpaceEntry&&(identical(other.path, path) || other.path == path)&&(identical(other.type, type) || other.type == type));
}


@override
int get hashCode => Object.hash(runtimeType,path,type);

@override
String toString() {
  return 'SpaceEntry(path: $path, type: $type)';
}


}

/// @nodoc
abstract mixin class $SpaceEntryCopyWith<$Res>  {
  factory $SpaceEntryCopyWith(SpaceEntry value, $Res Function(SpaceEntry) _then) = _$SpaceEntryCopyWithImpl;
@useResult
$Res call({
 SpaceRelativePath path, SpaceEntryType type
});




}
/// @nodoc
class _$SpaceEntryCopyWithImpl<$Res>
    implements $SpaceEntryCopyWith<$Res> {
  _$SpaceEntryCopyWithImpl(this._self, this._then);

  final SpaceEntry _self;
  final $Res Function(SpaceEntry) _then;

/// Create a copy of SpaceEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? path = null,Object? type = null,}) {
  return _then(_self.copyWith(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as SpaceRelativePath,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as SpaceEntryType,
  ));
}

}


/// Adds pattern-matching-related methods to [SpaceEntry].
extension SpaceEntryPatterns on SpaceEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SpaceEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SpaceEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SpaceEntry value)  $default,){
final _that = this;
switch (_that) {
case _SpaceEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SpaceEntry value)?  $default,){
final _that = this;
switch (_that) {
case _SpaceEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SpaceRelativePath path,  SpaceEntryType type)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SpaceEntry() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SpaceRelativePath path,  SpaceEntryType type)  $default,) {final _that = this;
switch (_that) {
case _SpaceEntry():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SpaceRelativePath path,  SpaceEntryType type)?  $default,) {final _that = this;
switch (_that) {
case _SpaceEntry() when $default != null:
return $default(_that.path,_that.type);case _:
  return null;

}
}

}

/// @nodoc


class _SpaceEntry extends SpaceEntry {
  const _SpaceEntry({required this.path, required this.type}): super._();
  

/// Where it is, relative to the space root.
@override final  SpaceRelativePath path;
/// What it is.
@override final  SpaceEntryType type;

/// Create a copy of SpaceEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SpaceEntryCopyWith<_SpaceEntry> get copyWith => __$SpaceEntryCopyWithImpl<_SpaceEntry>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SpaceEntry&&(identical(other.path, path) || other.path == path)&&(identical(other.type, type) || other.type == type));
}


@override
int get hashCode => Object.hash(runtimeType,path,type);

@override
String toString() {
  return 'SpaceEntry(path: $path, type: $type)';
}


}

/// @nodoc
abstract mixin class _$SpaceEntryCopyWith<$Res> implements $SpaceEntryCopyWith<$Res> {
  factory _$SpaceEntryCopyWith(_SpaceEntry value, $Res Function(_SpaceEntry) _then) = __$SpaceEntryCopyWithImpl;
@override @useResult
$Res call({
 SpaceRelativePath path, SpaceEntryType type
});




}
/// @nodoc
class __$SpaceEntryCopyWithImpl<$Res>
    implements _$SpaceEntryCopyWith<$Res> {
  __$SpaceEntryCopyWithImpl(this._self, this._then);

  final _SpaceEntry _self;
  final $Res Function(_SpaceEntry) _then;

/// Create a copy of SpaceEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? path = null,Object? type = null,}) {
  return _then(_SpaceEntry(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as SpaceRelativePath,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as SpaceEntryType,
  ));
}


}

// dart format on
