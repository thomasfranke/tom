// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'file_tree_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FileTreeState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FileTreeState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'FileTreeState()';
}


}

/// @nodoc
class $FileTreeStateCopyWith<$Res>  {
$FileTreeStateCopyWith(FileTreeState _, $Res Function(FileTreeState) __);
}


/// Adds pattern-matching-related methods to [FileTreeState].
extension FileTreeStatePatterns on FileTreeState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( FileTreeInitial value)?  initial,TResult Function( FileTreeLoading value)?  loading,TResult Function( FileTreeReady value)?  ready,TResult Function( FileTreeFailed value)?  failed,required TResult orElse(),}){
final _that = this;
switch (_that) {
case FileTreeInitial() when initial != null:
return initial(_that);case FileTreeLoading() when loading != null:
return loading(_that);case FileTreeReady() when ready != null:
return ready(_that);case FileTreeFailed() when failed != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( FileTreeInitial value)  initial,required TResult Function( FileTreeLoading value)  loading,required TResult Function( FileTreeReady value)  ready,required TResult Function( FileTreeFailed value)  failed,}){
final _that = this;
switch (_that) {
case FileTreeInitial():
return initial(_that);case FileTreeLoading():
return loading(_that);case FileTreeReady():
return ready(_that);case FileTreeFailed():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( FileTreeInitial value)?  initial,TResult? Function( FileTreeLoading value)?  loading,TResult? Function( FileTreeReady value)?  ready,TResult? Function( FileTreeFailed value)?  failed,}){
final _that = this;
switch (_that) {
case FileTreeInitial() when initial != null:
return initial(_that);case FileTreeLoading() when loading != null:
return loading(_that);case FileTreeReady() when ready != null:
return ready(_that);case FileTreeFailed() when failed != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( List<SpaceEntryValueObject> entries,  Set<SpaceRelativePathValueObject> collapsed,  NewEntryDraft? draft)?  ready,TResult Function( AppFailure failure)?  failed,required TResult orElse(),}) {final _that = this;
switch (_that) {
case FileTreeInitial() when initial != null:
return initial();case FileTreeLoading() when loading != null:
return loading();case FileTreeReady() when ready != null:
return ready(_that.entries,_that.collapsed,_that.draft);case FileTreeFailed() when failed != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( List<SpaceEntryValueObject> entries,  Set<SpaceRelativePathValueObject> collapsed,  NewEntryDraft? draft)  ready,required TResult Function( AppFailure failure)  failed,}) {final _that = this;
switch (_that) {
case FileTreeInitial():
return initial();case FileTreeLoading():
return loading();case FileTreeReady():
return ready(_that.entries,_that.collapsed,_that.draft);case FileTreeFailed():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( List<SpaceEntryValueObject> entries,  Set<SpaceRelativePathValueObject> collapsed,  NewEntryDraft? draft)?  ready,TResult? Function( AppFailure failure)?  failed,}) {final _that = this;
switch (_that) {
case FileTreeInitial() when initial != null:
return initial();case FileTreeLoading() when loading != null:
return loading();case FileTreeReady() when ready != null:
return ready(_that.entries,_that.collapsed,_that.draft);case FileTreeFailed() when failed != null:
return failed(_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class FileTreeInitial implements FileTreeState {
  const FileTreeInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FileTreeInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'FileTreeState.initial()';
}


}




/// @nodoc


class FileTreeLoading implements FileTreeState {
  const FileTreeLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FileTreeLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'FileTreeState.loading()';
}


}




/// @nodoc


class FileTreeReady implements FileTreeState {
  const FileTreeReady({required final  List<SpaceEntryValueObject> entries, required final  Set<SpaceRelativePathValueObject> collapsed, this.draft}): _entries = entries,_collapsed = collapsed;
  

/// Everything the space holds, in the order a tree shows it.
///
/// The whole space rather than one level, so expanding a folder is a
/// filter over a list. Handed over unmodifiable, never copied: Freezed
/// compares collections element-wise and copies nothing.
 final  List<SpaceEntryValueObject> _entries;
/// Everything the space holds, in the order a tree shows it.
///
/// The whole space rather than one level, so expanding a folder is a
/// filter over a list. Handed over unmodifiable, never copied: Freezed
/// compares collections element-wise and copies nothing.
 List<SpaceEntryValueObject> get entries {
  if (_entries is EqualUnmodifiableListView) return _entries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_entries);
}

/// The folders the user has closed — closed rather than open, so a
/// space opens showing what it holds.
 final  Set<SpaceRelativePathValueObject> _collapsed;
/// The folders the user has closed — closed rather than open, so a
/// space opens showing what it holds.
 Set<SpaceRelativePathValueObject> get collapsed {
  if (_collapsed is EqualUnmodifiableSetView) return _collapsed;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_collapsed);
}

/// A document or folder being named in the tree, or null when none is
/// (`docs/product/navigation/file-tree/new-document/doc.md`).
 final  NewEntryDraft? draft;

/// Create a copy of FileTreeState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FileTreeReadyCopyWith<FileTreeReady> get copyWith => _$FileTreeReadyCopyWithImpl<FileTreeReady>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FileTreeReady&&const DeepCollectionEquality().equals(other._entries, _entries)&&const DeepCollectionEquality().equals(other._collapsed, _collapsed)&&(identical(other.draft, draft) || other.draft == draft));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_entries),const DeepCollectionEquality().hash(_collapsed),draft);

@override
String toString() {
  return 'FileTreeState.ready(entries: $entries, collapsed: $collapsed, draft: $draft)';
}


}

/// @nodoc
abstract mixin class $FileTreeReadyCopyWith<$Res> implements $FileTreeStateCopyWith<$Res> {
  factory $FileTreeReadyCopyWith(FileTreeReady value, $Res Function(FileTreeReady) _then) = _$FileTreeReadyCopyWithImpl;
@useResult
$Res call({
 List<SpaceEntryValueObject> entries, Set<SpaceRelativePathValueObject> collapsed, NewEntryDraft? draft
});


$NewEntryDraftCopyWith<$Res>? get draft;

}
/// @nodoc
class _$FileTreeReadyCopyWithImpl<$Res>
    implements $FileTreeReadyCopyWith<$Res> {
  _$FileTreeReadyCopyWithImpl(this._self, this._then);

  final FileTreeReady _self;
  final $Res Function(FileTreeReady) _then;

/// Create a copy of FileTreeState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? entries = null,Object? collapsed = null,Object? draft = freezed,}) {
  return _then(FileTreeReady(
entries: null == entries ? _self._entries : entries // ignore: cast_nullable_to_non_nullable
as List<SpaceEntryValueObject>,collapsed: null == collapsed ? _self._collapsed : collapsed // ignore: cast_nullable_to_non_nullable
as Set<SpaceRelativePathValueObject>,draft: freezed == draft ? _self.draft : draft // ignore: cast_nullable_to_non_nullable
as NewEntryDraft?,
  ));
}

/// Create a copy of FileTreeState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NewEntryDraftCopyWith<$Res>? get draft {
    if (_self.draft == null) {
    return null;
  }

  return $NewEntryDraftCopyWith<$Res>(_self.draft!, (value) {
    return _then(_self.copyWith(draft: value));
  });
}
}

/// @nodoc


class FileTreeFailed implements FileTreeState {
  const FileTreeFailed(this.failure);
  

 final  AppFailure failure;

/// Create a copy of FileTreeState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FileTreeFailedCopyWith<FileTreeFailed> get copyWith => _$FileTreeFailedCopyWithImpl<FileTreeFailed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FileTreeFailed&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,failure);

@override
String toString() {
  return 'FileTreeState.failed(failure: $failure)';
}


}

/// @nodoc
abstract mixin class $FileTreeFailedCopyWith<$Res> implements $FileTreeStateCopyWith<$Res> {
  factory $FileTreeFailedCopyWith(FileTreeFailed value, $Res Function(FileTreeFailed) _then) = _$FileTreeFailedCopyWithImpl;
@useResult
$Res call({
 AppFailure failure
});




}
/// @nodoc
class _$FileTreeFailedCopyWithImpl<$Res>
    implements $FileTreeFailedCopyWith<$Res> {
  _$FileTreeFailedCopyWithImpl(this._self, this._then);

  final FileTreeFailed _self;
  final $Res Function(FileTreeFailed) _then;

/// Create a copy of FileTreeState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? failure = null,}) {
  return _then(FileTreeFailed(
null == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as AppFailure,
  ));
}


}

/// @nodoc
mixin _$NewEntryDraft {

/// The folder the entry goes into; null for the space's root.
 SpaceRelativePathValueObject? get folder;/// Whether a folder is being named — the menu's `New folder` — rather
/// than a document.
 bool get isFolder;/// Why the last name typed was refused, or null before one was.
///
/// Kept on the draft so the row stays where it is and says so in place.
 AppFailure? get refused;
/// Create a copy of NewEntryDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NewEntryDraftCopyWith<NewEntryDraft> get copyWith => _$NewEntryDraftCopyWithImpl<NewEntryDraft>(this as NewEntryDraft, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NewEntryDraft&&(identical(other.folder, folder) || other.folder == folder)&&(identical(other.isFolder, isFolder) || other.isFolder == isFolder)&&(identical(other.refused, refused) || other.refused == refused));
}


@override
int get hashCode => Object.hash(runtimeType,folder,isFolder,refused);

@override
String toString() {
  return 'NewEntryDraft(folder: $folder, isFolder: $isFolder, refused: $refused)';
}


}

/// @nodoc
abstract mixin class $NewEntryDraftCopyWith<$Res>  {
  factory $NewEntryDraftCopyWith(NewEntryDraft value, $Res Function(NewEntryDraft) _then) = _$NewEntryDraftCopyWithImpl;
@useResult
$Res call({
 SpaceRelativePathValueObject? folder, bool isFolder, AppFailure? refused
});




}
/// @nodoc
class _$NewEntryDraftCopyWithImpl<$Res>
    implements $NewEntryDraftCopyWith<$Res> {
  _$NewEntryDraftCopyWithImpl(this._self, this._then);

  final NewEntryDraft _self;
  final $Res Function(NewEntryDraft) _then;

/// Create a copy of NewEntryDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? folder = freezed,Object? isFolder = null,Object? refused = freezed,}) {
  return _then(_self.copyWith(
folder: freezed == folder ? _self.folder : folder // ignore: cast_nullable_to_non_nullable
as SpaceRelativePathValueObject?,isFolder: null == isFolder ? _self.isFolder : isFolder // ignore: cast_nullable_to_non_nullable
as bool,refused: freezed == refused ? _self.refused : refused // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}

}


/// Adds pattern-matching-related methods to [NewEntryDraft].
extension NewEntryDraftPatterns on NewEntryDraft {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NewEntryDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NewEntryDraft() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NewEntryDraft value)  $default,){
final _that = this;
switch (_that) {
case _NewEntryDraft():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NewEntryDraft value)?  $default,){
final _that = this;
switch (_that) {
case _NewEntryDraft() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SpaceRelativePathValueObject? folder,  bool isFolder,  AppFailure? refused)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NewEntryDraft() when $default != null:
return $default(_that.folder,_that.isFolder,_that.refused);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SpaceRelativePathValueObject? folder,  bool isFolder,  AppFailure? refused)  $default,) {final _that = this;
switch (_that) {
case _NewEntryDraft():
return $default(_that.folder,_that.isFolder,_that.refused);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SpaceRelativePathValueObject? folder,  bool isFolder,  AppFailure? refused)?  $default,) {final _that = this;
switch (_that) {
case _NewEntryDraft() when $default != null:
return $default(_that.folder,_that.isFolder,_that.refused);case _:
  return null;

}
}

}

/// @nodoc


class _NewEntryDraft implements NewEntryDraft {
  const _NewEntryDraft({this.folder, this.isFolder = false, this.refused});
  

/// The folder the entry goes into; null for the space's root.
@override final  SpaceRelativePathValueObject? folder;
/// Whether a folder is being named — the menu's `New folder` — rather
/// than a document.
@override@JsonKey() final  bool isFolder;
/// Why the last name typed was refused, or null before one was.
///
/// Kept on the draft so the row stays where it is and says so in place.
@override final  AppFailure? refused;

/// Create a copy of NewEntryDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NewEntryDraftCopyWith<_NewEntryDraft> get copyWith => __$NewEntryDraftCopyWithImpl<_NewEntryDraft>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NewEntryDraft&&(identical(other.folder, folder) || other.folder == folder)&&(identical(other.isFolder, isFolder) || other.isFolder == isFolder)&&(identical(other.refused, refused) || other.refused == refused));
}


@override
int get hashCode => Object.hash(runtimeType,folder,isFolder,refused);

@override
String toString() {
  return 'NewEntryDraft(folder: $folder, isFolder: $isFolder, refused: $refused)';
}


}

/// @nodoc
abstract mixin class _$NewEntryDraftCopyWith<$Res> implements $NewEntryDraftCopyWith<$Res> {
  factory _$NewEntryDraftCopyWith(_NewEntryDraft value, $Res Function(_NewEntryDraft) _then) = __$NewEntryDraftCopyWithImpl;
@override @useResult
$Res call({
 SpaceRelativePathValueObject? folder, bool isFolder, AppFailure? refused
});




}
/// @nodoc
class __$NewEntryDraftCopyWithImpl<$Res>
    implements _$NewEntryDraftCopyWith<$Res> {
  __$NewEntryDraftCopyWithImpl(this._self, this._then);

  final _NewEntryDraft _self;
  final $Res Function(_NewEntryDraft) _then;

/// Create a copy of NewEntryDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? folder = freezed,Object? isFolder = null,Object? refused = freezed,}) {
  return _then(_NewEntryDraft(
folder: freezed == folder ? _self.folder : folder // ignore: cast_nullable_to_non_nullable
as SpaceRelativePathValueObject?,isFolder: null == isFolder ? _self.isFolder : isFolder // ignore: cast_nullable_to_non_nullable
as bool,refused: freezed == refused ? _self.refused : refused // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}


}

// dart format on
