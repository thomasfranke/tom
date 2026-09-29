/// Which of the two themes the window draws.
library;

/// The reader's choice of theme, or the platform's.
///
/// The app's own enum rather than Flutter's `ThemeMode`, because this package
/// is pure Dart and may not reach a widget
/// ([Decision 14](../../../../../../docs/technical/decisions/014-each-layer-is-its-own-package.md)).
enum ThemeChoiceEnum {
  /// Whatever the operating system is set to; the state a window opens in.
  system,

  /// Light, chosen explicitly.
  light,

  /// Dark, chosen explicitly.
  dark,
}
