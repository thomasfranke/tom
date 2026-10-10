/// Moving onto a branch, whether or not it existed a moment ago.
library;

import 'package:tom_application/src/use_case.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

/// `HEAD` moved onto a branch, started first when it does not exist.
///
/// One use case for both because starting a branch is switching to it
/// (`docs/product/git-workflow/branch-switch/doc.md`). Neither asks about
/// unsaved work: that is the session's question, answered before the call.
final class SwitchBranchUseCase with UseCase {
  /// Creates the use case.
  const SwitchBranchUseCase({
    required this.gitFor,
    required this.observability,
  });

  /// How to reach git for a space.
  final GitRepositoryFor gitFor;

  @override
  final Observability observability;

  /// Checks [name] out in [space].
  Future<Result<void, AppFailure>> switchTo(
    SpaceEntity space,
    BranchNameValueObject name,
  ) => guard(() => gitFor(space).switchBranch(name));

  /// Starts [name] at the current `HEAD` of [space], moves onto it, and
  /// records the branch it was started from — what its diff is read against
  /// from then on (`docs/product/diff/branch-diff/doc.md`).
  ///
  /// A record that fails is reported and not returned: the branch exists,
  /// which is what was asked, and its base is deduced instead.
  Future<Result<void, AppFailure>> create(
    SpaceEntity space,
    BranchNameValueObject name,
  ) => guard<void, GitFailure>(() async {
    final GitRepository git = gitFor(space);
    final BranchNameValueObject? from = switch (await git.branches()) {
      Success<List<BranchEntity>, GitFailure>(
        value: final List<BranchEntity> branches,
      ) =>
        branches.where((BranchEntity it) => it.isCurrent).firstOrNull?.name,
      Failure<List<BranchEntity>, GitFailure>() => null,
    };
    final Result<void, GitFailure> created = await git.createBranch(name);
    if (created is Failure<void, GitFailure> || from == null) {
      return created;
    }
    final Result<void, GitFailure> recorded = await git.recordBase(name, from);
    if (recorded case Failure<void, GitFailure>(
      failure: final GitFailure failure,
    )) {
      await observability.capture(
        failure,
        StackTrace.current,
        layer: 'application',
      );
    }
    return created;
  });
}
