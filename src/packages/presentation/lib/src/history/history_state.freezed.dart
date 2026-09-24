// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'history_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HistoryState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HistoryState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'HistoryState()';
}


}

/// @nodoc
class $HistoryStateCopyWith<$Res>  {
$HistoryStateCopyWith(HistoryState _, $Res Function(HistoryState) __);
}


/// Adds pattern-matching-related methods to [HistoryState].
extension HistoryStatePatterns on HistoryState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( HistoryIdle value)?  idle,TResult Function( HistoryLoading value)?  loading,TResult Function( HistoryReady value)?  ready,TResult Function( HistoryFailed value)?  failed,required TResult orElse(),}){
final _that = this;
switch (_that) {
case HistoryIdle() when idle != null:
return idle(_that);case HistoryLoading() when loading != null:
return loading(_that);case HistoryReady() when ready != null:
return ready(_that);case HistoryFailed() when failed != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( HistoryIdle value)  idle,required TResult Function( HistoryLoading value)  loading,required TResult Function( HistoryReady value)  ready,required TResult Function( HistoryFailed value)  failed,}){
final _that = this;
switch (_that) {
case HistoryIdle():
return idle(_that);case HistoryLoading():
return loading(_that);case HistoryReady():
return ready(_that);case HistoryFailed():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( HistoryIdle value)?  idle,TResult? Function( HistoryLoading value)?  loading,TResult? Function( HistoryReady value)?  ready,TResult? Function( HistoryFailed value)?  failed,}){
final _that = this;
switch (_that) {
case HistoryIdle() when idle != null:
return idle(_that);case HistoryLoading() when loading != null:
return loading(_that);case HistoryReady() when ready != null:
return ready(_that);case HistoryFailed() when failed != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  idle,TResult Function()?  loading,TResult Function( List<CommitEntity> commits)?  ready,TResult Function( AppFailure failure)?  failed,required TResult orElse(),}) {final _that = this;
switch (_that) {
case HistoryIdle() when idle != null:
return idle();case HistoryLoading() when loading != null:
return loading();case HistoryReady() when ready != null:
return ready(_that.commits);case HistoryFailed() when failed != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  idle,required TResult Function()  loading,required TResult Function( List<CommitEntity> commits)  ready,required TResult Function( AppFailure failure)  failed,}) {final _that = this;
switch (_that) {
case HistoryIdle():
return idle();case HistoryLoading():
return loading();case HistoryReady():
return ready(_that.commits);case HistoryFailed():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  idle,TResult? Function()?  loading,TResult? Function( List<CommitEntity> commits)?  ready,TResult? Function( AppFailure failure)?  failed,}) {final _that = this;
switch (_that) {
case HistoryIdle() when idle != null:
return idle();case HistoryLoading() when loading != null:
return loading();case HistoryReady() when ready != null:
return ready(_that.commits);case HistoryFailed() when failed != null:
return failed(_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class HistoryIdle implements HistoryState {
  const HistoryIdle();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HistoryIdle);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'HistoryState.idle()';
}


}




/// @nodoc


class HistoryLoading implements HistoryState {
  const HistoryLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HistoryLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'HistoryState.loading()';
}


}




/// @nodoc


class HistoryReady implements HistoryState {
  const HistoryReady(final  List<CommitEntity> commits): _commits = commits;
  

 final  List<CommitEntity> _commits;
 List<CommitEntity> get commits {
  if (_commits is EqualUnmodifiableListView) return _commits;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_commits);
}


/// Create a copy of HistoryState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HistoryReadyCopyWith<HistoryReady> get copyWith => _$HistoryReadyCopyWithImpl<HistoryReady>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HistoryReady&&const DeepCollectionEquality().equals(other._commits, _commits));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_commits));

@override
String toString() {
  return 'HistoryState.ready(commits: $commits)';
}


}

/// @nodoc
abstract mixin class $HistoryReadyCopyWith<$Res> implements $HistoryStateCopyWith<$Res> {
  factory $HistoryReadyCopyWith(HistoryReady value, $Res Function(HistoryReady) _then) = _$HistoryReadyCopyWithImpl;
@useResult
$Res call({
 List<CommitEntity> commits
});




}
/// @nodoc
class _$HistoryReadyCopyWithImpl<$Res>
    implements $HistoryReadyCopyWith<$Res> {
  _$HistoryReadyCopyWithImpl(this._self, this._then);

  final HistoryReady _self;
  final $Res Function(HistoryReady) _then;

/// Create a copy of HistoryState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? commits = null,}) {
  return _then(HistoryReady(
null == commits ? _self._commits : commits // ignore: cast_nullable_to_non_nullable
as List<CommitEntity>,
  ));
}


}

/// @nodoc


class HistoryFailed implements HistoryState {
  const HistoryFailed(this.failure);
  

 final  AppFailure failure;

/// Create a copy of HistoryState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HistoryFailedCopyWith<HistoryFailed> get copyWith => _$HistoryFailedCopyWithImpl<HistoryFailed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HistoryFailed&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,failure);

@override
String toString() {
  return 'HistoryState.failed(failure: $failure)';
}


}

/// @nodoc
abstract mixin class $HistoryFailedCopyWith<$Res> implements $HistoryStateCopyWith<$Res> {
  factory $HistoryFailedCopyWith(HistoryFailed value, $Res Function(HistoryFailed) _then) = _$HistoryFailedCopyWithImpl;
@useResult
$Res call({
 AppFailure failure
});




}
/// @nodoc
class _$HistoryFailedCopyWithImpl<$Res>
    implements $HistoryFailedCopyWith<$Res> {
  _$HistoryFailedCopyWithImpl(this._self, this._then);

  final HistoryFailed _self;
  final $Res Function(HistoryFailed) _then;

/// Create a copy of HistoryState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? failure = null,}) {
  return _then(HistoryFailed(
null == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as AppFailure,
  ));
}


}

// dart format on
