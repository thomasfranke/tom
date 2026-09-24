/// Source mode: the open document's markdown, as text.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_desktop/screens/editor/editor_design.dart';
import 'package:tom_desktop/screens/editor/widgets/editor_caption_widget.dart';
import 'package:tom_desktop/screens/editor/widgets/editor_note_widget.dart';
import 'package:tom_desktop/screens/editor/widgets/editor_source_widget.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';

/// Everything the panel draws from, which is everything but the buffer.
///
/// A record so the whole thing is one `select`: the buffer changes on every
/// keystroke and nothing here does, so the panel is built once per document
/// rather than once per character.
typedef EditorStage = ({
  SpaceRelativePathValueObject? open,
  AppFailure? failure,
  bool isLoading,
});

/// The open document's source, editable.
///
/// **Deliberately not a rich-text editor** ([Decision
/// 3](../../../../../../docs/technical/decisions/003-editor-is-source-plus-preview.md)):
/// what is on screen is the file's own markdown, and the preview beside it
/// is where the formatting shows.
class EditorPanel extends ConsumerWidget {
  /// Creates the panel.
  const EditorPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final EditorStage stage = ref.watch(editorProvider.select(stageOf));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: EditorDesign.captionTop),
        const EditorCaptionWidget(),
        const SizedBox(
          height:
              EditorDesign.bodyTop -
              EditorDesign.captionTop -
              EditorDesign.caption * 1.4,
        ),
        Expanded(child: _body(stage)),
      ],
    );
  }

  /// What sits under the caption.
  static Widget _body(EditorStage stage) {
    if (stage.open case final SpaceRelativePathValueObject open) {
      // Keyed by the document's own path: another file is another buffer,
      // and a controller carried across would carry its undo history too.
      return EditorSourceWidget(key: ValueKey<String>(open.value));
    }
    if (stage.failure case final AppFailure failure) {
      return EditorNoteWidget(_explain(failure));
    }
    return EditorNoteWidget(
      stage.isLoading
          ? 'Reading the document…'
          : 'Choose a document in the explorer.',
    );
  }

  /// [state] with the buffer left out.
  static EditorStage stageOf(EditorState state) => (
    open: state is EditorReady ? state.saved.path : null,
    failure: state is EditorFailed ? state.failure : null,
    isLoading: state is EditorLoading,
  );

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
