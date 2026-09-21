// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HomeState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'HomeState()';
}


}

/// @nodoc
class $HomeStateCopyWith<$Res>  {
$HomeStateCopyWith(HomeState _, $Res Function(HomeState) __);
}


/// Adds pattern-matching-related methods to [HomeState].
extension HomeStatePatterns on HomeState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( HomeInitial value)?  initial,TResult Function( HomeLoading value)?  loading,TResult Function( HomeReady value)?  ready,TResult Function( HomeFailed value)?  failed,TResult Function( HomeOpened value)?  opened,required TResult orElse(),}){
final _that = this;
switch (_that) {
case HomeInitial() when initial != null:
return initial(_that);case HomeLoading() when loading != null:
return loading(_that);case HomeReady() when ready != null:
return ready(_that);case HomeFailed() when failed != null:
return failed(_that);case HomeOpened() when opened != null:
return opened(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( HomeInitial value)  initial,required TResult Function( HomeLoading value)  loading,required TResult Function( HomeReady value)  ready,required TResult Function( HomeFailed value)  failed,required TResult Function( HomeOpened value)  opened,}){
final _that = this;
switch (_that) {
case HomeInitial():
return initial(_that);case HomeLoading():
return loading(_that);case HomeReady():
return ready(_that);case HomeFailed():
return failed(_that);case HomeOpened():
return opened(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( HomeInitial value)?  initial,TResult? Function( HomeLoading value)?  loading,TResult? Function( HomeReady value)?  ready,TResult? Function( HomeFailed value)?  failed,TResult? Function( HomeOpened value)?  opened,}){
final _that = this;
switch (_that) {
case HomeInitial() when initial != null:
return initial(_that);case HomeLoading() when loading != null:
return loading(_that);case HomeReady() when ready != null:
return ready(_that);case HomeFailed() when failed != null:
return failed(_that);case HomeOpened() when opened != null:
return opened(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( List<RecentSpace> recents)?  ready,TResult Function( AppFailure failure,  List<RecentSpace> recents)?  failed,TResult Function( Space space)?  opened,required TResult orElse(),}) {final _that = this;
switch (_that) {
case HomeInitial() when initial != null:
return initial();case HomeLoading() when loading != null:
return loading();case HomeReady() when ready != null:
return ready(_that.recents);case HomeFailed() when failed != null:
return failed(_that.failure,_that.recents);case HomeOpened() when opened != null:
return opened(_that.space);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( List<RecentSpace> recents)  ready,required TResult Function( AppFailure failure,  List<RecentSpace> recents)  failed,required TResult Function( Space space)  opened,}) {final _that = this;
switch (_that) {
case HomeInitial():
return initial();case HomeLoading():
return loading();case HomeReady():
return ready(_that.recents);case HomeFailed():
return failed(_that.failure,_that.recents);case HomeOpened():
return opened(_that.space);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( List<RecentSpace> recents)?  ready,TResult? Function( AppFailure failure,  List<RecentSpace> recents)?  failed,TResult? Function( Space space)?  opened,}) {final _that = this;
switch (_that) {
case HomeInitial() when initial != null:
return initial();case HomeLoading() when loading != null:
return loading();case HomeReady() when ready != null:
return ready(_that.recents);case HomeFailed() when failed != null:
return failed(_that.failure,_that.recents);case HomeOpened() when opened != null:
return opened(_that.space);case _:
  return null;

}
}

}

/// @nodoc


class HomeInitial implements HomeState {
  const HomeInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'HomeState.initial()';
}


}




/// @nodoc


class HomeLoading implements HomeState {
  const HomeLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'HomeState.loading()';
}


}




/// @nodoc


class HomeReady implements HomeState {
  const HomeReady(final  List<RecentSpace> recents): _recents = recents;
  

 final  List<RecentSpace> _recents;
 List<RecentSpace> get recents {
  if (_recents is EqualUnmodifiableListView) return _recents;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recents);
}


/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HomeReadyCopyWith<HomeReady> get copyWith => _$HomeReadyCopyWithImpl<HomeReady>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeReady&&const DeepCollectionEquality().equals(other._recents, _recents));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_recents));

@override
String toString() {
  return 'HomeState.ready(recents: $recents)';
}


}

/// @nodoc
abstract mixin class $HomeReadyCopyWith<$Res> implements $HomeStateCopyWith<$Res> {
  factory $HomeReadyCopyWith(HomeReady value, $Res Function(HomeReady) _then) = _$HomeReadyCopyWithImpl;
@useResult
$Res call({
 List<RecentSpace> recents
});




}
/// @nodoc
class _$HomeReadyCopyWithImpl<$Res>
    implements $HomeReadyCopyWith<$Res> {
  _$HomeReadyCopyWithImpl(this._self, this._then);

  final HomeReady _self;
  final $Res Function(HomeReady) _then;

/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? recents = null,}) {
  return _then(HomeReady(
null == recents ? _self._recents : recents // ignore: cast_nullable_to_non_nullable
as List<RecentSpace>,
  ));
}


}

/// @nodoc


class HomeFailed implements HomeState {
  const HomeFailed({required this.failure, required final  List<RecentSpace> recents}): _recents = recents;
  

 final  AppFailure failure;
 final  List<RecentSpace> _recents;
 List<RecentSpace> get recents {
  if (_recents is EqualUnmodifiableListView) return _recents;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recents);
}


/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HomeFailedCopyWith<HomeFailed> get copyWith => _$HomeFailedCopyWithImpl<HomeFailed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeFailed&&(identical(other.failure, failure) || other.failure == failure)&&const DeepCollectionEquality().equals(other._recents, _recents));
}


@override
int get hashCode => Object.hash(runtimeType,failure,const DeepCollectionEquality().hash(_recents));

@override
String toString() {
  return 'HomeState.failed(failure: $failure, recents: $recents)';
}


}

/// @nodoc
abstract mixin class $HomeFailedCopyWith<$Res> implements $HomeStateCopyWith<$Res> {
  factory $HomeFailedCopyWith(HomeFailed value, $Res Function(HomeFailed) _then) = _$HomeFailedCopyWithImpl;
@useResult
$Res call({
 AppFailure failure, List<RecentSpace> recents
});




}
/// @nodoc
class _$HomeFailedCopyWithImpl<$Res>
    implements $HomeFailedCopyWith<$Res> {
  _$HomeFailedCopyWithImpl(this._self, this._then);

  final HomeFailed _self;
  final $Res Function(HomeFailed) _then;

/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? failure = null,Object? recents = null,}) {
  return _then(HomeFailed(
failure: null == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as AppFailure,recents: null == recents ? _self._recents : recents // ignore: cast_nullable_to_non_nullable
as List<RecentSpace>,
  ));
}


}

/// @nodoc


class HomeOpened implements HomeState {
  const HomeOpened(this.space);
  

 final  Space space;

/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HomeOpenedCopyWith<HomeOpened> get copyWith => _$HomeOpenedCopyWithImpl<HomeOpened>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeOpened&&(identical(other.space, space) || other.space == space));
}


@override
int get hashCode => Object.hash(runtimeType,space);

@override
String toString() {
  return 'HomeState.opened(space: $space)';
}


}

/// @nodoc
abstract mixin class $HomeOpenedCopyWith<$Res> implements $HomeStateCopyWith<$Res> {
  factory $HomeOpenedCopyWith(HomeOpened value, $Res Function(HomeOpened) _then) = _$HomeOpenedCopyWithImpl;
@useResult
$Res call({
 Space space
});


$SpaceCopyWith<$Res> get space;

}
/// @nodoc
class _$HomeOpenedCopyWithImpl<$Res>
    implements $HomeOpenedCopyWith<$Res> {
  _$HomeOpenedCopyWithImpl(this._self, this._then);

  final HomeOpened _self;
  final $Res Function(HomeOpened) _then;

/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? space = null,}) {
  return _then(HomeOpened(
null == space ? _self.space : space // ignore: cast_nullable_to_non_nullable
as Space,
  ));
}

/// Create a copy of HomeState
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
