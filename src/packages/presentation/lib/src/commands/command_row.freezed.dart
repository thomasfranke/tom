// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'command_row.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CommandRow {

/// Counted from the first command of the session, never reused.
 int get id;/// What ran, is running or waits to.
 CommandRecord get record;/// The plan it was asked in — the commands one method declared, or one
/// action ran — or null for a command nobody could be asked about.
 int? get plan;/// What the plan is called, or null when it was asked outside any
/// action.
 CommandActionEnum? get action;/// The command's key, as `git-approvals.json` spells it; null with
/// [plan].
 String? get key;/// Whether the command changes something rather than only reading.
 bool get isWrite;/// Whether it runs without the person saying yes: the list allows it,
/// or the mode no longer asks. What the row says before its time.
 bool get isAllowed;
/// Create a copy of CommandRow
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommandRowCopyWith<CommandRow> get copyWith => _$CommandRowCopyWithImpl<CommandRow>(this as CommandRow, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommandRow&&(identical(other.id, id) || other.id == id)&&(identical(other.record, record) || other.record == record)&&(identical(other.plan, plan) || other.plan == plan)&&(identical(other.action, action) || other.action == action)&&(identical(other.key, key) || other.key == key)&&(identical(other.isWrite, isWrite) || other.isWrite == isWrite)&&(identical(other.isAllowed, isAllowed) || other.isAllowed == isAllowed));
}


@override
int get hashCode => Object.hash(runtimeType,id,record,plan,action,key,isWrite,isAllowed);

@override
String toString() {
  return 'CommandRow(id: $id, record: $record, plan: $plan, action: $action, key: $key, isWrite: $isWrite, isAllowed: $isAllowed)';
}


}

/// @nodoc
abstract mixin class $CommandRowCopyWith<$Res>  {
  factory $CommandRowCopyWith(CommandRow value, $Res Function(CommandRow) _then) = _$CommandRowCopyWithImpl;
@useResult
$Res call({
 int id, CommandRecord record, int? plan, CommandActionEnum? action, String? key, bool isWrite, bool isAllowed
});


$CommandRecordCopyWith<$Res> get record;

}
/// @nodoc
class _$CommandRowCopyWithImpl<$Res>
    implements $CommandRowCopyWith<$Res> {
  _$CommandRowCopyWithImpl(this._self, this._then);

  final CommandRow _self;
  final $Res Function(CommandRow) _then;

/// Create a copy of CommandRow
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? record = null,Object? plan = freezed,Object? action = freezed,Object? key = freezed,Object? isWrite = null,Object? isAllowed = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,record: null == record ? _self.record : record // ignore: cast_nullable_to_non_nullable
as CommandRecord,plan: freezed == plan ? _self.plan : plan // ignore: cast_nullable_to_non_nullable
as int?,action: freezed == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as CommandActionEnum?,key: freezed == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String?,isWrite: null == isWrite ? _self.isWrite : isWrite // ignore: cast_nullable_to_non_nullable
as bool,isAllowed: null == isAllowed ? _self.isAllowed : isAllowed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of CommandRow
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CommandRecordCopyWith<$Res> get record {
  
  return $CommandRecordCopyWith<$Res>(_self.record, (value) {
    return _then(_self.copyWith(record: value));
  });
}
}


/// Adds pattern-matching-related methods to [CommandRow].
extension CommandRowPatterns on CommandRow {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CommandRow value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CommandRow() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CommandRow value)  $default,){
final _that = this;
switch (_that) {
case _CommandRow():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CommandRow value)?  $default,){
final _that = this;
switch (_that) {
case _CommandRow() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  CommandRecord record,  int? plan,  CommandActionEnum? action,  String? key,  bool isWrite,  bool isAllowed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CommandRow() when $default != null:
return $default(_that.id,_that.record,_that.plan,_that.action,_that.key,_that.isWrite,_that.isAllowed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  CommandRecord record,  int? plan,  CommandActionEnum? action,  String? key,  bool isWrite,  bool isAllowed)  $default,) {final _that = this;
switch (_that) {
case _CommandRow():
return $default(_that.id,_that.record,_that.plan,_that.action,_that.key,_that.isWrite,_that.isAllowed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  CommandRecord record,  int? plan,  CommandActionEnum? action,  String? key,  bool isWrite,  bool isAllowed)?  $default,) {final _that = this;
switch (_that) {
case _CommandRow() when $default != null:
return $default(_that.id,_that.record,_that.plan,_that.action,_that.key,_that.isWrite,_that.isAllowed);case _:
  return null;

}
}

}

/// @nodoc


class _CommandRow extends CommandRow {
  const _CommandRow({required this.id, required this.record, this.plan, this.action, this.key, this.isWrite = false, this.isAllowed = false}): super._();
  

/// Counted from the first command of the session, never reused.
@override final  int id;
/// What ran, is running or waits to.
@override final  CommandRecord record;
/// The plan it was asked in — the commands one method declared, or one
/// action ran — or null for a command nobody could be asked about.
@override final  int? plan;
/// What the plan is called, or null when it was asked outside any
/// action.
@override final  CommandActionEnum? action;
/// The command's key, as `git-approvals.json` spells it; null with
/// [plan].
@override final  String? key;
/// Whether the command changes something rather than only reading.
@override@JsonKey() final  bool isWrite;
/// Whether it runs without the person saying yes: the list allows it,
/// or the mode no longer asks. What the row says before its time.
@override@JsonKey() final  bool isAllowed;

/// Create a copy of CommandRow
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommandRowCopyWith<_CommandRow> get copyWith => __$CommandRowCopyWithImpl<_CommandRow>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommandRow&&(identical(other.id, id) || other.id == id)&&(identical(other.record, record) || other.record == record)&&(identical(other.plan, plan) || other.plan == plan)&&(identical(other.action, action) || other.action == action)&&(identical(other.key, key) || other.key == key)&&(identical(other.isWrite, isWrite) || other.isWrite == isWrite)&&(identical(other.isAllowed, isAllowed) || other.isAllowed == isAllowed));
}


@override
int get hashCode => Object.hash(runtimeType,id,record,plan,action,key,isWrite,isAllowed);

@override
String toString() {
  return 'CommandRow(id: $id, record: $record, plan: $plan, action: $action, key: $key, isWrite: $isWrite, isAllowed: $isAllowed)';
}


}

/// @nodoc
abstract mixin class _$CommandRowCopyWith<$Res> implements $CommandRowCopyWith<$Res> {
  factory _$CommandRowCopyWith(_CommandRow value, $Res Function(_CommandRow) _then) = __$CommandRowCopyWithImpl;
@override @useResult
$Res call({
 int id, CommandRecord record, int? plan, CommandActionEnum? action, String? key, bool isWrite, bool isAllowed
});


@override $CommandRecordCopyWith<$Res> get record;

}
/// @nodoc
class __$CommandRowCopyWithImpl<$Res>
    implements _$CommandRowCopyWith<$Res> {
  __$CommandRowCopyWithImpl(this._self, this._then);

  final _CommandRow _self;
  final $Res Function(_CommandRow) _then;

/// Create a copy of CommandRow
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? record = null,Object? plan = freezed,Object? action = freezed,Object? key = freezed,Object? isWrite = null,Object? isAllowed = null,}) {
  return _then(_CommandRow(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,record: null == record ? _self.record : record // ignore: cast_nullable_to_non_nullable
as CommandRecord,plan: freezed == plan ? _self.plan : plan // ignore: cast_nullable_to_non_nullable
as int?,action: freezed == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as CommandActionEnum?,key: freezed == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String?,isWrite: null == isWrite ? _self.isWrite : isWrite // ignore: cast_nullable_to_non_nullable
as bool,isAllowed: null == isAllowed ? _self.isAllowed : isAllowed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of CommandRow
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CommandRecordCopyWith<$Res> get record {
  
  return $CommandRecordCopyWith<$Res>(_self.record, (value) {
    return _then(_self.copyWith(record: value));
  });
}
}

// dart format on
