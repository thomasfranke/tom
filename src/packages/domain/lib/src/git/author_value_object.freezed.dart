// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'author_value_object.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AuthorValueObject {

/// The name, as `user.name` held it when the commit was made.
 String get name;/// The email, as `user.email` held it when the commit was made.
 String get email;
/// Create a copy of AuthorValueObject
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthorValueObjectCopyWith<AuthorValueObject> get copyWith => _$AuthorValueObjectCopyWithImpl<AuthorValueObject>(this as AuthorValueObject, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthorValueObject&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email));
}


@override
int get hashCode => Object.hash(runtimeType,name,email);

@override
String toString() {
  return 'AuthorValueObject(name: $name, email: $email)';
}


}

/// @nodoc
abstract mixin class $AuthorValueObjectCopyWith<$Res>  {
  factory $AuthorValueObjectCopyWith(AuthorValueObject value, $Res Function(AuthorValueObject) _then) = _$AuthorValueObjectCopyWithImpl;
@useResult
$Res call({
 String name, String email
});




}
/// @nodoc
class _$AuthorValueObjectCopyWithImpl<$Res>
    implements $AuthorValueObjectCopyWith<$Res> {
  _$AuthorValueObjectCopyWithImpl(this._self, this._then);

  final AuthorValueObject _self;
  final $Res Function(AuthorValueObject) _then;

/// Create a copy of AuthorValueObject
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? email = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AuthorValueObject].
extension AuthorValueObjectPatterns on AuthorValueObject {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuthorValueObject value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuthorValueObject() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuthorValueObject value)  $default,){
final _that = this;
switch (_that) {
case _AuthorValueObject():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuthorValueObject value)?  $default,){
final _that = this;
switch (_that) {
case _AuthorValueObject() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String email)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuthorValueObject() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String email)  $default,) {final _that = this;
switch (_that) {
case _AuthorValueObject():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String email)?  $default,) {final _that = this;
switch (_that) {
case _AuthorValueObject() when $default != null:
return $default(_that.name,_that.email);case _:
  return null;

}
}

}

/// @nodoc


class _AuthorValueObject implements AuthorValueObject {
  const _AuthorValueObject({required this.name, required this.email});
  

/// The name, as `user.name` held it when the commit was made.
@override final  String name;
/// The email, as `user.email` held it when the commit was made.
@override final  String email;

/// Create a copy of AuthorValueObject
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthorValueObjectCopyWith<_AuthorValueObject> get copyWith => __$AuthorValueObjectCopyWithImpl<_AuthorValueObject>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuthorValueObject&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email));
}


@override
int get hashCode => Object.hash(runtimeType,name,email);

@override
String toString() {
  return 'AuthorValueObject(name: $name, email: $email)';
}


}

/// @nodoc
abstract mixin class _$AuthorValueObjectCopyWith<$Res> implements $AuthorValueObjectCopyWith<$Res> {
  factory _$AuthorValueObjectCopyWith(_AuthorValueObject value, $Res Function(_AuthorValueObject) _then) = __$AuthorValueObjectCopyWithImpl;
@override @useResult
$Res call({
 String name, String email
});




}
/// @nodoc
class __$AuthorValueObjectCopyWithImpl<$Res>
    implements _$AuthorValueObjectCopyWith<$Res> {
  __$AuthorValueObjectCopyWithImpl(this._self, this._then);

  final _AuthorValueObject _self;
  final $Res Function(_AuthorValueObject) _then;

/// Create a copy of AuthorValueObject
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? email = null,}) {
  return _then(_AuthorValueObject(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
