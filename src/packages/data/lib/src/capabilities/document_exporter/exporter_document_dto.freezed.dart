// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exporter_document_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ExporterDocumentDto {

/// What the output is titled, the document's name without its extension.
 String get title;/// The top-level blocks, in document order.
 List<ExporterBlockDto> get blocks;/// Every link reference definition as the document's own lines, so a
/// block rendered alone resolves `[text][ref]`.
 String get linkDefinitions;/// Every footnote, in citation order.
 List<ExporterFootnoteDto> get footnotes;
/// Create a copy of ExporterDocumentDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExporterDocumentDtoCopyWith<ExporterDocumentDto> get copyWith => _$ExporterDocumentDtoCopyWithImpl<ExporterDocumentDto>(this as ExporterDocumentDto, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExporterDocumentDto&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other.blocks, blocks)&&(identical(other.linkDefinitions, linkDefinitions) || other.linkDefinitions == linkDefinitions)&&const DeepCollectionEquality().equals(other.footnotes, footnotes));
}


@override
int get hashCode => Object.hash(runtimeType,title,const DeepCollectionEquality().hash(blocks),linkDefinitions,const DeepCollectionEquality().hash(footnotes));

@override
String toString() {
  return 'ExporterDocumentDto(title: $title, blocks: $blocks, linkDefinitions: $linkDefinitions, footnotes: $footnotes)';
}


}

/// @nodoc
abstract mixin class $ExporterDocumentDtoCopyWith<$Res>  {
  factory $ExporterDocumentDtoCopyWith(ExporterDocumentDto value, $Res Function(ExporterDocumentDto) _then) = _$ExporterDocumentDtoCopyWithImpl;
@useResult
$Res call({
 String title, List<ExporterBlockDto> blocks, String linkDefinitions, List<ExporterFootnoteDto> footnotes
});




}
/// @nodoc
class _$ExporterDocumentDtoCopyWithImpl<$Res>
    implements $ExporterDocumentDtoCopyWith<$Res> {
  _$ExporterDocumentDtoCopyWithImpl(this._self, this._then);

  final ExporterDocumentDto _self;
  final $Res Function(ExporterDocumentDto) _then;

/// Create a copy of ExporterDocumentDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? blocks = null,Object? linkDefinitions = null,Object? footnotes = null,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,blocks: null == blocks ? _self.blocks : blocks // ignore: cast_nullable_to_non_nullable
as List<ExporterBlockDto>,linkDefinitions: null == linkDefinitions ? _self.linkDefinitions : linkDefinitions // ignore: cast_nullable_to_non_nullable
as String,footnotes: null == footnotes ? _self.footnotes : footnotes // ignore: cast_nullable_to_non_nullable
as List<ExporterFootnoteDto>,
  ));
}

}


/// Adds pattern-matching-related methods to [ExporterDocumentDto].
extension ExporterDocumentDtoPatterns on ExporterDocumentDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExporterDocumentDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExporterDocumentDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExporterDocumentDto value)  $default,){
final _that = this;
switch (_that) {
case _ExporterDocumentDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExporterDocumentDto value)?  $default,){
final _that = this;
switch (_that) {
case _ExporterDocumentDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  List<ExporterBlockDto> blocks,  String linkDefinitions,  List<ExporterFootnoteDto> footnotes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExporterDocumentDto() when $default != null:
return $default(_that.title,_that.blocks,_that.linkDefinitions,_that.footnotes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  List<ExporterBlockDto> blocks,  String linkDefinitions,  List<ExporterFootnoteDto> footnotes)  $default,) {final _that = this;
switch (_that) {
case _ExporterDocumentDto():
return $default(_that.title,_that.blocks,_that.linkDefinitions,_that.footnotes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  List<ExporterBlockDto> blocks,  String linkDefinitions,  List<ExporterFootnoteDto> footnotes)?  $default,) {final _that = this;
switch (_that) {
case _ExporterDocumentDto() when $default != null:
return $default(_that.title,_that.blocks,_that.linkDefinitions,_that.footnotes);case _:
  return null;

}
}

}

/// @nodoc


class _ExporterDocumentDto implements ExporterDocumentDto {
  const _ExporterDocumentDto({required this.title, required final  List<ExporterBlockDto> blocks, required this.linkDefinitions, final  List<ExporterFootnoteDto> footnotes = const <ExporterFootnoteDto>[]}): _blocks = blocks,_footnotes = footnotes;
  

/// What the output is titled, the document's name without its extension.
@override final  String title;
/// The top-level blocks, in document order.
 final  List<ExporterBlockDto> _blocks;
/// The top-level blocks, in document order.
@override List<ExporterBlockDto> get blocks {
  if (_blocks is EqualUnmodifiableListView) return _blocks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_blocks);
}

/// Every link reference definition as the document's own lines, so a
/// block rendered alone resolves `[text][ref]`.
@override final  String linkDefinitions;
/// Every footnote, in citation order.
 final  List<ExporterFootnoteDto> _footnotes;
/// Every footnote, in citation order.
@override@JsonKey() List<ExporterFootnoteDto> get footnotes {
  if (_footnotes is EqualUnmodifiableListView) return _footnotes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_footnotes);
}


/// Create a copy of ExporterDocumentDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExporterDocumentDtoCopyWith<_ExporterDocumentDto> get copyWith => __$ExporterDocumentDtoCopyWithImpl<_ExporterDocumentDto>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExporterDocumentDto&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other._blocks, _blocks)&&(identical(other.linkDefinitions, linkDefinitions) || other.linkDefinitions == linkDefinitions)&&const DeepCollectionEquality().equals(other._footnotes, _footnotes));
}


@override
int get hashCode => Object.hash(runtimeType,title,const DeepCollectionEquality().hash(_blocks),linkDefinitions,const DeepCollectionEquality().hash(_footnotes));

@override
String toString() {
  return 'ExporterDocumentDto(title: $title, blocks: $blocks, linkDefinitions: $linkDefinitions, footnotes: $footnotes)';
}


}

/// @nodoc
abstract mixin class _$ExporterDocumentDtoCopyWith<$Res> implements $ExporterDocumentDtoCopyWith<$Res> {
  factory _$ExporterDocumentDtoCopyWith(_ExporterDocumentDto value, $Res Function(_ExporterDocumentDto) _then) = __$ExporterDocumentDtoCopyWithImpl;
@override @useResult
$Res call({
 String title, List<ExporterBlockDto> blocks, String linkDefinitions, List<ExporterFootnoteDto> footnotes
});




}
/// @nodoc
class __$ExporterDocumentDtoCopyWithImpl<$Res>
    implements _$ExporterDocumentDtoCopyWith<$Res> {
  __$ExporterDocumentDtoCopyWithImpl(this._self, this._then);

  final _ExporterDocumentDto _self;
  final $Res Function(_ExporterDocumentDto) _then;

/// Create a copy of ExporterDocumentDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? blocks = null,Object? linkDefinitions = null,Object? footnotes = null,}) {
  return _then(_ExporterDocumentDto(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,blocks: null == blocks ? _self._blocks : blocks // ignore: cast_nullable_to_non_nullable
as List<ExporterBlockDto>,linkDefinitions: null == linkDefinitions ? _self.linkDefinitions : linkDefinitions // ignore: cast_nullable_to_non_nullable
as String,footnotes: null == footnotes ? _self._footnotes : footnotes // ignore: cast_nullable_to_non_nullable
as List<ExporterFootnoteDto>,
  ));
}


}

// dart format on
