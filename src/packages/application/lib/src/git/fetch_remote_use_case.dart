/// Asking the remote what it has, without touching the working tree.
library;

import 'package:tom_application/src/use_case.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

/// Updates the remote-tracking branches and nothing else.
///
/// **It never changes a file on disk** — that is what separates it from a
/// pull, and it is why it is safe to offer as a plain button
/// (`docs/product/git-workflow/push-pull/doc.md`). What it buys is that
/// ahead/behind starts meaning something.
final class FetchRemoteUseCase with UseCase {
  /// Creates the use case.
  const FetchRemoteUseCase({required this.gitFor, required this.observability});

  /// How to reach git for a space.
  final GitRepositoryFor gitFor;

  @override
  final Observability observability;

  /// Brings [space]'s remote-tracking branches up to date.
  Future<Result<void, AppFailure>> fetch(SpaceEntity space) =>
      guard(() => gitFor(space).fetch());
}
