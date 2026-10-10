// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pull_request_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PullRequestState {

/// The remote's project and its own branch, or null until git answered.
 PullRequestTargetValueObject? get target;/// The commits and changes over the base, or null until read.
 BranchProposalValueObject? get proposal;/// The overview, or null until read.
 BranchOverviewValueObject? get overview;/// What the base can be: the remote's own branch first, then every
/// other local branch but the one proposed.
 List<BranchNameValueObject> get bases;/// Which segment the right column shows.
 PullRequestSegmentEnum get segment;/// Why the last reading or the last press did not work, or null.
 AppFailure? get failure;/// Why [target] could not be read, or null — what tells a folder with no
/// repository from one git could not read.
 AppFailure? get targetFailure;/// Whether `gh` answered for this branch, so the pull request can be
/// created from here rather than only on the host's page.
 bool get throughGh;/// The pull request the branch already has, or null.
 OpenedPullRequestValueObject? get opened;/// Whether `Create pull request` is running.
 bool get creating;/// Why the last `Create pull request` did not open one, or null.
 AppFailure? get createFailure;
/// Create a copy of PullRequestState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PullRequestStateCopyWith<PullRequestState> get copyWith => _$PullRequestStateCopyWithImpl<PullRequestState>(this as PullRequestState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PullRequestState&&(identical(other.target, target) || other.target == target)&&(identical(other.proposal, proposal) || other.proposal == proposal)&&(identical(other.overview, overview) || other.overview == overview)&&const DeepCollectionEquality().equals(other.bases, bases)&&(identical(other.segment, segment) || other.segment == segment)&&(identical(other.failure, failure) || other.failure == failure)&&(identical(other.targetFailure, targetFailure) || other.targetFailure == targetFailure)&&(identical(other.throughGh, throughGh) || other.throughGh == throughGh)&&(identical(other.opened, opened) || other.opened == opened)&&(identical(other.creating, creating) || other.creating == creating)&&(identical(other.createFailure, createFailure) || other.createFailure == createFailure));
}


@override
int get hashCode => Object.hash(runtimeType,target,proposal,overview,const DeepCollectionEquality().hash(bases),segment,failure,targetFailure,throughGh,opened,creating,createFailure);

@override
String toString() {
  return 'PullRequestState(target: $target, proposal: $proposal, overview: $overview, bases: $bases, segment: $segment, failure: $failure, targetFailure: $targetFailure, throughGh: $throughGh, opened: $opened, creating: $creating, createFailure: $createFailure)';
}


}

/// @nodoc
abstract mixin class $PullRequestStateCopyWith<$Res>  {
  factory $PullRequestStateCopyWith(PullRequestState value, $Res Function(PullRequestState) _then) = _$PullRequestStateCopyWithImpl;
@useResult
$Res call({
 PullRequestTargetValueObject? target, BranchProposalValueObject? proposal, BranchOverviewValueObject? overview, List<BranchNameValueObject> bases, PullRequestSegmentEnum segment, AppFailure? failure, AppFailure? targetFailure, bool throughGh, OpenedPullRequestValueObject? opened, bool creating, AppFailure? createFailure
});


$PullRequestTargetValueObjectCopyWith<$Res>? get target;$BranchProposalValueObjectCopyWith<$Res>? get proposal;$BranchOverviewValueObjectCopyWith<$Res>? get overview;$OpenedPullRequestValueObjectCopyWith<$Res>? get opened;

}
/// @nodoc
class _$PullRequestStateCopyWithImpl<$Res>
    implements $PullRequestStateCopyWith<$Res> {
  _$PullRequestStateCopyWithImpl(this._self, this._then);

  final PullRequestState _self;
  final $Res Function(PullRequestState) _then;

/// Create a copy of PullRequestState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? target = freezed,Object? proposal = freezed,Object? overview = freezed,Object? bases = null,Object? segment = null,Object? failure = freezed,Object? targetFailure = freezed,Object? throughGh = null,Object? opened = freezed,Object? creating = null,Object? createFailure = freezed,}) {
  return _then(_self.copyWith(
target: freezed == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as PullRequestTargetValueObject?,proposal: freezed == proposal ? _self.proposal : proposal // ignore: cast_nullable_to_non_nullable
as BranchProposalValueObject?,overview: freezed == overview ? _self.overview : overview // ignore: cast_nullable_to_non_nullable
as BranchOverviewValueObject?,bases: null == bases ? _self.bases : bases // ignore: cast_nullable_to_non_nullable
as List<BranchNameValueObject>,segment: null == segment ? _self.segment : segment // ignore: cast_nullable_to_non_nullable
as PullRequestSegmentEnum,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as AppFailure?,targetFailure: freezed == targetFailure ? _self.targetFailure : targetFailure // ignore: cast_nullable_to_non_nullable
as AppFailure?,throughGh: null == throughGh ? _self.throughGh : throughGh // ignore: cast_nullable_to_non_nullable
as bool,opened: freezed == opened ? _self.opened : opened // ignore: cast_nullable_to_non_nullable
as OpenedPullRequestValueObject?,creating: null == creating ? _self.creating : creating // ignore: cast_nullable_to_non_nullable
as bool,createFailure: freezed == createFailure ? _self.createFailure : createFailure // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}
/// Create a copy of PullRequestState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PullRequestTargetValueObjectCopyWith<$Res>? get target {
    if (_self.target == null) {
    return null;
  }

  return $PullRequestTargetValueObjectCopyWith<$Res>(_self.target!, (value) {
    return _then(_self.copyWith(target: value));
  });
}/// Create a copy of PullRequestState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BranchProposalValueObjectCopyWith<$Res>? get proposal {
    if (_self.proposal == null) {
    return null;
  }

  return $BranchProposalValueObjectCopyWith<$Res>(_self.proposal!, (value) {
    return _then(_self.copyWith(proposal: value));
  });
}/// Create a copy of PullRequestState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BranchOverviewValueObjectCopyWith<$Res>? get overview {
    if (_self.overview == null) {
    return null;
  }

  return $BranchOverviewValueObjectCopyWith<$Res>(_self.overview!, (value) {
    return _then(_self.copyWith(overview: value));
  });
}/// Create a copy of PullRequestState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OpenedPullRequestValueObjectCopyWith<$Res>? get opened {
    if (_self.opened == null) {
    return null;
  }

  return $OpenedPullRequestValueObjectCopyWith<$Res>(_self.opened!, (value) {
    return _then(_self.copyWith(opened: value));
  });
}
}


/// Adds pattern-matching-related methods to [PullRequestState].
extension PullRequestStatePatterns on PullRequestState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PullRequestState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PullRequestState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PullRequestState value)  $default,){
final _that = this;
switch (_that) {
case _PullRequestState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PullRequestState value)?  $default,){
final _that = this;
switch (_that) {
case _PullRequestState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PullRequestTargetValueObject? target,  BranchProposalValueObject? proposal,  BranchOverviewValueObject? overview,  List<BranchNameValueObject> bases,  PullRequestSegmentEnum segment,  AppFailure? failure,  AppFailure? targetFailure,  bool throughGh,  OpenedPullRequestValueObject? opened,  bool creating,  AppFailure? createFailure)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PullRequestState() when $default != null:
return $default(_that.target,_that.proposal,_that.overview,_that.bases,_that.segment,_that.failure,_that.targetFailure,_that.throughGh,_that.opened,_that.creating,_that.createFailure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PullRequestTargetValueObject? target,  BranchProposalValueObject? proposal,  BranchOverviewValueObject? overview,  List<BranchNameValueObject> bases,  PullRequestSegmentEnum segment,  AppFailure? failure,  AppFailure? targetFailure,  bool throughGh,  OpenedPullRequestValueObject? opened,  bool creating,  AppFailure? createFailure)  $default,) {final _that = this;
switch (_that) {
case _PullRequestState():
return $default(_that.target,_that.proposal,_that.overview,_that.bases,_that.segment,_that.failure,_that.targetFailure,_that.throughGh,_that.opened,_that.creating,_that.createFailure);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PullRequestTargetValueObject? target,  BranchProposalValueObject? proposal,  BranchOverviewValueObject? overview,  List<BranchNameValueObject> bases,  PullRequestSegmentEnum segment,  AppFailure? failure,  AppFailure? targetFailure,  bool throughGh,  OpenedPullRequestValueObject? opened,  bool creating,  AppFailure? createFailure)?  $default,) {final _that = this;
switch (_that) {
case _PullRequestState() when $default != null:
return $default(_that.target,_that.proposal,_that.overview,_that.bases,_that.segment,_that.failure,_that.targetFailure,_that.throughGh,_that.opened,_that.creating,_that.createFailure);case _:
  return null;

}
}

}

/// @nodoc


class _PullRequestState extends PullRequestState {
  const _PullRequestState({this.target, this.proposal, this.overview, final  List<BranchNameValueObject> bases = const <BranchNameValueObject>[], this.segment = PullRequestSegmentEnum.proposal, this.failure, this.targetFailure, this.throughGh = false, this.opened, this.creating = false, this.createFailure}): _bases = bases,super._();
  

/// The remote's project and its own branch, or null until git answered.
@override final  PullRequestTargetValueObject? target;
/// The commits and changes over the base, or null until read.
@override final  BranchProposalValueObject? proposal;
/// The overview, or null until read.
@override final  BranchOverviewValueObject? overview;
/// What the base can be: the remote's own branch first, then every
/// other local branch but the one proposed.
 final  List<BranchNameValueObject> _bases;
/// What the base can be: the remote's own branch first, then every
/// other local branch but the one proposed.
@override@JsonKey() List<BranchNameValueObject> get bases {
  if (_bases is EqualUnmodifiableListView) return _bases;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_bases);
}

/// Which segment the right column shows.
@override@JsonKey() final  PullRequestSegmentEnum segment;
/// Why the last reading or the last press did not work, or null.
@override final  AppFailure? failure;
/// Why [target] could not be read, or null — what tells a folder with no
/// repository from one git could not read.
@override final  AppFailure? targetFailure;
/// Whether `gh` answered for this branch, so the pull request can be
/// created from here rather than only on the host's page.
@override@JsonKey() final  bool throughGh;
/// The pull request the branch already has, or null.
@override final  OpenedPullRequestValueObject? opened;
/// Whether `Create pull request` is running.
@override@JsonKey() final  bool creating;
/// Why the last `Create pull request` did not open one, or null.
@override final  AppFailure? createFailure;

/// Create a copy of PullRequestState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PullRequestStateCopyWith<_PullRequestState> get copyWith => __$PullRequestStateCopyWithImpl<_PullRequestState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PullRequestState&&(identical(other.target, target) || other.target == target)&&(identical(other.proposal, proposal) || other.proposal == proposal)&&(identical(other.overview, overview) || other.overview == overview)&&const DeepCollectionEquality().equals(other._bases, _bases)&&(identical(other.segment, segment) || other.segment == segment)&&(identical(other.failure, failure) || other.failure == failure)&&(identical(other.targetFailure, targetFailure) || other.targetFailure == targetFailure)&&(identical(other.throughGh, throughGh) || other.throughGh == throughGh)&&(identical(other.opened, opened) || other.opened == opened)&&(identical(other.creating, creating) || other.creating == creating)&&(identical(other.createFailure, createFailure) || other.createFailure == createFailure));
}


@override
int get hashCode => Object.hash(runtimeType,target,proposal,overview,const DeepCollectionEquality().hash(_bases),segment,failure,targetFailure,throughGh,opened,creating,createFailure);

@override
String toString() {
  return 'PullRequestState(target: $target, proposal: $proposal, overview: $overview, bases: $bases, segment: $segment, failure: $failure, targetFailure: $targetFailure, throughGh: $throughGh, opened: $opened, creating: $creating, createFailure: $createFailure)';
}


}

/// @nodoc
abstract mixin class _$PullRequestStateCopyWith<$Res> implements $PullRequestStateCopyWith<$Res> {
  factory _$PullRequestStateCopyWith(_PullRequestState value, $Res Function(_PullRequestState) _then) = __$PullRequestStateCopyWithImpl;
@override @useResult
$Res call({
 PullRequestTargetValueObject? target, BranchProposalValueObject? proposal, BranchOverviewValueObject? overview, List<BranchNameValueObject> bases, PullRequestSegmentEnum segment, AppFailure? failure, AppFailure? targetFailure, bool throughGh, OpenedPullRequestValueObject? opened, bool creating, AppFailure? createFailure
});


@override $PullRequestTargetValueObjectCopyWith<$Res>? get target;@override $BranchProposalValueObjectCopyWith<$Res>? get proposal;@override $BranchOverviewValueObjectCopyWith<$Res>? get overview;@override $OpenedPullRequestValueObjectCopyWith<$Res>? get opened;

}
/// @nodoc
class __$PullRequestStateCopyWithImpl<$Res>
    implements _$PullRequestStateCopyWith<$Res> {
  __$PullRequestStateCopyWithImpl(this._self, this._then);

  final _PullRequestState _self;
  final $Res Function(_PullRequestState) _then;

/// Create a copy of PullRequestState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? target = freezed,Object? proposal = freezed,Object? overview = freezed,Object? bases = null,Object? segment = null,Object? failure = freezed,Object? targetFailure = freezed,Object? throughGh = null,Object? opened = freezed,Object? creating = null,Object? createFailure = freezed,}) {
  return _then(_PullRequestState(
target: freezed == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as PullRequestTargetValueObject?,proposal: freezed == proposal ? _self.proposal : proposal // ignore: cast_nullable_to_non_nullable
as BranchProposalValueObject?,overview: freezed == overview ? _self.overview : overview // ignore: cast_nullable_to_non_nullable
as BranchOverviewValueObject?,bases: null == bases ? _self._bases : bases // ignore: cast_nullable_to_non_nullable
as List<BranchNameValueObject>,segment: null == segment ? _self.segment : segment // ignore: cast_nullable_to_non_nullable
as PullRequestSegmentEnum,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as AppFailure?,targetFailure: freezed == targetFailure ? _self.targetFailure : targetFailure // ignore: cast_nullable_to_non_nullable
as AppFailure?,throughGh: null == throughGh ? _self.throughGh : throughGh // ignore: cast_nullable_to_non_nullable
as bool,opened: freezed == opened ? _self.opened : opened // ignore: cast_nullable_to_non_nullable
as OpenedPullRequestValueObject?,creating: null == creating ? _self.creating : creating // ignore: cast_nullable_to_non_nullable
as bool,createFailure: freezed == createFailure ? _self.createFailure : createFailure // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}

/// Create a copy of PullRequestState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PullRequestTargetValueObjectCopyWith<$Res>? get target {
    if (_self.target == null) {
    return null;
  }

  return $PullRequestTargetValueObjectCopyWith<$Res>(_self.target!, (value) {
    return _then(_self.copyWith(target: value));
  });
}/// Create a copy of PullRequestState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BranchProposalValueObjectCopyWith<$Res>? get proposal {
    if (_self.proposal == null) {
    return null;
  }

  return $BranchProposalValueObjectCopyWith<$Res>(_self.proposal!, (value) {
    return _then(_self.copyWith(proposal: value));
  });
}/// Create a copy of PullRequestState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BranchOverviewValueObjectCopyWith<$Res>? get overview {
    if (_self.overview == null) {
    return null;
  }

  return $BranchOverviewValueObjectCopyWith<$Res>(_self.overview!, (value) {
    return _then(_self.copyWith(overview: value));
  });
}/// Create a copy of PullRequestState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OpenedPullRequestValueObjectCopyWith<$Res>? get opened {
    if (_self.opened == null) {
    return null;
  }

  return $OpenedPullRequestValueObjectCopyWith<$Res>(_self.opened!, (value) {
    return _then(_self.copyWith(opened: value));
  });
}
}

// dart format on
