// A block of rows repainted in place while work runs, and the glyphs every
// such block is drawn with.
library;

import 'dart:io';

import '../theme/theme.dart';
import '../tty.dart';

/// How wide a progress bar is drawn, in columns.
const barWidth = 20;

/// A progress bar, [done] of [total]; a [total] of zero draws an empty bar,
/// since a bar that starts full to mean "no information" reads as the
/// opposite.
String progressBar(int done, int total) {
  final filled = total > 0
      ? ((done / total) * barWidth).round().clamp(0, barWidth)
      : 0;
  return '█' * filled + '░' * (barWidth - filled);
}

/// A row's status mark, plus the margin around it: five columns, which is
/// what the double-width emoji it replaced occupied, so nothing to the right
/// shifts.
String statusMark(String glyph, String color) =>
    '  $color$glyph${Ansi.reset}  ';

/// A duration as `6s` or `2m04s` — never more precision than someone reading
/// a dashboard can use.
String formatDuration(Duration d) {
  final minutes = d.inMinutes;
  final seconds = d.inSeconds % 60;
  return minutes > 0
      ? '${minutes}m${seconds.toString().padLeft(2, '0')}s'
      : '${seconds}s';
}

/// The braille spinner, for work that reports stages rather than items.
const spinnerFrames = ['⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏'];

/// A fixed block of rows, repainted where it stands.
///
/// A subclass supplies [labelOf], [isSettled], [header] and [renderRow]; the
/// rewind, the plain-mode fallback, the label column and the tick are shared.
abstract class Dashboard<R> {
  Dashboard(this.rows, this.started);

  final List<R> rows;
  final DateTime started;

  /// The width of the left column, the longest label.
  ///
  /// `late final` because the width comes from [labelOf], which a constructor
  /// cannot call; computed once, since a row is mutated in place, never added.
  late final int labelWidth = rows.isEmpty
      ? 0
      : rows.map((row) => labelOf(row).length).reduce((a, b) => a > b ? a : b);

  /// Advances once per repaint, for a subclass that animates something.
  int get tick => _tick;
  int _tick = 0;

  int _paintedLines = 0;

  /// Labels already printed in plain mode, so each is reported once.
  final Set<String> _reported = {};

  /// The name in the left column.
  String labelOf(R row);

  /// Whether [row] has stopped moving — done, skipped, failed.
  ///
  /// Plain mode prints a row the moment this turns true and never again,
  /// which is what turns a repainting dashboard into a readable log.
  bool isSettled(R row);

  /// The line above the rows: what is running and how far along it is.
  String header();

  /// One row, rendered. Pad the label to [labelWidth].
  String renderRow(R row);

  /// Repaints the block, or appends the rows that have just settled.
  void render() {
    if (isPlain) return _renderPlain();

    _tick++;
    _erase();
    final lines = [header(), ...rows.map(renderRow)];
    stdout.writeln(lines.join('\n'));
    _paintedLines = lines.length;
  }

  /// Append-only: one line per row, the moment it stops moving. No header,
  /// because in a log a progress readout is the same line over and over.
  void _renderPlain() {
    for (final row in rows) {
      if (!isSettled(row) || !_reported.add(labelOf(row))) continue;
      stdout.writeln(renderRow(row));
    }
  }

  /// Writes [text] above the block, so it survives the next repaint.
  void log(String text) {
    if (isPlain) {
      stdout.writeln(text);
      return;
    }
    _erase();
    stdout.writeln(text);
    render();
  }

  void _erase() {
    if (isPlain || _paintedLines == 0) return;
    stdout.write('\x1B[${_paintedLines}A\x1B[J');
    _paintedLines = 0;
  }

  /// The whole block once as plain text, with no cursor moves — how a frame
  /// is read in a test, since a redraw loop cannot be captured by piping.
  List<String> frame() => [header(), ...rows.map(renderRow)];
}
