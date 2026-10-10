// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pull_request_status.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PullRequestStatus {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PullRequestStatus);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PullRequestStatus()';
}


}

/// @nodoc
class $PullRequestStatusCopyWith<$Res>  {
$PullRequestStatusCopyWith(PullRequestStatus _, $Res Function(PullRequestStatus) __);
}


/// Adds pattern-matching-related methods to [PullRequestStatus].
extension PullRequestStatusPatterns on PullRequestStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( PullRequestReady value)?  ready,TResult Function( PullRequestUncommitted value)?  uncommitted,TResult Function( PullRequestUnpublished value)?  unpublished,TResult Function( PullRequestUntitled value)?  untitled,TResult Function( PullRequestEmpty value)?  empty,TResult Function( PullRequestAlreadyOpen value)?  alreadyOpen,TResult Function( PullRequestNotCreated value)?  notCreated,TResult Function( PullRequestReading value)?  reading,TResult Function( PullRequestFailed value)?  failed,required TResult orElse(),}){
final _that = this;
switch (_that) {
case PullRequestReady() when ready != null:
return ready(_that);case PullRequestUncommitted() when uncommitted != null:
return uncommitted(_that);case PullRequestUnpublished() when unpublished != null:
return unpublished(_that);case PullRequestUntitled() when untitled != null:
return untitled(_that);case PullRequestEmpty() when empty != null:
return empty(_that);case PullRequestAlreadyOpen() when alreadyOpen != null:
return alreadyOpen(_that);case PullRequestNotCreated() when notCreated != null:
return notCreated(_that);case PullRequestReading() when reading != null:
return reading(_that);case PullRequestFailed() when failed != null:
return failed(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( PullRequestReady value)  ready,required TResult Function( PullRequestUncommitted value)  uncommitted,required TResult Function( PullRequestUnpublished value)  unpublished,required TResult Function( PullRequestUntitled value)  untitled,required TResult Function( PullRequestEmpty value)  empty,required TResult Function( PullRequestAlreadyOpen value)  alreadyOpen,required TResult Function( PullRequestNotCreated value)  notCreated,required TResult Function( PullRequestReading value)  reading,required TResult Function( PullRequestFailed value)  failed,}){
final _that = this;
switch (_that) {
case PullRequestReady():
return ready(_that);case PullRequestUncommitted():
return uncommitted(_that);case PullRequestUnpublished():
return unpublished(_that);case PullRequestUntitled():
return untitled(_that);case PullRequestEmpty():
return empty(_that);case PullRequestAlreadyOpen():
return alreadyOpen(_that);case PullRequestNotCreated():
return notCreated(_that);case PullRequestReading():
return reading(_that);case PullRequestFailed():
return failed(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( PullRequestReady value)?  ready,TResult? Function( PullRequestUncommitted value)?  uncommitted,TResult? Function( PullRequestUnpublished value)?  unpublished,TResult? Function( PullRequestUntitled value)?  untitled,TResult? Function( PullRequestEmpty value)?  empty,TResult? Function( PullRequestAlreadyOpen value)?  alreadyOpen,TResult? Function( PullRequestNotCreated value)?  notCreated,TResult? Function( PullRequestReading value)?  reading,TResult? Function( PullRequestFailed value)?  failed,}){
final _that = this;
switch (_that) {
case PullRequestReady() when ready != null:
return ready(_that);case PullRequestUncommitted() when uncommitted != null:
return uncommitted(_that);case PullRequestUnpublished() when unpublished != null:
return unpublished(_that);case PullRequestUntitled() when untitled != null:
return untitled(_that);case PullRequestEmpty() when empty != null:
return empty(_that);case PullRequestAlreadyOpen() when alreadyOpen != null:
return alreadyOpen(_that);case PullRequestNotCreated() when notCreated != null:
return notCreated(_that);case PullRequestReading() when reading != null:
return reading(_that);case PullRequestFailed() when failed != null:
return failed(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( int commits)?  ready,TResult Function( int documents)?  uncommitted,TResult Function( int commits,  bool hasUpstream)?  unpublished,TResult Function()?  untitled,TResult Function()?  empty,TResult Function( int number)?  alreadyOpen,TResult Function( AppFailure failure)?  notCreated,TResult Function()?  reading,TResult Function()?  failed,required TResult orElse(),}) {final _that = this;
switch (_that) {
case PullRequestReady() when ready != null:
return ready(_that.commits);case PullRequestUncommitted() when uncommitted != null:
return uncommitted(_that.documents);case PullRequestUnpublished() when unpublished != null:
return unpublished(_that.commits,_that.hasUpstream);case PullRequestUntitled() when untitled != null:
return untitled();case PullRequestEmpty() when empty != null:
return empty();case PullRequestAlreadyOpen() when alreadyOpen != null:
return alreadyOpen(_that.number);case PullRequestNotCreated() when notCreated != null:
return notCreated(_that.failure);case PullRequestReading() when reading != null:
return reading();case PullRequestFailed() when failed != null:
return failed();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( int commits)  ready,required TResult Function( int documents)  uncommitted,required TResult Function( int commits,  bool hasUpstream)  unpublished,required TResult Function()  untitled,required TResult Function()  empty,required TResult Function( int number)  alreadyOpen,required TResult Function( AppFailure failure)  notCreated,required TResult Function()  reading,required TResult Function()  failed,}) {final _that = this;
switch (_that) {
case PullRequestReady():
return ready(_that.commits);case PullRequestUncommitted():
return uncommitted(_that.documents);case PullRequestUnpublished():
return unpublished(_that.commits,_that.hasUpstream);case PullRequestUntitled():
return untitled();case PullRequestEmpty():
return empty();case PullRequestAlreadyOpen():
return alreadyOpen(_that.number);case PullRequestNotCreated():
return notCreated(_that.failure);case PullRequestReading():
return reading();case PullRequestFailed():
return failed();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( int commits)?  ready,TResult? Function( int documents)?  uncommitted,TResult? Function( int commits,  bool hasUpstream)?  unpublished,TResult? Function()?  untitled,TResult? Function()?  empty,TResult? Function( int number)?  alreadyOpen,TResult? Function( AppFailure failure)?  notCreated,TResult? Function()?  reading,TResult? Function()?  failed,}) {final _that = this;
switch (_that) {
case PullRequestReady() when ready != null:
return ready(_that.commits);case PullRequestUncommitted() when uncommitted != null:
return uncommitted(_that.documents);case PullRequestUnpublished() when unpublished != null:
return unpublished(_that.commits,_that.hasUpstream);case PullRequestUntitled() when untitled != null:
return untitled();case PullRequestEmpty() when empty != null:
return empty();case PullRequestAlreadyOpen() when alreadyOpen != null:
return alreadyOpen(_that.number);case PullRequestNotCreated() when notCreated != null:
return notCreated(_that.failure);case PullRequestReading() when reading != null:
return reading();case PullRequestFailed() when failed != null:
return failed();case _:
  return null;

}
}

}

/// @nodoc


class PullRequestReady extends PullRequestStatus {
  const PullRequestReady({required this.commits}): super._();
  

 final  int commits;

/// Create a copy of PullRequestStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PullRequestReadyCopyWith<PullRequestReady> get copyWith => _$PullRequestReadyCopyWithImpl<PullRequestReady>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PullRequestReady&&(identical(other.commits, commits) || other.commits == commits));
}


@override
int get hashCode => Object.hash(runtimeType,commits);

@override
String toString() {
  return 'PullRequestStatus.ready(commits: $commits)';
}


}

/// @nodoc
abstract mixin class $PullRequestReadyCopyWith<$Res> implements $PullRequestStatusCopyWith<$Res> {
  factory $PullRequestReadyCopyWith(PullRequestReady value, $Res Function(PullRequestReady) _then) = _$PullRequestReadyCopyWithImpl;
@useResult
$Res call({
 int commits
});




}
/// @nodoc
class _$PullRequestReadyCopyWithImpl<$Res>
    implements $PullRequestReadyCopyWith<$Res> {
  _$PullRequestReadyCopyWithImpl(this._self, this._then);

  final PullRequestReady _self;
  final $Res Function(PullRequestReady) _then;

/// Create a copy of PullRequestStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? commits = null,}) {
  return _then(PullRequestReady(
commits: null == commits ? _self.commits : commits // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class PullRequestUncommitted extends PullRequestStatus {
  const PullRequestUncommitted({required this.documents}): super._();
  

 final  int documents;

/// Create a copy of PullRequestStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PullRequestUncommittedCopyWith<PullRequestUncommitted> get copyWith => _$PullRequestUncommittedCopyWithImpl<PullRequestUncommitted>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PullRequestUncommitted&&(identical(other.documents, documents) || other.documents == documents));
}


@override
int get hashCode => Object.hash(runtimeType,documents);

@override
String toString() {
  return 'PullRequestStatus.uncommitted(documents: $documents)';
}


}

/// @nodoc
abstract mixin class $PullRequestUncommittedCopyWith<$Res> implements $PullRequestStatusCopyWith<$Res> {
  factory $PullRequestUncommittedCopyWith(PullRequestUncommitted value, $Res Function(PullRequestUncommitted) _then) = _$PullRequestUncommittedCopyWithImpl;
@useResult
$Res call({
 int documents
});




}
/// @nodoc
class _$PullRequestUncommittedCopyWithImpl<$Res>
    implements $PullRequestUncommittedCopyWith<$Res> {
  _$PullRequestUncommittedCopyWithImpl(this._self, this._then);

  final PullRequestUncommitted _self;
  final $Res Function(PullRequestUncommitted) _then;

/// Create a copy of PullRequestStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? documents = null,}) {
  return _then(PullRequestUncommitted(
documents: null == documents ? _self.documents : documents // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class PullRequestUnpublished extends PullRequestStatus {
  const PullRequestUnpublished({required this.commits, required this.hasUpstream}): super._();
  

 final  int commits;
 final  bool hasUpstream;

/// Create a copy of PullRequestStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PullRequestUnpublishedCopyWith<PullRequestUnpublished> get copyWith => _$PullRequestUnpublishedCopyWithImpl<PullRequestUnpublished>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PullRequestUnpublished&&(identical(other.commits, commits) || other.commits == commits)&&(identical(other.hasUpstream, hasUpstream) || other.hasUpstream == hasUpstream));
}


@override
int get hashCode => Object.hash(runtimeType,commits,hasUpstream);

@override
String toString() {
  return 'PullRequestStatus.unpublished(commits: $commits, hasUpstream: $hasUpstream)';
}


}

/// @nodoc
abstract mixin class $PullRequestUnpublishedCopyWith<$Res> implements $PullRequestStatusCopyWith<$Res> {
  factory $PullRequestUnpublishedCopyWith(PullRequestUnpublished value, $Res Function(PullRequestUnpublished) _then) = _$PullRequestUnpublishedCopyWithImpl;
@useResult
$Res call({
 int commits, bool hasUpstream
});




}
/// @nodoc
class _$PullRequestUnpublishedCopyWithImpl<$Res>
    implements $PullRequestUnpublishedCopyWith<$Res> {
  _$PullRequestUnpublishedCopyWithImpl(this._self, this._then);

  final PullRequestUnpublished _self;
  final $Res Function(PullRequestUnpublished) _then;

/// Create a copy of PullRequestStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? commits = null,Object? hasUpstream = null,}) {
  return _then(PullRequestUnpublished(
commits: null == commits ? _self.commits : commits // ignore: cast_nullable_to_non_nullable
as int,hasUpstream: null == hasUpstream ? _self.hasUpstream : hasUpstream // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class PullRequestUntitled extends PullRequestStatus {
  const PullRequestUntitled(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PullRequestUntitled);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PullRequestStatus.untitled()';
}


}




/// @nodoc


class PullRequestEmpty extends PullRequestStatus {
  const PullRequestEmpty(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PullRequestEmpty);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PullRequestStatus.empty()';
}


}




/// @nodoc


class PullRequestAlreadyOpen extends PullRequestStatus {
  const PullRequestAlreadyOpen({required this.number}): super._();
  

 final  int number;

/// Create a copy of PullRequestStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PullRequestAlreadyOpenCopyWith<PullRequestAlreadyOpen> get copyWith => _$PullRequestAlreadyOpenCopyWithImpl<PullRequestAlreadyOpen>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PullRequestAlreadyOpen&&(identical(other.number, number) || other.number == number));
}


@override
int get hashCode => Object.hash(runtimeType,number);

@override
String toString() {
  return 'PullRequestStatus.alreadyOpen(number: $number)';
}


}

/// @nodoc
abstract mixin class $PullRequestAlreadyOpenCopyWith<$Res> implements $PullRequestStatusCopyWith<$Res> {
  factory $PullRequestAlreadyOpenCopyWith(PullRequestAlreadyOpen value, $Res Function(PullRequestAlreadyOpen) _then) = _$PullRequestAlreadyOpenCopyWithImpl;
@useResult
$Res call({
 int number
});




}
/// @nodoc
class _$PullRequestAlreadyOpenCopyWithImpl<$Res>
    implements $PullRequestAlreadyOpenCopyWith<$Res> {
  _$PullRequestAlreadyOpenCopyWithImpl(this._self, this._then);

  final PullRequestAlreadyOpen _self;
  final $Res Function(PullRequestAlreadyOpen) _then;

/// Create a copy of PullRequestStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? number = null,}) {
  return _then(PullRequestAlreadyOpen(
number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class PullRequestNotCreated extends PullRequestStatus {
  const PullRequestNotCreated({required this.failure}): super._();
  

 final  AppFailure failure;

/// Create a copy of PullRequestStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PullRequestNotCreatedCopyWith<PullRequestNotCreated> get copyWith => _$PullRequestNotCreatedCopyWithImpl<PullRequestNotCreated>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PullRequestNotCreated&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,failure);

@override
String toString() {
  return 'PullRequestStatus.notCreated(failure: $failure)';
}


}

/// @nodoc
abstract mixin class $PullRequestNotCreatedCopyWith<$Res> implements $PullRequestStatusCopyWith<$Res> {
  factory $PullRequestNotCreatedCopyWith(PullRequestNotCreated value, $Res Function(PullRequestNotCreated) _then) = _$PullRequestNotCreatedCopyWithImpl;
@useResult
$Res call({
 AppFailure failure
});




}
/// @nodoc
class _$PullRequestNotCreatedCopyWithImpl<$Res>
    implements $PullRequestNotCreatedCopyWith<$Res> {
  _$PullRequestNotCreatedCopyWithImpl(this._self, this._then);

  final PullRequestNotCreated _self;
  final $Res Function(PullRequestNotCreated) _then;

/// Create a copy of PullRequestStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? failure = null,}) {
  return _then(PullRequestNotCreated(
failure: null == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as AppFailure,
  ));
}


}

/// @nodoc


class PullRequestReading extends PullRequestStatus {
  const PullRequestReading(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PullRequestReading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PullRequestStatus.reading()';
}


}




/// @nodoc


class PullRequestFailed extends PullRequestStatus {
  const PullRequestFailed(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PullRequestFailed);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PullRequestStatus.failed()';
}


}




// dart format on
