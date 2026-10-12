// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'branch_standing_value_object.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BranchStandingValueObject {

/// The branch standing.
 BranchRefValueObject get branch;/// Commits [branch] has that `HEAD` has not.
 int get ahead;/// Commits `HEAD` has that [branch] has not.
 int get behind;/// Whether the two share any commit at all; a branch with an unrelated
/// history (`gh-pages`) is no base whatever its numbers say.
 bool get sharesHistory;
/// Create a copy of BranchStandingValueObject
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BranchStandingValueObjectCopyWith<BranchStandingValueObject> get copyWith => _$BranchStandingValueObjectCopyWithImpl<BranchStandingValueObject>(this as BranchStandingValueObject, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BranchStandingValueObject&&(identical(other.branch, branch) || other.branch == branch)&&(identical(other.ahead, ahead) || other.ahead == ahead)&&(identical(other.behind, behind) || other.behind == behind)&&(identical(other.sharesHistory, sharesHistory) || other.sharesHistory == sharesHistory));
}


@override
int get hashCode => Object.hash(runtimeType,branch,ahead,behind,sharesHistory);

@override
String toString() {
  return 'BranchStandingValueObject(branch: $branch, ahead: $ahead, behind: $behind, sharesHistory: $sharesHistory)';
}


}

/// @nodoc
abstract mixin class $BranchStandingValueObjectCopyWith<$Res>  {
  factory $BranchStandingValueObjectCopyWith(BranchStandingValueObject value, $Res Function(BranchStandingValueObject) _then) = _$BranchStandingValueObjectCopyWithImpl;
@useResult
$Res call({
 BranchRefValueObject branch, int ahead, int behind, bool sharesHistory
});


$BranchRefValueObjectCopyWith<$Res> get branch;

}
/// @nodoc
class _$BranchStandingValueObjectCopyWithImpl<$Res>
    implements $BranchStandingValueObjectCopyWith<$Res> {
  _$BranchStandingValueObjectCopyWithImpl(this._self, this._then);

  final BranchStandingValueObject _self;
  final $Res Function(BranchStandingValueObject) _then;

/// Create a copy of BranchStandingValueObject
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? branch = null,Object? ahead = null,Object? behind = null,Object? sharesHistory = null,}) {
  return _then(_self.copyWith(
branch: null == branch ? _self.branch : branch // ignore: cast_nullable_to_non_nullable
as BranchRefValueObject,ahead: null == ahead ? _self.ahead : ahead // ignore: cast_nullable_to_non_nullable
as int,behind: null == behind ? _self.behind : behind // ignore: cast_nullable_to_non_nullable
as int,sharesHistory: null == sharesHistory ? _self.sharesHistory : sharesHistory // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of BranchStandingValueObject
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BranchRefValueObjectCopyWith<$Res> get branch {
  
  return $BranchRefValueObjectCopyWith<$Res>(_self.branch, (value) {
    return _then(_self.copyWith(branch: value));
  });
}
}


/// Adds pattern-matching-related methods to [BranchStandingValueObject].
extension BranchStandingValueObjectPatterns on BranchStandingValueObject {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BranchStandingValueObject value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BranchStandingValueObject() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BranchStandingValueObject value)  $default,){
final _that = this;
switch (_that) {
case _BranchStandingValueObject():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BranchStandingValueObject value)?  $default,){
final _that = this;
switch (_that) {
case _BranchStandingValueObject() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( BranchRefValueObject branch,  int ahead,  int behind,  bool sharesHistory)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BranchStandingValueObject() when $default != null:
return $default(_that.branch,_that.ahead,_that.behind,_that.sharesHistory);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( BranchRefValueObject branch,  int ahead,  int behind,  bool sharesHistory)  $default,) {final _that = this;
switch (_that) {
case _BranchStandingValueObject():
return $default(_that.branch,_that.ahead,_that.behind,_that.sharesHistory);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( BranchRefValueObject branch,  int ahead,  int behind,  bool sharesHistory)?  $default,) {final _that = this;
switch (_that) {
case _BranchStandingValueObject() when $default != null:
return $default(_that.branch,_that.ahead,_that.behind,_that.sharesHistory);case _:
  return null;

}
}

}

/// @nodoc


class _BranchStandingValueObject implements BranchStandingValueObject {
  const _BranchStandingValueObject({required this.branch, required this.ahead, required this.behind, required this.sharesHistory});
  

/// The branch standing.
@override final  BranchRefValueObject branch;
/// Commits [branch] has that `HEAD` has not.
@override final  int ahead;
/// Commits `HEAD` has that [branch] has not.
@override final  int behind;
/// Whether the two share any commit at all; a branch with an unrelated
/// history (`gh-pages`) is no base whatever its numbers say.
@override final  bool sharesHistory;

/// Create a copy of BranchStandingValueObject
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BranchStandingValueObjectCopyWith<_BranchStandingValueObject> get copyWith => __$BranchStandingValueObjectCopyWithImpl<_BranchStandingValueObject>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BranchStandingValueObject&&(identical(other.branch, branch) || other.branch == branch)&&(identical(other.ahead, ahead) || other.ahead == ahead)&&(identical(other.behind, behind) || other.behind == behind)&&(identical(other.sharesHistory, sharesHistory) || other.sharesHistory == sharesHistory));
}


@override
int get hashCode => Object.hash(runtimeType,branch,ahead,behind,sharesHistory);

@override
String toString() {
  return 'BranchStandingValueObject(branch: $branch, ahead: $ahead, behind: $behind, sharesHistory: $sharesHistory)';
}


}

/// @nodoc
abstract mixin class _$BranchStandingValueObjectCopyWith<$Res> implements $BranchStandingValueObjectCopyWith<$Res> {
  factory _$BranchStandingValueObjectCopyWith(_BranchStandingValueObject value, $Res Function(_BranchStandingValueObject) _then) = __$BranchStandingValueObjectCopyWithImpl;
@override @useResult
$Res call({
 BranchRefValueObject branch, int ahead, int behind, bool sharesHistory
});


@override $BranchRefValueObjectCopyWith<$Res> get branch;

}
/// @nodoc
class __$BranchStandingValueObjectCopyWithImpl<$Res>
    implements _$BranchStandingValueObjectCopyWith<$Res> {
  __$BranchStandingValueObjectCopyWithImpl(this._self, this._then);

  final _BranchStandingValueObject _self;
  final $Res Function(_BranchStandingValueObject) _then;

/// Create a copy of BranchStandingValueObject
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? branch = null,Object? ahead = null,Object? behind = null,Object? sharesHistory = null,}) {
  return _then(_BranchStandingValueObject(
branch: null == branch ? _self.branch : branch // ignore: cast_nullable_to_non_nullable
as BranchRefValueObject,ahead: null == ahead ? _self.ahead : ahead // ignore: cast_nullable_to_non_nullable
as int,behind: null == behind ? _self.behind : behind // ignore: cast_nullable_to_non_nullable
as int,sharesHistory: null == sharesHistory ? _self.sharesHistory : sharesHistory // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of BranchStandingValueObject
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BranchRefValueObjectCopyWith<$Res> get branch {
  
  return $BranchRefValueObjectCopyWith<$Res>(_self.branch, (value) {
    return _then(_self.copyWith(branch: value));
  });
}
}

// dart format on
