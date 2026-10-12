// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'branch_proposal_value_object.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BranchProposalValueObject {

/// The commits `HEAD` has over the base, newest first.
 List<CommitEntity> get commits;/// What they changed, one entry per path.
 List<BranchChangeValueObject> get changes;
/// Create a copy of BranchProposalValueObject
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BranchProposalValueObjectCopyWith<BranchProposalValueObject> get copyWith => _$BranchProposalValueObjectCopyWithImpl<BranchProposalValueObject>(this as BranchProposalValueObject, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BranchProposalValueObject&&const DeepCollectionEquality().equals(other.commits, commits)&&const DeepCollectionEquality().equals(other.changes, changes));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(commits),const DeepCollectionEquality().hash(changes));

@override
String toString() {
  return 'BranchProposalValueObject(commits: $commits, changes: $changes)';
}


}

/// @nodoc
abstract mixin class $BranchProposalValueObjectCopyWith<$Res>  {
  factory $BranchProposalValueObjectCopyWith(BranchProposalValueObject value, $Res Function(BranchProposalValueObject) _then) = _$BranchProposalValueObjectCopyWithImpl;
@useResult
$Res call({
 List<CommitEntity> commits, List<BranchChangeValueObject> changes
});




}
/// @nodoc
class _$BranchProposalValueObjectCopyWithImpl<$Res>
    implements $BranchProposalValueObjectCopyWith<$Res> {
  _$BranchProposalValueObjectCopyWithImpl(this._self, this._then);

  final BranchProposalValueObject _self;
  final $Res Function(BranchProposalValueObject) _then;

/// Create a copy of BranchProposalValueObject
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? commits = null,Object? changes = null,}) {
  return _then(_self.copyWith(
commits: null == commits ? _self.commits : commits // ignore: cast_nullable_to_non_nullable
as List<CommitEntity>,changes: null == changes ? _self.changes : changes // ignore: cast_nullable_to_non_nullable
as List<BranchChangeValueObject>,
  ));
}

}


/// Adds pattern-matching-related methods to [BranchProposalValueObject].
extension BranchProposalValueObjectPatterns on BranchProposalValueObject {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BranchProposalValueObject value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BranchProposalValueObject() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BranchProposalValueObject value)  $default,){
final _that = this;
switch (_that) {
case _BranchProposalValueObject():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BranchProposalValueObject value)?  $default,){
final _that = this;
switch (_that) {
case _BranchProposalValueObject() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<CommitEntity> commits,  List<BranchChangeValueObject> changes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BranchProposalValueObject() when $default != null:
return $default(_that.commits,_that.changes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<CommitEntity> commits,  List<BranchChangeValueObject> changes)  $default,) {final _that = this;
switch (_that) {
case _BranchProposalValueObject():
return $default(_that.commits,_that.changes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<CommitEntity> commits,  List<BranchChangeValueObject> changes)?  $default,) {final _that = this;
switch (_that) {
case _BranchProposalValueObject() when $default != null:
return $default(_that.commits,_that.changes);case _:
  return null;

}
}

}

/// @nodoc


class _BranchProposalValueObject extends BranchProposalValueObject {
  const _BranchProposalValueObject({required final  List<CommitEntity> commits, required final  List<BranchChangeValueObject> changes}): _commits = commits,_changes = changes,super._();
  

/// The commits `HEAD` has over the base, newest first.
 final  List<CommitEntity> _commits;
/// The commits `HEAD` has over the base, newest first.
@override List<CommitEntity> get commits {
  if (_commits is EqualUnmodifiableListView) return _commits;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_commits);
}

/// What they changed, one entry per path.
 final  List<BranchChangeValueObject> _changes;
/// What they changed, one entry per path.
@override List<BranchChangeValueObject> get changes {
  if (_changes is EqualUnmodifiableListView) return _changes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_changes);
}


/// Create a copy of BranchProposalValueObject
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BranchProposalValueObjectCopyWith<_BranchProposalValueObject> get copyWith => __$BranchProposalValueObjectCopyWithImpl<_BranchProposalValueObject>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BranchProposalValueObject&&const DeepCollectionEquality().equals(other._commits, _commits)&&const DeepCollectionEquality().equals(other._changes, _changes));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_commits),const DeepCollectionEquality().hash(_changes));

@override
String toString() {
  return 'BranchProposalValueObject(commits: $commits, changes: $changes)';
}


}

/// @nodoc
abstract mixin class _$BranchProposalValueObjectCopyWith<$Res> implements $BranchProposalValueObjectCopyWith<$Res> {
  factory _$BranchProposalValueObjectCopyWith(_BranchProposalValueObject value, $Res Function(_BranchProposalValueObject) _then) = __$BranchProposalValueObjectCopyWithImpl;
@override @useResult
$Res call({
 List<CommitEntity> commits, List<BranchChangeValueObject> changes
});




}
/// @nodoc
class __$BranchProposalValueObjectCopyWithImpl<$Res>
    implements _$BranchProposalValueObjectCopyWith<$Res> {
  __$BranchProposalValueObjectCopyWithImpl(this._self, this._then);

  final _BranchProposalValueObject _self;
  final $Res Function(_BranchProposalValueObject) _then;

/// Create a copy of BranchProposalValueObject
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? commits = null,Object? changes = null,}) {
  return _then(_BranchProposalValueObject(
commits: null == commits ? _self._commits : commits // ignore: cast_nullable_to_non_nullable
as List<CommitEntity>,changes: null == changes ? _self._changes : changes // ignore: cast_nullable_to_non_nullable
as List<BranchChangeValueObject>,
  ));
}


}

// dart format on
