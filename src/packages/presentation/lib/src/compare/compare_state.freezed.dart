// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'compare_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CompareState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CompareState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CompareState()';
}


}

/// @nodoc
class $CompareStateCopyWith<$Res>  {
$CompareStateCopyWith(CompareState _, $Res Function(CompareState) __);
}


/// Adds pattern-matching-related methods to [CompareState].
extension CompareStatePatterns on CompareState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( CompareIdle value)?  idle,TResult Function( CompareReady value)?  ready,required TResult orElse(),}){
final _that = this;
switch (_that) {
case CompareIdle() when idle != null:
return idle(_that);case CompareReady() when ready != null:
return ready(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( CompareIdle value)  idle,required TResult Function( CompareReady value)  ready,}){
final _that = this;
switch (_that) {
case CompareIdle():
return idle(_that);case CompareReady():
return ready(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( CompareIdle value)?  idle,TResult? Function( CompareReady value)?  ready,}){
final _that = this;
switch (_that) {
case CompareIdle() when idle != null:
return idle(_that);case CompareReady() when ready != null:
return ready(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  idle,TResult Function( List<BranchEntity> branches,  List<CommitEntity> commits,  String draft)?  ready,required TResult orElse(),}) {final _that = this;
switch (_that) {
case CompareIdle() when idle != null:
return idle();case CompareReady() when ready != null:
return ready(_that.branches,_that.commits,_that.draft);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  idle,required TResult Function( List<BranchEntity> branches,  List<CommitEntity> commits,  String draft)  ready,}) {final _that = this;
switch (_that) {
case CompareIdle():
return idle();case CompareReady():
return ready(_that.branches,_that.commits,_that.draft);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  idle,TResult? Function( List<BranchEntity> branches,  List<CommitEntity> commits,  String draft)?  ready,}) {final _that = this;
switch (_that) {
case CompareIdle() when idle != null:
return idle();case CompareReady() when ready != null:
return ready(_that.branches,_that.commits,_that.draft);case _:
  return null;

}
}

}

/// @nodoc


class CompareIdle extends CompareState {
  const CompareIdle(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CompareIdle);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CompareState.idle()';
}


}




/// @nodoc


class CompareReady extends CompareState {
  const CompareReady({required final  List<BranchEntity> branches, required final  List<CommitEntity> commits, this.draft = ''}): _branches = branches,_commits = commits,super._();
  

/// Every local branch, as the switcher lists them.
 final  List<BranchEntity> _branches;
/// Every local branch, as the switcher lists them.
 List<BranchEntity> get branches {
  if (_branches is EqualUnmodifiableListView) return _branches;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_branches);
}

/// The commits that touched the open document, as history lists them.
///
/// The document's own and not the repository's: a commit that never
/// touched it holds the same text as the last one that did, so offering
/// it would be a longer list saying the same things.
 final  List<CommitEntity> _commits;
/// The commits that touched the open document, as history lists them.
///
/// The document's own and not the repository's: a commit that never
/// touched it holds the same text as the last one that did, so offering
/// it would be a longer list saying the same things.
 List<CommitEntity> get commits {
  if (_commits is EqualUnmodifiableListView) return _commits;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_commits);
}

/// What is in the box; empty shows everything.
@JsonKey() final  String draft;

/// Create a copy of CompareState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CompareReadyCopyWith<CompareReady> get copyWith => _$CompareReadyCopyWithImpl<CompareReady>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CompareReady&&const DeepCollectionEquality().equals(other._branches, _branches)&&const DeepCollectionEquality().equals(other._commits, _commits)&&(identical(other.draft, draft) || other.draft == draft));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_branches),const DeepCollectionEquality().hash(_commits),draft);

@override
String toString() {
  return 'CompareState.ready(branches: $branches, commits: $commits, draft: $draft)';
}


}

/// @nodoc
abstract mixin class $CompareReadyCopyWith<$Res> implements $CompareStateCopyWith<$Res> {
  factory $CompareReadyCopyWith(CompareReady value, $Res Function(CompareReady) _then) = _$CompareReadyCopyWithImpl;
@useResult
$Res call({
 List<BranchEntity> branches, List<CommitEntity> commits, String draft
});




}
/// @nodoc
class _$CompareReadyCopyWithImpl<$Res>
    implements $CompareReadyCopyWith<$Res> {
  _$CompareReadyCopyWithImpl(this._self, this._then);

  final CompareReady _self;
  final $Res Function(CompareReady) _then;

/// Create a copy of CompareState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? branches = null,Object? commits = null,Object? draft = null,}) {
  return _then(CompareReady(
branches: null == branches ? _self._branches : branches // ignore: cast_nullable_to_non_nullable
as List<BranchEntity>,commits: null == commits ? _self._commits : commits // ignore: cast_nullable_to_non_nullable
as List<CommitEntity>,draft: null == draft ? _self.draft : draft // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
