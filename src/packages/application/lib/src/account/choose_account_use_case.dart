/// Choosing which GitHub account a repository is used with.
library;

import 'package:tom_application/src/use_case.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

/// Remembers [GithubAccountValueObject.login] in the repository's own config,
/// so the choice is per repository and survives the window
/// (`docs/product/workspace/the-account/doc.md`).
final class ChooseAccountUseCase with UseCase {
  /// Creates the use case.
  const ChooseAccountUseCase({
    required this.gitFor,
    required this.observability,
  });

  /// How to reach git for a space.
  final GitRepositoryFor gitFor;

  @override
  final Observability observability;

  /// Uses [account] in [space]'s repository from now on.
  Future<Result<void, AppFailure>> choose(
    SpaceEntity space,
    GithubAccountValueObject account,
  ) => guard(() => gitFor(space).chooseAccount(account.login));
}
