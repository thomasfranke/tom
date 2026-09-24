/// What the editor is holding right now.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

part 'editor_state.freezed.dart';

/// The states the editor can be in, and there are only these.
///
/// [EditorEmpty] is not a stalled load: it is a space with no document
/// chosen, which is how every space opens.
@freezed
sealed class EditorState with _$EditorState {
  /// No document is open.
  const factory EditorState.empty() = EditorEmpty;

  /// A document is being read off the disk.
  const factory EditorState.loading() = EditorLoading;

  /// The document is open, and this is the buffer over it.
  const factory EditorState.ready({
    /// The document as the disk last agreed it was.
    ///
    /// What the buffer is compared against, and what a save replaces. **The
    /// file is the truth**, so this is the app's record of that truth and
    /// never a second one.
    required DocumentEntity saved,

    /// The text being edited, which is the file's content until it is not.
    required String source,

    /// Whether a write is in flight.
    @Default(false) bool isSaving,

    /// Why the last save did not land, or null when it did.
    ///
    /// A save that fails silently is the one thing a text editor may never
    /// do: the buffer still holds work and the file does not.
    AppFailure? saveFailure,
  }) = EditorReady;

  /// The document could not be read.
  const factory EditorState.failed(AppFailure failure) = EditorFailed;

  const EditorState._();

  /// Whether the buffer and the file on disk have drifted apart.
  ///
  /// Compared rather than flagged, so typing a character and taking it back
  /// leaves the document clean — a flag would call that unsaved for the rest
  /// of the session.
  bool get isDirty => switch (this) {
    EditorReady(:final DocumentEntity saved, :final String source) =>
      saved.content != source,
    _ => false,
  };
}
