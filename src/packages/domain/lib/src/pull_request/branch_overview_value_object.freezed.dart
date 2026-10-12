// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'branch_overview_value_object.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BranchOverviewValueObject {

/// How many commits the branch has over its base.
 int get commits;/// Documents the branch added.
 int get added;/// Documents it changed.
 int get modified;/// Documents it deleted.
 int get deleted;/// Words the new text has that the old did not.
 int get wordsAdded;/// Words the old text had that the new does not.
 int get wordsRemoved;/// How many blocks of each kind changed, most first.
 Map<BlockKindEnum, int> get blocks;/// How many changed documents each folder holds, most first; the root
/// is the empty string.
 Map<String, int> get folders;/// Minutes a reviewer needs for the words above, at least one when any
/// word changed.
 int get readingMinutes;/// When the oldest commit was written, or null with none.
 CommitDateValueObject? get firstCommit;/// The document with the most lines added and removed, or null when
/// nothing has a count.
 BranchChangeValueObject? get mostChanged;
/// Create a copy of BranchOverviewValueObject
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BranchOverviewValueObjectCopyWith<BranchOverviewValueObject> get copyWith => _$BranchOverviewValueObjectCopyWithImpl<BranchOverviewValueObject>(this as BranchOverviewValueObject, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BranchOverviewValueObject&&(identical(other.commits, commits) || other.commits == commits)&&(identical(other.added, added) || other.added == added)&&(identical(other.modified, modified) || other.modified == modified)&&(identical(other.deleted, deleted) || other.deleted == deleted)&&(identical(other.wordsAdded, wordsAdded) || other.wordsAdded == wordsAdded)&&(identical(other.wordsRemoved, wordsRemoved) || other.wordsRemoved == wordsRemoved)&&const DeepCollectionEquality().equals(other.blocks, blocks)&&const DeepCollectionEquality().equals(other.folders, folders)&&(identical(other.readingMinutes, readingMinutes) || other.readingMinutes == readingMinutes)&&(identical(other.firstCommit, firstCommit) || other.firstCommit == firstCommit)&&(identical(other.mostChanged, mostChanged) || other.mostChanged == mostChanged));
}


@override
int get hashCode => Object.hash(runtimeType,commits,added,modified,deleted,wordsAdded,wordsRemoved,const DeepCollectionEquality().hash(blocks),const DeepCollectionEquality().hash(folders),readingMinutes,firstCommit,mostChanged);

@override
String toString() {
  return 'BranchOverviewValueObject(commits: $commits, added: $added, modified: $modified, deleted: $deleted, wordsAdded: $wordsAdded, wordsRemoved: $wordsRemoved, blocks: $blocks, folders: $folders, readingMinutes: $readingMinutes, firstCommit: $firstCommit, mostChanged: $mostChanged)';
}


}

/// @nodoc
abstract mixin class $BranchOverviewValueObjectCopyWith<$Res>  {
  factory $BranchOverviewValueObjectCopyWith(BranchOverviewValueObject value, $Res Function(BranchOverviewValueObject) _then) = _$BranchOverviewValueObjectCopyWithImpl;
@useResult
$Res call({
 int commits, int added, int modified, int deleted, int wordsAdded, int wordsRemoved, Map<BlockKindEnum, int> blocks, Map<String, int> folders, int readingMinutes, CommitDateValueObject? firstCommit, BranchChangeValueObject? mostChanged
});


$CommitDateValueObjectCopyWith<$Res>? get firstCommit;$BranchChangeValueObjectCopyWith<$Res>? get mostChanged;

}
/// @nodoc
class _$BranchOverviewValueObjectCopyWithImpl<$Res>
    implements $BranchOverviewValueObjectCopyWith<$Res> {
  _$BranchOverviewValueObjectCopyWithImpl(this._self, this._then);

  final BranchOverviewValueObject _self;
  final $Res Function(BranchOverviewValueObject) _then;

/// Create a copy of BranchOverviewValueObject
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? commits = null,Object? added = null,Object? modified = null,Object? deleted = null,Object? wordsAdded = null,Object? wordsRemoved = null,Object? blocks = null,Object? folders = null,Object? readingMinutes = null,Object? firstCommit = freezed,Object? mostChanged = freezed,}) {
  return _then(_self.copyWith(
commits: null == commits ? _self.commits : commits // ignore: cast_nullable_to_non_nullable
as int,added: null == added ? _self.added : added // ignore: cast_nullable_to_non_nullable
as int,modified: null == modified ? _self.modified : modified // ignore: cast_nullable_to_non_nullable
as int,deleted: null == deleted ? _self.deleted : deleted // ignore: cast_nullable_to_non_nullable
as int,wordsAdded: null == wordsAdded ? _self.wordsAdded : wordsAdded // ignore: cast_nullable_to_non_nullable
as int,wordsRemoved: null == wordsRemoved ? _self.wordsRemoved : wordsRemoved // ignore: cast_nullable_to_non_nullable
as int,blocks: null == blocks ? _self.blocks : blocks // ignore: cast_nullable_to_non_nullable
as Map<BlockKindEnum, int>,folders: null == folders ? _self.folders : folders // ignore: cast_nullable_to_non_nullable
as Map<String, int>,readingMinutes: null == readingMinutes ? _self.readingMinutes : readingMinutes // ignore: cast_nullable_to_non_nullable
as int,firstCommit: freezed == firstCommit ? _self.firstCommit : firstCommit // ignore: cast_nullable_to_non_nullable
as CommitDateValueObject?,mostChanged: freezed == mostChanged ? _self.mostChanged : mostChanged // ignore: cast_nullable_to_non_nullable
as BranchChangeValueObject?,
  ));
}
/// Create a copy of BranchOverviewValueObject
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CommitDateValueObjectCopyWith<$Res>? get firstCommit {
    if (_self.firstCommit == null) {
    return null;
  }

  return $CommitDateValueObjectCopyWith<$Res>(_self.firstCommit!, (value) {
    return _then(_self.copyWith(firstCommit: value));
  });
}/// Create a copy of BranchOverviewValueObject
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BranchChangeValueObjectCopyWith<$Res>? get mostChanged {
    if (_self.mostChanged == null) {
    return null;
  }

  return $BranchChangeValueObjectCopyWith<$Res>(_self.mostChanged!, (value) {
    return _then(_self.copyWith(mostChanged: value));
  });
}
}


/// Adds pattern-matching-related methods to [BranchOverviewValueObject].
extension BranchOverviewValueObjectPatterns on BranchOverviewValueObject {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BranchOverviewValueObject value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BranchOverviewValueObject() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BranchOverviewValueObject value)  $default,){
final _that = this;
switch (_that) {
case _BranchOverviewValueObject():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BranchOverviewValueObject value)?  $default,){
final _that = this;
switch (_that) {
case _BranchOverviewValueObject() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int commits,  int added,  int modified,  int deleted,  int wordsAdded,  int wordsRemoved,  Map<BlockKindEnum, int> blocks,  Map<String, int> folders,  int readingMinutes,  CommitDateValueObject? firstCommit,  BranchChangeValueObject? mostChanged)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BranchOverviewValueObject() when $default != null:
return $default(_that.commits,_that.added,_that.modified,_that.deleted,_that.wordsAdded,_that.wordsRemoved,_that.blocks,_that.folders,_that.readingMinutes,_that.firstCommit,_that.mostChanged);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int commits,  int added,  int modified,  int deleted,  int wordsAdded,  int wordsRemoved,  Map<BlockKindEnum, int> blocks,  Map<String, int> folders,  int readingMinutes,  CommitDateValueObject? firstCommit,  BranchChangeValueObject? mostChanged)  $default,) {final _that = this;
switch (_that) {
case _BranchOverviewValueObject():
return $default(_that.commits,_that.added,_that.modified,_that.deleted,_that.wordsAdded,_that.wordsRemoved,_that.blocks,_that.folders,_that.readingMinutes,_that.firstCommit,_that.mostChanged);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int commits,  int added,  int modified,  int deleted,  int wordsAdded,  int wordsRemoved,  Map<BlockKindEnum, int> blocks,  Map<String, int> folders,  int readingMinutes,  CommitDateValueObject? firstCommit,  BranchChangeValueObject? mostChanged)?  $default,) {final _that = this;
switch (_that) {
case _BranchOverviewValueObject() when $default != null:
return $default(_that.commits,_that.added,_that.modified,_that.deleted,_that.wordsAdded,_that.wordsRemoved,_that.blocks,_that.folders,_that.readingMinutes,_that.firstCommit,_that.mostChanged);case _:
  return null;

}
}

}

/// @nodoc


class _BranchOverviewValueObject implements BranchOverviewValueObject {
  const _BranchOverviewValueObject({required this.commits, required this.added, required this.modified, required this.deleted, required this.wordsAdded, required this.wordsRemoved, required final  Map<BlockKindEnum, int> blocks, required final  Map<String, int> folders, required this.readingMinutes, this.firstCommit, this.mostChanged}): _blocks = blocks,_folders = folders;
  

/// How many commits the branch has over its base.
@override final  int commits;
/// Documents the branch added.
@override final  int added;
/// Documents it changed.
@override final  int modified;
/// Documents it deleted.
@override final  int deleted;
/// Words the new text has that the old did not.
@override final  int wordsAdded;
/// Words the old text had that the new does not.
@override final  int wordsRemoved;
/// How many blocks of each kind changed, most first.
 final  Map<BlockKindEnum, int> _blocks;
/// How many blocks of each kind changed, most first.
@override Map<BlockKindEnum, int> get blocks {
  if (_blocks is EqualUnmodifiableMapView) return _blocks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_blocks);
}

/// How many changed documents each folder holds, most first; the root
/// is the empty string.
 final  Map<String, int> _folders;
/// How many changed documents each folder holds, most first; the root
/// is the empty string.
@override Map<String, int> get folders {
  if (_folders is EqualUnmodifiableMapView) return _folders;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_folders);
}

/// Minutes a reviewer needs for the words above, at least one when any
/// word changed.
@override final  int readingMinutes;
/// When the oldest commit was written, or null with none.
@override final  CommitDateValueObject? firstCommit;
/// The document with the most lines added and removed, or null when
/// nothing has a count.
@override final  BranchChangeValueObject? mostChanged;

/// Create a copy of BranchOverviewValueObject
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BranchOverviewValueObjectCopyWith<_BranchOverviewValueObject> get copyWith => __$BranchOverviewValueObjectCopyWithImpl<_BranchOverviewValueObject>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BranchOverviewValueObject&&(identical(other.commits, commits) || other.commits == commits)&&(identical(other.added, added) || other.added == added)&&(identical(other.modified, modified) || other.modified == modified)&&(identical(other.deleted, deleted) || other.deleted == deleted)&&(identical(other.wordsAdded, wordsAdded) || other.wordsAdded == wordsAdded)&&(identical(other.wordsRemoved, wordsRemoved) || other.wordsRemoved == wordsRemoved)&&const DeepCollectionEquality().equals(other._blocks, _blocks)&&const DeepCollectionEquality().equals(other._folders, _folders)&&(identical(other.readingMinutes, readingMinutes) || other.readingMinutes == readingMinutes)&&(identical(other.firstCommit, firstCommit) || other.firstCommit == firstCommit)&&(identical(other.mostChanged, mostChanged) || other.mostChanged == mostChanged));
}


@override
int get hashCode => Object.hash(runtimeType,commits,added,modified,deleted,wordsAdded,wordsRemoved,const DeepCollectionEquality().hash(_blocks),const DeepCollectionEquality().hash(_folders),readingMinutes,firstCommit,mostChanged);

@override
String toString() {
  return 'BranchOverviewValueObject(commits: $commits, added: $added, modified: $modified, deleted: $deleted, wordsAdded: $wordsAdded, wordsRemoved: $wordsRemoved, blocks: $blocks, folders: $folders, readingMinutes: $readingMinutes, firstCommit: $firstCommit, mostChanged: $mostChanged)';
}


}

/// @nodoc
abstract mixin class _$BranchOverviewValueObjectCopyWith<$Res> implements $BranchOverviewValueObjectCopyWith<$Res> {
  factory _$BranchOverviewValueObjectCopyWith(_BranchOverviewValueObject value, $Res Function(_BranchOverviewValueObject) _then) = __$BranchOverviewValueObjectCopyWithImpl;
@override @useResult
$Res call({
 int commits, int added, int modified, int deleted, int wordsAdded, int wordsRemoved, Map<BlockKindEnum, int> blocks, Map<String, int> folders, int readingMinutes, CommitDateValueObject? firstCommit, BranchChangeValueObject? mostChanged
});


@override $CommitDateValueObjectCopyWith<$Res>? get firstCommit;@override $BranchChangeValueObjectCopyWith<$Res>? get mostChanged;

}
/// @nodoc
class __$BranchOverviewValueObjectCopyWithImpl<$Res>
    implements _$BranchOverviewValueObjectCopyWith<$Res> {
  __$BranchOverviewValueObjectCopyWithImpl(this._self, this._then);

  final _BranchOverviewValueObject _self;
  final $Res Function(_BranchOverviewValueObject) _then;

/// Create a copy of BranchOverviewValueObject
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? commits = null,Object? added = null,Object? modified = null,Object? deleted = null,Object? wordsAdded = null,Object? wordsRemoved = null,Object? blocks = null,Object? folders = null,Object? readingMinutes = null,Object? firstCommit = freezed,Object? mostChanged = freezed,}) {
  return _then(_BranchOverviewValueObject(
commits: null == commits ? _self.commits : commits // ignore: cast_nullable_to_non_nullable
as int,added: null == added ? _self.added : added // ignore: cast_nullable_to_non_nullable
as int,modified: null == modified ? _self.modified : modified // ignore: cast_nullable_to_non_nullable
as int,deleted: null == deleted ? _self.deleted : deleted // ignore: cast_nullable_to_non_nullable
as int,wordsAdded: null == wordsAdded ? _self.wordsAdded : wordsAdded // ignore: cast_nullable_to_non_nullable
as int,wordsRemoved: null == wordsRemoved ? _self.wordsRemoved : wordsRemoved // ignore: cast_nullable_to_non_nullable
as int,blocks: null == blocks ? _self._blocks : blocks // ignore: cast_nullable_to_non_nullable
as Map<BlockKindEnum, int>,folders: null == folders ? _self._folders : folders // ignore: cast_nullable_to_non_nullable
as Map<String, int>,readingMinutes: null == readingMinutes ? _self.readingMinutes : readingMinutes // ignore: cast_nullable_to_non_nullable
as int,firstCommit: freezed == firstCommit ? _self.firstCommit : firstCommit // ignore: cast_nullable_to_non_nullable
as CommitDateValueObject?,mostChanged: freezed == mostChanged ? _self.mostChanged : mostChanged // ignore: cast_nullable_to_non_nullable
as BranchChangeValueObject?,
  ));
}

/// Create a copy of BranchOverviewValueObject
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CommitDateValueObjectCopyWith<$Res>? get firstCommit {
    if (_self.firstCommit == null) {
    return null;
  }

  return $CommitDateValueObjectCopyWith<$Res>(_self.firstCommit!, (value) {
    return _then(_self.copyWith(firstCommit: value));
  });
}/// Create a copy of BranchOverviewValueObject
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BranchChangeValueObjectCopyWith<$Res>? get mostChanged {
    if (_self.mostChanged == null) {
    return null;
  }

  return $BranchChangeValueObjectCopyWith<$Res>(_self.mostChanged!, (value) {
    return _then(_self.copyWith(mostChanged: value));
  });
}
}

// dart format on
