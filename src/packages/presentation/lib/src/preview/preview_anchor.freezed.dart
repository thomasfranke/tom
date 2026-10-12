// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'preview_anchor.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PreviewAnchor {

/// The document the heading is looked for in.
 SpaceRelativePathValueObject get document;/// What was written after the `#`.
 String get anchor;
/// Create a copy of PreviewAnchor
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PreviewAnchorCopyWith<PreviewAnchor> get copyWith => _$PreviewAnchorCopyWithImpl<PreviewAnchor>(this as PreviewAnchor, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PreviewAnchor&&(identical(other.document, document) || other.document == document)&&(identical(other.anchor, anchor) || other.anchor == anchor));
}


@override
int get hashCode => Object.hash(runtimeType,document,anchor);

@override
String toString() {
  return 'PreviewAnchor(document: $document, anchor: $anchor)';
}


}

/// @nodoc
abstract mixin class $PreviewAnchorCopyWith<$Res>  {
  factory $PreviewAnchorCopyWith(PreviewAnchor value, $Res Function(PreviewAnchor) _then) = _$PreviewAnchorCopyWithImpl;
@useResult
$Res call({
 SpaceRelativePathValueObject document, String anchor
});




}
/// @nodoc
class _$PreviewAnchorCopyWithImpl<$Res>
    implements $PreviewAnchorCopyWith<$Res> {
  _$PreviewAnchorCopyWithImpl(this._self, this._then);

  final PreviewAnchor _self;
  final $Res Function(PreviewAnchor) _then;

/// Create a copy of PreviewAnchor
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? document = null,Object? anchor = null,}) {
  return _then(_self.copyWith(
document: null == document ? _self.document : document // ignore: cast_nullable_to_non_nullable
as SpaceRelativePathValueObject,anchor: null == anchor ? _self.anchor : anchor // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PreviewAnchor].
extension PreviewAnchorPatterns on PreviewAnchor {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PreviewAnchor value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PreviewAnchor() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PreviewAnchor value)  $default,){
final _that = this;
switch (_that) {
case _PreviewAnchor():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PreviewAnchor value)?  $default,){
final _that = this;
switch (_that) {
case _PreviewAnchor() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SpaceRelativePathValueObject document,  String anchor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PreviewAnchor() when $default != null:
return $default(_that.document,_that.anchor);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SpaceRelativePathValueObject document,  String anchor)  $default,) {final _that = this;
switch (_that) {
case _PreviewAnchor():
return $default(_that.document,_that.anchor);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SpaceRelativePathValueObject document,  String anchor)?  $default,) {final _that = this;
switch (_that) {
case _PreviewAnchor() when $default != null:
return $default(_that.document,_that.anchor);case _:
  return null;

}
}

}

/// @nodoc


class _PreviewAnchor implements PreviewAnchor {
  const _PreviewAnchor({required this.document, required this.anchor});
  

/// The document the heading is looked for in.
@override final  SpaceRelativePathValueObject document;
/// What was written after the `#`.
@override final  String anchor;

/// Create a copy of PreviewAnchor
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PreviewAnchorCopyWith<_PreviewAnchor> get copyWith => __$PreviewAnchorCopyWithImpl<_PreviewAnchor>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PreviewAnchor&&(identical(other.document, document) || other.document == document)&&(identical(other.anchor, anchor) || other.anchor == anchor));
}


@override
int get hashCode => Object.hash(runtimeType,document,anchor);

@override
String toString() {
  return 'PreviewAnchor(document: $document, anchor: $anchor)';
}


}

/// @nodoc
abstract mixin class _$PreviewAnchorCopyWith<$Res> implements $PreviewAnchorCopyWith<$Res> {
  factory _$PreviewAnchorCopyWith(_PreviewAnchor value, $Res Function(_PreviewAnchor) _then) = __$PreviewAnchorCopyWithImpl;
@override @useResult
$Res call({
 SpaceRelativePathValueObject document, String anchor
});




}
/// @nodoc
class __$PreviewAnchorCopyWithImpl<$Res>
    implements _$PreviewAnchorCopyWith<$Res> {
  __$PreviewAnchorCopyWithImpl(this._self, this._then);

  final _PreviewAnchor _self;
  final $Res Function(_PreviewAnchor) _then;

/// Create a copy of PreviewAnchor
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? document = null,Object? anchor = null,}) {
  return _then(_PreviewAnchor(
document: null == document ? _self.document : document // ignore: cast_nullable_to_non_nullable
as SpaceRelativePathValueObject,anchor: null == anchor ? _self.anchor : anchor // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
