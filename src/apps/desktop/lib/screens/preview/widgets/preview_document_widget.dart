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

/// The document, scrolling as one column of blocks.
///
/// One [PreviewBlockWidget] per block and never one tree for the whole
/// document
/// ([flows](../../../../../../../docs/technical/flows.md#the-preview-is-assembled-block-by-block)).
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
  /// The column is then the *diff's* sequence rather than the document's,
  /// because a removed block is in neither version on disk and has to be
  /// drawn where it used to be.
  final DocumentDiffValueObject? diff;

  /// Whether the preview has the document area to itself.
  ///
  /// The mode the wider measure and the larger prose belong to: reading is
  /// not a lesser mode, and for anyone who never opens the source it is the
  /// product.
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
    // A document nothing changed is drawn as a document: the diff never adds
    // decoration to a file that matches `HEAD`
    // (`docs/product/diff/rendered-diff/doc.md`).
    final DocumentDiffValueObject? changes = (diff?.isUnchanged ?? true)
        ? null
        : diff;
    final double measure = isReading
        ? PreviewDesign.readingMeasure
        : PreviewDesign.measure;
    return Align(
      // Centred when the pane is the document's, left when it is sharing:
      // a reading column hugging the divider would read as a leftover.
      alignment: isReading ? Alignment.topCenter : Alignment.topLeft,
      child: SizedBox(
        // A measure, not a pane: the column keeps its line length whatever
        // the window does, and the pane grows around it — the diff's gutter
        // and tint included.
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
