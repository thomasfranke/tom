/// Drives fetch, pull and push — one explicit action at a time.
library;

// `select` lives in the runtime package, not in `riverpod_annotation`.
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/src/commands/command_action_enum.dart';
import 'package:tom_presentation/src/commands/command_scope.dart';
import 'package:tom_presentation/src/commands/commands_notifier.dart';
import 'package:tom_presentation/src/commands/commands_state.dart';
import 'package:tom_presentation/src/file_tree/file_tree_notifier.dart';
import 'package:tom_presentation/src/pull_request/pull_request_notifier.dart';
import 'package:tom_presentation/src/pull_request/pull_request_state.dart';
import 'package:tom_presentation/src/remote/link_state_enum.dart';
import 'package:tom_presentation/src/remote/remote_action_enum.dart';
import 'package:tom_presentation/src/remote/remote_providers.dart';
import 'package:tom_presentation/src/remote/remote_state.dart';
import 'package:tom_presentation/src/spaces/git_reading_notifier.dart';
import 'package:tom_presentation/src/spaces/space_session.dart';
import 'package:tom_presentation/src/spaces/space_session_notifier.dart';

part 'remote_notifier.g.dart';

/// Fetch, pull and push, each started by somebody and never on its own
/// (`docs/product/git-workflow/push-pull/README.md`).
///
/// It reads no git of its own: every action ends in [GitReadingNotifier]
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

  /// Forgets what the last request said, so a link that was down is offered
  /// again — the git menu's `Reload`. Without it, a column that went
  /// unavailable for *no network* would stay so until the space reopened.
  void recheck() {
    if (!state.isBusy) {
      state = const RemoteState.idle();
    }
  }

  /// Asks the remote what it has, changing no file on disk.
  Future<void> fetch() => _run(
    RemoteActionEnum.fetch,
    (SpaceEntity space) => fetchRemote.fetch(space),
  );

  /// Brings the remote's commits into this branch, keeping how many arrived.
  Future<void> pull() => _run(
    RemoteActionEnum.pull,
    (SpaceEntity space) => pullRemote.pull(space),
    succeeded: (int? arrived) => RemoteState.idle(arrived: arrived),
  );

  /// Publishes this branch's commits, keeping how many went.
  Future<void> push() {
    // Counted before the push, because the reading after it says 0.
    final int toPublish = ref.read(spaceSessionProvider)?.git?.ahead ?? 0;
    return _run(
      RemoteActionEnum.push,
      (SpaceEntity space) => pushRemote.push(space),
      succeeded: (void _) => RemoteState.idle(published: toPublish),
    );
  }

  /// Keeps [summary], the message of the commit just recorded, as the news
  /// the band quotes until the next thing happens.
  void commitLanded(String summary) {
    if (!state.isBusy) {
      state = RemoteState.idle(committed: summary);
    }
  }

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
    final Result<void, AppFailure> done = await CommandScope.run(
      CommandActionEnum.abortPull,
      () => abortPull.abort(space),
    );
    if (!ref.mounted) {
      return;
    }
    // An abort git refused is said the way a refused action is: the band
    // above the document, with what git answered. One the person refused is
    // said nowhere.
    if (done case Failure<void, AppFailure>(
      failure: final AppFailure it,
    ) when !it.isDenial) {
      state = RemoteState.failed(action: RemoteActionEnum.pull, failure: it);
    }
    await ref.read(gitReadingProvider.notifier).refresh();
    if (!ref.mounted) {
      return;
    }
    await ref.read(fileTreeProvider.notifier).refresh();
  }

  /// Runs [operation] as [action], then has git read again.
  ///
  /// [succeeded] turns what a success answered into the state to keep;
  /// without it, a success is a plain [RemoteIdle].
  Future<void> _run<T>(
    RemoteActionEnum action,
    Future<Result<T, AppFailure>> Function(SpaceEntity space) operation, {
    RemoteState Function(T value)? succeeded,
  }) async {
    final SpaceEntity? space = ref.read(spaceSessionProvider)?.space;
    if (space == null || state.isBusy) {
      return;
    }
    state = RemoteState.working(action);
    final Result<T, AppFailure> done = await CommandScope.run(
      action.command,
      () => operation(space),
    );
    // The window can be gone by the time git answers.
    if (!ref.mounted) {
      return;
    }
    state = switch (done) {
      Success<T, AppFailure>(:final T value) =>
        succeeded?.call(value) ?? const RemoteState.idle(),
      // The remote moving first is a situation, not a fault — the one with
      // a screen of its own.
      Failure<T, AppFailure>(failure: GitPushRejected()) =>
        const RemoteState.rejected(),
      // Somebody said no: nothing went wrong, so no band says anything.
      Failure<T, AppFailure>(failure: AppFailure(isDenial: true)) =>
        const RemoteState.idle(),
      Failure<T, AppFailure>(failure: final AppFailure failure) =>
        RemoteState.failed(action: action, failure: failure),
    };
    // Even after a rejected push: `git push` can update some refs and
    // refuse others.
    await ref.read(gitReadingProvider.notifier).refresh();
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

/// Whether the remote action in flight is still waiting for somebody to say
/// yes: the control that was pressed says so, and the progress bar stays
/// down — nothing is on the network yet
/// (`docs/product/git-workflow/approvals/doc.md`).
@riverpod
bool remoteAwaitingApproval(Ref ref) => switch (ref.watch(remoteProvider)) {
  RemoteWorking(:final RemoteActionEnum action) => ref.watch(
    commandsProvider.select(
      (CommandsState it) => it.isWaitingOn(action.command),
    ),
  ),
  _ => false,
};

/// What the link is, when it is anything: what the last request said, else
/// that the repository has no remote — read from the pull request's target
/// when the space opened, so nobody has to fail a fetch to learn it
/// (`docs/product/git-workflow/push-pull/when-the-link-is-broken/doc.md`).
@riverpod
LinkStateEnum? remoteLink(Ref ref) {
  final LinkStateEnum? said = ref.watch(
    remoteProvider.select((RemoteState state) => state.link),
  );
  if (said != null) {
    return said;
  }
  final bool hasNone = ref.watch(
    pullRequestProvider.select(
      (PullRequestState state) => state.target?.hasRemote == false,
    ),
  );
  return hasNone ? LinkStateEnum.noRemote : null;
}
