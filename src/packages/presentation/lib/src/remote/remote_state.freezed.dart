// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'remote_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RemoteState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RemoteState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'RemoteState()';
}


}

/// @nodoc
class $RemoteStateCopyWith<$Res>  {
$RemoteStateCopyWith(RemoteState _, $Res Function(RemoteState) __);
}


/// Adds pattern-matching-related methods to [RemoteState].
extension RemoteStatePatterns on RemoteState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( RemoteIdle value)?  idle,TResult Function( RemoteWorking value)?  working,TResult Function( RemoteRejected value)?  rejected,TResult Function( RemoteFailed value)?  failed,required TResult orElse(),}){
final _that = this;
switch (_that) {
case RemoteIdle() when idle != null:
return idle(_that);case RemoteWorking() when working != null:
return working(_that);case RemoteRejected() when rejected != null:
return rejected(_that);case RemoteFailed() when failed != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( RemoteIdle value)  idle,required TResult Function( RemoteWorking value)  working,required TResult Function( RemoteRejected value)  rejected,required TResult Function( RemoteFailed value)  failed,}){
final _that = this;
switch (_that) {
case RemoteIdle():
return idle(_that);case RemoteWorking():
return working(_that);case RemoteRejected():
return rejected(_that);case RemoteFailed():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( RemoteIdle value)?  idle,TResult? Function( RemoteWorking value)?  working,TResult? Function( RemoteRejected value)?  rejected,TResult? Function( RemoteFailed value)?  failed,}){
final _that = this;
switch (_that) {
case RemoteIdle() when idle != null:
return idle(_that);case RemoteWorking() when working != null:
return working(_that);case RemoteRejected() when rejected != null:
return rejected(_that);case RemoteFailed() when failed != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  idle,TResult Function( RemoteActionEnum action)?  working,TResult Function()?  rejected,TResult Function( RemoteActionEnum action,  AppFailure failure)?  failed,required TResult orElse(),}) {final _that = this;
switch (_that) {
case RemoteIdle() when idle != null:
return idle();case RemoteWorking() when working != null:
return working(_that.action);case RemoteRejected() when rejected != null:
return rejected();case RemoteFailed() when failed != null:
return failed(_that.action,_that.failure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  idle,required TResult Function( RemoteActionEnum action)  working,required TResult Function()  rejected,required TResult Function( RemoteActionEnum action,  AppFailure failure)  failed,}) {final _that = this;
switch (_that) {
case RemoteIdle():
return idle();case RemoteWorking():
return working(_that.action);case RemoteRejected():
return rejected();case RemoteFailed():
return failed(_that.action,_that.failure);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  idle,TResult? Function( RemoteActionEnum action)?  working,TResult? Function()?  rejected,TResult? Function( RemoteActionEnum action,  AppFailure failure)?  failed,}) {final _that = this;
switch (_that) {
case RemoteIdle() when idle != null:
return idle();case RemoteWorking() when working != null:
return working(_that.action);case RemoteRejected() when rejected != null:
return rejected();case RemoteFailed() when failed != null:
return failed(_that.action,_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class RemoteIdle extends RemoteState {
  const RemoteIdle(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RemoteIdle);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'RemoteState.idle()';
}


}




/// @nodoc


class RemoteWorking extends RemoteState {
  const RemoteWorking(this.action): super._();
  

 final  RemoteActionEnum action;

/// Create a copy of RemoteState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RemoteWorkingCopyWith<RemoteWorking> get copyWith => _$RemoteWorkingCopyWithImpl<RemoteWorking>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RemoteWorking&&(identical(other.action, action) || other.action == action));
}


@override
int get hashCode => Object.hash(runtimeType,action);

@override
String toString() {
  return 'RemoteState.working(action: $action)';
}


}

/// @nodoc
abstract mixin class $RemoteWorkingCopyWith<$Res> implements $RemoteStateCopyWith<$Res> {
  factory $RemoteWorkingCopyWith(RemoteWorking value, $Res Function(RemoteWorking) _then) = _$RemoteWorkingCopyWithImpl;
@useResult
$Res call({
 RemoteActionEnum action
});




}
/// @nodoc
class _$RemoteWorkingCopyWithImpl<$Res>
    implements $RemoteWorkingCopyWith<$Res> {
  _$RemoteWorkingCopyWithImpl(this._self, this._then);

  final RemoteWorking _self;
  final $Res Function(RemoteWorking) _then;

/// Create a copy of RemoteState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? action = null,}) {
  return _then(RemoteWorking(
null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as RemoteActionEnum,
  ));
}


}

/// @nodoc


class RemoteRejected extends RemoteState {
  const RemoteRejected(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RemoteRejected);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'RemoteState.rejected()';
}


}




/// @nodoc


class RemoteFailed extends RemoteState {
  const RemoteFailed({required this.action, required this.failure}): super._();
  

 final  RemoteActionEnum action;
 final  AppFailure failure;

/// Create a copy of RemoteState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RemoteFailedCopyWith<RemoteFailed> get copyWith => _$RemoteFailedCopyWithImpl<RemoteFailed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RemoteFailed&&(identical(other.action, action) || other.action == action)&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,action,failure);

@override
String toString() {
  return 'RemoteState.failed(action: $action, failure: $failure)';
}


}

/// @nodoc
abstract mixin class $RemoteFailedCopyWith<$Res> implements $RemoteStateCopyWith<$Res> {
  factory $RemoteFailedCopyWith(RemoteFailed value, $Res Function(RemoteFailed) _then) = _$RemoteFailedCopyWithImpl;
@useResult
$Res call({
 RemoteActionEnum action, AppFailure failure
});




}
/// @nodoc
class _$RemoteFailedCopyWithImpl<$Res>
    implements $RemoteFailedCopyWith<$Res> {
  _$RemoteFailedCopyWithImpl(this._self, this._then);

  final RemoteFailed _self;
  final $Res Function(RemoteFailed) _then;

/// Create a copy of RemoteState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? action = null,Object? failure = null,}) {
  return _then(RemoteFailed(
action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as RemoteActionEnum,failure: null == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as AppFailure,
  ));
}


}

// dart format on
