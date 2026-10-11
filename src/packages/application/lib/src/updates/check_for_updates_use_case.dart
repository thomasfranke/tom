/// Asking whether a newer TOM has been published.
library;

import 'package:tom_application/src/use_case.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

/// Compares the latest published release with the running one
/// (`docs/product/about/doc.md`). Asked for, never on its own.
final class CheckForUpdatesUseCase with UseCase {
  /// Creates the use case.
  const CheckForUpdatesUseCase({
    required this.updates,
    required this.observability,
  });

  /// Where releases are asked about.
  final UpdatesRepository updates;

  @override
  final Observability observability;

  /// What the host says about [running], the version of this build.
  Future<Result<UpdateAnswerValueObject, AppFailure>> check(
    AppVersionValueObject running,
  ) => guard<UpdateAnswerValueObject, UpdateFailure>(() async {
    final Result<ReleaseValueObject?, UpdateFailure> latest = await updates
        .latest();
    return switch (latest) {
      Failure<ReleaseValueObject?, UpdateFailure>(
        :final UpdateFailure failure,
      ) =>
        Failure<UpdateAnswerValueObject, UpdateFailure>(failure),
      Success<ReleaseValueObject?, UpdateFailure>(value: null) =>
        const Success<UpdateAnswerValueObject, UpdateFailure>(
          UpdateAnswerValueObject.noRelease(),
        ),
      Success<ReleaseValueObject?, UpdateFailure>(
        value: final ReleaseValueObject release,
      ) =>
        Success<UpdateAnswerValueObject, UpdateFailure>(
          release.version.isNewerThan(running)
              ? UpdateAnswerValueObject.newer(release)
              : const UpdateAnswerValueObject.upToDate(),
        ),
    };
  });
}
