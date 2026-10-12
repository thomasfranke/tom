// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'command_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CommandRecord {

/// The program, as it was asked for — `git`, `gh`, `open`.
 String get executable;/// Its arguments, one entry per argument.
 List<String> get arguments;/// When it was started.
 DateTime get startedAt;/// How long it ran, start to end.
 Duration get duration;/// What it exited with, or null when it never ended on its own — not
/// started, or killed for taking too long.
 int? get exitCode;/// What it printed, standard output then standard error.
 String get output;/// The exit codes the caller asked for as answers rather than errors —
/// `git config --get` of a key nobody set is 1, and that is the answer.
 Set<int> get answers;/// False when the program could not even be started — not installed, or
/// a folder it could not run in.
 bool get ran;/// Where it is between asked for and ended; ended, for a record written
/// once the process is over — which every one was before commands could
/// wait.
 CommandStageEnum get stage;/// What the gate that let it through knows it by, or null when nothing
/// waited: how a record finds the row that was already there for it.
 int? get ticket;
/// Create a copy of CommandRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommandRecordCopyWith<CommandRecord> get copyWith => _$CommandRecordCopyWithImpl<CommandRecord>(this as CommandRecord, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommandRecord&&(identical(other.executable, executable) || other.executable == executable)&&const DeepCollectionEquality().equals(other.arguments, arguments)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.exitCode, exitCode) || other.exitCode == exitCode)&&(identical(other.output, output) || other.output == output)&&const DeepCollectionEquality().equals(other.answers, answers)&&(identical(other.ran, ran) || other.ran == ran)&&(identical(other.stage, stage) || other.stage == stage)&&(identical(other.ticket, ticket) || other.ticket == ticket));
}


@override
int get hashCode => Object.hash(runtimeType,executable,const DeepCollectionEquality().hash(arguments),startedAt,duration,exitCode,output,const DeepCollectionEquality().hash(answers),ran,stage,ticket);

@override
String toString() {
  return 'CommandRecord(executable: $executable, arguments: $arguments, startedAt: $startedAt, duration: $duration, exitCode: $exitCode, output: $output, answers: $answers, ran: $ran, stage: $stage, ticket: $ticket)';
}


}

/// @nodoc
abstract mixin class $CommandRecordCopyWith<$Res>  {
  factory $CommandRecordCopyWith(CommandRecord value, $Res Function(CommandRecord) _then) = _$CommandRecordCopyWithImpl;
@useResult
$Res call({
 String executable, List<String> arguments, DateTime startedAt, Duration duration, int? exitCode, String output, Set<int> answers, bool ran, CommandStageEnum stage, int? ticket
});




}
/// @nodoc
class _$CommandRecordCopyWithImpl<$Res>
    implements $CommandRecordCopyWith<$Res> {
  _$CommandRecordCopyWithImpl(this._self, this._then);

  final CommandRecord _self;
  final $Res Function(CommandRecord) _then;

/// Create a copy of CommandRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? executable = null,Object? arguments = null,Object? startedAt = null,Object? duration = null,Object? exitCode = freezed,Object? output = null,Object? answers = null,Object? ran = null,Object? stage = null,Object? ticket = freezed,}) {
  return _then(_self.copyWith(
executable: null == executable ? _self.executable : executable // ignore: cast_nullable_to_non_nullable
as String,arguments: null == arguments ? _self.arguments : arguments // ignore: cast_nullable_to_non_nullable
as List<String>,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration,exitCode: freezed == exitCode ? _self.exitCode : exitCode // ignore: cast_nullable_to_non_nullable
as int?,output: null == output ? _self.output : output // ignore: cast_nullable_to_non_nullable
as String,answers: null == answers ? _self.answers : answers // ignore: cast_nullable_to_non_nullable
as Set<int>,ran: null == ran ? _self.ran : ran // ignore: cast_nullable_to_non_nullable
as bool,stage: null == stage ? _self.stage : stage // ignore: cast_nullable_to_non_nullable
as CommandStageEnum,ticket: freezed == ticket ? _self.ticket : ticket // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [CommandRecord].
extension CommandRecordPatterns on CommandRecord {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CommandRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CommandRecord() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CommandRecord value)  $default,){
final _that = this;
switch (_that) {
case _CommandRecord():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CommandRecord value)?  $default,){
final _that = this;
switch (_that) {
case _CommandRecord() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String executable,  List<String> arguments,  DateTime startedAt,  Duration duration,  int? exitCode,  String output,  Set<int> answers,  bool ran,  CommandStageEnum stage,  int? ticket)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CommandRecord() when $default != null:
return $default(_that.executable,_that.arguments,_that.startedAt,_that.duration,_that.exitCode,_that.output,_that.answers,_that.ran,_that.stage,_that.ticket);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String executable,  List<String> arguments,  DateTime startedAt,  Duration duration,  int? exitCode,  String output,  Set<int> answers,  bool ran,  CommandStageEnum stage,  int? ticket)  $default,) {final _that = this;
switch (_that) {
case _CommandRecord():
return $default(_that.executable,_that.arguments,_that.startedAt,_that.duration,_that.exitCode,_that.output,_that.answers,_that.ran,_that.stage,_that.ticket);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String executable,  List<String> arguments,  DateTime startedAt,  Duration duration,  int? exitCode,  String output,  Set<int> answers,  bool ran,  CommandStageEnum stage,  int? ticket)?  $default,) {final _that = this;
switch (_that) {
case _CommandRecord() when $default != null:
return $default(_that.executable,_that.arguments,_that.startedAt,_that.duration,_that.exitCode,_that.output,_that.answers,_that.ran,_that.stage,_that.ticket);case _:
  return null;

}
}

}

/// @nodoc


class _CommandRecord extends CommandRecord {
  const _CommandRecord({required this.executable, required final  List<String> arguments, required this.startedAt, required this.duration, this.exitCode, this.output = '', final  Set<int> answers = const <int>{}, this.ran = true, this.stage = CommandStageEnum.ended, this.ticket}): _arguments = arguments,_answers = answers,super._();
  

/// The program, as it was asked for — `git`, `gh`, `open`.
@override final  String executable;
/// Its arguments, one entry per argument.
 final  List<String> _arguments;
/// Its arguments, one entry per argument.
@override List<String> get arguments {
  if (_arguments is EqualUnmodifiableListView) return _arguments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_arguments);
}

/// When it was started.
@override final  DateTime startedAt;
/// How long it ran, start to end.
@override final  Duration duration;
/// What it exited with, or null when it never ended on its own — not
/// started, or killed for taking too long.
@override final  int? exitCode;
/// What it printed, standard output then standard error.
@override@JsonKey() final  String output;
/// The exit codes the caller asked for as answers rather than errors —
/// `git config --get` of a key nobody set is 1, and that is the answer.
 final  Set<int> _answers;
/// The exit codes the caller asked for as answers rather than errors —
/// `git config --get` of a key nobody set is 1, and that is the answer.
@override@JsonKey() Set<int> get answers {
  if (_answers is EqualUnmodifiableSetView) return _answers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_answers);
}

/// False when the program could not even be started — not installed, or
/// a folder it could not run in.
@override@JsonKey() final  bool ran;
/// Where it is between asked for and ended; ended, for a record written
/// once the process is over — which every one was before commands could
/// wait.
@override@JsonKey() final  CommandStageEnum stage;
/// What the gate that let it through knows it by, or null when nothing
/// waited: how a record finds the row that was already there for it.
@override final  int? ticket;

/// Create a copy of CommandRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommandRecordCopyWith<_CommandRecord> get copyWith => __$CommandRecordCopyWithImpl<_CommandRecord>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommandRecord&&(identical(other.executable, executable) || other.executable == executable)&&const DeepCollectionEquality().equals(other._arguments, _arguments)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.exitCode, exitCode) || other.exitCode == exitCode)&&(identical(other.output, output) || other.output == output)&&const DeepCollectionEquality().equals(other._answers, _answers)&&(identical(other.ran, ran) || other.ran == ran)&&(identical(other.stage, stage) || other.stage == stage)&&(identical(other.ticket, ticket) || other.ticket == ticket));
}


@override
int get hashCode => Object.hash(runtimeType,executable,const DeepCollectionEquality().hash(_arguments),startedAt,duration,exitCode,output,const DeepCollectionEquality().hash(_answers),ran,stage,ticket);

@override
String toString() {
  return 'CommandRecord(executable: $executable, arguments: $arguments, startedAt: $startedAt, duration: $duration, exitCode: $exitCode, output: $output, answers: $answers, ran: $ran, stage: $stage, ticket: $ticket)';
}


}

/// @nodoc
abstract mixin class _$CommandRecordCopyWith<$Res> implements $CommandRecordCopyWith<$Res> {
  factory _$CommandRecordCopyWith(_CommandRecord value, $Res Function(_CommandRecord) _then) = __$CommandRecordCopyWithImpl;
@override @useResult
$Res call({
 String executable, List<String> arguments, DateTime startedAt, Duration duration, int? exitCode, String output, Set<int> answers, bool ran, CommandStageEnum stage, int? ticket
});




}
/// @nodoc
class __$CommandRecordCopyWithImpl<$Res>
    implements _$CommandRecordCopyWith<$Res> {
  __$CommandRecordCopyWithImpl(this._self, this._then);

  final _CommandRecord _self;
  final $Res Function(_CommandRecord) _then;

/// Create a copy of CommandRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? executable = null,Object? arguments = null,Object? startedAt = null,Object? duration = null,Object? exitCode = freezed,Object? output = null,Object? answers = null,Object? ran = null,Object? stage = null,Object? ticket = freezed,}) {
  return _then(_CommandRecord(
executable: null == executable ? _self.executable : executable // ignore: cast_nullable_to_non_nullable
as String,arguments: null == arguments ? _self._arguments : arguments // ignore: cast_nullable_to_non_nullable
as List<String>,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration,exitCode: freezed == exitCode ? _self.exitCode : exitCode // ignore: cast_nullable_to_non_nullable
as int?,output: null == output ? _self.output : output // ignore: cast_nullable_to_non_nullable
as String,answers: null == answers ? _self._answers : answers // ignore: cast_nullable_to_non_nullable
as Set<int>,ran: null == ran ? _self.ran : ran // ignore: cast_nullable_to_non_nullable
as bool,stage: null == stage ? _self.stage : stage // ignore: cast_nullable_to_non_nullable
as CommandStageEnum,ticket: freezed == ticket ? _self.ticket : ticket // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
