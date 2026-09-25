/// Drives the changes panel: read git, stage, commit, read git again.
library;

import 'dart:async';

// `select` lives in the runtime package, not in `riverpod_annotation`.
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/src/changes/changes_providers.dart';
import 'package:tom_presentation/src/changes/changes_state.dart';
import 'package:tom_presentation/src/spaces/space_session.dart';
import 'package:tom_presentation/src/spaces/space_session_notifier.dart';

part 'changes_notifier.g.dart';

/// Stages, unstages and commits, and writes what git says into the session.
///
/// It re-reads rather than patches: nothing can predict what git will say
/// after an operation (a deleted file staged, an editor saving underneath,
/// a rebase in another terminal), so every one ends in `status()` again.
@riverpod
class ChangesNotifier extends _$ChangesNotifier {
  /// Reads where the repository stands.
  ReadGitStatusUseCase get readGitStatus => ref.read(readGitStatusProvider);

  /// Moves whole files in and out of the index.
  StageChangesUseCase get stageChanges => ref.read(stageChangesProvider);

  /// Records the index as a commit.
  CommitChangesUseCase get commitChanges => ref.read(commitChangesProvider);

  @override
  ChangesState build() {
    final SpaceEntity? space = ref.watch(
      spaceSessionProvider.select(
        (SpaceSessionState? session) => session?.space,
      ),
    );
    if (space == null) {
      return const ChangesState.initial();
    }
    // Scheduled, not awaited: `build` answers synchronously.
    unawaited(Future<void>.microtask(() => _reload(space)));
    return const ChangesState.loading();
  }

  /// Asks git where it stands again, from outside this panel.
  ///
  /// The one reader of git in the app: fetch, pull and push all end here
  /// rather than each re-reading for itself, so what the session holds has
  /// one way to go stale and one way to mend.
  Future<void> refresh() async {
    final SpaceEntity? space = ref.read(spaceSessionProvider)?.space;
    if (space != null) {
      await _reload(space, keepDraft: true);
    }
  }

  /// Types [message] into the commit box.
  void describe(String message) {
    if (state case final ChangesReady ready) {
      state = ready.copyWith(message: message, failure: null);
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
    (SpaceEntity space) => staged
        ? stageChanges.stage(space, <RepoRelativePathValueObject>[path])
        : stageChanges.unstage(space, <RepoRelativePathValueObject>[path]),
  );

  /// Stages everything git reports, or unstages all of it
  /// (`docs/product/git-workflow/commit/doc.md`).
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
      final String message = ready.message.trim();
      if (message.isEmpty) {
        return;
      }
      await _run((SpaceEntity space) => commitChanges.commit(space, message));
      if (state case final ChangesReady now when now.failure == null) {
        state = now.copyWith(message: '');
      }
    }
  }

  /// Runs [operation] against the open space, then re-reads git.
  Future<void> _run(
    Future<Result<void, AppFailure>> Function(SpaceEntity space) operation,
  ) async {
    final SpaceEntity? space = ref.read(spaceSessionProvider)?.space;
    if (space == null || state is! ChangesReady) {
      return;
    }
    final ChangesReady before = state as ChangesReady;
    if (before.isBusy) {
      return;
    }
    state = before.copyWith(isBusy: true, failure: null);
    final Result<void, AppFailure> done = await operation(space);
    // The panel can be gone by the time git answers.
    if (!ref.mounted) {
      return;
    }
    if (done case Failure<void, AppFailure>(failure: final AppFailure why)) {
      state = (state as ChangesReady).copyWith(isBusy: false, failure: why);
      return;
    }
    await _reload(space, keepDraft: true);
  }

  /// Asks git where it stands and tells the session.
  ///
  /// [keepDraft] carries the message across, because a reload after staging
  /// must not empty a box being typed into; it is read *after* the await,
  /// or a sentence typed while git ran would be thrown away.
  Future<void> _reload(SpaceEntity space, {bool keepDraft = false}) async {
    final Result<GitStatusValueObject, AppFailure> read = await readGitStatus
        .read(space);
    if (!ref.mounted) {
      return;
    }
    final String draft = keepDraft && state is ChangesReady
        ? (state as ChangesReady).message
        : '';
    switch (read) {
      case Success<GitStatusValueObject, AppFailure>(
        value: final GitStatusValueObject status,
      ):
        ref.read(spaceSessionProvider.notifier).observe(status);
        state = ChangesState.ready(message: draft);
      case Failure<GitStatusValueObject, AppFailure>(
        failure: final AppFailure failure,
      ):
        ref.read(spaceSessionProvider.notifier).observe(null);
        state = ChangesState.failed(failure);
    }
  }
}
