// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'git_reading_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GitReadingState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GitReadingState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GitReadingState()';
}


}

/// @nodoc
class $GitReadingStateCopyWith<$Res>  {
$GitReadingStateCopyWith(GitReadingState _, $Res Function(GitReadingState) __);
}


/// Adds pattern-matching-related methods to [GitReadingState].
extension GitReadingStatePatterns on GitReadingState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( GitReadingInitial value)?  initial,TResult Function( GitReadingLoading value)?  loading,TResult Function( GitReadingReady value)?  ready,TResult Function( GitReadingStale value)?  stale,TResult Function( GitReadingFailed value)?  failed,required TResult orElse(),}){
final _that = this;
switch (_that) {
case GitReadingInitial() when initial != null:
return initial(_that);case GitReadingLoading() when loading != null:
return loading(_that);case GitReadingReady() when ready != null:
return ready(_that);case GitReadingStale() when stale != null:
return stale(_that);case GitReadingFailed() when failed != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( GitReadingInitial value)  initial,required TResult Function( GitReadingLoading value)  loading,required TResult Function( GitReadingReady value)  ready,required TResult Function( GitReadingStale value)  stale,required TResult Function( GitReadingFailed value)  failed,}){
final _that = this;
switch (_that) {
case GitReadingInitial():
return initial(_that);case GitReadingLoading():
return loading(_that);case GitReadingReady():
return ready(_that);case GitReadingStale():
return stale(_that);case GitReadingFailed():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( GitReadingInitial value)?  initial,TResult? Function( GitReadingLoading value)?  loading,TResult? Function( GitReadingReady value)?  ready,TResult? Function( GitReadingStale value)?  stale,TResult? Function( GitReadingFailed value)?  failed,}){
final _that = this;
switch (_that) {
case GitReadingInitial() when initial != null:
return initial(_that);case GitReadingLoading() when loading != null:
return loading(_that);case GitReadingReady() when ready != null:
return ready(_that);case GitReadingStale() when stale != null:
return stale(_that);case GitReadingFailed() when failed != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function()?  ready,TResult Function()?  stale,TResult Function( AppFailure failure)?  failed,required TResult orElse(),}) {final _that = this;
switch (_that) {
case GitReadingInitial() when initial != null:
return initial();case GitReadingLoading() when loading != null:
return loading();case GitReadingReady() when ready != null:
return ready();case GitReadingStale() when stale != null:
return stale();case GitReadingFailed() when failed != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function()  ready,required TResult Function()  stale,required TResult Function( AppFailure failure)  failed,}) {final _that = this;
switch (_that) {
case GitReadingInitial():
return initial();case GitReadingLoading():
return loading();case GitReadingReady():
return ready();case GitReadingStale():
return stale();case GitReadingFailed():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function()?  ready,TResult? Function()?  stale,TResult? Function( AppFailure failure)?  failed,}) {final _that = this;
switch (_that) {
case GitReadingInitial() when initial != null:
return initial();case GitReadingLoading() when loading != null:
return loading();case GitReadingReady() when ready != null:
return ready();case GitReadingStale() when stale != null:
return stale();case GitReadingFailed() when failed != null:
return failed(_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class GitReadingInitial implements GitReadingState {
  const GitReadingInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GitReadingInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GitReadingState.initial()';
}


}




/// @nodoc


class GitReadingLoading implements GitReadingState {
  const GitReadingLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GitReadingLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GitReadingState.loading()';
}


}




/// @nodoc


class GitReadingReady implements GitReadingState {
  const GitReadingReady();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GitReadingReady);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GitReadingState.ready()';
}


}




/// @nodoc


class GitReadingStale implements GitReadingState {
  const GitReadingStale();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GitReadingStale);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GitReadingState.stale()';
}


}




/// @nodoc


class GitReadingFailed implements GitReadingState {
  const GitReadingFailed(this.failure);
  

 final  AppFailure failure;

/// Create a copy of GitReadingState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GitReadingFailedCopyWith<GitReadingFailed> get copyWith => _$GitReadingFailedCopyWithImpl<GitReadingFailed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GitReadingFailed&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,failure);

@override
String toString() {
  return 'GitReadingState.failed(failure: $failure)';
}


}

/// @nodoc
abstract mixin class $GitReadingFailedCopyWith<$Res> implements $GitReadingStateCopyWith<$Res> {
  factory $GitReadingFailedCopyWith(GitReadingFailed value, $Res Function(GitReadingFailed) _then) = _$GitReadingFailedCopyWithImpl;
@useResult
$Res call({
 AppFailure failure
});




}
/// @nodoc
class _$GitReadingFailedCopyWithImpl<$Res>
    implements $GitReadingFailedCopyWith<$Res> {
  _$GitReadingFailedCopyWithImpl(this._self, this._then);

  final GitReadingFailed _self;
  final $Res Function(GitReadingFailed) _then;

/// Create a copy of GitReadingState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? failure = null,}) {
  return _then(GitReadingFailed(
null == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as AppFailure,
  ));
}


}

// dart format on
