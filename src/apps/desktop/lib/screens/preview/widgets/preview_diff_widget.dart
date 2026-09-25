/// One block, with what changed about it drawn around it.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tom_desktop/screens/preview/preview_design.dart';
import 'package:tom_desktop/screens/preview/widgets/preview_block_widget.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_ui/tom_ui.dart';

/// The rendered diff: the block as drawn, tinted by what happened to it,
/// with a mark in the gutter (`docs/product/diff/rendered-diff/doc.md`).
///
/// An unchanged block is drawn exactly as it was. The letters are this
/// screen's alphabet, A · R · M: nothing is renamed here, which frees the R
/// the changes column spends on a rename.
class PreviewDiffWidget extends StatelessWidget {
  /// Creates the view of [block].
  const PreviewDiffWidget({
    required this.block,
    required this.diff,
    required this.body,
    super.key,
  });

  /// The block and what happened to it.
  final DiffBlockValueObject block;

  /// The two versions, for the document scope each side needs to render.
  final DocumentDiffValueObject diff;

  /// The prose size, the reading mode's or the split's.
  final double body;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<DiffBlockValueObject>('block', block))
      ..add(DiagnosticsProperty<DocumentDiffValueObject>('diff', diff))
      ..add(DoubleProperty('body', body));
  }

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    final PreviewBlockWidget rendered = PreviewBlockWidget(
      block: block.drawn,
      // A removed block is rendered in its own version's scope, where the
      // definitions that resolve its links are.
      document: block is DiffBlockRemoved ? diff.before : diff.after,
      body: body,
      struckThrough: block is DiffBlockRemoved,
    );
    final (Color, Color, String, String)? role = _roleOf(colors);
    // Every block is laid out the same way, marked or not: insetting only
    // the changed ones would shorten their line and rag the column.
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: TomMetrics.mark,
          child: role == null
              ? null
              : DiffMarkWidget(
                  letter: role.$3,
                  ink: role.$1,
                  fill: colors.surface,
                  tooltip: role.$4,
                ),
        ),
        const SizedBox(width: PreviewDesign.diffPad),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: role?.$2,
              // Transparent where nothing happened, and the same width either
              // way: a border is drawn inside the box and would shift the
              // text.
              border: Border(
                left: BorderSide(
                  color: role?.$1 ?? Colors.transparent,
                  width: PreviewDesign.diffBar,
                ),
              ),
              borderRadius: BorderRadius.circular(PreviewDesign.diffRadius),
            ),
            padding: const EdgeInsets.all(PreviewDesign.diffPad),
            child: rendered,
          ),
        ),
      ],
    );
  }

  /// The ink, the tint, the letter and the word; null for a block nothing
  /// happened to.
  (Color, Color, String, String)? _roleOf(TomColors colors) => switch (block) {
    DiffBlockUnchanged() => null,
    DiffBlockAdded() => (colors.added, colors.addedSoft, 'A', 'Added'),
    DiffBlockRemoved() => (colors.removed, colors.removedSoft, 'R', 'Removed'),
    DiffBlockModified() => (
      colors.modified,
      colors.modifiedSoft,
      'M',
      'Modified',
    ),
  };
}
