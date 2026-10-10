/// The pseudo-terminal `flutter_pty` opens, as the infra contract's process.
library;

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_pty/flutter_pty.dart';
import 'package:tom_infra/tom_infra.dart';

/// A [Pty], answering [PseudoTerminalProcess].
///
/// Here because `flutter_pty` is a Flutter plugin and `tom_infra` cannot
/// see Flutter ([Decision 37](../../../../../docs/technical/decisions/037-the-terminal-is-the-persons-own-shell-in-a-pty.md)).
/// Wiring, not logic: which shell, and with what, is
/// [LoginShellPseudoTerminalImpl]'s.
final class FlutterPtyPseudoTerminalProcessImpl
    implements PseudoTerminalProcess {
  /// Opens the pty and starts [executable] in it; the plugin throws a
  /// [StateError] when the platform refuses.
  FlutterPtyPseudoTerminalProcessImpl.spawn(
    this.executable, {
    required List<String> arguments,
    required String workingDirectory,
    required Map<String, String> environment,
    required int columns,
    required int rows,
  }) : _pty = Pty.start(
         executable,
         arguments: arguments,
         workingDirectory: workingDirectory,
         environment: environment,
         columns: columns,
         rows: rows,
       );

  final Pty _pty;

  @override
  final String executable;

  @override
  Stream<Uint8List> get output => _pty.output;

  @override
  Future<int> get exitCode => _pty.exitCode;

  @override
  void write(Uint8List data) => _pty.write(data);

  @override
  void resize(int columns, int rows) => _pty.resize(rows, columns);

  // A hangup, which is what a closing terminal sends: an interactive shell
  // ignores SIGTERM, and hands the hangup on to what it is running.
  @override
  void kill() => _pty.kill(
    Platform.isWindows ? ProcessSignal.sigterm : ProcessSignal.sighup,
  );
}
