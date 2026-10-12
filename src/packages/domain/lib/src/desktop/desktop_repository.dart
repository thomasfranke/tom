/// What the application may ask of the machine's own desktop.
library;

import 'package:tom_core/tom_core.dart';

/// The file manager and the terminal, opened on a folder of this machine.
///
/// Folders as absolute paths, because what is opened is sometimes the space
/// and sometimes its repository
/// (`docs/product/navigation/file-tree/explorer-menu/doc.md`,
/// `docs/product/git-workflow/git-menu/doc.md`). [AppFailure] because the
/// product has nothing to say about a refusal but that it happened.
abstract interface class DesktopRepository {
  /// Shows [folder] in the platform's file manager.
  Future<Result<void, AppFailure>> reveal(String folder);

  /// Opens the platform's terminal in [folder].
  Future<Result<void, AppFailure>> openTerminal(String folder);

  /// Opens [address] in the person's own browser.
  Future<Result<void, AppFailure>> openUrl(Uri address);
}
