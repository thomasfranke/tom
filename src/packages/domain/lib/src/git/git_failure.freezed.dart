// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'git_failure.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GitFailure {

 AppFailure? get cause;
/// Create a copy of GitFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GitFailureCopyWith<GitFailure> get copyWith => _$GitFailureCopyWithImpl<GitFailure>(this as GitFailure, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GitFailure&&(identical(other.cause, cause) || other.cause == cause));
}


@override
int get hashCode => Object.hash(runtimeType,cause);

@override
String toString() {
  return 'GitFailure(cause: $cause)';
}


}

/// @nodoc
abstract mixin class $GitFailureCopyWith<$Res>  {
  factory $GitFailureCopyWith(GitFailure value, $Res Function(GitFailure) _then) = _$GitFailureCopyWithImpl;
@useResult
$Res call({
 AppFailure? cause
});




}
/// @nodoc
class _$GitFailureCopyWithImpl<$Res>
    implements $GitFailureCopyWith<$Res> {
  _$GitFailureCopyWithImpl(this._self, this._then);

  final GitFailure _self;
  final $Res Function(GitFailure) _then;

/// Create a copy of GitFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? cause = freezed,}) {
  return _then(_self.copyWith(
cause: freezed == cause ? _self.cause : cause // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}

}


/// Adds pattern-matching-related methods to [GitFailure].
extension GitFailurePatterns on GitFailure {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( GitNotInstalled value)?  notInstalled,TResult Function( GitNotARepository value)?  notARepository,TResult Function( GitMergeConflict value)?  mergeConflict,TResult Function( GitAuthenticationFailed value)?  authenticationFailed,TResult Function( GitDetachedHead value)?  detachedHead,TResult Function( GitPushRejected value)?  pushRejected,TResult Function( GitTimedOut value)?  timedOut,TResult Function( GitPathNotInRevision value)?  pathNotInRevision,TResult Function( GitOperationFailed value)?  operationFailed,required TResult orElse(),}){
final _that = this;
switch (_that) {
case GitNotInstalled() when notInstalled != null:
return notInstalled(_that);case GitNotARepository() when notARepository != null:
return notARepository(_that);case GitMergeConflict() when mergeConflict != null:
return mergeConflict(_that);case GitAuthenticationFailed() when authenticationFailed != null:
return authenticationFailed(_that);case GitDetachedHead() when detachedHead != null:
return detachedHead(_that);case GitPushRejected() when pushRejected != null:
return pushRejected(_that);case GitTimedOut() when timedOut != null:
return timedOut(_that);case GitPathNotInRevision() when pathNotInRevision != null:
return pathNotInRevision(_that);case GitOperationFailed() when operationFailed != null:
return operationFailed(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( GitNotInstalled value)  notInstalled,required TResult Function( GitNotARepository value)  notARepository,required TResult Function( GitMergeConflict value)  mergeConflict,required TResult Function( GitAuthenticationFailed value)  authenticationFailed,required TResult Function( GitDetachedHead value)  detachedHead,required TResult Function( GitPushRejected value)  pushRejected,required TResult Function( GitTimedOut value)  timedOut,required TResult Function( GitPathNotInRevision value)  pathNotInRevision,required TResult Function( GitOperationFailed value)  operationFailed,}){
final _that = this;
switch (_that) {
case GitNotInstalled():
return notInstalled(_that);case GitNotARepository():
return notARepository(_that);case GitMergeConflict():
return mergeConflict(_that);case GitAuthenticationFailed():
return authenticationFailed(_that);case GitDetachedHead():
return detachedHead(_that);case GitPushRejected():
return pushRejected(_that);case GitTimedOut():
return timedOut(_that);case GitPathNotInRevision():
return pathNotInRevision(_that);case GitOperationFailed():
return operationFailed(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( GitNotInstalled value)?  notInstalled,TResult? Function( GitNotARepository value)?  notARepository,TResult? Function( GitMergeConflict value)?  mergeConflict,TResult? Function( GitAuthenticationFailed value)?  authenticationFailed,TResult? Function( GitDetachedHead value)?  detachedHead,TResult? Function( GitPushRejected value)?  pushRejected,TResult? Function( GitTimedOut value)?  timedOut,TResult? Function( GitPathNotInRevision value)?  pathNotInRevision,TResult? Function( GitOperationFailed value)?  operationFailed,}){
final _that = this;
switch (_that) {
case GitNotInstalled() when notInstalled != null:
return notInstalled(_that);case GitNotARepository() when notARepository != null:
return notARepository(_that);case GitMergeConflict() when mergeConflict != null:
return mergeConflict(_that);case GitAuthenticationFailed() when authenticationFailed != null:
return authenticationFailed(_that);case GitDetachedHead() when detachedHead != null:
return detachedHead(_that);case GitPushRejected() when pushRejected != null:
return pushRejected(_that);case GitTimedOut() when timedOut != null:
return timedOut(_that);case GitPathNotInRevision() when pathNotInRevision != null:
return pathNotInRevision(_that);case GitOperationFailed() when operationFailed != null:
return operationFailed(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( AppFailure? cause)?  notInstalled,TResult Function( String path,  AppFailure? cause)?  notARepository,TResult Function( List<String> conflictedFiles,  AppFailure? cause)?  mergeConflict,TResult Function( AppFailure? cause)?  authenticationFailed,TResult Function( AppFailure? cause)?  detachedHead,TResult Function( AppFailure? cause)?  pushRejected,TResult Function( AppFailure? cause)?  timedOut,TResult Function( String path,  AppFailure? cause)?  pathNotInRevision,TResult Function( AppFailure? cause)?  operationFailed,required TResult orElse(),}) {final _that = this;
switch (_that) {
case GitNotInstalled() when notInstalled != null:
return notInstalled(_that.cause);case GitNotARepository() when notARepository != null:
return notARepository(_that.path,_that.cause);case GitMergeConflict() when mergeConflict != null:
return mergeConflict(_that.conflictedFiles,_that.cause);case GitAuthenticationFailed() when authenticationFailed != null:
return authenticationFailed(_that.cause);case GitDetachedHead() when detachedHead != null:
return detachedHead(_that.cause);case GitPushRejected() when pushRejected != null:
return pushRejected(_that.cause);case GitTimedOut() when timedOut != null:
return timedOut(_that.cause);case GitPathNotInRevision() when pathNotInRevision != null:
return pathNotInRevision(_that.path,_that.cause);case GitOperationFailed() when operationFailed != null:
return operationFailed(_that.cause);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( AppFailure? cause)  notInstalled,required TResult Function( String path,  AppFailure? cause)  notARepository,required TResult Function( List<String> conflictedFiles,  AppFailure? cause)  mergeConflict,required TResult Function( AppFailure? cause)  authenticationFailed,required TResult Function( AppFailure? cause)  detachedHead,required TResult Function( AppFailure? cause)  pushRejected,required TResult Function( AppFailure? cause)  timedOut,required TResult Function( String path,  AppFailure? cause)  pathNotInRevision,required TResult Function( AppFailure? cause)  operationFailed,}) {final _that = this;
switch (_that) {
case GitNotInstalled():
return notInstalled(_that.cause);case GitNotARepository():
return notARepository(_that.path,_that.cause);case GitMergeConflict():
return mergeConflict(_that.conflictedFiles,_that.cause);case GitAuthenticationFailed():
return authenticationFailed(_that.cause);case GitDetachedHead():
return detachedHead(_that.cause);case GitPushRejected():
return pushRejected(_that.cause);case GitTimedOut():
return timedOut(_that.cause);case GitPathNotInRevision():
return pathNotInRevision(_that.path,_that.cause);case GitOperationFailed():
return operationFailed(_that.cause);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( AppFailure? cause)?  notInstalled,TResult? Function( String path,  AppFailure? cause)?  notARepository,TResult? Function( List<String> conflictedFiles,  AppFailure? cause)?  mergeConflict,TResult? Function( AppFailure? cause)?  authenticationFailed,TResult? Function( AppFailure? cause)?  detachedHead,TResult? Function( AppFailure? cause)?  pushRejected,TResult? Function( AppFailure? cause)?  timedOut,TResult? Function( String path,  AppFailure? cause)?  pathNotInRevision,TResult? Function( AppFailure? cause)?  operationFailed,}) {final _that = this;
switch (_that) {
case GitNotInstalled() when notInstalled != null:
return notInstalled(_that.cause);case GitNotARepository() when notARepository != null:
return notARepository(_that.path,_that.cause);case GitMergeConflict() when mergeConflict != null:
return mergeConflict(_that.conflictedFiles,_that.cause);case GitAuthenticationFailed() when authenticationFailed != null:
return authenticationFailed(_that.cause);case GitDetachedHead() when detachedHead != null:
return detachedHead(_that.cause);case GitPushRejected() when pushRejected != null:
return pushRejected(_that.cause);case GitTimedOut() when timedOut != null:
return timedOut(_that.cause);case GitPathNotInRevision() when pathNotInRevision != null:
return pathNotInRevision(_that.path,_that.cause);case GitOperationFailed() when operationFailed != null:
return operationFailed(_that.cause);case _:
  return null;

}
}

}

/// @nodoc


class GitNotInstalled implements GitFailure {
  const GitNotInstalled({this.cause});
  

@override final  AppFailure? cause;

/// Create a copy of GitFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GitNotInstalledCopyWith<GitNotInstalled> get copyWith => _$GitNotInstalledCopyWithImpl<GitNotInstalled>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GitNotInstalled&&(identical(other.cause, cause) || other.cause == cause));
}


@override
int get hashCode => Object.hash(runtimeType,cause);

@override
String toString() {
  return 'GitFailure.notInstalled(cause: $cause)';
}


}

/// @nodoc
abstract mixin class $GitNotInstalledCopyWith<$Res> implements $GitFailureCopyWith<$Res> {
  factory $GitNotInstalledCopyWith(GitNotInstalled value, $Res Function(GitNotInstalled) _then) = _$GitNotInstalledCopyWithImpl;
@override @useResult
$Res call({
 AppFailure? cause
});




}
/// @nodoc
class _$GitNotInstalledCopyWithImpl<$Res>
    implements $GitNotInstalledCopyWith<$Res> {
  _$GitNotInstalledCopyWithImpl(this._self, this._then);

  final GitNotInstalled _self;
  final $Res Function(GitNotInstalled) _then;

/// Create a copy of GitFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? cause = freezed,}) {
  return _then(GitNotInstalled(
cause: freezed == cause ? _self.cause : cause // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}


}

/// @nodoc


class GitNotARepository implements GitFailure {
  const GitNotARepository(this.path, {this.cause});
  

/// The absolute path that was searched for an enclosing repository.
 final  String path;
@override final  AppFailure? cause;

/// Create a copy of GitFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GitNotARepositoryCopyWith<GitNotARepository> get copyWith => _$GitNotARepositoryCopyWithImpl<GitNotARepository>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GitNotARepository&&(identical(other.path, path) || other.path == path)&&(identical(other.cause, cause) || other.cause == cause));
}


@override
int get hashCode => Object.hash(runtimeType,path,cause);

@override
String toString() {
  return 'GitFailure.notARepository(path: $path, cause: $cause)';
}


}

/// @nodoc
abstract mixin class $GitNotARepositoryCopyWith<$Res> implements $GitFailureCopyWith<$Res> {
  factory $GitNotARepositoryCopyWith(GitNotARepository value, $Res Function(GitNotARepository) _then) = _$GitNotARepositoryCopyWithImpl;
@override @useResult
$Res call({
 String path, AppFailure? cause
});




}
/// @nodoc
class _$GitNotARepositoryCopyWithImpl<$Res>
    implements $GitNotARepositoryCopyWith<$Res> {
  _$GitNotARepositoryCopyWithImpl(this._self, this._then);

  final GitNotARepository _self;
  final $Res Function(GitNotARepository) _then;

/// Create a copy of GitFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? path = null,Object? cause = freezed,}) {
  return _then(GitNotARepository(
null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,cause: freezed == cause ? _self.cause : cause // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}


}

/// @nodoc


class GitMergeConflict implements GitFailure {
  const GitMergeConflict(final  List<String> conflictedFiles, {this.cause}): _conflictedFiles = conflictedFiles;
  

/// Paths left conflicted, relative to the repository root.
///
/// Handed over, not copied (see `GitStatusValueObject.entries`).
 final  List<String> _conflictedFiles;
/// Paths left conflicted, relative to the repository root.
///
/// Handed over, not copied (see `GitStatusValueObject.entries`).
 List<String> get conflictedFiles {
  if (_conflictedFiles is EqualUnmodifiableListView) return _conflictedFiles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_conflictedFiles);
}

@override final  AppFailure? cause;

/// Create a copy of GitFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GitMergeConflictCopyWith<GitMergeConflict> get copyWith => _$GitMergeConflictCopyWithImpl<GitMergeConflict>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GitMergeConflict&&const DeepCollectionEquality().equals(other._conflictedFiles, _conflictedFiles)&&(identical(other.cause, cause) || other.cause == cause));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_conflictedFiles),cause);

@override
String toString() {
  return 'GitFailure.mergeConflict(conflictedFiles: $conflictedFiles, cause: $cause)';
}


}

/// @nodoc
abstract mixin class $GitMergeConflictCopyWith<$Res> implements $GitFailureCopyWith<$Res> {
  factory $GitMergeConflictCopyWith(GitMergeConflict value, $Res Function(GitMergeConflict) _then) = _$GitMergeConflictCopyWithImpl;
@override @useResult
$Res call({
 List<String> conflictedFiles, AppFailure? cause
});




}
/// @nodoc
class _$GitMergeConflictCopyWithImpl<$Res>
    implements $GitMergeConflictCopyWith<$Res> {
  _$GitMergeConflictCopyWithImpl(this._self, this._then);

  final GitMergeConflict _self;
  final $Res Function(GitMergeConflict) _then;

/// Create a copy of GitFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? conflictedFiles = null,Object? cause = freezed,}) {
  return _then(GitMergeConflict(
null == conflictedFiles ? _self._conflictedFiles : conflictedFiles // ignore: cast_nullable_to_non_nullable
as List<String>,cause: freezed == cause ? _self.cause : cause // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}


}

/// @nodoc


class GitAuthenticationFailed implements GitFailure {
  const GitAuthenticationFailed({this.cause});
  

@override final  AppFailure? cause;

/// Create a copy of GitFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GitAuthenticationFailedCopyWith<GitAuthenticationFailed> get copyWith => _$GitAuthenticationFailedCopyWithImpl<GitAuthenticationFailed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GitAuthenticationFailed&&(identical(other.cause, cause) || other.cause == cause));
}


@override
int get hashCode => Object.hash(runtimeType,cause);

@override
String toString() {
  return 'GitFailure.authenticationFailed(cause: $cause)';
}


}

/// @nodoc
abstract mixin class $GitAuthenticationFailedCopyWith<$Res> implements $GitFailureCopyWith<$Res> {
  factory $GitAuthenticationFailedCopyWith(GitAuthenticationFailed value, $Res Function(GitAuthenticationFailed) _then) = _$GitAuthenticationFailedCopyWithImpl;
@override @useResult
$Res call({
 AppFailure? cause
});




}
/// @nodoc
class _$GitAuthenticationFailedCopyWithImpl<$Res>
    implements $GitAuthenticationFailedCopyWith<$Res> {
  _$GitAuthenticationFailedCopyWithImpl(this._self, this._then);

  final GitAuthenticationFailed _self;
  final $Res Function(GitAuthenticationFailed) _then;

/// Create a copy of GitFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? cause = freezed,}) {
  return _then(GitAuthenticationFailed(
cause: freezed == cause ? _self.cause : cause // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}


}

/// @nodoc


class GitDetachedHead implements GitFailure {
  const GitDetachedHead({this.cause});
  

@override final  AppFailure? cause;

/// Create a copy of GitFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GitDetachedHeadCopyWith<GitDetachedHead> get copyWith => _$GitDetachedHeadCopyWithImpl<GitDetachedHead>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GitDetachedHead&&(identical(other.cause, cause) || other.cause == cause));
}


@override
int get hashCode => Object.hash(runtimeType,cause);

@override
String toString() {
  return 'GitFailure.detachedHead(cause: $cause)';
}


}

/// @nodoc
abstract mixin class $GitDetachedHeadCopyWith<$Res> implements $GitFailureCopyWith<$Res> {
  factory $GitDetachedHeadCopyWith(GitDetachedHead value, $Res Function(GitDetachedHead) _then) = _$GitDetachedHeadCopyWithImpl;
@override @useResult
$Res call({
 AppFailure? cause
});




}
/// @nodoc
class _$GitDetachedHeadCopyWithImpl<$Res>
    implements $GitDetachedHeadCopyWith<$Res> {
  _$GitDetachedHeadCopyWithImpl(this._self, this._then);

  final GitDetachedHead _self;
  final $Res Function(GitDetachedHead) _then;

/// Create a copy of GitFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? cause = freezed,}) {
  return _then(GitDetachedHead(
cause: freezed == cause ? _self.cause : cause // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}


}

/// @nodoc


class GitPushRejected implements GitFailure {
  const GitPushRejected({this.cause});
  

@override final  AppFailure? cause;

/// Create a copy of GitFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GitPushRejectedCopyWith<GitPushRejected> get copyWith => _$GitPushRejectedCopyWithImpl<GitPushRejected>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GitPushRejected&&(identical(other.cause, cause) || other.cause == cause));
}


@override
int get hashCode => Object.hash(runtimeType,cause);

@override
String toString() {
  return 'GitFailure.pushRejected(cause: $cause)';
}


}

/// @nodoc
abstract mixin class $GitPushRejectedCopyWith<$Res> implements $GitFailureCopyWith<$Res> {
  factory $GitPushRejectedCopyWith(GitPushRejected value, $Res Function(GitPushRejected) _then) = _$GitPushRejectedCopyWithImpl;
@override @useResult
$Res call({
 AppFailure? cause
});




}
/// @nodoc
class _$GitPushRejectedCopyWithImpl<$Res>
    implements $GitPushRejectedCopyWith<$Res> {
  _$GitPushRejectedCopyWithImpl(this._self, this._then);

  final GitPushRejected _self;
  final $Res Function(GitPushRejected) _then;

/// Create a copy of GitFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? cause = freezed,}) {
  return _then(GitPushRejected(
cause: freezed == cause ? _self.cause : cause // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}


}

/// @nodoc


class GitTimedOut implements GitFailure {
  const GitTimedOut({this.cause});
  

@override final  AppFailure? cause;

/// Create a copy of GitFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GitTimedOutCopyWith<GitTimedOut> get copyWith => _$GitTimedOutCopyWithImpl<GitTimedOut>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GitTimedOut&&(identical(other.cause, cause) || other.cause == cause));
}


@override
int get hashCode => Object.hash(runtimeType,cause);

@override
String toString() {
  return 'GitFailure.timedOut(cause: $cause)';
}


}

/// @nodoc
abstract mixin class $GitTimedOutCopyWith<$Res> implements $GitFailureCopyWith<$Res> {
  factory $GitTimedOutCopyWith(GitTimedOut value, $Res Function(GitTimedOut) _then) = _$GitTimedOutCopyWithImpl;
@override @useResult
$Res call({
 AppFailure? cause
});




}
/// @nodoc
class _$GitTimedOutCopyWithImpl<$Res>
    implements $GitTimedOutCopyWith<$Res> {
  _$GitTimedOutCopyWithImpl(this._self, this._then);

  final GitTimedOut _self;
  final $Res Function(GitTimedOut) _then;

/// Create a copy of GitFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? cause = freezed,}) {
  return _then(GitTimedOut(
cause: freezed == cause ? _self.cause : cause // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}


}

/// @nodoc


class GitPathNotInRevision implements GitFailure {
  const GitPathNotInRevision(this.path, {this.cause});
  

/// The path, as the user's repository spells it.
 final  String path;
@override final  AppFailure? cause;

/// Create a copy of GitFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GitPathNotInRevisionCopyWith<GitPathNotInRevision> get copyWith => _$GitPathNotInRevisionCopyWithImpl<GitPathNotInRevision>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GitPathNotInRevision&&(identical(other.path, path) || other.path == path)&&(identical(other.cause, cause) || other.cause == cause));
}


@override
int get hashCode => Object.hash(runtimeType,path,cause);

@override
String toString() {
  return 'GitFailure.pathNotInRevision(path: $path, cause: $cause)';
}


}

/// @nodoc
abstract mixin class $GitPathNotInRevisionCopyWith<$Res> implements $GitFailureCopyWith<$Res> {
  factory $GitPathNotInRevisionCopyWith(GitPathNotInRevision value, $Res Function(GitPathNotInRevision) _then) = _$GitPathNotInRevisionCopyWithImpl;
@override @useResult
$Res call({
 String path, AppFailure? cause
});




}
/// @nodoc
class _$GitPathNotInRevisionCopyWithImpl<$Res>
    implements $GitPathNotInRevisionCopyWith<$Res> {
  _$GitPathNotInRevisionCopyWithImpl(this._self, this._then);

  final GitPathNotInRevision _self;
  final $Res Function(GitPathNotInRevision) _then;

/// Create a copy of GitFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? path = null,Object? cause = freezed,}) {
  return _then(GitPathNotInRevision(
null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,cause: freezed == cause ? _self.cause : cause // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}


}

/// @nodoc


class GitOperationFailed implements GitFailure {
  const GitOperationFailed({this.cause});
  

@override final  AppFailure? cause;

/// Create a copy of GitFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GitOperationFailedCopyWith<GitOperationFailed> get copyWith => _$GitOperationFailedCopyWithImpl<GitOperationFailed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GitOperationFailed&&(identical(other.cause, cause) || other.cause == cause));
}


@override
int get hashCode => Object.hash(runtimeType,cause);

@override
String toString() {
  return 'GitFailure.operationFailed(cause: $cause)';
}


}

/// @nodoc
abstract mixin class $GitOperationFailedCopyWith<$Res> implements $GitFailureCopyWith<$Res> {
  factory $GitOperationFailedCopyWith(GitOperationFailed value, $Res Function(GitOperationFailed) _then) = _$GitOperationFailedCopyWithImpl;
@override @useResult
$Res call({
 AppFailure? cause
});




}
/// @nodoc
class _$GitOperationFailedCopyWithImpl<$Res>
    implements $GitOperationFailedCopyWith<$Res> {
  _$GitOperationFailedCopyWithImpl(this._self, this._then);

  final GitOperationFailed _self;
  final $Res Function(GitOperationFailed) _then;

/// Create a copy of GitFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? cause = freezed,}) {
  return _then(GitOperationFailed(
cause: freezed == cause ? _self.cause : cause // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}


}

// dart format on
