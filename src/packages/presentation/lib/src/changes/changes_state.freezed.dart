// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'changes_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChangesState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChangesState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ChangesState()';
}


}

/// @nodoc
class $ChangesStateCopyWith<$Res>  {
$ChangesStateCopyWith(ChangesState _, $Res Function(ChangesState) __);
}


/// Adds pattern-matching-related methods to [ChangesState].
extension ChangesStatePatterns on ChangesState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ChangesInitial value)?  initial,TResult Function( ChangesLoading value)?  loading,TResult Function( ChangesReady value)?  ready,TResult Function( ChangesFailed value)?  failed,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ChangesInitial() when initial != null:
return initial(_that);case ChangesLoading() when loading != null:
return loading(_that);case ChangesReady() when ready != null:
return ready(_that);case ChangesFailed() when failed != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ChangesInitial value)  initial,required TResult Function( ChangesLoading value)  loading,required TResult Function( ChangesReady value)  ready,required TResult Function( ChangesFailed value)  failed,}){
final _that = this;
switch (_that) {
case ChangesInitial():
return initial(_that);case ChangesLoading():
return loading(_that);case ChangesReady():
return ready(_that);case ChangesFailed():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ChangesInitial value)?  initial,TResult? Function( ChangesLoading value)?  loading,TResult? Function( ChangesReady value)?  ready,TResult? Function( ChangesFailed value)?  failed,}){
final _that = this;
switch (_that) {
case ChangesInitial() when initial != null:
return initial(_that);case ChangesLoading() when loading != null:
return loading(_that);case ChangesReady() when ready != null:
return ready(_that);case ChangesFailed() when failed != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( String message,  bool isBusy,  AppFailure? failure)?  ready,TResult Function( AppFailure failure)?  failed,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ChangesInitial() when initial != null:
return initial();case ChangesLoading() when loading != null:
return loading();case ChangesReady() when ready != null:
return ready(_that.message,_that.isBusy,_that.failure);case ChangesFailed() when failed != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( String message,  bool isBusy,  AppFailure? failure)  ready,required TResult Function( AppFailure failure)  failed,}) {final _that = this;
switch (_that) {
case ChangesInitial():
return initial();case ChangesLoading():
return loading();case ChangesReady():
return ready(_that.message,_that.isBusy,_that.failure);case ChangesFailed():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( String message,  bool isBusy,  AppFailure? failure)?  ready,TResult? Function( AppFailure failure)?  failed,}) {final _that = this;
switch (_that) {
case ChangesInitial() when initial != null:
return initial();case ChangesLoading() when loading != null:
return loading();case ChangesReady() when ready != null:
return ready(_that.message,_that.isBusy,_that.failure);case ChangesFailed() when failed != null:
return failed(_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class ChangesInitial implements ChangesState {
  const ChangesInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChangesInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ChangesState.initial()';
}


}




/// @nodoc


class ChangesLoading implements ChangesState {
  const ChangesLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChangesLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ChangesState.loading()';
}


}




/// @nodoc


class ChangesReady implements ChangesState {
  const ChangesReady({this.message = '', this.isBusy = false, this.failure});
  

/// The commit message being written.
///
/// Panel-local on purpose: an unsent message is a draft, and nothing
/// outside this panel has an opinion about it.
@JsonKey() final  String message;
/// Whether a stage, an unstage or a commit is in flight.
///
/// One flag for all three: git is serialized per space underneath, so a
/// second operation would queue behind the first anyway, and a panel
/// that let one be started twice would just be lying about it.
@JsonKey() final  bool isBusy;
/// Why the last operation did not land, or null when it did.
///
/// A commit that failed silently is as bad as a save that did: the work
/// is still only in the working tree.
 final  AppFailure? failure;

/// Create a copy of ChangesState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChangesReadyCopyWith<ChangesReady> get copyWith => _$ChangesReadyCopyWithImpl<ChangesReady>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChangesReady&&(identical(other.message, message) || other.message == message)&&(identical(other.isBusy, isBusy) || other.isBusy == isBusy)&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,message,isBusy,failure);

@override
String toString() {
  return 'ChangesState.ready(message: $message, isBusy: $isBusy, failure: $failure)';
}


}

/// @nodoc
abstract mixin class $ChangesReadyCopyWith<$Res> implements $ChangesStateCopyWith<$Res> {
  factory $ChangesReadyCopyWith(ChangesReady value, $Res Function(ChangesReady) _then) = _$ChangesReadyCopyWithImpl;
@useResult
$Res call({
 String message, bool isBusy, AppFailure? failure
});




}
/// @nodoc
class _$ChangesReadyCopyWithImpl<$Res>
    implements $ChangesReadyCopyWith<$Res> {
  _$ChangesReadyCopyWithImpl(this._self, this._then);

  final ChangesReady _self;
  final $Res Function(ChangesReady) _then;

/// Create a copy of ChangesState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,Object? isBusy = null,Object? failure = freezed,}) {
  return _then(ChangesReady(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,isBusy: null == isBusy ? _self.isBusy : isBusy // ignore: cast_nullable_to_non_nullable
as bool,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}


}

/// @nodoc


class ChangesFailed implements ChangesState {
  const ChangesFailed(this.failure);
  

 final  AppFailure failure;

/// Create a copy of ChangesState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChangesFailedCopyWith<ChangesFailed> get copyWith => _$ChangesFailedCopyWithImpl<ChangesFailed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChangesFailed&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,failure);

@override
String toString() {
  return 'ChangesState.failed(failure: $failure)';
}


}

/// @nodoc
abstract mixin class $ChangesFailedCopyWith<$Res> implements $ChangesStateCopyWith<$Res> {
  factory $ChangesFailedCopyWith(ChangesFailed value, $Res Function(ChangesFailed) _then) = _$ChangesFailedCopyWithImpl;
@useResult
$Res call({
 AppFailure failure
});




}
/// @nodoc
class _$ChangesFailedCopyWithImpl<$Res>
    implements $ChangesFailedCopyWith<$Res> {
  _$ChangesFailedCopyWithImpl(this._self, this._then);

  final ChangesFailed _self;
  final $Res Function(ChangesFailed) _then;

/// Create a copy of ChangesState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? failure = null,}) {
  return _then(ChangesFailed(
null == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as AppFailure,
  ));
}


}

// dart format on
