/// Reading the lines of work the repository holds.
library;

import 'package:tom_application/src/use_case.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

/// The local branches, with which one is checked out.
///
/// Local only, because the switcher moves between branches on this machine
/// (`docs/product/git-workflow/branch-switch/doc.md`).
final class ListBranchesUseCase with UseCase {
  /// Creates the use case.
  const ListBranchesUseCase({
    required this.gitFor,
    required this.observability,
  });

  /// How to reach git for a space.
  final GitRepositoryFor gitFor;

  @override
  final Observability observability;

  /// Every branch in [space]'s repository.
  Future<Result<List<BranchEntity>, AppFailure>> list(SpaceEntity space) =>
      guard(() => gitFor(space).branches());
}
