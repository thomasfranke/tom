// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pull_request_target_value_object.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PullRequestTargetValueObject {

/// The recognised project, or null for no remote or an unknown host.
 RemoteProjectValueObject? get project;/// The remote's own branch, the base a proposal starts at.
 BranchNameValueObject? get defaultBranch;/// Whether the repository has a remote at all, which is what tells an
/// unknown host from no remote when [project] is null.
 bool get hasRemote;/// The branch checked out when this was read, or null when detached.
///
/// Read here rather than taken from the git column, which may be shut.
 BranchNameValueObject? get branch;/// Whether `HEAD` pointed at a commit rather than a branch.
 bool get isDetached;
/// Create a copy of PullRequestTargetValueObject
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PullRequestTargetValueObjectCopyWith<PullRequestTargetValueObject> get copyWith => _$PullRequestTargetValueObjectCopyWithImpl<PullRequestTargetValueObject>(this as PullRequestTargetValueObject, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PullRequestTargetValueObject&&(identical(other.project, project) || other.project == project)&&(identical(other.defaultBranch, defaultBranch) || other.defaultBranch == defaultBranch)&&(identical(other.hasRemote, hasRemote) || other.hasRemote == hasRemote)&&(identical(other.branch, branch) || other.branch == branch)&&(identical(other.isDetached, isDetached) || other.isDetached == isDetached));
}


@override
int get hashCode => Object.hash(runtimeType,project,defaultBranch,hasRemote,branch,isDetached);

@override
String toString() {
  return 'PullRequestTargetValueObject(project: $project, defaultBranch: $defaultBranch, hasRemote: $hasRemote, branch: $branch, isDetached: $isDetached)';
}


}

/// @nodoc
abstract mixin class $PullRequestTargetValueObjectCopyWith<$Res>  {
  factory $PullRequestTargetValueObjectCopyWith(PullRequestTargetValueObject value, $Res Function(PullRequestTargetValueObject) _then) = _$PullRequestTargetValueObjectCopyWithImpl;
@useResult
$Res call({
 RemoteProjectValueObject? project, BranchNameValueObject? defaultBranch, bool hasRemote, BranchNameValueObject? branch, bool isDetached
});


$RemoteProjectValueObjectCopyWith<$Res>? get project;

}
/// @nodoc
class _$PullRequestTargetValueObjectCopyWithImpl<$Res>
    implements $PullRequestTargetValueObjectCopyWith<$Res> {
  _$PullRequestTargetValueObjectCopyWithImpl(this._self, this._then);

  final PullRequestTargetValueObject _self;
  final $Res Function(PullRequestTargetValueObject) _then;

/// Create a copy of PullRequestTargetValueObject
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? project = freezed,Object? defaultBranch = freezed,Object? hasRemote = null,Object? branch = freezed,Object? isDetached = null,}) {
  return _then(_self.copyWith(
project: freezed == project ? _self.project : project // ignore: cast_nullable_to_non_nullable
as RemoteProjectValueObject?,defaultBranch: freezed == defaultBranch ? _self.defaultBranch : defaultBranch // ignore: cast_nullable_to_non_nullable
as BranchNameValueObject?,hasRemote: null == hasRemote ? _self.hasRemote : hasRemote // ignore: cast_nullable_to_non_nullable
as bool,branch: freezed == branch ? _self.branch : branch // ignore: cast_nullable_to_non_nullable
as BranchNameValueObject?,isDetached: null == isDetached ? _self.isDetached : isDetached // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of PullRequestTargetValueObject
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RemoteProjectValueObjectCopyWith<$Res>? get project {
    if (_self.project == null) {
    return null;
  }

  return $RemoteProjectValueObjectCopyWith<$Res>(_self.project!, (value) {
    return _then(_self.copyWith(project: value));
  });
}
}


/// Adds pattern-matching-related methods to [PullRequestTargetValueObject].
extension PullRequestTargetValueObjectPatterns on PullRequestTargetValueObject {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PullRequestTargetValueObject value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PullRequestTargetValueObject() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PullRequestTargetValueObject value)  $default,){
final _that = this;
switch (_that) {
case _PullRequestTargetValueObject():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PullRequestTargetValueObject value)?  $default,){
final _that = this;
switch (_that) {
case _PullRequestTargetValueObject() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( RemoteProjectValueObject? project,  BranchNameValueObject? defaultBranch,  bool hasRemote,  BranchNameValueObject? branch,  bool isDetached)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PullRequestTargetValueObject() when $default != null:
return $default(_that.project,_that.defaultBranch,_that.hasRemote,_that.branch,_that.isDetached);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( RemoteProjectValueObject? project,  BranchNameValueObject? defaultBranch,  bool hasRemote,  BranchNameValueObject? branch,  bool isDetached)  $default,) {final _that = this;
switch (_that) {
case _PullRequestTargetValueObject():
return $default(_that.project,_that.defaultBranch,_that.hasRemote,_that.branch,_that.isDetached);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( RemoteProjectValueObject? project,  BranchNameValueObject? defaultBranch,  bool hasRemote,  BranchNameValueObject? branch,  bool isDetached)?  $default,) {final _that = this;
switch (_that) {
case _PullRequestTargetValueObject() when $default != null:
return $default(_that.project,_that.defaultBranch,_that.hasRemote,_that.branch,_that.isDetached);case _:
  return null;

}
}

}

/// @nodoc


class _PullRequestTargetValueObject implements PullRequestTargetValueObject {
  const _PullRequestTargetValueObject({this.project, this.defaultBranch, this.hasRemote = false, this.branch, this.isDetached = false});
  

/// The recognised project, or null for no remote or an unknown host.
@override final  RemoteProjectValueObject? project;
/// The remote's own branch, the base a proposal starts at.
@override final  BranchNameValueObject? defaultBranch;
/// Whether the repository has a remote at all, which is what tells an
/// unknown host from no remote when [project] is null.
@override@JsonKey() final  bool hasRemote;
/// The branch checked out when this was read, or null when detached.
///
/// Read here rather than taken from the git column, which may be shut.
@override final  BranchNameValueObject? branch;
/// Whether `HEAD` pointed at a commit rather than a branch.
@override@JsonKey() final  bool isDetached;

/// Create a copy of PullRequestTargetValueObject
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PullRequestTargetValueObjectCopyWith<_PullRequestTargetValueObject> get copyWith => __$PullRequestTargetValueObjectCopyWithImpl<_PullRequestTargetValueObject>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PullRequestTargetValueObject&&(identical(other.project, project) || other.project == project)&&(identical(other.defaultBranch, defaultBranch) || other.defaultBranch == defaultBranch)&&(identical(other.hasRemote, hasRemote) || other.hasRemote == hasRemote)&&(identical(other.branch, branch) || other.branch == branch)&&(identical(other.isDetached, isDetached) || other.isDetached == isDetached));
}


@override
int get hashCode => Object.hash(runtimeType,project,defaultBranch,hasRemote,branch,isDetached);

@override
String toString() {
  return 'PullRequestTargetValueObject(project: $project, defaultBranch: $defaultBranch, hasRemote: $hasRemote, branch: $branch, isDetached: $isDetached)';
}


}

/// @nodoc
abstract mixin class _$PullRequestTargetValueObjectCopyWith<$Res> implements $PullRequestTargetValueObjectCopyWith<$Res> {
  factory _$PullRequestTargetValueObjectCopyWith(_PullRequestTargetValueObject value, $Res Function(_PullRequestTargetValueObject) _then) = __$PullRequestTargetValueObjectCopyWithImpl;
@override @useResult
$Res call({
 RemoteProjectValueObject? project, BranchNameValueObject? defaultBranch, bool hasRemote, BranchNameValueObject? branch, bool isDetached
});


@override $RemoteProjectValueObjectCopyWith<$Res>? get project;

}
/// @nodoc
class __$PullRequestTargetValueObjectCopyWithImpl<$Res>
    implements _$PullRequestTargetValueObjectCopyWith<$Res> {
  __$PullRequestTargetValueObjectCopyWithImpl(this._self, this._then);

  final _PullRequestTargetValueObject _self;
  final $Res Function(_PullRequestTargetValueObject) _then;

/// Create a copy of PullRequestTargetValueObject
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? project = freezed,Object? defaultBranch = freezed,Object? hasRemote = null,Object? branch = freezed,Object? isDetached = null,}) {
  return _then(_PullRequestTargetValueObject(
project: freezed == project ? _self.project : project // ignore: cast_nullable_to_non_nullable
as RemoteProjectValueObject?,defaultBranch: freezed == defaultBranch ? _self.defaultBranch : defaultBranch // ignore: cast_nullable_to_non_nullable
as BranchNameValueObject?,hasRemote: null == hasRemote ? _self.hasRemote : hasRemote // ignore: cast_nullable_to_non_nullable
as bool,branch: freezed == branch ? _self.branch : branch // ignore: cast_nullable_to_non_nullable
as BranchNameValueObject?,isDetached: null == isDetached ? _self.isDetached : isDetached // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of PullRequestTargetValueObject
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RemoteProjectValueObjectCopyWith<$Res>? get project {
    if (_self.project == null) {
    return null;
  }

  return $RemoteProjectValueObjectCopyWith<$Res>(_self.project!, (value) {
    return _then(_self.copyWith(project: value));
  });
}
}

// dart format on
