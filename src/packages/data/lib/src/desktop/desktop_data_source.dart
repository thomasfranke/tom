/// The desktop, through its capability.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_infra/tom_infra.dart';

/// Where folders are handed to the platform's own programs.
final class DesktopDataSource {
  /// Creates a source over [shell].
  const DesktopDataSource({required this.shell});

  /// The platform's file manager and terminal.
  final DesktopShell shell;

  /// Shows [folder] in the file manager.
  Future<Result<void, DesktopShellFailure>> reveal(String folder) =>
      shell.reveal(folder);

  /// Opens a terminal in [folder].
  Future<Result<void, DesktopShellFailure>> openTerminal(String folder) =>
      shell.openTerminal(folder);

  /// Opens [address] in the browser.
  Future<Result<void, DesktopShellFailure>> openUrl(Uri address) =>
      shell.openUrl(address);
}
