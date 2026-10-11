/// The open space's one reader of git.
library;

import 'dart:async';

// `select` lives in the runtime package, not in `riverpod_annotation`.
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/src/changes/changes_providers.dart';
import 'package:tom_presentation/src/commands/command_action_enum.dart';
import 'package:tom_presentation/src/commands/command_scope.dart';
import 'package:tom_presentation/src/commands/opening_plan_notifier.dart';
import 'package:tom_presentation/src/home/home_providers.dart';
import 'package:tom_presentation/src/spaces/git_reading_state.dart';
import 'package:tom_presentation/src/spaces/space_session.dart';
import 'package:tom_presentation/src/spaces/space_session_notifier.dart';

part 'git_reading_notifier.g.dart';

/// Reads where the repository stands and writes it into
/// [SpaceSessionState.git] and [SpaceSessionState.merge], for everyone who
/// draws from it.
///
/// **Kept alive, and made to exist by the shell**, never by the git column:
/// the column is built only while it is showing, and a reading that lived
/// there left a space opened with it shut with no git at all. Everything
/// that writes to the repository ends in [refresh], so what the window
/// believes has one source and one way to mend.
@Riverpod(keepAlive: true)
class GitReadingNotifier extends _$GitReadingNotifier {
  /// Reads where the repository stands.
  ReadGitStatusUseCase get readGitStatus => ref.read(readGitStatusProvider);

  /// Reads whether a pull stopped mid-merge.
  ReadMergeStateUseCase get readMergeState => ref.read(readMergeStateProvider);

  /// Which reading is the current one, so an answer about the space just
  /// left, or an older request, cannot land over the next one's.
  int _generation = 0;

  @override
  GitReadingState build() {
    final SpaceEntity? space = ref.watch(
      spaceSessionProvider.select(
        (SpaceSessionState? session) => session?.space,
      ),
    );
    final bool locating = ref.watch(
      spaceSessionProvider.select(
        (SpaceSessionState? session) => session?.locatingRepository ?? false,
      ),
    );
    // The folder is on screen and git has not said where its repository is:
    // that is asked here, in the background, and may wait for a yes.
    if (space != null && locating) {
      unawaited(
        Future<void>.microtask(
          () => _locate(
            space,
            plan: ref.read(openingPlanProvider.notifier).take(),
          ),
        ),
      );
      return const GitReadingState.loading();
    }
    // A folder with no repository is never asked: what opening it found is
    // the whole answer (`docs/product/workspace/without-a-repository/doc.md`).
    if (space == null || !space.hasRepository) {
      return const GitReadingState.initial();
    }
    // Scheduled, not awaited: `build` answers synchronously and may not
    // write the session.
    unawaited(
      Future<void>.microtask(
        () => _read(space, plan: ref.read(openingPlanProvider.notifier).take()),
      ),
    );
    return const GitReadingState.loading();
  }

  /// Every reading is news, even one equal to the last — and `ready()` is
  /// const, so equal is also identical: the git column waits on it to stop
  /// being busy and to take up git's merge draft.
  @override
  bool updateShouldNotify(GitReadingState previous, GitReadingState next) =>
      true;

  /// Asks git where it stands again — after a commit, a stage, a fetch, a
  /// pull, a push, a branch switch, a save or a `Reload`.
  Future<void> refresh() async {
    final SpaceSessionState? session = ref.read(spaceSessionProvider);
    final SpaceEntity? space = session?.space;
    if (space != null && session!.locatingRepository) {
      await _locate(space);
    } else if (space != null && space.hasRepository) {
      await _read(space);
    }
  }

  /// Asks git where [space]'s repository is — the half of opening that
  /// waited — and completes the session with it; the reading that follows
  /// joins the same plan ([plan]).
  ///
  /// Refused, the folder stays as it is and the column says it is out of
  /// date, with `Reload` to ask again.
  Future<void> _locate(SpaceEntity space, {CommandScope? plan}) async {
    final CommandScope scope =
        plan ?? CommandScope.start(CommandActionEnum.readRepository);
    final Result<SpaceEntity, AppFailure> located = await scope.within(
      () => ref.read(openSpaceProvider).locate(space),
    );
    if (!ref.mounted ||
        ref.read(spaceSessionProvider)?.space.root != space.root) {
      return;
    }
    switch (located) {
      case Success<SpaceEntity, AppFailure>(value: final SpaceEntity found):
        ref.read(openingPlanProvider.notifier).handed = scope;
        ref.read(spaceSessionProvider.notifier).located(found);
      case Failure<SpaceEntity, AppFailure>(
        failure: AppFailure(isDenial: true),
      ):
        state = const GitReadingState.stale();
      case Failure<SpaceEntity, AppFailure>(failure: final AppFailure failure):
        state = GitReadingState.failed(failure);
    }
  }

  /// Reads the status, then the merge, and tells the session both — one
  /// action, so in the commands panel the two are one plan — and, when the
  /// space was just opened, the same plan as the opening's own commands
  /// ([plan]).
  Future<void> _read(SpaceEntity space, {CommandScope? plan}) =>
      (plan ?? CommandScope.start(CommandActionEnum.readRepository)).within(
        () => _readBoth(space),
      );

  Future<void> _readBoth(SpaceEntity space) async {
    final int generation = ++_generation;
    final Result<GitStatusValueObject, AppFailure> status = await readGitStatus
        .read(space);
    if (!_current(space, generation)) {
      return;
    }
    final SpaceSessionNotifier session = ref.read(
      spaceSessionProvider.notifier,
    );
    switch (status) {
      case Success<GitStatusValueObject, AppFailure>(
        value: final GitStatusValueObject git,
      ):
        session.observe(git);
        final Result<MergeStateValueObject, AppFailure> merge =
            await readMergeState.read(space);
        if (!_current(space, generation)) {
          return;
        }
        // The merge refused: the one the session had stands, out of date.
        if (merge case Failure<MergeStateValueObject, AppFailure>(
          failure: AppFailure(isDenial: true),
        )) {
          state = const GitReadingState.stale();
          return;
        }
        // A merge that cannot be read is no merge for the screen's purposes:
        // the status already carries the `C` marks.
        session.observeMerge(switch (merge) {
          Success<MergeStateValueObject, AppFailure>(
            value: final MergeStateValueObject it,
          ) =>
            it,
          Failure<MergeStateValueObject, AppFailure>() => null,
        });
        state = const GitReadingState.ready();
      // A refused read leaves the window as it was: the last reading stays
      // on the session, and nothing asks again until somebody does.
      case Failure<GitStatusValueObject, AppFailure>(
        failure: AppFailure(isDenial: true),
      ):
        state = const GitReadingState.stale();
      case Failure<GitStatusValueObject, AppFailure>(
        failure: final AppFailure failure,
      ):
        session.observe(null);
        state = GitReadingState.failed(failure);
    }
  }

  /// Whether a reading started as [generation] for [space] may still land.
  bool _current(SpaceEntity space, int generation) =>
      ref.mounted &&
      generation == _generation &&
      ref.read(spaceSessionProvider)?.space == space;
}
