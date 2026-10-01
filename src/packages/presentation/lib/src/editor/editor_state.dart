/// What the editor is holding right now.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

part 'editor_state.freezed.dart';

/// The states the editor can be in, and there are only these.
///
/// [EditorEmpty] is a space with no document chosen, not a stalled load.
@freezed
sealed class EditorState with _$EditorState {
  /// No document is open.
  const factory EditorState.empty() = EditorEmpty;

  /// A document is being read off the disk.
  const factory EditorState.loading() = EditorLoading;

  /// The document is open, and this is the buffer over it.
  const factory EditorState.ready({
    /// The document as the disk last agreed it was — what the buffer is
    /// compared against, and what a save replaces.
    required DocumentEntity saved,

    /// The text being edited, which is the file's content until it is not.
    required String source,

    /// Where the caret is, as an offset into the buffer.
    ///
    /// Here because the toolbar is not inside the pane: a button that bolds
    /// the selection has to know what is selected, and the row sits above
    /// the document rather than in it
    /// (`docs/product/editor/formatting-shortcuts/doc.md`).
    @Default(0) int selectionStart,

    /// Where it ends, exclusive; equal to the start for a caret.
    @Default(0) int selectionEnd,

    /// Whether a write is in flight.
    @Default(false) bool isSaving,

    /// Why the last save did not land, or null when it did.
    ///
    /// Said rather than swallowed, because the buffer still holds work and
    /// the file does not.
    AppFailure? saveFailure,
  }) = EditorReady;

  /// The document could not be read.
  const factory EditorState.failed(AppFailure failure) = EditorFailed;

  const EditorState._();

  /// Whether the buffer and the file on disk have drifted apart.
  ///
  /// Compared rather than flagged, so typing a character and taking it back
  /// leaves the document clean.
  bool get isDirty => switch (this) {
    EditorReady(:final DocumentEntity saved, :final String source) =>
      saved.content != source,
    _ => false,
  };
}
