// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workspace_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WorkspaceState {

/// Whether the left column is on screen.
 bool get showingExplorer;/// Whether the right column is.
 bool get showingAside;/// How wide the left column is, or null for the width it opens at.
///
/// The reader's, dragged from the divider beside it: it opens at a width
/// the tree reads well at, and somebody reading search results widens it
/// (`docs/product/workspace/regions/doc.md`).
 double? get explorerWidth;/// Which of the right column's panels is showing, by the id the module
/// registered it under; null means the first one.
///
/// The column's own state, not the document's — opening another file
/// does not change it.
 String? get asidePanel;
/// Create a copy of WorkspaceState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkspaceStateCopyWith<WorkspaceState> get copyWith => _$WorkspaceStateCopyWithImpl<WorkspaceState>(this as WorkspaceState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkspaceState&&(identical(other.showingExplorer, showingExplorer) || other.showingExplorer == showingExplorer)&&(identical(other.showingAside, showingAside) || other.showingAside == showingAside)&&(identical(other.explorerWidth, explorerWidth) || other.explorerWidth == explorerWidth)&&(identical(other.asidePanel, asidePanel) || other.asidePanel == asidePanel));
}


@override
int get hashCode => Object.hash(runtimeType,showingExplorer,showingAside,explorerWidth,asidePanel);

@override
String toString() {
  return 'WorkspaceState(showingExplorer: $showingExplorer, showingAside: $showingAside, explorerWidth: $explorerWidth, asidePanel: $asidePanel)';
}


}

/// @nodoc
abstract mixin class $WorkspaceStateCopyWith<$Res>  {
  factory $WorkspaceStateCopyWith(WorkspaceState value, $Res Function(WorkspaceState) _then) = _$WorkspaceStateCopyWithImpl;
@useResult
$Res call({
 bool showingExplorer, bool showingAside, double? explorerWidth, String? asidePanel
});




}
/// @nodoc
class _$WorkspaceStateCopyWithImpl<$Res>
    implements $WorkspaceStateCopyWith<$Res> {
  _$WorkspaceStateCopyWithImpl(this._self, this._then);

  final WorkspaceState _self;
  final $Res Function(WorkspaceState) _then;

/// Create a copy of WorkspaceState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? showingExplorer = null,Object? showingAside = null,Object? explorerWidth = freezed,Object? asidePanel = freezed,}) {
  return _then(_self.copyWith(
showingExplorer: null == showingExplorer ? _self.showingExplorer : showingExplorer // ignore: cast_nullable_to_non_nullable
as bool,showingAside: null == showingAside ? _self.showingAside : showingAside // ignore: cast_nullable_to_non_nullable
as bool,explorerWidth: freezed == explorerWidth ? _self.explorerWidth : explorerWidth // ignore: cast_nullable_to_non_nullable
as double?,asidePanel: freezed == asidePanel ? _self.asidePanel : asidePanel // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [WorkspaceState].
extension WorkspaceStatePatterns on WorkspaceState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkspaceState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkspaceState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkspaceState value)  $default,){
final _that = this;
switch (_that) {
case _WorkspaceState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkspaceState value)?  $default,){
final _that = this;
switch (_that) {
case _WorkspaceState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool showingExplorer,  bool showingAside,  double? explorerWidth,  String? asidePanel)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkspaceState() when $default != null:
return $default(_that.showingExplorer,_that.showingAside,_that.explorerWidth,_that.asidePanel);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool showingExplorer,  bool showingAside,  double? explorerWidth,  String? asidePanel)  $default,) {final _that = this;
switch (_that) {
case _WorkspaceState():
return $default(_that.showingExplorer,_that.showingAside,_that.explorerWidth,_that.asidePanel);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool showingExplorer,  bool showingAside,  double? explorerWidth,  String? asidePanel)?  $default,) {final _that = this;
switch (_that) {
case _WorkspaceState() when $default != null:
return $default(_that.showingExplorer,_that.showingAside,_that.explorerWidth,_that.asidePanel);case _:
  return null;

}
}

}

/// @nodoc


class _WorkspaceState implements WorkspaceState {
  const _WorkspaceState({this.showingExplorer = true, this.showingAside = true, this.explorerWidth, this.asidePanel});
  

/// Whether the left column is on screen.
@override@JsonKey() final  bool showingExplorer;
/// Whether the right column is.
@override@JsonKey() final  bool showingAside;
/// How wide the left column is, or null for the width it opens at.
///
/// The reader's, dragged from the divider beside it: it opens at a width
/// the tree reads well at, and somebody reading search results widens it
/// (`docs/product/workspace/regions/doc.md`).
@override final  double? explorerWidth;
/// Which of the right column's panels is showing, by the id the module
/// registered it under; null means the first one.
///
/// The column's own state, not the document's — opening another file
/// does not change it.
@override final  String? asidePanel;

/// Create a copy of WorkspaceState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkspaceStateCopyWith<_WorkspaceState> get copyWith => __$WorkspaceStateCopyWithImpl<_WorkspaceState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkspaceState&&(identical(other.showingExplorer, showingExplorer) || other.showingExplorer == showingExplorer)&&(identical(other.showingAside, showingAside) || other.showingAside == showingAside)&&(identical(other.explorerWidth, explorerWidth) || other.explorerWidth == explorerWidth)&&(identical(other.asidePanel, asidePanel) || other.asidePanel == asidePanel));
}


@override
int get hashCode => Object.hash(runtimeType,showingExplorer,showingAside,explorerWidth,asidePanel);

@override
String toString() {
  return 'WorkspaceState(showingExplorer: $showingExplorer, showingAside: $showingAside, explorerWidth: $explorerWidth, asidePanel: $asidePanel)';
}


}

/// @nodoc
abstract mixin class _$WorkspaceStateCopyWith<$Res> implements $WorkspaceStateCopyWith<$Res> {
  factory _$WorkspaceStateCopyWith(_WorkspaceState value, $Res Function(_WorkspaceState) _then) = __$WorkspaceStateCopyWithImpl;
@override @useResult
$Res call({
 bool showingExplorer, bool showingAside, double? explorerWidth, String? asidePanel
});




}
/// @nodoc
class __$WorkspaceStateCopyWithImpl<$Res>
    implements _$WorkspaceStateCopyWith<$Res> {
  __$WorkspaceStateCopyWithImpl(this._self, this._then);

  final _WorkspaceState _self;
  final $Res Function(_WorkspaceState) _then;

/// Create a copy of WorkspaceState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? showingExplorer = null,Object? showingAside = null,Object? explorerWidth = freezed,Object? asidePanel = freezed,}) {
  return _then(_WorkspaceState(
showingExplorer: null == showingExplorer ? _self.showingExplorer : showingExplorer // ignore: cast_nullable_to_non_nullable
as bool,showingAside: null == showingAside ? _self.showingAside : showingAside // ignore: cast_nullable_to_non_nullable
as bool,explorerWidth: freezed == explorerWidth ? _self.explorerWidth : explorerWidth // ignore: cast_nullable_to_non_nullable
as double?,asidePanel: freezed == asidePanel ? _self.asidePanel : asidePanel // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
