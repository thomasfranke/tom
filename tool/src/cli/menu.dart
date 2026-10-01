// A navigable screen — title, section, question and rows the arrow keys move
// through — redrawn in place.
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
    this.detailColor,
    this.description,
    this.emphasized = false,
  }) : _kind = _Kind.item;

  /// A horizontal divider. Not selectable.
  const MenuItem.rule()
    : label = '',
      value = null,
      detail = null,
      detailColor = null,
      description = null,
      emphasized = false,
      _kind = _Kind.rule;

  /// The way out of this screen. Selecting it resolves the menu to `null`.
  const MenuItem.back({this.label = Layout.backLabel, this.description})
    : value = null,
      detail = null,
      detailColor = null,
      emphasized = false,
      _kind = _Kind.back;

  /// A row that is shown but cannot be chosen — something the CLI will offer
  /// later, listed so its absence is visible. Skipped by the arrow keys, since
  /// a row the cursor lands on would have to explain itself on Enter.
  const MenuItem.disabled(
    this.label, {
    this.detail,
    this.detailColor,
    this.description,
  }) : value = null,
       emphasized = false,
       _kind = _Kind.disabled;

  /// A heading that groups the rows below it. Not selectable, so one screen
  /// holds more than one list without a submenu.
  const MenuItem.section(this.label)
    : value = null,
      detail = null,
      detailColor = null,
      description = null,
      emphasized = false,
      _kind = _Kind.section;

  final String label;
  final T? value;

  /// Right-aligned metadata, such as when this entry last ran.
  final String? detail;

  /// What colour to paint [detail], when its meaning is not neutral.
  ///
  /// A separate field rather than escape codes inside [detail], because the
  /// alignment is computed from that string's length. Setting it also drops
  /// the generic marker: two icons on one row is one too many.
  final String? detailColor;

  /// What this row does, shown in the footer while the cursor is on it — two
  /// or three lines at most, and never in [detail], which is drawn on every
  /// row at once.
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
/// meaning under CI, and callers route to the plain path before here.
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

  // Every screen owns the window from the top left; without this the second
  // screen would be drawn wherever the previous one left the cursor.
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

/// One frame as a list of rendered lines, so the caller can rewind by exactly
/// that many on the next. Public so `tom --preview` can render one without a
/// terminal.
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
  // No blank line under the question: the rows below are the answer to it,
  // and a gap there reads as two blocks rather than as one.
  if (prompt != null) {
    lines.add(
      '${' ' * Layout.promptColumn}${palette.prompt}$prompt${Ansi.reset}',
    );
  }

  // A row is not always one line, so each item contributes however many it
  // needs and the caller rewinds by the total.
  for (var i = 0; i < items.length; i++) {
    lines.addAll(_row(items[i], isSelected: i == selected, columns: columns));
  }

  lines.addAll(_footer(items[selected], columns: columns));
  return lines;
}

/// The footer: what the row under the cursor does, always the same height, so
/// the list does not move as the cursor does.
List<String> _footer<T>(MenuItem<T> selected, {required int columns}) {
  // No blank line above the rule: every screen already ends its list with
  // one, and two rules with a gap read as two separators.
  final lines = [
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

/// [text] broken into lines of at most [width] on word boundaries, and never
/// more than [Layout.footerLines] of them: a description that does not fit
/// needs rewriting, and a growing footer would move the list.
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
    // No padding of its own: the rule above already marks the break.
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

  // A row that colours its own detail speaks for itself; the generic marker
  // would be a second, duller icon in front of a meaningful one.
  final marker = item.detailColor == null ? Layout.detailMarker : '';

  // Right-align the metadata against the terminal edge, and drop it entirely
  // rather than wrap when the window is too narrow to hold both.
  final detailWidth = detail.length + marker.length + 1;
  final gap =
      columns - Layout.labelColumn - item.label.length - detailWidth - 2;
  if (gap < 2) return [line];

  final spacer = ' ' * gap;
  return [
    '$line$spacer${palette.detailIcon}$marker${Ansi.reset}'
        '${marker.isEmpty ? '' : ' '}'
        '${item.detailColor ?? palette.detail}$detail${Ansi.reset}',
  ];
}
