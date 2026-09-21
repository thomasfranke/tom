// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'space_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SpaceSessionState {

/// The folder the user opened, and the repository that encloses it.
 Space get space;/// The document the editor and the preview are showing, or null when
/// none has been chosen.
///
/// Null is the state a space opens in, not an error. It is a
/// [SpaceRelativePath] because that is what the app navigates in — git's
/// spelling is [Space.toRepoRelative]'s to produce, and nobody else's.
 SpaceRelativePath? get openDocument;
/// Create a copy of SpaceSessionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SpaceSessionStateCopyWith<SpaceSessionState> get copyWith => _$SpaceSessionStateCopyWithImpl<SpaceSessionState>(this as SpaceSessionState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SpaceSessionState&&(identical(other.space, space) || other.space == space)&&(identical(other.openDocument, openDocument) || other.openDocument == openDocument));
}


@override
int get hashCode => Object.hash(runtimeType,space,openDocument);

@override
String toString() {
  return 'SpaceSessionState(space: $space, openDocument: $openDocument)';
}


}

/// @nodoc
abstract mixin class $SpaceSessionStateCopyWith<$Res>  {
  factory $SpaceSessionStateCopyWith(SpaceSessionState value, $Res Function(SpaceSessionState) _then) = _$SpaceSessionStateCopyWithImpl;
@useResult
$Res call({
 Space space, SpaceRelativePath? openDocument
});


$SpaceCopyWith<$Res> get space;

}
/// @nodoc
class _$SpaceSessionStateCopyWithImpl<$Res>
    implements $SpaceSessionStateCopyWith<$Res> {
  _$SpaceSessionStateCopyWithImpl(this._self, this._then);

  final SpaceSessionState _self;
  final $Res Function(SpaceSessionState) _then;

/// Create a copy of SpaceSessionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? space = null,Object? openDocument = freezed,}) {
  return _then(_self.copyWith(
space: null == space ? _self.space : space // ignore: cast_nullable_to_non_nullable
as Space,openDocument: freezed == openDocument ? _self.openDocument : openDocument // ignore: cast_nullable_to_non_nullable
as SpaceRelativePath?,
  ));
}
/// Create a copy of SpaceSessionState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SpaceCopyWith<$Res> get space {
  
  return $SpaceCopyWith<$Res>(_self.space, (value) {
    return _then(_self.copyWith(space: value));
  });
}
}


/// Adds pattern-matching-related methods to [SpaceSessionState].
extension SpaceSessionStatePatterns on SpaceSessionState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SpaceSessionState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SpaceSessionState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SpaceSessionState value)  $default,){
final _that = this;
switch (_that) {
case _SpaceSessionState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SpaceSessionState value)?  $default,){
final _that = this;
switch (_that) {
case _SpaceSessionState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Space space,  SpaceRelativePath? openDocument)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SpaceSessionState() when $default != null:
return $default(_that.space,_that.openDocument);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Space space,  SpaceRelativePath? openDocument)  $default,) {final _that = this;
switch (_that) {
case _SpaceSessionState():
return $default(_that.space,_that.openDocument);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Space space,  SpaceRelativePath? openDocument)?  $default,) {final _that = this;
switch (_that) {
case _SpaceSessionState() when $default != null:
return $default(_that.space,_that.openDocument);case _:
  return null;

}
}

}

/// @nodoc


class _SpaceSessionState implements SpaceSessionState {
  const _SpaceSessionState({required this.space, this.openDocument});
  

/// The folder the user opened, and the repository that encloses it.
@override final  Space space;
/// The document the editor and the preview are showing, or null when
/// none has been chosen.
///
/// Null is the state a space opens in, not an error. It is a
/// [SpaceRelativePath] because that is what the app navigates in — git's
/// spelling is [Space.toRepoRelative]'s to produce, and nobody else's.
@override final  SpaceRelativePath? openDocument;

/// Create a copy of SpaceSessionState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SpaceSessionStateCopyWith<_SpaceSessionState> get copyWith => __$SpaceSessionStateCopyWithImpl<_SpaceSessionState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SpaceSessionState&&(identical(other.space, space) || other.space == space)&&(identical(other.openDocument, openDocument) || other.openDocument == openDocument));
}


@override
int get hashCode => Object.hash(runtimeType,space,openDocument);

@override
String toString() {
  return 'SpaceSessionState(space: $space, openDocument: $openDocument)';
}


}

/// @nodoc
abstract mixin class _$SpaceSessionStateCopyWith<$Res> implements $SpaceSessionStateCopyWith<$Res> {
  factory _$SpaceSessionStateCopyWith(_SpaceSessionState value, $Res Function(_SpaceSessionState) _then) = __$SpaceSessionStateCopyWithImpl;
@override @useResult
$Res call({
 Space space, SpaceRelativePath? openDocument
});


@override $SpaceCopyWith<$Res> get space;

}
/// @nodoc
class __$SpaceSessionStateCopyWithImpl<$Res>
    implements _$SpaceSessionStateCopyWith<$Res> {
  __$SpaceSessionStateCopyWithImpl(this._self, this._then);

  final _SpaceSessionState _self;
  final $Res Function(_SpaceSessionState) _then;

/// Create a copy of SpaceSessionState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? space = null,Object? openDocument = freezed,}) {
  return _then(_SpaceSessionState(
space: null == space ? _self.space : space // ignore: cast_nullable_to_non_nullable
as Space,openDocument: freezed == openDocument ? _self.openDocument : openDocument // ignore: cast_nullable_to_non_nullable
as SpaceRelativePath?,
  ));
}

/// Create a copy of SpaceSessionState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SpaceCopyWith<$Res> get space {
  
  return $SpaceCopyWith<$Res>(_self.space, (value) {
    return _then(_self.copyWith(space: value));
  });
}
}

// dart format on
