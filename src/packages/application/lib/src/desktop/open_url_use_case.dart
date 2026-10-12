/// Opening an address in the person's browser.
library;

import 'package:tom_application/src/use_case.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

/// `Open on GitHub instead`: the host's compare page, handed to the
/// browser (`docs/product/git-workflow/pull-request/opening-it/doc.md`).
final class OpenUrlUseCase with UseCase {
  /// Creates the use case.
  const OpenUrlUseCase({required this.desktop, required this.observability});

  /// The machine's own desktop.
  final DesktopRepository desktop;

  @override
  final Observability observability;

  /// Opens [address].
  Future<Result<void, AppFailure>> open(Uri address) =>
      guard(() => desktop.openUrl(address));
}
