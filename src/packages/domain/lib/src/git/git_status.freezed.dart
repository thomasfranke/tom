// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'git_status.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GitStatus {

/// The branch `HEAD` points at, or null when `HEAD` is detached.
 BranchName? get branch;/// The branch it tracks, or null when it tracks nothing.
 BranchName? get upstream;/// Commits this branch has that [upstream] does not.
 int get ahead;/// Commits [upstream] has that this branch does not.
 int get behind;/// Every path that differs, in the order git reported it.
 List<StatusEntry> get entries;
/// Create a copy of GitStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GitStatusCopyWith<GitStatus> get copyWith => _$GitStatusCopyWithImpl<GitStatus>(this as GitStatus, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GitStatus&&(identical(other.branch, branch) || other.branch == branch)&&(identical(other.upstream, upstream) || other.upstream == upstream)&&(identical(other.ahead, ahead) || other.ahead == ahead)&&(identical(other.behind, behind) || other.behind == behind)&&const DeepCollectionEquality().equals(other.entries, entries));
}


@override
int get hashCode => Object.hash(runtimeType,branch,upstream,ahead,behind,const DeepCollectionEquality().hash(entries));

@override
String toString() {
  return 'GitStatus(branch: $branch, upstream: $upstream, ahead: $ahead, behind: $behind, entries: $entries)';
}


}

/// @nodoc
abstract mixin class $GitStatusCopyWith<$Res>  {
  factory $GitStatusCopyWith(GitStatus value, $Res Function(GitStatus) _then) = _$GitStatusCopyWithImpl;
@useResult
$Res call({
 BranchName? branch, BranchName? upstream, int ahead, int behind, List<StatusEntry> entries
});




}
/// @nodoc
class _$GitStatusCopyWithImpl<$Res>
    implements $GitStatusCopyWith<$Res> {
  _$GitStatusCopyWithImpl(this._self, this._then);

  final GitStatus _self;
  final $Res Function(GitStatus) _then;

/// Create a copy of GitStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? branch = freezed,Object? upstream = freezed,Object? ahead = null,Object? behind = null,Object? entries = null,}) {
  return _then(_self.copyWith(
branch: freezed == branch ? _self.branch : branch // ignore: cast_nullable_to_non_nullable
as BranchName?,upstream: freezed == upstream ? _self.upstream : upstream // ignore: cast_nullable_to_non_nullable
as BranchName?,ahead: null == ahead ? _self.ahead : ahead // ignore: cast_nullable_to_non_nullable
as int,behind: null == behind ? _self.behind : behind // ignore: cast_nullable_to_non_nullable
as int,entries: null == entries ? _self.entries : entries // ignore: cast_nullable_to_non_nullable
as List<StatusEntry>,
  ));
}

}


/// Adds pattern-matching-related methods to [GitStatus].
extension GitStatusPatterns on GitStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GitStatus value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GitStatus() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GitStatus value)  $default,){
final _that = this;
switch (_that) {
case _GitStatus():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GitStatus value)?  $default,){
final _that = this;
switch (_that) {
case _GitStatus() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( BranchName? branch,  BranchName? upstream,  int ahead,  int behind,  List<StatusEntry> entries)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GitStatus() when $default != null:
return $default(_that.branch,_that.upstream,_that.ahead,_that.behind,_that.entries);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( BranchName? branch,  BranchName? upstream,  int ahead,  int behind,  List<StatusEntry> entries)  $default,) {final _that = this;
switch (_that) {
case _GitStatus():
return $default(_that.branch,_that.upstream,_that.ahead,_that.behind,_that.entries);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( BranchName? branch,  BranchName? upstream,  int ahead,  int behind,  List<StatusEntry> entries)?  $default,) {final _that = this;
switch (_that) {
case _GitStatus() when $default != null:
return $default(_that.branch,_that.upstream,_that.ahead,_that.behind,_that.entries);case _:
  return null;

}
}

}

/// @nodoc


class _GitStatus extends GitStatus {
  const _GitStatus({required this.branch, required this.upstream, required this.ahead, required this.behind, required final  List<StatusEntry> entries}): _entries = entries,super._();
  

/// The branch `HEAD` points at, or null when `HEAD` is detached.
@override final  BranchName? branch;
/// The branch it tracks, or null when it tracks nothing.
@override final  BranchName? upstream;
/// Commits this branch has that [upstream] does not.
@override final  int ahead;
/// Commits [upstream] has that this branch does not.
@override final  int behind;
/// Every path that differs, in the order git reported it.
 final  List<StatusEntry> _entries;
/// Every path that differs, in the order git reported it.
@override List<StatusEntry> get entries {
  if (_entries is EqualUnmodifiableListView) return _entries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_entries);
}


/// Create a copy of GitStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GitStatusCopyWith<_GitStatus> get copyWith => __$GitStatusCopyWithImpl<_GitStatus>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GitStatus&&(identical(other.branch, branch) || other.branch == branch)&&(identical(other.upstream, upstream) || other.upstream == upstream)&&(identical(other.ahead, ahead) || other.ahead == ahead)&&(identical(other.behind, behind) || other.behind == behind)&&const DeepCollectionEquality().equals(other._entries, _entries));
}


@override
int get hashCode => Object.hash(runtimeType,branch,upstream,ahead,behind,const DeepCollectionEquality().hash(_entries));

@override
String toString() {
  return 'GitStatus(branch: $branch, upstream: $upstream, ahead: $ahead, behind: $behind, entries: $entries)';
}


}

/// @nodoc
abstract mixin class _$GitStatusCopyWith<$Res> implements $GitStatusCopyWith<$Res> {
  factory _$GitStatusCopyWith(_GitStatus value, $Res Function(_GitStatus) _then) = __$GitStatusCopyWithImpl;
@override @useResult
$Res call({
 BranchName? branch, BranchName? upstream, int ahead, int behind, List<StatusEntry> entries
});




}
/// @nodoc
class __$GitStatusCopyWithImpl<$Res>
    implements _$GitStatusCopyWith<$Res> {
  __$GitStatusCopyWithImpl(this._self, this._then);

  final _GitStatus _self;
  final $Res Function(_GitStatus) _then;

/// Create a copy of GitStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? branch = freezed,Object? upstream = freezed,Object? ahead = null,Object? behind = null,Object? entries = null,}) {
  return _then(_GitStatus(
branch: freezed == branch ? _self.branch : branch // ignore: cast_nullable_to_non_nullable
as BranchName?,upstream: freezed == upstream ? _self.upstream : upstream // ignore: cast_nullable_to_non_nullable
as BranchName?,ahead: null == ahead ? _self.ahead : ahead // ignore: cast_nullable_to_non_nullable
as int,behind: null == behind ? _self.behind : behind // ignore: cast_nullable_to_non_nullable
as int,entries: null == entries ? _self._entries : entries // ignore: cast_nullable_to_non_nullable
as List<StatusEntry>,
  ));
}


}

// dart format on
