/// One conflicted region, as the two sides and the choice between them.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tom_desktop/screens/preview/preview_design.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_ui/tom_ui.dart';

/// The two sides of a merge, labelled, with the three ways out of it.
///
/// Both sides carry the **same** tint: `removed` would say your work is
/// leaving and `added` would say theirs has arrived, and neither is true
/// until somebody chooses — so they are told apart by their labels, never by
/// hue (`docs/product/editor/conflicted-document/doc.md`).
///
/// The words are VS Code's on purpose: whoever resolves conflicts here has
/// resolved them there, and a second vocabulary for the same three buttons is
/// a second thing to learn. No marker is ever drawn here; the source pane is
/// where git's own text stays.
class PreviewConflictWidget extends StatelessWidget {
  /// Creates the view of [region], calling [onChoose] with what was picked.
  const PreviewConflictWidget({
    required this.region,
    required this.body,
    required this.onChoose,
    super.key,
  });

  /// The region as the scanner read it out of the buffer.
  final ConflictRegionValueObject region;

  /// The prose size, the reading mode's or the split's.
  final double body;

  /// What to do with the side that was chosen.
  final ValueChanged<ConflictChoiceEnum> onChoose;

  /// Block top to the first label, inside the tint.
  static const double labelTop = 30 - PreviewDesign.diffPad;

  /// A label to the text under it.
  static const double labelGap = 15;

  /// A side's text to what follows it.
  static const double sideGap = 19;

  /// The height of each of the three buttons.
  static const double actionHeight = 28;

  /// What each of the three is wide.
  ///
  /// Fixed rather than sized from the label: the board draws them at these
  /// three widths, and a button that grew with a translated word would push
  /// the last one off the measure
  /// (`docs/design/screens/desktop/git-conflict/conflict-in-preview-light.svg`).
  static const double currentWidth = 168;

  /// What `Accept Incoming Change` is wide.
  static const double incomingWidth = 176;

  /// What `Accept Both Changes` is wide.
  static const double bothWidth = 152;

  /// The gap between two of them.
  static const double actionGap = 12;

  /// A label's size.
  static const double label = 11;

  /// An action's size.
  static const double action = 12.5;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<ConflictRegionValueObject>('region', region))
      ..add(DoubleProperty('body', body))
      ..add(
        ObjectFlagProperty<ValueChanged<ConflictChoiceEnum>>.has(
          'onChoose',
          onChoose,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    // Laid out like every other block, marked or not, so a conflict does not
    // shorten the line and rag the column.
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(width: TomMetrics.mark),
        const SizedBox(width: PreviewDesign.diffPad),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: colors.modifiedSoft,
              border: Border(
                left: BorderSide(
                  color: colors.modified,
                  width: PreviewDesign.diffBar,
                ),
              ),
              borderRadius: BorderRadius.circular(PreviewDesign.diffRadius),
            ),
            padding: const EdgeInsets.all(PreviewDesign.diffPad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: labelTop),
                _label(colors, 'Current Change'),
                const SizedBox(height: labelGap),
                _side(colors, region.current),
                const SizedBox(height: sideGap),
                // The rule is the seam between the two sides, in the same
                // ink as their labels: one more thing saying they are two.
                Container(height: 1, color: colors.modified),
                const SizedBox(height: sideGap),
                _label(colors, 'Incoming Change'),
                const SizedBox(height: labelGap),
                _side(colors, region.incoming),
                const SizedBox(height: sideGap + labelGap),
                _actions(colors),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Which side this is, above it rather than beside it.
  Widget _label(TomColors colors, String text) => Text(
    text,
    style: TextStyle(
      fontSize: label,
      height: 1.4,
      fontWeight: FontWeight.w600,
      color: colors.modified,
    ),
  );

  /// One side's text, in the prose the document is written in.
  ///
  /// Empty is drawn as nothing rather than as a gap with a word missing: a
  /// side that adds nothing is one of the two real answers.
  Widget _side(TomColors colors, String text) => Text(
    text,
    style: TextStyle(
      fontSize: body,
      height: PreviewDesign.bodyHeight,
      color: colors.textPrimary,
    ),
  );

  /// The three, in the order the situation has them.
  ///
  /// Three because that is what a merge offers: the one who wrote first, the
  /// one who wrote after, and the two that turn out not to disagree.
  ///
  /// Wrapped rather than in a row: the boards draw the preview with the
  /// explorer closed, and the three at their own widths need 504 — more than
  /// a split pane has with both columns open. Wrapping keeps the board's
  /// line where there is room for it and moves the third down where there is
  /// not, which beats a button somebody cannot reach.
  Widget _actions(TomColors colors) => Wrap(
    spacing: actionGap,
    runSpacing: actionGap,
    children: <Widget>[
      _act(
        colors,
        'Accept Current Change',
        ConflictChoiceEnum.current,
        currentWidth,
      ),
      _act(
        colors,
        'Accept Incoming Change',
        ConflictChoiceEnum.incoming,
        incomingWidth,
      ),
      _act(colors, 'Accept Both Changes', ConflictChoiceEnum.both, bothWidth),
    ],
  );

  /// One of them: outlined rather than filled, because none of the three is
  /// the answer the product prefers.
  Widget _act(
    TomColors colors,
    String text,
    ConflictChoiceEnum choice,
    double width,
  ) => SizedBox(
    width: width,
    height: actionHeight,
    child: OutlinedButton(
      onPressed: () => onChoose(choice),
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.modified,
        side: BorderSide(color: colors.modified),
        padding: EdgeInsets.zero,
        minimumSize: Size(width, actionHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TomMetrics.radius),
        ),
        textStyle: const TextStyle(
          fontSize: action,
          fontWeight: FontWeight.w500,
        ),
      ),
      child: Text(text),
    ),
  );
}
