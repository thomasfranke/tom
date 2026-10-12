/// How the Terminal tab looks: an ordinary terminal, not the app's.
///
/// The emulator's own palette and the platform's own monospace face — no
/// role of the app's, no vendored face, nothing to configure
/// ([Decision 37](../../../../../../docs/technical/decisions/037-the-terminal-is-the-persons-own-shell-in-a-pty.md)).
library;

import 'package:flutter/widgets.dart';
import 'package:xterm/xterm.dart' hide TerminalState;

/// The standard sixteen on black on white, which `xterm` has no variant of.
///
/// The sixteen are the ones VS Code's light terminal draws, so a program
/// written for a white terminal reads as it does elsewhere.
const TerminalTheme terminalLight = TerminalTheme(
  cursor: Color(0xFF000000),
  selection: Color(0x55ADD6FF),
  foreground: Color(0xFF000000),
  background: Color(0xFFFFFFFF),
  black: Color(0xFF000000),
  red: Color(0xFFCD3131),
  green: Color(0xFF00BC00),
  yellow: Color(0xFF949800),
  blue: Color(0xFF0451A5),
  magenta: Color(0xFFBC05BC),
  cyan: Color(0xFF0598BC),
  white: Color(0xFF555555),
  brightBlack: Color(0xFF666666),
  brightRed: Color(0xFFCD3131),
  brightGreen: Color(0xFF14CE14),
  brightYellow: Color(0xFFB5BA00),
  brightBlue: Color(0xFF0451A5),
  brightMagenta: Color(0xFFBC05BC),
  brightCyan: Color(0xFF0598BC),
  brightWhite: Color(0xFFA5A5A5),
  searchHitBackground: Color(0xFFFFFF2B),
  searchHitBackgroundCurrent: Color(0xFF31FF26),
  searchHitForeground: Color(0xFF000000),
);

/// The theme for the app's brightness: the emulator's default on dark.
TerminalTheme terminalThemeOf(Brightness brightness) =>
    brightness == Brightness.dark ? TerminalThemes.defaultTheme : terminalLight;

/// The Mac Terminal's own size, tuned by eye; a line of 1.0 is what lets
/// block and box-drawing characters meet from one row to the next.
const double _macSize = 12;

/// The platform's monospace at the usual size and the emulator's own line
/// height; the fallbacks carry the glyphs the first face lacks.
TerminalStyle terminalStyleOf(TargetPlatform platform) => switch (platform) {
  TargetPlatform.macOS => const TerminalStyle(
    fontSize: _macSize,
    height: 1,
    fontFamily: 'Menlo',
    fontFamilyFallback: <String>['Monaco', 'Courier'],
  ),
  TargetPlatform.windows => const TerminalStyle(
    fontSize: 14,
    fontFamily: 'Consolas',
    fontFamilyFallback: <String>['Courier New'],
  ),
  _ => const TerminalStyle(
    fontFamilyFallback: <String>[
      'DejaVu Sans Mono',
      'Liberation Mono',
      'Noto Sans Mono',
    ],
  ),
};
