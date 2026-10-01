// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'space_departure.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SpaceDeparture {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SpaceDeparture);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SpaceDeparture()';
}


}

/// @nodoc
class $SpaceDepartureCopyWith<$Res>  {
$SpaceDepartureCopyWith(SpaceDeparture _, $Res Function(SpaceDeparture) __);
}


/// Adds pattern-matching-related methods to [SpaceDeparture].
extension SpaceDeparturePatterns on SpaceDeparture {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( SpaceDepartureClosing value)?  closing,TResult Function( SpaceDepartureSwitching value)?  switching,required TResult orElse(),}){
final _that = this;
switch (_that) {
case SpaceDepartureClosing() when closing != null:
return closing(_that);case SpaceDepartureSwitching() when switching != null:
return switching(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( SpaceDepartureClosing value)  closing,required TResult Function( SpaceDepartureSwitching value)  switching,}){
final _that = this;
switch (_that) {
case SpaceDepartureClosing():
return closing(_that);case SpaceDepartureSwitching():
return switching(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( SpaceDepartureClosing value)?  closing,TResult? Function( SpaceDepartureSwitching value)?  switching,}){
final _that = this;
switch (_that) {
case SpaceDepartureClosing() when closing != null:
return closing(_that);case SpaceDepartureSwitching() when switching != null:
return switching(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  closing,TResult Function( RecentSpaceEntity space)?  switching,required TResult orElse(),}) {final _that = this;
switch (_that) {
case SpaceDepartureClosing() when closing != null:
return closing();case SpaceDepartureSwitching() when switching != null:
return switching(_that.space);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  closing,required TResult Function( RecentSpaceEntity space)  switching,}) {final _that = this;
switch (_that) {
case SpaceDepartureClosing():
return closing();case SpaceDepartureSwitching():
return switching(_that.space);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  closing,TResult? Function( RecentSpaceEntity space)?  switching,}) {final _that = this;
switch (_that) {
case SpaceDepartureClosing() when closing != null:
return closing();case SpaceDepartureSwitching() when switching != null:
return switching(_that.space);case _:
  return null;

}
}

}

/// @nodoc


class SpaceDepartureClosing implements SpaceDeparture {
  const SpaceDepartureClosing();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SpaceDepartureClosing);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SpaceDeparture.closing()';
}


}




/// @nodoc


class SpaceDepartureSwitching implements SpaceDeparture {
  const SpaceDepartureSwitching(this.space);
  

 final  RecentSpaceEntity space;

/// Create a copy of SpaceDeparture
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SpaceDepartureSwitchingCopyWith<SpaceDepartureSwitching> get copyWith => _$SpaceDepartureSwitchingCopyWithImpl<SpaceDepartureSwitching>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SpaceDepartureSwitching&&(identical(other.space, space) || other.space == space));
}


@override
int get hashCode => Object.hash(runtimeType,space);

@override
String toString() {
  return 'SpaceDeparture.switching(space: $space)';
}


}

/// @nodoc
abstract mixin class $SpaceDepartureSwitchingCopyWith<$Res> implements $SpaceDepartureCopyWith<$Res> {
  factory $SpaceDepartureSwitchingCopyWith(SpaceDepartureSwitching value, $Res Function(SpaceDepartureSwitching) _then) = _$SpaceDepartureSwitchingCopyWithImpl;
@useResult
$Res call({
 RecentSpaceEntity space
});


$RecentSpaceEntityCopyWith<$Res> get space;

}
/// @nodoc
class _$SpaceDepartureSwitchingCopyWithImpl<$Res>
    implements $SpaceDepartureSwitchingCopyWith<$Res> {
  _$SpaceDepartureSwitchingCopyWithImpl(this._self, this._then);

  final SpaceDepartureSwitching _self;
  final $Res Function(SpaceDepartureSwitching) _then;

/// Create a copy of SpaceDeparture
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? space = null,}) {
  return _then(SpaceDepartureSwitching(
null == space ? _self.space : space // ignore: cast_nullable_to_non_nullable
as RecentSpaceEntity,
  ));
}

/// Create a copy of SpaceDeparture
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RecentSpaceEntityCopyWith<$Res> get space {
  
  return $RecentSpaceEntityCopyWith<$Res>(_self.space, (value) {
    return _then(_self.copyWith(space: value));
  });
}
}

// dart format on
