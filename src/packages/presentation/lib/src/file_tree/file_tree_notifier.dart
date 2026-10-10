/// The file tree's state, and the two things a row can be asked to do.
library;

import 'dart:async';

// `select` lives in the runtime package, not in `riverpod_annotation`.
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/src/file_tree/file_tree_providers.dart';
import 'package:tom_presentation/src/file_tree/file_tree_state.dart';
import 'package:tom_presentation/src/spaces/document_mode_enum.dart';
import 'package:tom_presentation/src/spaces/git_reading_notifier.dart';
import 'package:tom_presentation/src/spaces/space_session.dart';
import 'package:tom_presentation/src/spaces/space_session_notifier.dart';

part 'file_tree_notifier.g.dart';

/// Drives the explorer: list the space, open and close its folders, say
/// which document the window should show. No business logic — a use case is
/// called and its [Result] becomes state.
///
/// Which folders are closed lives here because no other panel cares; which
/// document is open goes to the session, because every panel does.
@riverpod
class FileTreeNotifier extends _$FileTreeNotifier {
  /// Reads what the space holds.
  ListSpaceEntriesUseCase get listSpaceEntries =>
      ref.read(listSpaceEntriesProvider);

  /// Creates a document where the `+` was pressed.
  CreateDocumentUseCase get createDocumentUseCase =>
      ref.read(createDocumentProvider);

  /// Creates a folder where `New folder` asked.
  CreateFolderUseCase get createFolderUseCase => ref.read(createFolderProvider);

  /// Shows a folder in the file manager.
  RevealFolderUseCase get revealFolderUseCase => ref.read(revealFolderProvider);

  @override
  FileTreeState build() {
    // The space only, not the session: watching it whole would re-read the
    // folder on every click of a document.
    final SpaceEntity? space = ref.watch(
      spaceSessionProvider.select(
        (SpaceSessionState? session) => session?.space,
      ),
    );
    if (space == null) {
      return const FileTreeState.initial();
    }
    // Scheduled, not awaited: `build` answers synchronously.
    unawaited(Future<void>.microtask(() => _load(space)));
    return const FileTreeState.loading();
  }

  /// Walks the space again, for when TOM itself wrote to the disk.
  ///
  /// Changes made outside the app are the watcher's to notice ([Decision
  /// 10](../../../../../../docs/technical/decisions/010-watcher-and-git-cooperate-by-protocol.md)),
  /// not this method's.
  Future<void> refresh() async {
    final SpaceEntity? space = ref.read(spaceSessionProvider)?.space;
    if (space != null) {
      await _load(space);
    }
  }

  /// Opens or closes [entry] — whichever clicking its row means.
  ///
  /// A folder toggles, a markdown file becomes the open document, anything
  /// else does nothing
  /// (`docs/product/navigation/file-tree/what-is-shown/doc.md`).
  void activate(SpaceEntryValueObject entry) {
    if (entry.type == SpaceEntryTypeEnum.directory) {
      _toggle(entry.path);
      return;
    }
    if (entry.isDocument) {
      ref.read(spaceSessionProvider.notifier).show(entry.path);
    }
  }

  /// Asks for a new document's name, in the open document's folder — or at
  /// the space's root with nothing open — opening that folder if it was
  /// closed, so the row being typed in is on screen.
  void startNewDocument() => _startDraft(isFolder: false);

  /// Asks for a new folder's name, where a new document would go
  /// (`docs/product/navigation/file-tree/explorer-menu/doc.md`).
  void startNewFolder() => _startDraft(isFolder: true);

  /// Takes the row away and creates nothing — Escape, or a click elsewhere.
  void cancelDraft() {
    if (state case final FileTreeReady ready) {
      state = ready.copyWith(draft: null);
    }
  }

  /// Creates [typed] where the draft is; a refusal stays on the row, in
  /// place.
  ///
  /// A document is opened in source mode and git is asked again for its
  /// `N`; a folder is only re-read, since git does not see an empty one.
  Future<void> submitDraft(String typed) async {
    final SpaceEntity? space = ref.read(spaceSessionProvider)?.space;
    final FileTreeState now = state;
    if (space == null || now is! FileTreeReady || now.draft == null) {
      return;
    }
    final NewEntryDraft draft = now.draft!;
    // Read before the first await: after it, this notifier may be gone.
    final GitReadingNotifier git = ref.read(gitReadingProvider.notifier);
    final SpaceSessionNotifier session = ref.read(
      spaceSessionProvider.notifier,
    );
    final Result<SpaceRelativePathValueObject, AppFailure> created =
        draft.isFolder
        ? await createFolderUseCase.create(space, draft.folder, typed)
        : await createDocumentUseCase.create(space, draft.folder, typed);
    if (!ref.mounted) {
      return;
    }
    switch (created) {
      case Success<SpaceRelativePathValueObject, AppFailure>(
        value: final SpaceRelativePathValueObject path,
      ):
        if (draft.isFolder) {
          await _load(space);
          return;
        }
        await _openCreated(space, path, session, git);
      case Failure<SpaceRelativePathValueObject, AppFailure>(
        failure: final AppFailure why,
      ):
        if (state case final FileTreeReady ready) {
          state = ready.copyWith(draft: draft.copyWith(refused: why));
        }
    }
  }

  /// Creates [typed] in [folder] — the root when null — with no row typed
  /// in, as a missing wikilink's `Create it` asks; answers whether it was.
  ///
  /// What happens next is the `+`'s: opened in source, the tree re-read and
  /// git asked again (`docs/product/wikilinks/doc.md`).
  Future<bool> createDocument(
    SpaceRelativePathValueObject? folder,
    String typed,
  ) async {
    final SpaceEntity? space = ref.read(spaceSessionProvider)?.space;
    if (space == null) {
      return false;
    }
    // Read before the first await: after it, this notifier may be gone.
    final GitReadingNotifier git = ref.read(gitReadingProvider.notifier);
    final SpaceSessionNotifier session = ref.read(
      spaceSessionProvider.notifier,
    );
    final Result<SpaceRelativePathValueObject, AppFailure> created =
        await createDocumentUseCase.create(space, folder, typed);
    if (!ref.mounted) {
      return false;
    }
    switch (created) {
      case Success<SpaceRelativePathValueObject, AppFailure>(
        value: final SpaceRelativePathValueObject path,
      ):
        await _openCreated(space, path, session, git);
        return true;
      case Failure<SpaceRelativePathValueObject, AppFailure>():
        return false;
    }
  }

  /// Opens the document just created at [path] in source, and reads the
  /// folder and git again so it carries its `N` at once.
  Future<void> _openCreated(
    SpaceEntity space,
    SpaceRelativePathValueObject path,
    SpaceSessionNotifier session,
    GitReadingNotifier git,
  ) async {
    session
      ..show(path)
      ..look(DocumentModeEnum.source);
    await Future.wait(<Future<void>>[_load(space), git.refresh()]);
  }

  /// The menu's `Reload`: the folder read again, and git with it, so a file
  /// that arrived from outside carries its mark like any other.
  Future<void> reload() async {
    final GitReadingNotifier git = ref.read(gitReadingProvider.notifier);
    await Future.wait(<Future<void>>[refresh(), git.refresh()]);
  }

  /// Closes every folder but the ones the open document is in, because a
  /// tree that hides what is on screen has lost its reader.
  void collapseAll() {
    if (state case final FileTreeReady ready) {
      final SpaceRelativePathValueObject? folder = _folderOf(
        ref.read(spaceSessionProvider)?.openDocument,
      );
      state = ready.copyWith(
        collapsed: Set<SpaceRelativePathValueObject>.unmodifiable(
          <SpaceRelativePathValueObject>{
            for (final SpaceEntryValueObject entry in ready.entries)
              if (entry.type == SpaceEntryTypeEnum.directory &&
                  (folder == null || !_contains(entry.path, folder)))
                entry.path,
          },
        ),
      );
    }
  }

  /// Shows the space's folder — not the repository's — in the platform's
  /// file manager.
  Future<void> revealSpace() async {
    final SpaceEntity? space = ref.read(spaceSessionProvider)?.space;
    if (space != null) {
      await revealFolderUseCase.reveal(space.root);
    }
  }

  void _startDraft({required bool isFolder}) {
    if (state case final FileTreeReady ready) {
      final SpaceRelativePathValueObject? folder = _folderOf(
        ref.read(spaceSessionProvider)?.openDocument,
      );
      state = ready.copyWith(
        collapsed: Set<SpaceRelativePathValueObject>.unmodifiable(
          ready.collapsed.where(
            (SpaceRelativePathValueObject closed) =>
                folder == null || !_contains(closed, folder),
          ),
        ),
        draft: NewEntryDraft(folder: folder, isFolder: isFolder),
      );
    }
  }

  /// The folder [document] is in; null at the root or with nothing open.
  static SpaceRelativePathValueObject? _folderOf(
    SpaceRelativePathValueObject? document,
  ) {
    final String? path = document?.value;
    if (path == null || !path.contains('/')) {
      return null;
    }
    return SpaceRelativePathValueObject(
      path.substring(0, path.lastIndexOf('/')),
    );
  }

  /// Whether [folder] is [ancestor] or somewhere inside it.
  static bool _contains(
    SpaceRelativePathValueObject ancestor,
    SpaceRelativePathValueObject folder,
  ) => folder == ancestor || folder.value.startsWith('${ancestor.value}/');

  /// Reads [space] and shows what it holds.
  Future<void> _load(SpaceEntity space) async {
    final Result<List<SpaceEntryValueObject>, AppFailure> listed =
        await listSpaceEntries.list(space);
    // The panel can be gone by the time the walk answers.
    if (!ref.mounted) {
      return;
    }
    // A re-read keeps the folders the reader closed; a first read has none.
    final Set<SpaceRelativePathValueObject> collapsed = switch (state) {
      FileTreeReady(:final Set<SpaceRelativePathValueObject> collapsed) =>
        collapsed,
      _ => const <SpaceRelativePathValueObject>{},
    };
    state = switch (listed) {
      Success<List<SpaceEntryValueObject>, AppFailure>(
        value: final List<SpaceEntryValueObject> entries,
      ) =>
        FileTreeState.ready(
          entries: List<SpaceEntryValueObject>.unmodifiable(entries),
          collapsed: collapsed,
        ),
      Failure<List<SpaceEntryValueObject>, AppFailure>(
        failure: final AppFailure failure,
      ) =>
        FileTreeState.failed(failure),
    };
  }

  /// Closes [folder] if it is open, opens it if it is closed; nothing before
  /// the space has been read.
  void _toggle(SpaceRelativePathValueObject folder) {
    if (state case final FileTreeReady ready) {
      final Set<SpaceRelativePathValueObject> next = ready.collapsed.toSet();
      if (!next.remove(folder)) {
        next.add(folder);
      }
      state = ready.copyWith(
        collapsed: Set<SpaceRelativePathValueObject>.unmodifiable(next),
      );
    }
  }
}
