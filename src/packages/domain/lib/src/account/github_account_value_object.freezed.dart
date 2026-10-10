// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'github_account_value_object.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GithubAccountValueObject {

/// The login, without the `@`.
 String get login;/// The tool it was read from.
 AccountSourceEnum get source;
/// Create a copy of GithubAccountValueObject
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GithubAccountValueObjectCopyWith<GithubAccountValueObject> get copyWith => _$GithubAccountValueObjectCopyWithImpl<GithubAccountValueObject>(this as GithubAccountValueObject, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GithubAccountValueObject&&(identical(other.login, login) || other.login == login)&&(identical(other.source, source) || other.source == source));
}


@override
int get hashCode => Object.hash(runtimeType,login,source);

@override
String toString() {
  return 'GithubAccountValueObject(login: $login, source: $source)';
}


}

/// @nodoc
abstract mixin class $GithubAccountValueObjectCopyWith<$Res>  {
  factory $GithubAccountValueObjectCopyWith(GithubAccountValueObject value, $Res Function(GithubAccountValueObject) _then) = _$GithubAccountValueObjectCopyWithImpl;
@useResult
$Res call({
 String login, AccountSourceEnum source
});




}
/// @nodoc
class _$GithubAccountValueObjectCopyWithImpl<$Res>
    implements $GithubAccountValueObjectCopyWith<$Res> {
  _$GithubAccountValueObjectCopyWithImpl(this._self, this._then);

  final GithubAccountValueObject _self;
  final $Res Function(GithubAccountValueObject) _then;

/// Create a copy of GithubAccountValueObject
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? login = null,Object? source = null,}) {
  return _then(_self.copyWith(
login: null == login ? _self.login : login // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as AccountSourceEnum,
  ));
}

}


/// Adds pattern-matching-related methods to [GithubAccountValueObject].
extension GithubAccountValueObjectPatterns on GithubAccountValueObject {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GithubAccountValueObject value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GithubAccountValueObject() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GithubAccountValueObject value)  $default,){
final _that = this;
switch (_that) {
case _GithubAccountValueObject():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GithubAccountValueObject value)?  $default,){
final _that = this;
switch (_that) {
case _GithubAccountValueObject() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String login,  AccountSourceEnum source)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GithubAccountValueObject() when $default != null:
return $default(_that.login,_that.source);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String login,  AccountSourceEnum source)  $default,) {final _that = this;
switch (_that) {
case _GithubAccountValueObject():
return $default(_that.login,_that.source);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String login,  AccountSourceEnum source)?  $default,) {final _that = this;
switch (_that) {
case _GithubAccountValueObject() when $default != null:
return $default(_that.login,_that.source);case _:
  return null;

}
}

}

/// @nodoc


class _GithubAccountValueObject implements GithubAccountValueObject {
  const _GithubAccountValueObject({required this.login, required this.source});
  

/// The login, without the `@`.
@override final  String login;
/// The tool it was read from.
@override final  AccountSourceEnum source;

/// Create a copy of GithubAccountValueObject
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GithubAccountValueObjectCopyWith<_GithubAccountValueObject> get copyWith => __$GithubAccountValueObjectCopyWithImpl<_GithubAccountValueObject>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GithubAccountValueObject&&(identical(other.login, login) || other.login == login)&&(identical(other.source, source) || other.source == source));
}


@override
int get hashCode => Object.hash(runtimeType,login,source);

@override
String toString() {
  return 'GithubAccountValueObject(login: $login, source: $source)';
}


}

/// @nodoc
abstract mixin class _$GithubAccountValueObjectCopyWith<$Res> implements $GithubAccountValueObjectCopyWith<$Res> {
  factory _$GithubAccountValueObjectCopyWith(_GithubAccountValueObject value, $Res Function(_GithubAccountValueObject) _then) = __$GithubAccountValueObjectCopyWithImpl;
@override @useResult
$Res call({
 String login, AccountSourceEnum source
});




}
/// @nodoc
class __$GithubAccountValueObjectCopyWithImpl<$Res>
    implements _$GithubAccountValueObjectCopyWith<$Res> {
  __$GithubAccountValueObjectCopyWithImpl(this._self, this._then);

  final _GithubAccountValueObject _self;
  final $Res Function(_GithubAccountValueObject) _then;

/// Create a copy of GithubAccountValueObject
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? login = null,Object? source = null,}) {
  return _then(_GithubAccountValueObject(
login: null == login ? _self.login : login // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as AccountSourceEnum,
  ));
}


}

// dart format on
