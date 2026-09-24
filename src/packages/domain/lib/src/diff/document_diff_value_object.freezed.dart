// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'document_diff_value_object.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DocumentDiffValueObject {

/// The version compared against: `HEAD`, a branch, a commit.
 ParsedDocumentValueObject get before;/// The version on screen, which for the working copy is the buffer.
 ParsedDocumentValueObject get after;/// Every block of both versions, in reading order.
///
/// Handed over unmodifiable, never copied: Freezed compares collections
/// element-wise and copies nothing.
 List<DiffBlockValueObject> get blocks;
/// Create a copy of DocumentDiffValueObject
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DocumentDiffValueObjectCopyWith<DocumentDiffValueObject> get copyWith => _$DocumentDiffValueObjectCopyWithImpl<DocumentDiffValueObject>(this as DocumentDiffValueObject, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DocumentDiffValueObject&&(identical(other.before, before) || other.before == before)&&(identical(other.after, after) || other.after == after)&&const DeepCollectionEquality().equals(other.blocks, blocks));
}


@override
int get hashCode => Object.hash(runtimeType,before,after,const DeepCollectionEquality().hash(blocks));

@override
String toString() {
  return 'DocumentDiffValueObject(before: $before, after: $after, blocks: $blocks)';
}


}

/// @nodoc
abstract mixin class $DocumentDiffValueObjectCopyWith<$Res>  {
  factory $DocumentDiffValueObjectCopyWith(DocumentDiffValueObject value, $Res Function(DocumentDiffValueObject) _then) = _$DocumentDiffValueObjectCopyWithImpl;
@useResult
$Res call({
 ParsedDocumentValueObject before, ParsedDocumentValueObject after, List<DiffBlockValueObject> blocks
});


$ParsedDocumentValueObjectCopyWith<$Res> get before;$ParsedDocumentValueObjectCopyWith<$Res> get after;

}
/// @nodoc
class _$DocumentDiffValueObjectCopyWithImpl<$Res>
    implements $DocumentDiffValueObjectCopyWith<$Res> {
  _$DocumentDiffValueObjectCopyWithImpl(this._self, this._then);

  final DocumentDiffValueObject _self;
  final $Res Function(DocumentDiffValueObject) _then;

/// Create a copy of DocumentDiffValueObject
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? before = null,Object? after = null,Object? blocks = null,}) {
  return _then(_self.copyWith(
before: null == before ? _self.before : before // ignore: cast_nullable_to_non_nullable
as ParsedDocumentValueObject,after: null == after ? _self.after : after // ignore: cast_nullable_to_non_nullable
as ParsedDocumentValueObject,blocks: null == blocks ? _self.blocks : blocks // ignore: cast_nullable_to_non_nullable
as List<DiffBlockValueObject>,
  ));
}
/// Create a copy of DocumentDiffValueObject
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ParsedDocumentValueObjectCopyWith<$Res> get before {
  
  return $ParsedDocumentValueObjectCopyWith<$Res>(_self.before, (value) {
    return _then(_self.copyWith(before: value));
  });
}/// Create a copy of DocumentDiffValueObject
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ParsedDocumentValueObjectCopyWith<$Res> get after {
  
  return $ParsedDocumentValueObjectCopyWith<$Res>(_self.after, (value) {
    return _then(_self.copyWith(after: value));
  });
}
}


/// Adds pattern-matching-related methods to [DocumentDiffValueObject].
extension DocumentDiffValueObjectPatterns on DocumentDiffValueObject {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DocumentDiffValueObject value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DocumentDiffValueObject() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DocumentDiffValueObject value)  $default,){
final _that = this;
switch (_that) {
case _DocumentDiffValueObject():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DocumentDiffValueObject value)?  $default,){
final _that = this;
switch (_that) {
case _DocumentDiffValueObject() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ParsedDocumentValueObject before,  ParsedDocumentValueObject after,  List<DiffBlockValueObject> blocks)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DocumentDiffValueObject() when $default != null:
return $default(_that.before,_that.after,_that.blocks);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ParsedDocumentValueObject before,  ParsedDocumentValueObject after,  List<DiffBlockValueObject> blocks)  $default,) {final _that = this;
switch (_that) {
case _DocumentDiffValueObject():
return $default(_that.before,_that.after,_that.blocks);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ParsedDocumentValueObject before,  ParsedDocumentValueObject after,  List<DiffBlockValueObject> blocks)?  $default,) {final _that = this;
switch (_that) {
case _DocumentDiffValueObject() when $default != null:
return $default(_that.before,_that.after,_that.blocks);case _:
  return null;

}
}

}

/// @nodoc


class _DocumentDiffValueObject extends DocumentDiffValueObject {
  const _DocumentDiffValueObject({required this.before, required this.after, required final  List<DiffBlockValueObject> blocks}): _blocks = blocks,super._();
  

/// The version compared against: `HEAD`, a branch, a commit.
@override final  ParsedDocumentValueObject before;
/// The version on screen, which for the working copy is the buffer.
@override final  ParsedDocumentValueObject after;
/// Every block of both versions, in reading order.
///
/// Handed over unmodifiable, never copied: Freezed compares collections
/// element-wise and copies nothing.
 final  List<DiffBlockValueObject> _blocks;
/// Every block of both versions, in reading order.
///
/// Handed over unmodifiable, never copied: Freezed compares collections
/// element-wise and copies nothing.
@override List<DiffBlockValueObject> get blocks {
  if (_blocks is EqualUnmodifiableListView) return _blocks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_blocks);
}


/// Create a copy of DocumentDiffValueObject
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DocumentDiffValueObjectCopyWith<_DocumentDiffValueObject> get copyWith => __$DocumentDiffValueObjectCopyWithImpl<_DocumentDiffValueObject>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DocumentDiffValueObject&&(identical(other.before, before) || other.before == before)&&(identical(other.after, after) || other.after == after)&&const DeepCollectionEquality().equals(other._blocks, _blocks));
}


@override
int get hashCode => Object.hash(runtimeType,before,after,const DeepCollectionEquality().hash(_blocks));

@override
String toString() {
  return 'DocumentDiffValueObject(before: $before, after: $after, blocks: $blocks)';
}


}

/// @nodoc
abstract mixin class _$DocumentDiffValueObjectCopyWith<$Res> implements $DocumentDiffValueObjectCopyWith<$Res> {
  factory _$DocumentDiffValueObjectCopyWith(_DocumentDiffValueObject value, $Res Function(_DocumentDiffValueObject) _then) = __$DocumentDiffValueObjectCopyWithImpl;
@override @useResult
$Res call({
 ParsedDocumentValueObject before, ParsedDocumentValueObject after, List<DiffBlockValueObject> blocks
});


@override $ParsedDocumentValueObjectCopyWith<$Res> get before;@override $ParsedDocumentValueObjectCopyWith<$Res> get after;

}
/// @nodoc
class __$DocumentDiffValueObjectCopyWithImpl<$Res>
    implements _$DocumentDiffValueObjectCopyWith<$Res> {
  __$DocumentDiffValueObjectCopyWithImpl(this._self, this._then);

  final _DocumentDiffValueObject _self;
  final $Res Function(_DocumentDiffValueObject) _then;

/// Create a copy of DocumentDiffValueObject
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? before = null,Object? after = null,Object? blocks = null,}) {
  return _then(_DocumentDiffValueObject(
before: null == before ? _self.before : before // ignore: cast_nullable_to_non_nullable
as ParsedDocumentValueObject,after: null == after ? _self.after : after // ignore: cast_nullable_to_non_nullable
as ParsedDocumentValueObject,blocks: null == blocks ? _self._blocks : blocks // ignore: cast_nullable_to_non_nullable
as List<DiffBlockValueObject>,
  ));
}

/// Create a copy of DocumentDiffValueObject
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ParsedDocumentValueObjectCopyWith<$Res> get before {
  
  return $ParsedDocumentValueObjectCopyWith<$Res>(_self.before, (value) {
    return _then(_self.copyWith(before: value));
  });
}/// Create a copy of DocumentDiffValueObject
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ParsedDocumentValueObjectCopyWith<$Res> get after {
  
  return $ParsedDocumentValueObjectCopyWith<$Res>(_self.after, (value) {
    return _then(_self.copyWith(after: value));
  });
}
}

// dart format on
