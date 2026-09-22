// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'markdown_parser_failure.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MarkdownParserFailure {

/// What it reported, verbatim. For diagnostics — never parsed.
 String get description;
/// Create a copy of MarkdownParserFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MarkdownParserFailureCopyWith<MarkdownParserFailure> get copyWith => _$MarkdownParserFailureCopyWithImpl<MarkdownParserFailure>(this as MarkdownParserFailure, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MarkdownParserFailure&&(identical(other.description, description) || other.description == description));
}


@override
int get hashCode => Object.hash(runtimeType,description);

@override
String toString() {
  return 'MarkdownParserFailure(description: $description)';
}


}

/// @nodoc
abstract mixin class $MarkdownParserFailureCopyWith<$Res>  {
  factory $MarkdownParserFailureCopyWith(MarkdownParserFailure value, $Res Function(MarkdownParserFailure) _then) = _$MarkdownParserFailureCopyWithImpl;
@useResult
$Res call({
 String description
});




}
/// @nodoc
class _$MarkdownParserFailureCopyWithImpl<$Res>
    implements $MarkdownParserFailureCopyWith<$Res> {
  _$MarkdownParserFailureCopyWithImpl(this._self, this._then);

  final MarkdownParserFailure _self;
  final $Res Function(MarkdownParserFailure) _then;

/// Create a copy of MarkdownParserFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? description = null,}) {
  return _then(_self.copyWith(
description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MarkdownParserFailure].
extension MarkdownParserFailurePatterns on MarkdownParserFailure {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( MarkdownParserFailed value)?  failed,required TResult orElse(),}){
final _that = this;
switch (_that) {
case MarkdownParserFailed() when failed != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( MarkdownParserFailed value)  failed,}){
final _that = this;
switch (_that) {
case MarkdownParserFailed():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( MarkdownParserFailed value)?  failed,}){
final _that = this;
switch (_that) {
case MarkdownParserFailed() when failed != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String description)?  failed,required TResult orElse(),}) {final _that = this;
switch (_that) {
case MarkdownParserFailed() when failed != null:
return failed(_that.description);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String description)  failed,}) {final _that = this;
switch (_that) {
case MarkdownParserFailed():
return failed(_that.description);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String description)?  failed,}) {final _that = this;
switch (_that) {
case MarkdownParserFailed() when failed != null:
return failed(_that.description);case _:
  return null;

}
}

}

/// @nodoc


class MarkdownParserFailed implements MarkdownParserFailure {
  const MarkdownParserFailed(this.description);
  

/// What it reported, verbatim. For diagnostics — never parsed.
@override final  String description;

/// Create a copy of MarkdownParserFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MarkdownParserFailedCopyWith<MarkdownParserFailed> get copyWith => _$MarkdownParserFailedCopyWithImpl<MarkdownParserFailed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MarkdownParserFailed&&(identical(other.description, description) || other.description == description));
}


@override
int get hashCode => Object.hash(runtimeType,description);

@override
String toString() {
  return 'MarkdownParserFailure.failed(description: $description)';
}


}

/// @nodoc
abstract mixin class $MarkdownParserFailedCopyWith<$Res> implements $MarkdownParserFailureCopyWith<$Res> {
  factory $MarkdownParserFailedCopyWith(MarkdownParserFailed value, $Res Function(MarkdownParserFailed) _then) = _$MarkdownParserFailedCopyWithImpl;
@override @useResult
$Res call({
 String description
});




}
/// @nodoc
class _$MarkdownParserFailedCopyWithImpl<$Res>
    implements $MarkdownParserFailedCopyWith<$Res> {
  _$MarkdownParserFailedCopyWithImpl(this._self, this._then);

  final MarkdownParserFailed _self;
  final $Res Function(MarkdownParserFailed) _then;

/// Create a copy of MarkdownParserFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? description = null,}) {
  return _then(MarkdownParserFailed(
null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
