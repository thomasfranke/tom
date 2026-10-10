// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'diff_base_value_object.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DiffBaseValueObject {

/// The branch, as the bar names it.
 BranchRefValueObject get branch;/// `merge-base` of `HEAD` and [branch] — what the document is read at.
 CommitShaValueObject get forkPoint;
/// Create a copy of DiffBaseValueObject
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DiffBaseValueObjectCopyWith<DiffBaseValueObject> get copyWith => _$DiffBaseValueObjectCopyWithImpl<DiffBaseValueObject>(this as DiffBaseValueObject, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DiffBaseValueObject&&(identical(other.branch, branch) || other.branch == branch)&&(identical(other.forkPoint, forkPoint) || other.forkPoint == forkPoint));
}


@override
int get hashCode => Object.hash(runtimeType,branch,forkPoint);

@override
String toString() {
  return 'DiffBaseValueObject(branch: $branch, forkPoint: $forkPoint)';
}


}

/// @nodoc
abstract mixin class $DiffBaseValueObjectCopyWith<$Res>  {
  factory $DiffBaseValueObjectCopyWith(DiffBaseValueObject value, $Res Function(DiffBaseValueObject) _then) = _$DiffBaseValueObjectCopyWithImpl;
@useResult
$Res call({
 BranchRefValueObject branch, CommitShaValueObject forkPoint
});


$BranchRefValueObjectCopyWith<$Res> get branch;

}
/// @nodoc
class _$DiffBaseValueObjectCopyWithImpl<$Res>
    implements $DiffBaseValueObjectCopyWith<$Res> {
  _$DiffBaseValueObjectCopyWithImpl(this._self, this._then);

  final DiffBaseValueObject _self;
  final $Res Function(DiffBaseValueObject) _then;

/// Create a copy of DiffBaseValueObject
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? branch = null,Object? forkPoint = null,}) {
  return _then(_self.copyWith(
branch: null == branch ? _self.branch : branch // ignore: cast_nullable_to_non_nullable
as BranchRefValueObject,forkPoint: null == forkPoint ? _self.forkPoint : forkPoint // ignore: cast_nullable_to_non_nullable
as CommitShaValueObject,
  ));
}
/// Create a copy of DiffBaseValueObject
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BranchRefValueObjectCopyWith<$Res> get branch {
  
  return $BranchRefValueObjectCopyWith<$Res>(_self.branch, (value) {
    return _then(_self.copyWith(branch: value));
  });
}
}


/// Adds pattern-matching-related methods to [DiffBaseValueObject].
extension DiffBaseValueObjectPatterns on DiffBaseValueObject {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DiffBaseValueObject value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DiffBaseValueObject() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DiffBaseValueObject value)  $default,){
final _that = this;
switch (_that) {
case _DiffBaseValueObject():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DiffBaseValueObject value)?  $default,){
final _that = this;
switch (_that) {
case _DiffBaseValueObject() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( BranchRefValueObject branch,  CommitShaValueObject forkPoint)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DiffBaseValueObject() when $default != null:
return $default(_that.branch,_that.forkPoint);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( BranchRefValueObject branch,  CommitShaValueObject forkPoint)  $default,) {final _that = this;
switch (_that) {
case _DiffBaseValueObject():
return $default(_that.branch,_that.forkPoint);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( BranchRefValueObject branch,  CommitShaValueObject forkPoint)?  $default,) {final _that = this;
switch (_that) {
case _DiffBaseValueObject() when $default != null:
return $default(_that.branch,_that.forkPoint);case _:
  return null;

}
}

}

/// @nodoc


class _DiffBaseValueObject implements DiffBaseValueObject {
  const _DiffBaseValueObject({required this.branch, required this.forkPoint});
  

/// The branch, as the bar names it.
@override final  BranchRefValueObject branch;
/// `merge-base` of `HEAD` and [branch] — what the document is read at.
@override final  CommitShaValueObject forkPoint;

/// Create a copy of DiffBaseValueObject
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DiffBaseValueObjectCopyWith<_DiffBaseValueObject> get copyWith => __$DiffBaseValueObjectCopyWithImpl<_DiffBaseValueObject>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DiffBaseValueObject&&(identical(other.branch, branch) || other.branch == branch)&&(identical(other.forkPoint, forkPoint) || other.forkPoint == forkPoint));
}


@override
int get hashCode => Object.hash(runtimeType,branch,forkPoint);

@override
String toString() {
  return 'DiffBaseValueObject(branch: $branch, forkPoint: $forkPoint)';
}


}

/// @nodoc
abstract mixin class _$DiffBaseValueObjectCopyWith<$Res> implements $DiffBaseValueObjectCopyWith<$Res> {
  factory _$DiffBaseValueObjectCopyWith(_DiffBaseValueObject value, $Res Function(_DiffBaseValueObject) _then) = __$DiffBaseValueObjectCopyWithImpl;
@override @useResult
$Res call({
 BranchRefValueObject branch, CommitShaValueObject forkPoint
});


@override $BranchRefValueObjectCopyWith<$Res> get branch;

}
/// @nodoc
class __$DiffBaseValueObjectCopyWithImpl<$Res>
    implements _$DiffBaseValueObjectCopyWith<$Res> {
  __$DiffBaseValueObjectCopyWithImpl(this._self, this._then);

  final _DiffBaseValueObject _self;
  final $Res Function(_DiffBaseValueObject) _then;

/// Create a copy of DiffBaseValueObject
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? branch = null,Object? forkPoint = null,}) {
  return _then(_DiffBaseValueObject(
branch: null == branch ? _self.branch : branch // ignore: cast_nullable_to_non_nullable
as BranchRefValueObject,forkPoint: null == forkPoint ? _self.forkPoint : forkPoint // ignore: cast_nullable_to_non_nullable
as CommitShaValueObject,
  ));
}

/// Create a copy of DiffBaseValueObject
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BranchRefValueObjectCopyWith<$Res> get branch {
  
  return $BranchRefValueObjectCopyWith<$Res>(_self.branch, (value) {
    return _then(_self.copyWith(branch: value));
  });
}
}

// dart format on
