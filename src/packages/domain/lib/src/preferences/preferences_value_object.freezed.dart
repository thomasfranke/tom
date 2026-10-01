// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'preferences_value_object.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PreferencesValueObject {

/// Which theme the window draws; the platform's until somebody chooses.
 ThemeChoiceEnum get theme;/// Which language the app speaks.
 LanguageEnum get language;/// Whether the row above the document carries its seventeen buttons.
///
/// The row itself stays either way, because it is also where the view is
/// chosen; what this hides is the tools
/// (`docs/product/editor/formatting-shortcuts/doc.md`).
 bool get showingFormattingBar;
/// Create a copy of PreferencesValueObject
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PreferencesValueObjectCopyWith<PreferencesValueObject> get copyWith => _$PreferencesValueObjectCopyWithImpl<PreferencesValueObject>(this as PreferencesValueObject, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PreferencesValueObject&&(identical(other.theme, theme) || other.theme == theme)&&(identical(other.language, language) || other.language == language)&&(identical(other.showingFormattingBar, showingFormattingBar) || other.showingFormattingBar == showingFormattingBar));
}


@override
int get hashCode => Object.hash(runtimeType,theme,language,showingFormattingBar);

@override
String toString() {
  return 'PreferencesValueObject(theme: $theme, language: $language, showingFormattingBar: $showingFormattingBar)';
}


}

/// @nodoc
abstract mixin class $PreferencesValueObjectCopyWith<$Res>  {
  factory $PreferencesValueObjectCopyWith(PreferencesValueObject value, $Res Function(PreferencesValueObject) _then) = _$PreferencesValueObjectCopyWithImpl;
@useResult
$Res call({
 ThemeChoiceEnum theme, LanguageEnum language, bool showingFormattingBar
});




}
/// @nodoc
class _$PreferencesValueObjectCopyWithImpl<$Res>
    implements $PreferencesValueObjectCopyWith<$Res> {
  _$PreferencesValueObjectCopyWithImpl(this._self, this._then);

  final PreferencesValueObject _self;
  final $Res Function(PreferencesValueObject) _then;

/// Create a copy of PreferencesValueObject
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? theme = null,Object? language = null,Object? showingFormattingBar = null,}) {
  return _then(_self.copyWith(
theme: null == theme ? _self.theme : theme // ignore: cast_nullable_to_non_nullable
as ThemeChoiceEnum,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as LanguageEnum,showingFormattingBar: null == showingFormattingBar ? _self.showingFormattingBar : showingFormattingBar // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PreferencesValueObject].
extension PreferencesValueObjectPatterns on PreferencesValueObject {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PreferencesValueObject value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PreferencesValueObject() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PreferencesValueObject value)  $default,){
final _that = this;
switch (_that) {
case _PreferencesValueObject():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PreferencesValueObject value)?  $default,){
final _that = this;
switch (_that) {
case _PreferencesValueObject() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ThemeChoiceEnum theme,  LanguageEnum language,  bool showingFormattingBar)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PreferencesValueObject() when $default != null:
return $default(_that.theme,_that.language,_that.showingFormattingBar);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ThemeChoiceEnum theme,  LanguageEnum language,  bool showingFormattingBar)  $default,) {final _that = this;
switch (_that) {
case _PreferencesValueObject():
return $default(_that.theme,_that.language,_that.showingFormattingBar);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ThemeChoiceEnum theme,  LanguageEnum language,  bool showingFormattingBar)?  $default,) {final _that = this;
switch (_that) {
case _PreferencesValueObject() when $default != null:
return $default(_that.theme,_that.language,_that.showingFormattingBar);case _:
  return null;

}
}

}

/// @nodoc


class _PreferencesValueObject extends PreferencesValueObject {
  const _PreferencesValueObject({this.theme = ThemeChoiceEnum.system, this.language = LanguageEnum.english, this.showingFormattingBar = true}): super._();
  

/// Which theme the window draws; the platform's until somebody chooses.
@override@JsonKey() final  ThemeChoiceEnum theme;
/// Which language the app speaks.
@override@JsonKey() final  LanguageEnum language;
/// Whether the row above the document carries its seventeen buttons.
///
/// The row itself stays either way, because it is also where the view is
/// chosen; what this hides is the tools
/// (`docs/product/editor/formatting-shortcuts/doc.md`).
@override@JsonKey() final  bool showingFormattingBar;

/// Create a copy of PreferencesValueObject
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PreferencesValueObjectCopyWith<_PreferencesValueObject> get copyWith => __$PreferencesValueObjectCopyWithImpl<_PreferencesValueObject>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PreferencesValueObject&&(identical(other.theme, theme) || other.theme == theme)&&(identical(other.language, language) || other.language == language)&&(identical(other.showingFormattingBar, showingFormattingBar) || other.showingFormattingBar == showingFormattingBar));
}


@override
int get hashCode => Object.hash(runtimeType,theme,language,showingFormattingBar);

@override
String toString() {
  return 'PreferencesValueObject(theme: $theme, language: $language, showingFormattingBar: $showingFormattingBar)';
}


}

/// @nodoc
abstract mixin class _$PreferencesValueObjectCopyWith<$Res> implements $PreferencesValueObjectCopyWith<$Res> {
  factory _$PreferencesValueObjectCopyWith(_PreferencesValueObject value, $Res Function(_PreferencesValueObject) _then) = __$PreferencesValueObjectCopyWithImpl;
@override @useResult
$Res call({
 ThemeChoiceEnum theme, LanguageEnum language, bool showingFormattingBar
});




}
/// @nodoc
class __$PreferencesValueObjectCopyWithImpl<$Res>
    implements _$PreferencesValueObjectCopyWith<$Res> {
  __$PreferencesValueObjectCopyWithImpl(this._self, this._then);

  final _PreferencesValueObject _self;
  final $Res Function(_PreferencesValueObject) _then;

/// Create a copy of PreferencesValueObject
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? theme = null,Object? language = null,Object? showingFormattingBar = null,}) {
  return _then(_PreferencesValueObject(
theme: null == theme ? _self.theme : theme // ignore: cast_nullable_to_non_nullable
as ThemeChoiceEnum,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as LanguageEnum,showingFormattingBar: null == showingFormattingBar ? _self.showingFormattingBar : showingFormattingBar // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
