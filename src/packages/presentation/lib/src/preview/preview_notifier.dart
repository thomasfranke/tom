/// The preview's state: the editor's buffer, as blocks.
library;

import 'dart:async';

// `select` lives in the runtime package, not in `riverpod_annotation`.
import 'package:riverpod/riverpod.dart';
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

/// Renders the editor's buffer, never the disk — or, for an opened history
/// entry, the version git holds (`docs/product/editor/source-mode/doc.md`).
///
/// It *listens* to the editor rather than watching: a rebuild would throw
/// the rendered blocks away and flash "reading it" on every keystroke.
@riverpod
class PreviewNotifier extends _$PreviewNotifier {
  /// How long the last keystroke waits before the blocks are rebuilt: long
  /// enough that a run of typing parses once, short enough to read as live.
  static const Duration settle = Duration(milliseconds: 120);

  /// Splits a document's source into blocks.
  SplitDocumentUseCase get splitDocument => ref.read(splitDocumentProvider);

  /// Reads a document as one commit left it.
  ReadVersionUseCase get readVersion => ref.read(readVersionProvider);

  /// Compares what is on screen against a revision.
  DiffDocumentUseCase get diffDocument => ref.read(diffDocumentProvider);

  Timer? _scheduled;

  /// Which render is the current one, so a slow parse cannot land after a
  /// newer one has already answered.
  int _generation = 0;

  @override
  PreviewState build() {
    ref.onDispose(() => _scheduled?.cancel());
    // The version only, not the session: opened or closed it is another
    // document to draw, while a mode change or a git reading is nothing to
    // redraw at all.
    final CommitEntity? version = ref.watch(
      spaceSessionProvider.select(
        (SpaceSessionState? session) => session?.readingVersion,
      ),
    );
    // Listened to, not watched: neither another base nor a commit changes
    // the text, only what it is measured against, so the marks are worked
    // out again over the blocks already on screen. **The git reading is in
    // here because a commit is what makes a marked document clean** — it
    // moves `HEAD` without touching a character of the buffer.
    ref.listen<({RevisionValueObject? base, GitStatusValueObject? git})>(
      spaceSessionProvider.select(
        (SpaceSessionState? session) =>
            (base: session?.comparingAgainst, git: session?.git),
      ),
      (
        ({RevisionValueObject? base, GitStatusValueObject? git})? _,
        ({RevisionValueObject? base, GitStatusValueObject? git}) _,
      ) => unawaited(_recompare()),
    );
    final SpaceSessionState? session = ref.read(spaceSessionProvider);
    if (version != null && session != null) {
      if (session.openDocument case final SpaceRelativePathValueObject path) {
        unawaited(
          Future<void>.microtask(
            () => _renderVersion(session.space, version, path),
          ),
        );
        return const PreviewState.loading();
      }
    }
    ref.listen<EditorState>(editorProvider, _follow);
    final EditorState editor = ref.read(editorProvider);
    if (editor case final EditorReady ready) {
      // Scheduled, not awaited: `build` answers synchronously.
      unawaited(Future<void>.microtask(() => _render(_bufferOf(ready))));
      return const PreviewState.loading();
    }
    return _announce(editor);
  }

  /// Follows the editor from [previous] to [next]: a keystroke waits
  /// [settle], anything else is drawn at once because nothing on screen is
  /// worth keeping.
  void _follow(EditorState? previous, EditorState next) {
    _scheduled?.cancel();
    if (next case final EditorReady ready) {
      final bool sameDocument =
          previous is EditorReady && previous.saved.path == ready.saved.path;
      final bool typed = sameDocument && previous.source != ready.source;
      if (!typed) {
        // The same buffer saved, or reloaded: nothing to redraw. The path is
        // part of "same" — two documents with identical text still resolve
        // their links from different folders.
        if (sameDocument && previous.source == ready.source) {
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

  /// Reads [path] as [version] left it, then renders it like any document;
  /// a read git refuses is said, rather than the working copy shown as the
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
  ///
  /// A document already on screen is replaced whole, text and marks together,
  /// once the comparison answers: text first would drop every mark and the
  /// gutter for as long as git takes, and undecorated is what the pane draws
  /// for a document nothing changed. With nothing to keep, text goes up first.
  Future<void> _render(DocumentEntity document) async {
    final int generation = ++_generation;
    final bool replacing = state is PreviewReady;
    final Result<ParsedDocumentValueObject, AppFailure> split =
        await splitDocument.split(document);
    // A parse the user has already typed past, or a panel that is gone.
    if (!ref.mounted || generation != _generation) {
      return;
    }
    switch (split) {
      case Success<ParsedDocumentValueObject, AppFailure>(
        value: final ParsedDocumentValueObject parsed,
      ):
        if (!replacing) {
          state = PreviewState.ready(parsed);
        }
        await _decorate(parsed, generation, always: replacing);
      case Failure<ParsedDocumentValueObject, AppFailure>(
        failure: final AppFailure failure,
      ):
        state = PreviewState.failed(failure);
    }
  }

  /// Compares what is on screen again, because the base changed.
  ///
  /// The text is kept and only the marks move: another base is not another
  /// document, so there is nothing to read again.
  Future<void> _recompare() async {
    if (state case PreviewReady(document: final ParsedDocumentValueObject on)) {
      await _decorate(on, ++_generation, always: true);
    }
  }

  /// Publishes [parsed] with what it changed, once git has said.
  ///
  /// [always] publishes an undecorated answer too; without it, a document
  /// already on screen that changed nothing is left as it is.
  Future<void> _decorate(
    ParsedDocumentValueObject parsed,
    int generation, {
    required bool always,
  }) async {
    final DocumentDiffValueObject? diff = await _compare(parsed, generation);
    if (!ref.mounted || generation != _generation) {
      return;
    }
    if (always || diff != null) {
      state = PreviewState.ready(parsed, diff: diff);
    }
  }

  /// Asks what [parsed] changed against the session's base: `HEAD` unless a
  /// revision was chosen, and nothing at all for a version being read that
  /// nobody asked to compare (`docs/product/diff/branch-diff/doc.md`).
  ///
  /// A comparison that fails answers null, leaving the document undecorated
  /// rather than replaced by an error: what failed is the diff.
  Future<DocumentDiffValueObject?> _compare(
    ParsedDocumentValueObject parsed,
    int generation,
  ) async {
    final SpaceSessionState? session = ref.read(spaceSessionProvider);
    if (session == null) {
      return null;
    }
    final RevisionValueObject? base = session.comparingAgainst;
    if (base == null && session.readingVersion != null) {
      return null;
    }
    final Result<DocumentDiffValueObject, AppFailure> diffed =
        await diffDocument.diff(
          space: session.space,
          after: parsed,
          revision: base?.spec ?? DiffDocumentUseCase.head,
        );
    if (!ref.mounted || generation != _generation) {
      return null;
    }
    return switch (diffed) {
      Success<DocumentDiffValueObject, AppFailure>(
        value: final DocumentDiffValueObject diff,
      ) =>
        diff,
      Failure<DocumentDiffValueObject, AppFailure>() => null,
    };
  }
}
