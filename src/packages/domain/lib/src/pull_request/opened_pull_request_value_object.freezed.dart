// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'opened_pull_request_value_object.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OpenedPullRequestValueObject {

/// `#123`, without the `#`.
 int get number;/// Its page on the host.
 Uri get address;/// Its title on the host, which may have moved on from the draft's.
 String get title;
/// Create a copy of OpenedPullRequestValueObject
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OpenedPullRequestValueObjectCopyWith<OpenedPullRequestValueObject> get copyWith => _$OpenedPullRequestValueObjectCopyWithImpl<OpenedPullRequestValueObject>(this as OpenedPullRequestValueObject, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OpenedPullRequestValueObject&&(identical(other.number, number) || other.number == number)&&(identical(other.address, address) || other.address == address)&&(identical(other.title, title) || other.title == title));
}


@override
int get hashCode => Object.hash(runtimeType,number,address,title);

@override
String toString() {
  return 'OpenedPullRequestValueObject(number: $number, address: $address, title: $title)';
}


}

/// @nodoc
abstract mixin class $OpenedPullRequestValueObjectCopyWith<$Res>  {
  factory $OpenedPullRequestValueObjectCopyWith(OpenedPullRequestValueObject value, $Res Function(OpenedPullRequestValueObject) _then) = _$OpenedPullRequestValueObjectCopyWithImpl;
@useResult
$Res call({
 int number, Uri address, String title
});




}
/// @nodoc
class _$OpenedPullRequestValueObjectCopyWithImpl<$Res>
    implements $OpenedPullRequestValueObjectCopyWith<$Res> {
  _$OpenedPullRequestValueObjectCopyWithImpl(this._self, this._then);

  final OpenedPullRequestValueObject _self;
  final $Res Function(OpenedPullRequestValueObject) _then;

/// Create a copy of OpenedPullRequestValueObject
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? number = null,Object? address = null,Object? title = null,}) {
  return _then(_self.copyWith(
number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as Uri,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [OpenedPullRequestValueObject].
extension OpenedPullRequestValueObjectPatterns on OpenedPullRequestValueObject {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OpenedPullRequestValueObject value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OpenedPullRequestValueObject() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OpenedPullRequestValueObject value)  $default,){
final _that = this;
switch (_that) {
case _OpenedPullRequestValueObject():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OpenedPullRequestValueObject value)?  $default,){
final _that = this;
switch (_that) {
case _OpenedPullRequestValueObject() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int number,  Uri address,  String title)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OpenedPullRequestValueObject() when $default != null:
return $default(_that.number,_that.address,_that.title);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int number,  Uri address,  String title)  $default,) {final _that = this;
switch (_that) {
case _OpenedPullRequestValueObject():
return $default(_that.number,_that.address,_that.title);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int number,  Uri address,  String title)?  $default,) {final _that = this;
switch (_that) {
case _OpenedPullRequestValueObject() when $default != null:
return $default(_that.number,_that.address,_that.title);case _:
  return null;

}
}

}

/// @nodoc


class _OpenedPullRequestValueObject implements OpenedPullRequestValueObject {
  const _OpenedPullRequestValueObject({required this.number, required this.address, required this.title});
  

/// `#123`, without the `#`.
@override final  int number;
/// Its page on the host.
@override final  Uri address;
/// Its title on the host, which may have moved on from the draft's.
@override final  String title;

/// Create a copy of OpenedPullRequestValueObject
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OpenedPullRequestValueObjectCopyWith<_OpenedPullRequestValueObject> get copyWith => __$OpenedPullRequestValueObjectCopyWithImpl<_OpenedPullRequestValueObject>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OpenedPullRequestValueObject&&(identical(other.number, number) || other.number == number)&&(identical(other.address, address) || other.address == address)&&(identical(other.title, title) || other.title == title));
}


@override
int get hashCode => Object.hash(runtimeType,number,address,title);

@override
String toString() {
  return 'OpenedPullRequestValueObject(number: $number, address: $address, title: $title)';
}


}

/// @nodoc
abstract mixin class _$OpenedPullRequestValueObjectCopyWith<$Res> implements $OpenedPullRequestValueObjectCopyWith<$Res> {
  factory _$OpenedPullRequestValueObjectCopyWith(_OpenedPullRequestValueObject value, $Res Function(_OpenedPullRequestValueObject) _then) = __$OpenedPullRequestValueObjectCopyWithImpl;
@override @useResult
$Res call({
 int number, Uri address, String title
});




}
/// @nodoc
class __$OpenedPullRequestValueObjectCopyWithImpl<$Res>
    implements _$OpenedPullRequestValueObjectCopyWith<$Res> {
  __$OpenedPullRequestValueObjectCopyWithImpl(this._self, this._then);

  final _OpenedPullRequestValueObject _self;
  final $Res Function(_OpenedPullRequestValueObject) _then;

/// Create a copy of OpenedPullRequestValueObject
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? number = null,Object? address = null,Object? title = null,}) {
  return _then(_OpenedPullRequestValueObject(
number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as Uri,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
