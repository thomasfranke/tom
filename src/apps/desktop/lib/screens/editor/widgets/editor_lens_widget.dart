/// The three ways out of a conflict, on the line that opens it.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:re_editor/re_editor.dart';
import 'package:tom_desktop/l10n/l10n.dart';
import 'package:tom_desktop/screens/editor/editor_design.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// `Accept Current Change | Accept Incoming Change | Accept Both Changes`
/// after every `<<<<<<<` — VS Code's words, so nobody learns a second set
/// (`docs/product/editor/conflicted-document/doc.md`).
///
/// **Beside the marker, not on a row above it** as the board draws: a row
/// with no line behind it is a view zone, and `re_editor` forces every row
/// to the strut and builds no placeholders, so it cannot open one. Painted,
/// like the gutter, because the layout arrives mid-frame; only the words
/// hit-test, so the editor under them keeps every other touch.
class EditorLensWidget extends StatelessWidget {
  /// Creates the choices for the conflicts [marks] letters.
  const EditorLensWidget({
    required this.notifier,
    required this.marks,
    required this.onChoose,
    super.key,
  });

  /// What the editor last laid out: the visible lines, and where each sits.
  final CodeIndicatorValueNotifier notifier;

  /// Which lines open a conflict: the ones lettered `C`.
  final EditorMarks marks;

  /// What to do with the side chosen on the conflict opening at a line.
  final void Function(int line, ConflictChoiceEnum choice) onChoose;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        DiagnosticsProperty<CodeIndicatorValueNotifier>('notifier', notifier),
      )
      ..add(DiagnosticsProperty<EditorMarks>('marks', marks))
      ..add(
        ObjectFlagProperty<void Function(int, ConflictChoiceEnum)>.has(
          'onChoose',
          onChoose,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final bool conflicted = marks.spans.any(
      (EditorMarkSpan span) =>
          span.letters && span.mark == EditorMarkEnum.conflicted,
    );
    if (!conflicted) {
      return const SizedBox.shrink();
    }
    final TomColors colors = TomColors.of(context);
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final EditorLensPainter painter = EditorLensPainter(
          notifier: notifier,
          marks: marks,
          colors: colors,
          width: constraints.maxWidth,
          l10n: context.l10n,
        );
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          hitTestBehavior: HitTestBehavior.deferToChild,
          child: GestureDetector(
            behavior: HitTestBehavior.deferToChild,
            onTapUp: (TapUpDetails details) {
              if (painter.choiceAt(details.localPosition) case (
                final int line,
                final ConflictChoiceEnum choice,
              )) {
                onChoose(line, choice);
              }
            },
            child: CustomPaint(painter: painter, size: Size.infinite),
          ),
        );
      },
    );
  }
}

/// The choices themselves, over whatever the editor draws.
///
/// Public so a test can ask where a choice landed; nothing outside this file
/// builds one.
class EditorLensPainter extends CustomPainter {
  /// Paints the choices in [colors], repainting whenever the editor lays out
  /// again.
  EditorLensPainter({
    required this.notifier,
    required this.marks,
    required this.colors,
    required this.width,
    required AppLocalizations l10n,
  }) : choices = <(String, ConflictChoiceEnum)>[
         (l10n.conflictAcceptCurrent, ConflictChoiceEnum.current),
         (l10n.conflictAcceptIncoming, ConflictChoiceEnum.incoming),
         (l10n.conflictAcceptBoth, ConflictChoiceEnum.both),
       ],
       super(repaint: notifier);

  /// The editor's layout, and this painter's own repaint signal.
  final CodeIndicatorValueNotifier notifier;

  /// Which lines open a conflict.
  final EditorMarks marks;

  /// The roles the choices are drawn in.
  final TomColors colors;

  /// The pane's width, which a hit test is not told.
  final double width;

  /// The three, in the order the situation has them, in the window's words.
  final List<(String, ConflictChoiceEnum)> choices;

  /// Between two of them, spaced exactly as the board sets it.
  static const String separator = '  |  ';

  /// The whole line of choices, laid out once for every conflict.
  late final TextPainter _text = TextPainter(
    text: TextSpan(
      text: <String>[
        for (final (String word, _) in choices) word,
      ].join(separator),
      style: TextStyle(
        fontFamily: TomFonts.sans,
        fontSize: EditorDesign.lens,
        height: 1,
        fontWeight: FontWeight.w500,
        color: colors.modified,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();

  /// Each choice's ink, from the start of [_text].
  late final List<Rect> _words = _measure();

  /// Where the source's own baseline sits in a row.
  ///
  /// The choices stand on it rather than centred in the row, because they
  /// share the line with the marker and a sans set on a mono's middle reads
  /// as falling off it.
  late final double _baseline =
      _sourceBaseline() -
      _text.computeDistanceToActualBaseline(TextBaseline.alphabetic);

  /// A row's top to the baseline `re_editor` sets the source on: the same
  /// style under the same forced strut.
  static double _sourceBaseline() {
    final TextPainter row = TextPainter(
      text: const TextSpan(
        text: '0',
        style: TextStyle(
          fontFamily: TomFonts.mono,
          fontSize: EditorDesign.code,
          height: EditorDesign.codeHeight,
        ),
      ),
      strutStyle: const StrutStyle(
        fontFamily: TomFonts.mono,
        fontSize: EditorDesign.code,
        height: EditorDesign.codeHeight,
        forceStrutHeight: true,
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final double baseline = row.computeDistanceToActualBaseline(
      TextBaseline.alphabetic,
    );
    row.dispose();
    return baseline;
  }

  List<Rect> _measure() {
    final List<Rect> words = <Rect>[];
    int at = 0;
    for (final (String word, ConflictChoiceEnum _) in choices) {
      words.add(
        _text
            .getBoxesForSelection(
              TextSelection(baseOffset: at, extentOffset: at + word.length),
            )
            .map((TextBox box) => box.toRect())
            .reduce((Rect a, Rect b) => a.expandToInclude(b)),
      );
      at += word.length + separator.length;
    }
    return words;
  }

  /// Every visible `<<<<<<<` line, with where its choices start and its row.
  Iterable<(int, Offset, Rect)> _lenses() sync* {
    final CodeIndicatorValue? value = notifier.value;
    if (value == null) {
      return;
    }
    for (final CodeLineRenderParagraph line in value.paragraphs) {
      if (marks.at(line.index) != EditorMarkEnum.conflicted) {
        continue;
      }
      // The field starts where the numbers end, and the paragraph's own
      // offset already carries the padding and the horizontal scroll.
      final double x =
          EditorDesign.numbers +
          line.offset.dx +
          line.paragraph.width +
          EditorDesign.lensGap;
      yield (
        line.index,
        Offset(x, line.top + _baseline),
        Rect.fromLTWH(0, line.top, double.infinity, line.preferredLineHeight),
      );
    }
  }

  /// The right edge of the source's measure; past it nothing is drawn.
  double get _right => width - TomMetrics.pad;

  /// Which choice is under [position], and the line its conflict opens on.
  (int, ConflictChoiceEnum)? choiceAt(Offset position) {
    if (position.dx > _right) {
      return null;
    }
    for (final (int line, Offset origin, Rect row) in _lenses()) {
      if (position.dy < row.top || position.dy >= row.bottom) {
        continue;
      }
      for (int at = 0; at < choices.length; at++) {
        final Rect word = _words[at].shift(origin);
        if (position.dx >= word.left && position.dx <= word.right) {
          return (line, choices[at].$2);
        }
      }
    }
    return null;
  }

  /// Where [choice] is drawn on [line], or null when it is not on screen.
  Rect? wordFor(int line, ConflictChoiceEnum choice) {
    final int index = choices.indexWhere(
      ((String, ConflictChoiceEnum) c) => c.$2 == choice,
    );
    for (final (int at, Offset origin, Rect row) in _lenses()) {
      if (at == line) {
        final Rect word = _words[index].shift(origin);
        return Rect.fromLTRB(word.left, row.top, word.right, row.bottom);
      }
    }
    return null;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..save()
      ..clipRect(Rect.fromLTRB(0, 0, _right, size.height));
    for (final (int _, Offset origin, Rect _) in _lenses()) {
      _text.paint(canvas, origin);
    }
    canvas.restore();
  }

  @override
  bool? hitTest(Offset position) => choiceAt(position) != null;

  @override
  bool shouldRepaint(EditorLensPainter oldDelegate) =>
      oldDelegate.marks != marks ||
      oldDelegate.colors != colors ||
      oldDelegate.choices.first.$1 != choices.first.$1 ||
      oldDelegate.width != width;
}
