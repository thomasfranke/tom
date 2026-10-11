/// The command log nobody reads.
library;

import 'package:tom_core/src/command_log.dart';
import 'package:tom_core/src/command_record.dart';

/// The [CommandLog] that keeps nothing — what a capability writes to when
/// nobody gave it one, so a test or a tool never has to.
final class SilentCommandLogImpl implements CommandLog {
  /// Creates the log.
  const SilentCommandLogImpl();

  @override
  void record(CommandRecord record) {}
}
