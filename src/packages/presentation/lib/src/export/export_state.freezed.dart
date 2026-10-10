// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'export_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ExportState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExportState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ExportState()';
}


}

/// @nodoc
class $ExportStateCopyWith<$Res>  {
$ExportStateCopyWith(ExportState _, $Res Function(ExportState) __);
}


/// Adds pattern-matching-related methods to [ExportState].
extension ExportStatePatterns on ExportState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ExportIdle value)?  idle,TResult Function( ExportWorking value)?  working,TResult Function( ExportExported value)?  exported,TResult Function( ExportFailed value)?  failed,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ExportIdle() when idle != null:
return idle(_that);case ExportWorking() when working != null:
return working(_that);case ExportExported() when exported != null:
return exported(_that);case ExportFailed() when failed != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ExportIdle value)  idle,required TResult Function( ExportWorking value)  working,required TResult Function( ExportExported value)  exported,required TResult Function( ExportFailed value)  failed,}){
final _that = this;
switch (_that) {
case ExportIdle():
return idle(_that);case ExportWorking():
return working(_that);case ExportExported():
return exported(_that);case ExportFailed():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ExportIdle value)?  idle,TResult? Function( ExportWorking value)?  working,TResult? Function( ExportExported value)?  exported,TResult? Function( ExportFailed value)?  failed,}){
final _that = this;
switch (_that) {
case ExportIdle() when idle != null:
return idle(_that);case ExportWorking() when working != null:
return working(_that);case ExportExported() when exported != null:
return exported(_that);case ExportFailed() when failed != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  idle,TResult Function( ExportFormatEnum format,  String destination)?  working,TResult Function( ExportFormatEnum format,  String destination)?  exported,TResult Function( ExportFormatEnum format,  String destination,  AppFailure failure)?  failed,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ExportIdle() when idle != null:
return idle();case ExportWorking() when working != null:
return working(_that.format,_that.destination);case ExportExported() when exported != null:
return exported(_that.format,_that.destination);case ExportFailed() when failed != null:
return failed(_that.format,_that.destination,_that.failure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  idle,required TResult Function( ExportFormatEnum format,  String destination)  working,required TResult Function( ExportFormatEnum format,  String destination)  exported,required TResult Function( ExportFormatEnum format,  String destination,  AppFailure failure)  failed,}) {final _that = this;
switch (_that) {
case ExportIdle():
return idle();case ExportWorking():
return working(_that.format,_that.destination);case ExportExported():
return exported(_that.format,_that.destination);case ExportFailed():
return failed(_that.format,_that.destination,_that.failure);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  idle,TResult? Function( ExportFormatEnum format,  String destination)?  working,TResult? Function( ExportFormatEnum format,  String destination)?  exported,TResult? Function( ExportFormatEnum format,  String destination,  AppFailure failure)?  failed,}) {final _that = this;
switch (_that) {
case ExportIdle() when idle != null:
return idle();case ExportWorking() when working != null:
return working(_that.format,_that.destination);case ExportExported() when exported != null:
return exported(_that.format,_that.destination);case ExportFailed() when failed != null:
return failed(_that.format,_that.destination,_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class ExportIdle implements ExportState {
  const ExportIdle();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExportIdle);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ExportState.idle()';
}


}




/// @nodoc


class ExportWorking implements ExportState {
  const ExportWorking({required this.format, required this.destination});
  

 final  ExportFormatEnum format;
 final  String destination;

/// Create a copy of ExportState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExportWorkingCopyWith<ExportWorking> get copyWith => _$ExportWorkingCopyWithImpl<ExportWorking>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExportWorking&&(identical(other.format, format) || other.format == format)&&(identical(other.destination, destination) || other.destination == destination));
}


@override
int get hashCode => Object.hash(runtimeType,format,destination);

@override
String toString() {
  return 'ExportState.working(format: $format, destination: $destination)';
}


}

/// @nodoc
abstract mixin class $ExportWorkingCopyWith<$Res> implements $ExportStateCopyWith<$Res> {
  factory $ExportWorkingCopyWith(ExportWorking value, $Res Function(ExportWorking) _then) = _$ExportWorkingCopyWithImpl;
@useResult
$Res call({
 ExportFormatEnum format, String destination
});




}
/// @nodoc
class _$ExportWorkingCopyWithImpl<$Res>
    implements $ExportWorkingCopyWith<$Res> {
  _$ExportWorkingCopyWithImpl(this._self, this._then);

  final ExportWorking _self;
  final $Res Function(ExportWorking) _then;

/// Create a copy of ExportState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? format = null,Object? destination = null,}) {
  return _then(ExportWorking(
format: null == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as ExportFormatEnum,destination: null == destination ? _self.destination : destination // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class ExportExported implements ExportState {
  const ExportExported({required this.format, required this.destination});
  

 final  ExportFormatEnum format;
 final  String destination;

/// Create a copy of ExportState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExportExportedCopyWith<ExportExported> get copyWith => _$ExportExportedCopyWithImpl<ExportExported>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExportExported&&(identical(other.format, format) || other.format == format)&&(identical(other.destination, destination) || other.destination == destination));
}


@override
int get hashCode => Object.hash(runtimeType,format,destination);

@override
String toString() {
  return 'ExportState.exported(format: $format, destination: $destination)';
}


}

/// @nodoc
abstract mixin class $ExportExportedCopyWith<$Res> implements $ExportStateCopyWith<$Res> {
  factory $ExportExportedCopyWith(ExportExported value, $Res Function(ExportExported) _then) = _$ExportExportedCopyWithImpl;
@useResult
$Res call({
 ExportFormatEnum format, String destination
});




}
/// @nodoc
class _$ExportExportedCopyWithImpl<$Res>
    implements $ExportExportedCopyWith<$Res> {
  _$ExportExportedCopyWithImpl(this._self, this._then);

  final ExportExported _self;
  final $Res Function(ExportExported) _then;

/// Create a copy of ExportState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? format = null,Object? destination = null,}) {
  return _then(ExportExported(
format: null == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as ExportFormatEnum,destination: null == destination ? _self.destination : destination // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class ExportFailed implements ExportState {
  const ExportFailed({required this.format, required this.destination, required this.failure});
  

 final  ExportFormatEnum format;
 final  String destination;
 final  AppFailure failure;

/// Create a copy of ExportState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExportFailedCopyWith<ExportFailed> get copyWith => _$ExportFailedCopyWithImpl<ExportFailed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExportFailed&&(identical(other.format, format) || other.format == format)&&(identical(other.destination, destination) || other.destination == destination)&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,format,destination,failure);

@override
String toString() {
  return 'ExportState.failed(format: $format, destination: $destination, failure: $failure)';
}


}

/// @nodoc
abstract mixin class $ExportFailedCopyWith<$Res> implements $ExportStateCopyWith<$Res> {
  factory $ExportFailedCopyWith(ExportFailed value, $Res Function(ExportFailed) _then) = _$ExportFailedCopyWithImpl;
@useResult
$Res call({
 ExportFormatEnum format, String destination, AppFailure failure
});




}
/// @nodoc
class _$ExportFailedCopyWithImpl<$Res>
    implements $ExportFailedCopyWith<$Res> {
  _$ExportFailedCopyWithImpl(this._self, this._then);

  final ExportFailed _self;
  final $Res Function(ExportFailed) _then;

/// Create a copy of ExportState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? format = null,Object? destination = null,Object? failure = null,}) {
  return _then(ExportFailed(
format: null == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as ExportFormatEnum,destination: null == destination ? _self.destination : destination // ignore: cast_nullable_to_non_nullable
as String,failure: null == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as AppFailure,
  ));
}


}

// dart format on
