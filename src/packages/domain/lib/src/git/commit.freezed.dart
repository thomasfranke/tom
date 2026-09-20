// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'commit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Commit {

/// Its object name, which is its identity.
 CommitSha get sha;/// Who wrote it.
 Author get author;/// When it was written, and where the author's clock stood.
 CommitDate get date;/// The first line of the message.
 String get subject;/// Everything after the first line. Empty when there is none.
 String get body;
/// Create a copy of Commit
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommitCopyWith<Commit> get copyWith => _$CommitCopyWithImpl<Commit>(this as Commit, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Commit&&(identical(other.sha, sha) || other.sha == sha)&&(identical(other.author, author) || other.author == author)&&(identical(other.date, date) || other.date == date)&&(identical(other.subject, subject) || other.subject == subject)&&(identical(other.body, body) || other.body == body));
}


@override
int get hashCode => Object.hash(runtimeType,sha,author,date,subject,body);

@override
String toString() {
  return 'Commit(sha: $sha, author: $author, date: $date, subject: $subject, body: $body)';
}


}

/// @nodoc
abstract mixin class $CommitCopyWith<$Res>  {
  factory $CommitCopyWith(Commit value, $Res Function(Commit) _then) = _$CommitCopyWithImpl;
@useResult
$Res call({
 CommitSha sha, Author author, CommitDate date, String subject, String body
});


$AuthorCopyWith<$Res> get author;$CommitDateCopyWith<$Res> get date;

}
/// @nodoc
class _$CommitCopyWithImpl<$Res>
    implements $CommitCopyWith<$Res> {
  _$CommitCopyWithImpl(this._self, this._then);

  final Commit _self;
  final $Res Function(Commit) _then;

/// Create a copy of Commit
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sha = null,Object? author = null,Object? date = null,Object? subject = null,Object? body = null,}) {
  return _then(_self.copyWith(
sha: null == sha ? _self.sha : sha // ignore: cast_nullable_to_non_nullable
as CommitSha,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as Author,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as CommitDate,subject: null == subject ? _self.subject : subject // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of Commit
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AuthorCopyWith<$Res> get author {
  
  return $AuthorCopyWith<$Res>(_self.author, (value) {
    return _then(_self.copyWith(author: value));
  });
}/// Create a copy of Commit
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CommitDateCopyWith<$Res> get date {
  
  return $CommitDateCopyWith<$Res>(_self.date, (value) {
    return _then(_self.copyWith(date: value));
  });
}
}


/// Adds pattern-matching-related methods to [Commit].
extension CommitPatterns on Commit {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Commit value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Commit() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Commit value)  $default,){
final _that = this;
switch (_that) {
case _Commit():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Commit value)?  $default,){
final _that = this;
switch (_that) {
case _Commit() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CommitSha sha,  Author author,  CommitDate date,  String subject,  String body)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Commit() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CommitSha sha,  Author author,  CommitDate date,  String subject,  String body)  $default,) {final _that = this;
switch (_that) {
case _Commit():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CommitSha sha,  Author author,  CommitDate date,  String subject,  String body)?  $default,) {final _that = this;
switch (_that) {
case _Commit() when $default != null:
return $default(_that.sha,_that.author,_that.date,_that.subject,_that.body);case _:
  return null;

}
}

}

/// @nodoc


class _Commit implements Commit {
  const _Commit({required this.sha, required this.author, required this.date, required this.subject, required this.body});
  

/// Its object name, which is its identity.
@override final  CommitSha sha;
/// Who wrote it.
@override final  Author author;
/// When it was written, and where the author's clock stood.
@override final  CommitDate date;
/// The first line of the message.
@override final  String subject;
/// Everything after the first line. Empty when there is none.
@override final  String body;

/// Create a copy of Commit
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommitCopyWith<_Commit> get copyWith => __$CommitCopyWithImpl<_Commit>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Commit&&(identical(other.sha, sha) || other.sha == sha)&&(identical(other.author, author) || other.author == author)&&(identical(other.date, date) || other.date == date)&&(identical(other.subject, subject) || other.subject == subject)&&(identical(other.body, body) || other.body == body));
}


@override
int get hashCode => Object.hash(runtimeType,sha,author,date,subject,body);

@override
String toString() {
  return 'Commit(sha: $sha, author: $author, date: $date, subject: $subject, body: $body)';
}


}

/// @nodoc
abstract mixin class _$CommitCopyWith<$Res> implements $CommitCopyWith<$Res> {
  factory _$CommitCopyWith(_Commit value, $Res Function(_Commit) _then) = __$CommitCopyWithImpl;
@override @useResult
$Res call({
 CommitSha sha, Author author, CommitDate date, String subject, String body
});


@override $AuthorCopyWith<$Res> get author;@override $CommitDateCopyWith<$Res> get date;

}
/// @nodoc
class __$CommitCopyWithImpl<$Res>
    implements _$CommitCopyWith<$Res> {
  __$CommitCopyWithImpl(this._self, this._then);

  final _Commit _self;
  final $Res Function(_Commit) _then;

/// Create a copy of Commit
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sha = null,Object? author = null,Object? date = null,Object? subject = null,Object? body = null,}) {
  return _then(_Commit(
sha: null == sha ? _self.sha : sha // ignore: cast_nullable_to_non_nullable
as CommitSha,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as Author,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as CommitDate,subject: null == subject ? _self.subject : subject // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of Commit
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AuthorCopyWith<$Res> get author {
  
  return $AuthorCopyWith<$Res>(_self.author, (value) {
    return _then(_self.copyWith(author: value));
  });
}/// Create a copy of Commit
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CommitDateCopyWith<$Res> get date {
  
  return $CommitDateCopyWith<$Res>(_self.date, (value) {
    return _then(_self.copyWith(date: value));
  });
}
}

// dart format on
