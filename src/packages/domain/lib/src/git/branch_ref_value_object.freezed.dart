// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'branch_ref_value_object.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BranchRefValueObject {

/// The branch's own name, without the remote's.
 BranchNameValueObject get name;/// The remote whose copy this is, or null for a local branch.
 String? get remote;
/// Create a copy of BranchRefValueObject
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BranchRefValueObjectCopyWith<BranchRefValueObject> get copyWith => _$BranchRefValueObjectCopyWithImpl<BranchRefValueObject>(this as BranchRefValueObject, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BranchRefValueObject&&(identical(other.name, name) || other.name == name)&&(identical(other.remote, remote) || other.remote == remote));
}


@override
int get hashCode => Object.hash(runtimeType,name,remote);

@override
String toString() {
  return 'BranchRefValueObject(name: $name, remote: $remote)';
}


}

/// @nodoc
abstract mixin class $BranchRefValueObjectCopyWith<$Res>  {
  factory $BranchRefValueObjectCopyWith(BranchRefValueObject value, $Res Function(BranchRefValueObject) _then) = _$BranchRefValueObjectCopyWithImpl;
@useResult
$Res call({
 BranchNameValueObject name, String? remote
});




}
/// @nodoc
class _$BranchRefValueObjectCopyWithImpl<$Res>
    implements $BranchRefValueObjectCopyWith<$Res> {
  _$BranchRefValueObjectCopyWithImpl(this._self, this._then);

  final BranchRefValueObject _self;
  final $Res Function(BranchRefValueObject) _then;

/// Create a copy of BranchRefValueObject
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? remote = freezed,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as BranchNameValueObject,remote: freezed == remote ? _self.remote : remote // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [BranchRefValueObject].
extension BranchRefValueObjectPatterns on BranchRefValueObject {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BranchRefValueObject value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BranchRefValueObject() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BranchRefValueObject value)  $default,){
final _that = this;
switch (_that) {
case _BranchRefValueObject():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BranchRefValueObject value)?  $default,){
final _that = this;
switch (_that) {
case _BranchRefValueObject() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( BranchNameValueObject name,  String? remote)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BranchRefValueObject() when $default != null:
return $default(_that.name,_that.remote);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( BranchNameValueObject name,  String? remote)  $default,) {final _that = this;
switch (_that) {
case _BranchRefValueObject():
return $default(_that.name,_that.remote);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( BranchNameValueObject name,  String? remote)?  $default,) {final _that = this;
switch (_that) {
case _BranchRefValueObject() when $default != null:
return $default(_that.name,_that.remote);case _:
  return null;

}
}

}

/// @nodoc


class _BranchRefValueObject extends BranchRefValueObject {
  const _BranchRefValueObject({required this.name, this.remote}): super._();
  

/// The branch's own name, without the remote's.
@override final  BranchNameValueObject name;
/// The remote whose copy this is, or null for a local branch.
@override final  String? remote;

/// Create a copy of BranchRefValueObject
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BranchRefValueObjectCopyWith<_BranchRefValueObject> get copyWith => __$BranchRefValueObjectCopyWithImpl<_BranchRefValueObject>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BranchRefValueObject&&(identical(other.name, name) || other.name == name)&&(identical(other.remote, remote) || other.remote == remote));
}


@override
int get hashCode => Object.hash(runtimeType,name,remote);

@override
String toString() {
  return 'BranchRefValueObject(name: $name, remote: $remote)';
}


}

/// @nodoc
abstract mixin class _$BranchRefValueObjectCopyWith<$Res> implements $BranchRefValueObjectCopyWith<$Res> {
  factory _$BranchRefValueObjectCopyWith(_BranchRefValueObject value, $Res Function(_BranchRefValueObject) _then) = __$BranchRefValueObjectCopyWithImpl;
@override @useResult
$Res call({
 BranchNameValueObject name, String? remote
});




}
/// @nodoc
class __$BranchRefValueObjectCopyWithImpl<$Res>
    implements _$BranchRefValueObjectCopyWith<$Res> {
  __$BranchRefValueObjectCopyWithImpl(this._self, this._then);

  final _BranchRefValueObject _self;
  final $Res Function(_BranchRefValueObject) _then;

/// Create a copy of BranchRefValueObject
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? remote = freezed,}) {
  return _then(_BranchRefValueObject(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as BranchNameValueObject,remote: freezed == remote ? _self.remote : remote // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
