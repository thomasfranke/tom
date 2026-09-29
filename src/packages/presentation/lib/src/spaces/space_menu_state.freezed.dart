// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'space_menu_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SpaceMenuState {

/// The spaces to offer going back to, most recent first.
 List<RecentSpaceEntity> get recents;/// Whether the menu is on screen.
 bool get isShowing;/// What is waiting on the unsaved question, or null when nothing is.
 SpaceDeparture? get pending;/// Whether a space is being opened; the rows refuse a second click.
 bool get isBusy;/// Why the space that was chosen could not be opened.
///
/// Said in the menu rather than on a screen of its own: the space that
/// *is* open never closed, so there is nothing to go back from.
 String? get failure;
/// Create a copy of SpaceMenuState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SpaceMenuStateCopyWith<SpaceMenuState> get copyWith => _$SpaceMenuStateCopyWithImpl<SpaceMenuState>(this as SpaceMenuState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SpaceMenuState&&const DeepCollectionEquality().equals(other.recents, recents)&&(identical(other.isShowing, isShowing) || other.isShowing == isShowing)&&(identical(other.pending, pending) || other.pending == pending)&&(identical(other.isBusy, isBusy) || other.isBusy == isBusy)&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(recents),isShowing,pending,isBusy,failure);

@override
String toString() {
  return 'SpaceMenuState(recents: $recents, isShowing: $isShowing, pending: $pending, isBusy: $isBusy, failure: $failure)';
}


}

/// @nodoc
abstract mixin class $SpaceMenuStateCopyWith<$Res>  {
  factory $SpaceMenuStateCopyWith(SpaceMenuState value, $Res Function(SpaceMenuState) _then) = _$SpaceMenuStateCopyWithImpl;
@useResult
$Res call({
 List<RecentSpaceEntity> recents, bool isShowing, SpaceDeparture? pending, bool isBusy, String? failure
});


$SpaceDepartureCopyWith<$Res>? get pending;

}
/// @nodoc
class _$SpaceMenuStateCopyWithImpl<$Res>
    implements $SpaceMenuStateCopyWith<$Res> {
  _$SpaceMenuStateCopyWithImpl(this._self, this._then);

  final SpaceMenuState _self;
  final $Res Function(SpaceMenuState) _then;

/// Create a copy of SpaceMenuState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? recents = null,Object? isShowing = null,Object? pending = freezed,Object? isBusy = null,Object? failure = freezed,}) {
  return _then(_self.copyWith(
recents: null == recents ? _self.recents : recents // ignore: cast_nullable_to_non_nullable
as List<RecentSpaceEntity>,isShowing: null == isShowing ? _self.isShowing : isShowing // ignore: cast_nullable_to_non_nullable
as bool,pending: freezed == pending ? _self.pending : pending // ignore: cast_nullable_to_non_nullable
as SpaceDeparture?,isBusy: null == isBusy ? _self.isBusy : isBusy // ignore: cast_nullable_to_non_nullable
as bool,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of SpaceMenuState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SpaceDepartureCopyWith<$Res>? get pending {
    if (_self.pending == null) {
    return null;
  }

  return $SpaceDepartureCopyWith<$Res>(_self.pending!, (value) {
    return _then(_self.copyWith(pending: value));
  });
}
}


/// Adds pattern-matching-related methods to [SpaceMenuState].
extension SpaceMenuStatePatterns on SpaceMenuState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SpaceMenuState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SpaceMenuState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SpaceMenuState value)  $default,){
final _that = this;
switch (_that) {
case _SpaceMenuState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SpaceMenuState value)?  $default,){
final _that = this;
switch (_that) {
case _SpaceMenuState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<RecentSpaceEntity> recents,  bool isShowing,  SpaceDeparture? pending,  bool isBusy,  String? failure)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SpaceMenuState() when $default != null:
return $default(_that.recents,_that.isShowing,_that.pending,_that.isBusy,_that.failure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<RecentSpaceEntity> recents,  bool isShowing,  SpaceDeparture? pending,  bool isBusy,  String? failure)  $default,) {final _that = this;
switch (_that) {
case _SpaceMenuState():
return $default(_that.recents,_that.isShowing,_that.pending,_that.isBusy,_that.failure);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<RecentSpaceEntity> recents,  bool isShowing,  SpaceDeparture? pending,  bool isBusy,  String? failure)?  $default,) {final _that = this;
switch (_that) {
case _SpaceMenuState() when $default != null:
return $default(_that.recents,_that.isShowing,_that.pending,_that.isBusy,_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class _SpaceMenuState implements SpaceMenuState {
  const _SpaceMenuState({final  List<RecentSpaceEntity> recents = const <RecentSpaceEntity>[], this.isShowing = false, this.pending, this.isBusy = false, this.failure}): _recents = recents;
  

/// The spaces to offer going back to, most recent first.
 final  List<RecentSpaceEntity> _recents;
/// The spaces to offer going back to, most recent first.
@override@JsonKey() List<RecentSpaceEntity> get recents {
  if (_recents is EqualUnmodifiableListView) return _recents;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recents);
}

/// Whether the menu is on screen.
@override@JsonKey() final  bool isShowing;
/// What is waiting on the unsaved question, or null when nothing is.
@override final  SpaceDeparture? pending;
/// Whether a space is being opened; the rows refuse a second click.
@override@JsonKey() final  bool isBusy;
/// Why the space that was chosen could not be opened.
///
/// Said in the menu rather than on a screen of its own: the space that
/// *is* open never closed, so there is nothing to go back from.
@override final  String? failure;

/// Create a copy of SpaceMenuState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SpaceMenuStateCopyWith<_SpaceMenuState> get copyWith => __$SpaceMenuStateCopyWithImpl<_SpaceMenuState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SpaceMenuState&&const DeepCollectionEquality().equals(other._recents, _recents)&&(identical(other.isShowing, isShowing) || other.isShowing == isShowing)&&(identical(other.pending, pending) || other.pending == pending)&&(identical(other.isBusy, isBusy) || other.isBusy == isBusy)&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_recents),isShowing,pending,isBusy,failure);

@override
String toString() {
  return 'SpaceMenuState(recents: $recents, isShowing: $isShowing, pending: $pending, isBusy: $isBusy, failure: $failure)';
}


}

/// @nodoc
abstract mixin class _$SpaceMenuStateCopyWith<$Res> implements $SpaceMenuStateCopyWith<$Res> {
  factory _$SpaceMenuStateCopyWith(_SpaceMenuState value, $Res Function(_SpaceMenuState) _then) = __$SpaceMenuStateCopyWithImpl;
@override @useResult
$Res call({
 List<RecentSpaceEntity> recents, bool isShowing, SpaceDeparture? pending, bool isBusy, String? failure
});


@override $SpaceDepartureCopyWith<$Res>? get pending;

}
/// @nodoc
class __$SpaceMenuStateCopyWithImpl<$Res>
    implements _$SpaceMenuStateCopyWith<$Res> {
  __$SpaceMenuStateCopyWithImpl(this._self, this._then);

  final _SpaceMenuState _self;
  final $Res Function(_SpaceMenuState) _then;

/// Create a copy of SpaceMenuState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? recents = null,Object? isShowing = null,Object? pending = freezed,Object? isBusy = null,Object? failure = freezed,}) {
  return _then(_SpaceMenuState(
recents: null == recents ? _self._recents : recents // ignore: cast_nullable_to_non_nullable
as List<RecentSpaceEntity>,isShowing: null == isShowing ? _self.isShowing : isShowing // ignore: cast_nullable_to_non_nullable
as bool,pending: freezed == pending ? _self.pending : pending // ignore: cast_nullable_to_non_nullable
as SpaceDeparture?,isBusy: null == isBusy ? _self.isBusy : isBusy // ignore: cast_nullable_to_non_nullable
as bool,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of SpaceMenuState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SpaceDepartureCopyWith<$Res>? get pending {
    if (_self.pending == null) {
    return null;
  }

  return $SpaceDepartureCopyWith<$Res>(_self.pending!, (value) {
    return _then(_self.copyWith(pending: value));
  });
}
}

// dart format on
