// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'repository_access_value_object.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RepositoryAccessValueObject {

 bool get canRead; bool get canOpenPullRequests; bool get canPush; bool get canMerge; bool get canAdminister;
/// Create a copy of RepositoryAccessValueObject
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RepositoryAccessValueObjectCopyWith<RepositoryAccessValueObject> get copyWith => _$RepositoryAccessValueObjectCopyWithImpl<RepositoryAccessValueObject>(this as RepositoryAccessValueObject, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RepositoryAccessValueObject&&(identical(other.canRead, canRead) || other.canRead == canRead)&&(identical(other.canOpenPullRequests, canOpenPullRequests) || other.canOpenPullRequests == canOpenPullRequests)&&(identical(other.canPush, canPush) || other.canPush == canPush)&&(identical(other.canMerge, canMerge) || other.canMerge == canMerge)&&(identical(other.canAdminister, canAdminister) || other.canAdminister == canAdminister));
}


@override
int get hashCode => Object.hash(runtimeType,canRead,canOpenPullRequests,canPush,canMerge,canAdminister);

@override
String toString() {
  return 'RepositoryAccessValueObject(canRead: $canRead, canOpenPullRequests: $canOpenPullRequests, canPush: $canPush, canMerge: $canMerge, canAdminister: $canAdminister)';
}


}

/// @nodoc
abstract mixin class $RepositoryAccessValueObjectCopyWith<$Res>  {
  factory $RepositoryAccessValueObjectCopyWith(RepositoryAccessValueObject value, $Res Function(RepositoryAccessValueObject) _then) = _$RepositoryAccessValueObjectCopyWithImpl;
@useResult
$Res call({
 bool canRead, bool canOpenPullRequests, bool canPush, bool canMerge, bool canAdminister
});




}
/// @nodoc
class _$RepositoryAccessValueObjectCopyWithImpl<$Res>
    implements $RepositoryAccessValueObjectCopyWith<$Res> {
  _$RepositoryAccessValueObjectCopyWithImpl(this._self, this._then);

  final RepositoryAccessValueObject _self;
  final $Res Function(RepositoryAccessValueObject) _then;

/// Create a copy of RepositoryAccessValueObject
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? canRead = null,Object? canOpenPullRequests = null,Object? canPush = null,Object? canMerge = null,Object? canAdminister = null,}) {
  return _then(_self.copyWith(
canRead: null == canRead ? _self.canRead : canRead // ignore: cast_nullable_to_non_nullable
as bool,canOpenPullRequests: null == canOpenPullRequests ? _self.canOpenPullRequests : canOpenPullRequests // ignore: cast_nullable_to_non_nullable
as bool,canPush: null == canPush ? _self.canPush : canPush // ignore: cast_nullable_to_non_nullable
as bool,canMerge: null == canMerge ? _self.canMerge : canMerge // ignore: cast_nullable_to_non_nullable
as bool,canAdminister: null == canAdminister ? _self.canAdminister : canAdminister // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [RepositoryAccessValueObject].
extension RepositoryAccessValueObjectPatterns on RepositoryAccessValueObject {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RepositoryAccessValueObject value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RepositoryAccessValueObject() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RepositoryAccessValueObject value)  $default,){
final _that = this;
switch (_that) {
case _RepositoryAccessValueObject():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RepositoryAccessValueObject value)?  $default,){
final _that = this;
switch (_that) {
case _RepositoryAccessValueObject() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool canRead,  bool canOpenPullRequests,  bool canPush,  bool canMerge,  bool canAdminister)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RepositoryAccessValueObject() when $default != null:
return $default(_that.canRead,_that.canOpenPullRequests,_that.canPush,_that.canMerge,_that.canAdminister);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool canRead,  bool canOpenPullRequests,  bool canPush,  bool canMerge,  bool canAdminister)  $default,) {final _that = this;
switch (_that) {
case _RepositoryAccessValueObject():
return $default(_that.canRead,_that.canOpenPullRequests,_that.canPush,_that.canMerge,_that.canAdminister);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool canRead,  bool canOpenPullRequests,  bool canPush,  bool canMerge,  bool canAdminister)?  $default,) {final _that = this;
switch (_that) {
case _RepositoryAccessValueObject() when $default != null:
return $default(_that.canRead,_that.canOpenPullRequests,_that.canPush,_that.canMerge,_that.canAdminister);case _:
  return null;

}
}

}

/// @nodoc


class _RepositoryAccessValueObject implements RepositoryAccessValueObject {
  const _RepositoryAccessValueObject({required this.canRead, required this.canOpenPullRequests, required this.canPush, required this.canMerge, required this.canAdminister});
  

@override final  bool canRead;
@override final  bool canOpenPullRequests;
@override final  bool canPush;
@override final  bool canMerge;
@override final  bool canAdminister;

/// Create a copy of RepositoryAccessValueObject
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RepositoryAccessValueObjectCopyWith<_RepositoryAccessValueObject> get copyWith => __$RepositoryAccessValueObjectCopyWithImpl<_RepositoryAccessValueObject>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RepositoryAccessValueObject&&(identical(other.canRead, canRead) || other.canRead == canRead)&&(identical(other.canOpenPullRequests, canOpenPullRequests) || other.canOpenPullRequests == canOpenPullRequests)&&(identical(other.canPush, canPush) || other.canPush == canPush)&&(identical(other.canMerge, canMerge) || other.canMerge == canMerge)&&(identical(other.canAdminister, canAdminister) || other.canAdminister == canAdminister));
}


@override
int get hashCode => Object.hash(runtimeType,canRead,canOpenPullRequests,canPush,canMerge,canAdminister);

@override
String toString() {
  return 'RepositoryAccessValueObject(canRead: $canRead, canOpenPullRequests: $canOpenPullRequests, canPush: $canPush, canMerge: $canMerge, canAdminister: $canAdminister)';
}


}

/// @nodoc
abstract mixin class _$RepositoryAccessValueObjectCopyWith<$Res> implements $RepositoryAccessValueObjectCopyWith<$Res> {
  factory _$RepositoryAccessValueObjectCopyWith(_RepositoryAccessValueObject value, $Res Function(_RepositoryAccessValueObject) _then) = __$RepositoryAccessValueObjectCopyWithImpl;
@override @useResult
$Res call({
 bool canRead, bool canOpenPullRequests, bool canPush, bool canMerge, bool canAdminister
});




}
/// @nodoc
class __$RepositoryAccessValueObjectCopyWithImpl<$Res>
    implements _$RepositoryAccessValueObjectCopyWith<$Res> {
  __$RepositoryAccessValueObjectCopyWithImpl(this._self, this._then);

  final _RepositoryAccessValueObject _self;
  final $Res Function(_RepositoryAccessValueObject) _then;

/// Create a copy of RepositoryAccessValueObject
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? canRead = null,Object? canOpenPullRequests = null,Object? canPush = null,Object? canMerge = null,Object? canAdminister = null,}) {
  return _then(_RepositoryAccessValueObject(
canRead: null == canRead ? _self.canRead : canRead // ignore: cast_nullable_to_non_nullable
as bool,canOpenPullRequests: null == canOpenPullRequests ? _self.canOpenPullRequests : canOpenPullRequests // ignore: cast_nullable_to_non_nullable
as bool,canPush: null == canPush ? _self.canPush : canPush // ignore: cast_nullable_to_non_nullable
as bool,canMerge: null == canMerge ? _self.canMerge : canMerge // ignore: cast_nullable_to_non_nullable
as bool,canAdminister: null == canAdminister ? _self.canAdminister : canAdminister // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
