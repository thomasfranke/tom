// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'export_failure.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ExportFailure {

 AppFailure? get cause;
/// Create a copy of ExportFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExportFailureCopyWith<ExportFailure> get copyWith => _$ExportFailureCopyWithImpl<ExportFailure>(this as ExportFailure, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExportFailure&&(identical(other.cause, cause) || other.cause == cause));
}


@override
int get hashCode => Object.hash(runtimeType,cause);

@override
String toString() {
  return 'ExportFailure(cause: $cause)';
}


}

/// @nodoc
abstract mixin class $ExportFailureCopyWith<$Res>  {
  factory $ExportFailureCopyWith(ExportFailure value, $Res Function(ExportFailure) _then) = _$ExportFailureCopyWithImpl;
@useResult
$Res call({
 AppFailure? cause
});




}
/// @nodoc
class _$ExportFailureCopyWithImpl<$Res>
    implements $ExportFailureCopyWith<$Res> {
  _$ExportFailureCopyWithImpl(this._self, this._then);

  final ExportFailure _self;
  final $Res Function(ExportFailure) _then;

/// Create a copy of ExportFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? cause = freezed,}) {
  return _then(_self.copyWith(
cause: freezed == cause ? _self.cause : cause // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}

}


/// Adds pattern-matching-related methods to [ExportFailure].
extension ExportFailurePatterns on ExportFailure {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ExportCannotWrite value)?  cannotWrite,TResult Function( ExportUnsupported value)?  unsupported,TResult Function( ExportTooLarge value)?  tooLarge,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ExportCannotWrite() when cannotWrite != null:
return cannotWrite(_that);case ExportUnsupported() when unsupported != null:
return unsupported(_that);case ExportTooLarge() when tooLarge != null:
return tooLarge(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ExportCannotWrite value)  cannotWrite,required TResult Function( ExportUnsupported value)  unsupported,required TResult Function( ExportTooLarge value)  tooLarge,}){
final _that = this;
switch (_that) {
case ExportCannotWrite():
return cannotWrite(_that);case ExportUnsupported():
return unsupported(_that);case ExportTooLarge():
return tooLarge(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ExportCannotWrite value)?  cannotWrite,TResult? Function( ExportUnsupported value)?  unsupported,TResult? Function( ExportTooLarge value)?  tooLarge,}){
final _that = this;
switch (_that) {
case ExportCannotWrite() when cannotWrite != null:
return cannotWrite(_that);case ExportUnsupported() when unsupported != null:
return unsupported(_that);case ExportTooLarge() when tooLarge != null:
return tooLarge(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String destination,  AppFailure? cause)?  cannotWrite,TResult Function( ExportFormatEnum format,  AppFailure? cause)?  unsupported,TResult Function( ExportFormatEnum format,  AppFailure? cause)?  tooLarge,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ExportCannotWrite() when cannotWrite != null:
return cannotWrite(_that.destination,_that.cause);case ExportUnsupported() when unsupported != null:
return unsupported(_that.format,_that.cause);case ExportTooLarge() when tooLarge != null:
return tooLarge(_that.format,_that.cause);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String destination,  AppFailure? cause)  cannotWrite,required TResult Function( ExportFormatEnum format,  AppFailure? cause)  unsupported,required TResult Function( ExportFormatEnum format,  AppFailure? cause)  tooLarge,}) {final _that = this;
switch (_that) {
case ExportCannotWrite():
return cannotWrite(_that.destination,_that.cause);case ExportUnsupported():
return unsupported(_that.format,_that.cause);case ExportTooLarge():
return tooLarge(_that.format,_that.cause);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String destination,  AppFailure? cause)?  cannotWrite,TResult? Function( ExportFormatEnum format,  AppFailure? cause)?  unsupported,TResult? Function( ExportFormatEnum format,  AppFailure? cause)?  tooLarge,}) {final _that = this;
switch (_that) {
case ExportCannotWrite() when cannotWrite != null:
return cannotWrite(_that.destination,_that.cause);case ExportUnsupported() when unsupported != null:
return unsupported(_that.format,_that.cause);case ExportTooLarge() when tooLarge != null:
return tooLarge(_that.format,_that.cause);case _:
  return null;

}
}

}

/// @nodoc


class ExportCannotWrite implements ExportFailure {
  const ExportCannotWrite(this.destination, {this.cause});
  

/// The absolute path the export was to land at.
 final  String destination;
@override final  AppFailure? cause;

/// Create a copy of ExportFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExportCannotWriteCopyWith<ExportCannotWrite> get copyWith => _$ExportCannotWriteCopyWithImpl<ExportCannotWrite>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExportCannotWrite&&(identical(other.destination, destination) || other.destination == destination)&&(identical(other.cause, cause) || other.cause == cause));
}


@override
int get hashCode => Object.hash(runtimeType,destination,cause);

@override
String toString() {
  return 'ExportFailure.cannotWrite(destination: $destination, cause: $cause)';
}


}

/// @nodoc
abstract mixin class $ExportCannotWriteCopyWith<$Res> implements $ExportFailureCopyWith<$Res> {
  factory $ExportCannotWriteCopyWith(ExportCannotWrite value, $Res Function(ExportCannotWrite) _then) = _$ExportCannotWriteCopyWithImpl;
@override @useResult
$Res call({
 String destination, AppFailure? cause
});




}
/// @nodoc
class _$ExportCannotWriteCopyWithImpl<$Res>
    implements $ExportCannotWriteCopyWith<$Res> {
  _$ExportCannotWriteCopyWithImpl(this._self, this._then);

  final ExportCannotWrite _self;
  final $Res Function(ExportCannotWrite) _then;

/// Create a copy of ExportFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? destination = null,Object? cause = freezed,}) {
  return _then(ExportCannotWrite(
null == destination ? _self.destination : destination // ignore: cast_nullable_to_non_nullable
as String,cause: freezed == cause ? _self.cause : cause // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}


}

/// @nodoc


class ExportUnsupported implements ExportFailure {
  const ExportUnsupported(this.format, {this.cause});
  

/// The format that was asked for.
 final  ExportFormatEnum format;
@override final  AppFailure? cause;

/// Create a copy of ExportFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExportUnsupportedCopyWith<ExportUnsupported> get copyWith => _$ExportUnsupportedCopyWithImpl<ExportUnsupported>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExportUnsupported&&(identical(other.format, format) || other.format == format)&&(identical(other.cause, cause) || other.cause == cause));
}


@override
int get hashCode => Object.hash(runtimeType,format,cause);

@override
String toString() {
  return 'ExportFailure.unsupported(format: $format, cause: $cause)';
}


}

/// @nodoc
abstract mixin class $ExportUnsupportedCopyWith<$Res> implements $ExportFailureCopyWith<$Res> {
  factory $ExportUnsupportedCopyWith(ExportUnsupported value, $Res Function(ExportUnsupported) _then) = _$ExportUnsupportedCopyWithImpl;
@override @useResult
$Res call({
 ExportFormatEnum format, AppFailure? cause
});




}
/// @nodoc
class _$ExportUnsupportedCopyWithImpl<$Res>
    implements $ExportUnsupportedCopyWith<$Res> {
  _$ExportUnsupportedCopyWithImpl(this._self, this._then);

  final ExportUnsupported _self;
  final $Res Function(ExportUnsupported) _then;

/// Create a copy of ExportFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? format = null,Object? cause = freezed,}) {
  return _then(ExportUnsupported(
null == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as ExportFormatEnum,cause: freezed == cause ? _self.cause : cause // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}


}

/// @nodoc


class ExportTooLarge implements ExportFailure {
  const ExportTooLarge(this.format, {this.cause});
  

/// The format it did not fit.
 final  ExportFormatEnum format;
@override final  AppFailure? cause;

/// Create a copy of ExportFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExportTooLargeCopyWith<ExportTooLarge> get copyWith => _$ExportTooLargeCopyWithImpl<ExportTooLarge>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExportTooLarge&&(identical(other.format, format) || other.format == format)&&(identical(other.cause, cause) || other.cause == cause));
}


@override
int get hashCode => Object.hash(runtimeType,format,cause);

@override
String toString() {
  return 'ExportFailure.tooLarge(format: $format, cause: $cause)';
}


}

/// @nodoc
abstract mixin class $ExportTooLargeCopyWith<$Res> implements $ExportFailureCopyWith<$Res> {
  factory $ExportTooLargeCopyWith(ExportTooLarge value, $Res Function(ExportTooLarge) _then) = _$ExportTooLargeCopyWithImpl;
@override @useResult
$Res call({
 ExportFormatEnum format, AppFailure? cause
});




}
/// @nodoc
class _$ExportTooLargeCopyWithImpl<$Res>
    implements $ExportTooLargeCopyWith<$Res> {
  _$ExportTooLargeCopyWithImpl(this._self, this._then);

  final ExportTooLarge _self;
  final $Res Function(ExportTooLarge) _then;

/// Create a copy of ExportFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? format = null,Object? cause = freezed,}) {
  return _then(ExportTooLarge(
null == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as ExportFormatEnum,cause: freezed == cause ? _self.cause : cause // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}


}

// dart format on
