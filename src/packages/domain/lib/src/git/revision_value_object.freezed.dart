// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'revision_value_object.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RevisionValueObject {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RevisionValueObject);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'RevisionValueObject()';
}


}

/// @nodoc
class $RevisionValueObjectCopyWith<$Res>  {
$RevisionValueObjectCopyWith(RevisionValueObject _, $Res Function(RevisionValueObject) __);
}


/// Adds pattern-matching-related methods to [RevisionValueObject].
extension RevisionValueObjectPatterns on RevisionValueObject {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( RevisionBranch value)?  branch,TResult Function( RevisionCommit value)?  commit,required TResult orElse(),}){
final _that = this;
switch (_that) {
case RevisionBranch() when branch != null:
return branch(_that);case RevisionCommit() when commit != null:
return commit(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( RevisionBranch value)  branch,required TResult Function( RevisionCommit value)  commit,}){
final _that = this;
switch (_that) {
case RevisionBranch():
return branch(_that);case RevisionCommit():
return commit(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( RevisionBranch value)?  branch,TResult? Function( RevisionCommit value)?  commit,}){
final _that = this;
switch (_that) {
case RevisionBranch() when branch != null:
return branch(_that);case RevisionCommit() when commit != null:
return commit(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( BranchEntity branch)?  branch,TResult Function( CommitEntity commit)?  commit,required TResult orElse(),}) {final _that = this;
switch (_that) {
case RevisionBranch() when branch != null:
return branch(_that.branch);case RevisionCommit() when commit != null:
return commit(_that.commit);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( BranchEntity branch)  branch,required TResult Function( CommitEntity commit)  commit,}) {final _that = this;
switch (_that) {
case RevisionBranch():
return branch(_that.branch);case RevisionCommit():
return commit(_that.commit);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( BranchEntity branch)?  branch,TResult? Function( CommitEntity commit)?  commit,}) {final _that = this;
switch (_that) {
case RevisionBranch() when branch != null:
return branch(_that.branch);case RevisionCommit() when commit != null:
return commit(_that.commit);case _:
  return null;

}
}

}

/// @nodoc


class RevisionBranch extends RevisionValueObject {
  const RevisionBranch(this.branch): super._();
  

 final  BranchEntity branch;

/// Create a copy of RevisionValueObject
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RevisionBranchCopyWith<RevisionBranch> get copyWith => _$RevisionBranchCopyWithImpl<RevisionBranch>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RevisionBranch&&(identical(other.branch, branch) || other.branch == branch));
}


@override
int get hashCode => Object.hash(runtimeType,branch);

@override
String toString() {
  return 'RevisionValueObject.branch(branch: $branch)';
}


}

/// @nodoc
abstract mixin class $RevisionBranchCopyWith<$Res> implements $RevisionValueObjectCopyWith<$Res> {
  factory $RevisionBranchCopyWith(RevisionBranch value, $Res Function(RevisionBranch) _then) = _$RevisionBranchCopyWithImpl;
@useResult
$Res call({
 BranchEntity branch
});


$BranchEntityCopyWith<$Res> get branch;

}
/// @nodoc
class _$RevisionBranchCopyWithImpl<$Res>
    implements $RevisionBranchCopyWith<$Res> {
  _$RevisionBranchCopyWithImpl(this._self, this._then);

  final RevisionBranch _self;
  final $Res Function(RevisionBranch) _then;

/// Create a copy of RevisionValueObject
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? branch = null,}) {
  return _then(RevisionBranch(
null == branch ? _self.branch : branch // ignore: cast_nullable_to_non_nullable
as BranchEntity,
  ));
}

/// Create a copy of RevisionValueObject
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BranchEntityCopyWith<$Res> get branch {
  
  return $BranchEntityCopyWith<$Res>(_self.branch, (value) {
    return _then(_self.copyWith(branch: value));
  });
}
}

/// @nodoc


class RevisionCommit extends RevisionValueObject {
  const RevisionCommit(this.commit): super._();
  

 final  CommitEntity commit;

/// Create a copy of RevisionValueObject
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RevisionCommitCopyWith<RevisionCommit> get copyWith => _$RevisionCommitCopyWithImpl<RevisionCommit>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RevisionCommit&&(identical(other.commit, commit) || other.commit == commit));
}


@override
int get hashCode => Object.hash(runtimeType,commit);

@override
String toString() {
  return 'RevisionValueObject.commit(commit: $commit)';
}


}

/// @nodoc
abstract mixin class $RevisionCommitCopyWith<$Res> implements $RevisionValueObjectCopyWith<$Res> {
  factory $RevisionCommitCopyWith(RevisionCommit value, $Res Function(RevisionCommit) _then) = _$RevisionCommitCopyWithImpl;
@useResult
$Res call({
 CommitEntity commit
});


$CommitEntityCopyWith<$Res> get commit;

}
/// @nodoc
class _$RevisionCommitCopyWithImpl<$Res>
    implements $RevisionCommitCopyWith<$Res> {
  _$RevisionCommitCopyWithImpl(this._self, this._then);

  final RevisionCommit _self;
  final $Res Function(RevisionCommit) _then;

/// Create a copy of RevisionValueObject
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? commit = null,}) {
  return _then(RevisionCommit(
null == commit ? _self.commit : commit // ignore: cast_nullable_to_non_nullable
as CommitEntity,
  ));
}

/// Create a copy of RevisionValueObject
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CommitEntityCopyWith<$Res> get commit {
  
  return $CommitEntityCopyWith<$Res>(_self.commit, (value) {
    return _then(_self.copyWith(commit: value));
  });
}
}

// dart format on
