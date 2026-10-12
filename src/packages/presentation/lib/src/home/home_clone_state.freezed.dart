// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_clone_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HomeCloneState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeCloneState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'HomeCloneState()';
}


}

/// @nodoc
class $HomeCloneStateCopyWith<$Res>  {
$HomeCloneStateCopyWith(HomeCloneState _, $Res Function(HomeCloneState) __);
}


/// Adds pattern-matching-related methods to [HomeCloneState].
extension HomeCloneStatePatterns on HomeCloneState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( HomeCloneClosed value)?  closed,TResult Function( HomeCloneOpen value)?  open,TResult Function( HomeCloneCloning value)?  cloning,TResult Function( HomeCloneFailed value)?  failed,required TResult orElse(),}){
final _that = this;
switch (_that) {
case HomeCloneClosed() when closed != null:
return closed(_that);case HomeCloneOpen() when open != null:
return open(_that);case HomeCloneCloning() when cloning != null:
return cloning(_that);case HomeCloneFailed() when failed != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( HomeCloneClosed value)  closed,required TResult Function( HomeCloneOpen value)  open,required TResult Function( HomeCloneCloning value)  cloning,required TResult Function( HomeCloneFailed value)  failed,}){
final _that = this;
switch (_that) {
case HomeCloneClosed():
return closed(_that);case HomeCloneOpen():
return open(_that);case HomeCloneCloning():
return cloning(_that);case HomeCloneFailed():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( HomeCloneClosed value)?  closed,TResult? Function( HomeCloneOpen value)?  open,TResult? Function( HomeCloneCloning value)?  cloning,TResult? Function( HomeCloneFailed value)?  failed,}){
final _that = this;
switch (_that) {
case HomeCloneClosed() when closed != null:
return closed(_that);case HomeCloneOpen() when open != null:
return open(_that);case HomeCloneCloning() when cloning != null:
return cloning(_that);case HomeCloneFailed() when failed != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  closed,TResult Function()?  open,TResult Function( String url,  String destination,  CloneProgressValueObject? progress)?  cloning,TResult Function( String url,  AppFailure failure)?  failed,required TResult orElse(),}) {final _that = this;
switch (_that) {
case HomeCloneClosed() when closed != null:
return closed();case HomeCloneOpen() when open != null:
return open();case HomeCloneCloning() when cloning != null:
return cloning(_that.url,_that.destination,_that.progress);case HomeCloneFailed() when failed != null:
return failed(_that.url,_that.failure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  closed,required TResult Function()  open,required TResult Function( String url,  String destination,  CloneProgressValueObject? progress)  cloning,required TResult Function( String url,  AppFailure failure)  failed,}) {final _that = this;
switch (_that) {
case HomeCloneClosed():
return closed();case HomeCloneOpen():
return open();case HomeCloneCloning():
return cloning(_that.url,_that.destination,_that.progress);case HomeCloneFailed():
return failed(_that.url,_that.failure);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  closed,TResult? Function()?  open,TResult? Function( String url,  String destination,  CloneProgressValueObject? progress)?  cloning,TResult? Function( String url,  AppFailure failure)?  failed,}) {final _that = this;
switch (_that) {
case HomeCloneClosed() when closed != null:
return closed();case HomeCloneOpen() when open != null:
return open();case HomeCloneCloning() when cloning != null:
return cloning(_that.url,_that.destination,_that.progress);case HomeCloneFailed() when failed != null:
return failed(_that.url,_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class HomeCloneClosed implements HomeCloneState {
  const HomeCloneClosed();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeCloneClosed);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'HomeCloneState.closed()';
}


}




/// @nodoc


class HomeCloneOpen implements HomeCloneState {
  const HomeCloneOpen();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeCloneOpen);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'HomeCloneState.open()';
}


}




/// @nodoc


class HomeCloneCloning implements HomeCloneState {
  const HomeCloneCloning({required this.url, required this.destination, this.progress});
  

 final  String url;
 final  String destination;
 final  CloneProgressValueObject? progress;

/// Create a copy of HomeCloneState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HomeCloneCloningCopyWith<HomeCloneCloning> get copyWith => _$HomeCloneCloningCopyWithImpl<HomeCloneCloning>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeCloneCloning&&(identical(other.url, url) || other.url == url)&&(identical(other.destination, destination) || other.destination == destination)&&(identical(other.progress, progress) || other.progress == progress));
}


@override
int get hashCode => Object.hash(runtimeType,url,destination,progress);

@override
String toString() {
  return 'HomeCloneState.cloning(url: $url, destination: $destination, progress: $progress)';
}


}

/// @nodoc
abstract mixin class $HomeCloneCloningCopyWith<$Res> implements $HomeCloneStateCopyWith<$Res> {
  factory $HomeCloneCloningCopyWith(HomeCloneCloning value, $Res Function(HomeCloneCloning) _then) = _$HomeCloneCloningCopyWithImpl;
@useResult
$Res call({
 String url, String destination, CloneProgressValueObject? progress
});


$CloneProgressValueObjectCopyWith<$Res>? get progress;

}
/// @nodoc
class _$HomeCloneCloningCopyWithImpl<$Res>
    implements $HomeCloneCloningCopyWith<$Res> {
  _$HomeCloneCloningCopyWithImpl(this._self, this._then);

  final HomeCloneCloning _self;
  final $Res Function(HomeCloneCloning) _then;

/// Create a copy of HomeCloneState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? url = null,Object? destination = null,Object? progress = freezed,}) {
  return _then(HomeCloneCloning(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,destination: null == destination ? _self.destination : destination // ignore: cast_nullable_to_non_nullable
as String,progress: freezed == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as CloneProgressValueObject?,
  ));
}

/// Create a copy of HomeCloneState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CloneProgressValueObjectCopyWith<$Res>? get progress {
    if (_self.progress == null) {
    return null;
  }

  return $CloneProgressValueObjectCopyWith<$Res>(_self.progress!, (value) {
    return _then(_self.copyWith(progress: value));
  });
}
}

/// @nodoc


class HomeCloneFailed implements HomeCloneState {
  const HomeCloneFailed({required this.url, required this.failure});
  

 final  String url;
 final  AppFailure failure;

/// Create a copy of HomeCloneState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HomeCloneFailedCopyWith<HomeCloneFailed> get copyWith => _$HomeCloneFailedCopyWithImpl<HomeCloneFailed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeCloneFailed&&(identical(other.url, url) || other.url == url)&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,url,failure);

@override
String toString() {
  return 'HomeCloneState.failed(url: $url, failure: $failure)';
}


}

/// @nodoc
abstract mixin class $HomeCloneFailedCopyWith<$Res> implements $HomeCloneStateCopyWith<$Res> {
  factory $HomeCloneFailedCopyWith(HomeCloneFailed value, $Res Function(HomeCloneFailed) _then) = _$HomeCloneFailedCopyWithImpl;
@useResult
$Res call({
 String url, AppFailure failure
});




}
/// @nodoc
class _$HomeCloneFailedCopyWithImpl<$Res>
    implements $HomeCloneFailedCopyWith<$Res> {
  _$HomeCloneFailedCopyWithImpl(this._self, this._then);

  final HomeCloneFailed _self;
  final $Res Function(HomeCloneFailed) _then;

/// Create a copy of HomeCloneState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? url = null,Object? failure = null,}) {
  return _then(HomeCloneFailed(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,failure: null == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as AppFailure,
  ));
}


}

// dart format on
