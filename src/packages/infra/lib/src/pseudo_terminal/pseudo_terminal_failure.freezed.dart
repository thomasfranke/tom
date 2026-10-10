// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pseudo_terminal_failure.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PseudoTerminalFailure {

 AppFailure? get cause;
/// Create a copy of PseudoTerminalFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PseudoTerminalFailureCopyWith<PseudoTerminalFailure> get copyWith => _$PseudoTerminalFailureCopyWithImpl<PseudoTerminalFailure>(this as PseudoTerminalFailure, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PseudoTerminalFailure&&(identical(other.cause, cause) || other.cause == cause));
}


@override
int get hashCode => Object.hash(runtimeType,cause);

@override
String toString() {
  return 'PseudoTerminalFailure(cause: $cause)';
}


}

/// @nodoc
abstract mixin class $PseudoTerminalFailureCopyWith<$Res>  {
  factory $PseudoTerminalFailureCopyWith(PseudoTerminalFailure value, $Res Function(PseudoTerminalFailure) _then) = _$PseudoTerminalFailureCopyWithImpl;
@useResult
$Res call({
 AppFailure? cause
});




}
/// @nodoc
class _$PseudoTerminalFailureCopyWithImpl<$Res>
    implements $PseudoTerminalFailureCopyWith<$Res> {
  _$PseudoTerminalFailureCopyWithImpl(this._self, this._then);

  final PseudoTerminalFailure _self;
  final $Res Function(PseudoTerminalFailure) _then;

/// Create a copy of PseudoTerminalFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? cause = freezed,}) {
  return _then(_self.copyWith(
cause: freezed == cause ? _self.cause : cause // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}

}


/// Adds pattern-matching-related methods to [PseudoTerminalFailure].
extension PseudoTerminalFailurePatterns on PseudoTerminalFailure {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( PseudoTerminalUnavailable value)?  unavailable,TResult Function( PseudoTerminalStartFailed value)?  startFailed,required TResult orElse(),}){
final _that = this;
switch (_that) {
case PseudoTerminalUnavailable() when unavailable != null:
return unavailable(_that);case PseudoTerminalStartFailed() when startFailed != null:
return startFailed(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( PseudoTerminalUnavailable value)  unavailable,required TResult Function( PseudoTerminalStartFailed value)  startFailed,}){
final _that = this;
switch (_that) {
case PseudoTerminalUnavailable():
return unavailable(_that);case PseudoTerminalStartFailed():
return startFailed(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( PseudoTerminalUnavailable value)?  unavailable,TResult? Function( PseudoTerminalStartFailed value)?  startFailed,}){
final _that = this;
switch (_that) {
case PseudoTerminalUnavailable() when unavailable != null:
return unavailable(_that);case PseudoTerminalStartFailed() when startFailed != null:
return startFailed(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String shell,  AppFailure? cause)?  unavailable,TResult Function( String description,  AppFailure? cause)?  startFailed,required TResult orElse(),}) {final _that = this;
switch (_that) {
case PseudoTerminalUnavailable() when unavailable != null:
return unavailable(_that.shell,_that.cause);case PseudoTerminalStartFailed() when startFailed != null:
return startFailed(_that.description,_that.cause);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String shell,  AppFailure? cause)  unavailable,required TResult Function( String description,  AppFailure? cause)  startFailed,}) {final _that = this;
switch (_that) {
case PseudoTerminalUnavailable():
return unavailable(_that.shell,_that.cause);case PseudoTerminalStartFailed():
return startFailed(_that.description,_that.cause);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String shell,  AppFailure? cause)?  unavailable,TResult? Function( String description,  AppFailure? cause)?  startFailed,}) {final _that = this;
switch (_that) {
case PseudoTerminalUnavailable() when unavailable != null:
return unavailable(_that.shell,_that.cause);case PseudoTerminalStartFailed() when startFailed != null:
return startFailed(_that.description,_that.cause);case _:
  return null;

}
}

}

/// @nodoc


class PseudoTerminalUnavailable implements PseudoTerminalFailure {
  const PseudoTerminalUnavailable(this.shell, {this.cause});
  

/// The executable that was looked for.
 final  String shell;
@override final  AppFailure? cause;

/// Create a copy of PseudoTerminalFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PseudoTerminalUnavailableCopyWith<PseudoTerminalUnavailable> get copyWith => _$PseudoTerminalUnavailableCopyWithImpl<PseudoTerminalUnavailable>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PseudoTerminalUnavailable&&(identical(other.shell, shell) || other.shell == shell)&&(identical(other.cause, cause) || other.cause == cause));
}


@override
int get hashCode => Object.hash(runtimeType,shell,cause);

@override
String toString() {
  return 'PseudoTerminalFailure.unavailable(shell: $shell, cause: $cause)';
}


}

/// @nodoc
abstract mixin class $PseudoTerminalUnavailableCopyWith<$Res> implements $PseudoTerminalFailureCopyWith<$Res> {
  factory $PseudoTerminalUnavailableCopyWith(PseudoTerminalUnavailable value, $Res Function(PseudoTerminalUnavailable) _then) = _$PseudoTerminalUnavailableCopyWithImpl;
@override @useResult
$Res call({
 String shell, AppFailure? cause
});




}
/// @nodoc
class _$PseudoTerminalUnavailableCopyWithImpl<$Res>
    implements $PseudoTerminalUnavailableCopyWith<$Res> {
  _$PseudoTerminalUnavailableCopyWithImpl(this._self, this._then);

  final PseudoTerminalUnavailable _self;
  final $Res Function(PseudoTerminalUnavailable) _then;

/// Create a copy of PseudoTerminalFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? shell = null,Object? cause = freezed,}) {
  return _then(PseudoTerminalUnavailable(
null == shell ? _self.shell : shell // ignore: cast_nullable_to_non_nullable
as String,cause: freezed == cause ? _self.cause : cause // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}


}

/// @nodoc


class PseudoTerminalStartFailed implements PseudoTerminalFailure {
  const PseudoTerminalStartFailed(this.description, {this.cause});
  

/// What the platform said, verbatim. For diagnostics — never parsed.
 final  String description;
@override final  AppFailure? cause;

/// Create a copy of PseudoTerminalFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PseudoTerminalStartFailedCopyWith<PseudoTerminalStartFailed> get copyWith => _$PseudoTerminalStartFailedCopyWithImpl<PseudoTerminalStartFailed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PseudoTerminalStartFailed&&(identical(other.description, description) || other.description == description)&&(identical(other.cause, cause) || other.cause == cause));
}


@override
int get hashCode => Object.hash(runtimeType,description,cause);

@override
String toString() {
  return 'PseudoTerminalFailure.startFailed(description: $description, cause: $cause)';
}


}

/// @nodoc
abstract mixin class $PseudoTerminalStartFailedCopyWith<$Res> implements $PseudoTerminalFailureCopyWith<$Res> {
  factory $PseudoTerminalStartFailedCopyWith(PseudoTerminalStartFailed value, $Res Function(PseudoTerminalStartFailed) _then) = _$PseudoTerminalStartFailedCopyWithImpl;
@override @useResult
$Res call({
 String description, AppFailure? cause
});




}
/// @nodoc
class _$PseudoTerminalStartFailedCopyWithImpl<$Res>
    implements $PseudoTerminalStartFailedCopyWith<$Res> {
  _$PseudoTerminalStartFailedCopyWithImpl(this._self, this._then);

  final PseudoTerminalStartFailed _self;
  final $Res Function(PseudoTerminalStartFailed) _then;

/// Create a copy of PseudoTerminalFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? description = null,Object? cause = freezed,}) {
  return _then(PseudoTerminalStartFailed(
null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,cause: freezed == cause ? _self.cause : cause // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}


}

// dart format on
