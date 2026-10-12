// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'git_client_failure.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GitClientFailure {

 AppFailure? get cause;
/// Create a copy of GitClientFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GitClientFailureCopyWith<GitClientFailure> get copyWith => _$GitClientFailureCopyWithImpl<GitClientFailure>(this as GitClientFailure, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GitClientFailure&&(identical(other.cause, cause) || other.cause == cause));
}


@override
int get hashCode => Object.hash(runtimeType,cause);

@override
String toString() {
  return 'GitClientFailure(cause: $cause)';
}


}

/// @nodoc
abstract mixin class $GitClientFailureCopyWith<$Res>  {
  factory $GitClientFailureCopyWith(GitClientFailure value, $Res Function(GitClientFailure) _then) = _$GitClientFailureCopyWithImpl;
@useResult
$Res call({
 AppFailure? cause
});




}
/// @nodoc
class _$GitClientFailureCopyWithImpl<$Res>
    implements $GitClientFailureCopyWith<$Res> {
  _$GitClientFailureCopyWithImpl(this._self, this._then);

  final GitClientFailure _self;
  final $Res Function(GitClientFailure) _then;

/// Create a copy of GitClientFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? cause = freezed,}) {
  return _then(_self.copyWith(
cause: freezed == cause ? _self.cause : cause // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}

}


/// Adds pattern-matching-related methods to [GitClientFailure].
extension GitClientFailurePatterns on GitClientFailure {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( GitClientExecutableNotFound value)?  executableNotFound,TResult Function( GitClientNotARepository value)?  notARepository,TResult Function( GitClientMergeConflict value)?  mergeConflict,TResult Function( GitClientAuthenticationFailed value)?  authenticationFailed,TResult Function( GitClientNetworkUnavailable value)?  networkUnavailable,TResult Function( GitClientNoRemote value)?  noRemote,TResult Function( GitClientRemoteNotFound value)?  remoteNotFound,TResult Function( GitClientDestinationTaken value)?  destinationTaken,TResult Function( GitClientPushRejected value)?  pushRejected,TResult Function( GitClientBranchProtected value)?  branchProtected,TResult Function( GitClientLocalChangesOverwritten value)?  localChangesOverwritten,TResult Function( GitClientTimedOut value)?  timedOut,TResult Function( GitClientPathNotInRevision value)?  pathNotInRevision,TResult Function( GitClientPathCommitted value)?  pathCommitted,TResult Function( GitClientCommandDenied value)?  commandDenied,TResult Function( GitClientCommandFailed value)?  commandFailed,required TResult orElse(),}){
final _that = this;
switch (_that) {
case GitClientExecutableNotFound() when executableNotFound != null:
return executableNotFound(_that);case GitClientNotARepository() when notARepository != null:
return notARepository(_that);case GitClientMergeConflict() when mergeConflict != null:
return mergeConflict(_that);case GitClientAuthenticationFailed() when authenticationFailed != null:
return authenticationFailed(_that);case GitClientNetworkUnavailable() when networkUnavailable != null:
return networkUnavailable(_that);case GitClientNoRemote() when noRemote != null:
return noRemote(_that);case GitClientRemoteNotFound() when remoteNotFound != null:
return remoteNotFound(_that);case GitClientDestinationTaken() when destinationTaken != null:
return destinationTaken(_that);case GitClientPushRejected() when pushRejected != null:
return pushRejected(_that);case GitClientBranchProtected() when branchProtected != null:
return branchProtected(_that);case GitClientLocalChangesOverwritten() when localChangesOverwritten != null:
return localChangesOverwritten(_that);case GitClientTimedOut() when timedOut != null:
return timedOut(_that);case GitClientPathNotInRevision() when pathNotInRevision != null:
return pathNotInRevision(_that);case GitClientPathCommitted() when pathCommitted != null:
return pathCommitted(_that);case GitClientCommandDenied() when commandDenied != null:
return commandDenied(_that);case GitClientCommandFailed() when commandFailed != null:
return commandFailed(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( GitClientExecutableNotFound value)  executableNotFound,required TResult Function( GitClientNotARepository value)  notARepository,required TResult Function( GitClientMergeConflict value)  mergeConflict,required TResult Function( GitClientAuthenticationFailed value)  authenticationFailed,required TResult Function( GitClientNetworkUnavailable value)  networkUnavailable,required TResult Function( GitClientNoRemote value)  noRemote,required TResult Function( GitClientRemoteNotFound value)  remoteNotFound,required TResult Function( GitClientDestinationTaken value)  destinationTaken,required TResult Function( GitClientPushRejected value)  pushRejected,required TResult Function( GitClientBranchProtected value)  branchProtected,required TResult Function( GitClientLocalChangesOverwritten value)  localChangesOverwritten,required TResult Function( GitClientTimedOut value)  timedOut,required TResult Function( GitClientPathNotInRevision value)  pathNotInRevision,required TResult Function( GitClientPathCommitted value)  pathCommitted,required TResult Function( GitClientCommandDenied value)  commandDenied,required TResult Function( GitClientCommandFailed value)  commandFailed,}){
final _that = this;
switch (_that) {
case GitClientExecutableNotFound():
return executableNotFound(_that);case GitClientNotARepository():
return notARepository(_that);case GitClientMergeConflict():
return mergeConflict(_that);case GitClientAuthenticationFailed():
return authenticationFailed(_that);case GitClientNetworkUnavailable():
return networkUnavailable(_that);case GitClientNoRemote():
return noRemote(_that);case GitClientRemoteNotFound():
return remoteNotFound(_that);case GitClientDestinationTaken():
return destinationTaken(_that);case GitClientPushRejected():
return pushRejected(_that);case GitClientBranchProtected():
return branchProtected(_that);case GitClientLocalChangesOverwritten():
return localChangesOverwritten(_that);case GitClientTimedOut():
return timedOut(_that);case GitClientPathNotInRevision():
return pathNotInRevision(_that);case GitClientPathCommitted():
return pathCommitted(_that);case GitClientCommandDenied():
return commandDenied(_that);case GitClientCommandFailed():
return commandFailed(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( GitClientExecutableNotFound value)?  executableNotFound,TResult? Function( GitClientNotARepository value)?  notARepository,TResult? Function( GitClientMergeConflict value)?  mergeConflict,TResult? Function( GitClientAuthenticationFailed value)?  authenticationFailed,TResult? Function( GitClientNetworkUnavailable value)?  networkUnavailable,TResult? Function( GitClientNoRemote value)?  noRemote,TResult? Function( GitClientRemoteNotFound value)?  remoteNotFound,TResult? Function( GitClientDestinationTaken value)?  destinationTaken,TResult? Function( GitClientPushRejected value)?  pushRejected,TResult? Function( GitClientBranchProtected value)?  branchProtected,TResult? Function( GitClientLocalChangesOverwritten value)?  localChangesOverwritten,TResult? Function( GitClientTimedOut value)?  timedOut,TResult? Function( GitClientPathNotInRevision value)?  pathNotInRevision,TResult? Function( GitClientPathCommitted value)?  pathCommitted,TResult? Function( GitClientCommandDenied value)?  commandDenied,TResult? Function( GitClientCommandFailed value)?  commandFailed,}){
final _that = this;
switch (_that) {
case GitClientExecutableNotFound() when executableNotFound != null:
return executableNotFound(_that);case GitClientNotARepository() when notARepository != null:
return notARepository(_that);case GitClientMergeConflict() when mergeConflict != null:
return mergeConflict(_that);case GitClientAuthenticationFailed() when authenticationFailed != null:
return authenticationFailed(_that);case GitClientNetworkUnavailable() when networkUnavailable != null:
return networkUnavailable(_that);case GitClientNoRemote() when noRemote != null:
return noRemote(_that);case GitClientRemoteNotFound() when remoteNotFound != null:
return remoteNotFound(_that);case GitClientDestinationTaken() when destinationTaken != null:
return destinationTaken(_that);case GitClientPushRejected() when pushRejected != null:
return pushRejected(_that);case GitClientBranchProtected() when branchProtected != null:
return branchProtected(_that);case GitClientLocalChangesOverwritten() when localChangesOverwritten != null:
return localChangesOverwritten(_that);case GitClientTimedOut() when timedOut != null:
return timedOut(_that);case GitClientPathNotInRevision() when pathNotInRevision != null:
return pathNotInRevision(_that);case GitClientPathCommitted() when pathCommitted != null:
return pathCommitted(_that);case GitClientCommandDenied() when commandDenied != null:
return commandDenied(_that);case GitClientCommandFailed() when commandFailed != null:
return commandFailed(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( AppFailure? cause)?  executableNotFound,TResult Function( String path,  AppFailure? cause)?  notARepository,TResult Function( List<String> conflictedPaths,  AppFailure? cause)?  mergeConflict,TResult Function( String stderr,  AppFailure? cause)?  authenticationFailed,TResult Function( String stderr,  AppFailure? cause)?  networkUnavailable,TResult Function( String stderr,  AppFailure? cause)?  noRemote,TResult Function( String stderr,  AppFailure? cause)?  remoteNotFound,TResult Function( String path,  AppFailure? cause)?  destinationTaken,TResult Function( String stderr,  AppFailure? cause)?  pushRejected,TResult Function( String stderr,  AppFailure? cause)?  branchProtected,TResult Function( List<String> paths,  AppFailure? cause)?  localChangesOverwritten,TResult Function( String command,  Duration timeout,  AppFailure? cause)?  timedOut,TResult Function( String revision,  String path,  AppFailure? cause)?  pathNotInRevision,TResult Function( List<String> paths,  AppFailure? cause)?  pathCommitted,TResult Function( String command,  AppFailure? cause)?  commandDenied,TResult Function( String command,  int exitCode,  String stderr,  AppFailure? cause)?  commandFailed,required TResult orElse(),}) {final _that = this;
switch (_that) {
case GitClientExecutableNotFound() when executableNotFound != null:
return executableNotFound(_that.cause);case GitClientNotARepository() when notARepository != null:
return notARepository(_that.path,_that.cause);case GitClientMergeConflict() when mergeConflict != null:
return mergeConflict(_that.conflictedPaths,_that.cause);case GitClientAuthenticationFailed() when authenticationFailed != null:
return authenticationFailed(_that.stderr,_that.cause);case GitClientNetworkUnavailable() when networkUnavailable != null:
return networkUnavailable(_that.stderr,_that.cause);case GitClientNoRemote() when noRemote != null:
return noRemote(_that.stderr,_that.cause);case GitClientRemoteNotFound() when remoteNotFound != null:
return remoteNotFound(_that.stderr,_that.cause);case GitClientDestinationTaken() when destinationTaken != null:
return destinationTaken(_that.path,_that.cause);case GitClientPushRejected() when pushRejected != null:
return pushRejected(_that.stderr,_that.cause);case GitClientBranchProtected() when branchProtected != null:
return branchProtected(_that.stderr,_that.cause);case GitClientLocalChangesOverwritten() when localChangesOverwritten != null:
return localChangesOverwritten(_that.paths,_that.cause);case GitClientTimedOut() when timedOut != null:
return timedOut(_that.command,_that.timeout,_that.cause);case GitClientPathNotInRevision() when pathNotInRevision != null:
return pathNotInRevision(_that.revision,_that.path,_that.cause);case GitClientPathCommitted() when pathCommitted != null:
return pathCommitted(_that.paths,_that.cause);case GitClientCommandDenied() when commandDenied != null:
return commandDenied(_that.command,_that.cause);case GitClientCommandFailed() when commandFailed != null:
return commandFailed(_that.command,_that.exitCode,_that.stderr,_that.cause);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( AppFailure? cause)  executableNotFound,required TResult Function( String path,  AppFailure? cause)  notARepository,required TResult Function( List<String> conflictedPaths,  AppFailure? cause)  mergeConflict,required TResult Function( String stderr,  AppFailure? cause)  authenticationFailed,required TResult Function( String stderr,  AppFailure? cause)  networkUnavailable,required TResult Function( String stderr,  AppFailure? cause)  noRemote,required TResult Function( String stderr,  AppFailure? cause)  remoteNotFound,required TResult Function( String path,  AppFailure? cause)  destinationTaken,required TResult Function( String stderr,  AppFailure? cause)  pushRejected,required TResult Function( String stderr,  AppFailure? cause)  branchProtected,required TResult Function( List<String> paths,  AppFailure? cause)  localChangesOverwritten,required TResult Function( String command,  Duration timeout,  AppFailure? cause)  timedOut,required TResult Function( String revision,  String path,  AppFailure? cause)  pathNotInRevision,required TResult Function( List<String> paths,  AppFailure? cause)  pathCommitted,required TResult Function( String command,  AppFailure? cause)  commandDenied,required TResult Function( String command,  int exitCode,  String stderr,  AppFailure? cause)  commandFailed,}) {final _that = this;
switch (_that) {
case GitClientExecutableNotFound():
return executableNotFound(_that.cause);case GitClientNotARepository():
return notARepository(_that.path,_that.cause);case GitClientMergeConflict():
return mergeConflict(_that.conflictedPaths,_that.cause);case GitClientAuthenticationFailed():
return authenticationFailed(_that.stderr,_that.cause);case GitClientNetworkUnavailable():
return networkUnavailable(_that.stderr,_that.cause);case GitClientNoRemote():
return noRemote(_that.stderr,_that.cause);case GitClientRemoteNotFound():
return remoteNotFound(_that.stderr,_that.cause);case GitClientDestinationTaken():
return destinationTaken(_that.path,_that.cause);case GitClientPushRejected():
return pushRejected(_that.stderr,_that.cause);case GitClientBranchProtected():
return branchProtected(_that.stderr,_that.cause);case GitClientLocalChangesOverwritten():
return localChangesOverwritten(_that.paths,_that.cause);case GitClientTimedOut():
return timedOut(_that.command,_that.timeout,_that.cause);case GitClientPathNotInRevision():
return pathNotInRevision(_that.revision,_that.path,_that.cause);case GitClientPathCommitted():
return pathCommitted(_that.paths,_that.cause);case GitClientCommandDenied():
return commandDenied(_that.command,_that.cause);case GitClientCommandFailed():
return commandFailed(_that.command,_that.exitCode,_that.stderr,_that.cause);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( AppFailure? cause)?  executableNotFound,TResult? Function( String path,  AppFailure? cause)?  notARepository,TResult? Function( List<String> conflictedPaths,  AppFailure? cause)?  mergeConflict,TResult? Function( String stderr,  AppFailure? cause)?  authenticationFailed,TResult? Function( String stderr,  AppFailure? cause)?  networkUnavailable,TResult? Function( String stderr,  AppFailure? cause)?  noRemote,TResult? Function( String stderr,  AppFailure? cause)?  remoteNotFound,TResult? Function( String path,  AppFailure? cause)?  destinationTaken,TResult? Function( String stderr,  AppFailure? cause)?  pushRejected,TResult? Function( String stderr,  AppFailure? cause)?  branchProtected,TResult? Function( List<String> paths,  AppFailure? cause)?  localChangesOverwritten,TResult? Function( String command,  Duration timeout,  AppFailure? cause)?  timedOut,TResult? Function( String revision,  String path,  AppFailure? cause)?  pathNotInRevision,TResult? Function( List<String> paths,  AppFailure? cause)?  pathCommitted,TResult? Function( String command,  AppFailure? cause)?  commandDenied,TResult? Function( String command,  int exitCode,  String stderr,  AppFailure? cause)?  commandFailed,}) {final _that = this;
switch (_that) {
case GitClientExecutableNotFound() when executableNotFound != null:
return executableNotFound(_that.cause);case GitClientNotARepository() when notARepository != null:
return notARepository(_that.path,_that.cause);case GitClientMergeConflict() when mergeConflict != null:
return mergeConflict(_that.conflictedPaths,_that.cause);case GitClientAuthenticationFailed() when authenticationFailed != null:
return authenticationFailed(_that.stderr,_that.cause);case GitClientNetworkUnavailable() when networkUnavailable != null:
return networkUnavailable(_that.stderr,_that.cause);case GitClientNoRemote() when noRemote != null:
return noRemote(_that.stderr,_that.cause);case GitClientRemoteNotFound() when remoteNotFound != null:
return remoteNotFound(_that.stderr,_that.cause);case GitClientDestinationTaken() when destinationTaken != null:
return destinationTaken(_that.path,_that.cause);case GitClientPushRejected() when pushRejected != null:
return pushRejected(_that.stderr,_that.cause);case GitClientBranchProtected() when branchProtected != null:
return branchProtected(_that.stderr,_that.cause);case GitClientLocalChangesOverwritten() when localChangesOverwritten != null:
return localChangesOverwritten(_that.paths,_that.cause);case GitClientTimedOut() when timedOut != null:
return timedOut(_that.command,_that.timeout,_that.cause);case GitClientPathNotInRevision() when pathNotInRevision != null:
return pathNotInRevision(_that.revision,_that.path,_that.cause);case GitClientPathCommitted() when pathCommitted != null:
return pathCommitted(_that.paths,_that.cause);case GitClientCommandDenied() when commandDenied != null:
return commandDenied(_that.command,_that.cause);case GitClientCommandFailed() when commandFailed != null:
return commandFailed(_that.command,_that.exitCode,_that.stderr,_that.cause);case _:
  return null;

}
}

}

/// @nodoc


class GitClientExecutableNotFound implements GitClientFailure {
  const GitClientExecutableNotFound({this.cause});
  

@override final  AppFailure? cause;

/// Create a copy of GitClientFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GitClientExecutableNotFoundCopyWith<GitClientExecutableNotFound> get copyWith => _$GitClientExecutableNotFoundCopyWithImpl<GitClientExecutableNotFound>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GitClientExecutableNotFound&&(identical(other.cause, cause) || other.cause == cause));
}


@override
int get hashCode => Object.hash(runtimeType,cause);

@override
String toString() {
  return 'GitClientFailure.executableNotFound(cause: $cause)';
}


}

/// @nodoc
abstract mixin class $GitClientExecutableNotFoundCopyWith<$Res> implements $GitClientFailureCopyWith<$Res> {
  factory $GitClientExecutableNotFoundCopyWith(GitClientExecutableNotFound value, $Res Function(GitClientExecutableNotFound) _then) = _$GitClientExecutableNotFoundCopyWithImpl;
@override @useResult
$Res call({
 AppFailure? cause
});




}
/// @nodoc
class _$GitClientExecutableNotFoundCopyWithImpl<$Res>
    implements $GitClientExecutableNotFoundCopyWith<$Res> {
  _$GitClientExecutableNotFoundCopyWithImpl(this._self, this._then);

  final GitClientExecutableNotFound _self;
  final $Res Function(GitClientExecutableNotFound) _then;

/// Create a copy of GitClientFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? cause = freezed,}) {
  return _then(GitClientExecutableNotFound(
cause: freezed == cause ? _self.cause : cause // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}


}

/// @nodoc


class GitClientNotARepository implements GitClientFailure {
  const GitClientNotARepository(this.path, {this.cause});
  

/// The absolute path that was searched for an enclosing repository.
 final  String path;
@override final  AppFailure? cause;

/// Create a copy of GitClientFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GitClientNotARepositoryCopyWith<GitClientNotARepository> get copyWith => _$GitClientNotARepositoryCopyWithImpl<GitClientNotARepository>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GitClientNotARepository&&(identical(other.path, path) || other.path == path)&&(identical(other.cause, cause) || other.cause == cause));
}


@override
int get hashCode => Object.hash(runtimeType,path,cause);

@override
String toString() {
  return 'GitClientFailure.notARepository(path: $path, cause: $cause)';
}


}

/// @nodoc
abstract mixin class $GitClientNotARepositoryCopyWith<$Res> implements $GitClientFailureCopyWith<$Res> {
  factory $GitClientNotARepositoryCopyWith(GitClientNotARepository value, $Res Function(GitClientNotARepository) _then) = _$GitClientNotARepositoryCopyWithImpl;
@override @useResult
$Res call({
 String path, AppFailure? cause
});




}
/// @nodoc
class _$GitClientNotARepositoryCopyWithImpl<$Res>
    implements $GitClientNotARepositoryCopyWith<$Res> {
  _$GitClientNotARepositoryCopyWithImpl(this._self, this._then);

  final GitClientNotARepository _self;
  final $Res Function(GitClientNotARepository) _then;

/// Create a copy of GitClientFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? path = null,Object? cause = freezed,}) {
  return _then(GitClientNotARepository(
null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,cause: freezed == cause ? _self.cause : cause // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}


}

/// @nodoc


class GitClientMergeConflict implements GitClientFailure {
  const GitClientMergeConflict(final  List<String> conflictedPaths, {this.cause}): _conflictedPaths = conflictedPaths;
  

/// Paths left conflicted, relative to the repository root.
 final  List<String> _conflictedPaths;
/// Paths left conflicted, relative to the repository root.
 List<String> get conflictedPaths {
  if (_conflictedPaths is EqualUnmodifiableListView) return _conflictedPaths;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_conflictedPaths);
}

@override final  AppFailure? cause;

/// Create a copy of GitClientFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GitClientMergeConflictCopyWith<GitClientMergeConflict> get copyWith => _$GitClientMergeConflictCopyWithImpl<GitClientMergeConflict>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GitClientMergeConflict&&const DeepCollectionEquality().equals(other._conflictedPaths, _conflictedPaths)&&(identical(other.cause, cause) || other.cause == cause));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_conflictedPaths),cause);

@override
String toString() {
  return 'GitClientFailure.mergeConflict(conflictedPaths: $conflictedPaths, cause: $cause)';
}


}

/// @nodoc
abstract mixin class $GitClientMergeConflictCopyWith<$Res> implements $GitClientFailureCopyWith<$Res> {
  factory $GitClientMergeConflictCopyWith(GitClientMergeConflict value, $Res Function(GitClientMergeConflict) _then) = _$GitClientMergeConflictCopyWithImpl;
@override @useResult
$Res call({
 List<String> conflictedPaths, AppFailure? cause
});




}
/// @nodoc
class _$GitClientMergeConflictCopyWithImpl<$Res>
    implements $GitClientMergeConflictCopyWith<$Res> {
  _$GitClientMergeConflictCopyWithImpl(this._self, this._then);

  final GitClientMergeConflict _self;
  final $Res Function(GitClientMergeConflict) _then;

/// Create a copy of GitClientFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? conflictedPaths = null,Object? cause = freezed,}) {
  return _then(GitClientMergeConflict(
null == conflictedPaths ? _self._conflictedPaths : conflictedPaths // ignore: cast_nullable_to_non_nullable
as List<String>,cause: freezed == cause ? _self.cause : cause // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}


}

/// @nodoc


class GitClientAuthenticationFailed implements GitClientFailure {
  const GitClientAuthenticationFailed(this.stderr, {this.cause});
  

/// What git wrote to stderr, verbatim. For diagnostics — never parsed.
 final  String stderr;
@override final  AppFailure? cause;

/// Create a copy of GitClientFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GitClientAuthenticationFailedCopyWith<GitClientAuthenticationFailed> get copyWith => _$GitClientAuthenticationFailedCopyWithImpl<GitClientAuthenticationFailed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GitClientAuthenticationFailed&&(identical(other.stderr, stderr) || other.stderr == stderr)&&(identical(other.cause, cause) || other.cause == cause));
}


@override
int get hashCode => Object.hash(runtimeType,stderr,cause);

@override
String toString() {
  return 'GitClientFailure.authenticationFailed(stderr: $stderr, cause: $cause)';
}


}

/// @nodoc
abstract mixin class $GitClientAuthenticationFailedCopyWith<$Res> implements $GitClientFailureCopyWith<$Res> {
  factory $GitClientAuthenticationFailedCopyWith(GitClientAuthenticationFailed value, $Res Function(GitClientAuthenticationFailed) _then) = _$GitClientAuthenticationFailedCopyWithImpl;
@override @useResult
$Res call({
 String stderr, AppFailure? cause
});




}
/// @nodoc
class _$GitClientAuthenticationFailedCopyWithImpl<$Res>
    implements $GitClientAuthenticationFailedCopyWith<$Res> {
  _$GitClientAuthenticationFailedCopyWithImpl(this._self, this._then);

  final GitClientAuthenticationFailed _self;
  final $Res Function(GitClientAuthenticationFailed) _then;

/// Create a copy of GitClientFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? stderr = null,Object? cause = freezed,}) {
  return _then(GitClientAuthenticationFailed(
null == stderr ? _self.stderr : stderr // ignore: cast_nullable_to_non_nullable
as String,cause: freezed == cause ? _self.cause : cause // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}


}

/// @nodoc


class GitClientNetworkUnavailable implements GitClientFailure {
  const GitClientNetworkUnavailable(this.stderr, {this.cause});
  

/// What git wrote to stderr, verbatim. For diagnostics — never parsed.
 final  String stderr;
@override final  AppFailure? cause;

/// Create a copy of GitClientFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GitClientNetworkUnavailableCopyWith<GitClientNetworkUnavailable> get copyWith => _$GitClientNetworkUnavailableCopyWithImpl<GitClientNetworkUnavailable>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GitClientNetworkUnavailable&&(identical(other.stderr, stderr) || other.stderr == stderr)&&(identical(other.cause, cause) || other.cause == cause));
}


@override
int get hashCode => Object.hash(runtimeType,stderr,cause);

@override
String toString() {
  return 'GitClientFailure.networkUnavailable(stderr: $stderr, cause: $cause)';
}


}

/// @nodoc
abstract mixin class $GitClientNetworkUnavailableCopyWith<$Res> implements $GitClientFailureCopyWith<$Res> {
  factory $GitClientNetworkUnavailableCopyWith(GitClientNetworkUnavailable value, $Res Function(GitClientNetworkUnavailable) _then) = _$GitClientNetworkUnavailableCopyWithImpl;
@override @useResult
$Res call({
 String stderr, AppFailure? cause
});




}
/// @nodoc
class _$GitClientNetworkUnavailableCopyWithImpl<$Res>
    implements $GitClientNetworkUnavailableCopyWith<$Res> {
  _$GitClientNetworkUnavailableCopyWithImpl(this._self, this._then);

  final GitClientNetworkUnavailable _self;
  final $Res Function(GitClientNetworkUnavailable) _then;

/// Create a copy of GitClientFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? stderr = null,Object? cause = freezed,}) {
  return _then(GitClientNetworkUnavailable(
null == stderr ? _self.stderr : stderr // ignore: cast_nullable_to_non_nullable
as String,cause: freezed == cause ? _self.cause : cause // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}


}

/// @nodoc


class GitClientNoRemote implements GitClientFailure {
  const GitClientNoRemote(this.stderr, {this.cause});
  

/// What git wrote to stderr, verbatim. For diagnostics — never parsed.
 final  String stderr;
@override final  AppFailure? cause;

/// Create a copy of GitClientFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GitClientNoRemoteCopyWith<GitClientNoRemote> get copyWith => _$GitClientNoRemoteCopyWithImpl<GitClientNoRemote>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GitClientNoRemote&&(identical(other.stderr, stderr) || other.stderr == stderr)&&(identical(other.cause, cause) || other.cause == cause));
}


@override
int get hashCode => Object.hash(runtimeType,stderr,cause);

@override
String toString() {
  return 'GitClientFailure.noRemote(stderr: $stderr, cause: $cause)';
}


}

/// @nodoc
abstract mixin class $GitClientNoRemoteCopyWith<$Res> implements $GitClientFailureCopyWith<$Res> {
  factory $GitClientNoRemoteCopyWith(GitClientNoRemote value, $Res Function(GitClientNoRemote) _then) = _$GitClientNoRemoteCopyWithImpl;
@override @useResult
$Res call({
 String stderr, AppFailure? cause
});




}
/// @nodoc
class _$GitClientNoRemoteCopyWithImpl<$Res>
    implements $GitClientNoRemoteCopyWith<$Res> {
  _$GitClientNoRemoteCopyWithImpl(this._self, this._then);

  final GitClientNoRemote _self;
  final $Res Function(GitClientNoRemote) _then;

/// Create a copy of GitClientFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? stderr = null,Object? cause = freezed,}) {
  return _then(GitClientNoRemote(
null == stderr ? _self.stderr : stderr // ignore: cast_nullable_to_non_nullable
as String,cause: freezed == cause ? _self.cause : cause // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}


}

/// @nodoc


class GitClientRemoteNotFound implements GitClientFailure {
  const GitClientRemoteNotFound(this.stderr, {this.cause});
  

/// What git wrote to stderr, verbatim. For diagnostics — never parsed.
 final  String stderr;
@override final  AppFailure? cause;

/// Create a copy of GitClientFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GitClientRemoteNotFoundCopyWith<GitClientRemoteNotFound> get copyWith => _$GitClientRemoteNotFoundCopyWithImpl<GitClientRemoteNotFound>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GitClientRemoteNotFound&&(identical(other.stderr, stderr) || other.stderr == stderr)&&(identical(other.cause, cause) || other.cause == cause));
}


@override
int get hashCode => Object.hash(runtimeType,stderr,cause);

@override
String toString() {
  return 'GitClientFailure.remoteNotFound(stderr: $stderr, cause: $cause)';
}


}

/// @nodoc
abstract mixin class $GitClientRemoteNotFoundCopyWith<$Res> implements $GitClientFailureCopyWith<$Res> {
  factory $GitClientRemoteNotFoundCopyWith(GitClientRemoteNotFound value, $Res Function(GitClientRemoteNotFound) _then) = _$GitClientRemoteNotFoundCopyWithImpl;
@override @useResult
$Res call({
 String stderr, AppFailure? cause
});




}
/// @nodoc
class _$GitClientRemoteNotFoundCopyWithImpl<$Res>
    implements $GitClientRemoteNotFoundCopyWith<$Res> {
  _$GitClientRemoteNotFoundCopyWithImpl(this._self, this._then);

  final GitClientRemoteNotFound _self;
  final $Res Function(GitClientRemoteNotFound) _then;

/// Create a copy of GitClientFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? stderr = null,Object? cause = freezed,}) {
  return _then(GitClientRemoteNotFound(
null == stderr ? _self.stderr : stderr // ignore: cast_nullable_to_non_nullable
as String,cause: freezed == cause ? _self.cause : cause // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}


}

/// @nodoc


class GitClientDestinationTaken implements GitClientFailure {
  const GitClientDestinationTaken(this.path, {this.cause});
  

/// The absolute path the clone was asked to create.
 final  String path;
@override final  AppFailure? cause;

/// Create a copy of GitClientFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GitClientDestinationTakenCopyWith<GitClientDestinationTaken> get copyWith => _$GitClientDestinationTakenCopyWithImpl<GitClientDestinationTaken>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GitClientDestinationTaken&&(identical(other.path, path) || other.path == path)&&(identical(other.cause, cause) || other.cause == cause));
}


@override
int get hashCode => Object.hash(runtimeType,path,cause);

@override
String toString() {
  return 'GitClientFailure.destinationTaken(path: $path, cause: $cause)';
}


}

/// @nodoc
abstract mixin class $GitClientDestinationTakenCopyWith<$Res> implements $GitClientFailureCopyWith<$Res> {
  factory $GitClientDestinationTakenCopyWith(GitClientDestinationTaken value, $Res Function(GitClientDestinationTaken) _then) = _$GitClientDestinationTakenCopyWithImpl;
@override @useResult
$Res call({
 String path, AppFailure? cause
});




}
/// @nodoc
class _$GitClientDestinationTakenCopyWithImpl<$Res>
    implements $GitClientDestinationTakenCopyWith<$Res> {
  _$GitClientDestinationTakenCopyWithImpl(this._self, this._then);

  final GitClientDestinationTaken _self;
  final $Res Function(GitClientDestinationTaken) _then;

/// Create a copy of GitClientFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? path = null,Object? cause = freezed,}) {
  return _then(GitClientDestinationTaken(
null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,cause: freezed == cause ? _self.cause : cause // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}


}

/// @nodoc


class GitClientPushRejected implements GitClientFailure {
  const GitClientPushRejected(this.stderr, {this.cause});
  

/// What git wrote to stderr, verbatim. For diagnostics — never parsed.
 final  String stderr;
@override final  AppFailure? cause;

/// Create a copy of GitClientFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GitClientPushRejectedCopyWith<GitClientPushRejected> get copyWith => _$GitClientPushRejectedCopyWithImpl<GitClientPushRejected>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GitClientPushRejected&&(identical(other.stderr, stderr) || other.stderr == stderr)&&(identical(other.cause, cause) || other.cause == cause));
}


@override
int get hashCode => Object.hash(runtimeType,stderr,cause);

@override
String toString() {
  return 'GitClientFailure.pushRejected(stderr: $stderr, cause: $cause)';
}


}

/// @nodoc
abstract mixin class $GitClientPushRejectedCopyWith<$Res> implements $GitClientFailureCopyWith<$Res> {
  factory $GitClientPushRejectedCopyWith(GitClientPushRejected value, $Res Function(GitClientPushRejected) _then) = _$GitClientPushRejectedCopyWithImpl;
@override @useResult
$Res call({
 String stderr, AppFailure? cause
});




}
/// @nodoc
class _$GitClientPushRejectedCopyWithImpl<$Res>
    implements $GitClientPushRejectedCopyWith<$Res> {
  _$GitClientPushRejectedCopyWithImpl(this._self, this._then);

  final GitClientPushRejected _self;
  final $Res Function(GitClientPushRejected) _then;

/// Create a copy of GitClientFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? stderr = null,Object? cause = freezed,}) {
  return _then(GitClientPushRejected(
null == stderr ? _self.stderr : stderr // ignore: cast_nullable_to_non_nullable
as String,cause: freezed == cause ? _self.cause : cause // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}


}

/// @nodoc


class GitClientBranchProtected implements GitClientFailure {
  const GitClientBranchProtected(this.stderr, {this.cause});
  

/// What git wrote to stderr, verbatim. For diagnostics — never parsed.
 final  String stderr;
@override final  AppFailure? cause;

/// Create a copy of GitClientFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GitClientBranchProtectedCopyWith<GitClientBranchProtected> get copyWith => _$GitClientBranchProtectedCopyWithImpl<GitClientBranchProtected>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GitClientBranchProtected&&(identical(other.stderr, stderr) || other.stderr == stderr)&&(identical(other.cause, cause) || other.cause == cause));
}


@override
int get hashCode => Object.hash(runtimeType,stderr,cause);

@override
String toString() {
  return 'GitClientFailure.branchProtected(stderr: $stderr, cause: $cause)';
}


}

/// @nodoc
abstract mixin class $GitClientBranchProtectedCopyWith<$Res> implements $GitClientFailureCopyWith<$Res> {
  factory $GitClientBranchProtectedCopyWith(GitClientBranchProtected value, $Res Function(GitClientBranchProtected) _then) = _$GitClientBranchProtectedCopyWithImpl;
@override @useResult
$Res call({
 String stderr, AppFailure? cause
});




}
/// @nodoc
class _$GitClientBranchProtectedCopyWithImpl<$Res>
    implements $GitClientBranchProtectedCopyWith<$Res> {
  _$GitClientBranchProtectedCopyWithImpl(this._self, this._then);

  final GitClientBranchProtected _self;
  final $Res Function(GitClientBranchProtected) _then;

/// Create a copy of GitClientFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? stderr = null,Object? cause = freezed,}) {
  return _then(GitClientBranchProtected(
null == stderr ? _self.stderr : stderr // ignore: cast_nullable_to_non_nullable
as String,cause: freezed == cause ? _self.cause : cause // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}


}

/// @nodoc


class GitClientLocalChangesOverwritten implements GitClientFailure {
  const GitClientLocalChangesOverwritten(final  List<String> paths, {this.cause}): _paths = paths;
  

/// The paths git listed, relative to the repository root.
 final  List<String> _paths;
/// The paths git listed, relative to the repository root.
 List<String> get paths {
  if (_paths is EqualUnmodifiableListView) return _paths;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_paths);
}

@override final  AppFailure? cause;

/// Create a copy of GitClientFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GitClientLocalChangesOverwrittenCopyWith<GitClientLocalChangesOverwritten> get copyWith => _$GitClientLocalChangesOverwrittenCopyWithImpl<GitClientLocalChangesOverwritten>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GitClientLocalChangesOverwritten&&const DeepCollectionEquality().equals(other._paths, _paths)&&(identical(other.cause, cause) || other.cause == cause));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_paths),cause);

@override
String toString() {
  return 'GitClientFailure.localChangesOverwritten(paths: $paths, cause: $cause)';
}


}

/// @nodoc
abstract mixin class $GitClientLocalChangesOverwrittenCopyWith<$Res> implements $GitClientFailureCopyWith<$Res> {
  factory $GitClientLocalChangesOverwrittenCopyWith(GitClientLocalChangesOverwritten value, $Res Function(GitClientLocalChangesOverwritten) _then) = _$GitClientLocalChangesOverwrittenCopyWithImpl;
@override @useResult
$Res call({
 List<String> paths, AppFailure? cause
});




}
/// @nodoc
class _$GitClientLocalChangesOverwrittenCopyWithImpl<$Res>
    implements $GitClientLocalChangesOverwrittenCopyWith<$Res> {
  _$GitClientLocalChangesOverwrittenCopyWithImpl(this._self, this._then);

  final GitClientLocalChangesOverwritten _self;
  final $Res Function(GitClientLocalChangesOverwritten) _then;

/// Create a copy of GitClientFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? paths = null,Object? cause = freezed,}) {
  return _then(GitClientLocalChangesOverwritten(
null == paths ? _self._paths : paths // ignore: cast_nullable_to_non_nullable
as List<String>,cause: freezed == cause ? _self.cause : cause // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}


}

/// @nodoc


class GitClientTimedOut implements GitClientFailure {
  const GitClientTimedOut(this.command, this.timeout, {this.cause});
  

/// The command as it was run, for the "details" disclosure in the UI.
 final  String command;
/// How long it was allowed to take.
 final  Duration timeout;
@override final  AppFailure? cause;

/// Create a copy of GitClientFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GitClientTimedOutCopyWith<GitClientTimedOut> get copyWith => _$GitClientTimedOutCopyWithImpl<GitClientTimedOut>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GitClientTimedOut&&(identical(other.command, command) || other.command == command)&&(identical(other.timeout, timeout) || other.timeout == timeout)&&(identical(other.cause, cause) || other.cause == cause));
}


@override
int get hashCode => Object.hash(runtimeType,command,timeout,cause);

@override
String toString() {
  return 'GitClientFailure.timedOut(command: $command, timeout: $timeout, cause: $cause)';
}


}

/// @nodoc
abstract mixin class $GitClientTimedOutCopyWith<$Res> implements $GitClientFailureCopyWith<$Res> {
  factory $GitClientTimedOutCopyWith(GitClientTimedOut value, $Res Function(GitClientTimedOut) _then) = _$GitClientTimedOutCopyWithImpl;
@override @useResult
$Res call({
 String command, Duration timeout, AppFailure? cause
});




}
/// @nodoc
class _$GitClientTimedOutCopyWithImpl<$Res>
    implements $GitClientTimedOutCopyWith<$Res> {
  _$GitClientTimedOutCopyWithImpl(this._self, this._then);

  final GitClientTimedOut _self;
  final $Res Function(GitClientTimedOut) _then;

/// Create a copy of GitClientFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? command = null,Object? timeout = null,Object? cause = freezed,}) {
  return _then(GitClientTimedOut(
null == command ? _self.command : command // ignore: cast_nullable_to_non_nullable
as String,null == timeout ? _self.timeout : timeout // ignore: cast_nullable_to_non_nullable
as Duration,cause: freezed == cause ? _self.cause : cause // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}


}

/// @nodoc


class GitClientPathNotInRevision implements GitClientFailure {
  const GitClientPathNotInRevision(this.revision, this.path, {this.cause});
  

/// The revision as it was asked for — a sha, a branch, `HEAD`.
 final  String revision;
/// The path, relative to the repository root.
 final  String path;
@override final  AppFailure? cause;

/// Create a copy of GitClientFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GitClientPathNotInRevisionCopyWith<GitClientPathNotInRevision> get copyWith => _$GitClientPathNotInRevisionCopyWithImpl<GitClientPathNotInRevision>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GitClientPathNotInRevision&&(identical(other.revision, revision) || other.revision == revision)&&(identical(other.path, path) || other.path == path)&&(identical(other.cause, cause) || other.cause == cause));
}


@override
int get hashCode => Object.hash(runtimeType,revision,path,cause);

@override
String toString() {
  return 'GitClientFailure.pathNotInRevision(revision: $revision, path: $path, cause: $cause)';
}


}

/// @nodoc
abstract mixin class $GitClientPathNotInRevisionCopyWith<$Res> implements $GitClientFailureCopyWith<$Res> {
  factory $GitClientPathNotInRevisionCopyWith(GitClientPathNotInRevision value, $Res Function(GitClientPathNotInRevision) _then) = _$GitClientPathNotInRevisionCopyWithImpl;
@override @useResult
$Res call({
 String revision, String path, AppFailure? cause
});




}
/// @nodoc
class _$GitClientPathNotInRevisionCopyWithImpl<$Res>
    implements $GitClientPathNotInRevisionCopyWith<$Res> {
  _$GitClientPathNotInRevisionCopyWithImpl(this._self, this._then);

  final GitClientPathNotInRevision _self;
  final $Res Function(GitClientPathNotInRevision) _then;

/// Create a copy of GitClientFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? revision = null,Object? path = null,Object? cause = freezed,}) {
  return _then(GitClientPathNotInRevision(
null == revision ? _self.revision : revision // ignore: cast_nullable_to_non_nullable
as String,null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,cause: freezed == cause ? _self.cause : cause // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}


}

/// @nodoc


class GitClientPathCommitted implements GitClientFailure {
  const GitClientPathCommitted(final  List<String> paths, {this.cause}): _paths = paths;
  

/// The ones `HEAD` holds, relative to the repository root.
 final  List<String> _paths;
/// The ones `HEAD` holds, relative to the repository root.
 List<String> get paths {
  if (_paths is EqualUnmodifiableListView) return _paths;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_paths);
}

@override final  AppFailure? cause;

/// Create a copy of GitClientFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GitClientPathCommittedCopyWith<GitClientPathCommitted> get copyWith => _$GitClientPathCommittedCopyWithImpl<GitClientPathCommitted>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GitClientPathCommitted&&const DeepCollectionEquality().equals(other._paths, _paths)&&(identical(other.cause, cause) || other.cause == cause));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_paths),cause);

@override
String toString() {
  return 'GitClientFailure.pathCommitted(paths: $paths, cause: $cause)';
}


}

/// @nodoc
abstract mixin class $GitClientPathCommittedCopyWith<$Res> implements $GitClientFailureCopyWith<$Res> {
  factory $GitClientPathCommittedCopyWith(GitClientPathCommitted value, $Res Function(GitClientPathCommitted) _then) = _$GitClientPathCommittedCopyWithImpl;
@override @useResult
$Res call({
 List<String> paths, AppFailure? cause
});




}
/// @nodoc
class _$GitClientPathCommittedCopyWithImpl<$Res>
    implements $GitClientPathCommittedCopyWith<$Res> {
  _$GitClientPathCommittedCopyWithImpl(this._self, this._then);

  final GitClientPathCommitted _self;
  final $Res Function(GitClientPathCommitted) _then;

/// Create a copy of GitClientFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? paths = null,Object? cause = freezed,}) {
  return _then(GitClientPathCommitted(
null == paths ? _self._paths : paths // ignore: cast_nullable_to_non_nullable
as List<String>,cause: freezed == cause ? _self.cause : cause // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}


}

/// @nodoc


class GitClientCommandDenied implements GitClientFailure, CommandDenial {
  const GitClientCommandDenied(this.command, {this.cause});
  

/// The command as it would have run, secrets taken out.
 final  String command;
@override final  AppFailure? cause;

/// Create a copy of GitClientFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GitClientCommandDeniedCopyWith<GitClientCommandDenied> get copyWith => _$GitClientCommandDeniedCopyWithImpl<GitClientCommandDenied>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GitClientCommandDenied&&(identical(other.command, command) || other.command == command)&&(identical(other.cause, cause) || other.cause == cause));
}


@override
int get hashCode => Object.hash(runtimeType,command,cause);

@override
String toString() {
  return 'GitClientFailure.commandDenied(command: $command, cause: $cause)';
}


}

/// @nodoc
abstract mixin class $GitClientCommandDeniedCopyWith<$Res> implements $GitClientFailureCopyWith<$Res> {
  factory $GitClientCommandDeniedCopyWith(GitClientCommandDenied value, $Res Function(GitClientCommandDenied) _then) = _$GitClientCommandDeniedCopyWithImpl;
@override @useResult
$Res call({
 String command, AppFailure? cause
});




}
/// @nodoc
class _$GitClientCommandDeniedCopyWithImpl<$Res>
    implements $GitClientCommandDeniedCopyWith<$Res> {
  _$GitClientCommandDeniedCopyWithImpl(this._self, this._then);

  final GitClientCommandDenied _self;
  final $Res Function(GitClientCommandDenied) _then;

/// Create a copy of GitClientFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? command = null,Object? cause = freezed,}) {
  return _then(GitClientCommandDenied(
null == command ? _self.command : command // ignore: cast_nullable_to_non_nullable
as String,cause: freezed == cause ? _self.cause : cause // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}


}

/// @nodoc


class GitClientCommandFailed implements GitClientFailure {
  const GitClientCommandFailed(this.command, this.exitCode, this.stderr, {this.cause});
  

/// The command as it was run, for the "details" disclosure in the UI.
 final  String command;
/// The process exit code.
 final  int exitCode;
/// What git wrote to stderr, verbatim. For diagnostics — never parsed.
 final  String stderr;
@override final  AppFailure? cause;

/// Create a copy of GitClientFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GitClientCommandFailedCopyWith<GitClientCommandFailed> get copyWith => _$GitClientCommandFailedCopyWithImpl<GitClientCommandFailed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GitClientCommandFailed&&(identical(other.command, command) || other.command == command)&&(identical(other.exitCode, exitCode) || other.exitCode == exitCode)&&(identical(other.stderr, stderr) || other.stderr == stderr)&&(identical(other.cause, cause) || other.cause == cause));
}


@override
int get hashCode => Object.hash(runtimeType,command,exitCode,stderr,cause);

@override
String toString() {
  return 'GitClientFailure.commandFailed(command: $command, exitCode: $exitCode, stderr: $stderr, cause: $cause)';
}


}

/// @nodoc
abstract mixin class $GitClientCommandFailedCopyWith<$Res> implements $GitClientFailureCopyWith<$Res> {
  factory $GitClientCommandFailedCopyWith(GitClientCommandFailed value, $Res Function(GitClientCommandFailed) _then) = _$GitClientCommandFailedCopyWithImpl;
@override @useResult
$Res call({
 String command, int exitCode, String stderr, AppFailure? cause
});




}
/// @nodoc
class _$GitClientCommandFailedCopyWithImpl<$Res>
    implements $GitClientCommandFailedCopyWith<$Res> {
  _$GitClientCommandFailedCopyWithImpl(this._self, this._then);

  final GitClientCommandFailed _self;
  final $Res Function(GitClientCommandFailed) _then;

/// Create a copy of GitClientFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? command = null,Object? exitCode = null,Object? stderr = null,Object? cause = freezed,}) {
  return _then(GitClientCommandFailed(
null == command ? _self.command : command // ignore: cast_nullable_to_non_nullable
as String,null == exitCode ? _self.exitCode : exitCode // ignore: cast_nullable_to_non_nullable
as int,null == stderr ? _self.stderr : stderr // ignore: cast_nullable_to_non_nullable
as String,cause: freezed == cause ? _self.cause : cause // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}


}

// dart format on
