/// What the editor is holding right now.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/src/spaces/document_tab.dart';

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

    /// How many times somebody asked the pane to go to the selection — a
    /// click on a search occurrence. A count and not a flag, so asking for
    /// the same place twice still moves a pane that was scrolled away.
    @Default(0) int reveals,

    /// Whether a write is in flight.
    @Default(false) bool isSaving,

    /// Why the last save did not land, or null when it did.
    ///
    /// Said rather than swallowed, because the buffer still holds work and
    /// the file does not.
    AppFailure? saveFailure,

    /// Whether this is a pull request draft rather than a document of the
    /// space — `saved`'s path is then the draft's, under `.git/tom/`, and
    /// nothing that reads the space (the index, the diff, the tabs) may
    /// take it for one of its own (Decision 33).
    @Default(false) bool isDraft,

    /// Whether this is the app's preferences file — JSON in the app's own
    /// folder, so nothing that reads the space may take it for one of its
    /// documents, nothing formats it as markdown, and saving it applies it
    /// (`docs/product/preferences/where-it-is-stored/doc.md`).
    @Default(false) bool isPreferences,

    /// Whether this is a changed file of the repository outside the space —
    /// `saved`'s path is then relative to the repository root, read and
    /// written through `SpaceEntity.repositorySpace`, and the index never
    /// files it (`docs/product/git-workflow/commit/opening-a-change/doc.md`).
    @Default(false) bool isOutside,

    /// Whether the file is gone from the disk and the buffer holds its last
    /// committed version — read-only, every line and block marked removed,
    /// and the tab saying so
    /// (`docs/product/git-workflow/commit/opening-a-change/doc.md`).
    @Default(false) bool isDeleted,

    /// Whether the file is not text — a zero byte in its first 8 KB, or not
    /// UTF-8 — so nothing of it was loaded and the tab says so instead.
    @Default(false) bool isBinary,

    /// Whether the file changed on disk under this buffer's unsaved edits —
    /// found by a save that asked first, or a choice in the popover for the
    /// preferences file — so the tab asks `Reload` or `Keep mine` rather
    /// than choosing for the person.
    @Default(false) bool changedOnDisk,

    /// Whether `Keep mine` was the answer: the next save writes over what
    /// the disk holds without asking again, and takes this back.
    @Default(false) bool overwritesDisk,
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

  /// Whether nothing typed reaches the buffer: a deleted file's last version
  /// or a binary file — what the status bar says as `Read-only`, and what
  /// takes undo, redo and the formatting buttons away.
  bool get isReadOnly => switch (this) {
    EditorReady(:final bool isDeleted, :final bool isBinary) =>
      isDeleted || isBinary,
    _ => false,
  };

  /// What kind of file the buffer holds, which the status bar names; null
  /// with no buffer. A draft is markdown wherever it is kept.
  FileKindEnum? get kind => switch (this) {
    EditorReady(isPreferences: true) => FileKindEnum.json,
    EditorReady(isDraft: true) => FileKindEnum.markdown,
    EditorReady(:final DocumentEntity saved) => FileKindEnum.of(
      saved.path.value,
    ),
    _ => null,
  };

  /// Whether the preview renders this buffer: markdown that is text.
  bool get isRendered => switch (this) {
    EditorReady(isBinary: false) => kind?.isMarkdown ?? false,
    _ => false,
  };

  /// The tab this buffer is held under, or null with no buffer.
  DocumentTab? get tab => switch (this) {
    EditorReady(isPreferences: true, :final DocumentEntity saved) =>
      DocumentTab.preferences(saved.path),
    EditorReady(isOutside: true, :final DocumentEntity saved) =>
      DocumentTab.outside(RepoRelativePathValueObject(saved.path.value)),
    EditorReady(:final DocumentEntity saved) => DocumentTab.inSpace(saved.path),
    _ => null,
  };

  /// The caret's line and column, both counted from one, or null with no
  /// buffer — what the status bar says as `Ln 5, Col 12`.
  ({int line, int column})? get caret => switch (this) {
    EditorReady(:final String source, :final int selectionEnd) => () {
      final int at = selectionEnd.clamp(0, source.length);
      final String before = source.substring(0, at);
      return (
        line: '\n'.allMatches(before).length + 1,
        column: at - before.lastIndexOf('\n'),
      );
    }(),
    _ => null,
  };
}
