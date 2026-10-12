// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'command_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CommandRequest {

/// The command's template, [CommandKey.template].
 String get key;/// The program, as it will be asked for.
 String get executable;/// Its arguments as they may be shown, one entry per argument.
 List<String> get arguments;/// Whether it writes, [CommandKey.isWrite].
 bool get isWrite;
/// Create a copy of CommandRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommandRequestCopyWith<CommandRequest> get copyWith => _$CommandRequestCopyWithImpl<CommandRequest>(this as CommandRequest, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommandRequest&&(identical(other.key, key) || other.key == key)&&(identical(other.executable, executable) || other.executable == executable)&&const DeepCollectionEquality().equals(other.arguments, arguments)&&(identical(other.isWrite, isWrite) || other.isWrite == isWrite));
}


@override
int get hashCode => Object.hash(runtimeType,key,executable,const DeepCollectionEquality().hash(arguments),isWrite);

@override
String toString() {
  return 'CommandRequest(key: $key, executable: $executable, arguments: $arguments, isWrite: $isWrite)';
}


}

/// @nodoc
abstract mixin class $CommandRequestCopyWith<$Res>  {
  factory $CommandRequestCopyWith(CommandRequest value, $Res Function(CommandRequest) _then) = _$CommandRequestCopyWithImpl;
@useResult
$Res call({
 String key, String executable, List<String> arguments, bool isWrite
});




}
/// @nodoc
class _$CommandRequestCopyWithImpl<$Res>
    implements $CommandRequestCopyWith<$Res> {
  _$CommandRequestCopyWithImpl(this._self, this._then);

  final CommandRequest _self;
  final $Res Function(CommandRequest) _then;

/// Create a copy of CommandRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? key = null,Object? executable = null,Object? arguments = null,Object? isWrite = null,}) {
  return _then(_self.copyWith(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,executable: null == executable ? _self.executable : executable // ignore: cast_nullable_to_non_nullable
as String,arguments: null == arguments ? _self.arguments : arguments // ignore: cast_nullable_to_non_nullable
as List<String>,isWrite: null == isWrite ? _self.isWrite : isWrite // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CommandRequest].
extension CommandRequestPatterns on CommandRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CommandRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CommandRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CommandRequest value)  $default,){
final _that = this;
switch (_that) {
case _CommandRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CommandRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CommandRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String key,  String executable,  List<String> arguments,  bool isWrite)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CommandRequest() when $default != null:
return $default(_that.key,_that.executable,_that.arguments,_that.isWrite);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String key,  String executable,  List<String> arguments,  bool isWrite)  $default,) {final _that = this;
switch (_that) {
case _CommandRequest():
return $default(_that.key,_that.executable,_that.arguments,_that.isWrite);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String key,  String executable,  List<String> arguments,  bool isWrite)?  $default,) {final _that = this;
switch (_that) {
case _CommandRequest() when $default != null:
return $default(_that.key,_that.executable,_that.arguments,_that.isWrite);case _:
  return null;

}
}

}

/// @nodoc


class _CommandRequest extends CommandRequest {
  const _CommandRequest({required this.key, required this.executable, required final  List<String> arguments, required this.isWrite}): _arguments = arguments,super._();
  

/// The command's template, [CommandKey.template].
@override final  String key;
/// The program, as it will be asked for.
@override final  String executable;
/// Its arguments as they may be shown, one entry per argument.
 final  List<String> _arguments;
/// Its arguments as they may be shown, one entry per argument.
@override List<String> get arguments {
  if (_arguments is EqualUnmodifiableListView) return _arguments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_arguments);
}

/// Whether it writes, [CommandKey.isWrite].
@override final  bool isWrite;

/// Create a copy of CommandRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommandRequestCopyWith<_CommandRequest> get copyWith => __$CommandRequestCopyWithImpl<_CommandRequest>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommandRequest&&(identical(other.key, key) || other.key == key)&&(identical(other.executable, executable) || other.executable == executable)&&const DeepCollectionEquality().equals(other._arguments, _arguments)&&(identical(other.isWrite, isWrite) || other.isWrite == isWrite));
}


@override
int get hashCode => Object.hash(runtimeType,key,executable,const DeepCollectionEquality().hash(_arguments),isWrite);

@override
String toString() {
  return 'CommandRequest(key: $key, executable: $executable, arguments: $arguments, isWrite: $isWrite)';
}


}

/// @nodoc
abstract mixin class _$CommandRequestCopyWith<$Res> implements $CommandRequestCopyWith<$Res> {
  factory _$CommandRequestCopyWith(_CommandRequest value, $Res Function(_CommandRequest) _then) = __$CommandRequestCopyWithImpl;
@override @useResult
$Res call({
 String key, String executable, List<String> arguments, bool isWrite
});




}
/// @nodoc
class __$CommandRequestCopyWithImpl<$Res>
    implements _$CommandRequestCopyWith<$Res> {
  __$CommandRequestCopyWithImpl(this._self, this._then);

  final _CommandRequest _self;
  final $Res Function(_CommandRequest) _then;

/// Create a copy of CommandRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? key = null,Object? executable = null,Object? arguments = null,Object? isWrite = null,}) {
  return _then(_CommandRequest(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,executable: null == executable ? _self.executable : executable // ignore: cast_nullable_to_non_nullable
as String,arguments: null == arguments ? _self._arguments : arguments // ignore: cast_nullable_to_non_nullable
as List<String>,isWrite: null == isWrite ? _self.isWrite : isWrite // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
