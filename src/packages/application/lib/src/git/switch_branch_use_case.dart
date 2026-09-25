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

  /// Starts [name] at the current `HEAD` of [space] and moves onto it.
  Future<Result<void, AppFailure>> create(
    SpaceEntity space,
    BranchNameValueObject name,
  ) => guard(() => gitFor(space).createBranch(name));
}
