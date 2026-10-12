// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'file_content_value_object.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FileContentValueObject {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FileContentValueObject);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'FileContentValueObject()';
}


}

/// @nodoc
class $FileContentValueObjectCopyWith<$Res>  {
$FileContentValueObjectCopyWith(FileContentValueObject _, $Res Function(FileContentValueObject) __);
}


/// Adds pattern-matching-related methods to [FileContentValueObject].
extension FileContentValueObjectPatterns on FileContentValueObject {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( FileContentText value)?  text,TResult Function( FileContentBinary value)?  binary,required TResult orElse(),}){
final _that = this;
switch (_that) {
case FileContentText() when text != null:
return text(_that);case FileContentBinary() when binary != null:
return binary(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( FileContentText value)  text,required TResult Function( FileContentBinary value)  binary,}){
final _that = this;
switch (_that) {
case FileContentText():
return text(_that);case FileContentBinary():
return binary(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( FileContentText value)?  text,TResult? Function( FileContentBinary value)?  binary,}){
final _that = this;
switch (_that) {
case FileContentText() when text != null:
return text(_that);case FileContentBinary() when binary != null:
return binary(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( DocumentEntity document)?  text,TResult Function()?  binary,required TResult orElse(),}) {final _that = this;
switch (_that) {
case FileContentText() when text != null:
return text(_that.document);case FileContentBinary() when binary != null:
return binary();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( DocumentEntity document)  text,required TResult Function()  binary,}) {final _that = this;
switch (_that) {
case FileContentText():
return text(_that.document);case FileContentBinary():
return binary();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( DocumentEntity document)?  text,TResult? Function()?  binary,}) {final _that = this;
switch (_that) {
case FileContentText() when text != null:
return text(_that.document);case FileContentBinary() when binary != null:
return binary();case _:
  return null;

}
}

}

/// @nodoc


class FileContentText extends FileContentValueObject {
  const FileContentText(this.document): super._();
  

 final  DocumentEntity document;

/// Create a copy of FileContentValueObject
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FileContentTextCopyWith<FileContentText> get copyWith => _$FileContentTextCopyWithImpl<FileContentText>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FileContentText&&(identical(other.document, document) || other.document == document));
}


@override
int get hashCode => Object.hash(runtimeType,document);

@override
String toString() {
  return 'FileContentValueObject.text(document: $document)';
}


}

/// @nodoc
abstract mixin class $FileContentTextCopyWith<$Res> implements $FileContentValueObjectCopyWith<$Res> {
  factory $FileContentTextCopyWith(FileContentText value, $Res Function(FileContentText) _then) = _$FileContentTextCopyWithImpl;
@useResult
$Res call({
 DocumentEntity document
});


$DocumentEntityCopyWith<$Res> get document;

}
/// @nodoc
class _$FileContentTextCopyWithImpl<$Res>
    implements $FileContentTextCopyWith<$Res> {
  _$FileContentTextCopyWithImpl(this._self, this._then);

  final FileContentText _self;
  final $Res Function(FileContentText) _then;

/// Create a copy of FileContentValueObject
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? document = null,}) {
  return _then(FileContentText(
null == document ? _self.document : document // ignore: cast_nullable_to_non_nullable
as DocumentEntity,
  ));
}

/// Create a copy of FileContentValueObject
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DocumentEntityCopyWith<$Res> get document {
  
  return $DocumentEntityCopyWith<$Res>(_self.document, (value) {
    return _then(_self.copyWith(document: value));
  });
}
}

/// @nodoc


class FileContentBinary extends FileContentValueObject {
  const FileContentBinary(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FileContentBinary);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'FileContentValueObject.binary()';
}


}




// dart format on
