/// The person's shell, through its capability.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_infra/tom_infra.dart';

/// Where a shell is started in a pseudo-terminal.
final class TerminalDataSource {
  /// Creates a source over [terminal].
  const TerminalDataSource({required this.terminal});

  /// The pseudo-terminal capability.
  final PseudoTerminal terminal;

  /// Starts the shell in [folder], [columns] by [rows].
  Future<Result<PseudoTerminalProcess, PseudoTerminalFailure>> start(
    String folder, {
    required int columns,
    required int rows,
  }) => terminal.start(folder: folder, columns: columns, rows: rows);
}
