/// One block, with what changed about it drawn around it.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tom_desktop/screens/preview/preview_design.dart';
import 'package:tom_desktop/screens/preview/widgets/preview_block_widget.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_ui/tom_ui.dart';

/// The rendered diff: the block as it is drawn, in the tint of what happened
/// to it, with a mark in the gutter.
///
/// **An unchanged block is drawn exactly as it was.** The diff is on screen
/// for whole documents at a time, so anything it adds to what did not change
/// is noise a reader has to learn to ignore
/// (`docs/product/diff/rendered-diff/doc.md`).
///
/// The letters are this screen's alphabet: A, R and M, for a block that
/// arrived, went or was rewritten. Nothing is renamed here, which is what
/// frees the R the changes column spends on a rename.
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

  /// The prose size, which is the reading mode's answer or the split's.
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
      // A removed block is read in its own version's scope: the reference
      // definitions that resolve its links are the ones it was written with.
      document: block is DiffBlockRemoved ? diff.before : diff.after,
      body: body,
      struckThrough: block is DiffBlockRemoved,
    );
    final (Color, Color, String, String)? role = _roleOf(colors);
    // **Every block of a document being diffed is laid out the same way**,
    // marked or not: a gutter, then the prose. Insetting only the changed
    // ones would give them a shorter line than their neighbours, and the
    // column would go ragged as somebody typed.
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
              // Transparent where nothing happened, and the same width
              // either way: a border is drawn inside the box, so a bar only
              // the changed blocks carried would shift their text.
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

  /// How this block is spelled: the tint, the letter and the whole word.
  ///
  /// Null for a block nothing happened to, which is what "no decoration at
  /// all" is made of. Exhaustive, so a fifth verdict has to answer here.
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
