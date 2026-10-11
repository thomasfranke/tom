/// Asking the remote what it has, without touching the working tree.
library;

import 'package:tom_application/src/use_case.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

/// The remote-tracking branches brought up to date, and nothing else.
///
/// It never changes a file on disk, which is what separates it from a pull
/// (`docs/product/git-workflow/push-pull/what-each-does/doc.md`).
final class FetchRemoteUseCase with UseCase {
  /// Creates the use case.
  const FetchRemoteUseCase({required this.gitFor, required this.observability});

  /// How to reach git for a space.
  final GitRepositoryFor gitFor;

  @override
  final Observability observability;

  /// Brings [space]'s remote-tracking branches up to date.
  ///
  /// A repository with no remote says so before git is asked to fetch, since
  /// `git fetch` with none exits 0 and the button would claim it worked.
  Future<Result<void, AppFailure>> fetch(SpaceEntity space) => guard(() async {
    final GitRepository git = gitFor(space);
    switch (await git.remoteAddress()) {
      case Failure<String?, GitFailure>(failure: final GitFailure failure):
        return Failure<void, GitFailure>(failure);
      case Success<String?, GitFailure>(value: null):
        return const Failure<void, GitFailure>(GitNoRemote());
      case Success<String?, GitFailure>():
    }
    return git.fetch();
  });
}
