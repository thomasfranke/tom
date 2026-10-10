// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'command_gate.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CommandVerdict {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommandVerdict);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CommandVerdict()';
}


}

/// @nodoc
class $CommandVerdictCopyWith<$Res>  {
$CommandVerdictCopyWith(CommandVerdict _, $Res Function(CommandVerdict) __);
}


/// Adds pattern-matching-related methods to [CommandVerdict].
extension CommandVerdictPatterns on CommandVerdict {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( CommandRun value)?  run,TResult Function( CommandDenied value)?  denied,required TResult orElse(),}){
final _that = this;
switch (_that) {
case CommandRun() when run != null:
return run(_that);case CommandDenied() when denied != null:
return denied(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( CommandRun value)  run,required TResult Function( CommandDenied value)  denied,}){
final _that = this;
switch (_that) {
case CommandRun():
return run(_that);case CommandDenied():
return denied(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( CommandRun value)?  run,TResult? Function( CommandDenied value)?  denied,}){
final _that = this;
switch (_that) {
case CommandRun() when run != null:
return run(_that);case CommandDenied() when denied != null:
return denied(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( int? ticket)?  run,TResult Function()?  denied,required TResult orElse(),}) {final _that = this;
switch (_that) {
case CommandRun() when run != null:
return run(_that.ticket);case CommandDenied() when denied != null:
return denied();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( int? ticket)  run,required TResult Function()  denied,}) {final _that = this;
switch (_that) {
case CommandRun():
return run(_that.ticket);case CommandDenied():
return denied();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( int? ticket)?  run,TResult? Function()?  denied,}) {final _that = this;
switch (_that) {
case CommandRun() when run != null:
return run(_that.ticket);case CommandDenied() when denied != null:
return denied();case _:
  return null;

}
}

}

/// @nodoc


class CommandRun implements CommandVerdict {
  const CommandRun({this.ticket});
  

/// What the gate knows this command by, handed back with its record so
/// the list that asked finds its own row; null when nothing waited.
 final  int? ticket;

/// Create a copy of CommandVerdict
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommandRunCopyWith<CommandRun> get copyWith => _$CommandRunCopyWithImpl<CommandRun>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommandRun&&(identical(other.ticket, ticket) || other.ticket == ticket));
}


@override
int get hashCode => Object.hash(runtimeType,ticket);

@override
String toString() {
  return 'CommandVerdict.run(ticket: $ticket)';
}


}

/// @nodoc
abstract mixin class $CommandRunCopyWith<$Res> implements $CommandVerdictCopyWith<$Res> {
  factory $CommandRunCopyWith(CommandRun value, $Res Function(CommandRun) _then) = _$CommandRunCopyWithImpl;
@useResult
$Res call({
 int? ticket
});




}
/// @nodoc
class _$CommandRunCopyWithImpl<$Res>
    implements $CommandRunCopyWith<$Res> {
  _$CommandRunCopyWithImpl(this._self, this._then);

  final CommandRun _self;
  final $Res Function(CommandRun) _then;

/// Create a copy of CommandVerdict
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? ticket = freezed,}) {
  return _then(CommandRun(
ticket: freezed == ticket ? _self.ticket : ticket // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc


class CommandDenied implements CommandVerdict {
  const CommandDenied();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommandDenied);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CommandVerdict.denied()';
}


}




// dart format on
