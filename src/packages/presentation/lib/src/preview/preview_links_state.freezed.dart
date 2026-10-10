// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'preview_links_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PreviewLinksState {

/// Every distinct link of the document, with what it points at.
 Map<WikilinkValueObject, WikilinkTargetValueObject> get targets;
/// Create a copy of PreviewLinksState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PreviewLinksStateCopyWith<PreviewLinksState> get copyWith => _$PreviewLinksStateCopyWithImpl<PreviewLinksState>(this as PreviewLinksState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PreviewLinksState&&const DeepCollectionEquality().equals(other.targets, targets));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(targets));

@override
String toString() {
  return 'PreviewLinksState(targets: $targets)';
}


}

/// @nodoc
abstract mixin class $PreviewLinksStateCopyWith<$Res>  {
  factory $PreviewLinksStateCopyWith(PreviewLinksState value, $Res Function(PreviewLinksState) _then) = _$PreviewLinksStateCopyWithImpl;
@useResult
$Res call({
 Map<WikilinkValueObject, WikilinkTargetValueObject> targets
});




}
/// @nodoc
class _$PreviewLinksStateCopyWithImpl<$Res>
    implements $PreviewLinksStateCopyWith<$Res> {
  _$PreviewLinksStateCopyWithImpl(this._self, this._then);

  final PreviewLinksState _self;
  final $Res Function(PreviewLinksState) _then;

/// Create a copy of PreviewLinksState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? targets = null,}) {
  return _then(_self.copyWith(
targets: null == targets ? _self.targets : targets // ignore: cast_nullable_to_non_nullable
as Map<WikilinkValueObject, WikilinkTargetValueObject>,
  ));
}

}


/// Adds pattern-matching-related methods to [PreviewLinksState].
extension PreviewLinksStatePatterns on PreviewLinksState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PreviewLinksState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PreviewLinksState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PreviewLinksState value)  $default,){
final _that = this;
switch (_that) {
case _PreviewLinksState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PreviewLinksState value)?  $default,){
final _that = this;
switch (_that) {
case _PreviewLinksState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<WikilinkValueObject, WikilinkTargetValueObject> targets)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PreviewLinksState() when $default != null:
return $default(_that.targets);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<WikilinkValueObject, WikilinkTargetValueObject> targets)  $default,) {final _that = this;
switch (_that) {
case _PreviewLinksState():
return $default(_that.targets);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<WikilinkValueObject, WikilinkTargetValueObject> targets)?  $default,) {final _that = this;
switch (_that) {
case _PreviewLinksState() when $default != null:
return $default(_that.targets);case _:
  return null;

}
}

}

/// @nodoc


class _PreviewLinksState extends PreviewLinksState {
  const _PreviewLinksState({final  Map<WikilinkValueObject, WikilinkTargetValueObject> targets = const <WikilinkValueObject, WikilinkTargetValueObject>{}}): _targets = targets,super._();
  

/// Every distinct link of the document, with what it points at.
 final  Map<WikilinkValueObject, WikilinkTargetValueObject> _targets;
/// Every distinct link of the document, with what it points at.
@override@JsonKey() Map<WikilinkValueObject, WikilinkTargetValueObject> get targets {
  if (_targets is EqualUnmodifiableMapView) return _targets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_targets);
}


/// Create a copy of PreviewLinksState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PreviewLinksStateCopyWith<_PreviewLinksState> get copyWith => __$PreviewLinksStateCopyWithImpl<_PreviewLinksState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PreviewLinksState&&const DeepCollectionEquality().equals(other._targets, _targets));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_targets));

@override
String toString() {
  return 'PreviewLinksState(targets: $targets)';
}


}

/// @nodoc
abstract mixin class _$PreviewLinksStateCopyWith<$Res> implements $PreviewLinksStateCopyWith<$Res> {
  factory _$PreviewLinksStateCopyWith(_PreviewLinksState value, $Res Function(_PreviewLinksState) _then) = __$PreviewLinksStateCopyWithImpl;
@override @useResult
$Res call({
 Map<WikilinkValueObject, WikilinkTargetValueObject> targets
});




}
/// @nodoc
class __$PreviewLinksStateCopyWithImpl<$Res>
    implements _$PreviewLinksStateCopyWith<$Res> {
  __$PreviewLinksStateCopyWithImpl(this._self, this._then);

  final _PreviewLinksState _self;
  final $Res Function(_PreviewLinksState) _then;

/// Create a copy of PreviewLinksState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? targets = null,}) {
  return _then(_PreviewLinksState(
targets: null == targets ? _self._targets : targets // ignore: cast_nullable_to_non_nullable
as Map<WikilinkValueObject, WikilinkTargetValueObject>,
  ));
}


}

// dart format on
