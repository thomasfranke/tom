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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( GitClientExecutableNotFound value)?  executableNotFound,TResult Function( GitClientNotARepository value)?  notARepository,TResult Function( GitClientMergeConflict value)?  mergeConflict,TResult Function( GitClientAuthenticationFailed value)?  authenticationFailed,TResult Function( GitClientPushRejected value)?  pushRejected,TResult Function( GitClientTimedOut value)?  timedOut,TResult Function( GitClientCommandFailed value)?  commandFailed,required TResult orElse(),}){
final _that = this;
switch (_that) {
case GitClientExecutableNotFound() when executableNotFound != null:
return executableNotFound(_that);case GitClientNotARepository() when notARepository != null:
return notARepository(_that);case GitClientMergeConflict() when mergeConflict != null:
return mergeConflict(_that);case GitClientAuthenticationFailed() when authenticationFailed != null:
return authenticationFailed(_that);case GitClientPushRejected() when pushRejected != null:
return pushRejected(_that);case GitClientTimedOut() when timedOut != null:
return timedOut(_that);case GitClientCommandFailed() when commandFailed != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( GitClientExecutableNotFound value)  executableNotFound,required TResult Function( GitClientNotARepository value)  notARepository,required TResult Function( GitClientMergeConflict value)  mergeConflict,required TResult Function( GitClientAuthenticationFailed value)  authenticationFailed,required TResult Function( GitClientPushRejected value)  pushRejected,required TResult Function( GitClientTimedOut value)  timedOut,required TResult Function( GitClientCommandFailed value)  commandFailed,}){
final _that = this;
switch (_that) {
case GitClientExecutableNotFound():
return executableNotFound(_that);case GitClientNotARepository():
return notARepository(_that);case GitClientMergeConflict():
return mergeConflict(_that);case GitClientAuthenticationFailed():
return authenticationFailed(_that);case GitClientPushRejected():
return pushRejected(_that);case GitClientTimedOut():
return timedOut(_that);case GitClientCommandFailed():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( GitClientExecutableNotFound value)?  executableNotFound,TResult? Function( GitClientNotARepository value)?  notARepository,TResult? Function( GitClientMergeConflict value)?  mergeConflict,TResult? Function( GitClientAuthenticationFailed value)?  authenticationFailed,TResult? Function( GitClientPushRejected value)?  pushRejected,TResult? Function( GitClientTimedOut value)?  timedOut,TResult? Function( GitClientCommandFailed value)?  commandFailed,}){
final _that = this;
switch (_that) {
case GitClientExecutableNotFound() when executableNotFound != null:
return executableNotFound(_that);case GitClientNotARepository() when notARepository != null:
return notARepository(_that);case GitClientMergeConflict() when mergeConflict != null:
return mergeConflict(_that);case GitClientAuthenticationFailed() when authenticationFailed != null:
return authenticationFailed(_that);case GitClientPushRejected() when pushRejected != null:
return pushRejected(_that);case GitClientTimedOut() when timedOut != null:
return timedOut(_that);case GitClientCommandFailed() when commandFailed != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( AppFailure? cause)?  executableNotFound,TResult Function( String path,  AppFailure? cause)?  notARepository,TResult Function( List<String> conflictedPaths,  AppFailure? cause)?  mergeConflict,TResult Function( String stderr,  AppFailure? cause)?  authenticationFailed,TResult Function( String stderr,  AppFailure? cause)?  pushRejected,TResult Function( String command,  Duration timeout,  AppFailure? cause)?  timedOut,TResult Function( String command,  int exitCode,  String stderr,  AppFailure? cause)?  commandFailed,required TResult orElse(),}) {final _that = this;
switch (_that) {
case GitClientExecutableNotFound() when executableNotFound != null:
return executableNotFound(_that.cause);case GitClientNotARepository() when notARepository != null:
return notARepository(_that.path,_that.cause);case GitClientMergeConflict() when mergeConflict != null:
return mergeConflict(_that.conflictedPaths,_that.cause);case GitClientAuthenticationFailed() when authenticationFailed != null:
return authenticationFailed(_that.stderr,_that.cause);case GitClientPushRejected() when pushRejected != null:
return pushRejected(_that.stderr,_that.cause);case GitClientTimedOut() when timedOut != null:
return timedOut(_that.command,_that.timeout,_that.cause);case GitClientCommandFailed() when commandFailed != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( AppFailure? cause)  executableNotFound,required TResult Function( String path,  AppFailure? cause)  notARepository,required TResult Function( List<String> conflictedPaths,  AppFailure? cause)  mergeConflict,required TResult Function( String stderr,  AppFailure? cause)  authenticationFailed,required TResult Function( String stderr,  AppFailure? cause)  pushRejected,required TResult Function( String command,  Duration timeout,  AppFailure? cause)  timedOut,required TResult Function( String command,  int exitCode,  String stderr,  AppFailure? cause)  commandFailed,}) {final _that = this;
switch (_that) {
case GitClientExecutableNotFound():
return executableNotFound(_that.cause);case GitClientNotARepository():
return notARepository(_that.path,_that.cause);case GitClientMergeConflict():
return mergeConflict(_that.conflictedPaths,_that.cause);case GitClientAuthenticationFailed():
return authenticationFailed(_that.stderr,_that.cause);case GitClientPushRejected():
return pushRejected(_that.stderr,_that.cause);case GitClientTimedOut():
return timedOut(_that.command,_that.timeout,_that.cause);case GitClientCommandFailed():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( AppFailure? cause)?  executableNotFound,TResult? Function( String path,  AppFailure? cause)?  notARepository,TResult? Function( List<String> conflictedPaths,  AppFailure? cause)?  mergeConflict,TResult? Function( String stderr,  AppFailure? cause)?  authenticationFailed,TResult? Function( String stderr,  AppFailure? cause)?  pushRejected,TResult? Function( String command,  Duration timeout,  AppFailure? cause)?  timedOut,TResult? Function( String command,  int exitCode,  String stderr,  AppFailure? cause)?  commandFailed,}) {final _that = this;
switch (_that) {
case GitClientExecutableNotFound() when executableNotFound != null:
return executableNotFound(_that.cause);case GitClientNotARepository() when notARepository != null:
return notARepository(_that.path,_that.cause);case GitClientMergeConflict() when mergeConflict != null:
return mergeConflict(_that.conflictedPaths,_that.cause);case GitClientAuthenticationFailed() when authenticationFailed != null:
return authenticationFailed(_that.stderr,_that.cause);case GitClientPushRejected() when pushRejected != null:
return pushRejected(_that.stderr,_that.cause);case GitClientTimedOut() when timedOut != null:
return timedOut(_that.command,_that.timeout,_that.cause);case GitClientCommandFailed() when commandFailed != null:
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
