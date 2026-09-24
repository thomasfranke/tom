// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'preview_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PreviewState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PreviewState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PreviewState()';
}


}

/// @nodoc
class $PreviewStateCopyWith<$Res>  {
$PreviewStateCopyWith(PreviewState _, $Res Function(PreviewState) __);
}


/// Adds pattern-matching-related methods to [PreviewState].
extension PreviewStatePatterns on PreviewState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( PreviewEmpty value)?  empty,TResult Function( PreviewLoading value)?  loading,TResult Function( PreviewReady value)?  ready,TResult Function( PreviewFailed value)?  failed,required TResult orElse(),}){
final _that = this;
switch (_that) {
case PreviewEmpty() when empty != null:
return empty(_that);case PreviewLoading() when loading != null:
return loading(_that);case PreviewReady() when ready != null:
return ready(_that);case PreviewFailed() when failed != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( PreviewEmpty value)  empty,required TResult Function( PreviewLoading value)  loading,required TResult Function( PreviewReady value)  ready,required TResult Function( PreviewFailed value)  failed,}){
final _that = this;
switch (_that) {
case PreviewEmpty():
return empty(_that);case PreviewLoading():
return loading(_that);case PreviewReady():
return ready(_that);case PreviewFailed():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( PreviewEmpty value)?  empty,TResult? Function( PreviewLoading value)?  loading,TResult? Function( PreviewReady value)?  ready,TResult? Function( PreviewFailed value)?  failed,}){
final _that = this;
switch (_that) {
case PreviewEmpty() when empty != null:
return empty(_that);case PreviewLoading() when loading != null:
return loading(_that);case PreviewReady() when ready != null:
return ready(_that);case PreviewFailed() when failed != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  empty,TResult Function()?  loading,TResult Function( ParsedDocumentValueObject document,  DocumentDiffValueObject? diff)?  ready,TResult Function( AppFailure failure)?  failed,required TResult orElse(),}) {final _that = this;
switch (_that) {
case PreviewEmpty() when empty != null:
return empty();case PreviewLoading() when loading != null:
return loading();case PreviewReady() when ready != null:
return ready(_that.document,_that.diff);case PreviewFailed() when failed != null:
return failed(_that.failure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  empty,required TResult Function()  loading,required TResult Function( ParsedDocumentValueObject document,  DocumentDiffValueObject? diff)  ready,required TResult Function( AppFailure failure)  failed,}) {final _that = this;
switch (_that) {
case PreviewEmpty():
return empty();case PreviewLoading():
return loading();case PreviewReady():
return ready(_that.document,_that.diff);case PreviewFailed():
return failed(_that.failure);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  empty,TResult? Function()?  loading,TResult? Function( ParsedDocumentValueObject document,  DocumentDiffValueObject? diff)?  ready,TResult? Function( AppFailure failure)?  failed,}) {final _that = this;
switch (_that) {
case PreviewEmpty() when empty != null:
return empty();case PreviewLoading() when loading != null:
return loading();case PreviewReady() when ready != null:
return ready(_that.document,_that.diff);case PreviewFailed() when failed != null:
return failed(_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class PreviewEmpty implements PreviewState {
  const PreviewEmpty();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PreviewEmpty);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PreviewState.empty()';
}


}




/// @nodoc


class PreviewLoading implements PreviewState {
  const PreviewLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PreviewLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PreviewState.loading()';
}


}




/// @nodoc


class PreviewReady implements PreviewState {
  const PreviewReady(this.document, {this.diff});
  

 final  ParsedDocumentValueObject document;
/// What it changed against `HEAD`, once git has said.
///
/// Null until then, and null for a version being read: the text is
/// already here and a git call is a process, so the pane draws the
/// document first and decorates it when the answer lands
/// (`docs/product/diff/rendered-diff/doc.md`).
 final  DocumentDiffValueObject? diff;

/// Create a copy of PreviewState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PreviewReadyCopyWith<PreviewReady> get copyWith => _$PreviewReadyCopyWithImpl<PreviewReady>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PreviewReady&&(identical(other.document, document) || other.document == document)&&(identical(other.diff, diff) || other.diff == diff));
}


@override
int get hashCode => Object.hash(runtimeType,document,diff);

@override
String toString() {
  return 'PreviewState.ready(document: $document, diff: $diff)';
}


}

/// @nodoc
abstract mixin class $PreviewReadyCopyWith<$Res> implements $PreviewStateCopyWith<$Res> {
  factory $PreviewReadyCopyWith(PreviewReady value, $Res Function(PreviewReady) _then) = _$PreviewReadyCopyWithImpl;
@useResult
$Res call({
 ParsedDocumentValueObject document, DocumentDiffValueObject? diff
});


$ParsedDocumentValueObjectCopyWith<$Res> get document;$DocumentDiffValueObjectCopyWith<$Res>? get diff;

}
/// @nodoc
class _$PreviewReadyCopyWithImpl<$Res>
    implements $PreviewReadyCopyWith<$Res> {
  _$PreviewReadyCopyWithImpl(this._self, this._then);

  final PreviewReady _self;
  final $Res Function(PreviewReady) _then;

/// Create a copy of PreviewState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? document = null,Object? diff = freezed,}) {
  return _then(PreviewReady(
null == document ? _self.document : document // ignore: cast_nullable_to_non_nullable
as ParsedDocumentValueObject,diff: freezed == diff ? _self.diff : diff // ignore: cast_nullable_to_non_nullable
as DocumentDiffValueObject?,
  ));
}

/// Create a copy of PreviewState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ParsedDocumentValueObjectCopyWith<$Res> get document {
  
  return $ParsedDocumentValueObjectCopyWith<$Res>(_self.document, (value) {
    return _then(_self.copyWith(document: value));
  });
}/// Create a copy of PreviewState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DocumentDiffValueObjectCopyWith<$Res>? get diff {
    if (_self.diff == null) {
    return null;
  }

  return $DocumentDiffValueObjectCopyWith<$Res>(_self.diff!, (value) {
    return _then(_self.copyWith(diff: value));
  });
}
}

/// @nodoc


class PreviewFailed implements PreviewState {
  const PreviewFailed(this.failure);
  

 final  AppFailure failure;

/// Create a copy of PreviewState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PreviewFailedCopyWith<PreviewFailed> get copyWith => _$PreviewFailedCopyWithImpl<PreviewFailed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PreviewFailed&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,failure);

@override
String toString() {
  return 'PreviewState.failed(failure: $failure)';
}


}

/// @nodoc
abstract mixin class $PreviewFailedCopyWith<$Res> implements $PreviewStateCopyWith<$Res> {
  factory $PreviewFailedCopyWith(PreviewFailed value, $Res Function(PreviewFailed) _then) = _$PreviewFailedCopyWithImpl;
@useResult
$Res call({
 AppFailure failure
});




}
/// @nodoc
class _$PreviewFailedCopyWithImpl<$Res>
    implements $PreviewFailedCopyWith<$Res> {
  _$PreviewFailedCopyWithImpl(this._self, this._then);

  final PreviewFailed _self;
  final $Res Function(PreviewFailed) _then;

/// Create a copy of PreviewState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? failure = null,}) {
  return _then(PreviewFailed(
null == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as AppFailure,
  ));
}


}

// dart format on
