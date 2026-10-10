// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'document_exporter_failure.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DocumentExporterFailure {

 AppFailure? get cause;
/// Create a copy of DocumentExporterFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DocumentExporterFailureCopyWith<DocumentExporterFailure> get copyWith => _$DocumentExporterFailureCopyWithImpl<DocumentExporterFailure>(this as DocumentExporterFailure, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DocumentExporterFailure&&(identical(other.cause, cause) || other.cause == cause));
}


@override
int get hashCode => Object.hash(runtimeType,cause);

@override
String toString() {
  return 'DocumentExporterFailure(cause: $cause)';
}


}

/// @nodoc
abstract mixin class $DocumentExporterFailureCopyWith<$Res>  {
  factory $DocumentExporterFailureCopyWith(DocumentExporterFailure value, $Res Function(DocumentExporterFailure) _then) = _$DocumentExporterFailureCopyWithImpl;
@useResult
$Res call({
 AppFailure? cause
});




}
/// @nodoc
class _$DocumentExporterFailureCopyWithImpl<$Res>
    implements $DocumentExporterFailureCopyWith<$Res> {
  _$DocumentExporterFailureCopyWithImpl(this._self, this._then);

  final DocumentExporterFailure _self;
  final $Res Function(DocumentExporterFailure) _then;

/// Create a copy of DocumentExporterFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? cause = freezed,}) {
  return _then(_self.copyWith(
cause: freezed == cause ? _self.cause : cause // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}

}


/// Adds pattern-matching-related methods to [DocumentExporterFailure].
extension DocumentExporterFailurePatterns on DocumentExporterFailure {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( DocumentExporterWriteFailed value)?  writeFailed,TResult Function( DocumentExporterUnsupported value)?  unsupported,TResult Function( DocumentExporterTooLarge value)?  tooLarge,required TResult orElse(),}){
final _that = this;
switch (_that) {
case DocumentExporterWriteFailed() when writeFailed != null:
return writeFailed(_that);case DocumentExporterUnsupported() when unsupported != null:
return unsupported(_that);case DocumentExporterTooLarge() when tooLarge != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( DocumentExporterWriteFailed value)  writeFailed,required TResult Function( DocumentExporterUnsupported value)  unsupported,required TResult Function( DocumentExporterTooLarge value)  tooLarge,}){
final _that = this;
switch (_that) {
case DocumentExporterWriteFailed():
return writeFailed(_that);case DocumentExporterUnsupported():
return unsupported(_that);case DocumentExporterTooLarge():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( DocumentExporterWriteFailed value)?  writeFailed,TResult? Function( DocumentExporterUnsupported value)?  unsupported,TResult? Function( DocumentExporterTooLarge value)?  tooLarge,}){
final _that = this;
switch (_that) {
case DocumentExporterWriteFailed() when writeFailed != null:
return writeFailed(_that);case DocumentExporterUnsupported() when unsupported != null:
return unsupported(_that);case DocumentExporterTooLarge() when tooLarge != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String description,  AppFailure? cause)?  writeFailed,TResult Function( ExporterFormatEnum format,  AppFailure? cause)?  unsupported,TResult Function( String description,  AppFailure? cause)?  tooLarge,required TResult orElse(),}) {final _that = this;
switch (_that) {
case DocumentExporterWriteFailed() when writeFailed != null:
return writeFailed(_that.description,_that.cause);case DocumentExporterUnsupported() when unsupported != null:
return unsupported(_that.format,_that.cause);case DocumentExporterTooLarge() when tooLarge != null:
return tooLarge(_that.description,_that.cause);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String description,  AppFailure? cause)  writeFailed,required TResult Function( ExporterFormatEnum format,  AppFailure? cause)  unsupported,required TResult Function( String description,  AppFailure? cause)  tooLarge,}) {final _that = this;
switch (_that) {
case DocumentExporterWriteFailed():
return writeFailed(_that.description,_that.cause);case DocumentExporterUnsupported():
return unsupported(_that.format,_that.cause);case DocumentExporterTooLarge():
return tooLarge(_that.description,_that.cause);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String description,  AppFailure? cause)?  writeFailed,TResult? Function( ExporterFormatEnum format,  AppFailure? cause)?  unsupported,TResult? Function( String description,  AppFailure? cause)?  tooLarge,}) {final _that = this;
switch (_that) {
case DocumentExporterWriteFailed() when writeFailed != null:
return writeFailed(_that.description,_that.cause);case DocumentExporterUnsupported() when unsupported != null:
return unsupported(_that.format,_that.cause);case DocumentExporterTooLarge() when tooLarge != null:
return tooLarge(_that.description,_that.cause);case _:
  return null;

}
}

}

/// @nodoc


class DocumentExporterWriteFailed implements DocumentExporterFailure {
  const DocumentExporterWriteFailed(this.description, {this.cause});
  

/// What it reported, verbatim. For diagnostics — never parsed.
 final  String description;
@override final  AppFailure? cause;

/// Create a copy of DocumentExporterFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DocumentExporterWriteFailedCopyWith<DocumentExporterWriteFailed> get copyWith => _$DocumentExporterWriteFailedCopyWithImpl<DocumentExporterWriteFailed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DocumentExporterWriteFailed&&(identical(other.description, description) || other.description == description)&&(identical(other.cause, cause) || other.cause == cause));
}


@override
int get hashCode => Object.hash(runtimeType,description,cause);

@override
String toString() {
  return 'DocumentExporterFailure.writeFailed(description: $description, cause: $cause)';
}


}

/// @nodoc
abstract mixin class $DocumentExporterWriteFailedCopyWith<$Res> implements $DocumentExporterFailureCopyWith<$Res> {
  factory $DocumentExporterWriteFailedCopyWith(DocumentExporterWriteFailed value, $Res Function(DocumentExporterWriteFailed) _then) = _$DocumentExporterWriteFailedCopyWithImpl;
@override @useResult
$Res call({
 String description, AppFailure? cause
});




}
/// @nodoc
class _$DocumentExporterWriteFailedCopyWithImpl<$Res>
    implements $DocumentExporterWriteFailedCopyWith<$Res> {
  _$DocumentExporterWriteFailedCopyWithImpl(this._self, this._then);

  final DocumentExporterWriteFailed _self;
  final $Res Function(DocumentExporterWriteFailed) _then;

/// Create a copy of DocumentExporterFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? description = null,Object? cause = freezed,}) {
  return _then(DocumentExporterWriteFailed(
null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,cause: freezed == cause ? _self.cause : cause // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}


}

/// @nodoc


class DocumentExporterUnsupported implements DocumentExporterFailure {
  const DocumentExporterUnsupported(this.format, {this.cause});
  

/// The format that was asked for.
 final  ExporterFormatEnum format;
@override final  AppFailure? cause;

/// Create a copy of DocumentExporterFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DocumentExporterUnsupportedCopyWith<DocumentExporterUnsupported> get copyWith => _$DocumentExporterUnsupportedCopyWithImpl<DocumentExporterUnsupported>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DocumentExporterUnsupported&&(identical(other.format, format) || other.format == format)&&(identical(other.cause, cause) || other.cause == cause));
}


@override
int get hashCode => Object.hash(runtimeType,format,cause);

@override
String toString() {
  return 'DocumentExporterFailure.unsupported(format: $format, cause: $cause)';
}


}

/// @nodoc
abstract mixin class $DocumentExporterUnsupportedCopyWith<$Res> implements $DocumentExporterFailureCopyWith<$Res> {
  factory $DocumentExporterUnsupportedCopyWith(DocumentExporterUnsupported value, $Res Function(DocumentExporterUnsupported) _then) = _$DocumentExporterUnsupportedCopyWithImpl;
@override @useResult
$Res call({
 ExporterFormatEnum format, AppFailure? cause
});




}
/// @nodoc
class _$DocumentExporterUnsupportedCopyWithImpl<$Res>
    implements $DocumentExporterUnsupportedCopyWith<$Res> {
  _$DocumentExporterUnsupportedCopyWithImpl(this._self, this._then);

  final DocumentExporterUnsupported _self;
  final $Res Function(DocumentExporterUnsupported) _then;

/// Create a copy of DocumentExporterFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? format = null,Object? cause = freezed,}) {
  return _then(DocumentExporterUnsupported(
null == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as ExporterFormatEnum,cause: freezed == cause ? _self.cause : cause // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}


}

/// @nodoc


class DocumentExporterTooLarge implements DocumentExporterFailure {
  const DocumentExporterTooLarge(this.description, {this.cause});
  

/// What the engine said, verbatim. For diagnostics — never parsed.
 final  String description;
@override final  AppFailure? cause;

/// Create a copy of DocumentExporterFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DocumentExporterTooLargeCopyWith<DocumentExporterTooLarge> get copyWith => _$DocumentExporterTooLargeCopyWithImpl<DocumentExporterTooLarge>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DocumentExporterTooLarge&&(identical(other.description, description) || other.description == description)&&(identical(other.cause, cause) || other.cause == cause));
}


@override
int get hashCode => Object.hash(runtimeType,description,cause);

@override
String toString() {
  return 'DocumentExporterFailure.tooLarge(description: $description, cause: $cause)';
}


}

/// @nodoc
abstract mixin class $DocumentExporterTooLargeCopyWith<$Res> implements $DocumentExporterFailureCopyWith<$Res> {
  factory $DocumentExporterTooLargeCopyWith(DocumentExporterTooLarge value, $Res Function(DocumentExporterTooLarge) _then) = _$DocumentExporterTooLargeCopyWithImpl;
@override @useResult
$Res call({
 String description, AppFailure? cause
});




}
/// @nodoc
class _$DocumentExporterTooLargeCopyWithImpl<$Res>
    implements $DocumentExporterTooLargeCopyWith<$Res> {
  _$DocumentExporterTooLargeCopyWithImpl(this._self, this._then);

  final DocumentExporterTooLarge _self;
  final $Res Function(DocumentExporterTooLarge) _then;

/// Create a copy of DocumentExporterFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? description = null,Object? cause = freezed,}) {
  return _then(DocumentExporterTooLarge(
null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,cause: freezed == cause ? _self.cause : cause // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}


}

// dart format on
