// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'space.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Space {

/// Absolute path to the folder the user opened; the identity of the
/// space.
 String get root;/// Absolute path to the enclosing Git repository.
 String get repositoryRoot;/// What the space is called in the UI.
///
/// Derived from the folder name unless configured otherwise — see
/// [nameOfFolder], which is what derives it.
 String get name;
/// Create a copy of Space
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SpaceCopyWith<Space> get copyWith => _$SpaceCopyWithImpl<Space>(this as Space, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Space&&(identical(other.root, root) || other.root == root)&&(identical(other.repositoryRoot, repositoryRoot) || other.repositoryRoot == repositoryRoot)&&(identical(other.name, name) || other.name == name));
}


@override
int get hashCode => Object.hash(runtimeType,root,repositoryRoot,name);

@override
String toString() {
  return 'Space(root: $root, repositoryRoot: $repositoryRoot, name: $name)';
}


}

/// @nodoc
abstract mixin class $SpaceCopyWith<$Res>  {
  factory $SpaceCopyWith(Space value, $Res Function(Space) _then) = _$SpaceCopyWithImpl;
@useResult
$Res call({
 String root, String repositoryRoot, String name
});




}
/// @nodoc
class _$SpaceCopyWithImpl<$Res>
    implements $SpaceCopyWith<$Res> {
  _$SpaceCopyWithImpl(this._self, this._then);

  final Space _self;
  final $Res Function(Space) _then;

/// Create a copy of Space
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? root = null,Object? repositoryRoot = null,Object? name = null,}) {
  return _then(_self.copyWith(
root: null == root ? _self.root : root // ignore: cast_nullable_to_non_nullable
as String,repositoryRoot: null == repositoryRoot ? _self.repositoryRoot : repositoryRoot // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Space].
extension SpacePatterns on Space {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Space value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Space() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Space value)  $default,){
final _that = this;
switch (_that) {
case _Space():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Space value)?  $default,){
final _that = this;
switch (_that) {
case _Space() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String root,  String repositoryRoot,  String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Space() when $default != null:
return $default(_that.root,_that.repositoryRoot,_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String root,  String repositoryRoot,  String name)  $default,) {final _that = this;
switch (_that) {
case _Space():
return $default(_that.root,_that.repositoryRoot,_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String root,  String repositoryRoot,  String name)?  $default,) {final _that = this;
switch (_that) {
case _Space() when $default != null:
return $default(_that.root,_that.repositoryRoot,_that.name);case _:
  return null;

}
}

}

/// @nodoc


class _Space extends Space {
   _Space({required this.root, required this.repositoryRoot, required this.name}): assert(_isEnclosedBy(root, repositoryRoot), 'repositoryRoot must enclose root'),super._();
  

/// Absolute path to the folder the user opened; the identity of the
/// space.
@override final  String root;
/// Absolute path to the enclosing Git repository.
@override final  String repositoryRoot;
/// What the space is called in the UI.
///
/// Derived from the folder name unless configured otherwise — see
/// [nameOfFolder], which is what derives it.
@override final  String name;

/// Create a copy of Space
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SpaceCopyWith<_Space> get copyWith => __$SpaceCopyWithImpl<_Space>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Space&&(identical(other.root, root) || other.root == root)&&(identical(other.repositoryRoot, repositoryRoot) || other.repositoryRoot == repositoryRoot)&&(identical(other.name, name) || other.name == name));
}


@override
int get hashCode => Object.hash(runtimeType,root,repositoryRoot,name);

@override
String toString() {
  return 'Space(root: $root, repositoryRoot: $repositoryRoot, name: $name)';
}


}

/// @nodoc
abstract mixin class _$SpaceCopyWith<$Res> implements $SpaceCopyWith<$Res> {
  factory _$SpaceCopyWith(_Space value, $Res Function(_Space) _then) = __$SpaceCopyWithImpl;
@override @useResult
$Res call({
 String root, String repositoryRoot, String name
});




}
/// @nodoc
class __$SpaceCopyWithImpl<$Res>
    implements _$SpaceCopyWith<$Res> {
  __$SpaceCopyWithImpl(this._self, this._then);

  final _Space _self;
  final $Res Function(_Space) _then;

/// Create a copy of Space
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? root = null,Object? repositoryRoot = null,Object? name = null,}) {
  return _then(_Space(
root: null == root ? _self.root : root // ignore: cast_nullable_to_non_nullable
as String,repositoryRoot: null == repositoryRoot ? _self.repositoryRoot : repositoryRoot // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
