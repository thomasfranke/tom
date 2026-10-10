/// Allowing one command to run without asking, from now on.
library;

import 'package:tom_application/src/use_case.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

/// What `Always allow` writes: `true` beside one command's key, every other
/// key left as it is (`docs/product/git-workflow/approvals/doc.md`).
final class AllowCommandUseCase with UseCase {
  /// Creates the use case.
  const AllowCommandUseCase({
    required this.approvals,
    required this.observability,
  });

  /// Where the list is kept.
  final ApprovalsRepository approvals;

  @override
  final Observability observability;

  /// Lets the command named [key] run unasked.
  Future<Result<void, AppFailure>> allow(String key) =>
      guard(() => approvals.write(key, allowed: true));
}
