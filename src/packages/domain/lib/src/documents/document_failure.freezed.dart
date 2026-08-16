// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'document_failure.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DocumentFailure {

/// The path, relative to the space root.
 String get path;
/// Create a copy of DocumentFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DocumentFailureCopyWith<DocumentFailure> get copyWith => _$DocumentFailureCopyWithImpl<DocumentFailure>(this as DocumentFailure, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DocumentFailure&&(identical(other.path, path) || other.path == path));
}


@override
int get hashCode => Object.hash(runtimeType,path);

@override
String toString() {
  return 'DocumentFailure(path: $path)';
}


}

/// @nodoc
abstract mixin class $DocumentFailureCopyWith<$Res>  {
  factory $DocumentFailureCopyWith(DocumentFailure value, $Res Function(DocumentFailure) _then) = _$DocumentFailureCopyWithImpl;
@useResult
$Res call({
 String path
});




}
/// @nodoc
class _$DocumentFailureCopyWithImpl<$Res>
    implements $DocumentFailureCopyWith<$Res> {
  _$DocumentFailureCopyWithImpl(this._self, this._then);

  final DocumentFailure _self;
  final $Res Function(DocumentFailure) _then;

/// Create a copy of DocumentFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? path = null,}) {
  return _then(_self.copyWith(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [DocumentFailure].
extension DocumentFailurePatterns on DocumentFailure {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( DocumentNotFound value)?  notFound,TResult Function( PermissionDenied value)?  permissionDenied,TResult Function( ExternalChangeConflict value)?  externalChangeConflict,required TResult orElse(),}){
final _that = this;
switch (_that) {
case DocumentNotFound() when notFound != null:
return notFound(_that);case PermissionDenied() when permissionDenied != null:
return permissionDenied(_that);case ExternalChangeConflict() when externalChangeConflict != null:
return externalChangeConflict(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( DocumentNotFound value)  notFound,required TResult Function( PermissionDenied value)  permissionDenied,required TResult Function( ExternalChangeConflict value)  externalChangeConflict,}){
final _that = this;
switch (_that) {
case DocumentNotFound():
return notFound(_that);case PermissionDenied():
return permissionDenied(_that);case ExternalChangeConflict():
return externalChangeConflict(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( DocumentNotFound value)?  notFound,TResult? Function( PermissionDenied value)?  permissionDenied,TResult? Function( ExternalChangeConflict value)?  externalChangeConflict,}){
final _that = this;
switch (_that) {
case DocumentNotFound() when notFound != null:
return notFound(_that);case PermissionDenied() when permissionDenied != null:
return permissionDenied(_that);case ExternalChangeConflict() when externalChangeConflict != null:
return externalChangeConflict(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String path)?  notFound,TResult Function( String path)?  permissionDenied,TResult Function( String path)?  externalChangeConflict,required TResult orElse(),}) {final _that = this;
switch (_that) {
case DocumentNotFound() when notFound != null:
return notFound(_that.path);case PermissionDenied() when permissionDenied != null:
return permissionDenied(_that.path);case ExternalChangeConflict() when externalChangeConflict != null:
return externalChangeConflict(_that.path);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String path)  notFound,required TResult Function( String path)  permissionDenied,required TResult Function( String path)  externalChangeConflict,}) {final _that = this;
switch (_that) {
case DocumentNotFound():
return notFound(_that.path);case PermissionDenied():
return permissionDenied(_that.path);case ExternalChangeConflict():
return externalChangeConflict(_that.path);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String path)?  notFound,TResult? Function( String path)?  permissionDenied,TResult? Function( String path)?  externalChangeConflict,}) {final _that = this;
switch (_that) {
case DocumentNotFound() when notFound != null:
return notFound(_that.path);case PermissionDenied() when permissionDenied != null:
return permissionDenied(_that.path);case ExternalChangeConflict() when externalChangeConflict != null:
return externalChangeConflict(_that.path);case _:
  return null;

}
}

}

/// @nodoc


class DocumentNotFound implements DocumentFailure {
  const DocumentNotFound(this.path);
  

/// The path, relative to the space root.
@override final  String path;

/// Create a copy of DocumentFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DocumentNotFoundCopyWith<DocumentNotFound> get copyWith => _$DocumentNotFoundCopyWithImpl<DocumentNotFound>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DocumentNotFound&&(identical(other.path, path) || other.path == path));
}


@override
int get hashCode => Object.hash(runtimeType,path);

@override
String toString() {
  return 'DocumentFailure.notFound(path: $path)';
}


}

/// @nodoc
abstract mixin class $DocumentNotFoundCopyWith<$Res> implements $DocumentFailureCopyWith<$Res> {
  factory $DocumentNotFoundCopyWith(DocumentNotFound value, $Res Function(DocumentNotFound) _then) = _$DocumentNotFoundCopyWithImpl;
@override @useResult
$Res call({
 String path
});




}
/// @nodoc
class _$DocumentNotFoundCopyWithImpl<$Res>
    implements $DocumentNotFoundCopyWith<$Res> {
  _$DocumentNotFoundCopyWithImpl(this._self, this._then);

  final DocumentNotFound _self;
  final $Res Function(DocumentNotFound) _then;

/// Create a copy of DocumentFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? path = null,}) {
  return _then(DocumentNotFound(
null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class PermissionDenied implements DocumentFailure {
  const PermissionDenied(this.path);
  

/// The path, relative to the space root.
@override final  String path;

/// Create a copy of DocumentFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PermissionDeniedCopyWith<PermissionDenied> get copyWith => _$PermissionDeniedCopyWithImpl<PermissionDenied>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PermissionDenied&&(identical(other.path, path) || other.path == path));
}


@override
int get hashCode => Object.hash(runtimeType,path);

@override
String toString() {
  return 'DocumentFailure.permissionDenied(path: $path)';
}


}

/// @nodoc
abstract mixin class $PermissionDeniedCopyWith<$Res> implements $DocumentFailureCopyWith<$Res> {
  factory $PermissionDeniedCopyWith(PermissionDenied value, $Res Function(PermissionDenied) _then) = _$PermissionDeniedCopyWithImpl;
@override @useResult
$Res call({
 String path
});




}
/// @nodoc
class _$PermissionDeniedCopyWithImpl<$Res>
    implements $PermissionDeniedCopyWith<$Res> {
  _$PermissionDeniedCopyWithImpl(this._self, this._then);

  final PermissionDenied _self;
  final $Res Function(PermissionDenied) _then;

/// Create a copy of DocumentFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? path = null,}) {
  return _then(PermissionDenied(
null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class ExternalChangeConflict implements DocumentFailure {
  const ExternalChangeConflict(this.path);
  

/// The path, relative to the space root.
@override final  String path;

/// Create a copy of DocumentFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExternalChangeConflictCopyWith<ExternalChangeConflict> get copyWith => _$ExternalChangeConflictCopyWithImpl<ExternalChangeConflict>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExternalChangeConflict&&(identical(other.path, path) || other.path == path));
}


@override
int get hashCode => Object.hash(runtimeType,path);

@override
String toString() {
  return 'DocumentFailure.externalChangeConflict(path: $path)';
}


}

/// @nodoc
abstract mixin class $ExternalChangeConflictCopyWith<$Res> implements $DocumentFailureCopyWith<$Res> {
  factory $ExternalChangeConflictCopyWith(ExternalChangeConflict value, $Res Function(ExternalChangeConflict) _then) = _$ExternalChangeConflictCopyWithImpl;
@override @useResult
$Res call({
 String path
});




}
/// @nodoc
class _$ExternalChangeConflictCopyWithImpl<$Res>
    implements $ExternalChangeConflictCopyWith<$Res> {
  _$ExternalChangeConflictCopyWithImpl(this._self, this._then);

  final ExternalChangeConflict _self;
  final $Res Function(ExternalChangeConflict) _then;

/// Create a copy of DocumentFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? path = null,}) {
  return _then(ExternalChangeConflict(
null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
