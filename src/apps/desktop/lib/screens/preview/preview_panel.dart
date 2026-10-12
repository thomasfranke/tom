/// The preview: the open document, rendered block by block.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_desktop/l10n/l10n.dart';
import 'package:tom_desktop/screens/preview/preview_design.dart';
import 'package:tom_desktop/screens/preview/widgets/preview_document_widget.dart';
import 'package:tom_desktop/screens/preview/widgets/preview_note_widget.dart';
import 'package:tom_desktop/screens/shell/document_scroll_link.dart';
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
    final DocumentModeEnum? mode = ref.watch(
      spaceSessionProvider.select(
        (SpaceSessionState? session) => session?.mode,
      ),
    );
    final bool isReading = mode == DocumentModeEnum.preview;
    // Beside the source, scrolling either scrolls the other; alone, nothing
    // is linked.
    final DocumentScrollLink? link = mode == DocumentModeEnum.split
        ? ref.watch(documentScrollLinkProvider)
        : null;
    // Watched here, above the document, so a followed `#anchor` outlives
    // the moment between one document and the next.
    final PreviewAnchor? anchor = ref.watch(previewAnchorProvider);
    // A click on a search occurrence asks the editor to go to a place; with
    // only the preview on screen it is the preview that goes there.
    final ({int count, int line}) asked = ref.watch(
      editorProvider.select(
        (EditorState editor) => editor is EditorReady
            ? (
                count: editor.reveals,
                line: '\n'
                    .allMatches(
                      editor.source.substring(
                        0,
                        editor.selectionStart.clamp(0, editor.source.length),
                      ),
                    )
                    .length,
              )
            : (count: 0, line: 0),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: PreviewDesign.bodyTop),
        Expanded(
          child: switch (state) {
            PreviewEmpty() => PreviewNoteWidget(
              context.l10n.commonChooseADocument,
            ),
            PreviewLoading() => PreviewNoteWidget(
              context.l10n.commonReadingTheDocument,
            ),
            PreviewFailed(failure: final AppFailure failure) =>
              PreviewNoteWidget(_explain(context.l10n, failure)),
            PreviewReady(
              document: final ParsedDocumentValueObject document,
              diff: final DocumentDiffValueObject? diff,
              segments: final List<PreviewSegment>? segments,
            ) =>
              PreviewDocumentWidget(
                document: document,
                isReading: isReading,
                link: link,
                diff: diff,
                segments: segments,
                anchor: anchor,
                reveals: asked.count,
                revealLine: asked.line,
                onAnchor: () =>
                    ref.read(previewAnchorProvider.notifier).take(document),
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
  static String _explain(AppLocalizations l10n, AppFailure failure) =>
      switch (failure) {
        DocumentNotFound() => l10n.documentNotFound,
        DocumentPermissionDenied() => l10n.documentPermissionDenied,
        DocumentNotUtf8() => l10n.documentNotUtf8,
        _ => l10n.documentUnreadable,
      };
}
