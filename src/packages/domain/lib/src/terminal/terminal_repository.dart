/// Where a shell for the Terminal tab comes from.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/src/terminal/terminal_session_port.dart';
import 'package:tom_domain/src/terminal/terminal_size_value_object.dart';

/// Starts the person's own shell in a folder of this machine
/// (`docs/product/workspace/terminal/doc.md`).
///
/// [AppFailure] because the product has nothing to say about a shell that
/// would not start but that it did not.
abstract interface class TerminalRepository {
  /// Starts a shell in [folder], an absolute path, on a screen of [size].
  Future<Result<TerminalSessionPort, AppFailure>> start(
    String folder,
    TerminalSizeValueObject size,
  );
}
