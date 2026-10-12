// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'account_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AccountState {

/// The last summary read, kept while the next one is read.
 AccountSummaryValueObject? get summary;/// What git said before the first [summary]: who commits and the
/// project, nothing about GitHub yet.
 AccountSummaryValueObject? get local;/// Whether a reading is out.
 bool get isReading;/// Nothing was asked yet because git asks first (Manual): the button
/// says so, and opening the popover is what reads.
 bool get isUnread;
/// Create a copy of AccountState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AccountStateCopyWith<AccountState> get copyWith => _$AccountStateCopyWithImpl<AccountState>(this as AccountState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AccountState&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.local, local) || other.local == local)&&(identical(other.isReading, isReading) || other.isReading == isReading)&&(identical(other.isUnread, isUnread) || other.isUnread == isUnread));
}


@override
int get hashCode => Object.hash(runtimeType,summary,local,isReading,isUnread);

@override
String toString() {
  return 'AccountState(summary: $summary, local: $local, isReading: $isReading, isUnread: $isUnread)';
}


}

/// @nodoc
abstract mixin class $AccountStateCopyWith<$Res>  {
  factory $AccountStateCopyWith(AccountState value, $Res Function(AccountState) _then) = _$AccountStateCopyWithImpl;
@useResult
$Res call({
 AccountSummaryValueObject? summary, AccountSummaryValueObject? local, bool isReading, bool isUnread
});


$AccountSummaryValueObjectCopyWith<$Res>? get summary;$AccountSummaryValueObjectCopyWith<$Res>? get local;

}
/// @nodoc
class _$AccountStateCopyWithImpl<$Res>
    implements $AccountStateCopyWith<$Res> {
  _$AccountStateCopyWithImpl(this._self, this._then);

  final AccountState _self;
  final $Res Function(AccountState) _then;

/// Create a copy of AccountState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? summary = freezed,Object? local = freezed,Object? isReading = null,Object? isUnread = null,}) {
  return _then(_self.copyWith(
summary: freezed == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as AccountSummaryValueObject?,local: freezed == local ? _self.local : local // ignore: cast_nullable_to_non_nullable
as AccountSummaryValueObject?,isReading: null == isReading ? _self.isReading : isReading // ignore: cast_nullable_to_non_nullable
as bool,isUnread: null == isUnread ? _self.isUnread : isUnread // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of AccountState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AccountSummaryValueObjectCopyWith<$Res>? get summary {
    if (_self.summary == null) {
    return null;
  }

  return $AccountSummaryValueObjectCopyWith<$Res>(_self.summary!, (value) {
    return _then(_self.copyWith(summary: value));
  });
}/// Create a copy of AccountState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AccountSummaryValueObjectCopyWith<$Res>? get local {
    if (_self.local == null) {
    return null;
  }

  return $AccountSummaryValueObjectCopyWith<$Res>(_self.local!, (value) {
    return _then(_self.copyWith(local: value));
  });
}
}


/// Adds pattern-matching-related methods to [AccountState].
extension AccountStatePatterns on AccountState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AccountState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AccountState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AccountState value)  $default,){
final _that = this;
switch (_that) {
case _AccountState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AccountState value)?  $default,){
final _that = this;
switch (_that) {
case _AccountState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AccountSummaryValueObject? summary,  AccountSummaryValueObject? local,  bool isReading,  bool isUnread)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AccountState() when $default != null:
return $default(_that.summary,_that.local,_that.isReading,_that.isUnread);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AccountSummaryValueObject? summary,  AccountSummaryValueObject? local,  bool isReading,  bool isUnread)  $default,) {final _that = this;
switch (_that) {
case _AccountState():
return $default(_that.summary,_that.local,_that.isReading,_that.isUnread);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AccountSummaryValueObject? summary,  AccountSummaryValueObject? local,  bool isReading,  bool isUnread)?  $default,) {final _that = this;
switch (_that) {
case _AccountState() when $default != null:
return $default(_that.summary,_that.local,_that.isReading,_that.isUnread);case _:
  return null;

}
}

}

/// @nodoc


class _AccountState extends AccountState {
  const _AccountState({this.summary, this.local, this.isReading = false, this.isUnread = false}): super._();
  

/// The last summary read, kept while the next one is read.
@override final  AccountSummaryValueObject? summary;
/// What git said before the first [summary]: who commits and the
/// project, nothing about GitHub yet.
@override final  AccountSummaryValueObject? local;
/// Whether a reading is out.
@override@JsonKey() final  bool isReading;
/// Nothing was asked yet because git asks first (Manual): the button
/// says so, and opening the popover is what reads.
@override@JsonKey() final  bool isUnread;

/// Create a copy of AccountState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AccountStateCopyWith<_AccountState> get copyWith => __$AccountStateCopyWithImpl<_AccountState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AccountState&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.local, local) || other.local == local)&&(identical(other.isReading, isReading) || other.isReading == isReading)&&(identical(other.isUnread, isUnread) || other.isUnread == isUnread));
}


@override
int get hashCode => Object.hash(runtimeType,summary,local,isReading,isUnread);

@override
String toString() {
  return 'AccountState(summary: $summary, local: $local, isReading: $isReading, isUnread: $isUnread)';
}


}

/// @nodoc
abstract mixin class _$AccountStateCopyWith<$Res> implements $AccountStateCopyWith<$Res> {
  factory _$AccountStateCopyWith(_AccountState value, $Res Function(_AccountState) _then) = __$AccountStateCopyWithImpl;
@override @useResult
$Res call({
 AccountSummaryValueObject? summary, AccountSummaryValueObject? local, bool isReading, bool isUnread
});


@override $AccountSummaryValueObjectCopyWith<$Res>? get summary;@override $AccountSummaryValueObjectCopyWith<$Res>? get local;

}
/// @nodoc
class __$AccountStateCopyWithImpl<$Res>
    implements _$AccountStateCopyWith<$Res> {
  __$AccountStateCopyWithImpl(this._self, this._then);

  final _AccountState _self;
  final $Res Function(_AccountState) _then;

/// Create a copy of AccountState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? summary = freezed,Object? local = freezed,Object? isReading = null,Object? isUnread = null,}) {
  return _then(_AccountState(
summary: freezed == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as AccountSummaryValueObject?,local: freezed == local ? _self.local : local // ignore: cast_nullable_to_non_nullable
as AccountSummaryValueObject?,isReading: null == isReading ? _self.isReading : isReading // ignore: cast_nullable_to_non_nullable
as bool,isUnread: null == isUnread ? _self.isUnread : isUnread // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of AccountState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AccountSummaryValueObjectCopyWith<$Res>? get summary {
    if (_self.summary == null) {
    return null;
  }

  return $AccountSummaryValueObjectCopyWith<$Res>(_self.summary!, (value) {
    return _then(_self.copyWith(summary: value));
  });
}/// Create a copy of AccountState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AccountSummaryValueObjectCopyWith<$Res>? get local {
    if (_self.local == null) {
    return null;
  }

  return $AccountSummaryValueObjectCopyWith<$Res>(_self.local!, (value) {
    return _then(_self.copyWith(local: value));
  });
}
}

// dart format on
