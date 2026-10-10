/// The `dart:io` implementation of [DesktopShell].
library;

import 'dart:io';

import 'package:tom_core/tom_core.dart';
import 'package:tom_infra/src/desktop_shell/desktop_shell.dart';
import 'package:tom_infra/src/desktop_shell/desktop_shell_failure.dart';

/// Runs [executable] with [arguments] and answers its result.
typedef DesktopShellRunner =
    Future<ProcessResult> Function(
      String executable,
      List<String> arguments, {
      String? workingDirectory,
    });

/// Starts [executable] and lets it outlive the call.
typedef DesktopShellStarter =
    Future<void> Function(
      String executable,
      List<String> arguments, {
      String? workingDirectory,
    });

/// Asks each platform's own programs.
///
/// | Platform | File manager | Terminal |
/// |---|---|---|
/// | macOS | `open <folder>` | `open -a Terminal <folder>` |
/// | Windows | `explorer <folder>` | `cmd /c start cmd`, started in it |
/// | Linux, the rest | `xdg-open <folder>` | `x-terminal-emulator`, in it |
///
/// An address goes to `open`, `rundll32 url.dll` and `xdg-open`.
///
/// `explorer` answers 1 when it succeeded, so its exit code is not read.
final class DartIoDesktopShellImpl implements DesktopShell {
  /// Creates the implementation; the three parameters are the seam the
  /// other platforms' branches are tested through.
  const DartIoDesktopShellImpl({
    this.operatingSystem,
    this.run = _run,
    this.start = _start,
    this.commandLog = const SilentCommandLog(),
  });

  /// Where every program is written down — one left running as soon as it
  /// started, with nothing to say about how it ended.
  final CommandLog commandLog;

  /// The platform to answer for, or this machine's.
  final String? operatingSystem;

  /// What runs a program to its end.
  final DesktopShellRunner run;

  /// What starts one and leaves it running.
  final DesktopShellStarter start;

  String get _platform => operatingSystem ?? Platform.operatingSystem;

  @override
  Future<Result<void, DesktopShellFailure>> reveal(String folder) =>
      switch (_platform) {
        'macos' => _ran('open', <String>[folder]),
        'windows' => _ran('explorer', <String>[folder], readExit: false),
        _ => _ran('xdg-open', <String>[folder]),
      };

  @override
  Future<Result<void, DesktopShellFailure>> openTerminal(String folder) =>
      switch (_platform) {
        'macos' => _ran('open', <String>['-a', 'Terminal', folder]),
        'windows' => _started('cmd', <String>['/c', 'start', 'cmd'], folder),
        _ => _started('x-terminal-emulator', const <String>[], folder),
      };

  // `rundll32` on Windows rather than `start`, because `cmd` reads the `&`
  // every query string carries as the end of a command.
  @override
  Future<Result<void, DesktopShellFailure>> openUrl(Uri address) =>
      switch (_platform) {
        'macos' => _ran('open', <String>['$address']),
        'windows' => _ran('rundll32', <String>[
          'url.dll,FileProtocolHandler',
          '$address',
        ], readExit: false),
        _ => _ran('xdg-open', <String>['$address']),
      };

  Future<Result<void, DesktopShellFailure>> _ran(
    String executable,
    List<String> arguments, {
    bool readExit = true,
  }) async {
    // An exit nobody reads is an answer whatever it is: `explorer` says 1
    // when it worked.
    final CommandEnded ended = commandLog.started(
      executable,
      arguments,
      answers: readExit ? const <int>{} : const <int>{1},
    );
    try {
      final ProcessResult result = await run(executable, arguments);
      ended(result.exitCode, stdout: result.stdout, stderr: result.stderr);
      if (readExit && result.exitCode != 0) {
        return Failure<void, DesktopShellFailure>(
          DesktopShellOperationFailed('$executable: ${result.stderr}'.trim()),
        );
      }
      return const Success<void, DesktopShellFailure>(null);
    } on ProcessException catch (error) {
      ended(null, stderr: error.message, ran: false);
      return Failure<void, DesktopShellFailure>(_translate(executable, error));
    }
  }

  Future<Result<void, DesktopShellFailure>> _started(
    String executable,
    List<String> arguments,
    String folder,
  ) async {
    final CommandEnded ended = commandLog.started(executable, arguments);
    try {
      await start(executable, arguments, workingDirectory: folder);
      // Exit 0 for "it started": a program left running never says more.
      ended(0);
      return const Success<void, DesktopShellFailure>(null);
    } on ProcessException catch (error) {
      ended(null, stderr: error.message, ran: false);
      return Failure<void, DesktopShellFailure>(_translate(executable, error));
    }
  }

  /// A program that is not installed is named; anything else is described.
  static DesktopShellFailure _translate(
    String executable,
    ProcessException error,
  ) => error.errorCode == 2
      ? DesktopShellUnavailable(executable)
      : DesktopShellOperationFailed('$executable: ${error.message}');

  static Future<ProcessResult> _run(
    String executable,
    List<String> arguments, {
    String? workingDirectory,
  }) => Process.run(executable, arguments, workingDirectory: workingDirectory);

  static Future<void> _start(
    String executable,
    List<String> arguments, {
    String? workingDirectory,
  }) => Process.start(
    executable,
    arguments,
    workingDirectory: workingDirectory,
    mode: ProcessStartMode.detached,
  );
}
