/// One shell, running for the Terminal tab.
library;

import 'package:tom_domain/src/terminal/terminal_size_value_object.dart';

/// A live shell: what it draws, what it is typed, and when it ends
/// (`docs/product/workspace/terminal/doc.md`).
///
/// Text both ways: the bytes are put back into characters below, so a
/// chunk that ended mid-character never reaches a reader.
abstract interface class TerminalSessionPort {
  /// The shell's name — `zsh`, `bash`, `powershell`.
  String get shell;

  /// The folder it was started in, an absolute path.
  String get folder;

  /// What it writes to its screen, escape sequences included.
  Stream<String> get output;

  /// Its exit code, once it has ended.
  Future<int> get exited;

  /// Hands [input] to it as if typed.
  void write(String input);

  /// Tells it its screen is now [size].
  void resize(TerminalSizeValueObject size);

  /// Ends it, and whatever it is running.
  void close();
}
