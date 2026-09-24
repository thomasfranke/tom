// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'editor_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EditorState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EditorState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'EditorState()';
}


}

/// @nodoc
class $EditorStateCopyWith<$Res>  {
$EditorStateCopyWith(EditorState _, $Res Function(EditorState) __);
}


/// Adds pattern-matching-related methods to [EditorState].
extension EditorStatePatterns on EditorState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( EditorEmpty value)?  empty,TResult Function( EditorLoading value)?  loading,TResult Function( EditorReady value)?  ready,TResult Function( EditorFailed value)?  failed,required TResult orElse(),}){
final _that = this;
switch (_that) {
case EditorEmpty() when empty != null:
return empty(_that);case EditorLoading() when loading != null:
return loading(_that);case EditorReady() when ready != null:
return ready(_that);case EditorFailed() when failed != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( EditorEmpty value)  empty,required TResult Function( EditorLoading value)  loading,required TResult Function( EditorReady value)  ready,required TResult Function( EditorFailed value)  failed,}){
final _that = this;
switch (_that) {
case EditorEmpty():
return empty(_that);case EditorLoading():
return loading(_that);case EditorReady():
return ready(_that);case EditorFailed():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( EditorEmpty value)?  empty,TResult? Function( EditorLoading value)?  loading,TResult? Function( EditorReady value)?  ready,TResult? Function( EditorFailed value)?  failed,}){
final _that = this;
switch (_that) {
case EditorEmpty() when empty != null:
return empty(_that);case EditorLoading() when loading != null:
return loading(_that);case EditorReady() when ready != null:
return ready(_that);case EditorFailed() when failed != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  empty,TResult Function()?  loading,TResult Function( DocumentEntity saved,  String source,  bool isSaving,  AppFailure? saveFailure)?  ready,TResult Function( AppFailure failure)?  failed,required TResult orElse(),}) {final _that = this;
switch (_that) {
case EditorEmpty() when empty != null:
return empty();case EditorLoading() when loading != null:
return loading();case EditorReady() when ready != null:
return ready(_that.saved,_that.source,_that.isSaving,_that.saveFailure);case EditorFailed() when failed != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  empty,required TResult Function()  loading,required TResult Function( DocumentEntity saved,  String source,  bool isSaving,  AppFailure? saveFailure)  ready,required TResult Function( AppFailure failure)  failed,}) {final _that = this;
switch (_that) {
case EditorEmpty():
return empty();case EditorLoading():
return loading();case EditorReady():
return ready(_that.saved,_that.source,_that.isSaving,_that.saveFailure);case EditorFailed():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  empty,TResult? Function()?  loading,TResult? Function( DocumentEntity saved,  String source,  bool isSaving,  AppFailure? saveFailure)?  ready,TResult? Function( AppFailure failure)?  failed,}) {final _that = this;
switch (_that) {
case EditorEmpty() when empty != null:
return empty();case EditorLoading() when loading != null:
return loading();case EditorReady() when ready != null:
return ready(_that.saved,_that.source,_that.isSaving,_that.saveFailure);case EditorFailed() when failed != null:
return failed(_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class EditorEmpty extends EditorState {
  const EditorEmpty(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EditorEmpty);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'EditorState.empty()';
}


}




/// @nodoc


class EditorLoading extends EditorState {
  const EditorLoading(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EditorLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'EditorState.loading()';
}


}




/// @nodoc


class EditorReady extends EditorState {
  const EditorReady({required this.saved, required this.source, this.isSaving = false, this.saveFailure}): super._();
  

/// The document as the disk last agreed it was.
///
/// What the buffer is compared against, and what a save replaces. **The
/// file is the truth**, so this is the app's record of that truth and
/// never a second one.
 final  DocumentEntity saved;
/// The text being edited, which is the file's content until it is not.
 final  String source;
/// Whether a write is in flight.
@JsonKey() final  bool isSaving;
/// Why the last save did not land, or null when it did.
///
/// A save that fails silently is the one thing a text editor may never
/// do: the buffer still holds work and the file does not.
 final  AppFailure? saveFailure;

/// Create a copy of EditorState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EditorReadyCopyWith<EditorReady> get copyWith => _$EditorReadyCopyWithImpl<EditorReady>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EditorReady&&(identical(other.saved, saved) || other.saved == saved)&&(identical(other.source, source) || other.source == source)&&(identical(other.isSaving, isSaving) || other.isSaving == isSaving)&&(identical(other.saveFailure, saveFailure) || other.saveFailure == saveFailure));
}


@override
int get hashCode => Object.hash(runtimeType,saved,source,isSaving,saveFailure);

@override
String toString() {
  return 'EditorState.ready(saved: $saved, source: $source, isSaving: $isSaving, saveFailure: $saveFailure)';
}


}

/// @nodoc
abstract mixin class $EditorReadyCopyWith<$Res> implements $EditorStateCopyWith<$Res> {
  factory $EditorReadyCopyWith(EditorReady value, $Res Function(EditorReady) _then) = _$EditorReadyCopyWithImpl;
@useResult
$Res call({
 DocumentEntity saved, String source, bool isSaving, AppFailure? saveFailure
});


$DocumentEntityCopyWith<$Res> get saved;

}
/// @nodoc
class _$EditorReadyCopyWithImpl<$Res>
    implements $EditorReadyCopyWith<$Res> {
  _$EditorReadyCopyWithImpl(this._self, this._then);

  final EditorReady _self;
  final $Res Function(EditorReady) _then;

/// Create a copy of EditorState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? saved = null,Object? source = null,Object? isSaving = null,Object? saveFailure = freezed,}) {
  return _then(EditorReady(
saved: null == saved ? _self.saved : saved // ignore: cast_nullable_to_non_nullable
as DocumentEntity,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,saveFailure: freezed == saveFailure ? _self.saveFailure : saveFailure // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}

/// Create a copy of EditorState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DocumentEntityCopyWith<$Res> get saved {
  
  return $DocumentEntityCopyWith<$Res>(_self.saved, (value) {
    return _then(_self.copyWith(saved: value));
  });
}
}

/// @nodoc


class EditorFailed extends EditorState {
  const EditorFailed(this.failure): super._();
  

 final  AppFailure failure;

/// Create a copy of EditorState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EditorFailedCopyWith<EditorFailed> get copyWith => _$EditorFailedCopyWithImpl<EditorFailed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EditorFailed&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,failure);

@override
String toString() {
  return 'EditorState.failed(failure: $failure)';
}


}

/// @nodoc
abstract mixin class $EditorFailedCopyWith<$Res> implements $EditorStateCopyWith<$Res> {
  factory $EditorFailedCopyWith(EditorFailed value, $Res Function(EditorFailed) _then) = _$EditorFailedCopyWithImpl;
@useResult
$Res call({
 AppFailure failure
});




}
/// @nodoc
class _$EditorFailedCopyWithImpl<$Res>
    implements $EditorFailedCopyWith<$Res> {
  _$EditorFailedCopyWithImpl(this._self, this._then);

  final EditorFailed _self;
  final $Res Function(EditorFailed) _then;

/// Create a copy of EditorState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? failure = null,}) {
  return _then(EditorFailed(
null == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as AppFailure,
  ));
}


}

// dart format on
