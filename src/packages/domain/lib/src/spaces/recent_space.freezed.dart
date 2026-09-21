// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recent_space.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RecentSpace {

/// The absolute path of the folder that was opened; its identity.
 String get root;/// What it was called the last time it was open.
///
/// Stored rather than re-derived so the list reads the same as the app
/// did, even for a folder that is no longer there to ask.
 String get name;/// When it was last opened, in UTC.
///
/// Only used to order the list. An instant rather than a position,
/// because two windows can open two spaces and neither should have to
/// renumber the other's.
 DateTime get lastOpened;
/// Create a copy of RecentSpace
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecentSpaceCopyWith<RecentSpace> get copyWith => _$RecentSpaceCopyWithImpl<RecentSpace>(this as RecentSpace, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecentSpace&&(identical(other.root, root) || other.root == root)&&(identical(other.name, name) || other.name == name)&&(identical(other.lastOpened, lastOpened) || other.lastOpened == lastOpened));
}


@override
int get hashCode => Object.hash(runtimeType,root,name,lastOpened);

@override
String toString() {
  return 'RecentSpace(root: $root, name: $name, lastOpened: $lastOpened)';
}


}

/// @nodoc
abstract mixin class $RecentSpaceCopyWith<$Res>  {
  factory $RecentSpaceCopyWith(RecentSpace value, $Res Function(RecentSpace) _then) = _$RecentSpaceCopyWithImpl;
@useResult
$Res call({
 String root, String name, DateTime lastOpened
});




}
/// @nodoc
class _$RecentSpaceCopyWithImpl<$Res>
    implements $RecentSpaceCopyWith<$Res> {
  _$RecentSpaceCopyWithImpl(this._self, this._then);

  final RecentSpace _self;
  final $Res Function(RecentSpace) _then;

/// Create a copy of RecentSpace
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? root = null,Object? name = null,Object? lastOpened = null,}) {
  return _then(_self.copyWith(
root: null == root ? _self.root : root // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,lastOpened: null == lastOpened ? _self.lastOpened : lastOpened // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [RecentSpace].
extension RecentSpacePatterns on RecentSpace {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecentSpace value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecentSpace() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecentSpace value)  $default,){
final _that = this;
switch (_that) {
case _RecentSpace():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecentSpace value)?  $default,){
final _that = this;
switch (_that) {
case _RecentSpace() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String root,  String name,  DateTime lastOpened)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecentSpace() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String root,  String name,  DateTime lastOpened)  $default,) {final _that = this;
switch (_that) {
case _RecentSpace():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String root,  String name,  DateTime lastOpened)?  $default,) {final _that = this;
switch (_that) {
case _RecentSpace() when $default != null:
return $default(_that.root,_that.name,_that.lastOpened);case _:
  return null;

}
}

}

/// @nodoc


class _RecentSpace implements RecentSpace {
  const _RecentSpace({required this.root, required this.name, required this.lastOpened});
  

/// The absolute path of the folder that was opened; its identity.
@override final  String root;
/// What it was called the last time it was open.
///
/// Stored rather than re-derived so the list reads the same as the app
/// did, even for a folder that is no longer there to ask.
@override final  String name;
/// When it was last opened, in UTC.
///
/// Only used to order the list. An instant rather than a position,
/// because two windows can open two spaces and neither should have to
/// renumber the other's.
@override final  DateTime lastOpened;

/// Create a copy of RecentSpace
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecentSpaceCopyWith<_RecentSpace> get copyWith => __$RecentSpaceCopyWithImpl<_RecentSpace>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecentSpace&&(identical(other.root, root) || other.root == root)&&(identical(other.name, name) || other.name == name)&&(identical(other.lastOpened, lastOpened) || other.lastOpened == lastOpened));
}


@override
int get hashCode => Object.hash(runtimeType,root,name,lastOpened);

@override
String toString() {
  return 'RecentSpace(root: $root, name: $name, lastOpened: $lastOpened)';
}


}

/// @nodoc
abstract mixin class _$RecentSpaceCopyWith<$Res> implements $RecentSpaceCopyWith<$Res> {
  factory _$RecentSpaceCopyWith(_RecentSpace value, $Res Function(_RecentSpace) _then) = __$RecentSpaceCopyWithImpl;
@override @useResult
$Res call({
 String root, String name, DateTime lastOpened
});




}
/// @nodoc
class __$RecentSpaceCopyWithImpl<$Res>
    implements _$RecentSpaceCopyWith<$Res> {
  __$RecentSpaceCopyWithImpl(this._self, this._then);

  final _RecentSpace _self;
  final $Res Function(_RecentSpace) _then;

/// Create a copy of RecentSpace
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? root = null,Object? name = null,Object? lastOpened = null,}) {
  return _then(_RecentSpace(
root: null == root ? _self.root : root // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,lastOpened: null == lastOpened ? _self.lastOpened : lastOpened // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
