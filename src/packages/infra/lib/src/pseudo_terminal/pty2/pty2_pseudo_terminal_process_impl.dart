/// The pseudo-terminal `pty2` opens, as the contract's process.
library;

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:pty2/pty2.dart';
import 'package:tom_infra/src/pseudo_terminal/pseudo_terminal_process.dart';

/// A `pty2` [PseudoTerminal], answering [PseudoTerminalProcess].
///
/// Wiring, not logic: which shell, and with what, is
/// `LoginShellPseudoTerminalImpl`'s. `pty2` speaks text and this contract
/// speaks bytes, so what it decoded is encoded again — a chunk that ends in
/// the middle of a character is already stitched by `pty2`.
final class Pty2PseudoTerminalProcessImpl implements PseudoTerminalProcess {
  /// Opens the pty and starts [executable] in it; `pty2` throws a
  /// [PtyException] when the platform refuses.
  Pty2PseudoTerminalProcessImpl.spawn(
    this.executable, {
    required List<String> arguments,
    required String workingDirectory,
    required Map<String, String> environment,
    required int columns,
    required int rows,
  }) : _pty = PseudoTerminal.start(
         executable,
         arguments,
         workingDirectory: workingDirectory,
         environment: environment,
       ) {
    // `pty2` has no size to start at; the shell is told before it prompts
    // as far as the first read goes.
    _pty.resize(columns, rows);
  }

  /// Wraps a terminal somebody else opened — the seam a unit test puts a
  /// scripted one through, so the wiring is proved with no pty.
  Pty2PseudoTerminalProcessImpl.over(this.executable, PseudoTerminal terminal)
    : _pty = terminal;

  final PseudoTerminal _pty;

  @override
  final String executable;

  @override
  Stream<Uint8List> get output =>
      _pty.out.map((String text) => Uint8List.fromList(utf8.encode(text)));

  @override
  Future<int> get exitCode => _pty.exitCode;

  @override
  void write(Uint8List data) =>
      _pty.write(utf8.decode(data, allowMalformed: true));

  @override
  void resize(int columns, int rows) => _pty.resize(columns, rows);

  // A hangup, which is what a closing terminal sends: an interactive shell
  // ignores SIGTERM, and hands the hangup on to what it is running.
  @override
  void kill() {
    _pty.kill(
      Platform.isWindows ? ProcessSignal.sigterm : ProcessSignal.sighup,
    );
  }
}
