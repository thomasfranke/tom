/// [PseudoTerminal] as the person's own shell, with their own environment.
library;

import 'dart:io';

import 'package:tom_core/tom_core.dart';
import 'package:tom_infra/src/pseudo_terminal/pseudo_terminal.dart';
import 'package:tom_infra/src/pseudo_terminal/pseudo_terminal_failure.dart';
import 'package:tom_infra/src/pseudo_terminal/pseudo_terminal_process.dart';

/// Opens a pseudo-terminal and starts [executable] in it — the one piece a
/// Flutter plugin has to supply, so it is handed in rather than imported.
///
/// Throws when the platform refuses; the implementation turns that into a
/// [PseudoTerminalFailure].
typedef PseudoTerminalSpawn =
    PseudoTerminalProcess Function(
      String executable, {
      required List<String> arguments,
      required String workingDirectory,
      required Map<String, String> environment,
      required int columns,
      required int rows,
    });

/// Which shell, with which arguments: the person's own, as their own
/// terminal would start it.
///
/// | Platform | Shell | Arguments |
/// |---|---|---|
/// | macOS | `$SHELL`, else `/bin/zsh` | `-l`, as Terminal.app does |
/// | Linux, the rest | `$SHELL`, else `/bin/bash`, else `/bin/sh` | none |
/// | Windows | PowerShell, else `%ComSpec%`, else `cmd` | `-NoLogo` |
///
/// A login shell on macOS because an app opened from the Finder inherits
/// launchd's bare `PATH`; the profile is what puts `git` and `brew` back.
final class LoginShellPseudoTerminalImpl implements PseudoTerminal {
  /// Creates the implementation over [spawn]; the other three parameters are
  /// the seam the other platforms are tested through.
  LoginShellPseudoTerminalImpl({
    required this.spawn,
    String? operatingSystem,
    Map<String, String>? environment,
    bool Function(String path)? exists,
  }) : operatingSystem = operatingSystem ?? Platform.operatingSystem,
       environment = environment ?? Platform.environment,
       exists = exists ?? _exists;

  /// What opens the pseudo-terminal.
  final PseudoTerminalSpawn spawn;

  /// The platform to answer for.
  final String operatingSystem;

  /// The environment the app was started with, handed on to the shell whole.
  final Map<String, String> environment;

  /// Whether an executable is at a path.
  final bool Function(String path) exists;

  @override
  Future<Result<PseudoTerminalProcess, PseudoTerminalFailure>> start({
    required String folder,
    required int columns,
    required int rows,
  }) async {
    final (String executable, List<String> arguments) = shell();
    if (!exists(executable)) {
      return Failure<PseudoTerminalProcess, PseudoTerminalFailure>(
        PseudoTerminalUnavailable(executable),
      );
    }
    try {
      return Success<PseudoTerminalProcess, PseudoTerminalFailure>(
        spawn(
          executable,
          arguments: arguments,
          workingDirectory: folder,
          environment: shellEnvironment(),
          columns: columns,
          rows: rows,
        ),
      );
      // The plugin reports a refused pty as a `StateError`, which is the
      // platform's answer here and not a bug of ours.
    } on StateError catch (error) {
      return Failure<PseudoTerminalProcess, PseudoTerminalFailure>(
        PseudoTerminalStartFailed(error.message),
      );
    } on Exception catch (error) {
      return Failure<PseudoTerminalProcess, PseudoTerminalFailure>(
        PseudoTerminalStartFailed('$error'),
      );
    }
  }

  /// The shell to start and its arguments, per the table above.
  (String, List<String>) shell() {
    if (operatingSystem == 'windows') {
      final String root = environment['SystemRoot'] ?? r'C:\Windows';
      final String powerShell =
          '$root\\System32\\WindowsPowerShell\\v1.0\\powershell.exe';
      return exists(powerShell)
          ? (powerShell, const <String>['-NoLogo'])
          : (environment['ComSpec'] ?? 'cmd.exe', const <String>[]);
    }
    final String? own = environment['SHELL'];
    if (own != null && own.isNotEmpty && exists(own)) {
      return (own, _loginArguments);
    }
    if (operatingSystem == 'macos') {
      return ('/bin/zsh', _loginArguments);
    }
    return (exists('/bin/bash') ? '/bin/bash' : '/bin/sh', const <String>[]);
  }

  List<String> get _loginArguments =>
      operatingSystem == 'macos' ? const <String>['-l'] : const <String>[];

  /// The app's environment, said to be a colour terminal that speaks UTF-8.
  ///
  /// `LANG` only when the person set none: an app opened from the Finder
  /// has none, and without one zsh draws every accent as `<0303>`.
  Map<String, String> shellEnvironment() => <String, String>{
    ...environment,
    'TERM': 'xterm-256color',
    'COLORTERM': 'truecolor',
    'TERM_PROGRAM': 'TOM',
    if (!environment.containsKey('LANG') && !environment.containsKey('LC_ALL'))
      'LANG': 'en_US.UTF-8',
  };

  static bool _exists(String path) =>
      // A bare name such as `cmd.exe` is the platform's to find on `PATH`.
      !path.contains(Platform.pathSeparator) || File(path).existsSync();
}
