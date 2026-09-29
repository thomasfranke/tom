// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wikilink_target_value_object.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WikilinkTargetValueObject {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WikilinkTargetValueObject);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'WikilinkTargetValueObject()';
}


}

/// @nodoc
class $WikilinkTargetValueObjectCopyWith<$Res>  {
$WikilinkTargetValueObjectCopyWith(WikilinkTargetValueObject _, $Res Function(WikilinkTargetValueObject) __);
}


/// Adds pattern-matching-related methods to [WikilinkTargetValueObject].
extension WikilinkTargetValueObjectPatterns on WikilinkTargetValueObject {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( WikilinkResolved value)?  resolved,TResult Function( WikilinkMissing value)?  missing,TResult Function( WikilinkAmbiguous value)?  ambiguous,required TResult orElse(),}){
final _that = this;
switch (_that) {
case WikilinkResolved() when resolved != null:
return resolved(_that);case WikilinkMissing() when missing != null:
return missing(_that);case WikilinkAmbiguous() when ambiguous != null:
return ambiguous(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( WikilinkResolved value)  resolved,required TResult Function( WikilinkMissing value)  missing,required TResult Function( WikilinkAmbiguous value)  ambiguous,}){
final _that = this;
switch (_that) {
case WikilinkResolved():
return resolved(_that);case WikilinkMissing():
return missing(_that);case WikilinkAmbiguous():
return ambiguous(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( WikilinkResolved value)?  resolved,TResult? Function( WikilinkMissing value)?  missing,TResult? Function( WikilinkAmbiguous value)?  ambiguous,}){
final _that = this;
switch (_that) {
case WikilinkResolved() when resolved != null:
return resolved(_that);case WikilinkMissing() when missing != null:
return missing(_that);case WikilinkAmbiguous() when ambiguous != null:
return ambiguous(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( SpaceRelativePathValueObject path)?  resolved,TResult Function()?  missing,TResult Function( List<SpaceRelativePathValueObject> candidates)?  ambiguous,required TResult orElse(),}) {final _that = this;
switch (_that) {
case WikilinkResolved() when resolved != null:
return resolved(_that.path);case WikilinkMissing() when missing != null:
return missing();case WikilinkAmbiguous() when ambiguous != null:
return ambiguous(_that.candidates);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( SpaceRelativePathValueObject path)  resolved,required TResult Function()  missing,required TResult Function( List<SpaceRelativePathValueObject> candidates)  ambiguous,}) {final _that = this;
switch (_that) {
case WikilinkResolved():
return resolved(_that.path);case WikilinkMissing():
return missing();case WikilinkAmbiguous():
return ambiguous(_that.candidates);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( SpaceRelativePathValueObject path)?  resolved,TResult? Function()?  missing,TResult? Function( List<SpaceRelativePathValueObject> candidates)?  ambiguous,}) {final _that = this;
switch (_that) {
case WikilinkResolved() when resolved != null:
return resolved(_that.path);case WikilinkMissing() when missing != null:
return missing();case WikilinkAmbiguous() when ambiguous != null:
return ambiguous(_that.candidates);case _:
  return null;

}
}

}

/// @nodoc


class WikilinkResolved extends WikilinkTargetValueObject {
  const WikilinkResolved(this.path): super._();
  

/// Where it is, relative to the space root.
 final  SpaceRelativePathValueObject path;

/// Create a copy of WikilinkTargetValueObject
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WikilinkResolvedCopyWith<WikilinkResolved> get copyWith => _$WikilinkResolvedCopyWithImpl<WikilinkResolved>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WikilinkResolved&&(identical(other.path, path) || other.path == path));
}


@override
int get hashCode => Object.hash(runtimeType,path);

@override
String toString() {
  return 'WikilinkTargetValueObject.resolved(path: $path)';
}


}

/// @nodoc
abstract mixin class $WikilinkResolvedCopyWith<$Res> implements $WikilinkTargetValueObjectCopyWith<$Res> {
  factory $WikilinkResolvedCopyWith(WikilinkResolved value, $Res Function(WikilinkResolved) _then) = _$WikilinkResolvedCopyWithImpl;
@useResult
$Res call({
 SpaceRelativePathValueObject path
});




}
/// @nodoc
class _$WikilinkResolvedCopyWithImpl<$Res>
    implements $WikilinkResolvedCopyWith<$Res> {
  _$WikilinkResolvedCopyWithImpl(this._self, this._then);

  final WikilinkResolved _self;
  final $Res Function(WikilinkResolved) _then;

/// Create a copy of WikilinkTargetValueObject
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? path = null,}) {
  return _then(WikilinkResolved(
null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as SpaceRelativePathValueObject,
  ));
}


}

/// @nodoc


class WikilinkMissing extends WikilinkTargetValueObject {
  const WikilinkMissing(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WikilinkMissing);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'WikilinkTargetValueObject.missing()';
}


}




/// @nodoc


class WikilinkAmbiguous extends WikilinkTargetValueObject {
  const WikilinkAmbiguous(final  List<SpaceRelativePathValueObject> candidates): _candidates = candidates,super._();
  

/// Every match, in the order the listing had them.
 final  List<SpaceRelativePathValueObject> _candidates;
/// Every match, in the order the listing had them.
 List<SpaceRelativePathValueObject> get candidates {
  if (_candidates is EqualUnmodifiableListView) return _candidates;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_candidates);
}


/// Create a copy of WikilinkTargetValueObject
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WikilinkAmbiguousCopyWith<WikilinkAmbiguous> get copyWith => _$WikilinkAmbiguousCopyWithImpl<WikilinkAmbiguous>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WikilinkAmbiguous&&const DeepCollectionEquality().equals(other._candidates, _candidates));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_candidates));

@override
String toString() {
  return 'WikilinkTargetValueObject.ambiguous(candidates: $candidates)';
}


}

/// @nodoc
abstract mixin class $WikilinkAmbiguousCopyWith<$Res> implements $WikilinkTargetValueObjectCopyWith<$Res> {
  factory $WikilinkAmbiguousCopyWith(WikilinkAmbiguous value, $Res Function(WikilinkAmbiguous) _then) = _$WikilinkAmbiguousCopyWithImpl;
@useResult
$Res call({
 List<SpaceRelativePathValueObject> candidates
});




}
/// @nodoc
class _$WikilinkAmbiguousCopyWithImpl<$Res>
    implements $WikilinkAmbiguousCopyWith<$Res> {
  _$WikilinkAmbiguousCopyWithImpl(this._self, this._then);

  final WikilinkAmbiguous _self;
  final $Res Function(WikilinkAmbiguous) _then;

/// Create a copy of WikilinkTargetValueObject
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? candidates = null,}) {
  return _then(WikilinkAmbiguous(
null == candidates ? _self._candidates : candidates // ignore: cast_nullable_to_non_nullable
as List<SpaceRelativePathValueObject>,
  ));
}


}

// dart format on
