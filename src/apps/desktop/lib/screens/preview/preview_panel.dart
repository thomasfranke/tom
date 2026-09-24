/// The preview: the open document, rendered block by block.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_desktop/screens/preview/preview_design.dart';
import 'package:tom_desktop/screens/preview/widgets/preview_caption_widget.dart';
import 'package:tom_desktop/screens/preview/widgets/preview_document_widget.dart';
import 'package:tom_desktop/screens/preview/widgets/preview_note_widget.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';

/// The open document, one container per block.
///
/// **Assembled block by block, never as one widget tree**
/// ([flows](../../../../../../docs/technical/flows.md#the-preview-is-assembled-block-by-block)):
/// the container around each block is ours, and it is what will carry the
/// diff decoration in M2. Inline markdown inside a block is delegated, which
/// is where CommonMark's real complexity lives.
class PreviewPanel extends ConsumerWidget {
  /// Creates the panel.
  const PreviewPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PreviewState state = ref.watch(previewProvider);
    // Preview-only is the mode the generous measure belongs to: nothing is
    // sharing the pane, and this is how a reader sees the document.
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
        const SizedBox(height: PreviewDesign.captionTop),
        const PreviewCaptionWidget(),
        const SizedBox(
          height:
              PreviewDesign.bodyTop -
              PreviewDesign.captionTop -
              PreviewDesign.caption * 1.4,
        ),
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
            PreviewReady(document: final ParsedDocumentValueObject document) =>
              PreviewDocumentWidget(document: document, isReading: isReading),
          },
        ),
      ],
    );
  }

  /// What to say about a document that did not open.
  ///
  /// A catch-all, because this switches over [AppFailure] itself: whatever
  /// went wrong, the panel says something rather than staying blank.
  static String _explain(AppFailure failure) => switch (failure) {
    DocumentNotFound() => 'That document is no longer there.',
    DocumentPermissionDenied() => 'TOM is not allowed to read that document.',
    DocumentNotUtf8() =>
      'That file is not UTF-8 text, so TOM will not open it.',
    _ => 'That document could not be read.',
  };
}
