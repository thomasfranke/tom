/// Reading where the repository stands.
library;

import 'package:tom_application/src/use_case.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

/// Reads the branch, the distance from the remote and everything that
/// differs.
///
/// A reading, not a subscription: it is stale the moment an editor saves,
/// so every operation that changes the tree asks again rather than patching
/// what it has.
final class ReadGitStatusUseCase with UseCase {
  /// Creates the use case.
  const ReadGitStatusUseCase({
    required this.gitFor,
    required this.observability,
  });

  /// How to reach git for a space.
  final GitRepositoryFor gitFor;

  @override
  final Observability observability;

  /// Where [space]'s repository stands.
  Future<Result<GitStatusValueObject, AppFailure>> read(SpaceEntity space) =>
      guard(() => gitFor(space).status());
}
