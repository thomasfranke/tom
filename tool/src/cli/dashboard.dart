// A block of rows repainted in place while work runs, and the glyphs every
// such block is drawn with.
//
// Two commands grew one of these independently — the test runner and the
// codegen runner — and they agreed on everything but the rows: same rewind,
// same append-only fallback for a log, same bar, same marks, same duration
// format, written twice. What actually differs between them is what a row is
// and how it reads, so that is what a subclass supplies and this holds the
// rest.
library;

import 'dart:io';

import '../theme/theme.dart';
import '../tty.dart';

/// How wide a progress bar is drawn, in columns.
const barWidth = 20;

/// A progress bar, [done] of [total].
///
/// A [total] of zero draws an empty bar rather than a full one: nothing is
/// known yet, and a bar that starts full to mean "no information" is the
/// opposite of what it looks like.
String progressBar(int done, int total) {
  final filled = total > 0
      ? ((done / total) * barWidth).round().clamp(0, barWidth)
      : 0;
  return '█' * filled + '░' * (barWidth - filled);
}

/// A row's status mark, plus the margin around it.
///
/// Five columns in total — two of indent, one for the glyph, two of gap —
/// which is what the double-width emoji it replaced occupied. Keeping the
/// width identical is what stops every column to its right from shifting.
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

/// The braille spinner, for work whose progress cannot be counted.
///
/// Where there is a total to divide by, [progressBar] says more; this is for
/// the case where a process reports stages rather than items.
const spinnerFrames = ['⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏'];

/// A fixed block of rows, repainted where it stands.
///
/// Subclass it with the row type the command actually has: [labelOf],
/// [isSettled], [header] and [renderRow] are the four things that differ, and
/// everything below them — the rewind, the plain-mode fallback, the label
/// column, the tick a spinner advances on — is the same for any of them.
abstract class Dashboard<R> {
  Dashboard(this.rows, this.started);

  final List<R> rows;
  final DateTime started;

  /// The width of the left column: the longest label, so the numbers beside
  /// them line up whatever the rows are.
  ///
  /// `late final` rather than a constructor initializer, because the width
  /// comes from [labelOf] and a constructor cannot call an instance method.
  /// Computed once, on first paint, and the row set does not change after
  /// that — a row is mutated in place, never added.
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

  /// Append-only: one line per row, the moment it stops moving.
  ///
  /// No header and no repainting — the header is a progress readout, and in a
  /// log a progress readout is the same line over and over. The totals still
  /// arrive at the end, from the summary the caller prints.
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

  /// Renders the whole block once as plain text, with no cursor moves.
  ///
  /// What `tom --preview` is for the menu: a redraw loop cannot be captured
  /// by piping stdout anywhere, so this is how a frame is read in a test, a
  /// diff, or a terminal that does not exist.
  List<String> frame() => [header(), ...rows.map(renderRow)];
}
