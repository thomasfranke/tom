// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pull_request_host_failure.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PullRequestHostFailure {

 AppFailure? get cause;
/// Create a copy of PullRequestHostFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PullRequestHostFailureCopyWith<PullRequestHostFailure> get copyWith => _$PullRequestHostFailureCopyWithImpl<PullRequestHostFailure>(this as PullRequestHostFailure, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PullRequestHostFailure&&(identical(other.cause, cause) || other.cause == cause));
}


@override
int get hashCode => Object.hash(runtimeType,cause);

@override
String toString() {
  return 'PullRequestHostFailure(cause: $cause)';
}


}

/// @nodoc
abstract mixin class $PullRequestHostFailureCopyWith<$Res>  {
  factory $PullRequestHostFailureCopyWith(PullRequestHostFailure value, $Res Function(PullRequestHostFailure) _then) = _$PullRequestHostFailureCopyWithImpl;
@useResult
$Res call({
 AppFailure? cause
});




}
/// @nodoc
class _$PullRequestHostFailureCopyWithImpl<$Res>
    implements $PullRequestHostFailureCopyWith<$Res> {
  _$PullRequestHostFailureCopyWithImpl(this._self, this._then);

  final PullRequestHostFailure _self;
  final $Res Function(PullRequestHostFailure) _then;

/// Create a copy of PullRequestHostFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? cause = freezed,}) {
  return _then(_self.copyWith(
cause: freezed == cause ? _self.cause : cause // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}

}


/// Adds pattern-matching-related methods to [PullRequestHostFailure].
extension PullRequestHostFailurePatterns on PullRequestHostFailure {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( PullRequestHostUnavailable value)?  unavailable,TResult Function( PullRequestHostUnreachable value)?  unreachable,TResult Function( PullRequestHostRefused value)?  refused,TResult Function( PullRequestHostDenied value)?  denied,TResult Function( PullRequestHostOperationFailed value)?  operationFailed,required TResult orElse(),}){
final _that = this;
switch (_that) {
case PullRequestHostUnavailable() when unavailable != null:
return unavailable(_that);case PullRequestHostUnreachable() when unreachable != null:
return unreachable(_that);case PullRequestHostRefused() when refused != null:
return refused(_that);case PullRequestHostDenied() when denied != null:
return denied(_that);case PullRequestHostOperationFailed() when operationFailed != null:
return operationFailed(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( PullRequestHostUnavailable value)  unavailable,required TResult Function( PullRequestHostUnreachable value)  unreachable,required TResult Function( PullRequestHostRefused value)  refused,required TResult Function( PullRequestHostDenied value)  denied,required TResult Function( PullRequestHostOperationFailed value)  operationFailed,}){
final _that = this;
switch (_that) {
case PullRequestHostUnavailable():
return unavailable(_that);case PullRequestHostUnreachable():
return unreachable(_that);case PullRequestHostRefused():
return refused(_that);case PullRequestHostDenied():
return denied(_that);case PullRequestHostOperationFailed():
return operationFailed(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( PullRequestHostUnavailable value)?  unavailable,TResult? Function( PullRequestHostUnreachable value)?  unreachable,TResult? Function( PullRequestHostRefused value)?  refused,TResult? Function( PullRequestHostDenied value)?  denied,TResult? Function( PullRequestHostOperationFailed value)?  operationFailed,}){
final _that = this;
switch (_that) {
case PullRequestHostUnavailable() when unavailable != null:
return unavailable(_that);case PullRequestHostUnreachable() when unreachable != null:
return unreachable(_that);case PullRequestHostRefused() when refused != null:
return refused(_that);case PullRequestHostDenied() when denied != null:
return denied(_that);case PullRequestHostOperationFailed() when operationFailed != null:
return operationFailed(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( AppFailure? cause)?  unavailable,TResult Function( AppFailure? cause)?  unreachable,TResult Function( AppFailure? cause)?  refused,TResult Function( AppFailure? cause)?  denied,TResult Function( AppFailure? cause)?  operationFailed,required TResult orElse(),}) {final _that = this;
switch (_that) {
case PullRequestHostUnavailable() when unavailable != null:
return unavailable(_that.cause);case PullRequestHostUnreachable() when unreachable != null:
return unreachable(_that.cause);case PullRequestHostRefused() when refused != null:
return refused(_that.cause);case PullRequestHostDenied() when denied != null:
return denied(_that.cause);case PullRequestHostOperationFailed() when operationFailed != null:
return operationFailed(_that.cause);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( AppFailure? cause)  unavailable,required TResult Function( AppFailure? cause)  unreachable,required TResult Function( AppFailure? cause)  refused,required TResult Function( AppFailure? cause)  denied,required TResult Function( AppFailure? cause)  operationFailed,}) {final _that = this;
switch (_that) {
case PullRequestHostUnavailable():
return unavailable(_that.cause);case PullRequestHostUnreachable():
return unreachable(_that.cause);case PullRequestHostRefused():
return refused(_that.cause);case PullRequestHostDenied():
return denied(_that.cause);case PullRequestHostOperationFailed():
return operationFailed(_that.cause);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( AppFailure? cause)?  unavailable,TResult? Function( AppFailure? cause)?  unreachable,TResult? Function( AppFailure? cause)?  refused,TResult? Function( AppFailure? cause)?  denied,TResult? Function( AppFailure? cause)?  operationFailed,}) {final _that = this;
switch (_that) {
case PullRequestHostUnavailable() when unavailable != null:
return unavailable(_that.cause);case PullRequestHostUnreachable() when unreachable != null:
return unreachable(_that.cause);case PullRequestHostRefused() when refused != null:
return refused(_that.cause);case PullRequestHostDenied() when denied != null:
return denied(_that.cause);case PullRequestHostOperationFailed() when operationFailed != null:
return operationFailed(_that.cause);case _:
  return null;

}
}

}

/// @nodoc


class PullRequestHostUnavailable implements PullRequestHostFailure {
  const PullRequestHostUnavailable({this.cause});
  

@override final  AppFailure? cause;

/// Create a copy of PullRequestHostFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PullRequestHostUnavailableCopyWith<PullRequestHostUnavailable> get copyWith => _$PullRequestHostUnavailableCopyWithImpl<PullRequestHostUnavailable>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PullRequestHostUnavailable&&(identical(other.cause, cause) || other.cause == cause));
}


@override
int get hashCode => Object.hash(runtimeType,cause);

@override
String toString() {
  return 'PullRequestHostFailure.unavailable(cause: $cause)';
}


}

/// @nodoc
abstract mixin class $PullRequestHostUnavailableCopyWith<$Res> implements $PullRequestHostFailureCopyWith<$Res> {
  factory $PullRequestHostUnavailableCopyWith(PullRequestHostUnavailable value, $Res Function(PullRequestHostUnavailable) _then) = _$PullRequestHostUnavailableCopyWithImpl;
@override @useResult
$Res call({
 AppFailure? cause
});




}
/// @nodoc
class _$PullRequestHostUnavailableCopyWithImpl<$Res>
    implements $PullRequestHostUnavailableCopyWith<$Res> {
  _$PullRequestHostUnavailableCopyWithImpl(this._self, this._then);

  final PullRequestHostUnavailable _self;
  final $Res Function(PullRequestHostUnavailable) _then;

/// Create a copy of PullRequestHostFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? cause = freezed,}) {
  return _then(PullRequestHostUnavailable(
cause: freezed == cause ? _self.cause : cause // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}


}

/// @nodoc


class PullRequestHostUnreachable implements PullRequestHostFailure {
  const PullRequestHostUnreachable({this.cause});
  

@override final  AppFailure? cause;

/// Create a copy of PullRequestHostFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PullRequestHostUnreachableCopyWith<PullRequestHostUnreachable> get copyWith => _$PullRequestHostUnreachableCopyWithImpl<PullRequestHostUnreachable>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PullRequestHostUnreachable&&(identical(other.cause, cause) || other.cause == cause));
}


@override
int get hashCode => Object.hash(runtimeType,cause);

@override
String toString() {
  return 'PullRequestHostFailure.unreachable(cause: $cause)';
}


}

/// @nodoc
abstract mixin class $PullRequestHostUnreachableCopyWith<$Res> implements $PullRequestHostFailureCopyWith<$Res> {
  factory $PullRequestHostUnreachableCopyWith(PullRequestHostUnreachable value, $Res Function(PullRequestHostUnreachable) _then) = _$PullRequestHostUnreachableCopyWithImpl;
@override @useResult
$Res call({
 AppFailure? cause
});




}
/// @nodoc
class _$PullRequestHostUnreachableCopyWithImpl<$Res>
    implements $PullRequestHostUnreachableCopyWith<$Res> {
  _$PullRequestHostUnreachableCopyWithImpl(this._self, this._then);

  final PullRequestHostUnreachable _self;
  final $Res Function(PullRequestHostUnreachable) _then;

/// Create a copy of PullRequestHostFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? cause = freezed,}) {
  return _then(PullRequestHostUnreachable(
cause: freezed == cause ? _self.cause : cause // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}


}

/// @nodoc


class PullRequestHostRefused implements PullRequestHostFailure {
  const PullRequestHostRefused({this.cause});
  

@override final  AppFailure? cause;

/// Create a copy of PullRequestHostFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PullRequestHostRefusedCopyWith<PullRequestHostRefused> get copyWith => _$PullRequestHostRefusedCopyWithImpl<PullRequestHostRefused>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PullRequestHostRefused&&(identical(other.cause, cause) || other.cause == cause));
}


@override
int get hashCode => Object.hash(runtimeType,cause);

@override
String toString() {
  return 'PullRequestHostFailure.refused(cause: $cause)';
}


}

/// @nodoc
abstract mixin class $PullRequestHostRefusedCopyWith<$Res> implements $PullRequestHostFailureCopyWith<$Res> {
  factory $PullRequestHostRefusedCopyWith(PullRequestHostRefused value, $Res Function(PullRequestHostRefused) _then) = _$PullRequestHostRefusedCopyWithImpl;
@override @useResult
$Res call({
 AppFailure? cause
});




}
/// @nodoc
class _$PullRequestHostRefusedCopyWithImpl<$Res>
    implements $PullRequestHostRefusedCopyWith<$Res> {
  _$PullRequestHostRefusedCopyWithImpl(this._self, this._then);

  final PullRequestHostRefused _self;
  final $Res Function(PullRequestHostRefused) _then;

/// Create a copy of PullRequestHostFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? cause = freezed,}) {
  return _then(PullRequestHostRefused(
cause: freezed == cause ? _self.cause : cause // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}


}

/// @nodoc


class PullRequestHostDenied implements PullRequestHostFailure, CommandDenial {
  const PullRequestHostDenied({this.cause});
  

@override final  AppFailure? cause;

/// Create a copy of PullRequestHostFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PullRequestHostDeniedCopyWith<PullRequestHostDenied> get copyWith => _$PullRequestHostDeniedCopyWithImpl<PullRequestHostDenied>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PullRequestHostDenied&&(identical(other.cause, cause) || other.cause == cause));
}


@override
int get hashCode => Object.hash(runtimeType,cause);

@override
String toString() {
  return 'PullRequestHostFailure.denied(cause: $cause)';
}


}

/// @nodoc
abstract mixin class $PullRequestHostDeniedCopyWith<$Res> implements $PullRequestHostFailureCopyWith<$Res> {
  factory $PullRequestHostDeniedCopyWith(PullRequestHostDenied value, $Res Function(PullRequestHostDenied) _then) = _$PullRequestHostDeniedCopyWithImpl;
@override @useResult
$Res call({
 AppFailure? cause
});




}
/// @nodoc
class _$PullRequestHostDeniedCopyWithImpl<$Res>
    implements $PullRequestHostDeniedCopyWith<$Res> {
  _$PullRequestHostDeniedCopyWithImpl(this._self, this._then);

  final PullRequestHostDenied _self;
  final $Res Function(PullRequestHostDenied) _then;

/// Create a copy of PullRequestHostFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? cause = freezed,}) {
  return _then(PullRequestHostDenied(
cause: freezed == cause ? _self.cause : cause // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}


}

/// @nodoc


class PullRequestHostOperationFailed implements PullRequestHostFailure {
  const PullRequestHostOperationFailed({this.cause});
  

@override final  AppFailure? cause;

/// Create a copy of PullRequestHostFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PullRequestHostOperationFailedCopyWith<PullRequestHostOperationFailed> get copyWith => _$PullRequestHostOperationFailedCopyWithImpl<PullRequestHostOperationFailed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PullRequestHostOperationFailed&&(identical(other.cause, cause) || other.cause == cause));
}


@override
int get hashCode => Object.hash(runtimeType,cause);

@override
String toString() {
  return 'PullRequestHostFailure.operationFailed(cause: $cause)';
}


}

/// @nodoc
abstract mixin class $PullRequestHostOperationFailedCopyWith<$Res> implements $PullRequestHostFailureCopyWith<$Res> {
  factory $PullRequestHostOperationFailedCopyWith(PullRequestHostOperationFailed value, $Res Function(PullRequestHostOperationFailed) _then) = _$PullRequestHostOperationFailedCopyWithImpl;
@override @useResult
$Res call({
 AppFailure? cause
});




}
/// @nodoc
class _$PullRequestHostOperationFailedCopyWithImpl<$Res>
    implements $PullRequestHostOperationFailedCopyWith<$Res> {
  _$PullRequestHostOperationFailedCopyWithImpl(this._self, this._then);

  final PullRequestHostOperationFailed _self;
  final $Res Function(PullRequestHostOperationFailed) _then;

/// Create a copy of PullRequestHostFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? cause = freezed,}) {
  return _then(PullRequestHostOperationFailed(
cause: freezed == cause ? _self.cause : cause // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}


}

// dart format on
