/// The document, scrolling as one column of blocks.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tom_desktop/screens/preview/preview_design.dart';
import 'package:tom_desktop/screens/preview/widgets/preview_block_widget.dart';
import 'package:tom_desktop/screens/preview/widgets/preview_diff_widget.dart';
import 'package:tom_desktop/screens/preview/widgets/preview_note_widget.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_ui/tom_ui.dart';

/// The document, scrolling as one column of blocks, one [PreviewBlockWidget]
/// each
/// ([runtime](../../../../../../../docs/technical/runtime/preview.md)).
class PreviewDocumentWidget extends StatelessWidget {
  /// Creates the column for [document].
  const PreviewDocumentWidget({
    required this.document,
    required this.isReading,
    this.diff,
    super.key,
  });

  /// What to render.
  final ParsedDocumentValueObject document;

  /// What changed against `HEAD`, when that is known and anything did.
  ///
  /// The column is then the diff's sequence, not the document's, because a
  /// removed block has to be drawn where it used to be.
  final DocumentDiffValueObject? diff;

  /// Whether the preview has the document area to itself, which is the mode
  /// the wider measure and the larger prose belong to.
  final bool isReading;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        DiagnosticsProperty<ParsedDocumentValueObject>('document', document),
      )
      ..add(DiagnosticsProperty<bool>('isReading', isReading))
      ..add(DiagnosticsProperty<DocumentDiffValueObject?>('diff', diff));
  }

  @override
  Widget build(BuildContext context) {
    if (document.blocks.isEmpty && (diff?.blocks.isEmpty ?? true)) {
      return const PreviewNoteWidget('This document is empty.');
    }
    // A document that matches `HEAD` is drawn undecorated
    // (`docs/product/diff/rendered-diff/what-is-compared/doc.md`).
    final DocumentDiffValueObject? changes = (diff?.isUnchanged ?? true)
        ? null
        : diff;
    final double measure = isReading
        ? PreviewDesign.readingMeasure
        : PreviewDesign.measure;
    return Align(
      // Centred when the pane is the document's, left when it is shared: a
      // column hugging the divider reads as a leftover.
      alignment: isReading ? Alignment.topCenter : Alignment.topLeft,
      child: SizedBox(
        // A measure, not a pane: the column keeps its line length and the
        // pane grows around it, the diff's gutter included.
        width:
            measure +
            TomMetrics.pad * 2 +
            (changes == null ? 0 : PreviewDesign.diffInset),
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(
            TomMetrics.pad,
            0,
            TomMetrics.pad,
            TomMetrics.pad,
          ),
          itemCount: changes?.blocks.length ?? document.blocks.length,
          separatorBuilder: (BuildContext context, int index) =>
              const SizedBox(height: PreviewDesign.blockGap),
          itemBuilder: (BuildContext context, int index) => changes == null
              ? PreviewBlockWidget(
                  block: document.blocks[index],
                  document: document,
                  body: isReading
                      ? PreviewDesign.readingBody
                      : PreviewDesign.body,
                )
              : PreviewDiffWidget(
                  block: changes.blocks[index],
                  diff: changes,
                  body: isReading
                      ? PreviewDesign.readingBody
                      : PreviewDesign.body,
                ),
        ),
      ),
    );
  }
}
