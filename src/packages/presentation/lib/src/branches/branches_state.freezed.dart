// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'branches_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BranchesState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BranchesState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'BranchesState()';
}


}

/// @nodoc
class $BranchesStateCopyWith<$Res>  {
$BranchesStateCopyWith(BranchesState _, $Res Function(BranchesState) __);
}


/// Adds pattern-matching-related methods to [BranchesState].
extension BranchesStatePatterns on BranchesState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( BranchesInitial value)?  initial,TResult Function( BranchesLoading value)?  loading,TResult Function( BranchesReady value)?  ready,TResult Function( BranchesFailed value)?  failed,required TResult orElse(),}){
final _that = this;
switch (_that) {
case BranchesInitial() when initial != null:
return initial(_that);case BranchesLoading() when loading != null:
return loading(_that);case BranchesReady() when ready != null:
return ready(_that);case BranchesFailed() when failed != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( BranchesInitial value)  initial,required TResult Function( BranchesLoading value)  loading,required TResult Function( BranchesReady value)  ready,required TResult Function( BranchesFailed value)  failed,}){
final _that = this;
switch (_that) {
case BranchesInitial():
return initial(_that);case BranchesLoading():
return loading(_that);case BranchesReady():
return ready(_that);case BranchesFailed():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( BranchesInitial value)?  initial,TResult? Function( BranchesLoading value)?  loading,TResult? Function( BranchesReady value)?  ready,TResult? Function( BranchesFailed value)?  failed,}){
final _that = this;
switch (_that) {
case BranchesInitial() when initial != null:
return initial(_that);case BranchesLoading() when loading != null:
return loading(_that);case BranchesReady() when ready != null:
return ready(_that);case BranchesFailed() when failed != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( List<BranchEntity> branches,  String draft,  bool isCreating,  bool isBusy,  BranchNameValueObject? pending,  AppFailure? failure,  String? rejected)?  ready,TResult Function( AppFailure failure)?  failed,required TResult orElse(),}) {final _that = this;
switch (_that) {
case BranchesInitial() when initial != null:
return initial();case BranchesLoading() when loading != null:
return loading();case BranchesReady() when ready != null:
return ready(_that.branches,_that.draft,_that.isCreating,_that.isBusy,_that.pending,_that.failure,_that.rejected);case BranchesFailed() when failed != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( List<BranchEntity> branches,  String draft,  bool isCreating,  bool isBusy,  BranchNameValueObject? pending,  AppFailure? failure,  String? rejected)  ready,required TResult Function( AppFailure failure)  failed,}) {final _that = this;
switch (_that) {
case BranchesInitial():
return initial();case BranchesLoading():
return loading();case BranchesReady():
return ready(_that.branches,_that.draft,_that.isCreating,_that.isBusy,_that.pending,_that.failure,_that.rejected);case BranchesFailed():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( List<BranchEntity> branches,  String draft,  bool isCreating,  bool isBusy,  BranchNameValueObject? pending,  AppFailure? failure,  String? rejected)?  ready,TResult? Function( AppFailure failure)?  failed,}) {final _that = this;
switch (_that) {
case BranchesInitial() when initial != null:
return initial();case BranchesLoading() when loading != null:
return loading();case BranchesReady() when ready != null:
return ready(_that.branches,_that.draft,_that.isCreating,_that.isBusy,_that.pending,_that.failure,_that.rejected);case BranchesFailed() when failed != null:
return failed(_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class BranchesInitial extends BranchesState {
  const BranchesInitial(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BranchesInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'BranchesState.initial()';
}


}




/// @nodoc


class BranchesLoading extends BranchesState {
  const BranchesLoading(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BranchesLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'BranchesState.loading()';
}


}




/// @nodoc


class BranchesReady extends BranchesState {
  const BranchesReady({required final  List<BranchEntity> branches, this.draft = '', this.isCreating = false, this.isBusy = false, this.pending, this.failure, this.rejected}): _branches = branches,super._();
  

/// Every local branch, in the order git reported them.
 final  List<BranchEntity> _branches;
/// Every local branch, in the order git reported them.
 List<BranchEntity> get branches {
  if (_branches is EqualUnmodifiableListView) return _branches;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_branches);
}

/// What is in the one text box, which means two things.
///
/// While listing it filters; while creating it is the name of the
/// branch about to be started. One box on screen is one string here —
/// two fields for one control is how they come to disagree, and
/// carrying the text across is the useful behaviour anyway: filtering
/// for a branch that turns out not to exist leaves its name typed.
@JsonKey() final  String draft;
/// Whether the surface is naming a new branch rather than choosing one.
@JsonKey() final  bool isCreating;
/// Git is working, so nothing else may be started.
@JsonKey() final  bool isBusy;
/// The branch a switch is waiting to move to, or null when none is.
///
/// Set when switching would silently discard an unsaved buffer: the
/// product asks before, not after
/// (`docs/product/git-workflow/branch-switch/doc.md`), and this is the
/// question standing open.
 final  BranchNameValueObject? pending;
/// Why the last operation did not happen, or null when it did.
 final  AppFailure? failure;
/// What is wrong with the draft as a branch name, or null when nothing is.
///
/// Said while typing rather than after pressing: a name git would refuse
/// is knowable without asking git.
 final  String? rejected;

/// Create a copy of BranchesState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BranchesReadyCopyWith<BranchesReady> get copyWith => _$BranchesReadyCopyWithImpl<BranchesReady>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BranchesReady&&const DeepCollectionEquality().equals(other._branches, _branches)&&(identical(other.draft, draft) || other.draft == draft)&&(identical(other.isCreating, isCreating) || other.isCreating == isCreating)&&(identical(other.isBusy, isBusy) || other.isBusy == isBusy)&&(identical(other.pending, pending) || other.pending == pending)&&(identical(other.failure, failure) || other.failure == failure)&&(identical(other.rejected, rejected) || other.rejected == rejected));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_branches),draft,isCreating,isBusy,pending,failure,rejected);

@override
String toString() {
  return 'BranchesState.ready(branches: $branches, draft: $draft, isCreating: $isCreating, isBusy: $isBusy, pending: $pending, failure: $failure, rejected: $rejected)';
}


}

/// @nodoc
abstract mixin class $BranchesReadyCopyWith<$Res> implements $BranchesStateCopyWith<$Res> {
  factory $BranchesReadyCopyWith(BranchesReady value, $Res Function(BranchesReady) _then) = _$BranchesReadyCopyWithImpl;
@useResult
$Res call({
 List<BranchEntity> branches, String draft, bool isCreating, bool isBusy, BranchNameValueObject? pending, AppFailure? failure, String? rejected
});




}
/// @nodoc
class _$BranchesReadyCopyWithImpl<$Res>
    implements $BranchesReadyCopyWith<$Res> {
  _$BranchesReadyCopyWithImpl(this._self, this._then);

  final BranchesReady _self;
  final $Res Function(BranchesReady) _then;

/// Create a copy of BranchesState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? branches = null,Object? draft = null,Object? isCreating = null,Object? isBusy = null,Object? pending = freezed,Object? failure = freezed,Object? rejected = freezed,}) {
  return _then(BranchesReady(
branches: null == branches ? _self._branches : branches // ignore: cast_nullable_to_non_nullable
as List<BranchEntity>,draft: null == draft ? _self.draft : draft // ignore: cast_nullable_to_non_nullable
as String,isCreating: null == isCreating ? _self.isCreating : isCreating // ignore: cast_nullable_to_non_nullable
as bool,isBusy: null == isBusy ? _self.isBusy : isBusy // ignore: cast_nullable_to_non_nullable
as bool,pending: freezed == pending ? _self.pending : pending // ignore: cast_nullable_to_non_nullable
as BranchNameValueObject?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as AppFailure?,rejected: freezed == rejected ? _self.rejected : rejected // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class BranchesFailed extends BranchesState {
  const BranchesFailed(this.failure): super._();
  

 final  AppFailure failure;

/// Create a copy of BranchesState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BranchesFailedCopyWith<BranchesFailed> get copyWith => _$BranchesFailedCopyWithImpl<BranchesFailed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BranchesFailed&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,failure);

@override
String toString() {
  return 'BranchesState.failed(failure: $failure)';
}


}

/// @nodoc
abstract mixin class $BranchesFailedCopyWith<$Res> implements $BranchesStateCopyWith<$Res> {
  factory $BranchesFailedCopyWith(BranchesFailed value, $Res Function(BranchesFailed) _then) = _$BranchesFailedCopyWithImpl;
@useResult
$Res call({
 AppFailure failure
});




}
/// @nodoc
class _$BranchesFailedCopyWithImpl<$Res>
    implements $BranchesFailedCopyWith<$Res> {
  _$BranchesFailedCopyWithImpl(this._self, this._then);

  final BranchesFailed _self;
  final $Res Function(BranchesFailed) _then;

/// Create a copy of BranchesState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? failure = null,}) {
  return _then(BranchesFailed(
null == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as AppFailure,
  ));
}


}

// dart format on
