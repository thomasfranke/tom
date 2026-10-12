/// Which commands may run without asking.
library;

import 'package:tom_domain/tom_domain.dart';

/// The list the person keeps, as it is on disk now — read at every question
/// in Semi-automatic, so a save by hand applies at once
/// (`docs/product/git-workflow/approvals/doc.md`).
///
/// **No `guard` and no `Result`**, as reading the preferences has none: the
/// repository already answers "nothing is allowed" for anything it cannot
/// read, which is the safe answer.
final class ReadApprovalsUseCase {
  /// Creates the use case.
  const ReadApprovalsUseCase({required this.approvals});

  /// Where the list is kept.
  final ApprovalsRepository approvals;

  /// What the file allows.
  Future<ApprovalsValueObject> read() => approvals.read();
}
