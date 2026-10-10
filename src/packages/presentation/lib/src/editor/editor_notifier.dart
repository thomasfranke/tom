/// The editor's state: the open document, and the buffer over it.
library;

import 'dart:async';

// `select` lives in the runtime package, not in `riverpod_annotation`.
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/src/commands/command_action_enum.dart';
import 'package:tom_presentation/src/commands/command_scope.dart';
import 'package:tom_presentation/src/commands/commands_notifier.dart';
import 'package:tom_presentation/src/editor/editor_providers.dart';
import 'package:tom_presentation/src/editor/editor_state.dart';
import 'package:tom_presentation/src/editor/held_buffers_notifier.dart';
import 'package:tom_presentation/src/export/export_notifier.dart';
import 'package:tom_presentation/src/file_tree/file_tree_providers.dart';
import 'package:tom_presentation/src/preferences/preferences_notifier.dart';
import 'package:tom_presentation/src/spaces/document_tab.dart';
import 'package:tom_presentation/src/spaces/git_reading_notifier.dart';
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

  /// Reads a file that is not markdown, text or binary.
  ReadFileUseCase get readFile => ref.read(readFileProvider);

  /// Reads a deleted file as the last commit left it.
  ReadCommittedFileUseCase get readCommittedFile =>
      ref.read(readCommittedFileProvider);

  /// Writes the buffer back.
  SaveDocumentUseCase get saveDocument => ref.read(saveDocumentProvider);

  /// Reads a pull request draft, seeding it the first time.
  OpenPullRequestDraftUseCase get openDraft =>
      ref.read(openPullRequestDraftProvider);

  /// Writes a pull request draft back.
  SaveDocumentUseCase get saveDraft => ref.read(saveDraftProvider);

  /// Reads the preferences file.
  ReadDocumentUseCase get readPreferences =>
      ref.read(readPreferencesFileProvider);

  /// Writes the preferences file back.
  SaveDocumentUseCase get savePreferences =>
      ref.read(savePreferencesFileProvider);

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
    // A changed file outside the space has the buffer in the document's place.
    final RepoRelativePathValueObject? outside = ref.watch(
      spaceSessionProvider.select(
        (SpaceSessionState? session) => session?.outsideDocument,
      ),
    );
    // The pull request page takes the buffer while it is up, and gives the
    // tab's back when it goes (Decision 33).
    final BranchNameValueObject? draft = ref.watch(
      spaceSessionProvider.select(
        (SpaceSessionState? session) => session?.pullRequest,
      ),
    );
    // The preferences file has the buffer while its tab is the one on screen.
    final SpaceRelativePathValueObject? preferences = ref.watch(
      spaceSessionProvider.select(
        (SpaceSessionState? session) =>
            (session?.isShowingPreferencesFile ?? false)
            ? session!.preferencesFile
            : null,
      ),
    );
    // The buffer being left, if it has edits and its tab is still open: it
    // waits in the held buffers rather than going (`editor/tabs/doc.md`).
    // Put there after `build`, which may not write another provider.
    final EditorState? before = stateOrNull;
    if (space != null && draft != null) {
      unawaited(
        Future<void>.microtask(() {
          _hold(before);
          return _loadDraft(space, draft);
        }),
      );
      return const EditorState.loading();
    }
    if (space != null && preferences != null) {
      unawaited(
        Future<void>.microtask(
          () => _choose(
            space,
            before,
            DocumentTab.preferences(preferences),
            () => _loadPreferences(space, preferences),
          ),
        ),
      );
      return const EditorState.loading();
    }
    if (space != null && outside != null) {
      final DocumentTab tab = DocumentTab.outside(outside);
      unawaited(
        Future<void>.microtask(
          () => _choose(space, before, tab, () => _load(space, tab)),
        ),
      );
      return const EditorState.loading();
    }
    if (space == null || path == null) {
      if (space != null) {
        unawaited(Future<void>.microtask(() => _leaveDraft(space, before)));
      }
      return const EditorState.empty();
    }
    // Scheduled, not awaited: `build` answers synchronously.
    final DocumentTab tab = DocumentTab.inSpace(path);
    unawaited(
      Future<void>.microtask(
        () => _choose(space, before, tab, () => _load(space, tab)),
      ),
    );
    return const EditorState.loading();
  }

  /// Leaves [before] for [tab]: a draft is saved, a dirty buffer is held,
  /// and [tab]'s own held buffer comes back — or [read] reads it.
  Future<void> _choose(
    SpaceEntity space,
    EditorState? before,
    DocumentTab tab,
    Future<void> Function() read,
  ) {
    unawaited(_leaveDraft(space, before));
    _hold(before, leaving: tab);
    final EditorReady? held = ref.read(heldBuffersProvider.notifier).take(tab);
    if (held != null) {
      state = held;
      return Future<void>.value();
    }
    return read();
  }

  /// Puts [before] with the held buffers when it is dirty, is not [leaving]'s
  /// own, and its tab is still open — a closed tab's edits were answered for.
  /// A draft is never held: it has no tab, and it is saved on the way out.
  void _hold(EditorState? before, {DocumentTab? leaving}) {
    if (before case final EditorReady buffer
        when buffer.isDirty && !buffer.isDraft && buffer.tab != leaving) {
      final SpaceSessionState? session = ref.read(spaceSessionProvider);
      final bool open = buffer.isPreferences
          ? session?.preferencesTab == buffer.tab
          : session?.tabs.contains(buffer.tab) ?? false;
      if (open) {
        ref.read(heldBuffersProvider.notifier).hold(buffer);
      }
    }
  }

  /// The space the draft on screen was read from, so it is written back
  /// there and nowhere else.
  SpaceEntity? _draftSpace;

  /// Writes [before] when it is a draft with edits: leaving the pull request
  /// loses nothing, and asks nothing, because the draft is a file only this
  /// branch reads (`docs/product/git-workflow/pull-request/the-control/doc.md`).
  ///
  /// Only within its own space: leaving for another one asked first, and an
  /// answer of *discard* must not be overruled into the next repository.
  Future<void> _leaveDraft(SpaceEntity space, EditorState? before) async {
    if (before case final EditorReady draft
        when draft.isDraft && draft.isDirty && _draftSpace == space) {
      await _write(space, draft, draft.saved.copyWith(content: draft.source));
    }
  }

  /// Reads [branch]'s draft into a fresh buffer, seeding it from git the
  /// first time.
  Future<void> _loadDraft(
    SpaceEntity space,
    BranchNameValueObject branch,
  ) async {
    final BranchNameValueObject? base = ref
        .read(spaceSessionProvider)
        ?.pullRequestBase;
    if (base == null) {
      state = const EditorState.empty();
      return;
    }
    final Result<DocumentEntity, AppFailure> read = await CommandScope.run(
      CommandActionEnum.readPullRequest,
      () => openDraft.open(space, branch, base),
    );
    if (!ref.mounted) {
      return;
    }
    // Refused, there is no draft to show: the page closes back onto the tab
    // that was on screen, and nothing is said.
    if (read case Failure<DocumentEntity, AppFailure>(
      failure: AppFailure(isDenial: true),
    )) {
      ref.read(spaceSessionProvider.notifier).leavePullRequest();
      return;
    }
    _draftSpace = space;
    state = switch (read) {
      Success<DocumentEntity, AppFailure>(
        value: final DocumentEntity document,
      ) =>
        EditorState.ready(
          saved: document,
          source: document.content,
          isDraft: true,
        ),
      Failure<DocumentEntity, AppFailure>(failure: final AppFailure failure) =>
        EditorState.failed(failure),
    };
  }

  /// Whether any open tab has edits the disk does not: the one on screen or
  /// one held behind it. What leaving a space and switching a branch ask.
  bool get hasUnsaved =>
      state.isDirty ||
      ref
          .read(heldBuffersProvider)
          .values
          .any((EditorState buffer) => buffer.isDirty);

  /// Saves every buffer with edits, the one on screen and the held ones.
  Future<void> saveAll() async {
    await save();
    final SpaceEntity? space = ref.read(spaceSessionProvider)?.space;
    if (space == null || !ref.mounted) {
      return;
    }
    final HeldBuffersNotifier held = ref.read(heldBuffersProvider.notifier);
    for (final EditorState each in ref.read(heldBuffersProvider).values) {
      if (each is! EditorReady || !each.isDirty) {
        continue;
      }
      final EditorReady buffer = each;
      final DocumentEntity written = buffer.saved.copyWith(
        content: buffer.source,
      );
      final Result<void, AppFailure> saved = await _write(
        space,
        buffer,
        written,
      );
      if (!ref.mounted) {
        return;
      }
      if (saved is Success<void, AppFailure>) {
        held.drop(buffer.tab!);
        _applied(buffer);
      }
    }
  }

  /// Writes [written] where [buffer] came from: the drafts' folder, the
  /// app's own, or the space.
  ///
  /// A draft's folder is asked of git, so that write is the pull request's
  /// action in the commands panel; the other two run no command at all.
  Future<Result<void, AppFailure>> _write(
    SpaceEntity space,
    EditorReady buffer,
    DocumentEntity written,
  ) => buffer.isDraft
      ? CommandScope.run(
          CommandActionEnum.readPullRequest,
          () => saveDraft.save(space, written),
        )
      : (buffer.isPreferences ? savePreferences : saveDocument).save(
          _frameOf(space, buffer),
          written,
        );

  /// The space [buffer] is written in: the repository seen as a folder for a
  /// file outside [space], [space] for everything else.
  static SpaceEntity _frameOf(SpaceEntity space, EditorReady buffer) =>
      buffer.isOutside ? space.repositorySpace ?? space : space;

  /// Reads the preferences again when [written] was their file: **saving it
  /// applies it**, as a choice in the popover does — and a value it cannot
  /// use is the default, silently
  /// (`docs/product/preferences/where-it-is-stored/doc.md`).
  ///
  /// A document of the space has git asked again instead, so its mark is
  /// in the tree at once; only when a reading exists, as the editor makes
  /// none of its own.
  void _applied(EditorReady written) {
    if (written.isPreferences) {
      unawaited(ref.read(preferencesProvider.notifier).reload());
      // The same tab holds `git-approvals.json`: what waits is judged again
      // by the list as it was just saved.
      if (ref.exists(commandsProvider)) {
        unawaited(ref.read(commandsProvider.notifier).reconsider());
      }
    } else if (!written.isDraft && ref.exists(gitReadingProvider)) {
      unawaited(ref.read(gitReadingProvider.notifier).refresh());
    }
  }

  /// Follows the preferences file after something else wrote it — a choice
  /// in the popover: a tab with no unsaved edit reads it again, and one with
  /// edits is told, and asks (`preferences/where-it-is-stored/doc.md`).
  Future<void> preferencesFileChanged() async {
    final SpaceSessionState? session = ref.read(spaceSessionProvider);
    final SpaceRelativePathValueObject? file = session?.preferencesFile;
    if (session == null || file == null) {
      return;
    }
    if (state case final EditorReady open when open.isPreferences) {
      if (open.isDirty || open.isSaving) {
        state = open.copyWith(changedOnDisk: true);
      } else {
        await _loadPreferences(session.space, file);
      }
      return;
    }
    // A clean tab not on screen is read again when it is chosen; only a
    // held one has edits to ask about.
    if (ref.read(heldBuffersProvider)[DocumentTab.preferences(file)]
        case final EditorReady held) {
      ref
          .read(heldBuffersProvider.notifier)
          .hold(held.copyWith(changedOnDisk: true));
    }
  }

  /// Keeps the buffer over a file that changed on disk; the next save
  /// writes it over what is there.
  void keepMine() {
    if (state case final EditorReady open when open.changedOnDisk) {
      state = open.copyWith(changedOnDisk: false);
    }
  }

  /// Forgets the edits of every tab that is not on screen.
  void discardHeld() => ref.read(heldBuffersProvider.notifier).clear();

  /// Turns a button press into markdown, in the source itself.
  static const MarkdownFormatterService formatter = MarkdownFormatterService();

  /// Replaces the buffer with [source]; nothing here writes to a disk.
  ///
  /// [start] and [end] are where the pane left the selection; left out, the
  /// last one is kept, which is what a write from somewhere else — a
  /// replacement, a resolved conflict — has to say about a caret it never
  /// moved. A read-only buffer takes nothing ([EditorState.isReadOnly]).
  void edit(String source, {int? start, int? end}) {
    if (state case final EditorReady ready when !ready.isReadOnly) {
      // Typing into a tab in preview is what keeps it.
      if (source != ready.source) {
        _keep(ready);
      }
      state = ready.copyWith(
        source: source,
        selectionStart: start ?? ready.selectionStart,
        selectionEnd: end ?? ready.selectionEnd,
        saveFailure: null,
      );
    }
  }

  /// Moves the selection without touching the buffer.
  void select(int start, int end) {
    if (state case final EditorReady ready) {
      if (ready.selectionStart == start && ready.selectionEnd == end) {
        return;
      }
      state = ready.copyWith(selectionStart: start, selectionEnd: end);
    }
  }

  /// Writes [command]'s markdown into the buffer, around the selection.
  ///
  /// **An edit, not a save**: the unsaved mark appears, undo walks back
  /// through it, and the file changes when somebody saves
  /// (`docs/product/editor/formatting-shortcuts/doc.md`).
  void format(FormatCommandEnum command) {
    // Markdown has no place in a file that is not markdown, nor in one that
    // takes no typing.
    if (state case final EditorReady ready
        when ready.isRendered && !ready.isReadOnly) {
      final FormattedSourceValueObject written = formatter.apply(
        ready.source,
        command,
        start: ready.selectionStart,
        end: ready.selectionEnd,
      );
      _keep(ready);
      state = ready.copyWith(
        source: written.text,
        selectionStart: written.start,
        selectionEnd: written.end,
        saveFailure: null,
      );
    }
  }

  /// Writes the buffer where the document came from.
  ///
  /// A clean document is not written: a write nobody needs would touch the
  /// file's timestamp for git to notice.
  Future<void> save() async {
    if (state case final EditorReady ready) {
      final SpaceEntity? space = ref.read(spaceSessionProvider)?.space;
      if (space == null ||
          ready.isSaving ||
          !ready.isDirty ||
          ready.isReadOnly) {
        return;
      }
      final DocumentEntity written = ready.saved.copyWith(
        content: ready.source,
      );
      _keep(ready);
      state = ready.copyWith(isSaving: true, saveFailure: null);
      final Result<void, AppFailure> saved = await _write(
        space,
        ready,
        written,
      );
      // The panel can be gone by the time the disk answers.
      if (!ref.mounted) {
        return;
      }
      _settle(written, saved);
      if (saved is Success<void, AppFailure>) {
        _applied(ready);
      }
    }
  }

  /// Reads the open document off the disk again, dropping the buffer.
  ///
  /// What a branch switch leaves behind
  /// (`docs/product/git-workflow/branch-switch/doc.md`), and how *discard*
  /// is spelled.
  Future<void> reload() async {
    final SpaceSessionState? session = ref.read(spaceSessionProvider);
    if (session?.pullRequest case final BranchNameValueObject branch) {
      await _loadDraft(session!.space, branch);
      return;
    }
    if (session case SpaceSessionState(
      isShowingPreferencesFile: true,
      preferencesFile: final SpaceRelativePathValueObject file,
    )) {
      await _loadPreferences(session.space, file);
      return;
    }
    if (session?.onScreen case final DocumentTab tab) {
      await _load(session!.space, tab);
    }
  }

  /// Keeps [ready]'s tab, out of preview; a draft has no tab to keep, and
  /// the preferences file's is never in preview.
  void _keep(EditorReady ready) {
    if (!ready.isDraft && !ready.isPreferences) {
      ref.read(spaceSessionProvider.notifier).keep(ready.tab!);
    }
  }

  /// Records what the write did, over whatever the buffer holds now.
  ///
  /// [written] is what reached the disk, not necessarily what is on screen:
  /// typing during a save leaves the document saved *and* dirty again.
  void _settle(DocumentEntity written, Result<void, AppFailure> saved) {
    if (state case final EditorReady now) {
      state = switch (saved) {
        // What is on disk is the buffer's now, so nothing is left to ask.
        Success<void, AppFailure>() => now.copyWith(
          saved: written,
          isSaving: false,
          changedOnDisk: false,
        ),
        Failure<void, AppFailure>(failure: final AppFailure failure) =>
          now.copyWith(isSaving: false, saveFailure: failure),
      };
    }
  }

  /// Reads the preferences file at [file] into a fresh buffer.
  ///
  /// [space] is the use case's argument and nothing more: the file is read
  /// from the app's own folder whatever space is open.
  Future<void> _loadPreferences(
    SpaceEntity space,
    SpaceRelativePathValueObject file,
  ) async {
    final Result<DocumentEntity, AppFailure> read = await readPreferences.read(
      space,
      file,
    );
    if (!ref.mounted) {
      return;
    }
    state = switch (read) {
      Success<DocumentEntity, AppFailure>(
        value: final DocumentEntity document,
      ) =>
        EditorState.ready(
          saved: document,
          source: document.content,
          isPreferences: true,
        ),
      Failure<DocumentEntity, AppFailure>(failure: final AppFailure failure) =>
        EditorState.failed(failure),
    };
  }

  /// Reads [tab]'s file, in [space] or in its repository, into a fresh
  /// buffer: a markdown document as one, anything else as text or binary.
  ///
  /// A file git still lists that is gone from the disk opens as `HEAD` left
  /// it, read-only (`docs/product/git-workflow/commit/opening-a-change/doc.md`).
  Future<void> _load(SpaceEntity space, DocumentTab tab) async {
    final ({SpaceEntity space, SpaceRelativePathValueObject path})? address =
        tab.addressIn(space);
    if (address == null) {
      state = const EditorState.empty();
      return;
    }
    final Result<FileContentValueObject, AppFailure> read = tab.kind.isMarkdown
        ? await readDocument
              .read(address.space, address.path)
              .map(FileContentValueObject.text)
        : await readFile.read(address.space, address.path);
    // The session can have moved on by the time the disk answers.
    if (!ref.mounted) {
      return;
    }
    if (read case Failure<FileContentValueObject, AppFailure>(
      failure: DocumentNotFound(),
    ) when _listedByGit(space, tab)) {
      final Result<FileContentValueObject, AppFailure> last =
          await CommandScope.run(
            CommandActionEnum.readVersion,
            () => readCommittedFile.read(address.space, address.path),
          );
      if (!ref.mounted) {
        return;
      }
      if (last case Success<FileContentValueObject, AppFailure>(
        value: final FileContentValueObject content,
      )) {
        state = _bufferOf(content, tab, address.path, isDeleted: true);
        return;
      }
    }
    state = switch (read) {
      Success<FileContentValueObject, AppFailure>(
        value: final FileContentValueObject content,
      ) =>
        _bufferOf(content, tab, address.path, isDeleted: false),
      Failure<FileContentValueObject, AppFailure>(
        failure: final AppFailure failure,
      ) =>
        EditorState.failed(failure),
    };
  }

  /// A fresh buffer over [content], [tab]'s file at [path].
  static EditorState _bufferOf(
    FileContentValueObject content,
    DocumentTab tab,
    SpaceRelativePathValueObject path, {
    required bool isDeleted,
  }) => switch (content) {
    FileContentText(:final DocumentEntity document) => EditorState.ready(
      saved: document,
      source: document.content,
      isOutside: tab is OutsideDocumentTab,
      isDeleted: isDeleted,
    ),
    // Nothing of a binary file is held, so there is nothing to type over it
    // and nothing a save could write back.
    FileContentBinary() => EditorState.ready(
      saved: DocumentEntity(path: path, content: ''),
      source: '',
      isOutside: tab is OutsideDocumentTab,
      isDeleted: isDeleted,
      isBinary: true,
    ),
  };

  /// Whether git's last reading lists [tab]'s file — the only files whose
  /// absence from the disk is a deletion with a version to show.
  bool _listedByGit(SpaceEntity space, DocumentTab tab) {
    final RepoRelativePathValueObject? path = switch (tab) {
      SpaceDocumentTab(:final SpaceRelativePathValueObject path) =>
        space.hasRepository ? space.toRepoRelative(path) : null,
      OutsideDocumentTab(:final RepoRelativePathValueObject path) => path,
      PreferencesDocumentTab() => null,
    };
    return path != null &&
        (ref
                .read(spaceSessionProvider)
                ?.git
                ?.entries
                .any((StatusEntryValueObject entry) => entry.path == path) ??
            false);
  }

  /// Shows the folder holding the file on screen in the platform's file
  /// manager — the binary tab's `Reveal in Finder`.
  Future<void> reveal() async {
    final SpaceEntity? space = ref.read(spaceSessionProvider)?.space;
    if (state case final EditorReady open
        when space != null && !open.isDraft && !open.isPreferences) {
      final String file = _frameOf(space, open).absolutePathOf(open.saved.path);
      await ref
          .read(revealFolderProvider)
          .reveal(ExportNotifier.folderOf(file));
    }
  }
}
