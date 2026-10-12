// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'terminal_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TerminalState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TerminalState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TerminalState()';
}


}

/// @nodoc
class $TerminalStateCopyWith<$Res>  {
$TerminalStateCopyWith(TerminalState _, $Res Function(TerminalState) __);
}


/// Adds pattern-matching-related methods to [TerminalState].
extension TerminalStatePatterns on TerminalState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( TerminalInitial value)?  initial,TResult Function( TerminalStarting value)?  starting,TResult Function( TerminalRunning value)?  running,TResult Function( TerminalExited value)?  exited,TResult Function( TerminalFailed value)?  failed,required TResult orElse(),}){
final _that = this;
switch (_that) {
case TerminalInitial() when initial != null:
return initial(_that);case TerminalStarting() when starting != null:
return starting(_that);case TerminalRunning() when running != null:
return running(_that);case TerminalExited() when exited != null:
return exited(_that);case TerminalFailed() when failed != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( TerminalInitial value)  initial,required TResult Function( TerminalStarting value)  starting,required TResult Function( TerminalRunning value)  running,required TResult Function( TerminalExited value)  exited,required TResult Function( TerminalFailed value)  failed,}){
final _that = this;
switch (_that) {
case TerminalInitial():
return initial(_that);case TerminalStarting():
return starting(_that);case TerminalRunning():
return running(_that);case TerminalExited():
return exited(_that);case TerminalFailed():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( TerminalInitial value)?  initial,TResult? Function( TerminalStarting value)?  starting,TResult? Function( TerminalRunning value)?  running,TResult? Function( TerminalExited value)?  exited,TResult? Function( TerminalFailed value)?  failed,}){
final _that = this;
switch (_that) {
case TerminalInitial() when initial != null:
return initial(_that);case TerminalStarting() when starting != null:
return starting(_that);case TerminalRunning() when running != null:
return running(_that);case TerminalExited() when exited != null:
return exited(_that);case TerminalFailed() when failed != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  starting,TResult Function( String shell,  String folder)?  running,TResult Function( String shell,  String folder,  int code)?  exited,TResult Function( AppFailure failure)?  failed,required TResult orElse(),}) {final _that = this;
switch (_that) {
case TerminalInitial() when initial != null:
return initial();case TerminalStarting() when starting != null:
return starting();case TerminalRunning() when running != null:
return running(_that.shell,_that.folder);case TerminalExited() when exited != null:
return exited(_that.shell,_that.folder,_that.code);case TerminalFailed() when failed != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  starting,required TResult Function( String shell,  String folder)  running,required TResult Function( String shell,  String folder,  int code)  exited,required TResult Function( AppFailure failure)  failed,}) {final _that = this;
switch (_that) {
case TerminalInitial():
return initial();case TerminalStarting():
return starting();case TerminalRunning():
return running(_that.shell,_that.folder);case TerminalExited():
return exited(_that.shell,_that.folder,_that.code);case TerminalFailed():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  starting,TResult? Function( String shell,  String folder)?  running,TResult? Function( String shell,  String folder,  int code)?  exited,TResult? Function( AppFailure failure)?  failed,}) {final _that = this;
switch (_that) {
case TerminalInitial() when initial != null:
return initial();case TerminalStarting() when starting != null:
return starting();case TerminalRunning() when running != null:
return running(_that.shell,_that.folder);case TerminalExited() when exited != null:
return exited(_that.shell,_that.folder,_that.code);case TerminalFailed() when failed != null:
return failed(_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class TerminalInitial implements TerminalState {
  const TerminalInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TerminalInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TerminalState.initial()';
}


}




/// @nodoc


class TerminalStarting implements TerminalState {
  const TerminalStarting();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TerminalStarting);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TerminalState.starting()';
}


}




/// @nodoc


class TerminalRunning implements TerminalState {
  const TerminalRunning({required this.shell, required this.folder});
  

/// Its name — `zsh`.
 final  String shell;
/// Where it was started; a `cd` inside it does not move this.
 final  String folder;

/// Create a copy of TerminalState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TerminalRunningCopyWith<TerminalRunning> get copyWith => _$TerminalRunningCopyWithImpl<TerminalRunning>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TerminalRunning&&(identical(other.shell, shell) || other.shell == shell)&&(identical(other.folder, folder) || other.folder == folder));
}


@override
int get hashCode => Object.hash(runtimeType,shell,folder);

@override
String toString() {
  return 'TerminalState.running(shell: $shell, folder: $folder)';
}


}

/// @nodoc
abstract mixin class $TerminalRunningCopyWith<$Res> implements $TerminalStateCopyWith<$Res> {
  factory $TerminalRunningCopyWith(TerminalRunning value, $Res Function(TerminalRunning) _then) = _$TerminalRunningCopyWithImpl;
@useResult
$Res call({
 String shell, String folder
});




}
/// @nodoc
class _$TerminalRunningCopyWithImpl<$Res>
    implements $TerminalRunningCopyWith<$Res> {
  _$TerminalRunningCopyWithImpl(this._self, this._then);

  final TerminalRunning _self;
  final $Res Function(TerminalRunning) _then;

/// Create a copy of TerminalState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? shell = null,Object? folder = null,}) {
  return _then(TerminalRunning(
shell: null == shell ? _self.shell : shell // ignore: cast_nullable_to_non_nullable
as String,folder: null == folder ? _self.folder : folder // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class TerminalExited implements TerminalState {
  const TerminalExited({required this.shell, required this.folder, required this.code});
  

/// Its name.
 final  String shell;
/// Where it ran.
 final  String folder;
/// What it exited with.
 final  int code;

/// Create a copy of TerminalState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TerminalExitedCopyWith<TerminalExited> get copyWith => _$TerminalExitedCopyWithImpl<TerminalExited>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TerminalExited&&(identical(other.shell, shell) || other.shell == shell)&&(identical(other.folder, folder) || other.folder == folder)&&(identical(other.code, code) || other.code == code));
}


@override
int get hashCode => Object.hash(runtimeType,shell,folder,code);

@override
String toString() {
  return 'TerminalState.exited(shell: $shell, folder: $folder, code: $code)';
}


}

/// @nodoc
abstract mixin class $TerminalExitedCopyWith<$Res> implements $TerminalStateCopyWith<$Res> {
  factory $TerminalExitedCopyWith(TerminalExited value, $Res Function(TerminalExited) _then) = _$TerminalExitedCopyWithImpl;
@useResult
$Res call({
 String shell, String folder, int code
});




}
/// @nodoc
class _$TerminalExitedCopyWithImpl<$Res>
    implements $TerminalExitedCopyWith<$Res> {
  _$TerminalExitedCopyWithImpl(this._self, this._then);

  final TerminalExited _self;
  final $Res Function(TerminalExited) _then;

/// Create a copy of TerminalState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? shell = null,Object? folder = null,Object? code = null,}) {
  return _then(TerminalExited(
shell: null == shell ? _self.shell : shell // ignore: cast_nullable_to_non_nullable
as String,folder: null == folder ? _self.folder : folder // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class TerminalFailed implements TerminalState {
  const TerminalFailed(this.failure);
  

 final  AppFailure failure;

/// Create a copy of TerminalState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TerminalFailedCopyWith<TerminalFailed> get copyWith => _$TerminalFailedCopyWithImpl<TerminalFailed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TerminalFailed&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,failure);

@override
String toString() {
  return 'TerminalState.failed(failure: $failure)';
}


}

/// @nodoc
abstract mixin class $TerminalFailedCopyWith<$Res> implements $TerminalStateCopyWith<$Res> {
  factory $TerminalFailedCopyWith(TerminalFailed value, $Res Function(TerminalFailed) _then) = _$TerminalFailedCopyWithImpl;
@useResult
$Res call({
 AppFailure failure
});




}
/// @nodoc
class _$TerminalFailedCopyWithImpl<$Res>
    implements $TerminalFailedCopyWith<$Res> {
  _$TerminalFailedCopyWithImpl(this._self, this._then);

  final TerminalFailed _self;
  final $Res Function(TerminalFailed) _then;

/// Create a copy of TerminalState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? failure = null,}) {
  return _then(TerminalFailed(
null == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as AppFailure,
  ));
}


}

// dart format on
