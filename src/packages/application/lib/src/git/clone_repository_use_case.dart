/// Starting a space from a repository that is not on the machine yet.
library;

import 'package:tom_application/src/spaces/open_space_use_case.dart';
import 'package:tom_application/src/use_case.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

/// A repository cloned by URL and opened as a space at once
/// (`docs/product/home/cloning/doc.md`).
///
/// Opening goes through [OpenSpaceUseCase] rather than beside it, so a
/// clone is remembered in Home's list exactly as a folder picked by hand.
final class CloneRepositoryUseCase with UseCase {
  /// Creates the use case.
  const CloneRepositoryUseCase({
    required this.cloner,
    required this.openSpace,
    required this.observability,
  });

  /// What brings the repository onto the machine.
  final GitCloneRepository cloner;

  /// What turns the folder into a space once it is there.
  final OpenSpaceUseCase openSpace;

  @override
  final Observability observability;

  /// [url] cloned into [destination] and opened, with each stage handed to
  /// [onProgress] on the way.
  ///
  /// A failed clone answers in `GitFailure` and opens nothing.
  Future<Result<SpaceEntity, AppFailure>> clone({
    required String url,
    required String destination,
    void Function(CloneProgressValueObject progress)? onProgress,
  }) => guard(() async {
    final Result<void, GitFailure> cloned = await cloner.clone(
      url: url,
      destination: destination,
      onProgress: onProgress,
    );
    if (cloned case Failure<void, GitFailure>(
      failure: final GitFailure failure,
    )) {
      return Failure<SpaceEntity, AppFailure>(failure);
    }
    return openSpace.open(destination);
  });
}
