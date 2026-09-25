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
/// (`docs/product/git-workflow/push-pull/doc.md`).
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
    // A pull writes to the working tree, and TOM knows it did, so the tree
    // is walked again rather than left describing a folder that is gone.
    if (action == RemoteActionEnum.pull) {
      await ref.read(fileTreeProvider.notifier).refresh();
    }
  }
}
