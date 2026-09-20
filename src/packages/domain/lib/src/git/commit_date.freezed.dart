// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'commit_date.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CommitDate {

/// The instant, in UTC. Comparing two commits in time uses this.
 DateTime get utc;/// How far the author's clock stood from UTC, as git recorded it.
///
/// Zero is a real answer — the author was on UTC — not a missing one.
 Duration get offset;
/// Create a copy of CommitDate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommitDateCopyWith<CommitDate> get copyWith => _$CommitDateCopyWithImpl<CommitDate>(this as CommitDate, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommitDate&&(identical(other.utc, utc) || other.utc == utc)&&(identical(other.offset, offset) || other.offset == offset));
}


@override
int get hashCode => Object.hash(runtimeType,utc,offset);

@override
String toString() {
  return 'CommitDate(utc: $utc, offset: $offset)';
}


}

/// @nodoc
abstract mixin class $CommitDateCopyWith<$Res>  {
  factory $CommitDateCopyWith(CommitDate value, $Res Function(CommitDate) _then) = _$CommitDateCopyWithImpl;
@useResult
$Res call({
 DateTime utc, Duration offset
});




}
/// @nodoc
class _$CommitDateCopyWithImpl<$Res>
    implements $CommitDateCopyWith<$Res> {
  _$CommitDateCopyWithImpl(this._self, this._then);

  final CommitDate _self;
  final $Res Function(CommitDate) _then;

/// Create a copy of CommitDate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? utc = null,Object? offset = null,}) {
  return _then(_self.copyWith(
utc: null == utc ? _self.utc : utc // ignore: cast_nullable_to_non_nullable
as DateTime,offset: null == offset ? _self.offset : offset // ignore: cast_nullable_to_non_nullable
as Duration,
  ));
}

}


/// Adds pattern-matching-related methods to [CommitDate].
extension CommitDatePatterns on CommitDate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CommitDate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CommitDate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CommitDate value)  $default,){
final _that = this;
switch (_that) {
case _CommitDate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CommitDate value)?  $default,){
final _that = this;
switch (_that) {
case _CommitDate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime utc,  Duration offset)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CommitDate() when $default != null:
return $default(_that.utc,_that.offset);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime utc,  Duration offset)  $default,) {final _that = this;
switch (_that) {
case _CommitDate():
return $default(_that.utc,_that.offset);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime utc,  Duration offset)?  $default,) {final _that = this;
switch (_that) {
case _CommitDate() when $default != null:
return $default(_that.utc,_that.offset);case _:
  return null;

}
}

}

/// @nodoc


class _CommitDate extends CommitDate {
  const _CommitDate({required this.utc, required this.offset}): super._();
  

/// The instant, in UTC. Comparing two commits in time uses this.
@override final  DateTime utc;
/// How far the author's clock stood from UTC, as git recorded it.
///
/// Zero is a real answer — the author was on UTC — not a missing one.
@override final  Duration offset;

/// Create a copy of CommitDate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommitDateCopyWith<_CommitDate> get copyWith => __$CommitDateCopyWithImpl<_CommitDate>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommitDate&&(identical(other.utc, utc) || other.utc == utc)&&(identical(other.offset, offset) || other.offset == offset));
}


@override
int get hashCode => Object.hash(runtimeType,utc,offset);

@override
String toString() {
  return 'CommitDate(utc: $utc, offset: $offset)';
}


}

/// @nodoc
abstract mixin class _$CommitDateCopyWith<$Res> implements $CommitDateCopyWith<$Res> {
  factory _$CommitDateCopyWith(_CommitDate value, $Res Function(_CommitDate) _then) = __$CommitDateCopyWithImpl;
@override @useResult
$Res call({
 DateTime utc, Duration offset
});




}
/// @nodoc
class __$CommitDateCopyWithImpl<$Res>
    implements _$CommitDateCopyWith<$Res> {
  __$CommitDateCopyWithImpl(this._self, this._then);

  final _CommitDate _self;
  final $Res Function(_CommitDate) _then;

/// Create a copy of CommitDate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? utc = null,Object? offset = null,}) {
  return _then(_CommitDate(
utc: null == utc ? _self.utc : utc // ignore: cast_nullable_to_non_nullable
as DateTime,offset: null == offset ? _self.offset : offset // ignore: cast_nullable_to_non_nullable
as Duration,
  ));
}


}

// dart format on
