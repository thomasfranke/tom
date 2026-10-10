// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wikilink_completion_value_object.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WikilinkCompletionValueObject {

/// Where the typed target starts: the first character after `[[`, so a
/// choice replaces from here to the caret.
 int get from;/// What was typed after `[[`, as typed.
 String get query;/// The documents that match, best first.
 List<WikilinkCandidateValueObject> get candidates;
/// Create a copy of WikilinkCompletionValueObject
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WikilinkCompletionValueObjectCopyWith<WikilinkCompletionValueObject> get copyWith => _$WikilinkCompletionValueObjectCopyWithImpl<WikilinkCompletionValueObject>(this as WikilinkCompletionValueObject, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WikilinkCompletionValueObject&&(identical(other.from, from) || other.from == from)&&(identical(other.query, query) || other.query == query)&&const DeepCollectionEquality().equals(other.candidates, candidates));
}


@override
int get hashCode => Object.hash(runtimeType,from,query,const DeepCollectionEquality().hash(candidates));

@override
String toString() {
  return 'WikilinkCompletionValueObject(from: $from, query: $query, candidates: $candidates)';
}


}

/// @nodoc
abstract mixin class $WikilinkCompletionValueObjectCopyWith<$Res>  {
  factory $WikilinkCompletionValueObjectCopyWith(WikilinkCompletionValueObject value, $Res Function(WikilinkCompletionValueObject) _then) = _$WikilinkCompletionValueObjectCopyWithImpl;
@useResult
$Res call({
 int from, String query, List<WikilinkCandidateValueObject> candidates
});




}
/// @nodoc
class _$WikilinkCompletionValueObjectCopyWithImpl<$Res>
    implements $WikilinkCompletionValueObjectCopyWith<$Res> {
  _$WikilinkCompletionValueObjectCopyWithImpl(this._self, this._then);

  final WikilinkCompletionValueObject _self;
  final $Res Function(WikilinkCompletionValueObject) _then;

/// Create a copy of WikilinkCompletionValueObject
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? from = null,Object? query = null,Object? candidates = null,}) {
  return _then(_self.copyWith(
from: null == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as int,query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,candidates: null == candidates ? _self.candidates : candidates // ignore: cast_nullable_to_non_nullable
as List<WikilinkCandidateValueObject>,
  ));
}

}


/// Adds pattern-matching-related methods to [WikilinkCompletionValueObject].
extension WikilinkCompletionValueObjectPatterns on WikilinkCompletionValueObject {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WikilinkCompletionValueObject value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WikilinkCompletionValueObject() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WikilinkCompletionValueObject value)  $default,){
final _that = this;
switch (_that) {
case _WikilinkCompletionValueObject():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WikilinkCompletionValueObject value)?  $default,){
final _that = this;
switch (_that) {
case _WikilinkCompletionValueObject() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int from,  String query,  List<WikilinkCandidateValueObject> candidates)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WikilinkCompletionValueObject() when $default != null:
return $default(_that.from,_that.query,_that.candidates);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int from,  String query,  List<WikilinkCandidateValueObject> candidates)  $default,) {final _that = this;
switch (_that) {
case _WikilinkCompletionValueObject():
return $default(_that.from,_that.query,_that.candidates);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int from,  String query,  List<WikilinkCandidateValueObject> candidates)?  $default,) {final _that = this;
switch (_that) {
case _WikilinkCompletionValueObject() when $default != null:
return $default(_that.from,_that.query,_that.candidates);case _:
  return null;

}
}

}

/// @nodoc


class _WikilinkCompletionValueObject implements WikilinkCompletionValueObject {
  const _WikilinkCompletionValueObject({required this.from, required this.query, required final  List<WikilinkCandidateValueObject> candidates}): _candidates = candidates;
  

/// Where the typed target starts: the first character after `[[`, so a
/// choice replaces from here to the caret.
@override final  int from;
/// What was typed after `[[`, as typed.
@override final  String query;
/// The documents that match, best first.
 final  List<WikilinkCandidateValueObject> _candidates;
/// The documents that match, best first.
@override List<WikilinkCandidateValueObject> get candidates {
  if (_candidates is EqualUnmodifiableListView) return _candidates;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_candidates);
}


/// Create a copy of WikilinkCompletionValueObject
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WikilinkCompletionValueObjectCopyWith<_WikilinkCompletionValueObject> get copyWith => __$WikilinkCompletionValueObjectCopyWithImpl<_WikilinkCompletionValueObject>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WikilinkCompletionValueObject&&(identical(other.from, from) || other.from == from)&&(identical(other.query, query) || other.query == query)&&const DeepCollectionEquality().equals(other._candidates, _candidates));
}


@override
int get hashCode => Object.hash(runtimeType,from,query,const DeepCollectionEquality().hash(_candidates));

@override
String toString() {
  return 'WikilinkCompletionValueObject(from: $from, query: $query, candidates: $candidates)';
}


}

/// @nodoc
abstract mixin class _$WikilinkCompletionValueObjectCopyWith<$Res> implements $WikilinkCompletionValueObjectCopyWith<$Res> {
  factory _$WikilinkCompletionValueObjectCopyWith(_WikilinkCompletionValueObject value, $Res Function(_WikilinkCompletionValueObject) _then) = __$WikilinkCompletionValueObjectCopyWithImpl;
@override @useResult
$Res call({
 int from, String query, List<WikilinkCandidateValueObject> candidates
});




}
/// @nodoc
class __$WikilinkCompletionValueObjectCopyWithImpl<$Res>
    implements _$WikilinkCompletionValueObjectCopyWith<$Res> {
  __$WikilinkCompletionValueObjectCopyWithImpl(this._self, this._then);

  final _WikilinkCompletionValueObject _self;
  final $Res Function(_WikilinkCompletionValueObject) _then;

/// Create a copy of WikilinkCompletionValueObject
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? from = null,Object? query = null,Object? candidates = null,}) {
  return _then(_WikilinkCompletionValueObject(
from: null == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as int,query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,candidates: null == candidates ? _self._candidates : candidates // ignore: cast_nullable_to_non_nullable
as List<WikilinkCandidateValueObject>,
  ));
}


}

/// @nodoc
mixin _$WikilinkCandidateValueObject {

/// The document, relative to the space root.
 SpaceRelativePathValueObject get path;/// What goes between the brackets: the name when the space holds it
/// once, the path when it holds it more than once — so what is written
/// always resolves to the document that was chosen.
 String get target;
/// Create a copy of WikilinkCandidateValueObject
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WikilinkCandidateValueObjectCopyWith<WikilinkCandidateValueObject> get copyWith => _$WikilinkCandidateValueObjectCopyWithImpl<WikilinkCandidateValueObject>(this as WikilinkCandidateValueObject, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WikilinkCandidateValueObject&&(identical(other.path, path) || other.path == path)&&(identical(other.target, target) || other.target == target));
}


@override
int get hashCode => Object.hash(runtimeType,path,target);

@override
String toString() {
  return 'WikilinkCandidateValueObject(path: $path, target: $target)';
}


}

/// @nodoc
abstract mixin class $WikilinkCandidateValueObjectCopyWith<$Res>  {
  factory $WikilinkCandidateValueObjectCopyWith(WikilinkCandidateValueObject value, $Res Function(WikilinkCandidateValueObject) _then) = _$WikilinkCandidateValueObjectCopyWithImpl;
@useResult
$Res call({
 SpaceRelativePathValueObject path, String target
});




}
/// @nodoc
class _$WikilinkCandidateValueObjectCopyWithImpl<$Res>
    implements $WikilinkCandidateValueObjectCopyWith<$Res> {
  _$WikilinkCandidateValueObjectCopyWithImpl(this._self, this._then);

  final WikilinkCandidateValueObject _self;
  final $Res Function(WikilinkCandidateValueObject) _then;

/// Create a copy of WikilinkCandidateValueObject
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? path = null,Object? target = null,}) {
  return _then(_self.copyWith(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as SpaceRelativePathValueObject,target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [WikilinkCandidateValueObject].
extension WikilinkCandidateValueObjectPatterns on WikilinkCandidateValueObject {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WikilinkCandidateValueObject value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WikilinkCandidateValueObject() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WikilinkCandidateValueObject value)  $default,){
final _that = this;
switch (_that) {
case _WikilinkCandidateValueObject():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WikilinkCandidateValueObject value)?  $default,){
final _that = this;
switch (_that) {
case _WikilinkCandidateValueObject() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SpaceRelativePathValueObject path,  String target)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WikilinkCandidateValueObject() when $default != null:
return $default(_that.path,_that.target);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SpaceRelativePathValueObject path,  String target)  $default,) {final _that = this;
switch (_that) {
case _WikilinkCandidateValueObject():
return $default(_that.path,_that.target);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SpaceRelativePathValueObject path,  String target)?  $default,) {final _that = this;
switch (_that) {
case _WikilinkCandidateValueObject() when $default != null:
return $default(_that.path,_that.target);case _:
  return null;

}
}

}

/// @nodoc


class _WikilinkCandidateValueObject implements WikilinkCandidateValueObject {
  const _WikilinkCandidateValueObject({required this.path, required this.target});
  

/// The document, relative to the space root.
@override final  SpaceRelativePathValueObject path;
/// What goes between the brackets: the name when the space holds it
/// once, the path when it holds it more than once — so what is written
/// always resolves to the document that was chosen.
@override final  String target;

/// Create a copy of WikilinkCandidateValueObject
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WikilinkCandidateValueObjectCopyWith<_WikilinkCandidateValueObject> get copyWith => __$WikilinkCandidateValueObjectCopyWithImpl<_WikilinkCandidateValueObject>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WikilinkCandidateValueObject&&(identical(other.path, path) || other.path == path)&&(identical(other.target, target) || other.target == target));
}


@override
int get hashCode => Object.hash(runtimeType,path,target);

@override
String toString() {
  return 'WikilinkCandidateValueObject(path: $path, target: $target)';
}


}

/// @nodoc
abstract mixin class _$WikilinkCandidateValueObjectCopyWith<$Res> implements $WikilinkCandidateValueObjectCopyWith<$Res> {
  factory _$WikilinkCandidateValueObjectCopyWith(_WikilinkCandidateValueObject value, $Res Function(_WikilinkCandidateValueObject) _then) = __$WikilinkCandidateValueObjectCopyWithImpl;
@override @useResult
$Res call({
 SpaceRelativePathValueObject path, String target
});




}
/// @nodoc
class __$WikilinkCandidateValueObjectCopyWithImpl<$Res>
    implements _$WikilinkCandidateValueObjectCopyWith<$Res> {
  __$WikilinkCandidateValueObjectCopyWithImpl(this._self, this._then);

  final _WikilinkCandidateValueObject _self;
  final $Res Function(_WikilinkCandidateValueObject) _then;

/// Create a copy of WikilinkCandidateValueObject
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? path = null,Object? target = null,}) {
  return _then(_WikilinkCandidateValueObject(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as SpaceRelativePathValueObject,target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
