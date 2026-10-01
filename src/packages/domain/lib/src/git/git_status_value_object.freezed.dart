// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'git_status_value_object.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GitStatusValueObject {

/// The branch `HEAD` points at; null when detached, and also when the
/// name could not be parsed, which [isDetached] tells apart.
 BranchNameValueObject? get branch;/// The branch it tracks, or null when it tracks nothing.
 BranchNameValueObject? get upstream;/// Commits this branch has that [upstream] does not.
 int get ahead;/// Commits [upstream] has that this branch does not.
 int get behind;/// Every path that differs, in the order git reported it.
///
/// Handed over, not copied: Freezed compares element-wise but copies
/// nothing, so a caller keeping its own reference could change this
/// status and its `hashCode` under a set or a rebuild. Every producer
/// passes a list nothing else holds (`GitStatusParser` an unmodifiable
/// one); making that structural needs an immutable-collection package,
/// a dependency decision not this file's to take.
 List<StatusEntryValueObject> get entries;/// Whether `HEAD` points at a commit rather than a branch.
 bool get isDetached;
/// Create a copy of GitStatusValueObject
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GitStatusValueObjectCopyWith<GitStatusValueObject> get copyWith => _$GitStatusValueObjectCopyWithImpl<GitStatusValueObject>(this as GitStatusValueObject, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GitStatusValueObject&&(identical(other.branch, branch) || other.branch == branch)&&(identical(other.upstream, upstream) || other.upstream == upstream)&&(identical(other.ahead, ahead) || other.ahead == ahead)&&(identical(other.behind, behind) || other.behind == behind)&&const DeepCollectionEquality().equals(other.entries, entries)&&(identical(other.isDetached, isDetached) || other.isDetached == isDetached));
}


@override
int get hashCode => Object.hash(runtimeType,branch,upstream,ahead,behind,const DeepCollectionEquality().hash(entries),isDetached);

@override
String toString() {
  return 'GitStatusValueObject(branch: $branch, upstream: $upstream, ahead: $ahead, behind: $behind, entries: $entries, isDetached: $isDetached)';
}


}

/// @nodoc
abstract mixin class $GitStatusValueObjectCopyWith<$Res>  {
  factory $GitStatusValueObjectCopyWith(GitStatusValueObject value, $Res Function(GitStatusValueObject) _then) = _$GitStatusValueObjectCopyWithImpl;
@useResult
$Res call({
 BranchNameValueObject? branch, BranchNameValueObject? upstream, int ahead, int behind, List<StatusEntryValueObject> entries, bool isDetached
});




}
/// @nodoc
class _$GitStatusValueObjectCopyWithImpl<$Res>
    implements $GitStatusValueObjectCopyWith<$Res> {
  _$GitStatusValueObjectCopyWithImpl(this._self, this._then);

  final GitStatusValueObject _self;
  final $Res Function(GitStatusValueObject) _then;

/// Create a copy of GitStatusValueObject
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? branch = freezed,Object? upstream = freezed,Object? ahead = null,Object? behind = null,Object? entries = null,Object? isDetached = null,}) {
  return _then(_self.copyWith(
branch: freezed == branch ? _self.branch : branch // ignore: cast_nullable_to_non_nullable
as BranchNameValueObject?,upstream: freezed == upstream ? _self.upstream : upstream // ignore: cast_nullable_to_non_nullable
as BranchNameValueObject?,ahead: null == ahead ? _self.ahead : ahead // ignore: cast_nullable_to_non_nullable
as int,behind: null == behind ? _self.behind : behind // ignore: cast_nullable_to_non_nullable
as int,entries: null == entries ? _self.entries : entries // ignore: cast_nullable_to_non_nullable
as List<StatusEntryValueObject>,isDetached: null == isDetached ? _self.isDetached : isDetached // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [GitStatusValueObject].
extension GitStatusValueObjectPatterns on GitStatusValueObject {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GitStatusValueObject value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GitStatusValueObject() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GitStatusValueObject value)  $default,){
final _that = this;
switch (_that) {
case _GitStatusValueObject():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GitStatusValueObject value)?  $default,){
final _that = this;
switch (_that) {
case _GitStatusValueObject() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( BranchNameValueObject? branch,  BranchNameValueObject? upstream,  int ahead,  int behind,  List<StatusEntryValueObject> entries,  bool isDetached)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GitStatusValueObject() when $default != null:
return $default(_that.branch,_that.upstream,_that.ahead,_that.behind,_that.entries,_that.isDetached);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( BranchNameValueObject? branch,  BranchNameValueObject? upstream,  int ahead,  int behind,  List<StatusEntryValueObject> entries,  bool isDetached)  $default,) {final _that = this;
switch (_that) {
case _GitStatusValueObject():
return $default(_that.branch,_that.upstream,_that.ahead,_that.behind,_that.entries,_that.isDetached);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( BranchNameValueObject? branch,  BranchNameValueObject? upstream,  int ahead,  int behind,  List<StatusEntryValueObject> entries,  bool isDetached)?  $default,) {final _that = this;
switch (_that) {
case _GitStatusValueObject() when $default != null:
return $default(_that.branch,_that.upstream,_that.ahead,_that.behind,_that.entries,_that.isDetached);case _:
  return null;

}
}

}

/// @nodoc


class _GitStatusValueObject extends GitStatusValueObject {
  const _GitStatusValueObject({required this.branch, required this.upstream, required this.ahead, required this.behind, required final  List<StatusEntryValueObject> entries, required this.isDetached}): assert(!isDetached || branch == null),_entries = entries,super._();
  

/// The branch `HEAD` points at; null when detached, and also when the
/// name could not be parsed, which [isDetached] tells apart.
@override final  BranchNameValueObject? branch;
/// The branch it tracks, or null when it tracks nothing.
@override final  BranchNameValueObject? upstream;
/// Commits this branch has that [upstream] does not.
@override final  int ahead;
/// Commits [upstream] has that this branch does not.
@override final  int behind;
/// Every path that differs, in the order git reported it.
///
/// Handed over, not copied: Freezed compares element-wise but copies
/// nothing, so a caller keeping its own reference could change this
/// status and its `hashCode` under a set or a rebuild. Every producer
/// passes a list nothing else holds (`GitStatusParser` an unmodifiable
/// one); making that structural needs an immutable-collection package,
/// a dependency decision not this file's to take.
 final  List<StatusEntryValueObject> _entries;
/// Every path that differs, in the order git reported it.
///
/// Handed over, not copied: Freezed compares element-wise but copies
/// nothing, so a caller keeping its own reference could change this
/// status and its `hashCode` under a set or a rebuild. Every producer
/// passes a list nothing else holds (`GitStatusParser` an unmodifiable
/// one); making that structural needs an immutable-collection package,
/// a dependency decision not this file's to take.
@override List<StatusEntryValueObject> get entries {
  if (_entries is EqualUnmodifiableListView) return _entries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_entries);
}

/// Whether `HEAD` points at a commit rather than a branch.
@override final  bool isDetached;

/// Create a copy of GitStatusValueObject
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GitStatusValueObjectCopyWith<_GitStatusValueObject> get copyWith => __$GitStatusValueObjectCopyWithImpl<_GitStatusValueObject>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GitStatusValueObject&&(identical(other.branch, branch) || other.branch == branch)&&(identical(other.upstream, upstream) || other.upstream == upstream)&&(identical(other.ahead, ahead) || other.ahead == ahead)&&(identical(other.behind, behind) || other.behind == behind)&&const DeepCollectionEquality().equals(other._entries, _entries)&&(identical(other.isDetached, isDetached) || other.isDetached == isDetached));
}


@override
int get hashCode => Object.hash(runtimeType,branch,upstream,ahead,behind,const DeepCollectionEquality().hash(_entries),isDetached);

@override
String toString() {
  return 'GitStatusValueObject(branch: $branch, upstream: $upstream, ahead: $ahead, behind: $behind, entries: $entries, isDetached: $isDetached)';
}


}

/// @nodoc
abstract mixin class _$GitStatusValueObjectCopyWith<$Res> implements $GitStatusValueObjectCopyWith<$Res> {
  factory _$GitStatusValueObjectCopyWith(_GitStatusValueObject value, $Res Function(_GitStatusValueObject) _then) = __$GitStatusValueObjectCopyWithImpl;
@override @useResult
$Res call({
 BranchNameValueObject? branch, BranchNameValueObject? upstream, int ahead, int behind, List<StatusEntryValueObject> entries, bool isDetached
});




}
/// @nodoc
class __$GitStatusValueObjectCopyWithImpl<$Res>
    implements _$GitStatusValueObjectCopyWith<$Res> {
  __$GitStatusValueObjectCopyWithImpl(this._self, this._then);

  final _GitStatusValueObject _self;
  final $Res Function(_GitStatusValueObject) _then;

/// Create a copy of GitStatusValueObject
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? branch = freezed,Object? upstream = freezed,Object? ahead = null,Object? behind = null,Object? entries = null,Object? isDetached = null,}) {
  return _then(_GitStatusValueObject(
branch: freezed == branch ? _self.branch : branch // ignore: cast_nullable_to_non_nullable
as BranchNameValueObject?,upstream: freezed == upstream ? _self.upstream : upstream // ignore: cast_nullable_to_non_nullable
as BranchNameValueObject?,ahead: null == ahead ? _self.ahead : ahead // ignore: cast_nullable_to_non_nullable
as int,behind: null == behind ? _self.behind : behind // ignore: cast_nullable_to_non_nullable
as int,entries: null == entries ? _self._entries : entries // ignore: cast_nullable_to_non_nullable
as List<StatusEntryValueObject>,isDetached: null == isDetached ? _self.isDetached : isDetached // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
