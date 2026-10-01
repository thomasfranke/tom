// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'conflict_region_value_object.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ConflictRegionValueObject {

/// Where `<<<<<<<` begins, as an offset into the whole text.
 int get start;/// Where the line after `>>>>>>>` begins, exclusive.
 int get end;/// What the side already on this branch reads, without its markers.
 String get current;/// What the side being merged in reads, without its markers.
 String get incoming;/// What `<<<<<<<` names — usually `HEAD`, kept because git does not
/// promise that and the label is the user's only clue which is which.
 String get currentLabel;/// What `>>>>>>>` names, normally the branch or commit being merged.
 String get incomingLabel;
/// Create a copy of ConflictRegionValueObject
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConflictRegionValueObjectCopyWith<ConflictRegionValueObject> get copyWith => _$ConflictRegionValueObjectCopyWithImpl<ConflictRegionValueObject>(this as ConflictRegionValueObject, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConflictRegionValueObject&&(identical(other.start, start) || other.start == start)&&(identical(other.end, end) || other.end == end)&&(identical(other.current, current) || other.current == current)&&(identical(other.incoming, incoming) || other.incoming == incoming)&&(identical(other.currentLabel, currentLabel) || other.currentLabel == currentLabel)&&(identical(other.incomingLabel, incomingLabel) || other.incomingLabel == incomingLabel));
}


@override
int get hashCode => Object.hash(runtimeType,start,end,current,incoming,currentLabel,incomingLabel);

@override
String toString() {
  return 'ConflictRegionValueObject(start: $start, end: $end, current: $current, incoming: $incoming, currentLabel: $currentLabel, incomingLabel: $incomingLabel)';
}


}

/// @nodoc
abstract mixin class $ConflictRegionValueObjectCopyWith<$Res>  {
  factory $ConflictRegionValueObjectCopyWith(ConflictRegionValueObject value, $Res Function(ConflictRegionValueObject) _then) = _$ConflictRegionValueObjectCopyWithImpl;
@useResult
$Res call({
 int start, int end, String current, String incoming, String currentLabel, String incomingLabel
});




}
/// @nodoc
class _$ConflictRegionValueObjectCopyWithImpl<$Res>
    implements $ConflictRegionValueObjectCopyWith<$Res> {
  _$ConflictRegionValueObjectCopyWithImpl(this._self, this._then);

  final ConflictRegionValueObject _self;
  final $Res Function(ConflictRegionValueObject) _then;

/// Create a copy of ConflictRegionValueObject
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? start = null,Object? end = null,Object? current = null,Object? incoming = null,Object? currentLabel = null,Object? incomingLabel = null,}) {
  return _then(_self.copyWith(
start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as int,end: null == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as int,current: null == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as String,incoming: null == incoming ? _self.incoming : incoming // ignore: cast_nullable_to_non_nullable
as String,currentLabel: null == currentLabel ? _self.currentLabel : currentLabel // ignore: cast_nullable_to_non_nullable
as String,incomingLabel: null == incomingLabel ? _self.incomingLabel : incomingLabel // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ConflictRegionValueObject].
extension ConflictRegionValueObjectPatterns on ConflictRegionValueObject {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConflictRegionValueObject value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConflictRegionValueObject() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConflictRegionValueObject value)  $default,){
final _that = this;
switch (_that) {
case _ConflictRegionValueObject():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConflictRegionValueObject value)?  $default,){
final _that = this;
switch (_that) {
case _ConflictRegionValueObject() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int start,  int end,  String current,  String incoming,  String currentLabel,  String incomingLabel)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConflictRegionValueObject() when $default != null:
return $default(_that.start,_that.end,_that.current,_that.incoming,_that.currentLabel,_that.incomingLabel);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int start,  int end,  String current,  String incoming,  String currentLabel,  String incomingLabel)  $default,) {final _that = this;
switch (_that) {
case _ConflictRegionValueObject():
return $default(_that.start,_that.end,_that.current,_that.incoming,_that.currentLabel,_that.incomingLabel);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int start,  int end,  String current,  String incoming,  String currentLabel,  String incomingLabel)?  $default,) {final _that = this;
switch (_that) {
case _ConflictRegionValueObject() when $default != null:
return $default(_that.start,_that.end,_that.current,_that.incoming,_that.currentLabel,_that.incomingLabel);case _:
  return null;

}
}

}

/// @nodoc


class _ConflictRegionValueObject extends ConflictRegionValueObject {
  const _ConflictRegionValueObject({required this.start, required this.end, required this.current, required this.incoming, required this.currentLabel, required this.incomingLabel}): super._();
  

/// Where `<<<<<<<` begins, as an offset into the whole text.
@override final  int start;
/// Where the line after `>>>>>>>` begins, exclusive.
@override final  int end;
/// What the side already on this branch reads, without its markers.
@override final  String current;
/// What the side being merged in reads, without its markers.
@override final  String incoming;
/// What `<<<<<<<` names — usually `HEAD`, kept because git does not
/// promise that and the label is the user's only clue which is which.
@override final  String currentLabel;
/// What `>>>>>>>` names, normally the branch or commit being merged.
@override final  String incomingLabel;

/// Create a copy of ConflictRegionValueObject
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConflictRegionValueObjectCopyWith<_ConflictRegionValueObject> get copyWith => __$ConflictRegionValueObjectCopyWithImpl<_ConflictRegionValueObject>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConflictRegionValueObject&&(identical(other.start, start) || other.start == start)&&(identical(other.end, end) || other.end == end)&&(identical(other.current, current) || other.current == current)&&(identical(other.incoming, incoming) || other.incoming == incoming)&&(identical(other.currentLabel, currentLabel) || other.currentLabel == currentLabel)&&(identical(other.incomingLabel, incomingLabel) || other.incomingLabel == incomingLabel));
}


@override
int get hashCode => Object.hash(runtimeType,start,end,current,incoming,currentLabel,incomingLabel);

@override
String toString() {
  return 'ConflictRegionValueObject(start: $start, end: $end, current: $current, incoming: $incoming, currentLabel: $currentLabel, incomingLabel: $incomingLabel)';
}


}

/// @nodoc
abstract mixin class _$ConflictRegionValueObjectCopyWith<$Res> implements $ConflictRegionValueObjectCopyWith<$Res> {
  factory _$ConflictRegionValueObjectCopyWith(_ConflictRegionValueObject value, $Res Function(_ConflictRegionValueObject) _then) = __$ConflictRegionValueObjectCopyWithImpl;
@override @useResult
$Res call({
 int start, int end, String current, String incoming, String currentLabel, String incomingLabel
});




}
/// @nodoc
class __$ConflictRegionValueObjectCopyWithImpl<$Res>
    implements _$ConflictRegionValueObjectCopyWith<$Res> {
  __$ConflictRegionValueObjectCopyWithImpl(this._self, this._then);

  final _ConflictRegionValueObject _self;
  final $Res Function(_ConflictRegionValueObject) _then;

/// Create a copy of ConflictRegionValueObject
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? start = null,Object? end = null,Object? current = null,Object? incoming = null,Object? currentLabel = null,Object? incomingLabel = null,}) {
  return _then(_ConflictRegionValueObject(
start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as int,end: null == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as int,current: null == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as String,incoming: null == incoming ? _self.incoming : incoming // ignore: cast_nullable_to_non_nullable
as String,currentLabel: null == currentLabel ? _self.currentLabel : currentLabel // ignore: cast_nullable_to_non_nullable
as String,incomingLabel: null == incomingLabel ? _self.incomingLabel : incomingLabel // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
