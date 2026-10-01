/// The preview: the open document, rendered block by block.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_desktop/screens/preview/preview_design.dart';
import 'package:tom_desktop/screens/preview/widgets/preview_document_widget.dart';
import 'package:tom_desktop/screens/preview/widgets/preview_note_widget.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';

/// The open document, one container per block
/// ([runtime](../../../../../../docs/technical/runtime/preview.md)).
///
/// The container is the app's and carries the diff decoration; what is
/// inside it is delegated.
class PreviewPanel extends ConsumerWidget {
  /// Creates the panel.
  const PreviewPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PreviewState state = ref.watch(previewProvider);
    // Preview-only is the mode the wider measure belongs to.
    final bool isReading =
        ref.watch(
          spaceSessionProvider.select(
            (SpaceSessionState? session) => session?.mode,
          ),
        ) ==
        DocumentModeEnum.preview;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: PreviewDesign.bodyTop),
        Expanded(
          child: switch (state) {
            PreviewEmpty() => const PreviewNoteWidget(
              'Choose a document in the explorer.',
            ),
            PreviewLoading() => const PreviewNoteWidget(
              'Reading the document…',
            ),
            PreviewFailed(failure: final AppFailure failure) =>
              PreviewNoteWidget(_explain(failure)),
            PreviewReady(
              document: final ParsedDocumentValueObject document,
              diff: final DocumentDiffValueObject? diff,
              segments: final List<PreviewSegment>? segments,
            ) =>
              PreviewDocumentWidget(
                document: document,
                isReading: isReading,
                diff: diff,
                segments: segments,
                onChoose:
                    (
                      ConflictRegionValueObject region,
                      ConflictChoiceEnum choice,
                    ) => _choose(ref, document, region, choice),
              ),
          },
        ),
      ],
    );
  }

  /// Keeps the side that was chosen, in the buffer.
  ///
  /// **A choice is an edit, not a save**: the document is rewritten where it
  /// is being typed, the unsaved mark appears, and undo walks back through
  /// it like any other keystroke. The file on disk changes when somebody
  /// saves it (`docs/product/editor/conflicted-document/doc.md`).
  static void _choose(
    WidgetRef ref,
    ParsedDocumentValueObject document,
    ConflictRegionValueObject region,
    ConflictChoiceEnum choice,
  ) {
    const ConflictScannerService scanner = ConflictScannerService();
    ref
        .read(editorProvider.notifier)
        .edit(scanner.resolve(document.document.content, region, choice));
  }

  /// What to say about a document that did not open.
  ///
  /// A catch-all, because this switches over [AppFailure] itself and the
  /// panel must say something whatever went wrong.
  static String _explain(AppFailure failure) => switch (failure) {
    DocumentNotFound() => 'That document is no longer there.',
    DocumentPermissionDenied() => 'TOM is not allowed to read that document.',
    DocumentNotUtf8() =>
      'That file is not UTF-8 text, so TOM will not open it.',
    _ => 'That document could not be read.',
  };
}
