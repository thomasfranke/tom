/// One stretch of the source that carries a mark.
library;

import 'package:tom_presentation/src/editor/editor_mark_enum.dart';

/// The lines a change covers, and what the pane draws over them.
///
/// A span rather than a line, because the boards draw **a letter as well as
/// a tint**: the letter sits on the first line and the tint runs the whole
/// block (`docs/product/diff/rendered-diff/how-it-is-drawn/doc.md`).
///
/// The two are separable, which is why they are two flags rather than one
/// kind. A conflict's `<<<<<<<` carries the letter and no tint — **the
/// markers stay as git wrote them and the two sides are what is tinted** —
/// and each side carries the tint and no letter of its own
/// (`docs/product/editor/conflicted-document/doc.md`).
final class EditorMarkSpan {
  /// A changed block: a letter on its first line, a tint over all of them.
  const EditorMarkSpan.block({
    required this.from,
    required this.to,
    required this.mark,
  }) : letters = true,
       tints = true;

  /// A line that carries the letter and nothing behind it.
  const EditorMarkSpan.letter(int at, this.mark)
    : from = at,
      to = at,
      letters = true,
      tints = false;

  /// A stretch that is tinted and lettered by something above it.
  const EditorMarkSpan.tint({
    required this.from,
    required this.to,
    required this.mark,
  }) : letters = false,
       tints = true;

  /// A removal, which has no lines of its own.
  ///
  /// **A removed block is a seam, not text**: it is not in the buffer, so
  /// drawing it would put characters in front of somebody that typing cannot
  /// reach. The seam sits above [from], between the two lines it used to be
  /// between.
  const EditorMarkSpan.seam(int at)
    : from = at,
      to = at,
      mark = EditorMarkEnum.removed,
      letters = false,
      tints = false;

  /// The first line it covers.
  final int from;

  /// The last, inclusive; equal to [from] for one line and for a seam.
  final int to;

  /// What happened to it.
  final EditorMarkEnum mark;

  /// Whether [from] carries the letter.
  final bool letters;

  /// Whether the lines it covers are tinted.
  final bool tints;

  /// Whether this is a seam rather than a stretch of lines.
  bool get isSeam => !letters && !tints;

  /// Whether [line] is tinted by this span.
  bool holds(int line) => tints && line >= from && line <= to;

  @override
  bool operator ==(Object other) =>
      other is EditorMarkSpan &&
      other.from == from &&
      other.to == to &&
      other.mark == mark &&
      other.letters == letters &&
      other.tints == tints;

  @override
  int get hashCode => Object.hash(from, to, mark, letters, tints);

  @override
  String toString() =>
      'EditorMarkSpan($from..$to, ${mark.name}, '
      'letters: $letters, tints: $tints)';
}
