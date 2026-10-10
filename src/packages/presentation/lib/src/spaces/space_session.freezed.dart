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
/// none has been chosen — the state a space opens in, not an error.
///
/// Space-relative because that is what the app navigates in; git's
/// spelling is [SpaceEntity.toRepoRelative]'s to produce.
 SpaceRelativePathValueObject? get openDocument;/// A changed file of the repository outside the space, on screen in
/// [openDocument]'s place — never both set — or null.
///
/// A field of its own so every reader of [openDocument] (the tree's open
/// row, the index, history, export) sees no document without being told
/// (`docs/product/git-workflow/commit/opening-a-change/doc.md`).
 RepoRelativePathValueObject? get outsideDocument;/// The documents open as tabs, left to right; the one [onScreen] names is
/// one of them whenever it is set (`docs/product/editor/tabs/doc.md`).
///
/// A session's, not a repository's: what somebody has been in, which a
/// commit does not empty.
 List<DocumentTab> get tabs;/// The app's own file open as a tab — `preferences.json`, or
/// `git-approvals.json` beside it, one at a time — by its path in the
/// app's folder, never the space's; or null.
///
/// A tab after [tabs] rather than one of them, because what reads [tabs]
/// takes each for a file of the space or its repository; it is on screen
/// while [openDocument] is null ([isShowingPreferencesFile],
/// `docs/product/preferences/where-it-is-stored/doc.md`).
 SpaceRelativePathValueObject? get preferencesFile;/// The tab opened by a click and not yet kept — italic, and replaced by
/// the next click rather than joined by it — or null when every tab is
/// kept.
 DocumentTab? get previewTab;/// How the document area is being looked at; split is where a space
/// opens.
///
/// Here rather than in a panel because two things read it: the bar that
/// offers the modes and the shell that decides which panels to draw.
 DocumentModeEnum get mode;/// Where the repository stands, or null while nobody has read it yet.
///
/// A reading, not a subscription: stale as soon as anything writes to
/// disk, re-read after every operation that changes the tree. Shared so
/// the status bar and the changes panel draw from one answer.
 GitStatusValueObject? get git;/// The commit whose version of [openDocument] is being read, or null
/// when the working copy is.
///
/// The whole commit rather than its sha, because the bar names the
/// author and the date and a second lookup could disagree with the list.
 CommitEntity? get readingVersion;/// The branch the checked-out one came from and where it left it — the
/// working copy is compared at that fork point — or null for `HEAD`: on
/// that branch itself, when detached, or before anybody read it.
///
/// Nobody chooses it: `DiffBaseNotifier` reads it whenever git is read
/// (`docs/product/diff/branch-diff/doc.md`). Here because three things
/// read it: the preview, the label beside the `Diff` chip, and the pull
/// request's first base.
 DiffBaseValueObject? get comparingAgainst;/// Whether the preview decorates what changed, which it does until
/// somebody presses the `Diff` chip.
///
/// Here rather than in the preview because the chip that switches it is
/// in the bar and the marks are in the panel, and one of them has to
/// hold the answer. Off is a reading position, not a comparison: turning
/// the marks back on brings the same base back
/// (`docs/product/diff/rendered-diff/turning-it-off/doc.md`).
 bool get showingDiff;/// The merge a conflicted pull left behind, or null while nobody has
/// asked git.
///
/// Beside [git] because it is read in the same breath and drawn by the
/// same panels: the band says the pull stopped, the changes list counts
/// what is left to resolve, and the message box starts from the draft
/// git wrote. Read rather than remembered, so closing the window and
/// opening it again finds the same conflict
/// (`docs/product/git-workflow/push-pull/when-a-pull-conflicts/doc.md`).
 MergeStateValueObject? get merge;/// The branch whose pull request is being written, or null when the
/// document area is [openDocument]'s.
///
/// One more reading position beside [openDocument], the way
/// [readingVersion] is: set, the editor holds the branch's draft and the
/// tab strip gives way to the status row; the tabs keep what they hold
/// and come back as they were ([Decision
/// 33](../../../../../../docs/technical/decisions/033-a-pull-request-draft-is-a-document-outside-the-space.md)).
 BranchNameValueObject? get pullRequest;/// The branch the pull request is proposed onto, which starts at the
/// remote's own and is chosen in the right column.
///
/// Here and not in the column because the draft is seeded from it and
/// the status row reads it too.
 BranchNameValueObject? get pullRequestBase;
/// Create a copy of SpaceSessionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SpaceSessionStateCopyWith<SpaceSessionState> get copyWith => _$SpaceSessionStateCopyWithImpl<SpaceSessionState>(this as SpaceSessionState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SpaceSessionState&&(identical(other.space, space) || other.space == space)&&(identical(other.openDocument, openDocument) || other.openDocument == openDocument)&&(identical(other.outsideDocument, outsideDocument) || other.outsideDocument == outsideDocument)&&const DeepCollectionEquality().equals(other.tabs, tabs)&&(identical(other.preferencesFile, preferencesFile) || other.preferencesFile == preferencesFile)&&(identical(other.previewTab, previewTab) || other.previewTab == previewTab)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.git, git) || other.git == git)&&(identical(other.readingVersion, readingVersion) || other.readingVersion == readingVersion)&&(identical(other.comparingAgainst, comparingAgainst) || other.comparingAgainst == comparingAgainst)&&(identical(other.showingDiff, showingDiff) || other.showingDiff == showingDiff)&&(identical(other.merge, merge) || other.merge == merge)&&(identical(other.pullRequest, pullRequest) || other.pullRequest == pullRequest)&&(identical(other.pullRequestBase, pullRequestBase) || other.pullRequestBase == pullRequestBase));
}


@override
int get hashCode => Object.hash(runtimeType,space,openDocument,outsideDocument,const DeepCollectionEquality().hash(tabs),preferencesFile,previewTab,mode,git,readingVersion,comparingAgainst,showingDiff,merge,pullRequest,pullRequestBase);

@override
String toString() {
  return 'SpaceSessionState(space: $space, openDocument: $openDocument, outsideDocument: $outsideDocument, tabs: $tabs, preferencesFile: $preferencesFile, previewTab: $previewTab, mode: $mode, git: $git, readingVersion: $readingVersion, comparingAgainst: $comparingAgainst, showingDiff: $showingDiff, merge: $merge, pullRequest: $pullRequest, pullRequestBase: $pullRequestBase)';
}


}

/// @nodoc
abstract mixin class $SpaceSessionStateCopyWith<$Res>  {
  factory $SpaceSessionStateCopyWith(SpaceSessionState value, $Res Function(SpaceSessionState) _then) = _$SpaceSessionStateCopyWithImpl;
@useResult
$Res call({
 SpaceEntity space, SpaceRelativePathValueObject? openDocument, RepoRelativePathValueObject? outsideDocument, List<DocumentTab> tabs, SpaceRelativePathValueObject? preferencesFile, DocumentTab? previewTab, DocumentModeEnum mode, GitStatusValueObject? git, CommitEntity? readingVersion, DiffBaseValueObject? comparingAgainst, bool showingDiff, MergeStateValueObject? merge, BranchNameValueObject? pullRequest, BranchNameValueObject? pullRequestBase
});


$SpaceEntityCopyWith<$Res> get space;$DocumentTabCopyWith<$Res>? get previewTab;$GitStatusValueObjectCopyWith<$Res>? get git;$CommitEntityCopyWith<$Res>? get readingVersion;$DiffBaseValueObjectCopyWith<$Res>? get comparingAgainst;$MergeStateValueObjectCopyWith<$Res>? get merge;

}
/// @nodoc
class _$SpaceSessionStateCopyWithImpl<$Res>
    implements $SpaceSessionStateCopyWith<$Res> {
  _$SpaceSessionStateCopyWithImpl(this._self, this._then);

  final SpaceSessionState _self;
  final $Res Function(SpaceSessionState) _then;

/// Create a copy of SpaceSessionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? space = null,Object? openDocument = freezed,Object? outsideDocument = freezed,Object? tabs = null,Object? preferencesFile = freezed,Object? previewTab = freezed,Object? mode = null,Object? git = freezed,Object? readingVersion = freezed,Object? comparingAgainst = freezed,Object? showingDiff = null,Object? merge = freezed,Object? pullRequest = freezed,Object? pullRequestBase = freezed,}) {
  return _then(_self.copyWith(
space: null == space ? _self.space : space // ignore: cast_nullable_to_non_nullable
as SpaceEntity,openDocument: freezed == openDocument ? _self.openDocument : openDocument // ignore: cast_nullable_to_non_nullable
as SpaceRelativePathValueObject?,outsideDocument: freezed == outsideDocument ? _self.outsideDocument : outsideDocument // ignore: cast_nullable_to_non_nullable
as RepoRelativePathValueObject?,tabs: null == tabs ? _self.tabs : tabs // ignore: cast_nullable_to_non_nullable
as List<DocumentTab>,preferencesFile: freezed == preferencesFile ? _self.preferencesFile : preferencesFile // ignore: cast_nullable_to_non_nullable
as SpaceRelativePathValueObject?,previewTab: freezed == previewTab ? _self.previewTab : previewTab // ignore: cast_nullable_to_non_nullable
as DocumentTab?,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as DocumentModeEnum,git: freezed == git ? _self.git : git // ignore: cast_nullable_to_non_nullable
as GitStatusValueObject?,readingVersion: freezed == readingVersion ? _self.readingVersion : readingVersion // ignore: cast_nullable_to_non_nullable
as CommitEntity?,comparingAgainst: freezed == comparingAgainst ? _self.comparingAgainst : comparingAgainst // ignore: cast_nullable_to_non_nullable
as DiffBaseValueObject?,showingDiff: null == showingDiff ? _self.showingDiff : showingDiff // ignore: cast_nullable_to_non_nullable
as bool,merge: freezed == merge ? _self.merge : merge // ignore: cast_nullable_to_non_nullable
as MergeStateValueObject?,pullRequest: freezed == pullRequest ? _self.pullRequest : pullRequest // ignore: cast_nullable_to_non_nullable
as BranchNameValueObject?,pullRequestBase: freezed == pullRequestBase ? _self.pullRequestBase : pullRequestBase // ignore: cast_nullable_to_non_nullable
as BranchNameValueObject?,
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
$DocumentTabCopyWith<$Res>? get previewTab {
    if (_self.previewTab == null) {
    return null;
  }

  return $DocumentTabCopyWith<$Res>(_self.previewTab!, (value) {
    return _then(_self.copyWith(previewTab: value));
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
}/// Create a copy of SpaceSessionState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DiffBaseValueObjectCopyWith<$Res>? get comparingAgainst {
    if (_self.comparingAgainst == null) {
    return null;
  }

  return $DiffBaseValueObjectCopyWith<$Res>(_self.comparingAgainst!, (value) {
    return _then(_self.copyWith(comparingAgainst: value));
  });
}/// Create a copy of SpaceSessionState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MergeStateValueObjectCopyWith<$Res>? get merge {
    if (_self.merge == null) {
    return null;
  }

  return $MergeStateValueObjectCopyWith<$Res>(_self.merge!, (value) {
    return _then(_self.copyWith(merge: value));
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SpaceEntity space,  SpaceRelativePathValueObject? openDocument,  RepoRelativePathValueObject? outsideDocument,  List<DocumentTab> tabs,  SpaceRelativePathValueObject? preferencesFile,  DocumentTab? previewTab,  DocumentModeEnum mode,  GitStatusValueObject? git,  CommitEntity? readingVersion,  DiffBaseValueObject? comparingAgainst,  bool showingDiff,  MergeStateValueObject? merge,  BranchNameValueObject? pullRequest,  BranchNameValueObject? pullRequestBase)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SpaceSessionState() when $default != null:
return $default(_that.space,_that.openDocument,_that.outsideDocument,_that.tabs,_that.preferencesFile,_that.previewTab,_that.mode,_that.git,_that.readingVersion,_that.comparingAgainst,_that.showingDiff,_that.merge,_that.pullRequest,_that.pullRequestBase);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SpaceEntity space,  SpaceRelativePathValueObject? openDocument,  RepoRelativePathValueObject? outsideDocument,  List<DocumentTab> tabs,  SpaceRelativePathValueObject? preferencesFile,  DocumentTab? previewTab,  DocumentModeEnum mode,  GitStatusValueObject? git,  CommitEntity? readingVersion,  DiffBaseValueObject? comparingAgainst,  bool showingDiff,  MergeStateValueObject? merge,  BranchNameValueObject? pullRequest,  BranchNameValueObject? pullRequestBase)  $default,) {final _that = this;
switch (_that) {
case _SpaceSessionState():
return $default(_that.space,_that.openDocument,_that.outsideDocument,_that.tabs,_that.preferencesFile,_that.previewTab,_that.mode,_that.git,_that.readingVersion,_that.comparingAgainst,_that.showingDiff,_that.merge,_that.pullRequest,_that.pullRequestBase);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SpaceEntity space,  SpaceRelativePathValueObject? openDocument,  RepoRelativePathValueObject? outsideDocument,  List<DocumentTab> tabs,  SpaceRelativePathValueObject? preferencesFile,  DocumentTab? previewTab,  DocumentModeEnum mode,  GitStatusValueObject? git,  CommitEntity? readingVersion,  DiffBaseValueObject? comparingAgainst,  bool showingDiff,  MergeStateValueObject? merge,  BranchNameValueObject? pullRequest,  BranchNameValueObject? pullRequestBase)?  $default,) {final _that = this;
switch (_that) {
case _SpaceSessionState() when $default != null:
return $default(_that.space,_that.openDocument,_that.outsideDocument,_that.tabs,_that.preferencesFile,_that.previewTab,_that.mode,_that.git,_that.readingVersion,_that.comparingAgainst,_that.showingDiff,_that.merge,_that.pullRequest,_that.pullRequestBase);case _:
  return null;

}
}

}

/// @nodoc


class _SpaceSessionState extends SpaceSessionState {
  const _SpaceSessionState({required this.space, this.openDocument, this.outsideDocument, final  List<DocumentTab> tabs = const <DocumentTab>[], this.preferencesFile, this.previewTab, this.mode = DocumentModeEnum.split, this.git, this.readingVersion, this.comparingAgainst, this.showingDiff = true, this.merge, this.pullRequest, this.pullRequestBase}): _tabs = tabs,super._();
  

/// The folder the user opened, and the repository that encloses it.
@override final  SpaceEntity space;
/// The document the editor and the preview are showing, or null when
/// none has been chosen — the state a space opens in, not an error.
///
/// Space-relative because that is what the app navigates in; git's
/// spelling is [SpaceEntity.toRepoRelative]'s to produce.
@override final  SpaceRelativePathValueObject? openDocument;
/// A changed file of the repository outside the space, on screen in
/// [openDocument]'s place — never both set — or null.
///
/// A field of its own so every reader of [openDocument] (the tree's open
/// row, the index, history, export) sees no document without being told
/// (`docs/product/git-workflow/commit/opening-a-change/doc.md`).
@override final  RepoRelativePathValueObject? outsideDocument;
/// The documents open as tabs, left to right; the one [onScreen] names is
/// one of them whenever it is set (`docs/product/editor/tabs/doc.md`).
///
/// A session's, not a repository's: what somebody has been in, which a
/// commit does not empty.
 final  List<DocumentTab> _tabs;
/// The documents open as tabs, left to right; the one [onScreen] names is
/// one of them whenever it is set (`docs/product/editor/tabs/doc.md`).
///
/// A session's, not a repository's: what somebody has been in, which a
/// commit does not empty.
@override@JsonKey() List<DocumentTab> get tabs {
  if (_tabs is EqualUnmodifiableListView) return _tabs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tabs);
}

/// The app's own file open as a tab — `preferences.json`, or
/// `git-approvals.json` beside it, one at a time — by its path in the
/// app's folder, never the space's; or null.
///
/// A tab after [tabs] rather than one of them, because what reads [tabs]
/// takes each for a file of the space or its repository; it is on screen
/// while [openDocument] is null ([isShowingPreferencesFile],
/// `docs/product/preferences/where-it-is-stored/doc.md`).
@override final  SpaceRelativePathValueObject? preferencesFile;
/// The tab opened by a click and not yet kept — italic, and replaced by
/// the next click rather than joined by it — or null when every tab is
/// kept.
@override final  DocumentTab? previewTab;
/// How the document area is being looked at; split is where a space
/// opens.
///
/// Here rather than in a panel because two things read it: the bar that
/// offers the modes and the shell that decides which panels to draw.
@override@JsonKey() final  DocumentModeEnum mode;
/// Where the repository stands, or null while nobody has read it yet.
///
/// A reading, not a subscription: stale as soon as anything writes to
/// disk, re-read after every operation that changes the tree. Shared so
/// the status bar and the changes panel draw from one answer.
@override final  GitStatusValueObject? git;
/// The commit whose version of [openDocument] is being read, or null
/// when the working copy is.
///
/// The whole commit rather than its sha, because the bar names the
/// author and the date and a second lookup could disagree with the list.
@override final  CommitEntity? readingVersion;
/// The branch the checked-out one came from and where it left it — the
/// working copy is compared at that fork point — or null for `HEAD`: on
/// that branch itself, when detached, or before anybody read it.
///
/// Nobody chooses it: `DiffBaseNotifier` reads it whenever git is read
/// (`docs/product/diff/branch-diff/doc.md`). Here because three things
/// read it: the preview, the label beside the `Diff` chip, and the pull
/// request's first base.
@override final  DiffBaseValueObject? comparingAgainst;
/// Whether the preview decorates what changed, which it does until
/// somebody presses the `Diff` chip.
///
/// Here rather than in the preview because the chip that switches it is
/// in the bar and the marks are in the panel, and one of them has to
/// hold the answer. Off is a reading position, not a comparison: turning
/// the marks back on brings the same base back
/// (`docs/product/diff/rendered-diff/turning-it-off/doc.md`).
@override@JsonKey() final  bool showingDiff;
/// The merge a conflicted pull left behind, or null while nobody has
/// asked git.
///
/// Beside [git] because it is read in the same breath and drawn by the
/// same panels: the band says the pull stopped, the changes list counts
/// what is left to resolve, and the message box starts from the draft
/// git wrote. Read rather than remembered, so closing the window and
/// opening it again finds the same conflict
/// (`docs/product/git-workflow/push-pull/when-a-pull-conflicts/doc.md`).
@override final  MergeStateValueObject? merge;
/// The branch whose pull request is being written, or null when the
/// document area is [openDocument]'s.
///
/// One more reading position beside [openDocument], the way
/// [readingVersion] is: set, the editor holds the branch's draft and the
/// tab strip gives way to the status row; the tabs keep what they hold
/// and come back as they were ([Decision
/// 33](../../../../../../docs/technical/decisions/033-a-pull-request-draft-is-a-document-outside-the-space.md)).
@override final  BranchNameValueObject? pullRequest;
/// The branch the pull request is proposed onto, which starts at the
/// remote's own and is chosen in the right column.
///
/// Here and not in the column because the draft is seeded from it and
/// the status row reads it too.
@override final  BranchNameValueObject? pullRequestBase;

/// Create a copy of SpaceSessionState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SpaceSessionStateCopyWith<_SpaceSessionState> get copyWith => __$SpaceSessionStateCopyWithImpl<_SpaceSessionState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SpaceSessionState&&(identical(other.space, space) || other.space == space)&&(identical(other.openDocument, openDocument) || other.openDocument == openDocument)&&(identical(other.outsideDocument, outsideDocument) || other.outsideDocument == outsideDocument)&&const DeepCollectionEquality().equals(other._tabs, _tabs)&&(identical(other.preferencesFile, preferencesFile) || other.preferencesFile == preferencesFile)&&(identical(other.previewTab, previewTab) || other.previewTab == previewTab)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.git, git) || other.git == git)&&(identical(other.readingVersion, readingVersion) || other.readingVersion == readingVersion)&&(identical(other.comparingAgainst, comparingAgainst) || other.comparingAgainst == comparingAgainst)&&(identical(other.showingDiff, showingDiff) || other.showingDiff == showingDiff)&&(identical(other.merge, merge) || other.merge == merge)&&(identical(other.pullRequest, pullRequest) || other.pullRequest == pullRequest)&&(identical(other.pullRequestBase, pullRequestBase) || other.pullRequestBase == pullRequestBase));
}


@override
int get hashCode => Object.hash(runtimeType,space,openDocument,outsideDocument,const DeepCollectionEquality().hash(_tabs),preferencesFile,previewTab,mode,git,readingVersion,comparingAgainst,showingDiff,merge,pullRequest,pullRequestBase);

@override
String toString() {
  return 'SpaceSessionState(space: $space, openDocument: $openDocument, outsideDocument: $outsideDocument, tabs: $tabs, preferencesFile: $preferencesFile, previewTab: $previewTab, mode: $mode, git: $git, readingVersion: $readingVersion, comparingAgainst: $comparingAgainst, showingDiff: $showingDiff, merge: $merge, pullRequest: $pullRequest, pullRequestBase: $pullRequestBase)';
}


}

/// @nodoc
abstract mixin class _$SpaceSessionStateCopyWith<$Res> implements $SpaceSessionStateCopyWith<$Res> {
  factory _$SpaceSessionStateCopyWith(_SpaceSessionState value, $Res Function(_SpaceSessionState) _then) = __$SpaceSessionStateCopyWithImpl;
@override @useResult
$Res call({
 SpaceEntity space, SpaceRelativePathValueObject? openDocument, RepoRelativePathValueObject? outsideDocument, List<DocumentTab> tabs, SpaceRelativePathValueObject? preferencesFile, DocumentTab? previewTab, DocumentModeEnum mode, GitStatusValueObject? git, CommitEntity? readingVersion, DiffBaseValueObject? comparingAgainst, bool showingDiff, MergeStateValueObject? merge, BranchNameValueObject? pullRequest, BranchNameValueObject? pullRequestBase
});


@override $SpaceEntityCopyWith<$Res> get space;@override $DocumentTabCopyWith<$Res>? get previewTab;@override $GitStatusValueObjectCopyWith<$Res>? get git;@override $CommitEntityCopyWith<$Res>? get readingVersion;@override $DiffBaseValueObjectCopyWith<$Res>? get comparingAgainst;@override $MergeStateValueObjectCopyWith<$Res>? get merge;

}
/// @nodoc
class __$SpaceSessionStateCopyWithImpl<$Res>
    implements _$SpaceSessionStateCopyWith<$Res> {
  __$SpaceSessionStateCopyWithImpl(this._self, this._then);

  final _SpaceSessionState _self;
  final $Res Function(_SpaceSessionState) _then;

/// Create a copy of SpaceSessionState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? space = null,Object? openDocument = freezed,Object? outsideDocument = freezed,Object? tabs = null,Object? preferencesFile = freezed,Object? previewTab = freezed,Object? mode = null,Object? git = freezed,Object? readingVersion = freezed,Object? comparingAgainst = freezed,Object? showingDiff = null,Object? merge = freezed,Object? pullRequest = freezed,Object? pullRequestBase = freezed,}) {
  return _then(_SpaceSessionState(
space: null == space ? _self.space : space // ignore: cast_nullable_to_non_nullable
as SpaceEntity,openDocument: freezed == openDocument ? _self.openDocument : openDocument // ignore: cast_nullable_to_non_nullable
as SpaceRelativePathValueObject?,outsideDocument: freezed == outsideDocument ? _self.outsideDocument : outsideDocument // ignore: cast_nullable_to_non_nullable
as RepoRelativePathValueObject?,tabs: null == tabs ? _self._tabs : tabs // ignore: cast_nullable_to_non_nullable
as List<DocumentTab>,preferencesFile: freezed == preferencesFile ? _self.preferencesFile : preferencesFile // ignore: cast_nullable_to_non_nullable
as SpaceRelativePathValueObject?,previewTab: freezed == previewTab ? _self.previewTab : previewTab // ignore: cast_nullable_to_non_nullable
as DocumentTab?,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as DocumentModeEnum,git: freezed == git ? _self.git : git // ignore: cast_nullable_to_non_nullable
as GitStatusValueObject?,readingVersion: freezed == readingVersion ? _self.readingVersion : readingVersion // ignore: cast_nullable_to_non_nullable
as CommitEntity?,comparingAgainst: freezed == comparingAgainst ? _self.comparingAgainst : comparingAgainst // ignore: cast_nullable_to_non_nullable
as DiffBaseValueObject?,showingDiff: null == showingDiff ? _self.showingDiff : showingDiff // ignore: cast_nullable_to_non_nullable
as bool,merge: freezed == merge ? _self.merge : merge // ignore: cast_nullable_to_non_nullable
as MergeStateValueObject?,pullRequest: freezed == pullRequest ? _self.pullRequest : pullRequest // ignore: cast_nullable_to_non_nullable
as BranchNameValueObject?,pullRequestBase: freezed == pullRequestBase ? _self.pullRequestBase : pullRequestBase // ignore: cast_nullable_to_non_nullable
as BranchNameValueObject?,
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
$DocumentTabCopyWith<$Res>? get previewTab {
    if (_self.previewTab == null) {
    return null;
  }

  return $DocumentTabCopyWith<$Res>(_self.previewTab!, (value) {
    return _then(_self.copyWith(previewTab: value));
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
}/// Create a copy of SpaceSessionState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DiffBaseValueObjectCopyWith<$Res>? get comparingAgainst {
    if (_self.comparingAgainst == null) {
    return null;
  }

  return $DiffBaseValueObjectCopyWith<$Res>(_self.comparingAgainst!, (value) {
    return _then(_self.copyWith(comparingAgainst: value));
  });
}/// Create a copy of SpaceSessionState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MergeStateValueObjectCopyWith<$Res>? get merge {
    if (_self.merge == null) {
    return null;
  }

  return $MergeStateValueObjectCopyWith<$Res>(_self.merge!, (value) {
    return _then(_self.copyWith(merge: value));
  });
}
}

// dart format on
