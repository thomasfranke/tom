// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'merge_state_value_object.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MergeStateValueObject {

/// Whether `MERGE_HEAD` is there.
 bool get inProgress;/// The message git prepared, empty when there is no merge.
///
/// Concluding the merge starts from this rather than from a blank box,
/// because git already wrote the sentence a terminal would have opened
/// an editor on.
 String get message;
/// Create a copy of MergeStateValueObject
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MergeStateValueObjectCopyWith<MergeStateValueObject> get copyWith => _$MergeStateValueObjectCopyWithImpl<MergeStateValueObject>(this as MergeStateValueObject, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MergeStateValueObject&&(identical(other.inProgress, inProgress) || other.inProgress == inProgress)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,inProgress,message);

@override
String toString() {
  return 'MergeStateValueObject(inProgress: $inProgress, message: $message)';
}


}

/// @nodoc
abstract mixin class $MergeStateValueObjectCopyWith<$Res>  {
  factory $MergeStateValueObjectCopyWith(MergeStateValueObject value, $Res Function(MergeStateValueObject) _then) = _$MergeStateValueObjectCopyWithImpl;
@useResult
$Res call({
 bool inProgress, String message
});




}
/// @nodoc
class _$MergeStateValueObjectCopyWithImpl<$Res>
    implements $MergeStateValueObjectCopyWith<$Res> {
  _$MergeStateValueObjectCopyWithImpl(this._self, this._then);

  final MergeStateValueObject _self;
  final $Res Function(MergeStateValueObject) _then;

/// Create a copy of MergeStateValueObject
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? inProgress = null,Object? message = null,}) {
  return _then(_self.copyWith(
inProgress: null == inProgress ? _self.inProgress : inProgress // ignore: cast_nullable_to_non_nullable
as bool,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MergeStateValueObject].
extension MergeStateValueObjectPatterns on MergeStateValueObject {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MergeStateValueObject value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MergeStateValueObject() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MergeStateValueObject value)  $default,){
final _that = this;
switch (_that) {
case _MergeStateValueObject():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MergeStateValueObject value)?  $default,){
final _that = this;
switch (_that) {
case _MergeStateValueObject() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool inProgress,  String message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MergeStateValueObject() when $default != null:
return $default(_that.inProgress,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool inProgress,  String message)  $default,) {final _that = this;
switch (_that) {
case _MergeStateValueObject():
return $default(_that.inProgress,_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool inProgress,  String message)?  $default,) {final _that = this;
switch (_that) {
case _MergeStateValueObject() when $default != null:
return $default(_that.inProgress,_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _MergeStateValueObject extends MergeStateValueObject {
  const _MergeStateValueObject({required this.inProgress, required this.message}): super._();
  

/// Whether `MERGE_HEAD` is there.
@override final  bool inProgress;
/// The message git prepared, empty when there is no merge.
///
/// Concluding the merge starts from this rather than from a blank box,
/// because git already wrote the sentence a terminal would have opened
/// an editor on.
@override final  String message;

/// Create a copy of MergeStateValueObject
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MergeStateValueObjectCopyWith<_MergeStateValueObject> get copyWith => __$MergeStateValueObjectCopyWithImpl<_MergeStateValueObject>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MergeStateValueObject&&(identical(other.inProgress, inProgress) || other.inProgress == inProgress)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,inProgress,message);

@override
String toString() {
  return 'MergeStateValueObject(inProgress: $inProgress, message: $message)';
}


}

/// @nodoc
abstract mixin class _$MergeStateValueObjectCopyWith<$Res> implements $MergeStateValueObjectCopyWith<$Res> {
  factory _$MergeStateValueObjectCopyWith(_MergeStateValueObject value, $Res Function(_MergeStateValueObject) _then) = __$MergeStateValueObjectCopyWithImpl;
@override @useResult
$Res call({
 bool inProgress, String message
});




}
/// @nodoc
class __$MergeStateValueObjectCopyWithImpl<$Res>
    implements _$MergeStateValueObjectCopyWith<$Res> {
  __$MergeStateValueObjectCopyWithImpl(this._self, this._then);

  final _MergeStateValueObject _self;
  final $Res Function(_MergeStateValueObject) _then;

/// Create a copy of MergeStateValueObject
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? inProgress = null,Object? message = null,}) {
  return _then(_MergeStateValueObject(
inProgress: null == inProgress ? _self.inProgress : inProgress // ignore: cast_nullable_to_non_nullable
as bool,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
