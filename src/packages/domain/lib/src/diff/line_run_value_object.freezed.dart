// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'line_run_value_object.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LineRunValueObject {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LineRunValueObject);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'LineRunValueObject()';
}


}

/// @nodoc
class $LineRunValueObjectCopyWith<$Res>  {
$LineRunValueObjectCopyWith(LineRunValueObject _, $Res Function(LineRunValueObject) __);
}


/// Adds pattern-matching-related methods to [LineRunValueObject].
extension LineRunValueObjectPatterns on LineRunValueObject {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( LineRunAdded value)?  added,TResult Function( LineRunModified value)?  modified,TResult Function( LineRunRemoved value)?  removed,required TResult orElse(),}){
final _that = this;
switch (_that) {
case LineRunAdded() when added != null:
return added(_that);case LineRunModified() when modified != null:
return modified(_that);case LineRunRemoved() when removed != null:
return removed(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( LineRunAdded value)  added,required TResult Function( LineRunModified value)  modified,required TResult Function( LineRunRemoved value)  removed,}){
final _that = this;
switch (_that) {
case LineRunAdded():
return added(_that);case LineRunModified():
return modified(_that);case LineRunRemoved():
return removed(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( LineRunAdded value)?  added,TResult? Function( LineRunModified value)?  modified,TResult? Function( LineRunRemoved value)?  removed,}){
final _that = this;
switch (_that) {
case LineRunAdded() when added != null:
return added(_that);case LineRunModified() when modified != null:
return modified(_that);case LineRunRemoved() when removed != null:
return removed(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( int from,  int to)?  added,TResult Function( int from,  int to)?  modified,TResult Function( int at,  int count)?  removed,required TResult orElse(),}) {final _that = this;
switch (_that) {
case LineRunAdded() when added != null:
return added(_that.from,_that.to);case LineRunModified() when modified != null:
return modified(_that.from,_that.to);case LineRunRemoved() when removed != null:
return removed(_that.at,_that.count);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( int from,  int to)  added,required TResult Function( int from,  int to)  modified,required TResult Function( int at,  int count)  removed,}) {final _that = this;
switch (_that) {
case LineRunAdded():
return added(_that.from,_that.to);case LineRunModified():
return modified(_that.from,_that.to);case LineRunRemoved():
return removed(_that.at,_that.count);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( int from,  int to)?  added,TResult? Function( int from,  int to)?  modified,TResult? Function( int at,  int count)?  removed,}) {final _that = this;
switch (_that) {
case LineRunAdded() when added != null:
return added(_that.from,_that.to);case LineRunModified() when modified != null:
return modified(_that.from,_that.to);case LineRunRemoved() when removed != null:
return removed(_that.at,_that.count);case _:
  return null;

}
}

}

/// @nodoc


class LineRunAdded implements LineRunValueObject {
  const LineRunAdded({required this.from, required this.to});
  

 final  int from;
 final  int to;

/// Create a copy of LineRunValueObject
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LineRunAddedCopyWith<LineRunAdded> get copyWith => _$LineRunAddedCopyWithImpl<LineRunAdded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LineRunAdded&&(identical(other.from, from) || other.from == from)&&(identical(other.to, to) || other.to == to));
}


@override
int get hashCode => Object.hash(runtimeType,from,to);

@override
String toString() {
  return 'LineRunValueObject.added(from: $from, to: $to)';
}


}

/// @nodoc
abstract mixin class $LineRunAddedCopyWith<$Res> implements $LineRunValueObjectCopyWith<$Res> {
  factory $LineRunAddedCopyWith(LineRunAdded value, $Res Function(LineRunAdded) _then) = _$LineRunAddedCopyWithImpl;
@useResult
$Res call({
 int from, int to
});




}
/// @nodoc
class _$LineRunAddedCopyWithImpl<$Res>
    implements $LineRunAddedCopyWith<$Res> {
  _$LineRunAddedCopyWithImpl(this._self, this._then);

  final LineRunAdded _self;
  final $Res Function(LineRunAdded) _then;

/// Create a copy of LineRunValueObject
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? from = null,Object? to = null,}) {
  return _then(LineRunAdded(
from: null == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as int,to: null == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class LineRunModified implements LineRunValueObject {
  const LineRunModified({required this.from, required this.to});
  

 final  int from;
 final  int to;

/// Create a copy of LineRunValueObject
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LineRunModifiedCopyWith<LineRunModified> get copyWith => _$LineRunModifiedCopyWithImpl<LineRunModified>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LineRunModified&&(identical(other.from, from) || other.from == from)&&(identical(other.to, to) || other.to == to));
}


@override
int get hashCode => Object.hash(runtimeType,from,to);

@override
String toString() {
  return 'LineRunValueObject.modified(from: $from, to: $to)';
}


}

/// @nodoc
abstract mixin class $LineRunModifiedCopyWith<$Res> implements $LineRunValueObjectCopyWith<$Res> {
  factory $LineRunModifiedCopyWith(LineRunModified value, $Res Function(LineRunModified) _then) = _$LineRunModifiedCopyWithImpl;
@useResult
$Res call({
 int from, int to
});




}
/// @nodoc
class _$LineRunModifiedCopyWithImpl<$Res>
    implements $LineRunModifiedCopyWith<$Res> {
  _$LineRunModifiedCopyWithImpl(this._self, this._then);

  final LineRunModified _self;
  final $Res Function(LineRunModified) _then;

/// Create a copy of LineRunValueObject
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? from = null,Object? to = null,}) {
  return _then(LineRunModified(
from: null == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as int,to: null == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class LineRunRemoved implements LineRunValueObject {
  const LineRunRemoved({required this.at, required this.count});
  

 final  int at;
 final  int count;

/// Create a copy of LineRunValueObject
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LineRunRemovedCopyWith<LineRunRemoved> get copyWith => _$LineRunRemovedCopyWithImpl<LineRunRemoved>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LineRunRemoved&&(identical(other.at, at) || other.at == at)&&(identical(other.count, count) || other.count == count));
}


@override
int get hashCode => Object.hash(runtimeType,at,count);

@override
String toString() {
  return 'LineRunValueObject.removed(at: $at, count: $count)';
}


}

/// @nodoc
abstract mixin class $LineRunRemovedCopyWith<$Res> implements $LineRunValueObjectCopyWith<$Res> {
  factory $LineRunRemovedCopyWith(LineRunRemoved value, $Res Function(LineRunRemoved) _then) = _$LineRunRemovedCopyWithImpl;
@useResult
$Res call({
 int at, int count
});




}
/// @nodoc
class _$LineRunRemovedCopyWithImpl<$Res>
    implements $LineRunRemovedCopyWith<$Res> {
  _$LineRunRemovedCopyWithImpl(this._self, this._then);

  final LineRunRemoved _self;
  final $Res Function(LineRunRemoved) _then;

/// Create a copy of LineRunValueObject
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? at = null,Object? count = null,}) {
  return _then(LineRunRemoved(
at: null == at ? _self.at : at // ignore: cast_nullable_to_non_nullable
as int,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
