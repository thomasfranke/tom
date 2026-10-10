// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'account_summary_value_object.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AccountSummaryValueObject {

 CommitIdentityValueObject get identity;/// Every account the machine holds, the chosen one among them.
///
/// Handed over, not copied: the producer passes `List.unmodifiable`.
 List<GithubAccountValueObject> get accounts;/// The account used in this repository, or null when there is none.
 GithubAccountValueObject? get chosen;/// The repository on GitHub, or null when `origin` is not there.
 RemoteProjectValueObject? get project;/// What [chosen] may do on [project], or null when nothing says.
 RepositoryAccessValueObject? get access;
/// Create a copy of AccountSummaryValueObject
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AccountSummaryValueObjectCopyWith<AccountSummaryValueObject> get copyWith => _$AccountSummaryValueObjectCopyWithImpl<AccountSummaryValueObject>(this as AccountSummaryValueObject, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AccountSummaryValueObject&&(identical(other.identity, identity) || other.identity == identity)&&const DeepCollectionEquality().equals(other.accounts, accounts)&&(identical(other.chosen, chosen) || other.chosen == chosen)&&(identical(other.project, project) || other.project == project)&&(identical(other.access, access) || other.access == access));
}


@override
int get hashCode => Object.hash(runtimeType,identity,const DeepCollectionEquality().hash(accounts),chosen,project,access);

@override
String toString() {
  return 'AccountSummaryValueObject(identity: $identity, accounts: $accounts, chosen: $chosen, project: $project, access: $access)';
}


}

/// @nodoc
abstract mixin class $AccountSummaryValueObjectCopyWith<$Res>  {
  factory $AccountSummaryValueObjectCopyWith(AccountSummaryValueObject value, $Res Function(AccountSummaryValueObject) _then) = _$AccountSummaryValueObjectCopyWithImpl;
@useResult
$Res call({
 CommitIdentityValueObject identity, List<GithubAccountValueObject> accounts, GithubAccountValueObject? chosen, RemoteProjectValueObject? project, RepositoryAccessValueObject? access
});


$CommitIdentityValueObjectCopyWith<$Res> get identity;$GithubAccountValueObjectCopyWith<$Res>? get chosen;$RemoteProjectValueObjectCopyWith<$Res>? get project;$RepositoryAccessValueObjectCopyWith<$Res>? get access;

}
/// @nodoc
class _$AccountSummaryValueObjectCopyWithImpl<$Res>
    implements $AccountSummaryValueObjectCopyWith<$Res> {
  _$AccountSummaryValueObjectCopyWithImpl(this._self, this._then);

  final AccountSummaryValueObject _self;
  final $Res Function(AccountSummaryValueObject) _then;

/// Create a copy of AccountSummaryValueObject
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? identity = null,Object? accounts = null,Object? chosen = freezed,Object? project = freezed,Object? access = freezed,}) {
  return _then(_self.copyWith(
identity: null == identity ? _self.identity : identity // ignore: cast_nullable_to_non_nullable
as CommitIdentityValueObject,accounts: null == accounts ? _self.accounts : accounts // ignore: cast_nullable_to_non_nullable
as List<GithubAccountValueObject>,chosen: freezed == chosen ? _self.chosen : chosen // ignore: cast_nullable_to_non_nullable
as GithubAccountValueObject?,project: freezed == project ? _self.project : project // ignore: cast_nullable_to_non_nullable
as RemoteProjectValueObject?,access: freezed == access ? _self.access : access // ignore: cast_nullable_to_non_nullable
as RepositoryAccessValueObject?,
  ));
}
/// Create a copy of AccountSummaryValueObject
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CommitIdentityValueObjectCopyWith<$Res> get identity {
  
  return $CommitIdentityValueObjectCopyWith<$Res>(_self.identity, (value) {
    return _then(_self.copyWith(identity: value));
  });
}/// Create a copy of AccountSummaryValueObject
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GithubAccountValueObjectCopyWith<$Res>? get chosen {
    if (_self.chosen == null) {
    return null;
  }

  return $GithubAccountValueObjectCopyWith<$Res>(_self.chosen!, (value) {
    return _then(_self.copyWith(chosen: value));
  });
}/// Create a copy of AccountSummaryValueObject
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RemoteProjectValueObjectCopyWith<$Res>? get project {
    if (_self.project == null) {
    return null;
  }

  return $RemoteProjectValueObjectCopyWith<$Res>(_self.project!, (value) {
    return _then(_self.copyWith(project: value));
  });
}/// Create a copy of AccountSummaryValueObject
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RepositoryAccessValueObjectCopyWith<$Res>? get access {
    if (_self.access == null) {
    return null;
  }

  return $RepositoryAccessValueObjectCopyWith<$Res>(_self.access!, (value) {
    return _then(_self.copyWith(access: value));
  });
}
}


/// Adds pattern-matching-related methods to [AccountSummaryValueObject].
extension AccountSummaryValueObjectPatterns on AccountSummaryValueObject {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AccountSummaryValueObject value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AccountSummaryValueObject() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AccountSummaryValueObject value)  $default,){
final _that = this;
switch (_that) {
case _AccountSummaryValueObject():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AccountSummaryValueObject value)?  $default,){
final _that = this;
switch (_that) {
case _AccountSummaryValueObject() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CommitIdentityValueObject identity,  List<GithubAccountValueObject> accounts,  GithubAccountValueObject? chosen,  RemoteProjectValueObject? project,  RepositoryAccessValueObject? access)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AccountSummaryValueObject() when $default != null:
return $default(_that.identity,_that.accounts,_that.chosen,_that.project,_that.access);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CommitIdentityValueObject identity,  List<GithubAccountValueObject> accounts,  GithubAccountValueObject? chosen,  RemoteProjectValueObject? project,  RepositoryAccessValueObject? access)  $default,) {final _that = this;
switch (_that) {
case _AccountSummaryValueObject():
return $default(_that.identity,_that.accounts,_that.chosen,_that.project,_that.access);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CommitIdentityValueObject identity,  List<GithubAccountValueObject> accounts,  GithubAccountValueObject? chosen,  RemoteProjectValueObject? project,  RepositoryAccessValueObject? access)?  $default,) {final _that = this;
switch (_that) {
case _AccountSummaryValueObject() when $default != null:
return $default(_that.identity,_that.accounts,_that.chosen,_that.project,_that.access);case _:
  return null;

}
}

}

/// @nodoc


class _AccountSummaryValueObject implements AccountSummaryValueObject {
  const _AccountSummaryValueObject({required this.identity, final  List<GithubAccountValueObject> accounts = const <GithubAccountValueObject>[], this.chosen, this.project, this.access}): _accounts = accounts;
  

@override final  CommitIdentityValueObject identity;
/// Every account the machine holds, the chosen one among them.
///
/// Handed over, not copied: the producer passes `List.unmodifiable`.
 final  List<GithubAccountValueObject> _accounts;
/// Every account the machine holds, the chosen one among them.
///
/// Handed over, not copied: the producer passes `List.unmodifiable`.
@override@JsonKey() List<GithubAccountValueObject> get accounts {
  if (_accounts is EqualUnmodifiableListView) return _accounts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_accounts);
}

/// The account used in this repository, or null when there is none.
@override final  GithubAccountValueObject? chosen;
/// The repository on GitHub, or null when `origin` is not there.
@override final  RemoteProjectValueObject? project;
/// What [chosen] may do on [project], or null when nothing says.
@override final  RepositoryAccessValueObject? access;

/// Create a copy of AccountSummaryValueObject
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AccountSummaryValueObjectCopyWith<_AccountSummaryValueObject> get copyWith => __$AccountSummaryValueObjectCopyWithImpl<_AccountSummaryValueObject>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AccountSummaryValueObject&&(identical(other.identity, identity) || other.identity == identity)&&const DeepCollectionEquality().equals(other._accounts, _accounts)&&(identical(other.chosen, chosen) || other.chosen == chosen)&&(identical(other.project, project) || other.project == project)&&(identical(other.access, access) || other.access == access));
}


@override
int get hashCode => Object.hash(runtimeType,identity,const DeepCollectionEquality().hash(_accounts),chosen,project,access);

@override
String toString() {
  return 'AccountSummaryValueObject(identity: $identity, accounts: $accounts, chosen: $chosen, project: $project, access: $access)';
}


}

/// @nodoc
abstract mixin class _$AccountSummaryValueObjectCopyWith<$Res> implements $AccountSummaryValueObjectCopyWith<$Res> {
  factory _$AccountSummaryValueObjectCopyWith(_AccountSummaryValueObject value, $Res Function(_AccountSummaryValueObject) _then) = __$AccountSummaryValueObjectCopyWithImpl;
@override @useResult
$Res call({
 CommitIdentityValueObject identity, List<GithubAccountValueObject> accounts, GithubAccountValueObject? chosen, RemoteProjectValueObject? project, RepositoryAccessValueObject? access
});


@override $CommitIdentityValueObjectCopyWith<$Res> get identity;@override $GithubAccountValueObjectCopyWith<$Res>? get chosen;@override $RemoteProjectValueObjectCopyWith<$Res>? get project;@override $RepositoryAccessValueObjectCopyWith<$Res>? get access;

}
/// @nodoc
class __$AccountSummaryValueObjectCopyWithImpl<$Res>
    implements _$AccountSummaryValueObjectCopyWith<$Res> {
  __$AccountSummaryValueObjectCopyWithImpl(this._self, this._then);

  final _AccountSummaryValueObject _self;
  final $Res Function(_AccountSummaryValueObject) _then;

/// Create a copy of AccountSummaryValueObject
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? identity = null,Object? accounts = null,Object? chosen = freezed,Object? project = freezed,Object? access = freezed,}) {
  return _then(_AccountSummaryValueObject(
identity: null == identity ? _self.identity : identity // ignore: cast_nullable_to_non_nullable
as CommitIdentityValueObject,accounts: null == accounts ? _self._accounts : accounts // ignore: cast_nullable_to_non_nullable
as List<GithubAccountValueObject>,chosen: freezed == chosen ? _self.chosen : chosen // ignore: cast_nullable_to_non_nullable
as GithubAccountValueObject?,project: freezed == project ? _self.project : project // ignore: cast_nullable_to_non_nullable
as RemoteProjectValueObject?,access: freezed == access ? _self.access : access // ignore: cast_nullable_to_non_nullable
as RepositoryAccessValueObject?,
  ));
}

/// Create a copy of AccountSummaryValueObject
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CommitIdentityValueObjectCopyWith<$Res> get identity {
  
  return $CommitIdentityValueObjectCopyWith<$Res>(_self.identity, (value) {
    return _then(_self.copyWith(identity: value));
  });
}/// Create a copy of AccountSummaryValueObject
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GithubAccountValueObjectCopyWith<$Res>? get chosen {
    if (_self.chosen == null) {
    return null;
  }

  return $GithubAccountValueObjectCopyWith<$Res>(_self.chosen!, (value) {
    return _then(_self.copyWith(chosen: value));
  });
}/// Create a copy of AccountSummaryValueObject
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RemoteProjectValueObjectCopyWith<$Res>? get project {
    if (_self.project == null) {
    return null;
  }

  return $RemoteProjectValueObjectCopyWith<$Res>(_self.project!, (value) {
    return _then(_self.copyWith(project: value));
  });
}/// Create a copy of AccountSummaryValueObject
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RepositoryAccessValueObjectCopyWith<$Res>? get access {
    if (_self.access == null) {
    return null;
  }

  return $RepositoryAccessValueObjectCopyWith<$Res>(_self.access!, (value) {
    return _then(_self.copyWith(access: value));
  });
}
}

// dart format on
