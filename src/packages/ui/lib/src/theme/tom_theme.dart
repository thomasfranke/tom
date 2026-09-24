/// The two themes, built from the roles.
library;

import 'package:flutter/material.dart';
import 'package:tom_ui/src/theme/tom_colors.dart';

/// The app's theme for [brightness].
///
/// **Both modes ship together**: a colour added in one without its
/// counterpart is a bug, not a follow-up ([visual
/// language](../../../../../docs/technical/design/visual-language.md)). They
/// are built by one function from one palette type for exactly that reason —
/// there is no way to add a role to one and forget the other.
///
/// Material is the substrate, not the look: what the app draws comes from
/// [TomColors], and `ThemeData` is filled in from the same roles so that a
/// stray Material widget cannot appear in Material's own default blue.
ThemeData tomTheme(Brightness brightness) {
  final TomColors colors = brightness == Brightness.dark
      ? TomColors.dark
      : TomColors.light;
  final ColorScheme scheme =
      ColorScheme.fromSeed(
        seedColor: colors.accent,
        brightness: brightness,
      ).copyWith(
        surface: colors.surface,
        onSurface: colors.textPrimary,
        primary: colors.accent,
        outline: colors.border,
        outlineVariant: colors.borderStrong,
        error: colors.removed,
      );
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: colors.surface,
    dividerTheme: DividerThemeData(
      color: colors.border,
      thickness: 1,
      space: 1,
    ),
    extensions: <ThemeExtension<TomColors>>[colors],
  );
}
