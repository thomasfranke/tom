/// The person's own shell in a pseudo-terminal, behind a contract.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_infra/src/pseudo_terminal/pseudo_terminal_failure.dart';
import 'package:tom_infra/src/pseudo_terminal/pseudo_terminal_process.dart';

/// Starts the shell the person uses in their own terminal, in a folder
/// ([Decision 37](../../../../../../docs/technical/decisions/037-the-terminal-is-the-persons-own-shell-in-a-pty.md)).
///
/// **Nothing it runs is written to the `CommandLog`**: the commands panel is
/// what TOM ran, and what somebody types into their own shell is theirs.
abstract interface class PseudoTerminal {
  /// Starts the shell in [folder], an absolute path, on a screen [columns]
  /// wide and [rows] tall.
  Future<Result<PseudoTerminalProcess, PseudoTerminalFailure>> start({
    required String folder,
    required int columns,
    required int rows,
  });
}
