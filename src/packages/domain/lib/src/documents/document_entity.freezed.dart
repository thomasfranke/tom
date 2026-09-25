// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'document_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DocumentEntity {

/// Where the file is, relative to the space root; the document's identity.
 SpaceRelativePathValueObject get path;/// The raw markdown source, exactly as it was read.
///
/// Never normalized: a line ending or trailing newline changed on the way
/// through is a diff the user did not make.
 String get content;
/// Create a copy of DocumentEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DocumentEntityCopyWith<DocumentEntity> get copyWith => _$DocumentEntityCopyWithImpl<DocumentEntity>(this as DocumentEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DocumentEntity&&(identical(other.path, path) || other.path == path)&&(identical(other.content, content) || other.content == content));
}


@override
int get hashCode => Object.hash(runtimeType,path,content);

@override
String toString() {
  return 'DocumentEntity(path: $path, content: $content)';
}


}

/// @nodoc
abstract mixin class $DocumentEntityCopyWith<$Res>  {
  factory $DocumentEntityCopyWith(DocumentEntity value, $Res Function(DocumentEntity) _then) = _$DocumentEntityCopyWithImpl;
@useResult
$Res call({
 SpaceRelativePathValueObject path, String content
});




}
/// @nodoc
class _$DocumentEntityCopyWithImpl<$Res>
    implements $DocumentEntityCopyWith<$Res> {
  _$DocumentEntityCopyWithImpl(this._self, this._then);

  final DocumentEntity _self;
  final $Res Function(DocumentEntity) _then;

/// Create a copy of DocumentEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? path = null,Object? content = null,}) {
  return _then(_self.copyWith(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as SpaceRelativePathValueObject,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [DocumentEntity].
extension DocumentEntityPatterns on DocumentEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DocumentEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DocumentEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DocumentEntity value)  $default,){
final _that = this;
switch (_that) {
case _DocumentEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DocumentEntity value)?  $default,){
final _that = this;
switch (_that) {
case _DocumentEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SpaceRelativePathValueObject path,  String content)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DocumentEntity() when $default != null:
return $default(_that.path,_that.content);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SpaceRelativePathValueObject path,  String content)  $default,) {final _that = this;
switch (_that) {
case _DocumentEntity():
return $default(_that.path,_that.content);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SpaceRelativePathValueObject path,  String content)?  $default,) {final _that = this;
switch (_that) {
case _DocumentEntity() when $default != null:
return $default(_that.path,_that.content);case _:
  return null;

}
}

}

/// @nodoc


class _DocumentEntity extends DocumentEntity {
  const _DocumentEntity({required this.path, required this.content}): super._();
  

/// Where the file is, relative to the space root; the document's identity.
@override final  SpaceRelativePathValueObject path;
/// The raw markdown source, exactly as it was read.
///
/// Never normalized: a line ending or trailing newline changed on the way
/// through is a diff the user did not make.
@override final  String content;

/// Create a copy of DocumentEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DocumentEntityCopyWith<_DocumentEntity> get copyWith => __$DocumentEntityCopyWithImpl<_DocumentEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DocumentEntity&&(identical(other.path, path) || other.path == path)&&(identical(other.content, content) || other.content == content));
}


@override
int get hashCode => Object.hash(runtimeType,path,content);

@override
String toString() {
  return 'DocumentEntity(path: $path, content: $content)';
}


}

/// @nodoc
abstract mixin class _$DocumentEntityCopyWith<$Res> implements $DocumentEntityCopyWith<$Res> {
  factory _$DocumentEntityCopyWith(_DocumentEntity value, $Res Function(_DocumentEntity) _then) = __$DocumentEntityCopyWithImpl;
@override @useResult
$Res call({
 SpaceRelativePathValueObject path, String content
});




}
/// @nodoc
class __$DocumentEntityCopyWithImpl<$Res>
    implements _$DocumentEntityCopyWith<$Res> {
  __$DocumentEntityCopyWithImpl(this._self, this._then);

  final _DocumentEntity _self;
  final $Res Function(_DocumentEntity) _then;

/// Create a copy of DocumentEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? path = null,Object? content = null,}) {
  return _then(_DocumentEntity(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as SpaceRelativePathValueObject,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
