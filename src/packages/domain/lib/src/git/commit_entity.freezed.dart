// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'commit_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CommitEntity {

/// Its object name, which is its identity.
 CommitShaValueObject get sha;/// Who wrote it.
 AuthorValueObject get author;/// When it was written, and where the author's clock stood.
 CommitDateValueObject get date;/// The first line of the message.
 String get subject;/// Everything after the first line. Empty when there is none.
 String get body;
/// Create a copy of CommitEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommitEntityCopyWith<CommitEntity> get copyWith => _$CommitEntityCopyWithImpl<CommitEntity>(this as CommitEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommitEntity&&(identical(other.sha, sha) || other.sha == sha)&&(identical(other.author, author) || other.author == author)&&(identical(other.date, date) || other.date == date)&&(identical(other.subject, subject) || other.subject == subject)&&(identical(other.body, body) || other.body == body));
}


@override
int get hashCode => Object.hash(runtimeType,sha,author,date,subject,body);

@override
String toString() {
  return 'CommitEntity(sha: $sha, author: $author, date: $date, subject: $subject, body: $body)';
}


}

/// @nodoc
abstract mixin class $CommitEntityCopyWith<$Res>  {
  factory $CommitEntityCopyWith(CommitEntity value, $Res Function(CommitEntity) _then) = _$CommitEntityCopyWithImpl;
@useResult
$Res call({
 CommitShaValueObject sha, AuthorValueObject author, CommitDateValueObject date, String subject, String body
});


$AuthorValueObjectCopyWith<$Res> get author;$CommitDateValueObjectCopyWith<$Res> get date;

}
/// @nodoc
class _$CommitEntityCopyWithImpl<$Res>
    implements $CommitEntityCopyWith<$Res> {
  _$CommitEntityCopyWithImpl(this._self, this._then);

  final CommitEntity _self;
  final $Res Function(CommitEntity) _then;

/// Create a copy of CommitEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sha = null,Object? author = null,Object? date = null,Object? subject = null,Object? body = null,}) {
  return _then(_self.copyWith(
sha: null == sha ? _self.sha : sha // ignore: cast_nullable_to_non_nullable
as CommitShaValueObject,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as AuthorValueObject,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as CommitDateValueObject,subject: null == subject ? _self.subject : subject // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of CommitEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AuthorValueObjectCopyWith<$Res> get author {
  
  return $AuthorValueObjectCopyWith<$Res>(_self.author, (value) {
    return _then(_self.copyWith(author: value));
  });
}/// Create a copy of CommitEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CommitDateValueObjectCopyWith<$Res> get date {
  
  return $CommitDateValueObjectCopyWith<$Res>(_self.date, (value) {
    return _then(_self.copyWith(date: value));
  });
}
}


/// Adds pattern-matching-related methods to [CommitEntity].
extension CommitEntityPatterns on CommitEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CommitEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CommitEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CommitEntity value)  $default,){
final _that = this;
switch (_that) {
case _CommitEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CommitEntity value)?  $default,){
final _that = this;
switch (_that) {
case _CommitEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CommitShaValueObject sha,  AuthorValueObject author,  CommitDateValueObject date,  String subject,  String body)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CommitEntity() when $default != null:
return $default(_that.sha,_that.author,_that.date,_that.subject,_that.body);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CommitShaValueObject sha,  AuthorValueObject author,  CommitDateValueObject date,  String subject,  String body)  $default,) {final _that = this;
switch (_that) {
case _CommitEntity():
return $default(_that.sha,_that.author,_that.date,_that.subject,_that.body);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CommitShaValueObject sha,  AuthorValueObject author,  CommitDateValueObject date,  String subject,  String body)?  $default,) {final _that = this;
switch (_that) {
case _CommitEntity() when $default != null:
return $default(_that.sha,_that.author,_that.date,_that.subject,_that.body);case _:
  return null;

}
}

}

/// @nodoc


class _CommitEntity implements CommitEntity {
  const _CommitEntity({required this.sha, required this.author, required this.date, required this.subject, required this.body});
  

/// Its object name, which is its identity.
@override final  CommitShaValueObject sha;
/// Who wrote it.
@override final  AuthorValueObject author;
/// When it was written, and where the author's clock stood.
@override final  CommitDateValueObject date;
/// The first line of the message.
@override final  String subject;
/// Everything after the first line. Empty when there is none.
@override final  String body;

/// Create a copy of CommitEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommitEntityCopyWith<_CommitEntity> get copyWith => __$CommitEntityCopyWithImpl<_CommitEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommitEntity&&(identical(other.sha, sha) || other.sha == sha)&&(identical(other.author, author) || other.author == author)&&(identical(other.date, date) || other.date == date)&&(identical(other.subject, subject) || other.subject == subject)&&(identical(other.body, body) || other.body == body));
}


@override
int get hashCode => Object.hash(runtimeType,sha,author,date,subject,body);

@override
String toString() {
  return 'CommitEntity(sha: $sha, author: $author, date: $date, subject: $subject, body: $body)';
}


}

/// @nodoc
abstract mixin class _$CommitEntityCopyWith<$Res> implements $CommitEntityCopyWith<$Res> {
  factory _$CommitEntityCopyWith(_CommitEntity value, $Res Function(_CommitEntity) _then) = __$CommitEntityCopyWithImpl;
@override @useResult
$Res call({
 CommitShaValueObject sha, AuthorValueObject author, CommitDateValueObject date, String subject, String body
});


@override $AuthorValueObjectCopyWith<$Res> get author;@override $CommitDateValueObjectCopyWith<$Res> get date;

}
/// @nodoc
class __$CommitEntityCopyWithImpl<$Res>
    implements _$CommitEntityCopyWith<$Res> {
  __$CommitEntityCopyWithImpl(this._self, this._then);

  final _CommitEntity _self;
  final $Res Function(_CommitEntity) _then;

/// Create a copy of CommitEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sha = null,Object? author = null,Object? date = null,Object? subject = null,Object? body = null,}) {
  return _then(_CommitEntity(
sha: null == sha ? _self.sha : sha // ignore: cast_nullable_to_non_nullable
as CommitShaValueObject,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as AuthorValueObject,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as CommitDateValueObject,subject: null == subject ? _self.subject : subject // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of CommitEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AuthorValueObjectCopyWith<$Res> get author {
  
  return $AuthorValueObjectCopyWith<$Res>(_self.author, (value) {
    return _then(_self.copyWith(author: value));
  });
}/// Create a copy of CommitEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CommitDateValueObjectCopyWith<$Res> get date {
  
  return $CommitDateValueObjectCopyWith<$Res>(_self.date, (value) {
    return _then(_self.copyWith(date: value));
  });
}
}

// dart format on
