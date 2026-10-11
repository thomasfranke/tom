// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'updates_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UpdatesState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdatesState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'UpdatesState()';
}


}

/// @nodoc
class $UpdatesStateCopyWith<$Res>  {
$UpdatesStateCopyWith(UpdatesState _, $Res Function(UpdatesState) __);
}


/// Adds pattern-matching-related methods to [UpdatesState].
extension UpdatesStatePatterns on UpdatesState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( UpdatesNoRelease value)?  noRelease,TResult Function( UpdatesIdle value)?  idle,TResult Function( UpdatesAsking value)?  asking,TResult Function( UpdatesUpToDate value)?  upToDate,TResult Function( UpdatesNewer value)?  newer,TResult Function( UpdatesFailed value)?  failed,required TResult orElse(),}){
final _that = this;
switch (_that) {
case UpdatesNoRelease() when noRelease != null:
return noRelease(_that);case UpdatesIdle() when idle != null:
return idle(_that);case UpdatesAsking() when asking != null:
return asking(_that);case UpdatesUpToDate() when upToDate != null:
return upToDate(_that);case UpdatesNewer() when newer != null:
return newer(_that);case UpdatesFailed() when failed != null:
return failed(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( UpdatesNoRelease value)  noRelease,required TResult Function( UpdatesIdle value)  idle,required TResult Function( UpdatesAsking value)  asking,required TResult Function( UpdatesUpToDate value)  upToDate,required TResult Function( UpdatesNewer value)  newer,required TResult Function( UpdatesFailed value)  failed,}){
final _that = this;
switch (_that) {
case UpdatesNoRelease():
return noRelease(_that);case UpdatesIdle():
return idle(_that);case UpdatesAsking():
return asking(_that);case UpdatesUpToDate():
return upToDate(_that);case UpdatesNewer():
return newer(_that);case UpdatesFailed():
return failed(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( UpdatesNoRelease value)?  noRelease,TResult? Function( UpdatesIdle value)?  idle,TResult? Function( UpdatesAsking value)?  asking,TResult? Function( UpdatesUpToDate value)?  upToDate,TResult? Function( UpdatesNewer value)?  newer,TResult? Function( UpdatesFailed value)?  failed,}){
final _that = this;
switch (_that) {
case UpdatesNoRelease() when noRelease != null:
return noRelease(_that);case UpdatesIdle() when idle != null:
return idle(_that);case UpdatesAsking() when asking != null:
return asking(_that);case UpdatesUpToDate() when upToDate != null:
return upToDate(_that);case UpdatesNewer() when newer != null:
return newer(_that);case UpdatesFailed() when failed != null:
return failed(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  noRelease,TResult Function()?  idle,TResult Function()?  asking,TResult Function( DateTime checkedAt)?  upToDate,TResult Function( String version,  String notesUrl)?  newer,TResult Function()?  failed,required TResult orElse(),}) {final _that = this;
switch (_that) {
case UpdatesNoRelease() when noRelease != null:
return noRelease();case UpdatesIdle() when idle != null:
return idle();case UpdatesAsking() when asking != null:
return asking();case UpdatesUpToDate() when upToDate != null:
return upToDate(_that.checkedAt);case UpdatesNewer() when newer != null:
return newer(_that.version,_that.notesUrl);case UpdatesFailed() when failed != null:
return failed();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  noRelease,required TResult Function()  idle,required TResult Function()  asking,required TResult Function( DateTime checkedAt)  upToDate,required TResult Function( String version,  String notesUrl)  newer,required TResult Function()  failed,}) {final _that = this;
switch (_that) {
case UpdatesNoRelease():
return noRelease();case UpdatesIdle():
return idle();case UpdatesAsking():
return asking();case UpdatesUpToDate():
return upToDate(_that.checkedAt);case UpdatesNewer():
return newer(_that.version,_that.notesUrl);case UpdatesFailed():
return failed();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  noRelease,TResult? Function()?  idle,TResult? Function()?  asking,TResult? Function( DateTime checkedAt)?  upToDate,TResult? Function( String version,  String notesUrl)?  newer,TResult? Function()?  failed,}) {final _that = this;
switch (_that) {
case UpdatesNoRelease() when noRelease != null:
return noRelease();case UpdatesIdle() when idle != null:
return idle();case UpdatesAsking() when asking != null:
return asking();case UpdatesUpToDate() when upToDate != null:
return upToDate(_that.checkedAt);case UpdatesNewer() when newer != null:
return newer(_that.version,_that.notesUrl);case UpdatesFailed() when failed != null:
return failed();case _:
  return null;

}
}

}

/// @nodoc


class UpdatesNoRelease implements UpdatesState {
  const UpdatesNoRelease();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdatesNoRelease);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'UpdatesState.noRelease()';
}


}




/// @nodoc


class UpdatesIdle implements UpdatesState {
  const UpdatesIdle();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdatesIdle);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'UpdatesState.idle()';
}


}




/// @nodoc


class UpdatesAsking implements UpdatesState {
  const UpdatesAsking();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdatesAsking);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'UpdatesState.asking()';
}


}




/// @nodoc


class UpdatesUpToDate implements UpdatesState {
  const UpdatesUpToDate(this.checkedAt);
  

 final  DateTime checkedAt;

/// Create a copy of UpdatesState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdatesUpToDateCopyWith<UpdatesUpToDate> get copyWith => _$UpdatesUpToDateCopyWithImpl<UpdatesUpToDate>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdatesUpToDate&&(identical(other.checkedAt, checkedAt) || other.checkedAt == checkedAt));
}


@override
int get hashCode => Object.hash(runtimeType,checkedAt);

@override
String toString() {
  return 'UpdatesState.upToDate(checkedAt: $checkedAt)';
}


}

/// @nodoc
abstract mixin class $UpdatesUpToDateCopyWith<$Res> implements $UpdatesStateCopyWith<$Res> {
  factory $UpdatesUpToDateCopyWith(UpdatesUpToDate value, $Res Function(UpdatesUpToDate) _then) = _$UpdatesUpToDateCopyWithImpl;
@useResult
$Res call({
 DateTime checkedAt
});




}
/// @nodoc
class _$UpdatesUpToDateCopyWithImpl<$Res>
    implements $UpdatesUpToDateCopyWith<$Res> {
  _$UpdatesUpToDateCopyWithImpl(this._self, this._then);

  final UpdatesUpToDate _self;
  final $Res Function(UpdatesUpToDate) _then;

/// Create a copy of UpdatesState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? checkedAt = null,}) {
  return _then(UpdatesUpToDate(
null == checkedAt ? _self.checkedAt : checkedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc


class UpdatesNewer implements UpdatesState {
  const UpdatesNewer({required this.version, required this.notesUrl});
  

 final  String version;
 final  String notesUrl;

/// Create a copy of UpdatesState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdatesNewerCopyWith<UpdatesNewer> get copyWith => _$UpdatesNewerCopyWithImpl<UpdatesNewer>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdatesNewer&&(identical(other.version, version) || other.version == version)&&(identical(other.notesUrl, notesUrl) || other.notesUrl == notesUrl));
}


@override
int get hashCode => Object.hash(runtimeType,version,notesUrl);

@override
String toString() {
  return 'UpdatesState.newer(version: $version, notesUrl: $notesUrl)';
}


}

/// @nodoc
abstract mixin class $UpdatesNewerCopyWith<$Res> implements $UpdatesStateCopyWith<$Res> {
  factory $UpdatesNewerCopyWith(UpdatesNewer value, $Res Function(UpdatesNewer) _then) = _$UpdatesNewerCopyWithImpl;
@useResult
$Res call({
 String version, String notesUrl
});




}
/// @nodoc
class _$UpdatesNewerCopyWithImpl<$Res>
    implements $UpdatesNewerCopyWith<$Res> {
  _$UpdatesNewerCopyWithImpl(this._self, this._then);

  final UpdatesNewer _self;
  final $Res Function(UpdatesNewer) _then;

/// Create a copy of UpdatesState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? version = null,Object? notesUrl = null,}) {
  return _then(UpdatesNewer(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,notesUrl: null == notesUrl ? _self.notesUrl : notesUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class UpdatesFailed implements UpdatesState {
  const UpdatesFailed();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdatesFailed);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'UpdatesState.failed()';
}


}




// dart format on
