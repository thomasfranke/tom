/// Keeps what the diff is compared against in step with git.
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
import 'package:tom_presentation/src/compare/compare_providers.dart';
import 'package:tom_presentation/src/spaces/space_session.dart';
import 'package:tom_presentation/src/spaces/space_session_notifier.dart';

part 'diff_base_notifier.g.dart';

/// Where `HEAD` is, as far as the base is concerned.
typedef _Where = ({BranchNameValueObject? branch, bool isDetached});

/// Writes the branch the checked-out one came from, and where it left it,
/// into [SpaceSessionState.comparingAgainst]
/// (`docs/product/diff/branch-diff/doc.md`).
///
/// It follows the session's git reading rather than the operations that move
/// `HEAD`, so a branch switched in a terminal is followed like one switched
/// here: another branch is read whole, any other reading only moves the fork
/// point, which a merge or a pull can shift. **Kept alive, and made to exist
/// by the shell**, because nothing else listens to it — the session is what
/// the preview and the bar read.
@Riverpod(keepAlive: true)
class DiffBaseNotifier extends _$DiffBaseNotifier {
  /// Reads the base.
  ReadDiffBaseUseCase get readDiffBase => ref.read(readDiffBaseProvider);

  /// Which reading is the current one, so an answer about the branch just
  /// left cannot land over the next one's.
  int _generation = 0;

  /// The branch the base on the session was read for.
  _Where? _readFor;

  @override
  void build() {
    final SpaceEntity? space = ref.watch(
      spaceSessionProvider.select(
        (SpaceSessionState? session) => session?.space,
      ),
    );
    _readFor = null;
    if (space == null || !space.hasRepository) {
      return;
    }
    ref.listen<GitStatusValueObject?>(
      spaceSessionProvider.select((SpaceSessionState? session) => session?.git),
      (GitStatusValueObject? _, GitStatusValueObject? next) {
        if (next != null) {
          // Scheduled, not run: the first call is inside `build`, which may
          // not write the session.
          unawaited(Future<void>.microtask(() => _follow(space, next)));
        }
      },
      fireImmediately: true,
    );
  }

  /// Reads the base again for another branch, or only its fork point for
  /// the same one.
  Future<void> _follow(SpaceEntity space, GitStatusValueObject git) async {
    final _Where where = (branch: git.branch, isDetached: git.isDetached);
    final DiffBaseValueObject? current = ref
        .read(spaceSessionProvider)
        ?.comparingAgainst;
    if (where == _readFor && current == null) {
      return;
    }
    final int generation = ++_generation;
    final bool sameBranch = where == _readFor;
    final Result<DiffBaseValueObject?, AppFailure> read =
        await CommandScope.run(
          CommandActionEnum.readDiffBase,
          () => sameBranch
              ? readDiffBase.refresh(space, current!.branch)
              : readDiffBase.read(space),
        );
    if (!ref.mounted ||
        generation != _generation ||
        ref.read(spaceSessionProvider)?.space != space) {
      return;
    }
    // Refused, the base on the session stands: it is asked again when git
    // is next read, never before.
    if (read case Failure<DiffBaseValueObject?, AppFailure>(
      failure: AppFailure(isDenial: true),
    )) {
      return;
    }
    // A failure is `HEAD`, which is what the diff compared against before
    // there was a base at all — and is asked again whole on the next reading.
    _readFor = read is Success<DiffBaseValueObject?, AppFailure> ? where : null;
    ref.read(spaceSessionProvider.notifier).compare(switch (read) {
      Success<DiffBaseValueObject?, AppFailure>(
        value: final DiffBaseValueObject? base,
      ) =>
        base,
      Failure<DiffBaseValueObject?, AppFailure>() => null,
    });
  }
}
