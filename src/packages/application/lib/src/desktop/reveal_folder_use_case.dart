/// Showing a folder in the platform's file manager.
library;

import 'package:tom_application/src/use_case.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

/// `Reveal in Finder`: the space's folder from the explorer, the
/// repository's from the git column
/// (`docs/product/navigation/file-tree/explorer-menu/doc.md`).
final class RevealFolderUseCase with UseCase {
  /// Creates the use case.
  const RevealFolderUseCase({
    required this.desktop,
    required this.observability,
  });

  /// The machine's own desktop.
  final DesktopRepository desktop;

  @override
  final Observability observability;

  /// Shows [folder], an absolute path.
  Future<Result<void, AppFailure>> reveal(String folder) =>
      guard(() => desktop.reveal(folder));
}
