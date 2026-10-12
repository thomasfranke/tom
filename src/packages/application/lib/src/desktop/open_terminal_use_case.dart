/// Opening a terminal where git runs.
library;

import 'package:tom_application/src/use_case.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

/// `Open in terminal`, at the repository's root: what this product does not
/// do is still a `git` command away
/// (`docs/product/git-workflow/git-menu/doc.md`).
final class OpenTerminalUseCase with UseCase {
  /// Creates the use case.
  const OpenTerminalUseCase({
    required this.desktop,
    required this.observability,
  });

  /// The machine's own desktop.
  final DesktopRepository desktop;

  @override
  final Observability observability;

  /// Opens a terminal in [folder], an absolute path.
  Future<Result<void, AppFailure>> open(String folder) =>
      guard(() => desktop.openTerminal(folder));
}
