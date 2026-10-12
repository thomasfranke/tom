// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'line_diff_value_object.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LineDiffValueObject {

/// Every stretch that changed, in reading order; unchanged lines are the
/// gaps between them. Handed over unmodifiable, never copied.
 List<LineRunValueObject> get runs;
/// Create a copy of LineDiffValueObject
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LineDiffValueObjectCopyWith<LineDiffValueObject> get copyWith => _$LineDiffValueObjectCopyWithImpl<LineDiffValueObject>(this as LineDiffValueObject, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LineDiffValueObject&&const DeepCollectionEquality().equals(other.runs, runs));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(runs));

@override
String toString() {
  return 'LineDiffValueObject(runs: $runs)';
}


}

/// @nodoc
abstract mixin class $LineDiffValueObjectCopyWith<$Res>  {
  factory $LineDiffValueObjectCopyWith(LineDiffValueObject value, $Res Function(LineDiffValueObject) _then) = _$LineDiffValueObjectCopyWithImpl;
@useResult
$Res call({
 List<LineRunValueObject> runs
});




}
/// @nodoc
class _$LineDiffValueObjectCopyWithImpl<$Res>
    implements $LineDiffValueObjectCopyWith<$Res> {
  _$LineDiffValueObjectCopyWithImpl(this._self, this._then);

  final LineDiffValueObject _self;
  final $Res Function(LineDiffValueObject) _then;

/// Create a copy of LineDiffValueObject
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? runs = null,}) {
  return _then(_self.copyWith(
runs: null == runs ? _self.runs : runs // ignore: cast_nullable_to_non_nullable
as List<LineRunValueObject>,
  ));
}

}


/// Adds pattern-matching-related methods to [LineDiffValueObject].
extension LineDiffValueObjectPatterns on LineDiffValueObject {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LineDiffValueObject value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LineDiffValueObject() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LineDiffValueObject value)  $default,){
final _that = this;
switch (_that) {
case _LineDiffValueObject():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LineDiffValueObject value)?  $default,){
final _that = this;
switch (_that) {
case _LineDiffValueObject() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<LineRunValueObject> runs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LineDiffValueObject() when $default != null:
return $default(_that.runs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<LineRunValueObject> runs)  $default,) {final _that = this;
switch (_that) {
case _LineDiffValueObject():
return $default(_that.runs);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<LineRunValueObject> runs)?  $default,) {final _that = this;
switch (_that) {
case _LineDiffValueObject() when $default != null:
return $default(_that.runs);case _:
  return null;

}
}

}

/// @nodoc


class _LineDiffValueObject extends LineDiffValueObject {
  const _LineDiffValueObject({required final  List<LineRunValueObject> runs}): _runs = runs,super._();
  

/// Every stretch that changed, in reading order; unchanged lines are the
/// gaps between them. Handed over unmodifiable, never copied.
 final  List<LineRunValueObject> _runs;
/// Every stretch that changed, in reading order; unchanged lines are the
/// gaps between them. Handed over unmodifiable, never copied.
@override List<LineRunValueObject> get runs {
  if (_runs is EqualUnmodifiableListView) return _runs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_runs);
}


/// Create a copy of LineDiffValueObject
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LineDiffValueObjectCopyWith<_LineDiffValueObject> get copyWith => __$LineDiffValueObjectCopyWithImpl<_LineDiffValueObject>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LineDiffValueObject&&const DeepCollectionEquality().equals(other._runs, _runs));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_runs));

@override
String toString() {
  return 'LineDiffValueObject(runs: $runs)';
}


}

/// @nodoc
abstract mixin class _$LineDiffValueObjectCopyWith<$Res> implements $LineDiffValueObjectCopyWith<$Res> {
  factory _$LineDiffValueObjectCopyWith(_LineDiffValueObject value, $Res Function(_LineDiffValueObject) _then) = __$LineDiffValueObjectCopyWithImpl;
@override @useResult
$Res call({
 List<LineRunValueObject> runs
});




}
/// @nodoc
class __$LineDiffValueObjectCopyWithImpl<$Res>
    implements _$LineDiffValueObjectCopyWith<$Res> {
  __$LineDiffValueObjectCopyWithImpl(this._self, this._then);

  final _LineDiffValueObject _self;
  final $Res Function(_LineDiffValueObject) _then;

/// Create a copy of LineDiffValueObject
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? runs = null,}) {
  return _then(_LineDiffValueObject(
runs: null == runs ? _self._runs : runs // ignore: cast_nullable_to_non_nullable
as List<LineRunValueObject>,
  ));
}


}

// dart format on
