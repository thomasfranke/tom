/// The document, scrolling as one column of blocks.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tom_desktop/screens/preview/preview_design.dart';
import 'package:tom_desktop/screens/preview/widgets/preview_block_widget.dart';
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
    super.key,
  });

  /// What to render.
  final ParsedDocumentValueObject document;

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
      ..add(DiagnosticsProperty<bool>('isReading', isReading));
  }

  @override
  Widget build(BuildContext context) {
    if (document.blocks.isEmpty) {
      return const PreviewNoteWidget('This document is empty.');
    }
    final double measure = isReading
        ? PreviewDesign.readingMeasure
        : PreviewDesign.measure;
    return Align(
      // Centred when the pane is the document's, left when it is sharing:
      // a reading column hugging the divider would read as a leftover.
      alignment: isReading ? Alignment.topCenter : Alignment.topLeft,
      child: SizedBox(
        // A measure, not a pane: the column keeps its line length whatever
        // the window does, and the pane grows around it.
        width: measure + TomMetrics.pad * 2,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(
            TomMetrics.pad,
            0,
            TomMetrics.pad,
            TomMetrics.pad,
          ),
          itemCount: document.blocks.length,
          separatorBuilder: (BuildContext context, int index) =>
              const SizedBox(height: PreviewDesign.blockGap),
          itemBuilder: (BuildContext context, int index) => PreviewBlockWidget(
            block: document.blocks[index],
            document: document,
            body: isReading ? PreviewDesign.readingBody : PreviewDesign.body,
          ),
        ),
      ),
    );
  }
}
