/// Source mode: the open document's markdown, as text.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_desktop/l10n/l10n.dart';
import 'package:tom_desktop/screens/editor/editor_design.dart';
import 'package:tom_desktop/screens/editor/widgets/editor_binary_widget.dart';
import 'package:tom_desktop/screens/editor/widgets/editor_note_widget.dart';
import 'package:tom_desktop/screens/editor/widgets/editor_source_widget.dart';
import 'package:tom_desktop/screens/editor/widgets/editor_version_widget.dart';
import 'package:tom_desktop/screens/shell/document_scroll_link.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';

/// Everything the panel draws from, which is everything but the buffer.
///
/// One record, one `select`: the buffer changes on every keystroke and
/// nothing here does, so the panel is built per document, not per character.
typedef EditorStage = ({
  SpaceRelativePathValueObject? open,
  AppFailure? failure,
  bool isLoading,
  bool isBinary,
});

/// The open document's source, editable and never rich text
/// ([Decision 3](../../../../../../docs/technical/decisions/003-editor-is-source-plus-preview.md)).
class EditorPanel extends ConsumerWidget {
  /// Creates the panel.
  const EditorPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final EditorStage stage = ref.watch(editorProvider.select(stageOf));
    // No text to show, so no pane: the sentence is centred in the whole of
    // it rather than under the source's top inset.
    if (stage.isBinary) {
      return const EditorBinaryWidget();
    }
    final bool isReadingVersion = ref.watch(
      spaceSessionProvider.select(
        (SpaceSessionState? session) => session?.readingVersion != null,
      ),
    );
    // Beside the preview, scrolling either scrolls the other; alone, nothing
    // is linked — a kept pane under the preview is not beside it.
    final DocumentScrollLink? link =
        ref.watch(
              spaceSessionProvider.select(
                (SpaceSessionState? session) => session?.mode,
              ),
            ) ==
            DocumentModeEnum.split
        ? ref.watch(documentScrollLinkProvider)
        : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: EditorDesign.bodyTop),
        Expanded(
          child: _body(
            context.l10n,
            stage,
            isReadingVersion: isReadingVersion,
            link: link,
          ),
        ),
      ],
    );
  }

  /// What the pane holds.
  static Widget _body(
    AppLocalizations l10n,
    EditorStage stage, {
    required bool isReadingVersion,
    required DocumentScrollLink? link,
  }) {
    if (stage.open case final SpaceRelativePathValueObject open) {
      // Keyed by the document's path: another file is another controller,
      // and one carried across would carry its undo history too.
      //
      // While a version is read the working copy stays mounted and unseen
      // under it, in the same slot whether or not one is read, so coming back
      // finds the buffer, the caret and the history as they were left.
      return Stack(
        children: <Widget>[
          Positioned.fill(
            child: Visibility(
              visible: !isReadingVersion,
              maintainState: true,
              child: EditorSourceWidget(
                key: ValueKey<String>(open.value),
                link: link,
              ),
            ),
          ),
          Positioned.fill(
            child: isReadingVersion
                ? EditorVersionWidget(link: link)
                : const SizedBox.shrink(),
          ),
        ],
      );
    }
    if (stage.failure case final AppFailure failure) {
      return EditorNoteWidget(_explain(l10n, failure));
    }
    return EditorNoteWidget(
      stage.isLoading
          ? l10n.commonReadingTheDocument
          : l10n.commonChooseADocument,
    );
  }

  /// [state] with the buffer left out.
  static EditorStage stageOf(EditorState state) => (
    open: state is EditorReady ? state.saved.path : null,
    failure: state is EditorFailed ? state.failure : null,
    isLoading: state is EditorLoading,
    isBinary: state is EditorReady && state.isBinary,
  );

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
