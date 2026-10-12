// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'branch_change_value_object.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BranchChangeValueObject {

/// Where the file is, relative to the repository root.
 RepoRelativePathValueObject get path;/// What happened to it.
 FileStateEnum get state;/// Lines the branch added, or null for a file git calls binary.
 int? get added;/// Lines the branch removed, or null for a file git calls binary.
 int? get removed;
/// Create a copy of BranchChangeValueObject
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BranchChangeValueObjectCopyWith<BranchChangeValueObject> get copyWith => _$BranchChangeValueObjectCopyWithImpl<BranchChangeValueObject>(this as BranchChangeValueObject, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BranchChangeValueObject&&(identical(other.path, path) || other.path == path)&&(identical(other.state, state) || other.state == state)&&(identical(other.added, added) || other.added == added)&&(identical(other.removed, removed) || other.removed == removed));
}


@override
int get hashCode => Object.hash(runtimeType,path,state,added,removed);

@override
String toString() {
  return 'BranchChangeValueObject(path: $path, state: $state, added: $added, removed: $removed)';
}


}

/// @nodoc
abstract mixin class $BranchChangeValueObjectCopyWith<$Res>  {
  factory $BranchChangeValueObjectCopyWith(BranchChangeValueObject value, $Res Function(BranchChangeValueObject) _then) = _$BranchChangeValueObjectCopyWithImpl;
@useResult
$Res call({
 RepoRelativePathValueObject path, FileStateEnum state, int? added, int? removed
});




}
/// @nodoc
class _$BranchChangeValueObjectCopyWithImpl<$Res>
    implements $BranchChangeValueObjectCopyWith<$Res> {
  _$BranchChangeValueObjectCopyWithImpl(this._self, this._then);

  final BranchChangeValueObject _self;
  final $Res Function(BranchChangeValueObject) _then;

/// Create a copy of BranchChangeValueObject
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? path = null,Object? state = null,Object? added = freezed,Object? removed = freezed,}) {
  return _then(_self.copyWith(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as RepoRelativePathValueObject,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as FileStateEnum,added: freezed == added ? _self.added : added // ignore: cast_nullable_to_non_nullable
as int?,removed: freezed == removed ? _self.removed : removed // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [BranchChangeValueObject].
extension BranchChangeValueObjectPatterns on BranchChangeValueObject {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BranchChangeValueObject value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BranchChangeValueObject() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BranchChangeValueObject value)  $default,){
final _that = this;
switch (_that) {
case _BranchChangeValueObject():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BranchChangeValueObject value)?  $default,){
final _that = this;
switch (_that) {
case _BranchChangeValueObject() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( RepoRelativePathValueObject path,  FileStateEnum state,  int? added,  int? removed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BranchChangeValueObject() when $default != null:
return $default(_that.path,_that.state,_that.added,_that.removed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( RepoRelativePathValueObject path,  FileStateEnum state,  int? added,  int? removed)  $default,) {final _that = this;
switch (_that) {
case _BranchChangeValueObject():
return $default(_that.path,_that.state,_that.added,_that.removed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( RepoRelativePathValueObject path,  FileStateEnum state,  int? added,  int? removed)?  $default,) {final _that = this;
switch (_that) {
case _BranchChangeValueObject() when $default != null:
return $default(_that.path,_that.state,_that.added,_that.removed);case _:
  return null;

}
}

}

/// @nodoc


class _BranchChangeValueObject implements BranchChangeValueObject {
  const _BranchChangeValueObject({required this.path, required this.state, this.added, this.removed});
  

/// Where the file is, relative to the repository root.
@override final  RepoRelativePathValueObject path;
/// What happened to it.
@override final  FileStateEnum state;
/// Lines the branch added, or null for a file git calls binary.
@override final  int? added;
/// Lines the branch removed, or null for a file git calls binary.
@override final  int? removed;

/// Create a copy of BranchChangeValueObject
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BranchChangeValueObjectCopyWith<_BranchChangeValueObject> get copyWith => __$BranchChangeValueObjectCopyWithImpl<_BranchChangeValueObject>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BranchChangeValueObject&&(identical(other.path, path) || other.path == path)&&(identical(other.state, state) || other.state == state)&&(identical(other.added, added) || other.added == added)&&(identical(other.removed, removed) || other.removed == removed));
}


@override
int get hashCode => Object.hash(runtimeType,path,state,added,removed);

@override
String toString() {
  return 'BranchChangeValueObject(path: $path, state: $state, added: $added, removed: $removed)';
}


}

/// @nodoc
abstract mixin class _$BranchChangeValueObjectCopyWith<$Res> implements $BranchChangeValueObjectCopyWith<$Res> {
  factory _$BranchChangeValueObjectCopyWith(_BranchChangeValueObject value, $Res Function(_BranchChangeValueObject) _then) = __$BranchChangeValueObjectCopyWithImpl;
@override @useResult
$Res call({
 RepoRelativePathValueObject path, FileStateEnum state, int? added, int? removed
});




}
/// @nodoc
class __$BranchChangeValueObjectCopyWithImpl<$Res>
    implements _$BranchChangeValueObjectCopyWith<$Res> {
  __$BranchChangeValueObjectCopyWithImpl(this._self, this._then);

  final _BranchChangeValueObject _self;
  final $Res Function(_BranchChangeValueObject) _then;

/// Create a copy of BranchChangeValueObject
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? path = null,Object? state = null,Object? added = freezed,Object? removed = freezed,}) {
  return _then(_BranchChangeValueObject(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as RepoRelativePathValueObject,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as FileStateEnum,added: freezed == added ? _self.added : added // ignore: cast_nullable_to_non_nullable
as int?,removed: freezed == removed ? _self.removed : removed // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
