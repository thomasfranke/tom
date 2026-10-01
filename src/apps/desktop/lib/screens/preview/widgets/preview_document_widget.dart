/// The document, scrolling as one column of blocks.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tom_desktop/screens/preview/preview_design.dart';
import 'package:tom_desktop/screens/preview/widgets/preview_block_widget.dart';
import 'package:tom_desktop/screens/preview/widgets/preview_conflict_widget.dart';
import 'package:tom_desktop/screens/preview/widgets/preview_diff_widget.dart';
import 'package:tom_desktop/screens/preview/widgets/preview_footnotes_widget.dart';
import 'package:tom_desktop/screens/preview/widgets/preview_note_widget.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
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
    this.segments,
    this.onChoose,
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

  /// The document cut at its conflicts, when it holds any.
  ///
  /// Non-null takes over from [document] and from [diff] both: while a
  /// marker is on screen the preview shows the conflict and nothing else.
  final List<PreviewSegment>? segments;

  /// What to do when a side is chosen.
  final void Function(ConflictRegionValueObject, ConflictChoiceEnum)? onChoose;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        DiagnosticsProperty<ParsedDocumentValueObject>('document', document),
      )
      ..add(DiagnosticsProperty<bool>('isReading', isReading))
      ..add(DiagnosticsProperty<DocumentDiffValueObject?>('diff', diff))
      ..add(IntProperty('segments', segments?.length))
      ..add(
        ObjectFlagProperty<
          void Function(ConflictRegionValueObject, ConflictChoiceEnum)?
        >.has('onChoose', onChoose),
      );
  }

  /// One row per block outside a conflict, and one per conflict.
  ///
  /// Flattened here rather than nested, so the whole document stays a single
  /// scrolling column however many conflicts it holds.
  List<Widget> _rows(double body) {
    final List<Widget> rows = <Widget>[];
    for (final PreviewSegment part in segments!) {
      switch (part) {
        case PreviewProse(document: final ParsedDocumentValueObject prose):
          for (final BlockValueObject block in prose.blocks) {
            rows.add(
              PreviewBlockWidget(block: block, document: prose, body: body),
            );
          }
        case PreviewConflict(region: final ConflictRegionValueObject region):
          rows.add(
            PreviewConflictWidget(
              region: region,
              body: body,
              onChoose: (ConflictChoiceEnum choice) =>
                  onChoose?.call(region, choice),
            ),
          );
      }
    }
    return rows;
  }

  /// How many rows the blocks themselves take.
  int _rowCount(List<Widget>? rows, DocumentDiffValueObject? changes) =>
      rows?.length ?? changes?.blocks.length ?? document.blocks.length;

  @override
  Widget build(BuildContext context) {
    if (document.blocks.isEmpty &&
        (diff?.blocks.isEmpty ?? true) &&
        (segments?.isEmpty ?? true)) {
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
    final List<Widget>? rows = segments == null
        ? null
        : _rows(isReading ? PreviewDesign.readingBody : PreviewDesign.body);
    // Not while a marker is on screen: the conflict is what the preview is
    // showing, and a foot assembled from a half-merged document would be
    // assembled from two.
    final bool hasFootnotes = segments == null && document.footnotes.isNotEmpty;
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
            (changes == null && segments == null ? 0 : PreviewDesign.diffInset),
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(
            TomMetrics.pad,
            0,
            TomMetrics.pad,
            TomMetrics.pad,
          ),
          // One more row than there are blocks when the document has notes:
          // the foot is assembled from what was written all over it, so it
          // belongs to the document rather than to any block.
          itemCount: _rowCount(rows, changes) + (hasFootnotes ? 1 : 0),
          separatorBuilder: (BuildContext context, int index) =>
              const SizedBox(height: PreviewDesign.blockGap),
          itemBuilder: (BuildContext context, int index) =>
              hasFootnotes && index == _rowCount(rows, changes)
              ? PreviewFootnotesWidget(
                  footnotes: document.footnotes,
                  body: isReading
                      ? PreviewDesign.readingBody
                      : PreviewDesign.body,
                )
              : rows != null
              ? rows[index]
              : changes == null
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
