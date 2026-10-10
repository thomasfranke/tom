/// One shell running in a pseudo-terminal.
library;

import 'dart:typed_data';

/// A started shell: bytes out, bytes in, and the size of the screen it
/// draws on.
///
/// Bytes rather than text across the contract, because a chunk can end in
/// the middle of a character and only the reader of the whole stream can
/// put it back together.
abstract interface class PseudoTerminalProcess {
  /// The shell's executable, as it was started — `/bin/zsh`.
  String get executable;

  /// What the shell writes to its screen, escape sequences included.
  Stream<Uint8List> get output;

  /// The shell's exit code, once it has ended.
  Future<int> get exitCode;

  /// Hands [data] to the shell as if typed.
  void write(Uint8List data);

  /// Tells the shell its screen is now [columns] wide and [rows] tall.
  void resize(int columns, int rows);

  /// Ends the shell and whatever it is running in the foreground.
  void kill();
}
