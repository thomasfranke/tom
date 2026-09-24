// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'space_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SpaceSessionState {

/// The folder the user opened, and the repository that encloses it.
 SpaceEntity get space;/// The document the editor and the preview are showing, or null when
/// none has been chosen.
///
/// Null is the state a space opens in, not an error. It is a
/// [SpaceRelativePathValueObject] because that is what the app navigates
/// in — git's spelling is [SpaceEntity.toRepoRelative]'s to produce, and
/// nobody else's.
 SpaceRelativePathValueObject? get openDocument;/// How the document area is being looked at.
///
/// Here rather than in a panel because it decides which panels the
/// region draws at all: the bar that offers the three modes and the
/// shell that obeys them are two readers, and two readers is what this
/// state is for.
///
/// Split is where a space opens — the product's own claim is that
/// source and preview belong side by side.
 DocumentModeEnum get mode;/// Where the repository stands, or null while nobody has read it yet.
///
/// Here because three panels ask: the changes panel draws the list, the
/// status bar says the branch and the counts, and M2's diff will want
/// the same reading. Three answers to "which branch is this" is the
/// failure mode this state exists to prevent.
///
/// A reading, not a subscription — stale as soon as anything writes to
/// disk, and re-read after every operation that changes the tree.
 GitStatusValueObject? get git;/// The commit whose version of [openDocument] is being read, or null
/// when the working copy is.
///
/// Here because three panels ask: the preview renders that version
/// rather than the buffer, the bar above the document says which commit
/// is on screen and offers the way back, and the shell draws no source
/// pane at all — nothing types into the past.
///
/// The whole commit rather than its sha, because the bar names the
/// author and the date and a second lookup to say so would be a second
/// answer that can disagree with the list.
 CommitEntity? get readingVersion;
/// Create a copy of SpaceSessionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SpaceSessionStateCopyWith<SpaceSessionState> get copyWith => _$SpaceSessionStateCopyWithImpl<SpaceSessionState>(this as SpaceSessionState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SpaceSessionState&&(identical(other.space, space) || other.space == space)&&(identical(other.openDocument, openDocument) || other.openDocument == openDocument)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.git, git) || other.git == git)&&(identical(other.readingVersion, readingVersion) || other.readingVersion == readingVersion));
}


@override
int get hashCode => Object.hash(runtimeType,space,openDocument,mode,git,readingVersion);

@override
String toString() {
  return 'SpaceSessionState(space: $space, openDocument: $openDocument, mode: $mode, git: $git, readingVersion: $readingVersion)';
}


}

/// @nodoc
abstract mixin class $SpaceSessionStateCopyWith<$Res>  {
  factory $SpaceSessionStateCopyWith(SpaceSessionState value, $Res Function(SpaceSessionState) _then) = _$SpaceSessionStateCopyWithImpl;
@useResult
$Res call({
 SpaceEntity space, SpaceRelativePathValueObject? openDocument, DocumentModeEnum mode, GitStatusValueObject? git, CommitEntity? readingVersion
});


$SpaceEntityCopyWith<$Res> get space;$GitStatusValueObjectCopyWith<$Res>? get git;$CommitEntityCopyWith<$Res>? get readingVersion;

}
/// @nodoc
class _$SpaceSessionStateCopyWithImpl<$Res>
    implements $SpaceSessionStateCopyWith<$Res> {
  _$SpaceSessionStateCopyWithImpl(this._self, this._then);

  final SpaceSessionState _self;
  final $Res Function(SpaceSessionState) _then;

/// Create a copy of SpaceSessionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? space = null,Object? openDocument = freezed,Object? mode = null,Object? git = freezed,Object? readingVersion = freezed,}) {
  return _then(_self.copyWith(
space: null == space ? _self.space : space // ignore: cast_nullable_to_non_nullable
as SpaceEntity,openDocument: freezed == openDocument ? _self.openDocument : openDocument // ignore: cast_nullable_to_non_nullable
as SpaceRelativePathValueObject?,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as DocumentModeEnum,git: freezed == git ? _self.git : git // ignore: cast_nullable_to_non_nullable
as GitStatusValueObject?,readingVersion: freezed == readingVersion ? _self.readingVersion : readingVersion // ignore: cast_nullable_to_non_nullable
as CommitEntity?,
  ));
}
/// Create a copy of SpaceSessionState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SpaceEntityCopyWith<$Res> get space {
  
  return $SpaceEntityCopyWith<$Res>(_self.space, (value) {
    return _then(_self.copyWith(space: value));
  });
}/// Create a copy of SpaceSessionState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GitStatusValueObjectCopyWith<$Res>? get git {
    if (_self.git == null) {
    return null;
  }

  return $GitStatusValueObjectCopyWith<$Res>(_self.git!, (value) {
    return _then(_self.copyWith(git: value));
  });
}/// Create a copy of SpaceSessionState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CommitEntityCopyWith<$Res>? get readingVersion {
    if (_self.readingVersion == null) {
    return null;
  }

  return $CommitEntityCopyWith<$Res>(_self.readingVersion!, (value) {
    return _then(_self.copyWith(readingVersion: value));
  });
}
}


/// Adds pattern-matching-related methods to [SpaceSessionState].
extension SpaceSessionStatePatterns on SpaceSessionState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SpaceSessionState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SpaceSessionState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SpaceSessionState value)  $default,){
final _that = this;
switch (_that) {
case _SpaceSessionState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SpaceSessionState value)?  $default,){
final _that = this;
switch (_that) {
case _SpaceSessionState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SpaceEntity space,  SpaceRelativePathValueObject? openDocument,  DocumentModeEnum mode,  GitStatusValueObject? git,  CommitEntity? readingVersion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SpaceSessionState() when $default != null:
return $default(_that.space,_that.openDocument,_that.mode,_that.git,_that.readingVersion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SpaceEntity space,  SpaceRelativePathValueObject? openDocument,  DocumentModeEnum mode,  GitStatusValueObject? git,  CommitEntity? readingVersion)  $default,) {final _that = this;
switch (_that) {
case _SpaceSessionState():
return $default(_that.space,_that.openDocument,_that.mode,_that.git,_that.readingVersion);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SpaceEntity space,  SpaceRelativePathValueObject? openDocument,  DocumentModeEnum mode,  GitStatusValueObject? git,  CommitEntity? readingVersion)?  $default,) {final _that = this;
switch (_that) {
case _SpaceSessionState() when $default != null:
return $default(_that.space,_that.openDocument,_that.mode,_that.git,_that.readingVersion);case _:
  return null;

}
}

}

/// @nodoc


class _SpaceSessionState implements SpaceSessionState {
  const _SpaceSessionState({required this.space, this.openDocument, this.mode = DocumentModeEnum.split, this.git, this.readingVersion});
  

/// The folder the user opened, and the repository that encloses it.
@override final  SpaceEntity space;
/// The document the editor and the preview are showing, or null when
/// none has been chosen.
///
/// Null is the state a space opens in, not an error. It is a
/// [SpaceRelativePathValueObject] because that is what the app navigates
/// in — git's spelling is [SpaceEntity.toRepoRelative]'s to produce, and
/// nobody else's.
@override final  SpaceRelativePathValueObject? openDocument;
/// How the document area is being looked at.
///
/// Here rather than in a panel because it decides which panels the
/// region draws at all: the bar that offers the three modes and the
/// shell that obeys them are two readers, and two readers is what this
/// state is for.
///
/// Split is where a space opens — the product's own claim is that
/// source and preview belong side by side.
@override@JsonKey() final  DocumentModeEnum mode;
/// Where the repository stands, or null while nobody has read it yet.
///
/// Here because three panels ask: the changes panel draws the list, the
/// status bar says the branch and the counts, and M2's diff will want
/// the same reading. Three answers to "which branch is this" is the
/// failure mode this state exists to prevent.
///
/// A reading, not a subscription — stale as soon as anything writes to
/// disk, and re-read after every operation that changes the tree.
@override final  GitStatusValueObject? git;
/// The commit whose version of [openDocument] is being read, or null
/// when the working copy is.
///
/// Here because three panels ask: the preview renders that version
/// rather than the buffer, the bar above the document says which commit
/// is on screen and offers the way back, and the shell draws no source
/// pane at all — nothing types into the past.
///
/// The whole commit rather than its sha, because the bar names the
/// author and the date and a second lookup to say so would be a second
/// answer that can disagree with the list.
@override final  CommitEntity? readingVersion;

/// Create a copy of SpaceSessionState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SpaceSessionStateCopyWith<_SpaceSessionState> get copyWith => __$SpaceSessionStateCopyWithImpl<_SpaceSessionState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SpaceSessionState&&(identical(other.space, space) || other.space == space)&&(identical(other.openDocument, openDocument) || other.openDocument == openDocument)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.git, git) || other.git == git)&&(identical(other.readingVersion, readingVersion) || other.readingVersion == readingVersion));
}


@override
int get hashCode => Object.hash(runtimeType,space,openDocument,mode,git,readingVersion);

@override
String toString() {
  return 'SpaceSessionState(space: $space, openDocument: $openDocument, mode: $mode, git: $git, readingVersion: $readingVersion)';
}


}

/// @nodoc
abstract mixin class _$SpaceSessionStateCopyWith<$Res> implements $SpaceSessionStateCopyWith<$Res> {
  factory _$SpaceSessionStateCopyWith(_SpaceSessionState value, $Res Function(_SpaceSessionState) _then) = __$SpaceSessionStateCopyWithImpl;
@override @useResult
$Res call({
 SpaceEntity space, SpaceRelativePathValueObject? openDocument, DocumentModeEnum mode, GitStatusValueObject? git, CommitEntity? readingVersion
});


@override $SpaceEntityCopyWith<$Res> get space;@override $GitStatusValueObjectCopyWith<$Res>? get git;@override $CommitEntityCopyWith<$Res>? get readingVersion;

}
/// @nodoc
class __$SpaceSessionStateCopyWithImpl<$Res>
    implements _$SpaceSessionStateCopyWith<$Res> {
  __$SpaceSessionStateCopyWithImpl(this._self, this._then);

  final _SpaceSessionState _self;
  final $Res Function(_SpaceSessionState) _then;

/// Create a copy of SpaceSessionState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? space = null,Object? openDocument = freezed,Object? mode = null,Object? git = freezed,Object? readingVersion = freezed,}) {
  return _then(_SpaceSessionState(
space: null == space ? _self.space : space // ignore: cast_nullable_to_non_nullable
as SpaceEntity,openDocument: freezed == openDocument ? _self.openDocument : openDocument // ignore: cast_nullable_to_non_nullable
as SpaceRelativePathValueObject?,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as DocumentModeEnum,git: freezed == git ? _self.git : git // ignore: cast_nullable_to_non_nullable
as GitStatusValueObject?,readingVersion: freezed == readingVersion ? _self.readingVersion : readingVersion // ignore: cast_nullable_to_non_nullable
as CommitEntity?,
  ));
}

/// Create a copy of SpaceSessionState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SpaceEntityCopyWith<$Res> get space {
  
  return $SpaceEntityCopyWith<$Res>(_self.space, (value) {
    return _then(_self.copyWith(space: value));
  });
}/// Create a copy of SpaceSessionState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GitStatusValueObjectCopyWith<$Res>? get git {
    if (_self.git == null) {
    return null;
  }

  return $GitStatusValueObjectCopyWith<$Res>(_self.git!, (value) {
    return _then(_self.copyWith(git: value));
  });
}/// Create a copy of SpaceSessionState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CommitEntityCopyWith<$Res>? get readingVersion {
    if (_self.readingVersion == null) {
    return null;
  }

  return $CommitEntityCopyWith<$Res>(_self.readingVersion!, (value) {
    return _then(_self.copyWith(readingVersion: value));
  });
}
}

// dart format on
