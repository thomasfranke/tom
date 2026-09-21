// The visual language, split in two: what never varies, and what a palette
// decides.
//
// Layout is shared — a label column that moved between themes would make the
// cursor jump when someone switched. Colors are the part that varies, and
// they live one file per palette beside this one.
library;

import 'dark.dart';

export 'ansi.dart';
export 'dark.dart';
export 'light.dart';

/// The palette in force.
///
/// Dark by default because that is what a terminal usually is, and because
/// the bright white this palette uses for an emphasized row is unreadable on
/// a light background — the wrong default is not merely off-key, it hides a
/// row. Reassign at startup to switch.
Palette palette = dark;

/// Glyphs, columns and labels: the part of the look no palette changes.
abstract final class Layout {
  /// Marks the row the arrow keys are on.
  static const cursor = '>';

  /// The label column, counted from the left edge. The cursor is drawn inside
  /// this margin rather than pushing the label, so rows never shift
  /// horizontally as the selection moves.
  static const labelColumn = 6;

  /// Where the cursor glyph sits, two columns left of the label.
  static const cursorColumn = 4;

  /// Indent of the question that introduces a list of rows, and of a section
  /// heading that groups them.
  static const promptColumn = 2;

  /// Width of the horizontal rules that bracket a block. Deliberately fixed
  /// and narrower than the longest row: it reads as a divider, not a border.
  static const ruleWidth = 28;
  static const ruleGlyph = '─';

  static const backLabel = '← Back';
  static const quitLabel = '← Quit';

  /// How many lines the footer reserves for the selected row's description.
  ///
  /// Fixed, and reserved whether or not there is anything to put in them: a
  /// footer that changed height would move the list under the cursor every
  /// time the selection changed.
  static const footerLines = 3;

  static const checked = '◉';
  static const unchecked = '○';

  /// Precedes a row's right-aligned metadata.
  static const detailMarker = '⊘';

  /// The em dash between a title and its subtitle: `TOM — dev`.
  static const titleSeparator = '—';

  /// What every screen is headed with.
  ///
  /// Here rather than in `tom.dart` because a screen is drawn wherever the
  /// work is, and a command that paints its own frame — the end-to-end
  /// runner clears the terminal between scenarios — has to be able to put
  /// the same header back. A header that appears on most screens reads as a
  /// bug on the one it is missing from.
  static const appTitle = 'TOM';
  static const appSubtitle = 'dev';

  /// Between the steps of a section that is a path through screens:
  /// `Codegen › Hard`.
  static const crumbSeparator = '›';
}

/// The colors one palette assigns to each role.
///
/// Roles, not colors: a screen asks for [selected], never for cyan, so a
/// palette can answer with whatever reads as selected on its background.
final class Palette {
  const Palette({
    required this.title,
    required this.titleSuffix,
    required this.section,
    required this.prompt,
    required this.selected,
    required this.row,
    required this.rowEmphasized,
    required this.rowDisabled,
    required this.rule,
    required this.detail,
    required this.detailIcon,
    required this.back,
    required this.ok,
    required this.fail,
    required this.running,
    required this.queued,
    required this.skipped,
  });

  final String title;
  final String titleSuffix;
  final String section;
  final String prompt;

  /// The row the cursor is on, and the cursor glyph itself.
  final String selected;

  final String row;

  /// A row worth the eye going to first — the host platform, the last run.
  final String rowEmphasized;

  /// A row that is listed but cannot be chosen. Reads as present-but-inert
  /// without disappearing.
  final String rowDisabled;

  final String rule;
  final String detail;
  final String detailIcon;
  final String back;

  /// The four states a dashboard row can be in.
  ///
  /// Status used to be carried by the emoji itself — 🟢 is green whatever the
  /// terminal thinks. That made it the one part of the output no palette
  /// could reach, and it cost two columns per row, since an emoji is double
  /// width and inconsistently so between terminals. The glyphs are one column
  /// now and the color comes from here.
  final String ok;
  final String fail;
  final String running;
  final String queued;
  final String skipped;
}

/// The glyphs a dashboard row is marked with, one column each.
///
/// A check and a cross for the two outcomes, because those are read without
/// being learned; the quieter states get quieter marks — a pointer for what
/// is moving, a dot for what is waiting, an empty circle for what was passed
/// over. Nothing here is double width, and nothing needs a font installed.
abstract final class Status {
  static const ok = '✓';

  /// The heavy cross, not the light one: a failure should be the thing the
  /// eye lands on first when scanning a column of results, and `✗` next to
  /// `✓` reads as the same weight rather than as an alarm.
  static const fail = '✘';
  static const running = '▸';
  static const queued = '·';
  static const skipped = '○';
}
