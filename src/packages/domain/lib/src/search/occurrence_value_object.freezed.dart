// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'occurrence_value_object.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OccurrenceValueObject {

/// Where it begins, as an offset into the whole text.
 int get start;/// What the text reads there — the match as found, in its own case.
 String get matched;/// Which line it is on, zero-based, for showing it in context.
 int get line;/// The nearest heading at or above it, without its hashes; empty when
/// the match is above the document's first one.
 String get heading;/// The stretch of the line around the match, cut with `…` where it was
/// cut, and holding [matched] itself at [excerptStart].
 String get excerpt;/// Where [matched] begins inside [excerpt], so the surface can colour it
/// without searching the excerpt again — and without disagreeing with
/// what was found.
 int get excerptStart;
/// Create a copy of OccurrenceValueObject
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OccurrenceValueObjectCopyWith<OccurrenceValueObject> get copyWith => _$OccurrenceValueObjectCopyWithImpl<OccurrenceValueObject>(this as OccurrenceValueObject, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OccurrenceValueObject&&(identical(other.start, start) || other.start == start)&&(identical(other.matched, matched) || other.matched == matched)&&(identical(other.line, line) || other.line == line)&&(identical(other.heading, heading) || other.heading == heading)&&(identical(other.excerpt, excerpt) || other.excerpt == excerpt)&&(identical(other.excerptStart, excerptStart) || other.excerptStart == excerptStart));
}


@override
int get hashCode => Object.hash(runtimeType,start,matched,line,heading,excerpt,excerptStart);

@override
String toString() {
  return 'OccurrenceValueObject(start: $start, matched: $matched, line: $line, heading: $heading, excerpt: $excerpt, excerptStart: $excerptStart)';
}


}

/// @nodoc
abstract mixin class $OccurrenceValueObjectCopyWith<$Res>  {
  factory $OccurrenceValueObjectCopyWith(OccurrenceValueObject value, $Res Function(OccurrenceValueObject) _then) = _$OccurrenceValueObjectCopyWithImpl;
@useResult
$Res call({
 int start, String matched, int line, String heading, String excerpt, int excerptStart
});




}
/// @nodoc
class _$OccurrenceValueObjectCopyWithImpl<$Res>
    implements $OccurrenceValueObjectCopyWith<$Res> {
  _$OccurrenceValueObjectCopyWithImpl(this._self, this._then);

  final OccurrenceValueObject _self;
  final $Res Function(OccurrenceValueObject) _then;

/// Create a copy of OccurrenceValueObject
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? start = null,Object? matched = null,Object? line = null,Object? heading = null,Object? excerpt = null,Object? excerptStart = null,}) {
  return _then(_self.copyWith(
start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as int,matched: null == matched ? _self.matched : matched // ignore: cast_nullable_to_non_nullable
as String,line: null == line ? _self.line : line // ignore: cast_nullable_to_non_nullable
as int,heading: null == heading ? _self.heading : heading // ignore: cast_nullable_to_non_nullable
as String,excerpt: null == excerpt ? _self.excerpt : excerpt // ignore: cast_nullable_to_non_nullable
as String,excerptStart: null == excerptStart ? _self.excerptStart : excerptStart // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [OccurrenceValueObject].
extension OccurrenceValueObjectPatterns on OccurrenceValueObject {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OccurrenceValueObject value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OccurrenceValueObject() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OccurrenceValueObject value)  $default,){
final _that = this;
switch (_that) {
case _OccurrenceValueObject():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OccurrenceValueObject value)?  $default,){
final _that = this;
switch (_that) {
case _OccurrenceValueObject() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int start,  String matched,  int line,  String heading,  String excerpt,  int excerptStart)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OccurrenceValueObject() when $default != null:
return $default(_that.start,_that.matched,_that.line,_that.heading,_that.excerpt,_that.excerptStart);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int start,  String matched,  int line,  String heading,  String excerpt,  int excerptStart)  $default,) {final _that = this;
switch (_that) {
case _OccurrenceValueObject():
return $default(_that.start,_that.matched,_that.line,_that.heading,_that.excerpt,_that.excerptStart);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int start,  String matched,  int line,  String heading,  String excerpt,  int excerptStart)?  $default,) {final _that = this;
switch (_that) {
case _OccurrenceValueObject() when $default != null:
return $default(_that.start,_that.matched,_that.line,_that.heading,_that.excerpt,_that.excerptStart);case _:
  return null;

}
}

}

/// @nodoc


class _OccurrenceValueObject extends OccurrenceValueObject {
  const _OccurrenceValueObject({required this.start, required this.matched, required this.line, required this.heading, required this.excerpt, required this.excerptStart}): super._();
  

/// Where it begins, as an offset into the whole text.
@override final  int start;
/// What the text reads there — the match as found, in its own case.
@override final  String matched;
/// Which line it is on, zero-based, for showing it in context.
@override final  int line;
/// The nearest heading at or above it, without its hashes; empty when
/// the match is above the document's first one.
@override final  String heading;
/// The stretch of the line around the match, cut with `…` where it was
/// cut, and holding [matched] itself at [excerptStart].
@override final  String excerpt;
/// Where [matched] begins inside [excerpt], so the surface can colour it
/// without searching the excerpt again — and without disagreeing with
/// what was found.
@override final  int excerptStart;

/// Create a copy of OccurrenceValueObject
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OccurrenceValueObjectCopyWith<_OccurrenceValueObject> get copyWith => __$OccurrenceValueObjectCopyWithImpl<_OccurrenceValueObject>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OccurrenceValueObject&&(identical(other.start, start) || other.start == start)&&(identical(other.matched, matched) || other.matched == matched)&&(identical(other.line, line) || other.line == line)&&(identical(other.heading, heading) || other.heading == heading)&&(identical(other.excerpt, excerpt) || other.excerpt == excerpt)&&(identical(other.excerptStart, excerptStart) || other.excerptStart == excerptStart));
}


@override
int get hashCode => Object.hash(runtimeType,start,matched,line,heading,excerpt,excerptStart);

@override
String toString() {
  return 'OccurrenceValueObject(start: $start, matched: $matched, line: $line, heading: $heading, excerpt: $excerpt, excerptStart: $excerptStart)';
}


}

/// @nodoc
abstract mixin class _$OccurrenceValueObjectCopyWith<$Res> implements $OccurrenceValueObjectCopyWith<$Res> {
  factory _$OccurrenceValueObjectCopyWith(_OccurrenceValueObject value, $Res Function(_OccurrenceValueObject) _then) = __$OccurrenceValueObjectCopyWithImpl;
@override @useResult
$Res call({
 int start, String matched, int line, String heading, String excerpt, int excerptStart
});




}
/// @nodoc
class __$OccurrenceValueObjectCopyWithImpl<$Res>
    implements _$OccurrenceValueObjectCopyWith<$Res> {
  __$OccurrenceValueObjectCopyWithImpl(this._self, this._then);

  final _OccurrenceValueObject _self;
  final $Res Function(_OccurrenceValueObject) _then;

/// Create a copy of OccurrenceValueObject
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? start = null,Object? matched = null,Object? line = null,Object? heading = null,Object? excerpt = null,Object? excerptStart = null,}) {
  return _then(_OccurrenceValueObject(
start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as int,matched: null == matched ? _self.matched : matched // ignore: cast_nullable_to_non_nullable
as String,line: null == line ? _self.line : line // ignore: cast_nullable_to_non_nullable
as int,heading: null == heading ? _self.heading : heading // ignore: cast_nullable_to_non_nullable
as String,excerpt: null == excerpt ? _self.excerpt : excerpt // ignore: cast_nullable_to_non_nullable
as String,excerptStart: null == excerptStart ? _self.excerptStart : excerptStart // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
