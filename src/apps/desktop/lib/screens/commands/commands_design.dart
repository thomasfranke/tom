/// What the design fixes about the commands panel.
library;

/// The numbers of `22 · Screens: Commands & Terminal` — `command-log`,
/// `command-log-output` and `command-log-a-failure` — measured from the
/// panel's own edges (`docs/product/workspace/commands/doc.md`).
abstract final class CommandsDesign {
  /// Below the head's rule to the first row: the rows start 40 from the
  /// panel's top, and the head with its rule is 35.
  static const double listTop = 5;

  /// One row.
  static const double rowHeight = 24;

  /// The hover and failure fill's inset from the panel's edges.
  static const double rowInset = 4;

  /// Its corner, and the output box's.
  static const double rowRadius = 6;

  /// The time's left edge.
  static const double timeLeft = 14;

  /// The status mark's centre.
  static const double statusCentre = 94;

  /// The check, on a command that worked.
  static const double check = 12;

  /// The cross, on one that failed.
  static const double cross = 10;

  /// The command's left edge, and the output box's.
  static const double commandLeft = 110;

  /// The duration's right edge, from the panel's.
  static const double durationRight = 54;

  /// The copy glyph's left edge, from the panel's right edge.
  static const double copyRight = 26;

  /// The copy glyph.
  static const double copy = 12;

  /// The output box's right edge, from the panel's.
  static const double outputRight = 14;

  /// Between a row and its output box.
  static const double outputAbove = 2;

  /// Between the output box and the next row.
  static const double outputBelow = 6;

  /// Inside the output box.
  static const double outputPadding = 8;

  /// The time, the duration and the output.
  static const double small = 11.5;

  /// The command.
  static const double command = 12;
}
