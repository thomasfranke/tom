// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'status_entry_value_object.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$StatusEntryValueObject {

/// Where the file is, relative to the repository root.
 RepoRelativePathValueObject get path;/// What happened to it.
 FileStateEnum get state;/// Whether the change is in the index, ready to be committed.
 bool get isStaged;/// Where the file came from, when [state] is [FileStateEnum.renamed].
 RepoRelativePathValueObject? get previousPath;
/// Create a copy of StatusEntryValueObject
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StatusEntryValueObjectCopyWith<StatusEntryValueObject> get copyWith => _$StatusEntryValueObjectCopyWithImpl<StatusEntryValueObject>(this as StatusEntryValueObject, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StatusEntryValueObject&&(identical(other.path, path) || other.path == path)&&(identical(other.state, state) || other.state == state)&&(identical(other.isStaged, isStaged) || other.isStaged == isStaged)&&(identical(other.previousPath, previousPath) || other.previousPath == previousPath));
}


@override
int get hashCode => Object.hash(runtimeType,path,state,isStaged,previousPath);

@override
String toString() {
  return 'StatusEntryValueObject(path: $path, state: $state, isStaged: $isStaged, previousPath: $previousPath)';
}


}

/// @nodoc
abstract mixin class $StatusEntryValueObjectCopyWith<$Res>  {
  factory $StatusEntryValueObjectCopyWith(StatusEntryValueObject value, $Res Function(StatusEntryValueObject) _then) = _$StatusEntryValueObjectCopyWithImpl;
@useResult
$Res call({
 RepoRelativePathValueObject path, FileStateEnum state, bool isStaged, RepoRelativePathValueObject? previousPath
});




}
/// @nodoc
class _$StatusEntryValueObjectCopyWithImpl<$Res>
    implements $StatusEntryValueObjectCopyWith<$Res> {
  _$StatusEntryValueObjectCopyWithImpl(this._self, this._then);

  final StatusEntryValueObject _self;
  final $Res Function(StatusEntryValueObject) _then;

/// Create a copy of StatusEntryValueObject
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? path = null,Object? state = null,Object? isStaged = null,Object? previousPath = freezed,}) {
  return _then(_self.copyWith(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as RepoRelativePathValueObject,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as FileStateEnum,isStaged: null == isStaged ? _self.isStaged : isStaged // ignore: cast_nullable_to_non_nullable
as bool,previousPath: freezed == previousPath ? _self.previousPath : previousPath // ignore: cast_nullable_to_non_nullable
as RepoRelativePathValueObject?,
  ));
}

}


/// Adds pattern-matching-related methods to [StatusEntryValueObject].
extension StatusEntryValueObjectPatterns on StatusEntryValueObject {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StatusEntryValueObject value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StatusEntryValueObject() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StatusEntryValueObject value)  $default,){
final _that = this;
switch (_that) {
case _StatusEntryValueObject():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StatusEntryValueObject value)?  $default,){
final _that = this;
switch (_that) {
case _StatusEntryValueObject() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( RepoRelativePathValueObject path,  FileStateEnum state,  bool isStaged,  RepoRelativePathValueObject? previousPath)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StatusEntryValueObject() when $default != null:
return $default(_that.path,_that.state,_that.isStaged,_that.previousPath);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( RepoRelativePathValueObject path,  FileStateEnum state,  bool isStaged,  RepoRelativePathValueObject? previousPath)  $default,) {final _that = this;
switch (_that) {
case _StatusEntryValueObject():
return $default(_that.path,_that.state,_that.isStaged,_that.previousPath);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( RepoRelativePathValueObject path,  FileStateEnum state,  bool isStaged,  RepoRelativePathValueObject? previousPath)?  $default,) {final _that = this;
switch (_that) {
case _StatusEntryValueObject() when $default != null:
return $default(_that.path,_that.state,_that.isStaged,_that.previousPath);case _:
  return null;

}
}

}

/// @nodoc


class _StatusEntryValueObject implements StatusEntryValueObject {
  const _StatusEntryValueObject({required this.path, required this.state, required this.isStaged, this.previousPath});
  

/// Where the file is, relative to the repository root.
@override final  RepoRelativePathValueObject path;
/// What happened to it.
@override final  FileStateEnum state;
/// Whether the change is in the index, ready to be committed.
@override final  bool isStaged;
/// Where the file came from, when [state] is [FileStateEnum.renamed].
@override final  RepoRelativePathValueObject? previousPath;

/// Create a copy of StatusEntryValueObject
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StatusEntryValueObjectCopyWith<_StatusEntryValueObject> get copyWith => __$StatusEntryValueObjectCopyWithImpl<_StatusEntryValueObject>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StatusEntryValueObject&&(identical(other.path, path) || other.path == path)&&(identical(other.state, state) || other.state == state)&&(identical(other.isStaged, isStaged) || other.isStaged == isStaged)&&(identical(other.previousPath, previousPath) || other.previousPath == previousPath));
}


@override
int get hashCode => Object.hash(runtimeType,path,state,isStaged,previousPath);

@override
String toString() {
  return 'StatusEntryValueObject(path: $path, state: $state, isStaged: $isStaged, previousPath: $previousPath)';
}


}

/// @nodoc
abstract mixin class _$StatusEntryValueObjectCopyWith<$Res> implements $StatusEntryValueObjectCopyWith<$Res> {
  factory _$StatusEntryValueObjectCopyWith(_StatusEntryValueObject value, $Res Function(_StatusEntryValueObject) _then) = __$StatusEntryValueObjectCopyWithImpl;
@override @useResult
$Res call({
 RepoRelativePathValueObject path, FileStateEnum state, bool isStaged, RepoRelativePathValueObject? previousPath
});




}
/// @nodoc
class __$StatusEntryValueObjectCopyWithImpl<$Res>
    implements _$StatusEntryValueObjectCopyWith<$Res> {
  __$StatusEntryValueObjectCopyWithImpl(this._self, this._then);

  final _StatusEntryValueObject _self;
  final $Res Function(_StatusEntryValueObject) _then;

/// Create a copy of StatusEntryValueObject
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? path = null,Object? state = null,Object? isStaged = null,Object? previousPath = freezed,}) {
  return _then(_StatusEntryValueObject(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as RepoRelativePathValueObject,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as FileStateEnum,isStaged: null == isStaged ? _self.isStaged : isStaged // ignore: cast_nullable_to_non_nullable
as bool,previousPath: freezed == previousPath ? _self.previousPath : previousPath // ignore: cast_nullable_to_non_nullable
as RepoRelativePathValueObject?,
  ));
}


}

// dart format on
