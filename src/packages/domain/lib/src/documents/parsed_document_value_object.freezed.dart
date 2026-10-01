// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'parsed_document_value_object.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ParsedDocumentValueObject {

/// The document these blocks came from, source and all.
 DocumentEntity get document;/// The top-level blocks, in document order.
///
/// Handed over unmodifiable, never copied: Freezed compares collections
/// element-wise and copies nothing.
 List<BlockValueObject> get blocks;/// Every link reference definition in the document, as its own lines, so
/// `[text][ref]` resolves in a block that does not hold the definition.
 String get linkDefinitions;/// Every footnote, in citation order.
///
/// Structured where [linkDefinitions] is a string, because the two are
/// used differently: a definition is appended to a block and parsed
/// again, while a footnote is **drawn** — its number in the prose and its
/// text at the foot — and drawing needs the parts apart
/// ([Decision 31](../../../../../../docs/technical/decisions/031-where-a-footnotes-text-goes.md)).
 List<FootnoteValueObject> get footnotes;
/// Create a copy of ParsedDocumentValueObject
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ParsedDocumentValueObjectCopyWith<ParsedDocumentValueObject> get copyWith => _$ParsedDocumentValueObjectCopyWithImpl<ParsedDocumentValueObject>(this as ParsedDocumentValueObject, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ParsedDocumentValueObject&&(identical(other.document, document) || other.document == document)&&const DeepCollectionEquality().equals(other.blocks, blocks)&&(identical(other.linkDefinitions, linkDefinitions) || other.linkDefinitions == linkDefinitions)&&const DeepCollectionEquality().equals(other.footnotes, footnotes));
}


@override
int get hashCode => Object.hash(runtimeType,document,const DeepCollectionEquality().hash(blocks),linkDefinitions,const DeepCollectionEquality().hash(footnotes));

@override
String toString() {
  return 'ParsedDocumentValueObject(document: $document, blocks: $blocks, linkDefinitions: $linkDefinitions, footnotes: $footnotes)';
}


}

/// @nodoc
abstract mixin class $ParsedDocumentValueObjectCopyWith<$Res>  {
  factory $ParsedDocumentValueObjectCopyWith(ParsedDocumentValueObject value, $Res Function(ParsedDocumentValueObject) _then) = _$ParsedDocumentValueObjectCopyWithImpl;
@useResult
$Res call({
 DocumentEntity document, List<BlockValueObject> blocks, String linkDefinitions, List<FootnoteValueObject> footnotes
});


$DocumentEntityCopyWith<$Res> get document;

}
/// @nodoc
class _$ParsedDocumentValueObjectCopyWithImpl<$Res>
    implements $ParsedDocumentValueObjectCopyWith<$Res> {
  _$ParsedDocumentValueObjectCopyWithImpl(this._self, this._then);

  final ParsedDocumentValueObject _self;
  final $Res Function(ParsedDocumentValueObject) _then;

/// Create a copy of ParsedDocumentValueObject
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? document = null,Object? blocks = null,Object? linkDefinitions = null,Object? footnotes = null,}) {
  return _then(_self.copyWith(
document: null == document ? _self.document : document // ignore: cast_nullable_to_non_nullable
as DocumentEntity,blocks: null == blocks ? _self.blocks : blocks // ignore: cast_nullable_to_non_nullable
as List<BlockValueObject>,linkDefinitions: null == linkDefinitions ? _self.linkDefinitions : linkDefinitions // ignore: cast_nullable_to_non_nullable
as String,footnotes: null == footnotes ? _self.footnotes : footnotes // ignore: cast_nullable_to_non_nullable
as List<FootnoteValueObject>,
  ));
}
/// Create a copy of ParsedDocumentValueObject
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DocumentEntityCopyWith<$Res> get document {
  
  return $DocumentEntityCopyWith<$Res>(_self.document, (value) {
    return _then(_self.copyWith(document: value));
  });
}
}


/// Adds pattern-matching-related methods to [ParsedDocumentValueObject].
extension ParsedDocumentValueObjectPatterns on ParsedDocumentValueObject {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ParsedDocumentValueObject value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ParsedDocumentValueObject() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ParsedDocumentValueObject value)  $default,){
final _that = this;
switch (_that) {
case _ParsedDocumentValueObject():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ParsedDocumentValueObject value)?  $default,){
final _that = this;
switch (_that) {
case _ParsedDocumentValueObject() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DocumentEntity document,  List<BlockValueObject> blocks,  String linkDefinitions,  List<FootnoteValueObject> footnotes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ParsedDocumentValueObject() when $default != null:
return $default(_that.document,_that.blocks,_that.linkDefinitions,_that.footnotes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DocumentEntity document,  List<BlockValueObject> blocks,  String linkDefinitions,  List<FootnoteValueObject> footnotes)  $default,) {final _that = this;
switch (_that) {
case _ParsedDocumentValueObject():
return $default(_that.document,_that.blocks,_that.linkDefinitions,_that.footnotes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DocumentEntity document,  List<BlockValueObject> blocks,  String linkDefinitions,  List<FootnoteValueObject> footnotes)?  $default,) {final _that = this;
switch (_that) {
case _ParsedDocumentValueObject() when $default != null:
return $default(_that.document,_that.blocks,_that.linkDefinitions,_that.footnotes);case _:
  return null;

}
}

}

/// @nodoc


class _ParsedDocumentValueObject implements ParsedDocumentValueObject {
  const _ParsedDocumentValueObject({required this.document, required final  List<BlockValueObject> blocks, required this.linkDefinitions, final  List<FootnoteValueObject> footnotes = const <FootnoteValueObject>[]}): _blocks = blocks,_footnotes = footnotes;
  

/// The document these blocks came from, source and all.
@override final  DocumentEntity document;
/// The top-level blocks, in document order.
///
/// Handed over unmodifiable, never copied: Freezed compares collections
/// element-wise and copies nothing.
 final  List<BlockValueObject> _blocks;
/// The top-level blocks, in document order.
///
/// Handed over unmodifiable, never copied: Freezed compares collections
/// element-wise and copies nothing.
@override List<BlockValueObject> get blocks {
  if (_blocks is EqualUnmodifiableListView) return _blocks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_blocks);
}

/// Every link reference definition in the document, as its own lines, so
/// `[text][ref]` resolves in a block that does not hold the definition.
@override final  String linkDefinitions;
/// Every footnote, in citation order.
///
/// Structured where [linkDefinitions] is a string, because the two are
/// used differently: a definition is appended to a block and parsed
/// again, while a footnote is **drawn** — its number in the prose and its
/// text at the foot — and drawing needs the parts apart
/// ([Decision 31](../../../../../../docs/technical/decisions/031-where-a-footnotes-text-goes.md)).
 final  List<FootnoteValueObject> _footnotes;
/// Every footnote, in citation order.
///
/// Structured where [linkDefinitions] is a string, because the two are
/// used differently: a definition is appended to a block and parsed
/// again, while a footnote is **drawn** — its number in the prose and its
/// text at the foot — and drawing needs the parts apart
/// ([Decision 31](../../../../../../docs/technical/decisions/031-where-a-footnotes-text-goes.md)).
@override@JsonKey() List<FootnoteValueObject> get footnotes {
  if (_footnotes is EqualUnmodifiableListView) return _footnotes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_footnotes);
}


/// Create a copy of ParsedDocumentValueObject
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ParsedDocumentValueObjectCopyWith<_ParsedDocumentValueObject> get copyWith => __$ParsedDocumentValueObjectCopyWithImpl<_ParsedDocumentValueObject>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ParsedDocumentValueObject&&(identical(other.document, document) || other.document == document)&&const DeepCollectionEquality().equals(other._blocks, _blocks)&&(identical(other.linkDefinitions, linkDefinitions) || other.linkDefinitions == linkDefinitions)&&const DeepCollectionEquality().equals(other._footnotes, _footnotes));
}


@override
int get hashCode => Object.hash(runtimeType,document,const DeepCollectionEquality().hash(_blocks),linkDefinitions,const DeepCollectionEquality().hash(_footnotes));

@override
String toString() {
  return 'ParsedDocumentValueObject(document: $document, blocks: $blocks, linkDefinitions: $linkDefinitions, footnotes: $footnotes)';
}


}

/// @nodoc
abstract mixin class _$ParsedDocumentValueObjectCopyWith<$Res> implements $ParsedDocumentValueObjectCopyWith<$Res> {
  factory _$ParsedDocumentValueObjectCopyWith(_ParsedDocumentValueObject value, $Res Function(_ParsedDocumentValueObject) _then) = __$ParsedDocumentValueObjectCopyWithImpl;
@override @useResult
$Res call({
 DocumentEntity document, List<BlockValueObject> blocks, String linkDefinitions, List<FootnoteValueObject> footnotes
});


@override $DocumentEntityCopyWith<$Res> get document;

}
/// @nodoc
class __$ParsedDocumentValueObjectCopyWithImpl<$Res>
    implements _$ParsedDocumentValueObjectCopyWith<$Res> {
  __$ParsedDocumentValueObjectCopyWithImpl(this._self, this._then);

  final _ParsedDocumentValueObject _self;
  final $Res Function(_ParsedDocumentValueObject) _then;

/// Create a copy of ParsedDocumentValueObject
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? document = null,Object? blocks = null,Object? linkDefinitions = null,Object? footnotes = null,}) {
  return _then(_ParsedDocumentValueObject(
document: null == document ? _self.document : document // ignore: cast_nullable_to_non_nullable
as DocumentEntity,blocks: null == blocks ? _self._blocks : blocks // ignore: cast_nullable_to_non_nullable
as List<BlockValueObject>,linkDefinitions: null == linkDefinitions ? _self.linkDefinitions : linkDefinitions // ignore: cast_nullable_to_non_nullable
as String,footnotes: null == footnotes ? _self._footnotes : footnotes // ignore: cast_nullable_to_non_nullable
as List<FootnoteValueObject>,
  ));
}

/// Create a copy of ParsedDocumentValueObject
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DocumentEntityCopyWith<$Res> get document {
  
  return $DocumentEntityCopyWith<$Res>(_self.document, (value) {
    return _then(_self.copyWith(document: value));
  });
}
}

// dart format on
