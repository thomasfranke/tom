// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'file_tree_row.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FileTreeRow {

/// What the space holds here.
 SpaceEntryValueObject get entry;/// How far in it is drawn — 0 at the top level.
///
/// Derived from the path rather than counted during the walk, so the
/// walk cannot indent the tree wrongly.
 int get depth;/// Whether this is a folder whose contents are showing; false for a
/// file.
 bool get isExpanded;/// What git says happened to this file, or null when it says nothing.
///
/// Always null for a folder: a folder is not in a state, it contains
/// files that are ([holdsChange]).
 FileStateEnum? get change;/// Whether this folder contains a changed file, at any depth.
///
/// Always false for a file, which carries [change] instead.
 bool get holdsChange;
/// Create a copy of FileTreeRow
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FileTreeRowCopyWith<FileTreeRow> get copyWith => _$FileTreeRowCopyWithImpl<FileTreeRow>(this as FileTreeRow, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FileTreeRow&&(identical(other.entry, entry) || other.entry == entry)&&(identical(other.depth, depth) || other.depth == depth)&&(identical(other.isExpanded, isExpanded) || other.isExpanded == isExpanded)&&(identical(other.change, change) || other.change == change)&&(identical(other.holdsChange, holdsChange) || other.holdsChange == holdsChange));
}


@override
int get hashCode => Object.hash(runtimeType,entry,depth,isExpanded,change,holdsChange);

@override
String toString() {
  return 'FileTreeRow(entry: $entry, depth: $depth, isExpanded: $isExpanded, change: $change, holdsChange: $holdsChange)';
}


}

/// @nodoc
abstract mixin class $FileTreeRowCopyWith<$Res>  {
  factory $FileTreeRowCopyWith(FileTreeRow value, $Res Function(FileTreeRow) _then) = _$FileTreeRowCopyWithImpl;
@useResult
$Res call({
 SpaceEntryValueObject entry, int depth, bool isExpanded, FileStateEnum? change, bool holdsChange
});


$SpaceEntryValueObjectCopyWith<$Res> get entry;

}
/// @nodoc
class _$FileTreeRowCopyWithImpl<$Res>
    implements $FileTreeRowCopyWith<$Res> {
  _$FileTreeRowCopyWithImpl(this._self, this._then);

  final FileTreeRow _self;
  final $Res Function(FileTreeRow) _then;

/// Create a copy of FileTreeRow
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? entry = null,Object? depth = null,Object? isExpanded = null,Object? change = freezed,Object? holdsChange = null,}) {
  return _then(_self.copyWith(
entry: null == entry ? _self.entry : entry // ignore: cast_nullable_to_non_nullable
as SpaceEntryValueObject,depth: null == depth ? _self.depth : depth // ignore: cast_nullable_to_non_nullable
as int,isExpanded: null == isExpanded ? _self.isExpanded : isExpanded // ignore: cast_nullable_to_non_nullable
as bool,change: freezed == change ? _self.change : change // ignore: cast_nullable_to_non_nullable
as FileStateEnum?,holdsChange: null == holdsChange ? _self.holdsChange : holdsChange // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of FileTreeRow
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SpaceEntryValueObjectCopyWith<$Res> get entry {
  
  return $SpaceEntryValueObjectCopyWith<$Res>(_self.entry, (value) {
    return _then(_self.copyWith(entry: value));
  });
}
}


/// Adds pattern-matching-related methods to [FileTreeRow].
extension FileTreeRowPatterns on FileTreeRow {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FileTreeRow value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FileTreeRow() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FileTreeRow value)  $default,){
final _that = this;
switch (_that) {
case _FileTreeRow():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FileTreeRow value)?  $default,){
final _that = this;
switch (_that) {
case _FileTreeRow() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SpaceEntryValueObject entry,  int depth,  bool isExpanded,  FileStateEnum? change,  bool holdsChange)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FileTreeRow() when $default != null:
return $default(_that.entry,_that.depth,_that.isExpanded,_that.change,_that.holdsChange);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SpaceEntryValueObject entry,  int depth,  bool isExpanded,  FileStateEnum? change,  bool holdsChange)  $default,) {final _that = this;
switch (_that) {
case _FileTreeRow():
return $default(_that.entry,_that.depth,_that.isExpanded,_that.change,_that.holdsChange);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SpaceEntryValueObject entry,  int depth,  bool isExpanded,  FileStateEnum? change,  bool holdsChange)?  $default,) {final _that = this;
switch (_that) {
case _FileTreeRow() when $default != null:
return $default(_that.entry,_that.depth,_that.isExpanded,_that.change,_that.holdsChange);case _:
  return null;

}
}

}

/// @nodoc


class _FileTreeRow extends FileTreeRow {
  const _FileTreeRow({required this.entry, required this.depth, required this.isExpanded, this.change, this.holdsChange = false}): super._();
  

/// What the space holds here.
@override final  SpaceEntryValueObject entry;
/// How far in it is drawn — 0 at the top level.
///
/// Derived from the path rather than counted during the walk, so the
/// walk cannot indent the tree wrongly.
@override final  int depth;
/// Whether this is a folder whose contents are showing; false for a
/// file.
@override final  bool isExpanded;
/// What git says happened to this file, or null when it says nothing.
///
/// Always null for a folder: a folder is not in a state, it contains
/// files that are ([holdsChange]).
@override final  FileStateEnum? change;
/// Whether this folder contains a changed file, at any depth.
///
/// Always false for a file, which carries [change] instead.
@override@JsonKey() final  bool holdsChange;

/// Create a copy of FileTreeRow
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FileTreeRowCopyWith<_FileTreeRow> get copyWith => __$FileTreeRowCopyWithImpl<_FileTreeRow>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FileTreeRow&&(identical(other.entry, entry) || other.entry == entry)&&(identical(other.depth, depth) || other.depth == depth)&&(identical(other.isExpanded, isExpanded) || other.isExpanded == isExpanded)&&(identical(other.change, change) || other.change == change)&&(identical(other.holdsChange, holdsChange) || other.holdsChange == holdsChange));
}


@override
int get hashCode => Object.hash(runtimeType,entry,depth,isExpanded,change,holdsChange);

@override
String toString() {
  return 'FileTreeRow(entry: $entry, depth: $depth, isExpanded: $isExpanded, change: $change, holdsChange: $holdsChange)';
}


}

/// @nodoc
abstract mixin class _$FileTreeRowCopyWith<$Res> implements $FileTreeRowCopyWith<$Res> {
  factory _$FileTreeRowCopyWith(_FileTreeRow value, $Res Function(_FileTreeRow) _then) = __$FileTreeRowCopyWithImpl;
@override @useResult
$Res call({
 SpaceEntryValueObject entry, int depth, bool isExpanded, FileStateEnum? change, bool holdsChange
});


@override $SpaceEntryValueObjectCopyWith<$Res> get entry;

}
/// @nodoc
class __$FileTreeRowCopyWithImpl<$Res>
    implements _$FileTreeRowCopyWith<$Res> {
  __$FileTreeRowCopyWithImpl(this._self, this._then);

  final _FileTreeRow _self;
  final $Res Function(_FileTreeRow) _then;

/// Create a copy of FileTreeRow
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? entry = null,Object? depth = null,Object? isExpanded = null,Object? change = freezed,Object? holdsChange = null,}) {
  return _then(_FileTreeRow(
entry: null == entry ? _self.entry : entry // ignore: cast_nullable_to_non_nullable
as SpaceEntryValueObject,depth: null == depth ? _self.depth : depth // ignore: cast_nullable_to_non_nullable
as int,isExpanded: null == isExpanded ? _self.isExpanded : isExpanded // ignore: cast_nullable_to_non_nullable
as bool,change: freezed == change ? _self.change : change // ignore: cast_nullable_to_non_nullable
as FileStateEnum?,holdsChange: null == holdsChange ? _self.holdsChange : holdsChange // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of FileTreeRow
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SpaceEntryValueObjectCopyWith<$Res> get entry {
  
  return $SpaceEntryValueObjectCopyWith<$Res>(_self.entry, (value) {
    return _then(_self.copyWith(entry: value));
  });
}
}

// dart format on
