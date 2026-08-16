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





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GitFailure);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GitFailure()';
}


}

/// @nodoc
class $GitFailureCopyWith<$Res>  {
$GitFailureCopyWith(GitFailure _, $Res Function(GitFailure) __);
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( GitNotInstalled value)?  notInstalled,TResult Function( NotARepository value)?  notARepository,TResult Function( MergeConflict value)?  mergeConflict,TResult Function( AuthenticationFailed value)?  authenticationFailed,TResult Function( DetachedHead value)?  detachedHead,TResult Function( GitCommandFailed value)?  commandFailed,required TResult orElse(),}){
final _that = this;
switch (_that) {
case GitNotInstalled() when notInstalled != null:
return notInstalled(_that);case NotARepository() when notARepository != null:
return notARepository(_that);case MergeConflict() when mergeConflict != null:
return mergeConflict(_that);case AuthenticationFailed() when authenticationFailed != null:
return authenticationFailed(_that);case DetachedHead() when detachedHead != null:
return detachedHead(_that);case GitCommandFailed() when commandFailed != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( GitNotInstalled value)  notInstalled,required TResult Function( NotARepository value)  notARepository,required TResult Function( MergeConflict value)  mergeConflict,required TResult Function( AuthenticationFailed value)  authenticationFailed,required TResult Function( DetachedHead value)  detachedHead,required TResult Function( GitCommandFailed value)  commandFailed,}){
final _that = this;
switch (_that) {
case GitNotInstalled():
return notInstalled(_that);case NotARepository():
return notARepository(_that);case MergeConflict():
return mergeConflict(_that);case AuthenticationFailed():
return authenticationFailed(_that);case DetachedHead():
return detachedHead(_that);case GitCommandFailed():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( GitNotInstalled value)?  notInstalled,TResult? Function( NotARepository value)?  notARepository,TResult? Function( MergeConflict value)?  mergeConflict,TResult? Function( AuthenticationFailed value)?  authenticationFailed,TResult? Function( DetachedHead value)?  detachedHead,TResult? Function( GitCommandFailed value)?  commandFailed,}){
final _that = this;
switch (_that) {
case GitNotInstalled() when notInstalled != null:
return notInstalled(_that);case NotARepository() when notARepository != null:
return notARepository(_that);case MergeConflict() when mergeConflict != null:
return mergeConflict(_that);case AuthenticationFailed() when authenticationFailed != null:
return authenticationFailed(_that);case DetachedHead() when detachedHead != null:
return detachedHead(_that);case GitCommandFailed() when commandFailed != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  notInstalled,TResult Function( String path)?  notARepository,TResult Function( List<String> conflictedFiles)?  mergeConflict,TResult Function()?  authenticationFailed,TResult Function()?  detachedHead,TResult Function( String command,  String stderr)?  commandFailed,required TResult orElse(),}) {final _that = this;
switch (_that) {
case GitNotInstalled() when notInstalled != null:
return notInstalled();case NotARepository() when notARepository != null:
return notARepository(_that.path);case MergeConflict() when mergeConflict != null:
return mergeConflict(_that.conflictedFiles);case AuthenticationFailed() when authenticationFailed != null:
return authenticationFailed();case DetachedHead() when detachedHead != null:
return detachedHead();case GitCommandFailed() when commandFailed != null:
return commandFailed(_that.command,_that.stderr);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  notInstalled,required TResult Function( String path)  notARepository,required TResult Function( List<String> conflictedFiles)  mergeConflict,required TResult Function()  authenticationFailed,required TResult Function()  detachedHead,required TResult Function( String command,  String stderr)  commandFailed,}) {final _that = this;
switch (_that) {
case GitNotInstalled():
return notInstalled();case NotARepository():
return notARepository(_that.path);case MergeConflict():
return mergeConflict(_that.conflictedFiles);case AuthenticationFailed():
return authenticationFailed();case DetachedHead():
return detachedHead();case GitCommandFailed():
return commandFailed(_that.command,_that.stderr);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  notInstalled,TResult? Function( String path)?  notARepository,TResult? Function( List<String> conflictedFiles)?  mergeConflict,TResult? Function()?  authenticationFailed,TResult? Function()?  detachedHead,TResult? Function( String command,  String stderr)?  commandFailed,}) {final _that = this;
switch (_that) {
case GitNotInstalled() when notInstalled != null:
return notInstalled();case NotARepository() when notARepository != null:
return notARepository(_that.path);case MergeConflict() when mergeConflict != null:
return mergeConflict(_that.conflictedFiles);case AuthenticationFailed() when authenticationFailed != null:
return authenticationFailed();case DetachedHead() when detachedHead != null:
return detachedHead();case GitCommandFailed() when commandFailed != null:
return commandFailed(_that.command,_that.stderr);case _:
  return null;

}
}

}

/// @nodoc


class GitNotInstalled implements GitFailure {
  const GitNotInstalled();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GitNotInstalled);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GitFailure.notInstalled()';
}


}




/// @nodoc


class NotARepository implements GitFailure {
  const NotARepository(this.path);
  

/// The absolute path that was searched for an enclosing repository.
 final  String path;

/// Create a copy of GitFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotARepositoryCopyWith<NotARepository> get copyWith => _$NotARepositoryCopyWithImpl<NotARepository>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotARepository&&(identical(other.path, path) || other.path == path));
}


@override
int get hashCode => Object.hash(runtimeType,path);

@override
String toString() {
  return 'GitFailure.notARepository(path: $path)';
}


}

/// @nodoc
abstract mixin class $NotARepositoryCopyWith<$Res> implements $GitFailureCopyWith<$Res> {
  factory $NotARepositoryCopyWith(NotARepository value, $Res Function(NotARepository) _then) = _$NotARepositoryCopyWithImpl;
@useResult
$Res call({
 String path
});




}
/// @nodoc
class _$NotARepositoryCopyWithImpl<$Res>
    implements $NotARepositoryCopyWith<$Res> {
  _$NotARepositoryCopyWithImpl(this._self, this._then);

  final NotARepository _self;
  final $Res Function(NotARepository) _then;

/// Create a copy of GitFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? path = null,}) {
  return _then(NotARepository(
null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class MergeConflict implements GitFailure {
  const MergeConflict(final  List<String> conflictedFiles): _conflictedFiles = conflictedFiles;
  

/// Paths left conflicted, relative to the repository root.
 final  List<String> _conflictedFiles;
/// Paths left conflicted, relative to the repository root.
 List<String> get conflictedFiles {
  if (_conflictedFiles is EqualUnmodifiableListView) return _conflictedFiles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_conflictedFiles);
}


/// Create a copy of GitFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MergeConflictCopyWith<MergeConflict> get copyWith => _$MergeConflictCopyWithImpl<MergeConflict>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MergeConflict&&const DeepCollectionEquality().equals(other._conflictedFiles, _conflictedFiles));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_conflictedFiles));

@override
String toString() {
  return 'GitFailure.mergeConflict(conflictedFiles: $conflictedFiles)';
}


}

/// @nodoc
abstract mixin class $MergeConflictCopyWith<$Res> implements $GitFailureCopyWith<$Res> {
  factory $MergeConflictCopyWith(MergeConflict value, $Res Function(MergeConflict) _then) = _$MergeConflictCopyWithImpl;
@useResult
$Res call({
 List<String> conflictedFiles
});




}
/// @nodoc
class _$MergeConflictCopyWithImpl<$Res>
    implements $MergeConflictCopyWith<$Res> {
  _$MergeConflictCopyWithImpl(this._self, this._then);

  final MergeConflict _self;
  final $Res Function(MergeConflict) _then;

/// Create a copy of GitFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? conflictedFiles = null,}) {
  return _then(MergeConflict(
null == conflictedFiles ? _self._conflictedFiles : conflictedFiles // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

/// @nodoc


class AuthenticationFailed implements GitFailure {
  const AuthenticationFailed();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthenticationFailed);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GitFailure.authenticationFailed()';
}


}




/// @nodoc


class DetachedHead implements GitFailure {
  const DetachedHead();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DetachedHead);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GitFailure.detachedHead()';
}


}




/// @nodoc


class GitCommandFailed implements GitFailure {
  const GitCommandFailed(this.command, this.stderr);
  

/// The command as it was run, for the "details" disclosure in the UI.
 final  String command;
/// What git wrote to stderr, verbatim.
 final  String stderr;

/// Create a copy of GitFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GitCommandFailedCopyWith<GitCommandFailed> get copyWith => _$GitCommandFailedCopyWithImpl<GitCommandFailed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GitCommandFailed&&(identical(other.command, command) || other.command == command)&&(identical(other.stderr, stderr) || other.stderr == stderr));
}


@override
int get hashCode => Object.hash(runtimeType,command,stderr);

@override
String toString() {
  return 'GitFailure.commandFailed(command: $command, stderr: $stderr)';
}


}

/// @nodoc
abstract mixin class $GitCommandFailedCopyWith<$Res> implements $GitFailureCopyWith<$Res> {
  factory $GitCommandFailedCopyWith(GitCommandFailed value, $Res Function(GitCommandFailed) _then) = _$GitCommandFailedCopyWithImpl;
@useResult
$Res call({
 String command, String stderr
});




}
/// @nodoc
class _$GitCommandFailedCopyWithImpl<$Res>
    implements $GitCommandFailedCopyWith<$Res> {
  _$GitCommandFailedCopyWithImpl(this._self, this._then);

  final GitCommandFailed _self;
  final $Res Function(GitCommandFailed) _then;

/// Create a copy of GitFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? command = null,Object? stderr = null,}) {
  return _then(GitCommandFailed(
null == command ? _self.command : command // ignore: cast_nullable_to_non_nullable
as String,null == stderr ? _self.stderr : stderr // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
