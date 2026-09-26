// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_index_failure.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SearchIndexFailure {

/// What it reported, verbatim. For diagnostics — never parsed.
 String get description; AppFailure? get cause;
/// Create a copy of SearchIndexFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchIndexFailureCopyWith<SearchIndexFailure> get copyWith => _$SearchIndexFailureCopyWithImpl<SearchIndexFailure>(this as SearchIndexFailure, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchIndexFailure&&(identical(other.description, description) || other.description == description)&&(identical(other.cause, cause) || other.cause == cause));
}


@override
int get hashCode => Object.hash(runtimeType,description,cause);

@override
String toString() {
  return 'SearchIndexFailure(description: $description, cause: $cause)';
}


}

/// @nodoc
abstract mixin class $SearchIndexFailureCopyWith<$Res>  {
  factory $SearchIndexFailureCopyWith(SearchIndexFailure value, $Res Function(SearchIndexFailure) _then) = _$SearchIndexFailureCopyWithImpl;
@useResult
$Res call({
 String description, AppFailure? cause
});




}
/// @nodoc
class _$SearchIndexFailureCopyWithImpl<$Res>
    implements $SearchIndexFailureCopyWith<$Res> {
  _$SearchIndexFailureCopyWithImpl(this._self, this._then);

  final SearchIndexFailure _self;
  final $Res Function(SearchIndexFailure) _then;

/// Create a copy of SearchIndexFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? description = null,Object? cause = freezed,}) {
  return _then(_self.copyWith(
description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,cause: freezed == cause ? _self.cause : cause // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}

}


/// Adds pattern-matching-related methods to [SearchIndexFailure].
extension SearchIndexFailurePatterns on SearchIndexFailure {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( SearchIndexFailed value)?  failed,required TResult orElse(),}){
final _that = this;
switch (_that) {
case SearchIndexFailed() when failed != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( SearchIndexFailed value)  failed,}){
final _that = this;
switch (_that) {
case SearchIndexFailed():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( SearchIndexFailed value)?  failed,}){
final _that = this;
switch (_that) {
case SearchIndexFailed() when failed != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String description,  AppFailure? cause)?  failed,required TResult orElse(),}) {final _that = this;
switch (_that) {
case SearchIndexFailed() when failed != null:
return failed(_that.description,_that.cause);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String description,  AppFailure? cause)  failed,}) {final _that = this;
switch (_that) {
case SearchIndexFailed():
return failed(_that.description,_that.cause);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String description,  AppFailure? cause)?  failed,}) {final _that = this;
switch (_that) {
case SearchIndexFailed() when failed != null:
return failed(_that.description,_that.cause);case _:
  return null;

}
}

}

/// @nodoc


class SearchIndexFailed implements SearchIndexFailure {
  const SearchIndexFailed(this.description, {this.cause});
  

/// What it reported, verbatim. For diagnostics — never parsed.
@override final  String description;
@override final  AppFailure? cause;

/// Create a copy of SearchIndexFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchIndexFailedCopyWith<SearchIndexFailed> get copyWith => _$SearchIndexFailedCopyWithImpl<SearchIndexFailed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchIndexFailed&&(identical(other.description, description) || other.description == description)&&(identical(other.cause, cause) || other.cause == cause));
}


@override
int get hashCode => Object.hash(runtimeType,description,cause);

@override
String toString() {
  return 'SearchIndexFailure.failed(description: $description, cause: $cause)';
}


}

/// @nodoc
abstract mixin class $SearchIndexFailedCopyWith<$Res> implements $SearchIndexFailureCopyWith<$Res> {
  factory $SearchIndexFailedCopyWith(SearchIndexFailed value, $Res Function(SearchIndexFailed) _then) = _$SearchIndexFailedCopyWithImpl;
@override @useResult
$Res call({
 String description, AppFailure? cause
});




}
/// @nodoc
class _$SearchIndexFailedCopyWithImpl<$Res>
    implements $SearchIndexFailedCopyWith<$Res> {
  _$SearchIndexFailedCopyWithImpl(this._self, this._then);

  final SearchIndexFailed _self;
  final $Res Function(SearchIndexFailed) _then;

/// Create a copy of SearchIndexFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? description = null,Object? cause = freezed,}) {
  return _then(SearchIndexFailed(
null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,cause: freezed == cause ? _self.cause : cause // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}


}

// dart format on
