// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'space_failure.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SpaceFailure {

 AppFailure? get cause;
/// Create a copy of SpaceFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SpaceFailureCopyWith<SpaceFailure> get copyWith => _$SpaceFailureCopyWithImpl<SpaceFailure>(this as SpaceFailure, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SpaceFailure&&(identical(other.cause, cause) || other.cause == cause));
}


@override
int get hashCode => Object.hash(runtimeType,cause);

@override
String toString() {
  return 'SpaceFailure(cause: $cause)';
}


}

/// @nodoc
abstract mixin class $SpaceFailureCopyWith<$Res>  {
  factory $SpaceFailureCopyWith(SpaceFailure value, $Res Function(SpaceFailure) _then) = _$SpaceFailureCopyWithImpl;
@useResult
$Res call({
 AppFailure? cause
});




}
/// @nodoc
class _$SpaceFailureCopyWithImpl<$Res>
    implements $SpaceFailureCopyWith<$Res> {
  _$SpaceFailureCopyWithImpl(this._self, this._then);

  final SpaceFailure _self;
  final $Res Function(SpaceFailure) _then;

/// Create a copy of SpaceFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? cause = freezed,}) {
  return _then(_self.copyWith(
cause: freezed == cause ? _self.cause : cause // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}

}


/// Adds pattern-matching-related methods to [SpaceFailure].
extension SpaceFailurePatterns on SpaceFailure {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( SpaceFolderMissing value)?  folderMissing,TResult Function( SpaceAccessDenied value)?  accessDenied,TResult Function( SpaceOperationFailed value)?  operationFailed,required TResult orElse(),}){
final _that = this;
switch (_that) {
case SpaceFolderMissing() when folderMissing != null:
return folderMissing(_that);case SpaceAccessDenied() when accessDenied != null:
return accessDenied(_that);case SpaceOperationFailed() when operationFailed != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( SpaceFolderMissing value)  folderMissing,required TResult Function( SpaceAccessDenied value)  accessDenied,required TResult Function( SpaceOperationFailed value)  operationFailed,}){
final _that = this;
switch (_that) {
case SpaceFolderMissing():
return folderMissing(_that);case SpaceAccessDenied():
return accessDenied(_that);case SpaceOperationFailed():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( SpaceFolderMissing value)?  folderMissing,TResult? Function( SpaceAccessDenied value)?  accessDenied,TResult? Function( SpaceOperationFailed value)?  operationFailed,}){
final _that = this;
switch (_that) {
case SpaceFolderMissing() when folderMissing != null:
return folderMissing(_that);case SpaceAccessDenied() when accessDenied != null:
return accessDenied(_that);case SpaceOperationFailed() when operationFailed != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String root,  AppFailure? cause)?  folderMissing,TResult Function( String path,  AppFailure? cause)?  accessDenied,TResult Function( String path,  AppFailure? cause)?  operationFailed,required TResult orElse(),}) {final _that = this;
switch (_that) {
case SpaceFolderMissing() when folderMissing != null:
return folderMissing(_that.root,_that.cause);case SpaceAccessDenied() when accessDenied != null:
return accessDenied(_that.path,_that.cause);case SpaceOperationFailed() when operationFailed != null:
return operationFailed(_that.path,_that.cause);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String root,  AppFailure? cause)  folderMissing,required TResult Function( String path,  AppFailure? cause)  accessDenied,required TResult Function( String path,  AppFailure? cause)  operationFailed,}) {final _that = this;
switch (_that) {
case SpaceFolderMissing():
return folderMissing(_that.root,_that.cause);case SpaceAccessDenied():
return accessDenied(_that.path,_that.cause);case SpaceOperationFailed():
return operationFailed(_that.path,_that.cause);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String root,  AppFailure? cause)?  folderMissing,TResult? Function( String path,  AppFailure? cause)?  accessDenied,TResult? Function( String path,  AppFailure? cause)?  operationFailed,}) {final _that = this;
switch (_that) {
case SpaceFolderMissing() when folderMissing != null:
return folderMissing(_that.root,_that.cause);case SpaceAccessDenied() when accessDenied != null:
return accessDenied(_that.path,_that.cause);case SpaceOperationFailed() when operationFailed != null:
return operationFailed(_that.path,_that.cause);case _:
  return null;

}
}

}

/// @nodoc


class SpaceFolderMissing implements SpaceFailure {
  const SpaceFolderMissing(this.root, {this.cause});
  

/// The absolute path the space was opened at.
 final  String root;
@override final  AppFailure? cause;

/// Create a copy of SpaceFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SpaceFolderMissingCopyWith<SpaceFolderMissing> get copyWith => _$SpaceFolderMissingCopyWithImpl<SpaceFolderMissing>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SpaceFolderMissing&&(identical(other.root, root) || other.root == root)&&(identical(other.cause, cause) || other.cause == cause));
}


@override
int get hashCode => Object.hash(runtimeType,root,cause);

@override
String toString() {
  return 'SpaceFailure.folderMissing(root: $root, cause: $cause)';
}


}

/// @nodoc
abstract mixin class $SpaceFolderMissingCopyWith<$Res> implements $SpaceFailureCopyWith<$Res> {
  factory $SpaceFolderMissingCopyWith(SpaceFolderMissing value, $Res Function(SpaceFolderMissing) _then) = _$SpaceFolderMissingCopyWithImpl;
@override @useResult
$Res call({
 String root, AppFailure? cause
});




}
/// @nodoc
class _$SpaceFolderMissingCopyWithImpl<$Res>
    implements $SpaceFolderMissingCopyWith<$Res> {
  _$SpaceFolderMissingCopyWithImpl(this._self, this._then);

  final SpaceFolderMissing _self;
  final $Res Function(SpaceFolderMissing) _then;

/// Create a copy of SpaceFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? root = null,Object? cause = freezed,}) {
  return _then(SpaceFolderMissing(
null == root ? _self.root : root // ignore: cast_nullable_to_non_nullable
as String,cause: freezed == cause ? _self.cause : cause // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}


}

/// @nodoc


class SpaceAccessDenied implements SpaceFailure {
  const SpaceAccessDenied(this.path, {this.cause});
  

/// The absolute path that could not be read.
///
/// The folder that actually failed, which inside a recursive walk is
/// rarely the space root.
 final  String path;
@override final  AppFailure? cause;

/// Create a copy of SpaceFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SpaceAccessDeniedCopyWith<SpaceAccessDenied> get copyWith => _$SpaceAccessDeniedCopyWithImpl<SpaceAccessDenied>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SpaceAccessDenied&&(identical(other.path, path) || other.path == path)&&(identical(other.cause, cause) || other.cause == cause));
}


@override
int get hashCode => Object.hash(runtimeType,path,cause);

@override
String toString() {
  return 'SpaceFailure.accessDenied(path: $path, cause: $cause)';
}


}

/// @nodoc
abstract mixin class $SpaceAccessDeniedCopyWith<$Res> implements $SpaceFailureCopyWith<$Res> {
  factory $SpaceAccessDeniedCopyWith(SpaceAccessDenied value, $Res Function(SpaceAccessDenied) _then) = _$SpaceAccessDeniedCopyWithImpl;
@override @useResult
$Res call({
 String path, AppFailure? cause
});




}
/// @nodoc
class _$SpaceAccessDeniedCopyWithImpl<$Res>
    implements $SpaceAccessDeniedCopyWith<$Res> {
  _$SpaceAccessDeniedCopyWithImpl(this._self, this._then);

  final SpaceAccessDenied _self;
  final $Res Function(SpaceAccessDenied) _then;

/// Create a copy of SpaceFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? path = null,Object? cause = freezed,}) {
  return _then(SpaceAccessDenied(
null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,cause: freezed == cause ? _self.cause : cause // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}


}

/// @nodoc


class SpaceOperationFailed implements SpaceFailure {
  const SpaceOperationFailed(this.path, {this.cause});
  

/// The absolute path the operation was attempted on.
 final  String path;
@override final  AppFailure? cause;

/// Create a copy of SpaceFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SpaceOperationFailedCopyWith<SpaceOperationFailed> get copyWith => _$SpaceOperationFailedCopyWithImpl<SpaceOperationFailed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SpaceOperationFailed&&(identical(other.path, path) || other.path == path)&&(identical(other.cause, cause) || other.cause == cause));
}


@override
int get hashCode => Object.hash(runtimeType,path,cause);

@override
String toString() {
  return 'SpaceFailure.operationFailed(path: $path, cause: $cause)';
}


}

/// @nodoc
abstract mixin class $SpaceOperationFailedCopyWith<$Res> implements $SpaceFailureCopyWith<$Res> {
  factory $SpaceOperationFailedCopyWith(SpaceOperationFailed value, $Res Function(SpaceOperationFailed) _then) = _$SpaceOperationFailedCopyWithImpl;
@override @useResult
$Res call({
 String path, AppFailure? cause
});




}
/// @nodoc
class _$SpaceOperationFailedCopyWithImpl<$Res>
    implements $SpaceOperationFailedCopyWith<$Res> {
  _$SpaceOperationFailedCopyWithImpl(this._self, this._then);

  final SpaceOperationFailed _self;
  final $Res Function(SpaceOperationFailed) _then;

/// Create a copy of SpaceFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? path = null,Object? cause = freezed,}) {
  return _then(SpaceOperationFailed(
null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,cause: freezed == cause ? _self.cause : cause // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}


}

// dart format on
