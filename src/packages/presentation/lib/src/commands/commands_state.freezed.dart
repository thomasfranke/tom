// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'commands_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CommandsState {

/// The last `CommandsNotifier.kept` commands, oldest first.
 List<CommandRow> get rows;/// How many ran this session, the dropped ones included.
 int get total;/// The rows showing their output, by [CommandRow.id].
 Set<int> get expanded;/// The row the panel is asked to scroll to, until it has.
 int? get revealing;/// The row whose `Always allow` was pressed in Manual, while the
/// question it raises — switch to Semi-automatic? — is unanswered.
 int? get pendingSwitch;
/// Create a copy of CommandsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommandsStateCopyWith<CommandsState> get copyWith => _$CommandsStateCopyWithImpl<CommandsState>(this as CommandsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommandsState&&const DeepCollectionEquality().equals(other.rows, rows)&&(identical(other.total, total) || other.total == total)&&const DeepCollectionEquality().equals(other.expanded, expanded)&&(identical(other.revealing, revealing) || other.revealing == revealing)&&(identical(other.pendingSwitch, pendingSwitch) || other.pendingSwitch == pendingSwitch));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(rows),total,const DeepCollectionEquality().hash(expanded),revealing,pendingSwitch);

@override
String toString() {
  return 'CommandsState(rows: $rows, total: $total, expanded: $expanded, revealing: $revealing, pendingSwitch: $pendingSwitch)';
}


}

/// @nodoc
abstract mixin class $CommandsStateCopyWith<$Res>  {
  factory $CommandsStateCopyWith(CommandsState value, $Res Function(CommandsState) _then) = _$CommandsStateCopyWithImpl;
@useResult
$Res call({
 List<CommandRow> rows, int total, Set<int> expanded, int? revealing, int? pendingSwitch
});




}
/// @nodoc
class _$CommandsStateCopyWithImpl<$Res>
    implements $CommandsStateCopyWith<$Res> {
  _$CommandsStateCopyWithImpl(this._self, this._then);

  final CommandsState _self;
  final $Res Function(CommandsState) _then;

/// Create a copy of CommandsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rows = null,Object? total = null,Object? expanded = null,Object? revealing = freezed,Object? pendingSwitch = freezed,}) {
  return _then(_self.copyWith(
rows: null == rows ? _self.rows : rows // ignore: cast_nullable_to_non_nullable
as List<CommandRow>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,expanded: null == expanded ? _self.expanded : expanded // ignore: cast_nullable_to_non_nullable
as Set<int>,revealing: freezed == revealing ? _self.revealing : revealing // ignore: cast_nullable_to_non_nullable
as int?,pendingSwitch: freezed == pendingSwitch ? _self.pendingSwitch : pendingSwitch // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [CommandsState].
extension CommandsStatePatterns on CommandsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CommandsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CommandsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CommandsState value)  $default,){
final _that = this;
switch (_that) {
case _CommandsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CommandsState value)?  $default,){
final _that = this;
switch (_that) {
case _CommandsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<CommandRow> rows,  int total,  Set<int> expanded,  int? revealing,  int? pendingSwitch)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CommandsState() when $default != null:
return $default(_that.rows,_that.total,_that.expanded,_that.revealing,_that.pendingSwitch);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<CommandRow> rows,  int total,  Set<int> expanded,  int? revealing,  int? pendingSwitch)  $default,) {final _that = this;
switch (_that) {
case _CommandsState():
return $default(_that.rows,_that.total,_that.expanded,_that.revealing,_that.pendingSwitch);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<CommandRow> rows,  int total,  Set<int> expanded,  int? revealing,  int? pendingSwitch)?  $default,) {final _that = this;
switch (_that) {
case _CommandsState() when $default != null:
return $default(_that.rows,_that.total,_that.expanded,_that.revealing,_that.pendingSwitch);case _:
  return null;

}
}

}

/// @nodoc


class _CommandsState extends CommandsState {
  const _CommandsState({final  List<CommandRow> rows = const <CommandRow>[], this.total = 0, final  Set<int> expanded = const <int>{}, this.revealing, this.pendingSwitch}): _rows = rows,_expanded = expanded,super._();
  

/// The last `CommandsNotifier.kept` commands, oldest first.
 final  List<CommandRow> _rows;
/// The last `CommandsNotifier.kept` commands, oldest first.
@override@JsonKey() List<CommandRow> get rows {
  if (_rows is EqualUnmodifiableListView) return _rows;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rows);
}

/// How many ran this session, the dropped ones included.
@override@JsonKey() final  int total;
/// The rows showing their output, by [CommandRow.id].
 final  Set<int> _expanded;
/// The rows showing their output, by [CommandRow.id].
@override@JsonKey() Set<int> get expanded {
  if (_expanded is EqualUnmodifiableSetView) return _expanded;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_expanded);
}

/// The row the panel is asked to scroll to, until it has.
@override final  int? revealing;
/// The row whose `Always allow` was pressed in Manual, while the
/// question it raises — switch to Semi-automatic? — is unanswered.
@override final  int? pendingSwitch;

/// Create a copy of CommandsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommandsStateCopyWith<_CommandsState> get copyWith => __$CommandsStateCopyWithImpl<_CommandsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommandsState&&const DeepCollectionEquality().equals(other._rows, _rows)&&(identical(other.total, total) || other.total == total)&&const DeepCollectionEquality().equals(other._expanded, _expanded)&&(identical(other.revealing, revealing) || other.revealing == revealing)&&(identical(other.pendingSwitch, pendingSwitch) || other.pendingSwitch == pendingSwitch));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_rows),total,const DeepCollectionEquality().hash(_expanded),revealing,pendingSwitch);

@override
String toString() {
  return 'CommandsState(rows: $rows, total: $total, expanded: $expanded, revealing: $revealing, pendingSwitch: $pendingSwitch)';
}


}

/// @nodoc
abstract mixin class _$CommandsStateCopyWith<$Res> implements $CommandsStateCopyWith<$Res> {
  factory _$CommandsStateCopyWith(_CommandsState value, $Res Function(_CommandsState) _then) = __$CommandsStateCopyWithImpl;
@override @useResult
$Res call({
 List<CommandRow> rows, int total, Set<int> expanded, int? revealing, int? pendingSwitch
});




}
/// @nodoc
class __$CommandsStateCopyWithImpl<$Res>
    implements _$CommandsStateCopyWith<$Res> {
  __$CommandsStateCopyWithImpl(this._self, this._then);

  final _CommandsState _self;
  final $Res Function(_CommandsState) _then;

/// Create a copy of CommandsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rows = null,Object? total = null,Object? expanded = null,Object? revealing = freezed,Object? pendingSwitch = freezed,}) {
  return _then(_CommandsState(
rows: null == rows ? _self._rows : rows // ignore: cast_nullable_to_non_nullable
as List<CommandRow>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,expanded: null == expanded ? _self._expanded : expanded // ignore: cast_nullable_to_non_nullable
as Set<int>,revealing: freezed == revealing ? _self.revealing : revealing // ignore: cast_nullable_to_non_nullable
as int?,pendingSwitch: freezed == pendingSwitch ? _self.pendingSwitch : pendingSwitch // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
