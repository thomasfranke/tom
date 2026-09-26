// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SearchState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SearchState()';
}


}

/// @nodoc
class $SearchStateCopyWith<$Res>  {
$SearchStateCopyWith(SearchState _, $Res Function(SearchState) __);
}


/// Adds pattern-matching-related methods to [SearchState].
extension SearchStatePatterns on SearchState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( SearchIdle value)?  idle,TResult Function( SearchIndexing value)?  indexing,TResult Function( SearchReady value)?  ready,TResult Function( SearchFailed value)?  failed,required TResult orElse(),}){
final _that = this;
switch (_that) {
case SearchIdle() when idle != null:
return idle(_that);case SearchIndexing() when indexing != null:
return indexing(_that);case SearchReady() when ready != null:
return ready(_that);case SearchFailed() when failed != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( SearchIdle value)  idle,required TResult Function( SearchIndexing value)  indexing,required TResult Function( SearchReady value)  ready,required TResult Function( SearchFailed value)  failed,}){
final _that = this;
switch (_that) {
case SearchIdle():
return idle(_that);case SearchIndexing():
return indexing(_that);case SearchReady():
return ready(_that);case SearchFailed():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( SearchIdle value)?  idle,TResult? Function( SearchIndexing value)?  indexing,TResult? Function( SearchReady value)?  ready,TResult? Function( SearchFailed value)?  failed,}){
final _that = this;
switch (_that) {
case SearchIdle() when idle != null:
return idle(_that);case SearchIndexing() when indexing != null:
return indexing(_that);case SearchReady() when ready != null:
return ready(_that);case SearchFailed() when failed != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  idle,TResult Function( String terms)?  indexing,TResult Function( String terms,  List<SearchHitValueObject> hits)?  ready,TResult Function( AppFailure failure)?  failed,required TResult orElse(),}) {final _that = this;
switch (_that) {
case SearchIdle() when idle != null:
return idle();case SearchIndexing() when indexing != null:
return indexing(_that.terms);case SearchReady() when ready != null:
return ready(_that.terms,_that.hits);case SearchFailed() when failed != null:
return failed(_that.failure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  idle,required TResult Function( String terms)  indexing,required TResult Function( String terms,  List<SearchHitValueObject> hits)  ready,required TResult Function( AppFailure failure)  failed,}) {final _that = this;
switch (_that) {
case SearchIdle():
return idle();case SearchIndexing():
return indexing(_that.terms);case SearchReady():
return ready(_that.terms,_that.hits);case SearchFailed():
return failed(_that.failure);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  idle,TResult? Function( String terms)?  indexing,TResult? Function( String terms,  List<SearchHitValueObject> hits)?  ready,TResult? Function( AppFailure failure)?  failed,}) {final _that = this;
switch (_that) {
case SearchIdle() when idle != null:
return idle();case SearchIndexing() when indexing != null:
return indexing(_that.terms);case SearchReady() when ready != null:
return ready(_that.terms,_that.hits);case SearchFailed() when failed != null:
return failed(_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class SearchIdle extends SearchState {
  const SearchIdle(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchIdle);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SearchState.idle()';
}


}




/// @nodoc


class SearchIndexing extends SearchState {
  const SearchIndexing({this.terms = ''}): super._();
  

/// What has been typed meanwhile; searched for once the index is built.
@JsonKey() final  String terms;

/// Create a copy of SearchState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchIndexingCopyWith<SearchIndexing> get copyWith => _$SearchIndexingCopyWithImpl<SearchIndexing>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchIndexing&&(identical(other.terms, terms) || other.terms == terms));
}


@override
int get hashCode => Object.hash(runtimeType,terms);

@override
String toString() {
  return 'SearchState.indexing(terms: $terms)';
}


}

/// @nodoc
abstract mixin class $SearchIndexingCopyWith<$Res> implements $SearchStateCopyWith<$Res> {
  factory $SearchIndexingCopyWith(SearchIndexing value, $Res Function(SearchIndexing) _then) = _$SearchIndexingCopyWithImpl;
@useResult
$Res call({
 String terms
});




}
/// @nodoc
class _$SearchIndexingCopyWithImpl<$Res>
    implements $SearchIndexingCopyWith<$Res> {
  _$SearchIndexingCopyWithImpl(this._self, this._then);

  final SearchIndexing _self;
  final $Res Function(SearchIndexing) _then;

/// Create a copy of SearchState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? terms = null,}) {
  return _then(SearchIndexing(
terms: null == terms ? _self.terms : terms // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class SearchReady extends SearchState {
  const SearchReady({this.terms = '', final  List<SearchHitValueObject> hits = const <SearchHitValueObject>[]}): _hits = hits,super._();
  

/// What is in the box; empty means nothing has been asked for.
@JsonKey() final  String terms;
/// The documents that matched, best first.
 final  List<SearchHitValueObject> _hits;
/// The documents that matched, best first.
@JsonKey() List<SearchHitValueObject> get hits {
  if (_hits is EqualUnmodifiableListView) return _hits;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_hits);
}


/// Create a copy of SearchState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchReadyCopyWith<SearchReady> get copyWith => _$SearchReadyCopyWithImpl<SearchReady>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchReady&&(identical(other.terms, terms) || other.terms == terms)&&const DeepCollectionEquality().equals(other._hits, _hits));
}


@override
int get hashCode => Object.hash(runtimeType,terms,const DeepCollectionEquality().hash(_hits));

@override
String toString() {
  return 'SearchState.ready(terms: $terms, hits: $hits)';
}


}

/// @nodoc
abstract mixin class $SearchReadyCopyWith<$Res> implements $SearchStateCopyWith<$Res> {
  factory $SearchReadyCopyWith(SearchReady value, $Res Function(SearchReady) _then) = _$SearchReadyCopyWithImpl;
@useResult
$Res call({
 String terms, List<SearchHitValueObject> hits
});




}
/// @nodoc
class _$SearchReadyCopyWithImpl<$Res>
    implements $SearchReadyCopyWith<$Res> {
  _$SearchReadyCopyWithImpl(this._self, this._then);

  final SearchReady _self;
  final $Res Function(SearchReady) _then;

/// Create a copy of SearchState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? terms = null,Object? hits = null,}) {
  return _then(SearchReady(
terms: null == terms ? _self.terms : terms // ignore: cast_nullable_to_non_nullable
as String,hits: null == hits ? _self._hits : hits // ignore: cast_nullable_to_non_nullable
as List<SearchHitValueObject>,
  ));
}


}

/// @nodoc


class SearchFailed extends SearchState {
  const SearchFailed(this.failure): super._();
  

 final  AppFailure failure;

/// Create a copy of SearchState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchFailedCopyWith<SearchFailed> get copyWith => _$SearchFailedCopyWithImpl<SearchFailed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchFailed&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,failure);

@override
String toString() {
  return 'SearchState.failed(failure: $failure)';
}


}

/// @nodoc
abstract mixin class $SearchFailedCopyWith<$Res> implements $SearchStateCopyWith<$Res> {
  factory $SearchFailedCopyWith(SearchFailed value, $Res Function(SearchFailed) _then) = _$SearchFailedCopyWithImpl;
@useResult
$Res call({
 AppFailure failure
});




}
/// @nodoc
class _$SearchFailedCopyWithImpl<$Res>
    implements $SearchFailedCopyWith<$Res> {
  _$SearchFailedCopyWithImpl(this._self, this._then);

  final SearchFailed _self;
  final $Res Function(SearchFailed) _then;

/// Create a copy of SearchState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? failure = null,}) {
  return _then(SearchFailed(
null == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as AppFailure,
  ));
}


}

// dart format on
