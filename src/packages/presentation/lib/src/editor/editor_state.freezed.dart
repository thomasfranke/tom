// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'editor_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EditorState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EditorState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'EditorState()';
}


}

/// @nodoc
class $EditorStateCopyWith<$Res>  {
$EditorStateCopyWith(EditorState _, $Res Function(EditorState) __);
}


/// Adds pattern-matching-related methods to [EditorState].
extension EditorStatePatterns on EditorState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( EditorEmpty value)?  empty,TResult Function( EditorLoading value)?  loading,TResult Function( EditorReady value)?  ready,TResult Function( EditorFailed value)?  failed,required TResult orElse(),}){
final _that = this;
switch (_that) {
case EditorEmpty() when empty != null:
return empty(_that);case EditorLoading() when loading != null:
return loading(_that);case EditorReady() when ready != null:
return ready(_that);case EditorFailed() when failed != null:
return failed(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( EditorEmpty value)  empty,required TResult Function( EditorLoading value)  loading,required TResult Function( EditorReady value)  ready,required TResult Function( EditorFailed value)  failed,}){
final _that = this;
switch (_that) {
case EditorEmpty():
return empty(_that);case EditorLoading():
return loading(_that);case EditorReady():
return ready(_that);case EditorFailed():
return failed(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( EditorEmpty value)?  empty,TResult? Function( EditorLoading value)?  loading,TResult? Function( EditorReady value)?  ready,TResult? Function( EditorFailed value)?  failed,}){
final _that = this;
switch (_that) {
case EditorEmpty() when empty != null:
return empty(_that);case EditorLoading() when loading != null:
return loading(_that);case EditorReady() when ready != null:
return ready(_that);case EditorFailed() when failed != null:
return failed(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  empty,TResult Function()?  loading,TResult Function( DocumentEntity saved,  String source,  int selectionStart,  int selectionEnd,  int reveals,  bool isSaving,  AppFailure? saveFailure,  bool isDraft,  bool isPreferences,  bool isOutside,  bool isDeleted,  bool isBinary,  bool changedOnDisk,  bool overwritesDisk)?  ready,TResult Function( AppFailure failure)?  failed,required TResult orElse(),}) {final _that = this;
switch (_that) {
case EditorEmpty() when empty != null:
return empty();case EditorLoading() when loading != null:
return loading();case EditorReady() when ready != null:
return ready(_that.saved,_that.source,_that.selectionStart,_that.selectionEnd,_that.reveals,_that.isSaving,_that.saveFailure,_that.isDraft,_that.isPreferences,_that.isOutside,_that.isDeleted,_that.isBinary,_that.changedOnDisk,_that.overwritesDisk);case EditorFailed() when failed != null:
return failed(_that.failure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  empty,required TResult Function()  loading,required TResult Function( DocumentEntity saved,  String source,  int selectionStart,  int selectionEnd,  int reveals,  bool isSaving,  AppFailure? saveFailure,  bool isDraft,  bool isPreferences,  bool isOutside,  bool isDeleted,  bool isBinary,  bool changedOnDisk,  bool overwritesDisk)  ready,required TResult Function( AppFailure failure)  failed,}) {final _that = this;
switch (_that) {
case EditorEmpty():
return empty();case EditorLoading():
return loading();case EditorReady():
return ready(_that.saved,_that.source,_that.selectionStart,_that.selectionEnd,_that.reveals,_that.isSaving,_that.saveFailure,_that.isDraft,_that.isPreferences,_that.isOutside,_that.isDeleted,_that.isBinary,_that.changedOnDisk,_that.overwritesDisk);case EditorFailed():
return failed(_that.failure);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  empty,TResult? Function()?  loading,TResult? Function( DocumentEntity saved,  String source,  int selectionStart,  int selectionEnd,  int reveals,  bool isSaving,  AppFailure? saveFailure,  bool isDraft,  bool isPreferences,  bool isOutside,  bool isDeleted,  bool isBinary,  bool changedOnDisk,  bool overwritesDisk)?  ready,TResult? Function( AppFailure failure)?  failed,}) {final _that = this;
switch (_that) {
case EditorEmpty() when empty != null:
return empty();case EditorLoading() when loading != null:
return loading();case EditorReady() when ready != null:
return ready(_that.saved,_that.source,_that.selectionStart,_that.selectionEnd,_that.reveals,_that.isSaving,_that.saveFailure,_that.isDraft,_that.isPreferences,_that.isOutside,_that.isDeleted,_that.isBinary,_that.changedOnDisk,_that.overwritesDisk);case EditorFailed() when failed != null:
return failed(_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class EditorEmpty extends EditorState {
  const EditorEmpty(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EditorEmpty);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'EditorState.empty()';
}


}




/// @nodoc


class EditorLoading extends EditorState {
  const EditorLoading(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EditorLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'EditorState.loading()';
}


}




/// @nodoc


class EditorReady extends EditorState {
  const EditorReady({required this.saved, required this.source, this.selectionStart = 0, this.selectionEnd = 0, this.reveals = 0, this.isSaving = false, this.saveFailure, this.isDraft = false, this.isPreferences = false, this.isOutside = false, this.isDeleted = false, this.isBinary = false, this.changedOnDisk = false, this.overwritesDisk = false}): super._();
  

/// The document as the disk last agreed it was — what the buffer is
/// compared against, and what a save replaces.
 final  DocumentEntity saved;
/// The text being edited, which is the file's content until it is not.
 final  String source;
/// Where the caret is, as an offset into the buffer.
///
/// Here because the toolbar is not inside the pane: a button that bolds
/// the selection has to know what is selected, and the row sits above
/// the document rather than in it
/// (`docs/product/editor/formatting-shortcuts/doc.md`).
@JsonKey() final  int selectionStart;
/// Where it ends, exclusive; equal to the start for a caret.
@JsonKey() final  int selectionEnd;
/// How many times somebody asked the pane to go to the selection — a
/// click on a search occurrence. A count and not a flag, so asking for
/// the same place twice still moves a pane that was scrolled away.
@JsonKey() final  int reveals;
/// Whether a write is in flight.
@JsonKey() final  bool isSaving;
/// Why the last save did not land, or null when it did.
///
/// Said rather than swallowed, because the buffer still holds work and
/// the file does not.
 final  AppFailure? saveFailure;
/// Whether this is a pull request draft rather than a document of the
/// space — `saved`'s path is then the draft's, under `.git/tom/`, and
/// nothing that reads the space (the index, the diff, the tabs) may
/// take it for one of its own (Decision 33).
@JsonKey() final  bool isDraft;
/// Whether this is the app's preferences file — JSON in the app's own
/// folder, so nothing that reads the space may take it for one of its
/// documents, nothing formats it as markdown, and saving it applies it
/// (`docs/product/preferences/where-it-is-stored/doc.md`).
@JsonKey() final  bool isPreferences;
/// Whether this is a changed file of the repository outside the space —
/// `saved`'s path is then relative to the repository root, read and
/// written through `SpaceEntity.repositorySpace`, and the index never
/// files it (`docs/product/git-workflow/commit/opening-a-change/doc.md`).
@JsonKey() final  bool isOutside;
/// Whether the file is gone from the disk and the buffer holds its last
/// committed version — read-only, every line and block marked removed,
/// and the tab saying so
/// (`docs/product/git-workflow/commit/opening-a-change/doc.md`).
@JsonKey() final  bool isDeleted;
/// Whether the file is not text — a zero byte in its first 8 KB, or not
/// UTF-8 — so nothing of it was loaded and the tab says so instead.
@JsonKey() final  bool isBinary;
/// Whether the file changed on disk under this buffer's unsaved edits —
/// found by a save that asked first, or a choice in the popover for the
/// preferences file — so the tab asks `Reload` or `Keep mine` rather
/// than choosing for the person.
@JsonKey() final  bool changedOnDisk;
/// Whether `Keep mine` was the answer: the next save writes over what
/// the disk holds without asking again, and takes this back.
@JsonKey() final  bool overwritesDisk;

/// Create a copy of EditorState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EditorReadyCopyWith<EditorReady> get copyWith => _$EditorReadyCopyWithImpl<EditorReady>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EditorReady&&(identical(other.saved, saved) || other.saved == saved)&&(identical(other.source, source) || other.source == source)&&(identical(other.selectionStart, selectionStart) || other.selectionStart == selectionStart)&&(identical(other.selectionEnd, selectionEnd) || other.selectionEnd == selectionEnd)&&(identical(other.reveals, reveals) || other.reveals == reveals)&&(identical(other.isSaving, isSaving) || other.isSaving == isSaving)&&(identical(other.saveFailure, saveFailure) || other.saveFailure == saveFailure)&&(identical(other.isDraft, isDraft) || other.isDraft == isDraft)&&(identical(other.isPreferences, isPreferences) || other.isPreferences == isPreferences)&&(identical(other.isOutside, isOutside) || other.isOutside == isOutside)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&(identical(other.isBinary, isBinary) || other.isBinary == isBinary)&&(identical(other.changedOnDisk, changedOnDisk) || other.changedOnDisk == changedOnDisk)&&(identical(other.overwritesDisk, overwritesDisk) || other.overwritesDisk == overwritesDisk));
}


@override
int get hashCode => Object.hash(runtimeType,saved,source,selectionStart,selectionEnd,reveals,isSaving,saveFailure,isDraft,isPreferences,isOutside,isDeleted,isBinary,changedOnDisk,overwritesDisk);

@override
String toString() {
  return 'EditorState.ready(saved: $saved, source: $source, selectionStart: $selectionStart, selectionEnd: $selectionEnd, reveals: $reveals, isSaving: $isSaving, saveFailure: $saveFailure, isDraft: $isDraft, isPreferences: $isPreferences, isOutside: $isOutside, isDeleted: $isDeleted, isBinary: $isBinary, changedOnDisk: $changedOnDisk, overwritesDisk: $overwritesDisk)';
}


}

/// @nodoc
abstract mixin class $EditorReadyCopyWith<$Res> implements $EditorStateCopyWith<$Res> {
  factory $EditorReadyCopyWith(EditorReady value, $Res Function(EditorReady) _then) = _$EditorReadyCopyWithImpl;
@useResult
$Res call({
 DocumentEntity saved, String source, int selectionStart, int selectionEnd, int reveals, bool isSaving, AppFailure? saveFailure, bool isDraft, bool isPreferences, bool isOutside, bool isDeleted, bool isBinary, bool changedOnDisk, bool overwritesDisk
});


$DocumentEntityCopyWith<$Res> get saved;

}
/// @nodoc
class _$EditorReadyCopyWithImpl<$Res>
    implements $EditorReadyCopyWith<$Res> {
  _$EditorReadyCopyWithImpl(this._self, this._then);

  final EditorReady _self;
  final $Res Function(EditorReady) _then;

/// Create a copy of EditorState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? saved = null,Object? source = null,Object? selectionStart = null,Object? selectionEnd = null,Object? reveals = null,Object? isSaving = null,Object? saveFailure = freezed,Object? isDraft = null,Object? isPreferences = null,Object? isOutside = null,Object? isDeleted = null,Object? isBinary = null,Object? changedOnDisk = null,Object? overwritesDisk = null,}) {
  return _then(EditorReady(
saved: null == saved ? _self.saved : saved // ignore: cast_nullable_to_non_nullable
as DocumentEntity,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,selectionStart: null == selectionStart ? _self.selectionStart : selectionStart // ignore: cast_nullable_to_non_nullable
as int,selectionEnd: null == selectionEnd ? _self.selectionEnd : selectionEnd // ignore: cast_nullable_to_non_nullable
as int,reveals: null == reveals ? _self.reveals : reveals // ignore: cast_nullable_to_non_nullable
as int,isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,saveFailure: freezed == saveFailure ? _self.saveFailure : saveFailure // ignore: cast_nullable_to_non_nullable
as AppFailure?,isDraft: null == isDraft ? _self.isDraft : isDraft // ignore: cast_nullable_to_non_nullable
as bool,isPreferences: null == isPreferences ? _self.isPreferences : isPreferences // ignore: cast_nullable_to_non_nullable
as bool,isOutside: null == isOutside ? _self.isOutside : isOutside // ignore: cast_nullable_to_non_nullable
as bool,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,isBinary: null == isBinary ? _self.isBinary : isBinary // ignore: cast_nullable_to_non_nullable
as bool,changedOnDisk: null == changedOnDisk ? _self.changedOnDisk : changedOnDisk // ignore: cast_nullable_to_non_nullable
as bool,overwritesDisk: null == overwritesDisk ? _self.overwritesDisk : overwritesDisk // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of EditorState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DocumentEntityCopyWith<$Res> get saved {
  
  return $DocumentEntityCopyWith<$Res>(_self.saved, (value) {
    return _then(_self.copyWith(saved: value));
  });
}
}

/// @nodoc


class EditorFailed extends EditorState {
  const EditorFailed(this.failure): super._();
  

 final  AppFailure failure;

/// Create a copy of EditorState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EditorFailedCopyWith<EditorFailed> get copyWith => _$EditorFailedCopyWithImpl<EditorFailed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EditorFailed&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,failure);

@override
String toString() {
  return 'EditorState.failed(failure: $failure)';
}


}

/// @nodoc
abstract mixin class $EditorFailedCopyWith<$Res> implements $EditorStateCopyWith<$Res> {
  factory $EditorFailedCopyWith(EditorFailed value, $Res Function(EditorFailed) _then) = _$EditorFailedCopyWithImpl;
@useResult
$Res call({
 AppFailure failure
});




}
/// @nodoc
class _$EditorFailedCopyWithImpl<$Res>
    implements $EditorFailedCopyWith<$Res> {
  _$EditorFailedCopyWithImpl(this._self, this._then);

  final EditorFailed _self;
  final $Res Function(EditorFailed) _then;

/// Create a copy of EditorState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? failure = null,}) {
  return _then(EditorFailed(
null == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as AppFailure,
  ));
}


}

// dart format on
