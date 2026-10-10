// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'terminal_size_value_object.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TerminalSizeValueObject {

/// Characters across.
 int get columns;/// Lines down.
 int get rows;
/// Create a copy of TerminalSizeValueObject
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TerminalSizeValueObjectCopyWith<TerminalSizeValueObject> get copyWith => _$TerminalSizeValueObjectCopyWithImpl<TerminalSizeValueObject>(this as TerminalSizeValueObject, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TerminalSizeValueObject&&(identical(other.columns, columns) || other.columns == columns)&&(identical(other.rows, rows) || other.rows == rows));
}


@override
int get hashCode => Object.hash(runtimeType,columns,rows);

@override
String toString() {
  return 'TerminalSizeValueObject(columns: $columns, rows: $rows)';
}


}

/// @nodoc
abstract mixin class $TerminalSizeValueObjectCopyWith<$Res>  {
  factory $TerminalSizeValueObjectCopyWith(TerminalSizeValueObject value, $Res Function(TerminalSizeValueObject) _then) = _$TerminalSizeValueObjectCopyWithImpl;
@useResult
$Res call({
 int columns, int rows
});




}
/// @nodoc
class _$TerminalSizeValueObjectCopyWithImpl<$Res>
    implements $TerminalSizeValueObjectCopyWith<$Res> {
  _$TerminalSizeValueObjectCopyWithImpl(this._self, this._then);

  final TerminalSizeValueObject _self;
  final $Res Function(TerminalSizeValueObject) _then;

/// Create a copy of TerminalSizeValueObject
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? columns = null,Object? rows = null,}) {
  return _then(_self.copyWith(
columns: null == columns ? _self.columns : columns // ignore: cast_nullable_to_non_nullable
as int,rows: null == rows ? _self.rows : rows // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TerminalSizeValueObject].
extension TerminalSizeValueObjectPatterns on TerminalSizeValueObject {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TerminalSizeValueObject value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TerminalSizeValueObject() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TerminalSizeValueObject value)  $default,){
final _that = this;
switch (_that) {
case _TerminalSizeValueObject():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TerminalSizeValueObject value)?  $default,){
final _that = this;
switch (_that) {
case _TerminalSizeValueObject() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int columns,  int rows)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TerminalSizeValueObject() when $default != null:
return $default(_that.columns,_that.rows);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int columns,  int rows)  $default,) {final _that = this;
switch (_that) {
case _TerminalSizeValueObject():
return $default(_that.columns,_that.rows);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int columns,  int rows)?  $default,) {final _that = this;
switch (_that) {
case _TerminalSizeValueObject() when $default != null:
return $default(_that.columns,_that.rows);case _:
  return null;

}
}

}

/// @nodoc


class _TerminalSizeValueObject implements TerminalSizeValueObject {
  const _TerminalSizeValueObject({required this.columns, required this.rows}): assert(columns > 0 && rows > 0, 'a screen holds at least one cell');
  

/// Characters across.
@override final  int columns;
/// Lines down.
@override final  int rows;

/// Create a copy of TerminalSizeValueObject
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TerminalSizeValueObjectCopyWith<_TerminalSizeValueObject> get copyWith => __$TerminalSizeValueObjectCopyWithImpl<_TerminalSizeValueObject>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TerminalSizeValueObject&&(identical(other.columns, columns) || other.columns == columns)&&(identical(other.rows, rows) || other.rows == rows));
}


@override
int get hashCode => Object.hash(runtimeType,columns,rows);

@override
String toString() {
  return 'TerminalSizeValueObject(columns: $columns, rows: $rows)';
}


}

/// @nodoc
abstract mixin class _$TerminalSizeValueObjectCopyWith<$Res> implements $TerminalSizeValueObjectCopyWith<$Res> {
  factory _$TerminalSizeValueObjectCopyWith(_TerminalSizeValueObject value, $Res Function(_TerminalSizeValueObject) _then) = __$TerminalSizeValueObjectCopyWithImpl;
@override @useResult
$Res call({
 int columns, int rows
});




}
/// @nodoc
class __$TerminalSizeValueObjectCopyWithImpl<$Res>
    implements _$TerminalSizeValueObjectCopyWith<$Res> {
  __$TerminalSizeValueObjectCopyWithImpl(this._self, this._then);

  final _TerminalSizeValueObject _self;
  final $Res Function(_TerminalSizeValueObject) _then;

/// Create a copy of TerminalSizeValueObject
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? columns = null,Object? rows = null,}) {
  return _then(_TerminalSizeValueObject(
columns: null == columns ? _self.columns : columns // ignore: cast_nullable_to_non_nullable
as int,rows: null == rows ? _self.rows : rows // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
