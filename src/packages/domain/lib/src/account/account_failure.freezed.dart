// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'account_failure.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AccountFailure {

 AppFailure? get cause;
/// Create a copy of AccountFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AccountFailureCopyWith<AccountFailure> get copyWith => _$AccountFailureCopyWithImpl<AccountFailure>(this as AccountFailure, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AccountFailure&&(identical(other.cause, cause) || other.cause == cause));
}


@override
int get hashCode => Object.hash(runtimeType,cause);

@override
String toString() {
  return 'AccountFailure(cause: $cause)';
}


}

/// @nodoc
abstract mixin class $AccountFailureCopyWith<$Res>  {
  factory $AccountFailureCopyWith(AccountFailure value, $Res Function(AccountFailure) _then) = _$AccountFailureCopyWithImpl;
@useResult
$Res call({
 AppFailure? cause
});




}
/// @nodoc
class _$AccountFailureCopyWithImpl<$Res>
    implements $AccountFailureCopyWith<$Res> {
  _$AccountFailureCopyWithImpl(this._self, this._then);

  final AccountFailure _self;
  final $Res Function(AccountFailure) _then;

/// Create a copy of AccountFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? cause = freezed,}) {
  return _then(_self.copyWith(
cause: freezed == cause ? _self.cause : cause // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}

}


/// Adds pattern-matching-related methods to [AccountFailure].
extension AccountFailurePatterns on AccountFailure {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( AccountUnreachable value)?  unreachable,TResult Function( AccountRefused value)?  refused,TResult Function( AccountDenied value)?  denied,TResult Function( AccountOperationFailed value)?  operationFailed,required TResult orElse(),}){
final _that = this;
switch (_that) {
case AccountUnreachable() when unreachable != null:
return unreachable(_that);case AccountRefused() when refused != null:
return refused(_that);case AccountDenied() when denied != null:
return denied(_that);case AccountOperationFailed() when operationFailed != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( AccountUnreachable value)  unreachable,required TResult Function( AccountRefused value)  refused,required TResult Function( AccountDenied value)  denied,required TResult Function( AccountOperationFailed value)  operationFailed,}){
final _that = this;
switch (_that) {
case AccountUnreachable():
return unreachable(_that);case AccountRefused():
return refused(_that);case AccountDenied():
return denied(_that);case AccountOperationFailed():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( AccountUnreachable value)?  unreachable,TResult? Function( AccountRefused value)?  refused,TResult? Function( AccountDenied value)?  denied,TResult? Function( AccountOperationFailed value)?  operationFailed,}){
final _that = this;
switch (_that) {
case AccountUnreachable() when unreachable != null:
return unreachable(_that);case AccountRefused() when refused != null:
return refused(_that);case AccountDenied() when denied != null:
return denied(_that);case AccountOperationFailed() when operationFailed != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( AppFailure? cause)?  unreachable,TResult Function( AppFailure? cause)?  refused,TResult Function( AppFailure? cause)?  denied,TResult Function( AppFailure? cause)?  operationFailed,required TResult orElse(),}) {final _that = this;
switch (_that) {
case AccountUnreachable() when unreachable != null:
return unreachable(_that.cause);case AccountRefused() when refused != null:
return refused(_that.cause);case AccountDenied() when denied != null:
return denied(_that.cause);case AccountOperationFailed() when operationFailed != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( AppFailure? cause)  unreachable,required TResult Function( AppFailure? cause)  refused,required TResult Function( AppFailure? cause)  denied,required TResult Function( AppFailure? cause)  operationFailed,}) {final _that = this;
switch (_that) {
case AccountUnreachable():
return unreachable(_that.cause);case AccountRefused():
return refused(_that.cause);case AccountDenied():
return denied(_that.cause);case AccountOperationFailed():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( AppFailure? cause)?  unreachable,TResult? Function( AppFailure? cause)?  refused,TResult? Function( AppFailure? cause)?  denied,TResult? Function( AppFailure? cause)?  operationFailed,}) {final _that = this;
switch (_that) {
case AccountUnreachable() when unreachable != null:
return unreachable(_that.cause);case AccountRefused() when refused != null:
return refused(_that.cause);case AccountDenied() when denied != null:
return denied(_that.cause);case AccountOperationFailed() when operationFailed != null:
return operationFailed(_that.cause);case _:
  return null;

}
}

}

/// @nodoc


class AccountUnreachable implements AccountFailure {
  const AccountUnreachable({this.cause});
  

@override final  AppFailure? cause;

/// Create a copy of AccountFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AccountUnreachableCopyWith<AccountUnreachable> get copyWith => _$AccountUnreachableCopyWithImpl<AccountUnreachable>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AccountUnreachable&&(identical(other.cause, cause) || other.cause == cause));
}


@override
int get hashCode => Object.hash(runtimeType,cause);

@override
String toString() {
  return 'AccountFailure.unreachable(cause: $cause)';
}


}

/// @nodoc
abstract mixin class $AccountUnreachableCopyWith<$Res> implements $AccountFailureCopyWith<$Res> {
  factory $AccountUnreachableCopyWith(AccountUnreachable value, $Res Function(AccountUnreachable) _then) = _$AccountUnreachableCopyWithImpl;
@override @useResult
$Res call({
 AppFailure? cause
});




}
/// @nodoc
class _$AccountUnreachableCopyWithImpl<$Res>
    implements $AccountUnreachableCopyWith<$Res> {
  _$AccountUnreachableCopyWithImpl(this._self, this._then);

  final AccountUnreachable _self;
  final $Res Function(AccountUnreachable) _then;

/// Create a copy of AccountFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? cause = freezed,}) {
  return _then(AccountUnreachable(
cause: freezed == cause ? _self.cause : cause // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}


}

/// @nodoc


class AccountRefused implements AccountFailure {
  const AccountRefused({this.cause});
  

@override final  AppFailure? cause;

/// Create a copy of AccountFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AccountRefusedCopyWith<AccountRefused> get copyWith => _$AccountRefusedCopyWithImpl<AccountRefused>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AccountRefused&&(identical(other.cause, cause) || other.cause == cause));
}


@override
int get hashCode => Object.hash(runtimeType,cause);

@override
String toString() {
  return 'AccountFailure.refused(cause: $cause)';
}


}

/// @nodoc
abstract mixin class $AccountRefusedCopyWith<$Res> implements $AccountFailureCopyWith<$Res> {
  factory $AccountRefusedCopyWith(AccountRefused value, $Res Function(AccountRefused) _then) = _$AccountRefusedCopyWithImpl;
@override @useResult
$Res call({
 AppFailure? cause
});




}
/// @nodoc
class _$AccountRefusedCopyWithImpl<$Res>
    implements $AccountRefusedCopyWith<$Res> {
  _$AccountRefusedCopyWithImpl(this._self, this._then);

  final AccountRefused _self;
  final $Res Function(AccountRefused) _then;

/// Create a copy of AccountFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? cause = freezed,}) {
  return _then(AccountRefused(
cause: freezed == cause ? _self.cause : cause // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}


}

/// @nodoc


class AccountDenied implements AccountFailure, CommandDenial {
  const AccountDenied({this.cause});
  

@override final  AppFailure? cause;

/// Create a copy of AccountFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AccountDeniedCopyWith<AccountDenied> get copyWith => _$AccountDeniedCopyWithImpl<AccountDenied>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AccountDenied&&(identical(other.cause, cause) || other.cause == cause));
}


@override
int get hashCode => Object.hash(runtimeType,cause);

@override
String toString() {
  return 'AccountFailure.denied(cause: $cause)';
}


}

/// @nodoc
abstract mixin class $AccountDeniedCopyWith<$Res> implements $AccountFailureCopyWith<$Res> {
  factory $AccountDeniedCopyWith(AccountDenied value, $Res Function(AccountDenied) _then) = _$AccountDeniedCopyWithImpl;
@override @useResult
$Res call({
 AppFailure? cause
});




}
/// @nodoc
class _$AccountDeniedCopyWithImpl<$Res>
    implements $AccountDeniedCopyWith<$Res> {
  _$AccountDeniedCopyWithImpl(this._self, this._then);

  final AccountDenied _self;
  final $Res Function(AccountDenied) _then;

/// Create a copy of AccountFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? cause = freezed,}) {
  return _then(AccountDenied(
cause: freezed == cause ? _self.cause : cause // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}


}

/// @nodoc


class AccountOperationFailed implements AccountFailure {
  const AccountOperationFailed({this.cause});
  

@override final  AppFailure? cause;

/// Create a copy of AccountFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AccountOperationFailedCopyWith<AccountOperationFailed> get copyWith => _$AccountOperationFailedCopyWithImpl<AccountOperationFailed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AccountOperationFailed&&(identical(other.cause, cause) || other.cause == cause));
}


@override
int get hashCode => Object.hash(runtimeType,cause);

@override
String toString() {
  return 'AccountFailure.operationFailed(cause: $cause)';
}


}

/// @nodoc
abstract mixin class $AccountOperationFailedCopyWith<$Res> implements $AccountFailureCopyWith<$Res> {
  factory $AccountOperationFailedCopyWith(AccountOperationFailed value, $Res Function(AccountOperationFailed) _then) = _$AccountOperationFailedCopyWithImpl;
@override @useResult
$Res call({
 AppFailure? cause
});




}
/// @nodoc
class _$AccountOperationFailedCopyWithImpl<$Res>
    implements $AccountOperationFailedCopyWith<$Res> {
  _$AccountOperationFailedCopyWithImpl(this._self, this._then);

  final AccountOperationFailed _self;
  final $Res Function(AccountOperationFailed) _then;

/// Create a copy of AccountFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? cause = freezed,}) {
  return _then(AccountOperationFailed(
cause: freezed == cause ? _self.cause : cause // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}


}

// dart format on
