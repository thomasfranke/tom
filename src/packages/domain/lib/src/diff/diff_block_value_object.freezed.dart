// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'diff_block_value_object.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DiffBlockValueObject {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DiffBlockValueObject);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'DiffBlockValueObject()';
}


}

/// @nodoc
class $DiffBlockValueObjectCopyWith<$Res>  {
$DiffBlockValueObjectCopyWith(DiffBlockValueObject _, $Res Function(DiffBlockValueObject) __);
}


/// Adds pattern-matching-related methods to [DiffBlockValueObject].
extension DiffBlockValueObjectPatterns on DiffBlockValueObject {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( DiffBlockUnchanged value)?  unchanged,TResult Function( DiffBlockAdded value)?  added,TResult Function( DiffBlockRemoved value)?  removed,TResult Function( DiffBlockModified value)?  modified,required TResult orElse(),}){
final _that = this;
switch (_that) {
case DiffBlockUnchanged() when unchanged != null:
return unchanged(_that);case DiffBlockAdded() when added != null:
return added(_that);case DiffBlockRemoved() when removed != null:
return removed(_that);case DiffBlockModified() when modified != null:
return modified(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( DiffBlockUnchanged value)  unchanged,required TResult Function( DiffBlockAdded value)  added,required TResult Function( DiffBlockRemoved value)  removed,required TResult Function( DiffBlockModified value)  modified,}){
final _that = this;
switch (_that) {
case DiffBlockUnchanged():
return unchanged(_that);case DiffBlockAdded():
return added(_that);case DiffBlockRemoved():
return removed(_that);case DiffBlockModified():
return modified(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( DiffBlockUnchanged value)?  unchanged,TResult? Function( DiffBlockAdded value)?  added,TResult? Function( DiffBlockRemoved value)?  removed,TResult? Function( DiffBlockModified value)?  modified,}){
final _that = this;
switch (_that) {
case DiffBlockUnchanged() when unchanged != null:
return unchanged(_that);case DiffBlockAdded() when added != null:
return added(_that);case DiffBlockRemoved() when removed != null:
return removed(_that);case DiffBlockModified() when modified != null:
return modified(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( BlockValueObject block)?  unchanged,TResult Function( BlockValueObject block)?  added,TResult Function( BlockValueObject block)?  removed,TResult Function( BlockValueObject before,  BlockValueObject after)?  modified,required TResult orElse(),}) {final _that = this;
switch (_that) {
case DiffBlockUnchanged() when unchanged != null:
return unchanged(_that.block);case DiffBlockAdded() when added != null:
return added(_that.block);case DiffBlockRemoved() when removed != null:
return removed(_that.block);case DiffBlockModified() when modified != null:
return modified(_that.before,_that.after);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( BlockValueObject block)  unchanged,required TResult Function( BlockValueObject block)  added,required TResult Function( BlockValueObject block)  removed,required TResult Function( BlockValueObject before,  BlockValueObject after)  modified,}) {final _that = this;
switch (_that) {
case DiffBlockUnchanged():
return unchanged(_that.block);case DiffBlockAdded():
return added(_that.block);case DiffBlockRemoved():
return removed(_that.block);case DiffBlockModified():
return modified(_that.before,_that.after);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( BlockValueObject block)?  unchanged,TResult? Function( BlockValueObject block)?  added,TResult? Function( BlockValueObject block)?  removed,TResult? Function( BlockValueObject before,  BlockValueObject after)?  modified,}) {final _that = this;
switch (_that) {
case DiffBlockUnchanged() when unchanged != null:
return unchanged(_that.block);case DiffBlockAdded() when added != null:
return added(_that.block);case DiffBlockRemoved() when removed != null:
return removed(_that.block);case DiffBlockModified() when modified != null:
return modified(_that.before,_that.after);case _:
  return null;

}
}

}

/// @nodoc


class DiffBlockUnchanged extends DiffBlockValueObject {
  const DiffBlockUnchanged(this.block): super._();
  

 final  BlockValueObject block;

/// Create a copy of DiffBlockValueObject
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DiffBlockUnchangedCopyWith<DiffBlockUnchanged> get copyWith => _$DiffBlockUnchangedCopyWithImpl<DiffBlockUnchanged>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DiffBlockUnchanged&&(identical(other.block, block) || other.block == block));
}


@override
int get hashCode => Object.hash(runtimeType,block);

@override
String toString() {
  return 'DiffBlockValueObject.unchanged(block: $block)';
}


}

/// @nodoc
abstract mixin class $DiffBlockUnchangedCopyWith<$Res> implements $DiffBlockValueObjectCopyWith<$Res> {
  factory $DiffBlockUnchangedCopyWith(DiffBlockUnchanged value, $Res Function(DiffBlockUnchanged) _then) = _$DiffBlockUnchangedCopyWithImpl;
@useResult
$Res call({
 BlockValueObject block
});


$BlockValueObjectCopyWith<$Res> get block;

}
/// @nodoc
class _$DiffBlockUnchangedCopyWithImpl<$Res>
    implements $DiffBlockUnchangedCopyWith<$Res> {
  _$DiffBlockUnchangedCopyWithImpl(this._self, this._then);

  final DiffBlockUnchanged _self;
  final $Res Function(DiffBlockUnchanged) _then;

/// Create a copy of DiffBlockValueObject
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? block = null,}) {
  return _then(DiffBlockUnchanged(
null == block ? _self.block : block // ignore: cast_nullable_to_non_nullable
as BlockValueObject,
  ));
}

/// Create a copy of DiffBlockValueObject
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BlockValueObjectCopyWith<$Res> get block {
  
  return $BlockValueObjectCopyWith<$Res>(_self.block, (value) {
    return _then(_self.copyWith(block: value));
  });
}
}

/// @nodoc


class DiffBlockAdded extends DiffBlockValueObject {
  const DiffBlockAdded(this.block): super._();
  

 final  BlockValueObject block;

/// Create a copy of DiffBlockValueObject
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DiffBlockAddedCopyWith<DiffBlockAdded> get copyWith => _$DiffBlockAddedCopyWithImpl<DiffBlockAdded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DiffBlockAdded&&(identical(other.block, block) || other.block == block));
}


@override
int get hashCode => Object.hash(runtimeType,block);

@override
String toString() {
  return 'DiffBlockValueObject.added(block: $block)';
}


}

/// @nodoc
abstract mixin class $DiffBlockAddedCopyWith<$Res> implements $DiffBlockValueObjectCopyWith<$Res> {
  factory $DiffBlockAddedCopyWith(DiffBlockAdded value, $Res Function(DiffBlockAdded) _then) = _$DiffBlockAddedCopyWithImpl;
@useResult
$Res call({
 BlockValueObject block
});


$BlockValueObjectCopyWith<$Res> get block;

}
/// @nodoc
class _$DiffBlockAddedCopyWithImpl<$Res>
    implements $DiffBlockAddedCopyWith<$Res> {
  _$DiffBlockAddedCopyWithImpl(this._self, this._then);

  final DiffBlockAdded _self;
  final $Res Function(DiffBlockAdded) _then;

/// Create a copy of DiffBlockValueObject
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? block = null,}) {
  return _then(DiffBlockAdded(
null == block ? _self.block : block // ignore: cast_nullable_to_non_nullable
as BlockValueObject,
  ));
}

/// Create a copy of DiffBlockValueObject
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BlockValueObjectCopyWith<$Res> get block {
  
  return $BlockValueObjectCopyWith<$Res>(_self.block, (value) {
    return _then(_self.copyWith(block: value));
  });
}
}

/// @nodoc


class DiffBlockRemoved extends DiffBlockValueObject {
  const DiffBlockRemoved(this.block): super._();
  

 final  BlockValueObject block;

/// Create a copy of DiffBlockValueObject
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DiffBlockRemovedCopyWith<DiffBlockRemoved> get copyWith => _$DiffBlockRemovedCopyWithImpl<DiffBlockRemoved>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DiffBlockRemoved&&(identical(other.block, block) || other.block == block));
}


@override
int get hashCode => Object.hash(runtimeType,block);

@override
String toString() {
  return 'DiffBlockValueObject.removed(block: $block)';
}


}

/// @nodoc
abstract mixin class $DiffBlockRemovedCopyWith<$Res> implements $DiffBlockValueObjectCopyWith<$Res> {
  factory $DiffBlockRemovedCopyWith(DiffBlockRemoved value, $Res Function(DiffBlockRemoved) _then) = _$DiffBlockRemovedCopyWithImpl;
@useResult
$Res call({
 BlockValueObject block
});


$BlockValueObjectCopyWith<$Res> get block;

}
/// @nodoc
class _$DiffBlockRemovedCopyWithImpl<$Res>
    implements $DiffBlockRemovedCopyWith<$Res> {
  _$DiffBlockRemovedCopyWithImpl(this._self, this._then);

  final DiffBlockRemoved _self;
  final $Res Function(DiffBlockRemoved) _then;

/// Create a copy of DiffBlockValueObject
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? block = null,}) {
  return _then(DiffBlockRemoved(
null == block ? _self.block : block // ignore: cast_nullable_to_non_nullable
as BlockValueObject,
  ));
}

/// Create a copy of DiffBlockValueObject
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BlockValueObjectCopyWith<$Res> get block {
  
  return $BlockValueObjectCopyWith<$Res>(_self.block, (value) {
    return _then(_self.copyWith(block: value));
  });
}
}

/// @nodoc


class DiffBlockModified extends DiffBlockValueObject {
  const DiffBlockModified({required this.before, required this.after}): super._();
  

 final  BlockValueObject before;
 final  BlockValueObject after;

/// Create a copy of DiffBlockValueObject
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DiffBlockModifiedCopyWith<DiffBlockModified> get copyWith => _$DiffBlockModifiedCopyWithImpl<DiffBlockModified>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DiffBlockModified&&(identical(other.before, before) || other.before == before)&&(identical(other.after, after) || other.after == after));
}


@override
int get hashCode => Object.hash(runtimeType,before,after);

@override
String toString() {
  return 'DiffBlockValueObject.modified(before: $before, after: $after)';
}


}

/// @nodoc
abstract mixin class $DiffBlockModifiedCopyWith<$Res> implements $DiffBlockValueObjectCopyWith<$Res> {
  factory $DiffBlockModifiedCopyWith(DiffBlockModified value, $Res Function(DiffBlockModified) _then) = _$DiffBlockModifiedCopyWithImpl;
@useResult
$Res call({
 BlockValueObject before, BlockValueObject after
});


$BlockValueObjectCopyWith<$Res> get before;$BlockValueObjectCopyWith<$Res> get after;

}
/// @nodoc
class _$DiffBlockModifiedCopyWithImpl<$Res>
    implements $DiffBlockModifiedCopyWith<$Res> {
  _$DiffBlockModifiedCopyWithImpl(this._self, this._then);

  final DiffBlockModified _self;
  final $Res Function(DiffBlockModified) _then;

/// Create a copy of DiffBlockValueObject
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? before = null,Object? after = null,}) {
  return _then(DiffBlockModified(
before: null == before ? _self.before : before // ignore: cast_nullable_to_non_nullable
as BlockValueObject,after: null == after ? _self.after : after // ignore: cast_nullable_to_non_nullable
as BlockValueObject,
  ));
}

/// Create a copy of DiffBlockValueObject
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BlockValueObjectCopyWith<$Res> get before {
  
  return $BlockValueObjectCopyWith<$Res>(_self.before, (value) {
    return _then(_self.copyWith(before: value));
  });
}/// Create a copy of DiffBlockValueObject
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BlockValueObjectCopyWith<$Res> get after {
  
  return $BlockValueObjectCopyWith<$Res>(_self.after, (value) {
    return _then(_self.copyWith(after: value));
  });
}
}

// dart format on
