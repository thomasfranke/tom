// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_failure.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SearchFailure {

 AppFailure? get cause;
/// Create a copy of SearchFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchFailureCopyWith<SearchFailure> get copyWith => _$SearchFailureCopyWithImpl<SearchFailure>(this as SearchFailure, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchFailure&&(identical(other.cause, cause) || other.cause == cause));
}


@override
int get hashCode => Object.hash(runtimeType,cause);

@override
String toString() {
  return 'SearchFailure(cause: $cause)';
}


}

/// @nodoc
abstract mixin class $SearchFailureCopyWith<$Res>  {
  factory $SearchFailureCopyWith(SearchFailure value, $Res Function(SearchFailure) _then) = _$SearchFailureCopyWithImpl;
@useResult
$Res call({
 AppFailure? cause
});




}
/// @nodoc
class _$SearchFailureCopyWithImpl<$Res>
    implements $SearchFailureCopyWith<$Res> {
  _$SearchFailureCopyWithImpl(this._self, this._then);

  final SearchFailure _self;
  final $Res Function(SearchFailure) _then;

/// Create a copy of SearchFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? cause = freezed,}) {
  return _then(_self.copyWith(
cause: freezed == cause ? _self.cause : cause // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}

}


/// Adds pattern-matching-related methods to [SearchFailure].
extension SearchFailurePatterns on SearchFailure {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( SearchIndexCorrupted value)?  indexCorrupted,required TResult orElse(),}){
final _that = this;
switch (_that) {
case SearchIndexCorrupted() when indexCorrupted != null:
return indexCorrupted(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( SearchIndexCorrupted value)  indexCorrupted,}){
final _that = this;
switch (_that) {
case SearchIndexCorrupted():
return indexCorrupted(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( SearchIndexCorrupted value)?  indexCorrupted,}){
final _that = this;
switch (_that) {
case SearchIndexCorrupted() when indexCorrupted != null:
return indexCorrupted(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( AppFailure? cause)?  indexCorrupted,required TResult orElse(),}) {final _that = this;
switch (_that) {
case SearchIndexCorrupted() when indexCorrupted != null:
return indexCorrupted(_that.cause);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( AppFailure? cause)  indexCorrupted,}) {final _that = this;
switch (_that) {
case SearchIndexCorrupted():
return indexCorrupted(_that.cause);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( AppFailure? cause)?  indexCorrupted,}) {final _that = this;
switch (_that) {
case SearchIndexCorrupted() when indexCorrupted != null:
return indexCorrupted(_that.cause);case _:
  return null;

}
}

}

/// @nodoc


class SearchIndexCorrupted implements SearchFailure {
  const SearchIndexCorrupted({this.cause});
  

@override final  AppFailure? cause;

/// Create a copy of SearchFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchIndexCorruptedCopyWith<SearchIndexCorrupted> get copyWith => _$SearchIndexCorruptedCopyWithImpl<SearchIndexCorrupted>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchIndexCorrupted&&(identical(other.cause, cause) || other.cause == cause));
}


@override
int get hashCode => Object.hash(runtimeType,cause);

@override
String toString() {
  return 'SearchFailure.indexCorrupted(cause: $cause)';
}


}

/// @nodoc
abstract mixin class $SearchIndexCorruptedCopyWith<$Res> implements $SearchFailureCopyWith<$Res> {
  factory $SearchIndexCorruptedCopyWith(SearchIndexCorrupted value, $Res Function(SearchIndexCorrupted) _then) = _$SearchIndexCorruptedCopyWithImpl;
@override @useResult
$Res call({
 AppFailure? cause
});




}
/// @nodoc
class _$SearchIndexCorruptedCopyWithImpl<$Res>
    implements $SearchIndexCorruptedCopyWith<$Res> {
  _$SearchIndexCorruptedCopyWithImpl(this._self, this._then);

  final SearchIndexCorrupted _self;
  final $Res Function(SearchIndexCorrupted) _then;

/// Create a copy of SearchFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? cause = freezed,}) {
  return _then(SearchIndexCorrupted(
cause: freezed == cause ? _self.cause : cause // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}


}

// dart format on
