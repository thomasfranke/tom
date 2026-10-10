/// Reading what the rendered diff is compared against.
library;

import 'package:tom_application/src/use_case.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

/// The branch the one checked out came from and where it left it, or null
/// for `HEAD` (`docs/product/diff/branch-diff/doc.md`).
///
/// Git answers and [BranchBaseService] decides; nobody chooses. The same
/// handful of commands however many branches there are, because every one is
/// stood against `HEAD` in one `for-each-ref`. The fork point is
/// [GitRepository.forkPoint], the one a pull request onto the branch reads,
/// so the diff shows what the branch did and never what the base did since.
final class ReadDiffBaseUseCase with UseCase {
  /// Creates the use case.
  const ReadDiffBaseUseCase({
    required this.gitFor,
    required this.observability,
    this.bases = const BranchBaseService(),
  });

  /// How to reach git for a space.
  final GitRepositoryFor gitFor;

  @override
  final Observability observability;

  /// The rule.
  final BranchBaseService bases;

  /// What the diff in [space] is compared against.
  Future<Result<DiffBaseValueObject?, AppFailure>> read(
    SpaceEntity space,
  ) => guard<DiffBaseValueObject?, GitFailure>(() async {
    final GitRepository git = gitFor(space);
    final Result<List<BranchEntity>, GitFailure> listed = await git.branches();
    if (listed case Failure<List<BranchEntity>, GitFailure>(
      failure: final GitFailure failure,
    )) {
      return Failure<DiffBaseValueObject?, GitFailure>(failure);
    }
    final BranchEntity? current =
        (listed as Success<List<BranchEntity>, GitFailure>).value
            .where((BranchEntity it) => it.isCurrent)
            .firstOrNull;
    // Detached, or a branch with no commits: `HEAD` is all there is.
    if (current == null) {
      return const Success<DiffBaseValueObject?, GitFailure>(null);
    }
    final Result<BranchNameValueObject?, GitFailure> remotes = await git
        .defaultBranch();
    if (remotes case Failure<BranchNameValueObject?, GitFailure>(
      failure: final GitFailure failure,
    )) {
      return Failure<DiffBaseValueObject?, GitFailure>(failure);
    }
    final Result<BranchNameValueObject?, GitFailure> recorded = await git
        .recordedBase(current.name);
    if (recorded case Failure<BranchNameValueObject?, GitFailure>(
      failure: final GitFailure failure,
    )) {
      return Failure<DiffBaseValueObject?, GitFailure>(failure);
    }
    final Result<List<BranchStandingValueObject>, GitFailure> standings =
        await git.standings();
    if (standings case Failure<List<BranchStandingValueObject>, GitFailure>(
      failure: final GitFailure failure,
    )) {
      return Failure<DiffBaseValueObject?, GitFailure>(failure);
    }
    final BranchRefValueObject? branch = bases.choose(
      current: current.name,
      upstream: current.upstream,
      defaultBranch:
          (remotes as Success<BranchNameValueObject?, GitFailure>).value,
      recorded: (recorded as Success<BranchNameValueObject?, GitFailure>).value,
      standings:
          (standings as Success<List<BranchStandingValueObject>, GitFailure>)
              .value,
    );
    return branch == null
        ? const Success<DiffBaseValueObject?, GitFailure>(null)
        : _leftAt(git, branch);
  });

  /// Where `HEAD` left [branch] now — read again after anything that could
  /// move it (a merge, a pull) without the branch itself changing.
  Future<Result<DiffBaseValueObject?, AppFailure>> refresh(
    SpaceEntity space,
    BranchRefValueObject branch,
  ) => guard<DiffBaseValueObject?, GitFailure>(
    () => _leftAt(gitFor(space), branch),
  );

  /// [branch] with its fork point, or null — `HEAD` — when the two share
  /// no history.
  static Future<Result<DiffBaseValueObject?, GitFailure>> _leftAt(
    GitRepository git,
    BranchRefValueObject branch,
  ) async => (await git.forkPoint(branch.name)).map(
    (CommitShaValueObject? fork) => fork == null
        ? null
        : DiffBaseValueObject(branch: branch, forkPoint: fork),
  );
}
