/// What the machine's own desktop does with a folder, behind a contract.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_infra/src/desktop_shell/desktop_shell_failure.dart';

/// The platform's file manager and terminal, asked to open a folder.
///
/// A capability like the others ([Decision
/// 7](../../../../../../docs/technical/decisions/007-external-dependencies-behind-contracts.md)):
/// each platform names a different program, and the menus that offer these
/// (`docs/product/navigation/file-tree/explorer-menu/doc.md`) should not know
/// which. Both return once the program was started, not once it is closed.
abstract interface class DesktopShell {
  /// Shows [folder] in the platform's file manager.
  Future<Result<void, DesktopShellFailure>> reveal(String folder);

  /// Opens the platform's terminal with [folder] as its working directory.
  Future<Result<void, DesktopShellFailure>> openTerminal(String folder);

  /// Opens [address] in the person's own browser, the host's compare page
  /// for one ([Decision
  /// 33](../../../../../../docs/technical/decisions/033-a-pull-request-draft-is-a-document-outside-the-space.md)).
  Future<Result<void, DesktopShellFailure>> openUrl(Uri address);
}
