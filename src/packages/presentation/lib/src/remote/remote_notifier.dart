/// Drives fetch, pull and push — one explicit action at a time.
library;

// `select` lives in the runtime package, not in `riverpod_annotation`.
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/src/changes/changes_notifier.dart';
import 'package:tom_presentation/src/file_tree/file_tree_notifier.dart';
import 'package:tom_presentation/src/remote/remote_action_enum.dart';
import 'package:tom_presentation/src/remote/remote_providers.dart';
import 'package:tom_presentation/src/remote/remote_state.dart';
import 'package:tom_presentation/src/spaces/space_session.dart';
import 'package:tom_presentation/src/spaces/space_session_notifier.dart';

part 'remote_notifier.g.dart';

/// Fetch, pull and push, each started by somebody and never on its own
/// (`docs/product/git-workflow/push-pull/README.md`).
///
/// It reads no git of its own: every action ends in [ChangesNotifier]
/// re-reading, so what the window believes about the repository has one
/// source.
@riverpod
class RemoteNotifier extends _$RemoteNotifier {
  /// Updates the remote-tracking branches.
  FetchRemoteUseCase get fetchRemote => ref.read(fetchRemoteProvider);

  /// Brings the remote's commits in.
  PullRemoteUseCase get pullRemote => ref.read(pullRemoteProvider);

  /// Publishes this branch.
  PushRemoteUseCase get pushRemote => ref.read(pushRemoteProvider);

  /// Undoes the merge a conflicted pull left behind.
  AbortPullUseCase get abortPull => ref.read(abortPullProvider);

  @override
  RemoteState build() {
    // The space only: a rejection from the last folder is about a repository
    // nobody is looking at any more.
    ref.watch(
      spaceSessionProvider.select(
        (SpaceSessionState? session) => session?.space,
      ),
    );
    return const RemoteState.idle();
  }

  /// Asks the remote what it has, changing no file on disk.
  Future<void> fetch() => _run(
    RemoteActionEnum.fetch,
    (SpaceEntity space) => fetchRemote.fetch(space),
  );

  /// Brings the remote's commits into this branch.
  Future<void> pull() => _run(
    RemoteActionEnum.pull,
    (SpaceEntity space) => pullRemote.pull(space),
  );

  /// Publishes this branch's commits.
  Future<void> push() => _run(
    RemoteActionEnum.push,
    (SpaceEntity space) => pushRemote.push(space),
  );

  /// Puts the working tree back where the conflicted pull found it.
  ///
  /// Not one of [_run]'s three: nothing is asked of the remote, so there is
  /// no `working` state to enter and no verb for a button to wear. What it
  /// shares with them is the tail — git is read again, and the tree walked,
  /// because the merge ending changes both
  /// (`docs/product/git-workflow/push-pull/when-a-pull-conflicts/doc.md`).
  Future<void> abort() async {
    final SpaceEntity? space = ref.read(spaceSessionProvider)?.space;
    if (space == null || state.isBusy) {
      return;
    }
    final Result<void, AppFailure> done = await abortPull.abort(space);
    if (!ref.mounted) {
      return;
    }
    // A refused abort is said the way a refused action is: the band above
    // the document, with what git answered.
    if (done case Failure<void, AppFailure>(failure: final AppFailure it)) {
      state = RemoteState.failed(action: RemoteActionEnum.pull, failure: it);
    }
    await ref.read(changesProvider.notifier).refresh();
    if (!ref.mounted) {
      return;
    }
    await ref.read(fileTreeProvider.notifier).refresh();
  }

  /// Runs [operation] as [action], then has git read again.
  Future<void> _run(
    RemoteActionEnum action,
    Future<Result<void, AppFailure>> Function(SpaceEntity space) operation,
  ) async {
    final SpaceEntity? space = ref.read(spaceSessionProvider)?.space;
    if (space == null || state.isBusy) {
      return;
    }
    state = RemoteState.working(action);
    final Result<void, AppFailure> done = await operation(space);
    // The window can be gone by the time git answers.
    if (!ref.mounted) {
      return;
    }
    state = switch (done) {
      Success<void, AppFailure>() => const RemoteState.idle(),
      // The remote moving first is a situation, not a fault — the one with
      // a screen of its own.
      Failure<void, AppFailure>(failure: GitPushRejected()) =>
        const RemoteState.rejected(),
      Failure<void, AppFailure>(failure: final AppFailure failure) =>
        RemoteState.failed(action: action, failure: failure),
    };
    // Even after a rejected push: `git push` can update some refs and
    // refuse others.
    await ref.read(changesProvider.notifier).refresh();
    // Checked between the two: a notifier disposed while the first was
    // running has no `Ref` left to read the second with.
    if (!ref.mounted) {
      return;
    }
    // A pull writes to the working tree, and TOM knows it did, so the tree
    // is walked again rather than left describing a folder that is gone.
    if (action == RemoteActionEnum.pull) {
      await ref.read(fileTreeProvider.notifier).refresh();
    }
  }
}
