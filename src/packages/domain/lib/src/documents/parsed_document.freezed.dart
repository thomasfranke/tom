// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'parsed_document.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ParsedDocument {

/// The document these blocks came from, source and all.
 Document get document;/// The top-level blocks, in document order.
///
/// Handed over unmodifiable, never copied: Freezed compares collections
/// element-wise and copies nothing.
 List<Block> get blocks;/// Every link reference definition in the document, as its own lines.
///
/// What makes `[text][ref]` resolve in a block that does not hold the
/// definition. **Footnotes do not survive the same way** and are M2's
/// problem, with a failing case waiting in Decision 19.
 String get linkDefinitions;
/// Create a copy of ParsedDocument
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ParsedDocumentCopyWith<ParsedDocument> get copyWith => _$ParsedDocumentCopyWithImpl<ParsedDocument>(this as ParsedDocument, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ParsedDocument&&(identical(other.document, document) || other.document == document)&&const DeepCollectionEquality().equals(other.blocks, blocks)&&(identical(other.linkDefinitions, linkDefinitions) || other.linkDefinitions == linkDefinitions));
}


@override
int get hashCode => Object.hash(runtimeType,document,const DeepCollectionEquality().hash(blocks),linkDefinitions);

@override
String toString() {
  return 'ParsedDocument(document: $document, blocks: $blocks, linkDefinitions: $linkDefinitions)';
}


}

/// @nodoc
abstract mixin class $ParsedDocumentCopyWith<$Res>  {
  factory $ParsedDocumentCopyWith(ParsedDocument value, $Res Function(ParsedDocument) _then) = _$ParsedDocumentCopyWithImpl;
@useResult
$Res call({
 Document document, List<Block> blocks, String linkDefinitions
});


$DocumentCopyWith<$Res> get document;

}
/// @nodoc
class _$ParsedDocumentCopyWithImpl<$Res>
    implements $ParsedDocumentCopyWith<$Res> {
  _$ParsedDocumentCopyWithImpl(this._self, this._then);

  final ParsedDocument _self;
  final $Res Function(ParsedDocument) _then;

/// Create a copy of ParsedDocument
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? document = null,Object? blocks = null,Object? linkDefinitions = null,}) {
  return _then(_self.copyWith(
document: null == document ? _self.document : document // ignore: cast_nullable_to_non_nullable
as Document,blocks: null == blocks ? _self.blocks : blocks // ignore: cast_nullable_to_non_nullable
as List<Block>,linkDefinitions: null == linkDefinitions ? _self.linkDefinitions : linkDefinitions // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of ParsedDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DocumentCopyWith<$Res> get document {
  
  return $DocumentCopyWith<$Res>(_self.document, (value) {
    return _then(_self.copyWith(document: value));
  });
}
}


/// Adds pattern-matching-related methods to [ParsedDocument].
extension ParsedDocumentPatterns on ParsedDocument {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ParsedDocument value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ParsedDocument() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ParsedDocument value)  $default,){
final _that = this;
switch (_that) {
case _ParsedDocument():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ParsedDocument value)?  $default,){
final _that = this;
switch (_that) {
case _ParsedDocument() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Document document,  List<Block> blocks,  String linkDefinitions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ParsedDocument() when $default != null:
return $default(_that.document,_that.blocks,_that.linkDefinitions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Document document,  List<Block> blocks,  String linkDefinitions)  $default,) {final _that = this;
switch (_that) {
case _ParsedDocument():
return $default(_that.document,_that.blocks,_that.linkDefinitions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Document document,  List<Block> blocks,  String linkDefinitions)?  $default,) {final _that = this;
switch (_that) {
case _ParsedDocument() when $default != null:
return $default(_that.document,_that.blocks,_that.linkDefinitions);case _:
  return null;

}
}

}

/// @nodoc


class _ParsedDocument implements ParsedDocument {
  const _ParsedDocument({required this.document, required final  List<Block> blocks, required this.linkDefinitions}): _blocks = blocks;
  

/// The document these blocks came from, source and all.
@override final  Document document;
/// The top-level blocks, in document order.
///
/// Handed over unmodifiable, never copied: Freezed compares collections
/// element-wise and copies nothing.
 final  List<Block> _blocks;
/// The top-level blocks, in document order.
///
/// Handed over unmodifiable, never copied: Freezed compares collections
/// element-wise and copies nothing.
@override List<Block> get blocks {
  if (_blocks is EqualUnmodifiableListView) return _blocks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_blocks);
}

/// Every link reference definition in the document, as its own lines.
///
/// What makes `[text][ref]` resolve in a block that does not hold the
/// definition. **Footnotes do not survive the same way** and are M2's
/// problem, with a failing case waiting in Decision 19.
@override final  String linkDefinitions;

/// Create a copy of ParsedDocument
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ParsedDocumentCopyWith<_ParsedDocument> get copyWith => __$ParsedDocumentCopyWithImpl<_ParsedDocument>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ParsedDocument&&(identical(other.document, document) || other.document == document)&&const DeepCollectionEquality().equals(other._blocks, _blocks)&&(identical(other.linkDefinitions, linkDefinitions) || other.linkDefinitions == linkDefinitions));
}


@override
int get hashCode => Object.hash(runtimeType,document,const DeepCollectionEquality().hash(_blocks),linkDefinitions);

@override
String toString() {
  return 'ParsedDocument(document: $document, blocks: $blocks, linkDefinitions: $linkDefinitions)';
}


}

/// @nodoc
abstract mixin class _$ParsedDocumentCopyWith<$Res> implements $ParsedDocumentCopyWith<$Res> {
  factory _$ParsedDocumentCopyWith(_ParsedDocument value, $Res Function(_ParsedDocument) _then) = __$ParsedDocumentCopyWithImpl;
@override @useResult
$Res call({
 Document document, List<Block> blocks, String linkDefinitions
});


@override $DocumentCopyWith<$Res> get document;

}
/// @nodoc
class __$ParsedDocumentCopyWithImpl<$Res>
    implements _$ParsedDocumentCopyWith<$Res> {
  __$ParsedDocumentCopyWithImpl(this._self, this._then);

  final _ParsedDocument _self;
  final $Res Function(_ParsedDocument) _then;

/// Create a copy of ParsedDocument
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? document = null,Object? blocks = null,Object? linkDefinitions = null,}) {
  return _then(_ParsedDocument(
document: null == document ? _self.document : document // ignore: cast_nullable_to_non_nullable
as Document,blocks: null == blocks ? _self._blocks : blocks // ignore: cast_nullable_to_non_nullable
as List<Block>,linkDefinitions: null == linkDefinitions ? _self.linkDefinitions : linkDefinitions // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of ParsedDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DocumentCopyWith<$Res> get document {
  
  return $DocumentCopyWith<$Res>(_self.document, (value) {
    return _then(_self.copyWith(document: value));
  });
}
}

// dart format on
