// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'document_tab.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DocumentTab {

 Object? get path;



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DocumentTab&&const DeepCollectionEquality().equals(other.path, path));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(path));

@override
String toString() {
  return 'DocumentTab(path: $path)';
}


}

/// @nodoc
class $DocumentTabCopyWith<$Res>  {
$DocumentTabCopyWith(DocumentTab _, $Res Function(DocumentTab) __);
}


/// Adds pattern-matching-related methods to [DocumentTab].
extension DocumentTabPatterns on DocumentTab {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( SpaceDocumentTab value)?  inSpace,TResult Function( OutsideDocumentTab value)?  outside,TResult Function( PreferencesDocumentTab value)?  preferences,required TResult orElse(),}){
final _that = this;
switch (_that) {
case SpaceDocumentTab() when inSpace != null:
return inSpace(_that);case OutsideDocumentTab() when outside != null:
return outside(_that);case PreferencesDocumentTab() when preferences != null:
return preferences(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( SpaceDocumentTab value)  inSpace,required TResult Function( OutsideDocumentTab value)  outside,required TResult Function( PreferencesDocumentTab value)  preferences,}){
final _that = this;
switch (_that) {
case SpaceDocumentTab():
return inSpace(_that);case OutsideDocumentTab():
return outside(_that);case PreferencesDocumentTab():
return preferences(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( SpaceDocumentTab value)?  inSpace,TResult? Function( OutsideDocumentTab value)?  outside,TResult? Function( PreferencesDocumentTab value)?  preferences,}){
final _that = this;
switch (_that) {
case SpaceDocumentTab() when inSpace != null:
return inSpace(_that);case OutsideDocumentTab() when outside != null:
return outside(_that);case PreferencesDocumentTab() when preferences != null:
return preferences(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( SpaceRelativePathValueObject path)?  inSpace,TResult Function( RepoRelativePathValueObject path)?  outside,TResult Function( SpaceRelativePathValueObject path)?  preferences,required TResult orElse(),}) {final _that = this;
switch (_that) {
case SpaceDocumentTab() when inSpace != null:
return inSpace(_that.path);case OutsideDocumentTab() when outside != null:
return outside(_that.path);case PreferencesDocumentTab() when preferences != null:
return preferences(_that.path);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( SpaceRelativePathValueObject path)  inSpace,required TResult Function( RepoRelativePathValueObject path)  outside,required TResult Function( SpaceRelativePathValueObject path)  preferences,}) {final _that = this;
switch (_that) {
case SpaceDocumentTab():
return inSpace(_that.path);case OutsideDocumentTab():
return outside(_that.path);case PreferencesDocumentTab():
return preferences(_that.path);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( SpaceRelativePathValueObject path)?  inSpace,TResult? Function( RepoRelativePathValueObject path)?  outside,TResult? Function( SpaceRelativePathValueObject path)?  preferences,}) {final _that = this;
switch (_that) {
case SpaceDocumentTab() when inSpace != null:
return inSpace(_that.path);case OutsideDocumentTab() when outside != null:
return outside(_that.path);case PreferencesDocumentTab() when preferences != null:
return preferences(_that.path);case _:
  return null;

}
}

}

/// @nodoc


class SpaceDocumentTab extends DocumentTab {
  const SpaceDocumentTab(this.path): super._();
  

@override final  SpaceRelativePathValueObject path;

/// Create a copy of DocumentTab
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SpaceDocumentTabCopyWith<SpaceDocumentTab> get copyWith => _$SpaceDocumentTabCopyWithImpl<SpaceDocumentTab>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SpaceDocumentTab&&(identical(other.path, path) || other.path == path));
}


@override
int get hashCode => Object.hash(runtimeType,path);

@override
String toString() {
  return 'DocumentTab.inSpace(path: $path)';
}


}

/// @nodoc
abstract mixin class $SpaceDocumentTabCopyWith<$Res> implements $DocumentTabCopyWith<$Res> {
  factory $SpaceDocumentTabCopyWith(SpaceDocumentTab value, $Res Function(SpaceDocumentTab) _then) = _$SpaceDocumentTabCopyWithImpl;
@useResult
$Res call({
 SpaceRelativePathValueObject path
});




}
/// @nodoc
class _$SpaceDocumentTabCopyWithImpl<$Res>
    implements $SpaceDocumentTabCopyWith<$Res> {
  _$SpaceDocumentTabCopyWithImpl(this._self, this._then);

  final SpaceDocumentTab _self;
  final $Res Function(SpaceDocumentTab) _then;

/// Create a copy of DocumentTab
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? path = null,}) {
  return _then(SpaceDocumentTab(
null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as SpaceRelativePathValueObject,
  ));
}


}

/// @nodoc


class OutsideDocumentTab extends DocumentTab {
  const OutsideDocumentTab(this.path): super._();
  

@override final  RepoRelativePathValueObject path;

/// Create a copy of DocumentTab
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OutsideDocumentTabCopyWith<OutsideDocumentTab> get copyWith => _$OutsideDocumentTabCopyWithImpl<OutsideDocumentTab>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OutsideDocumentTab&&(identical(other.path, path) || other.path == path));
}


@override
int get hashCode => Object.hash(runtimeType,path);

@override
String toString() {
  return 'DocumentTab.outside(path: $path)';
}


}

/// @nodoc
abstract mixin class $OutsideDocumentTabCopyWith<$Res> implements $DocumentTabCopyWith<$Res> {
  factory $OutsideDocumentTabCopyWith(OutsideDocumentTab value, $Res Function(OutsideDocumentTab) _then) = _$OutsideDocumentTabCopyWithImpl;
@useResult
$Res call({
 RepoRelativePathValueObject path
});




}
/// @nodoc
class _$OutsideDocumentTabCopyWithImpl<$Res>
    implements $OutsideDocumentTabCopyWith<$Res> {
  _$OutsideDocumentTabCopyWithImpl(this._self, this._then);

  final OutsideDocumentTab _self;
  final $Res Function(OutsideDocumentTab) _then;

/// Create a copy of DocumentTab
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? path = null,}) {
  return _then(OutsideDocumentTab(
null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as RepoRelativePathValueObject,
  ));
}


}

/// @nodoc


class PreferencesDocumentTab extends DocumentTab {
  const PreferencesDocumentTab(this.path): super._();
  

@override final  SpaceRelativePathValueObject path;

/// Create a copy of DocumentTab
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PreferencesDocumentTabCopyWith<PreferencesDocumentTab> get copyWith => _$PreferencesDocumentTabCopyWithImpl<PreferencesDocumentTab>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PreferencesDocumentTab&&(identical(other.path, path) || other.path == path));
}


@override
int get hashCode => Object.hash(runtimeType,path);

@override
String toString() {
  return 'DocumentTab.preferences(path: $path)';
}


}

/// @nodoc
abstract mixin class $PreferencesDocumentTabCopyWith<$Res> implements $DocumentTabCopyWith<$Res> {
  factory $PreferencesDocumentTabCopyWith(PreferencesDocumentTab value, $Res Function(PreferencesDocumentTab) _then) = _$PreferencesDocumentTabCopyWithImpl;
@useResult
$Res call({
 SpaceRelativePathValueObject path
});




}
/// @nodoc
class _$PreferencesDocumentTabCopyWithImpl<$Res>
    implements $PreferencesDocumentTabCopyWith<$Res> {
  _$PreferencesDocumentTabCopyWithImpl(this._self, this._then);

  final PreferencesDocumentTab _self;
  final $Res Function(PreferencesDocumentTab) _then;

/// Create a copy of DocumentTab
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? path = null,}) {
  return _then(PreferencesDocumentTab(
null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as SpaceRelativePathValueObject,
  ));
}


}

// dart format on
