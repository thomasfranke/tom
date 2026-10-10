/// Putting every command the app can run in the list, for the person to edit.
library;

import 'package:tom_application/src/use_case.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

/// Makes `git-approvals.json` list every command, each `false` unless the
/// person already said otherwise — done before the file is opened, so a
/// first look finds the whole list
/// (`docs/product/git-workflow/approvals/doc.md`).
final class SeedApprovalsUseCase with UseCase {
  /// Creates the use case.
  const SeedApprovalsUseCase({
    required this.approvals,
    required this.observability,
  });

  /// Where the list is kept.
  final ApprovalsRepository approvals;

  @override
  final Observability observability;

  /// Lists what is missing, touching nothing that is there.
  Future<Result<void, AppFailure>> seed() => guard(approvals.seed);
}
