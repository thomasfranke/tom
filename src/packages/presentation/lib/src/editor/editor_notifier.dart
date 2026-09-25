/// The editor's state: the open document, and the buffer over it.
library;

import 'dart:async';

// `select` lives in the runtime package, not in `riverpod_annotation`.
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

/// The one buffer in the app, over whatever document the session says is
/// open; the preview renders it rather than the file
/// (`docs/product/editor/source-mode/doc.md`).
///
/// Kept alive because changing the mode takes the source panel off screen,
/// and an unsaved buffer must not go with it.
@Riverpod(keepAlive: true)
class EditorNotifier extends _$EditorNotifier {
  /// Reads a document's source off the disk.
  ReadDocumentUseCase get readDocument => ref.read(readDocumentProvider);

  /// Writes the buffer back.
  SaveDocumentUseCase get saveDocument => ref.read(saveDocumentProvider);

  @override
  EditorState build() {
    // The space and the document separately, never the session whole: a
    // mode change would rebuild this and throw an unsaved buffer away.
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
    // Scheduled, not awaited: `build` answers synchronously.
    unawaited(Future<void>.microtask(() => _load(space, path)));
    return const EditorState.loading();
  }

  /// Replaces the buffer with [source]; nothing here writes to a disk.
  void edit(String source) {
    if (state case final EditorReady ready) {
      state = ready.copyWith(source: source, saveFailure: null);
    }
  }

  /// Writes the buffer where the document came from.
  ///
  /// A clean document is not written: a write nobody needs would touch the
  /// file's timestamp for git to notice.
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
      // The panel can be gone by the time the disk answers.
      if (!ref.mounted) {
        return;
      }
      _settle(written, saved);
    }
  }

  /// Reads the open document off the disk again, dropping the buffer.
  ///
  /// What a branch switch leaves behind
  /// (`docs/product/git-workflow/branch-switch/doc.md`), and how *discard*
  /// is spelled.
  Future<void> reload() async {
    final SpaceSessionState? session = ref.read(spaceSessionProvider);
    if (session?.openDocument case final SpaceRelativePathValueObject path) {
      await _load(session!.space, path);
    }
  }

  /// Records what the write did, over whatever the buffer holds now.
  ///
  /// [written] is what reached the disk, not necessarily what is on screen:
  /// typing during a save leaves the document saved *and* dirty again.
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
    // The session can have moved on by the time the disk answers.
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
