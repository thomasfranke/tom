// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'text_differ_failure.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TextDifferFailure {

/// What it reported, verbatim. For diagnostics — never parsed.
 String get description; AppFailure? get cause;
/// Create a copy of TextDifferFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TextDifferFailureCopyWith<TextDifferFailure> get copyWith => _$TextDifferFailureCopyWithImpl<TextDifferFailure>(this as TextDifferFailure, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TextDifferFailure&&(identical(other.description, description) || other.description == description)&&(identical(other.cause, cause) || other.cause == cause));
}


@override
int get hashCode => Object.hash(runtimeType,description,cause);

@override
String toString() {
  return 'TextDifferFailure(description: $description, cause: $cause)';
}


}

/// @nodoc
abstract mixin class $TextDifferFailureCopyWith<$Res>  {
  factory $TextDifferFailureCopyWith(TextDifferFailure value, $Res Function(TextDifferFailure) _then) = _$TextDifferFailureCopyWithImpl;
@useResult
$Res call({
 String description, AppFailure? cause
});




}
/// @nodoc
class _$TextDifferFailureCopyWithImpl<$Res>
    implements $TextDifferFailureCopyWith<$Res> {
  _$TextDifferFailureCopyWithImpl(this._self, this._then);

  final TextDifferFailure _self;
  final $Res Function(TextDifferFailure) _then;

/// Create a copy of TextDifferFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? description = null,Object? cause = freezed,}) {
  return _then(_self.copyWith(
description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,cause: freezed == cause ? _self.cause : cause // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}

}


/// Adds pattern-matching-related methods to [TextDifferFailure].
extension TextDifferFailurePatterns on TextDifferFailure {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( TextDifferFailed value)?  failed,required TResult orElse(),}){
final _that = this;
switch (_that) {
case TextDifferFailed() when failed != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( TextDifferFailed value)  failed,}){
final _that = this;
switch (_that) {
case TextDifferFailed():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( TextDifferFailed value)?  failed,}){
final _that = this;
switch (_that) {
case TextDifferFailed() when failed != null:
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
case TextDifferFailed() when failed != null:
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
case TextDifferFailed():
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
case TextDifferFailed() when failed != null:
return failed(_that.description,_that.cause);case _:
  return null;

}
}

}

/// @nodoc


class TextDifferFailed implements TextDifferFailure {
  const TextDifferFailed(this.description, {this.cause});
  

/// What it reported, verbatim. For diagnostics — never parsed.
@override final  String description;
@override final  AppFailure? cause;

/// Create a copy of TextDifferFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TextDifferFailedCopyWith<TextDifferFailed> get copyWith => _$TextDifferFailedCopyWithImpl<TextDifferFailed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TextDifferFailed&&(identical(other.description, description) || other.description == description)&&(identical(other.cause, cause) || other.cause == cause));
}


@override
int get hashCode => Object.hash(runtimeType,description,cause);

@override
String toString() {
  return 'TextDifferFailure.failed(description: $description, cause: $cause)';
}


}

/// @nodoc
abstract mixin class $TextDifferFailedCopyWith<$Res> implements $TextDifferFailureCopyWith<$Res> {
  factory $TextDifferFailedCopyWith(TextDifferFailed value, $Res Function(TextDifferFailed) _then) = _$TextDifferFailedCopyWithImpl;
@override @useResult
$Res call({
 String description, AppFailure? cause
});




}
/// @nodoc
class _$TextDifferFailedCopyWithImpl<$Res>
    implements $TextDifferFailedCopyWith<$Res> {
  _$TextDifferFailedCopyWithImpl(this._self, this._then);

  final TextDifferFailed _self;
  final $Res Function(TextDifferFailed) _then;

/// Create a copy of TextDifferFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? description = null,Object? cause = freezed,}) {
  return _then(TextDifferFailed(
null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,cause: freezed == cause ? _self.cause : cause // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}


}

// dart format on
