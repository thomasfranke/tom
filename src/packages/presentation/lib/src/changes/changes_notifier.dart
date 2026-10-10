/// Drives the changes panel: stage, commit, have git read again.
library;

// `select` lives in the runtime package, not in `riverpod_annotation`.
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/src/changes/changes_providers.dart';
import 'package:tom_presentation/src/changes/changes_state.dart';
import 'package:tom_presentation/src/commands/command_action_enum.dart';
import 'package:tom_presentation/src/commands/command_scope.dart';
import 'package:tom_presentation/src/editor/editor_notifier.dart';
import 'package:tom_presentation/src/editor/held_buffers_notifier.dart';
import 'package:tom_presentation/src/file_tree/file_tree_notifier.dart';
import 'package:tom_presentation/src/file_tree/file_tree_providers.dart';
import 'package:tom_presentation/src/spaces/document_mode_enum.dart';
import 'package:tom_presentation/src/spaces/document_tab.dart';
import 'package:tom_presentation/src/spaces/git_reading_notifier.dart';
import 'package:tom_presentation/src/spaces/git_reading_state.dart';
import 'package:tom_presentation/src/spaces/space_session.dart';
import 'package:tom_presentation/src/spaces/space_session_notifier.dart';

part 'changes_notifier.g.dart';

/// Stages, unstages and commits, and holds the git column's draft on top of
/// what [GitReadingNotifier] reads.
///
/// It re-reads rather than patches: nothing can predict what git will say
/// after an operation (a deleted file staged, an editor saving underneath,
/// a rebase in another terminal), so every one ends in a reading again.
///
/// **Kept alive for the commit message being written**, which outlives the
/// column being put away; `build` still watches the open space, so leaving
/// one clears the draft — the case where dropping it is right.
@Riverpod(keepAlive: true)
class ChangesNotifier extends _$ChangesNotifier {
  /// Moves whole files in and out of the index.
  StageChangesUseCase get stageChanges => ref.read(stageChangesProvider);

  /// Records the index as a commit.
  CommitChangesUseCase get commitChanges => ref.read(commitChangesProvider);

  /// Puts every tracked file back as the last commit has it.
  DiscardAllChangesUseCase get discardAllChanges =>
      ref.read(discardAllChangesProvider);

  /// Puts one file of the list back.
  DiscardChangeUseCase get discardChange => ref.read(discardChangeProvider);

  /// Opens a terminal where git runs.
  OpenTerminalUseCase get openTerminalUseCase => ref.read(openTerminalProvider);

  @override
  ChangesState build() {
    final SpaceEntity? space = ref.watch(
      spaceSessionProvider.select(
        (SpaceSessionState? session) => session?.space,
      ),
    );
    if (space == null || !space.hasRepository) {
      return const ChangesState.initial();
    }
    // Listened to, not watched: a rebuild would throw the draft away.
    final ProviderSubscription<GitReadingState> reading = ref.listen(
      gitReadingProvider,
      (GitReadingState? _, GitReadingState next) => state = _after(next, state),
    );
    return _after(reading.read(), null);
  }

  /// Types [message] into the commit box.
  void describe(String message) {
    if (state case final ChangesReady ready) {
      state = ready.copyWith(message: message, failure: null);
    }
  }

  /// Types [description] under the summary.
  void describeBody(String description) {
    if (state case final ChangesReady ready) {
      state = ready.copyWith(description: description, failure: null);
    }
  }

  /// Puts [path] in the index, or takes it back out.
  ///
  /// One call for both directions, because a row's checkbox is one control:
  /// [staged] is what it should become, not what it was.
  Future<void> setStaged(
    RepoRelativePathValueObject path,
    // ignore: avoid_positional_boolean_parameters — it is the second half of
    // "stage this path", not a flag on an operation that has another meaning.
    bool staged,
  ) => _run(
    staged ? CommandActionEnum.stage : CommandActionEnum.unstage,
    (SpaceEntity space) => staged
        ? stageChanges.stage(space, <RepoRelativePathValueObject>[path])
        : stageChanges.unstage(space, <RepoRelativePathValueObject>[path]),
  );

  /// Stages everything git reports, or unstages all of it
  /// (`docs/product/git-workflow/commit/the-changes-list/doc.md`).
  ///
  /// Built from the status rather than `git add -A`, so what it acts on is
  /// exactly the list that was on screen.
  Future<void> setAllStaged({required bool staged}) {
    final GitStatusValueObject? status = ref.read(spaceSessionProvider)?.git;
    if (status == null) {
      return Future<void>.value();
    }
    final List<RepoRelativePathValueObject> paths = status.entries
        .where((StatusEntryValueObject entry) => entry.isStaged != staged)
        .map((StatusEntryValueObject entry) => entry.path)
        .toList();
    return _run(
      staged ? CommandActionEnum.stage : CommandActionEnum.unstage,
      (SpaceEntity space) => staged
          ? stageChanges.stage(space, paths)
          : stageChanges.unstage(space, paths),
    );
  }

  /// Records what is staged, and clears the box it was described in.
  ///
  /// The message survives a commit that failed: it is the only copy of a
  /// sentence somebody wrote.
  Future<void> commit() async {
    if (state case final ChangesReady ready) {
      final String summary = ready.message.trim();
      if (summary.isEmpty) {
        return;
      }
      final String body = ready.description.trim();
      final String message = body.isEmpty ? summary : '$summary\n\n$body';
      final _Outcome outcome = await _run(
        CommandActionEnum.commit,
        (SpaceEntity space) => commitChanges.commit(space, message),
        isCommit: true,
      );
      // Only a commit that was made empties the box: one that failed, or
      // that somebody refused, leaves the sentence where it was written.
      if (state case final ChangesReady now when outcome == _Outcome.landed) {
        state = now.copyWith(message: '', description: '');
      }
    }
  }

  /// The menu's `Discard all changes`, once its confirmation was answered:
  /// every tracked file back to the last commit, then the tree walked and
  /// the open document read off the disk again
  /// (`docs/product/git-workflow/git-menu/doc.md`).
  Future<void> discardAll() async {
    // Read before the first await: after it, this notifier may be gone.
    final FileTreeNotifier tree = ref.read(fileTreeProvider.notifier);
    final EditorNotifier editor = ref.read(editorProvider.notifier);
    final _Outcome outcome = await _run(
      CommandActionEnum.discardAll,
      discardAllChanges.discard,
    );
    // Refused, the working tree is as it was: reading the open document
    // again would only throw its unsaved edits away.
    if (!ref.mounted || outcome == _Outcome.denied) {
      return;
    }
    await tree.refresh();
    await editor.reload();
  }

  /// Whether [entry]'s row offers its ↶: every row but a conflicted one.
  bool canDiscard(StatusEntryValueObject entry) =>
      DiscardKindEnum.of(entry) != null;

  /// The row's ↶, once its confirmation was answered: [entry] put back the
  /// way [DiscardKindEnum.of] says (`the-changes-list/doc.md`).
  ///
  /// A file that goes off the disk loses its tab; one that comes back as it
  /// was is read again, and an unsaved buffer over it is dropped too —
  /// discarding was asking for the file as git has it.
  Future<void> discard(StatusEntryValueObject entry) async {
    // Read before the first await: after it, this notifier may be gone.
    final FileTreeNotifier tree = ref.read(fileTreeProvider.notifier);
    final EditorNotifier editor = ref.read(editorProvider.notifier);
    final SpaceSessionNotifier session = ref.read(
      spaceSessionProvider.notifier,
    );
    final HeldBuffersNotifier held = ref.read(heldBuffersProvider.notifier);
    final SpaceEntity? space = ref.read(spaceSessionProvider)?.space;
    final DiscardKindEnum? kind = DiscardKindEnum.of(entry);
    // What `_run` would turn away, turned away here, or the tab would close
    // over a file git was never asked about.
    if (space == null ||
        kind == null ||
        state is! ChangesReady ||
        (state as ChangesReady).isBusy) {
      return;
    }
    final _Outcome outcome = await _run(
      CommandActionEnum.discard,
      (SpaceEntity space) => discardChange.discard(space, entry),
    );
    // Failed or refused, the file is as it was: its tab and its buffer stay.
    if (!ref.mounted || outcome != _Outcome.landed) {
      return;
    }
    final bool gone =
        kind == DiscardKindEnum.delete || entry.state == FileStateEnum.renamed;
    // Outside the space too: a changed file opened from this list has a tab.
    final DocumentTab tab = DocumentTab.of(space, entry.path);
    held.drop(tab);
    final SpaceSessionState? now = ref.read(spaceSessionProvider);
    if (gone && (now?.tabs.contains(tab) ?? false)) {
      session.closeTab(tab);
    } else if (!gone && now?.onScreen == tab) {
      await editor.reload();
    }
    await tree.refresh();
  }

  /// Whether [entry]'s row opens: every row, of any file, inside the space
  /// or not, still on disk or deleted — whenever there is a repository
  /// (`docs/product/git-workflow/commit/opening-a-change/doc.md`).
  bool canOpen(StatusEntryValueObject entry) =>
      ref.read(spaceSessionProvider)?.space.hasRepository ?? false;

  /// Opens [entry]'s file with the diff on: pressing a change is asking to
  /// see it. What a deleted or binary file holds is the editor's to find out.
  ///
  /// A deleted document opens in preview, every block removed, and the modes
  /// stay the person's to change; it is not a version being read, because
  /// there is no now to go back to.
  Future<void> open(StatusEntryValueObject entry) async {
    final SpaceEntity? space = ref.read(spaceSessionProvider)?.space;
    if (space == null || !canOpen(entry)) {
      return;
    }
    final DocumentTab tab = DocumentTab.of(space, entry.path);
    final SpaceSessionNotifier session = ref.read(spaceSessionProvider.notifier)
      ..choose(tab)
      ..decorate(showing: true);
    if (entry.state == FileStateEnum.deleted && tab.kind.isMarkdown) {
      session.look(DocumentModeEnum.preview);
    }
  }

  /// The menu's `Open in terminal`, at the repository's root.
  Future<void> openTerminalHere() async {
    final String? root = ref.read(spaceSessionProvider)?.space.repositoryRoot;
    if (root != null) {
      await openTerminalUseCase.open(root);
    }
  }

  /// The menu's `Open repository in Finder`: the repository's folder, not
  /// the space's, because the git column is the repository's.
  Future<void> revealRepository() async {
    final String? root = ref.read(spaceSessionProvider)?.space.repositoryRoot;
    if (root != null) {
      await ref.read(revealFolderProvider).reveal(root);
    }
  }

  /// Runs [operation] against the open space as [action], then re-reads
  /// git; [isCommit] says the operation is the commit.
  ///
  /// **A refusal is not a failure**: nothing is said about it, and git is
  /// read again so the window shows what is true — what ran before the
  /// refusal stays ran (`docs/product/git-workflow/approvals/doc.md`).
  Future<_Outcome> _run(
    CommandActionEnum action,
    Future<Result<void, AppFailure>> Function(SpaceEntity space) operation, {
    bool isCommit = false,
  }) async {
    final SpaceEntity? space = ref.read(spaceSessionProvider)?.space;
    if (space == null || state is! ChangesReady) {
      return _Outcome.skipped;
    }
    final ChangesReady before = state as ChangesReady;
    if (before.isBusy) {
      return _Outcome.skipped;
    }
    state = before.copyWith(
      isBusy: true,
      isCommitting: isCommit,
      failure: null,
    );
    final Result<void, AppFailure> done = await CommandScope.run(
      action,
      () => operation(space),
    );
    // The panel can be gone by the time git answers.
    if (!ref.mounted) {
      return _Outcome.skipped;
    }
    final AppFailure? why = switch (done) {
      Failure<void, AppFailure>(:final AppFailure failure) => failure,
      Success<void, AppFailure>() => null,
    };
    if (why != null && !why.isDenial) {
      state = (state as ChangesReady).copyWith(
        isBusy: false,
        isCommitting: false,
        failure: why,
      );
      return _Outcome.failed;
    }
    // The reading lands back here through the listener `build` set up.
    await ref.read(gitReadingProvider.notifier).refresh();
    return why == null ? _Outcome.landed : _Outcome.denied;
  }

  /// The panel once [reading] has answered, carrying [before]'s draft.
  ///
  /// The draft is taken from the state at the moment the answer lands, not
  /// when it was asked for, or a sentence typed while git ran would be
  /// thrown away; a reading still out leaves the panel as it is.
  ChangesState _after(GitReadingState reading, ChangesState? before) {
    final ChangesReady? kept = before is ChangesReady ? before : null;
    return switch (reading) {
      GitReadingInitial() ||
      GitReadingLoading() => before ?? const ChangesState.loading(),
      GitReadingFailed(:final AppFailure failure) => ChangesState.failed(
        failure,
      ),
      // The draft git wrote only fills an empty box: a sentence somebody is
      // typing is theirs, and a merge arriving must not replace it. A
      // reading somebody refused is answered the same way: the column is no
      // longer busy, over what the session still holds.
      GitReadingReady() || GitReadingStale() => ChangesState.ready(
        message: (kept?.message ?? '').isEmpty ? _mergeDraft() : kept!.message,
        description: kept?.description ?? '',
      ),
    };
  }

  /// The message git drafted for a merge in progress, or nothing.
  String _mergeDraft() {
    final MergeStateValueObject? merge = ref.read(spaceSessionProvider)?.merge;
    return (merge?.inProgress ?? false) ? merge!.message : '';
  }
}

/// How an operation of the column ended.
enum _Outcome {
  /// It ran, and git was read again.
  landed,

  /// Git refused it; the column says why.
  failed,

  /// The person refused it; nothing is said.
  denied,

  /// It never started: no space, or another operation in flight.
  skipped,
}
