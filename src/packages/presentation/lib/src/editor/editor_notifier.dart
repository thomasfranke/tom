/// The editor's state: the open document, and the buffer over it.
library;

import 'dart:async';

// `select` is an extension on `ProviderListenable` and lives in the runtime
// package; `riverpod_annotation` carries the annotations and not much else.
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/src/editor/editor_providers.dart';
import 'package:tom_presentation/src/editor/editor_state.dart';
import 'package:tom_presentation/src/spaces/space_session.dart';
import 'package:tom_presentation/src/spaces/space_session_notifier.dart';

part 'editor_notifier.g.dart';

/// Holds the buffer for whatever document the session says is open.
///
/// **The one buffer in the app.** The preview renders it rather than the
/// file, which is what makes an edit appear on the other side with no
/// refresh step (`docs/product/editor/source-mode/doc.md`).
///
/// Everything else here guards it. It watches the space and the open
/// document one at a time rather than the session whole, and it is kept
/// alive rather than disposed the moment nothing listens: changing the mode
/// takes the source panel off screen, and an unsaved buffer must not go
/// with it.
@Riverpod(keepAlive: true)
class EditorNotifier extends _$EditorNotifier {
  /// Reads a document's source off the disk.
  ReadDocumentUseCase get readDocument => ref.read(readDocumentProvider);

  /// Writes the buffer back.
  SaveDocumentUseCase get saveDocument => ref.read(saveDocumentProvider);

  @override
  EditorState build() {
    final SpaceEntity? space = ref.watch(
      spaceSessionProvider.select(
        (SpaceSessionState? session) => session?.space,
      ),
    );
    final SpaceRelativePathValueObject? path = ref.watch(
      spaceSessionProvider.select(
        (SpaceSessionState? session) => session?.openDocument,
      ),
    );
    if (space == null || path == null) {
      return const EditorState.empty();
    }
    // Scheduled, not awaited: `build` answers synchronously, and the first
    // answer is "reading it".
    unawaited(Future<void>.microtask(() => _load(space, path)));
    return const EditorState.loading();
  }

  /// Replaces the buffer with [source].
  ///
  /// Called on every keystroke, so it does nothing but hold text: a save is
  /// [save] and nothing here writes to a disk.
  void edit(String source) {
    if (state case final EditorReady ready) {
      state = ready.copyWith(source: source, saveFailure: null);
    }
  }

  /// Writes the buffer where the document came from.
  ///
  /// Saving a document that has not changed is allowed and does nothing —
  /// pressing the shortcut twice is not an error, and a write nobody needs
  /// would touch the file's timestamp for git to notice.
  Future<void> save() async {
    if (state case final EditorReady ready) {
      final SpaceEntity? space = ref.read(spaceSessionProvider)?.space;
      if (space == null || ready.isSaving || !ready.isDirty) {
        return;
      }
      final DocumentEntity written = ready.saved.copyWith(
        content: ready.source,
      );
      state = ready.copyWith(isSaving: true, saveFailure: null);
      final Result<void, AppFailure> saved = await saveDocument.save(
        space,
        written,
      );
      // The disk is real, and the panel can be gone by the time it answers.
      if (!ref.mounted) {
        return;
      }
      _settle(written, saved);
    }
  }

  /// Reads the open document off the disk again, dropping the buffer.
  ///
  /// **What a branch switch leaves behind.** Every open document shows the
  /// version on the new branch
  /// (`docs/product/git-workflow/branch-switch/doc.md`), and the buffer is
  /// the one thing that would still be showing the old one. It is also how
  /// *discard* is spelled: what was typed is thrown away by reading the file
  /// that is there now.
  Future<void> reload() async {
    final SpaceSessionState? session = ref.read(spaceSessionProvider);
    if (session?.openDocument case final SpaceRelativePathValueObject path) {
      await _load(session!.space, path);
    }
  }

  /// Records what the write did, over whatever the buffer holds now.
  ///
  /// [written] is what actually reached the disk, which is not necessarily
  /// what is on screen: typing during a save is ordinary, and the document
  /// is then saved *and* dirty again, which is the honest answer.
  void _settle(DocumentEntity written, Result<void, AppFailure> saved) {
    if (state case final EditorReady now) {
      state = switch (saved) {
        Success<void, AppFailure>() => now.copyWith(
          saved: written,
          isSaving: false,
        ),
        Failure<void, AppFailure>(failure: final AppFailure failure) =>
          now.copyWith(isSaving: false, saveFailure: failure),
      };
    }
  }

  /// Reads [path] inside [space] into a fresh buffer.
  Future<void> _load(
    SpaceEntity space,
    SpaceRelativePathValueObject path,
  ) async {
    final Result<DocumentEntity, AppFailure> read = await readDocument.read(
      space,
      path,
    );
    // The read is real disk, and the session can have moved on by the time
    // it answers — the notifier is rebuilt for the next document, and this
    // instance has nobody left to tell.
    if (!ref.mounted) {
      return;
    }
    state = switch (read) {
      Success<DocumentEntity, AppFailure>(
        value: final DocumentEntity document,
      ) =>
        EditorState.ready(saved: document, source: document.content),
      Failure<DocumentEntity, AppFailure>(failure: final AppFailure failure) =>
        EditorState.failed(failure),
    };
  }
}
