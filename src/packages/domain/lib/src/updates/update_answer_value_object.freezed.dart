// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'update_answer_value_object.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UpdateAnswerValueObject {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateAnswerValueObject);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'UpdateAnswerValueObject()';
}


}

/// @nodoc
class $UpdateAnswerValueObjectCopyWith<$Res>  {
$UpdateAnswerValueObjectCopyWith(UpdateAnswerValueObject _, $Res Function(UpdateAnswerValueObject) __);
}


/// Adds pattern-matching-related methods to [UpdateAnswerValueObject].
extension UpdateAnswerValueObjectPatterns on UpdateAnswerValueObject {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( UpdateNoRelease value)?  noRelease,TResult Function( UpdateUpToDate value)?  upToDate,TResult Function( UpdateNewer value)?  newer,required TResult orElse(),}){
final _that = this;
switch (_that) {
case UpdateNoRelease() when noRelease != null:
return noRelease(_that);case UpdateUpToDate() when upToDate != null:
return upToDate(_that);case UpdateNewer() when newer != null:
return newer(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( UpdateNoRelease value)  noRelease,required TResult Function( UpdateUpToDate value)  upToDate,required TResult Function( UpdateNewer value)  newer,}){
final _that = this;
switch (_that) {
case UpdateNoRelease():
return noRelease(_that);case UpdateUpToDate():
return upToDate(_that);case UpdateNewer():
return newer(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( UpdateNoRelease value)?  noRelease,TResult? Function( UpdateUpToDate value)?  upToDate,TResult? Function( UpdateNewer value)?  newer,}){
final _that = this;
switch (_that) {
case UpdateNoRelease() when noRelease != null:
return noRelease(_that);case UpdateUpToDate() when upToDate != null:
return upToDate(_that);case UpdateNewer() when newer != null:
return newer(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  noRelease,TResult Function()?  upToDate,TResult Function( ReleaseValueObject release)?  newer,required TResult orElse(),}) {final _that = this;
switch (_that) {
case UpdateNoRelease() when noRelease != null:
return noRelease();case UpdateUpToDate() when upToDate != null:
return upToDate();case UpdateNewer() when newer != null:
return newer(_that.release);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  noRelease,required TResult Function()  upToDate,required TResult Function( ReleaseValueObject release)  newer,}) {final _that = this;
switch (_that) {
case UpdateNoRelease():
return noRelease();case UpdateUpToDate():
return upToDate();case UpdateNewer():
return newer(_that.release);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  noRelease,TResult? Function()?  upToDate,TResult? Function( ReleaseValueObject release)?  newer,}) {final _that = this;
switch (_that) {
case UpdateNoRelease() when noRelease != null:
return noRelease();case UpdateUpToDate() when upToDate != null:
return upToDate();case UpdateNewer() when newer != null:
return newer(_that.release);case _:
  return null;

}
}

}

/// @nodoc


class UpdateNoRelease implements UpdateAnswerValueObject {
  const UpdateNoRelease();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateNoRelease);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'UpdateAnswerValueObject.noRelease()';
}


}




/// @nodoc


class UpdateUpToDate implements UpdateAnswerValueObject {
  const UpdateUpToDate();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateUpToDate);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'UpdateAnswerValueObject.upToDate()';
}


}




/// @nodoc


class UpdateNewer implements UpdateAnswerValueObject {
  const UpdateNewer(this.release);
  

 final  ReleaseValueObject release;

/// Create a copy of UpdateAnswerValueObject
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateNewerCopyWith<UpdateNewer> get copyWith => _$UpdateNewerCopyWithImpl<UpdateNewer>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateNewer&&(identical(other.release, release) || other.release == release));
}


@override
int get hashCode => Object.hash(runtimeType,release);

@override
String toString() {
  return 'UpdateAnswerValueObject.newer(release: $release)';
}


}

/// @nodoc
abstract mixin class $UpdateNewerCopyWith<$Res> implements $UpdateAnswerValueObjectCopyWith<$Res> {
  factory $UpdateNewerCopyWith(UpdateNewer value, $Res Function(UpdateNewer) _then) = _$UpdateNewerCopyWithImpl;
@useResult
$Res call({
 ReleaseValueObject release
});


$ReleaseValueObjectCopyWith<$Res> get release;

}
/// @nodoc
class _$UpdateNewerCopyWithImpl<$Res>
    implements $UpdateNewerCopyWith<$Res> {
  _$UpdateNewerCopyWithImpl(this._self, this._then);

  final UpdateNewer _self;
  final $Res Function(UpdateNewer) _then;

/// Create a copy of UpdateAnswerValueObject
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? release = null,}) {
  return _then(UpdateNewer(
null == release ? _self.release : release // ignore: cast_nullable_to_non_nullable
as ReleaseValueObject,
  ));
}

/// Create a copy of UpdateAnswerValueObject
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReleaseValueObjectCopyWith<$Res> get release {
  
  return $ReleaseValueObjectCopyWith<$Res>(_self.release, (value) {
    return _then(_self.copyWith(release: value));
  });
}
}

// dart format on
