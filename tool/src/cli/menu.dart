// A navigable screen: a title, a section, a question, and rows the arrow keys
// move through. One screen at a time, redrawn in place.
library;

import 'dart:io';

import '../theme/theme.dart';
import 'terminal.dart';

/// One row of a menu.
///
/// Rules, sections and disabled rows are drawn but skipped by the cursor;
/// [MenuItem.back] is selectable and resolves to `null`, which is the same
/// answer Esc and `q` give.
final class MenuItem<T> {
  const MenuItem(
    this.label,
    this.value, {
    this.detail,
    this.description,
    this.emphasized = false,
  }) : _kind = _Kind.item;

  /// A horizontal divider. Not selectable.
  const MenuItem.rule()
    : label = '',
      value = null,
      detail = null,
      description = null,
      emphasized = false,
      _kind = _Kind.rule;

  /// The way out of this screen. Selecting it resolves the menu to `null`.
  const MenuItem.back({this.label = Layout.backLabel, this.description})
    : value = null,
      detail = null,
      emphasized = false,
      _kind = _Kind.back;

  /// A row that is shown but cannot be chosen — something the CLI will offer
  /// later, listed now so its absence is visible rather than mysterious.
  ///
  /// Skipped by the arrow keys, which is the difference that matters: a
  /// disabled row the cursor could land on would have to explain itself on
  /// Enter, and nobody presses Enter twice to learn nothing happens.
  const MenuItem.disabled(this.label, {this.detail, this.description})
    : value = null,
      emphasized = false,
      _kind = _Kind.disabled;

  /// A heading that groups the rows below it. Not selectable.
  ///
  /// This is what lets one screen hold more than one list without sending the
  /// user through a submenu to reach the second — the groups are visible at
  /// once, and the arrow keys run straight through them.
  const MenuItem.section(this.label)
    : value = null,
      detail = null,
      description = null,
      emphasized = false,
      _kind = _Kind.section;

  final String label;
  final T? value;

  /// Right-aligned metadata, such as when this entry last ran.
  final String? detail;

  /// What this row does, shown in the footer while the cursor is on it.
  ///
  /// Two or three lines at most: the footer explains the row you are about to
  /// choose, and a paragraph there would compete with the list for attention
  /// rather than support it. This is where a description belongs — never in
  /// [detail], which is metadata and is drawn on every row at once.
  final String? description;

  /// Draws the row brighter than its neighbours — the one entry worth the
  /// eye going to first.
  final bool emphasized;

  final _Kind _kind;

  bool get _selectable => _kind == _Kind.item || _kind == _Kind.back;
}

enum _Kind { item, rule, back, section, disabled }

/// Presents [items] and returns the value the user chose, or `null` if they
/// backed out with `← Back`, Esc, `q` or Ctrl-C.
///
/// Throws [StateError] when the terminal is not interactive: a menu has no
/// meaning under CI, and callers are expected to have routed to the
/// non-interactive path long before here (see `Terminal.isPlain`).
Future<T?> showMenu<T>(
  Terminal terminal, {
  required String title,
  required List<MenuItem<T>> items,
  String? titleSuffix,
  String? section,
  String? prompt,
  int initialIndex = 0,
}) async {
  if (!terminal.interactive) {
    throw StateError('showMenu requires an interactive terminal');
  }

  final selectable = [
    for (var i = 0; i < items.length; i++)
      if (items[i]._selectable) i,
  ];
  if (selectable.isEmpty) return null;

  var cursor = selectable.contains(initialIndex)
      ? selectable.indexOf(initialIndex)
      : 0;

  var drawnLines = 0;

  void render() {
    final lines = composeFrame(
      title: title,
      titleSuffix: titleSuffix,
      section: section,
      prompt: prompt,
      items: items,
      selected: selectable[cursor],
      columns: terminal.columns,
    );
    // Rewind over the previous frame, then overwrite it row by row. Each row
    // clears to end of line so a shorter row fully replaces a longer one.
    final buffer = StringBuffer(Ansi.up(drawnLines));
    for (final line in lines) {
      buffer.writeln('$line${Ansi.clearLine}');
    }
    stdout.write(buffer);
    drawnLines = lines.length;
  }

  // Every screen owns the window from the top left. Without this the second
  // screen of a session would be drawn wherever the previous one left the
  // cursor, appended below it rather than replacing it.
  terminal.beginScreen();
  render();

  await for (final key in terminal.keys) {
    switch (key) {
      case Key.up:
        cursor = (cursor - 1) % selectable.length;
      case Key.down:
        cursor = (cursor + 1) % selectable.length;
      case Key.enter || Key.right:
        final chosen = items[selectable[cursor]];
        return chosen._kind == _Kind.back ? null : chosen.value;
      case Key.left || Key.escape || Key.quit:
        return null;
      case Key.space || Key.other:
        continue;
    }
    render();
  }
  return null;
}

/// Builds one frame as a list of rendered lines, so the caller can count them
/// and rewind by exactly that many on the next.
///
/// Public so a frame can be rendered without a terminal — `tom --preview` is
/// how the look is checked and tuned, since a redraw loop cannot be captured
/// by piping stdout somewhere.
List<String> composeFrame<T>({
  required String title,
  required List<MenuItem<T>> items,
  required int selected,
  required int columns,
  String? titleSuffix,
  String? section,
  String? prompt,
}) {
  final lines = <String>[];

  final suffix = titleSuffix == null
      ? ''
      : ' ${palette.titleSuffix}${Layout.titleSeparator} $titleSuffix'
            '${Ansi.reset}';
  lines
    ..add('${palette.title}$title${Ansi.reset}$suffix')
    ..add('');

  if (section != null) {
    lines
      ..add('${palette.section}$section${Ansi.reset}')
      ..add('');
  }
  if (prompt != null) {
    lines
      ..add('${' ' * Layout.promptColumn}${palette.prompt}$prompt${Ansi.reset}')
      ..add('');
  }

  // A row is not always one line, so each item contributes however many it
  // needs and the caller rewinds by the total.
  for (var i = 0; i < items.length; i++) {
    lines.addAll(_row(items[i], isSelected: i == selected, columns: columns));
  }

  lines.addAll(_footer(items[selected], columns: columns));
  return lines;
}

/// The footer: what the row under the cursor does.
///
/// Always the same height, whether or not the row has anything to say. A
/// footer that grew and shrank would push the list up and down as the cursor
/// moved, which is the one thing a fixed label column was there to prevent.
List<String> _footer<T>(MenuItem<T> selected, {required int columns}) {
  final lines = [
    '',
    '${' ' * Layout.labelColumn}${palette.rule}'
        '${Layout.ruleGlyph * Layout.ruleWidth}${Ansi.reset}',
  ];

  final wrapped = _wrap(
    selected.description ?? '',
    // Leave the right margin the detail column already respects, so the two
    // never end up disagreeing about where the text stops.
    width: columns - Layout.labelColumn - 2,
  );

  for (var i = 0; i < Layout.footerLines; i++) {
    final text = i < wrapped.length ? wrapped[i] : '';
    lines.add(
      text.isEmpty
          ? ''
          : '${' ' * Layout.labelColumn}${palette.prompt}$text${Ansi.reset}',
    );
  }
  return lines;
}

/// Breaks [text] into lines of at most [width], on word boundaries, and never
/// more than [Layout.footerLines] of them.
///
/// Truncating rather than wrapping further is deliberate: a description that
/// does not fit in three lines is a description that needs rewriting, and
/// silently growing the footer would move the list.
List<String> _wrap(String text, {required int width}) {
  if (text.isEmpty || width < 8) return const [];

  final lines = <String>[];
  var current = StringBuffer();

  for (final word in text.split(' ')) {
    final candidate = current.isEmpty ? word : '$current $word';
    if (candidate.length <= width) {
      current = StringBuffer(candidate);
      continue;
    }
    lines.add(current.toString());
    if (lines.length == Layout.footerLines) return lines;
    current = StringBuffer(word);
  }

  if (current.isNotEmpty && lines.length < Layout.footerLines) {
    lines.add(current.toString());
  }
  return lines;
}

List<String> _row<T>(
  MenuItem<T> item, {
  required bool isSelected,
  required int columns,
}) {
  if (item._kind == _Kind.rule) {
    final rule = Layout.ruleGlyph * Layout.ruleWidth;
    return ['${' ' * Layout.labelColumn}${palette.rule}$rule${Ansi.reset}'];
  }

  if (item._kind == _Kind.section) {
    // One line, no padding of its own: a rule above it already marks the
    // break, and a heading that also carried blank lines would push the
    // groups apart twice over. Whoever wants air adds it to the list.
    return [
      '${' ' * Layout.promptColumn}${palette.section}${item.label}'
          '${Ansi.reset}',
    ];
  }

  // The cursor lives inside the left margin so the label column never moves.
  final margin = isSelected
      ? '${' ' * Layout.cursorColumn}${palette.selected}${Layout.cursor}'
            '${Ansi.reset} '
      : ' ' * Layout.labelColumn;

  final color = switch (item) {
    _ when isSelected => palette.selected,
    _ when item._kind == _Kind.disabled => palette.rowDisabled,
    _ when item._kind == _Kind.back => palette.back,
    _ when item.emphasized => palette.rowEmphasized,
    _ => palette.row,
  };

  final line = '$margin$color${item.label}${Ansi.reset}';

  final detail = item.detail;
  if (detail == null) return [line];

  // Right-align the metadata against the terminal edge, and drop it entirely
  // rather than wrap when the window is too narrow to hold both.
  final detailWidth = detail.length + Layout.detailMarker.length + 1;
  final gap =
      columns - Layout.labelColumn - item.label.length - detailWidth - 2;
  if (gap < 2) return [line];

  final spacer = ' ' * gap;
  return [
    '$line$spacer${palette.detailIcon}${Layout.detailMarker}${Ansi.reset} '
        '${palette.detail}$detail${Ansi.reset}',
  ];
}
