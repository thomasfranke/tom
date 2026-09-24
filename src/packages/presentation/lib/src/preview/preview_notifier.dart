/// The preview's state: the editor's buffer, as blocks.
library;

import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/src/editor/editor_notifier.dart';
import 'package:tom_presentation/src/editor/editor_state.dart';
import 'package:tom_presentation/src/preview/preview_providers.dart';
import 'package:tom_presentation/src/preview/preview_state.dart';
import 'package:tom_presentation/src/spaces/space_session.dart';
import 'package:tom_presentation/src/spaces/space_session_notifier.dart';

part 'preview_notifier.g.dart';

/// Renders whatever the editor is holding — or the version being read.
///
/// **It reads the buffer, never the disk**, which is what makes an edit
/// appear here with no refresh step (`docs/product/editor/source-mode/doc.md`).
/// The one exception is an opened history entry: the session names a commit,
/// that version is what is rendered — not diff text — and the editor is not
/// listened to at all while it is on screen.
///
/// It *listens* rather than watching: a rebuild would throw the rendered
/// blocks away and flash the pane back to "reading it" on every keystroke.
@riverpod
class PreviewNotifier extends _$PreviewNotifier {
  /// How long the last keystroke waits before the blocks are rebuilt.
  ///
  /// Short enough to read as live and long enough that a run of typing
  /// parses once rather than once per character — the frame a per-keystroke
  /// parse would land in already has the next keystroke in it.
  static const Duration settle = Duration(milliseconds: 120);

  /// Splits a document's source into blocks.
  SplitDocumentUseCase get splitDocument => ref.read(splitDocumentProvider);

  /// Reads a document as one commit left it.
  ReadVersionUseCase get readVersion => ref.read(readVersionProvider);

  Timer? _scheduled;

  /// Which render is the current one, so a slow parse cannot land after a
  /// newer one has already answered.
  int _generation = 0;

  @override
  PreviewState build() {
    ref.onDispose(() => _scheduled?.cancel());
    // Watched, not listened to: opening a version and coming back are both
    // a different document to draw, and rebuilding is the honest way to
    // start again.
    final SpaceSessionState? session = ref.watch(spaceSessionProvider);
    if (session?.readingVersion case final CommitEntity version) {
      if (session?.openDocument case final SpaceRelativePathValueObject path) {
        unawaited(
          Future<void>.microtask(
            () => _renderVersion(session!.space, version, path),
          ),
        );
        return const PreviewState.loading();
      }
    }
    ref.listen<EditorState>(editorProvider, _follow);
    final EditorState editor = ref.read(editorProvider);
    if (editor case final EditorReady ready) {
      // Scheduled, not awaited: `build` answers synchronously, and the first
      // answer is "reading it".
      unawaited(Future<void>.microtask(() => _render(_bufferOf(ready))));
      return const PreviewState.loading();
    }
    return _announce(editor);
  }

  /// Follows the editor from [previous] to [next].
  ///
  /// A keystroke waits [settle]; anything else — another document, a failed
  /// read, the first buffer — is drawn at once, because there is nothing on
  /// screen worth keeping.
  void _follow(EditorState? previous, EditorState next) {
    _scheduled?.cancel();
    if (next case final EditorReady ready) {
      final bool typed =
          previous is EditorReady &&
          previous.saved.path == ready.saved.path &&
          previous.source != ready.source;
      if (!typed) {
        // The same buffer saved, or reloaded: nothing to redraw.
        if (previous is EditorReady && previous.source == ready.source) {
          return;
        }
        unawaited(_render(_bufferOf(ready)));
        return;
      }
      _scheduled = Timer(settle, () => unawaited(_render(_bufferOf(ready))));
      return;
    }
    state = _announce(next);
  }

  /// What the preview says about an editor that is holding no buffer.
  PreviewState _announce(EditorState editor) => switch (editor) {
    EditorEmpty() => const PreviewState.empty(),
    EditorLoading() => const PreviewState.loading(),
    EditorFailed(failure: final AppFailure failure) => PreviewState.failed(
      failure,
    ),
    EditorReady() => const PreviewState.loading(),
  };

  /// The buffer as a document: the open document's path, the editor's text.
  DocumentEntity _bufferOf(EditorReady ready) =>
      ready.saved.copyWith(content: ready.source);

  /// Reads [path] as [version] left it, then renders it like any document.
  ///
  /// The read is git, not the disk, so it can fail on its own — a commit
  /// that never had this file, a repository that has moved on — and the
  /// pane says so rather than showing the working copy as if it were the
  /// past.
  Future<void> _renderVersion(
    SpaceEntity space,
    CommitEntity version,
    SpaceRelativePathValueObject path,
  ) async {
    final int generation = ++_generation;
    final Result<DocumentEntity, AppFailure> read = await readVersion.read(
      space,
      version.sha,
      path,
    );
    if (!ref.mounted || generation != _generation) {
      return;
    }
    switch (read) {
      case Success<DocumentEntity, AppFailure>(
        value: final DocumentEntity document,
      ):
        await _render(document);
      case Failure<DocumentEntity, AppFailure>(
        failure: final AppFailure failure,
      ):
        state = PreviewState.failed(failure);
    }
  }

  /// Splits [document] and shows what it holds.
  Future<void> _render(DocumentEntity document) async {
    final int generation = ++_generation;
    final Result<ParsedDocumentValueObject, AppFailure> split =
        await splitDocument.split(document);
    // A parse the user has already typed past, or a panel that is gone.
    if (!ref.mounted || generation != _generation) {
      return;
    }
    state = switch (split) {
      Success<ParsedDocumentValueObject, AppFailure>(
        value: final ParsedDocumentValueObject parsed,
      ) =>
        PreviewState.ready(parsed),
      Failure<ParsedDocumentValueObject, AppFailure>(
        failure: final AppFailure failure,
      ) =>
        PreviewState.failed(failure),
    };
  }
}
