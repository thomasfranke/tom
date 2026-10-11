/// What the design fixes about the Terminal tab.
library;

import 'package:flutter/painting.dart';

/// The numbers of `22 · Screens: Commands & Terminal`, board `Terminal`
/// (`docs/product/workspace/terminal/doc.md`); the terminal itself is drawn
/// by `TerminalLook`, an ordinary one.
abstract final class TerminalDesign {
  /// How many lines the scrollback keeps.
  static const int scrollback = 5000;

  /// The shell and its folder, after the tabs.
  static const double place = 11;

  /// The shell's name from the last tab: 27 between the inks on the board,
  /// 6 under the count's 33 (the brief read 13; the pixels say 27).
  static const double placeLead = 26;

  /// The air between the shell's text and the edges of its body, inside the
  /// body's own colour: 14 at the sides and 11 under the head's rule, as the
  /// board `The bottom panel — its states` draws it. The foot is not drawn
  /// by any text there, so its 6 is the conservative reading.
  static const EdgeInsets padding = EdgeInsets.fromLTRB(14, 11, 14, 6);
}
