/// The tint behind the lines something happened to.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:re_editor/re_editor.dart';
import 'package:tom_desktop/screens/editor/editor_design.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// A band under every changed block, and a seam where one was removed.
///
/// **A changed block carries a letter as well as a tint**, and **in split
/// view both panes are marked** — the letter is the gutter's
/// (`editor_marks_widget.dart`) and the tint is this
/// (`docs/product/diff/rendered-diff/how-it-is-drawn/doc.md`).
///
/// Drawn **behind** the editor rather than inside it: the band crosses the
/// line numbers and the text both, and the indicator column is only as wide
/// as the numbers. The editor is left transparent so this shows through.
class EditorBandsWidget extends StatelessWidget {
  /// Creates the bands for [marks].
  const EditorBandsWidget({
    required this.notifier,
    required this.marks,
    super.key,
  });

  /// What the editor last laid out: the visible lines, and where each sits.
  final CodeIndicatorValueNotifier notifier;

  /// What each line is tinted with.
  final EditorMarks marks;

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
      painter: EditorBandsPainter(
        notifier: notifier,
        marks: marks,
        colors: TomColors.of(context),
      ),
    );
  }
}

/// The bands themselves, under whatever the editor draws.
///
/// Public so a test can read back what it was given; nothing outside this
/// file builds one.
class EditorBandsPainter extends CustomPainter {
  /// Paints [marks] in [colors], repainting whenever the editor lays out
  /// again.
  EditorBandsPainter({
    required this.notifier,
    required this.marks,
    required this.colors,
  }) : super(repaint: notifier);

  /// The editor's layout, and this painter's own repaint signal.
  final CodeIndicatorValueNotifier notifier;

  /// What each line is tinted with.
  final EditorMarks marks;

  /// The roles the bands are drawn in.
  final TomColors colors;

  /// The ink and the tint for [mark].
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
    // The same right edge the source text has, so the band ends where the
    // measure does rather than at the pane's frame.
    final double right = size.width - TomMetrics.pad;
    if (right <= EditorDesign.bandLeft) {
      return;
    }
    canvas
      ..save()
      ..clipRect(Offset.zero & size);
    for (final CodeLineRenderParagraph line in value.paragraphs) {
      if (marks.bandAt(line.index) case final EditorMarkEnum mark) {
        final (Color ink, Color fill) = _roleOf(mark);
        canvas
          ..drawRect(
            Rect.fromLTRB(
              EditorDesign.bandLeft,
              line.top,
              right,
              line.bottom,
            ),
            Paint()..color = fill,
          )
          ..drawRect(
            Rect.fromLTWH(
              EditorDesign.bandLeft,
              line.top,
              EditorDesign.bandBar,
              line.height,
            ),
            Paint()..color = ink,
          );
      }
      if (marks.seamAbove(line.index)) {
        // Centred on the join, because it says something used to be
        // *between* these two lines.
        canvas.drawRect(
          Rect.fromLTRB(
            EditorDesign.bandLeft,
            line.top - EditorDesign.seam / 2,
            right,
            line.top + EditorDesign.seam / 2,
          ),
          Paint()..color = colors.removed,
        );
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(EditorBandsPainter oldDelegate) =>
      oldDelegate.marks != marks || oldDelegate.colors != colors;
}
