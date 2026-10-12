// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'commit_identity_value_object.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CommitIdentityValueObject {

 String? get name; String? get email;
/// Create a copy of CommitIdentityValueObject
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommitIdentityValueObjectCopyWith<CommitIdentityValueObject> get copyWith => _$CommitIdentityValueObjectCopyWithImpl<CommitIdentityValueObject>(this as CommitIdentityValueObject, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommitIdentityValueObject&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email));
}


@override
int get hashCode => Object.hash(runtimeType,name,email);

@override
String toString() {
  return 'CommitIdentityValueObject(name: $name, email: $email)';
}


}

/// @nodoc
abstract mixin class $CommitIdentityValueObjectCopyWith<$Res>  {
  factory $CommitIdentityValueObjectCopyWith(CommitIdentityValueObject value, $Res Function(CommitIdentityValueObject) _then) = _$CommitIdentityValueObjectCopyWithImpl;
@useResult
$Res call({
 String? name, String? email
});




}
/// @nodoc
class _$CommitIdentityValueObjectCopyWithImpl<$Res>
    implements $CommitIdentityValueObjectCopyWith<$Res> {
  _$CommitIdentityValueObjectCopyWithImpl(this._self, this._then);

  final CommitIdentityValueObject _self;
  final $Res Function(CommitIdentityValueObject) _then;

/// Create a copy of CommitIdentityValueObject
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = freezed,Object? email = freezed,}) {
  return _then(_self.copyWith(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CommitIdentityValueObject].
extension CommitIdentityValueObjectPatterns on CommitIdentityValueObject {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CommitIdentityValueObject value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CommitIdentityValueObject() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CommitIdentityValueObject value)  $default,){
final _that = this;
switch (_that) {
case _CommitIdentityValueObject():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CommitIdentityValueObject value)?  $default,){
final _that = this;
switch (_that) {
case _CommitIdentityValueObject() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? name,  String? email)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CommitIdentityValueObject() when $default != null:
return $default(_that.name,_that.email);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? name,  String? email)  $default,) {final _that = this;
switch (_that) {
case _CommitIdentityValueObject():
return $default(_that.name,_that.email);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? name,  String? email)?  $default,) {final _that = this;
switch (_that) {
case _CommitIdentityValueObject() when $default != null:
return $default(_that.name,_that.email);case _:
  return null;

}
}

}

/// @nodoc


class _CommitIdentityValueObject extends CommitIdentityValueObject {
  const _CommitIdentityValueObject({this.name, this.email}): super._();
  

@override final  String? name;
@override final  String? email;

/// Create a copy of CommitIdentityValueObject
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommitIdentityValueObjectCopyWith<_CommitIdentityValueObject> get copyWith => __$CommitIdentityValueObjectCopyWithImpl<_CommitIdentityValueObject>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommitIdentityValueObject&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email));
}


@override
int get hashCode => Object.hash(runtimeType,name,email);

@override
String toString() {
  return 'CommitIdentityValueObject(name: $name, email: $email)';
}


}

/// @nodoc
abstract mixin class _$CommitIdentityValueObjectCopyWith<$Res> implements $CommitIdentityValueObjectCopyWith<$Res> {
  factory _$CommitIdentityValueObjectCopyWith(_CommitIdentityValueObject value, $Res Function(_CommitIdentityValueObject) _then) = __$CommitIdentityValueObjectCopyWithImpl;
@override @useResult
$Res call({
 String? name, String? email
});




}
/// @nodoc
class __$CommitIdentityValueObjectCopyWithImpl<$Res>
    implements _$CommitIdentityValueObjectCopyWith<$Res> {
  __$CommitIdentityValueObjectCopyWithImpl(this._self, this._then);

  final _CommitIdentityValueObject _self;
  final $Res Function(_CommitIdentityValueObject) _then;

/// Create a copy of CommitIdentityValueObject
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = freezed,Object? email = freezed,}) {
  return _then(_CommitIdentityValueObject(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
