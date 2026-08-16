// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'filesystem_failure.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FilesystemFailure {

/// The path that was asked for.
 String get path;
/// Create a copy of FilesystemFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FilesystemFailureCopyWith<FilesystemFailure> get copyWith => _$FilesystemFailureCopyWithImpl<FilesystemFailure>(this as FilesystemFailure, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FilesystemFailure&&(identical(other.path, path) || other.path == path));
}


@override
int get hashCode => Object.hash(runtimeType,path);

@override
String toString() {
  return 'FilesystemFailure(path: $path)';
}


}

/// @nodoc
abstract mixin class $FilesystemFailureCopyWith<$Res>  {
  factory $FilesystemFailureCopyWith(FilesystemFailure value, $Res Function(FilesystemFailure) _then) = _$FilesystemFailureCopyWithImpl;
@useResult
$Res call({
 String path
});




}
/// @nodoc
class _$FilesystemFailureCopyWithImpl<$Res>
    implements $FilesystemFailureCopyWith<$Res> {
  _$FilesystemFailureCopyWithImpl(this._self, this._then);

  final FilesystemFailure _self;
  final $Res Function(FilesystemFailure) _then;

/// Create a copy of FilesystemFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? path = null,}) {
  return _then(_self.copyWith(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [FilesystemFailure].
extension FilesystemFailurePatterns on FilesystemFailure {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( FilesystemEntryNotFound value)?  entryNotFound,TResult Function( FilesystemAccessDenied value)?  accessDenied,TResult Function( FilesystemOperationFailed value)?  operationFailed,required TResult orElse(),}){
final _that = this;
switch (_that) {
case FilesystemEntryNotFound() when entryNotFound != null:
return entryNotFound(_that);case FilesystemAccessDenied() when accessDenied != null:
return accessDenied(_that);case FilesystemOperationFailed() when operationFailed != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( FilesystemEntryNotFound value)  entryNotFound,required TResult Function( FilesystemAccessDenied value)  accessDenied,required TResult Function( FilesystemOperationFailed value)  operationFailed,}){
final _that = this;
switch (_that) {
case FilesystemEntryNotFound():
return entryNotFound(_that);case FilesystemAccessDenied():
return accessDenied(_that);case FilesystemOperationFailed():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( FilesystemEntryNotFound value)?  entryNotFound,TResult? Function( FilesystemAccessDenied value)?  accessDenied,TResult? Function( FilesystemOperationFailed value)?  operationFailed,}){
final _that = this;
switch (_that) {
case FilesystemEntryNotFound() when entryNotFound != null:
return entryNotFound(_that);case FilesystemAccessDenied() when accessDenied != null:
return accessDenied(_that);case FilesystemOperationFailed() when operationFailed != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String path)?  entryNotFound,TResult Function( String path)?  accessDenied,TResult Function( String path,  String description)?  operationFailed,required TResult orElse(),}) {final _that = this;
switch (_that) {
case FilesystemEntryNotFound() when entryNotFound != null:
return entryNotFound(_that.path);case FilesystemAccessDenied() when accessDenied != null:
return accessDenied(_that.path);case FilesystemOperationFailed() when operationFailed != null:
return operationFailed(_that.path,_that.description);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String path)  entryNotFound,required TResult Function( String path)  accessDenied,required TResult Function( String path,  String description)  operationFailed,}) {final _that = this;
switch (_that) {
case FilesystemEntryNotFound():
return entryNotFound(_that.path);case FilesystemAccessDenied():
return accessDenied(_that.path);case FilesystemOperationFailed():
return operationFailed(_that.path,_that.description);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String path)?  entryNotFound,TResult? Function( String path)?  accessDenied,TResult? Function( String path,  String description)?  operationFailed,}) {final _that = this;
switch (_that) {
case FilesystemEntryNotFound() when entryNotFound != null:
return entryNotFound(_that.path);case FilesystemAccessDenied() when accessDenied != null:
return accessDenied(_that.path);case FilesystemOperationFailed() when operationFailed != null:
return operationFailed(_that.path,_that.description);case _:
  return null;

}
}

}

/// @nodoc


class FilesystemEntryNotFound implements FilesystemFailure {
  const FilesystemEntryNotFound(this.path);
  

/// The path that was asked for.
@override final  String path;

/// Create a copy of FilesystemFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FilesystemEntryNotFoundCopyWith<FilesystemEntryNotFound> get copyWith => _$FilesystemEntryNotFoundCopyWithImpl<FilesystemEntryNotFound>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FilesystemEntryNotFound&&(identical(other.path, path) || other.path == path));
}


@override
int get hashCode => Object.hash(runtimeType,path);

@override
String toString() {
  return 'FilesystemFailure.entryNotFound(path: $path)';
}


}

/// @nodoc
abstract mixin class $FilesystemEntryNotFoundCopyWith<$Res> implements $FilesystemFailureCopyWith<$Res> {
  factory $FilesystemEntryNotFoundCopyWith(FilesystemEntryNotFound value, $Res Function(FilesystemEntryNotFound) _then) = _$FilesystemEntryNotFoundCopyWithImpl;
@override @useResult
$Res call({
 String path
});




}
/// @nodoc
class _$FilesystemEntryNotFoundCopyWithImpl<$Res>
    implements $FilesystemEntryNotFoundCopyWith<$Res> {
  _$FilesystemEntryNotFoundCopyWithImpl(this._self, this._then);

  final FilesystemEntryNotFound _self;
  final $Res Function(FilesystemEntryNotFound) _then;

/// Create a copy of FilesystemFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? path = null,}) {
  return _then(FilesystemEntryNotFound(
null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class FilesystemAccessDenied implements FilesystemFailure {
  const FilesystemAccessDenied(this.path);
  

/// The path the operation was denied on.
@override final  String path;

/// Create a copy of FilesystemFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FilesystemAccessDeniedCopyWith<FilesystemAccessDenied> get copyWith => _$FilesystemAccessDeniedCopyWithImpl<FilesystemAccessDenied>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FilesystemAccessDenied&&(identical(other.path, path) || other.path == path));
}


@override
int get hashCode => Object.hash(runtimeType,path);

@override
String toString() {
  return 'FilesystemFailure.accessDenied(path: $path)';
}


}

/// @nodoc
abstract mixin class $FilesystemAccessDeniedCopyWith<$Res> implements $FilesystemFailureCopyWith<$Res> {
  factory $FilesystemAccessDeniedCopyWith(FilesystemAccessDenied value, $Res Function(FilesystemAccessDenied) _then) = _$FilesystemAccessDeniedCopyWithImpl;
@override @useResult
$Res call({
 String path
});




}
/// @nodoc
class _$FilesystemAccessDeniedCopyWithImpl<$Res>
    implements $FilesystemAccessDeniedCopyWith<$Res> {
  _$FilesystemAccessDeniedCopyWithImpl(this._self, this._then);

  final FilesystemAccessDenied _self;
  final $Res Function(FilesystemAccessDenied) _then;

/// Create a copy of FilesystemFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? path = null,}) {
  return _then(FilesystemAccessDenied(
null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class FilesystemOperationFailed implements FilesystemFailure {
  const FilesystemOperationFailed(this.path, this.description);
  

/// The path the operation was attempted on.
@override final  String path;
/// What `dart:io` reported, verbatim. For diagnostics — never parsed.
 final  String description;

/// Create a copy of FilesystemFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FilesystemOperationFailedCopyWith<FilesystemOperationFailed> get copyWith => _$FilesystemOperationFailedCopyWithImpl<FilesystemOperationFailed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FilesystemOperationFailed&&(identical(other.path, path) || other.path == path)&&(identical(other.description, description) || other.description == description));
}


@override
int get hashCode => Object.hash(runtimeType,path,description);

@override
String toString() {
  return 'FilesystemFailure.operationFailed(path: $path, description: $description)';
}


}

/// @nodoc
abstract mixin class $FilesystemOperationFailedCopyWith<$Res> implements $FilesystemFailureCopyWith<$Res> {
  factory $FilesystemOperationFailedCopyWith(FilesystemOperationFailed value, $Res Function(FilesystemOperationFailed) _then) = _$FilesystemOperationFailedCopyWithImpl;
@override @useResult
$Res call({
 String path, String description
});




}
/// @nodoc
class _$FilesystemOperationFailedCopyWithImpl<$Res>
    implements $FilesystemOperationFailedCopyWith<$Res> {
  _$FilesystemOperationFailedCopyWithImpl(this._self, this._then);

  final FilesystemOperationFailed _self;
  final $Res Function(FilesystemOperationFailed) _then;

/// Create a copy of FilesystemFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? path = null,Object? description = null,}) {
  return _then(FilesystemOperationFailed(
null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
