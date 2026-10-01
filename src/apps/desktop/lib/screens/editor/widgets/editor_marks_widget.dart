/// The marks in the source pane's gutter, beside the lines they belong to.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:re_editor/re_editor.dart';
import 'package:tom_desktop/screens/editor/editor_design.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// A letter beside every line something happened to, in the gutter left of
/// the numbers — `A`, `R`, `M` for the diff and `C` for a conflict.
///
/// Placed from the editor's own layout rather than from a line height of
/// ours: with wrapping on, a paragraph is as tall as the rows it needed, and
/// only `re_editor` knows how many that was.
///
/// **Painted rather than mounted.** The editor writes its layout to this
/// notifier *while it is laying out*, so a widget rebuilding on it schedules
/// a build during a frame; a painter takes the same notifier as its `repaint`
/// and lands in the frame that produced it. It is why the mark is drawn here
/// instead of reusing [DiffMarkWidget], whose numbers it keeps.
class EditorMarksWidget extends StatelessWidget {
  /// Creates the gutter for [marks].
  const EditorMarksWidget({
    required this.notifier,
    required this.marks,
    super.key,
  });

  /// What the editor last laid out: the visible lines, and where each sits.
  final CodeIndicatorValueNotifier notifier;

  /// What each line is marked as.
  final EditorMarks marks;

  /// Where the mark for [line] goes, in the gutter's own coordinates.
  ///
  /// Centred on the line's **first** row: a wrapped line is taller than the
  /// mark, and the mark says where the change begins.
  static Rect squareFor(CodeLineRenderParagraph line) => Rect.fromLTWH(
    EditorDesign.markLeft,
    line.top + (line.preferredLineHeight - TomMetrics.mark) / 2,
    TomMetrics.mark,
    TomMetrics.mark,
  );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        DiagnosticsProperty<CodeIndicatorValueNotifier>('notifier', notifier),
      )
      ..add(DiagnosticsProperty<EditorMarks>('marks', marks));
  }

  @override
  Widget build(BuildContext context) {
    if (marks.isEmpty) {
      return const SizedBox.shrink();
    }
    return CustomPaint(
      painter: EditorMarksPainter(
        notifier: notifier,
        marks: marks,
        colors: TomColors.of(context),
      ),
    );
  }
}

/// The letters themselves, on the surface the numbers are painted on.
///
/// Public so a test can read back what it was given; nothing outside this
/// file builds one.
class EditorMarksPainter extends CustomPainter {
  /// Paints [marks] in [colors], repainting whenever the editor lays out
  /// again.
  EditorMarksPainter({
    required this.notifier,
    required this.marks,
    required this.colors,
  }) : super(repaint: notifier);

  /// The editor's layout, and this painter's own repaint signal.
  final CodeIndicatorValueNotifier notifier;

  /// What each line is marked as.
  final EditorMarks marks;

  /// The roles the letters are drawn in.
  final TomColors colors;

  /// The letter each mark carries, the same alphabet the changes column and
  /// the file tree use.
  static String letterOf(EditorMarkEnum mark) => switch (mark) {
    EditorMarkEnum.added => 'A',
    EditorMarkEnum.removed => 'R',
    EditorMarkEnum.modified => 'M',
    EditorMarkEnum.conflicted => 'C',
  };

  /// The ink and the square for [mark].
  (Color, Color) _roleOf(EditorMarkEnum mark) => switch (mark) {
    EditorMarkEnum.added => (colors.added, colors.addedSoft),
    EditorMarkEnum.removed => (colors.removed, colors.removedSoft),
    // A conflict is `modified`: nothing failed, and neither side is leaving
    // until somebody chooses.
    EditorMarkEnum.modified ||
    EditorMarkEnum.conflicted => (colors.modified, colors.modifiedSoft),
  };

  @override
  void paint(Canvas canvas, Size size) {
    final CodeIndicatorValue? value = notifier.value;
    if (value == null) {
      return;
    }
    canvas
      ..save()
      // Clipped like the numbers are: a line scrolled half out of the pane
      // must not paint its mark over the caption.
      ..clipRect(Offset.zero & size);
    for (final CodeLineRenderParagraph line in value.paragraphs) {
      final EditorMarkEnum? mark = marks.at(line.index);
      if (mark == null) {
        continue;
      }
      final (Color ink, Color fill) = _roleOf(mark);
      final Rect square = EditorMarksWidget.squareFor(line);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          square,
          const Radius.circular(TomMetrics.radiusTight),
        ),
        Paint()..color = fill,
      );
      final TextPainter painter = TextPainter(
        text: TextSpan(
          text: letterOf(mark),
          style: TextStyle(
            fontSize: 11,
            height: 1,
            fontWeight: FontWeight.w600,
            fontFamily: TomFonts.sans,
            color: ink,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(
        canvas,
        square.center - Offset(painter.width / 2, painter.height / 2),
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(EditorMarksPainter oldDelegate) =>
      oldDelegate.marks != marks || oldDelegate.colors != colors;
}
