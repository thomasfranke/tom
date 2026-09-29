/// The two themes, built from the roles.
library;

import 'package:flutter/material.dart';
import 'package:tom_ui/src/theme/tom_colors.dart';
import 'package:tom_ui/src/theme/tom_fonts.dart';

/// The app's theme for [brightness], built by one function from one palette
/// type so a role cannot be added to one mode and forgotten in the other
/// ([visual
/// language](../../../../../../docs/design/visual-language/README.md)).
/// `ThemeData` is filled from the same roles, so a stray Material widget
/// never shows Material's default blue.
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
    // The interface face, set once: every widget that states no family gets
    // it, which is what keeps a stray Text from shipping the platform's own.
    fontFamily: TomFonts.sans,
    scaffoldBackgroundColor: colors.surface,
    dividerTheme: DividerThemeData(
      color: colors.border,
      thickness: 1,
      space: 1,
    ),
    extensions: <ThemeExtension<TomColors>>[colors],
  );
}
