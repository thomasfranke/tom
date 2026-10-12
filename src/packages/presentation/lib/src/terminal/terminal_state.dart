/// Where the Terminal tab's shell stands.
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tom_core/tom_core.dart';

part 'terminal_state.freezed.dart';

/// The states the space's one shell can be in, and there are only these
/// (`docs/product/workspace/terminal/doc.md`).
///
/// What the shell drew is not here: it is the notifier's transcript, which
/// changes on every keystroke and is read by the emulator, not by a build.
@freezed
sealed class TerminalState with _$TerminalState {
  /// Nobody has shown the tab in this space yet, so no shell is running.
  const factory TerminalState.initial() = TerminalInitial;

  /// The shell has been asked for and has not answered.
  const factory TerminalState.starting() = TerminalStarting;

  /// [shell] is running in [folder], an absolute path.
  const factory TerminalState.running({
    /// Its name — `zsh`.
    required String shell,

    /// Where it was started; a `cd` inside it does not move this.
    required String folder,
  }) = TerminalRunning;

  /// [shell] ended with [code]; the next key starts another.
  const factory TerminalState.exited({
    /// Its name.
    required String shell,

    /// Where it ran.
    required String folder,

    /// What it exited with.
    required int code,
  }) = TerminalExited;

  /// No shell would start.
  const factory TerminalState.failed(AppFailure failure) = TerminalFailed;
}

/// [folder] with the person's [home] spelled `~`, the way a prompt says it.
String terminalPlaceOf(String folder, String? home) {
  if (home == null || home.isEmpty) {
    return folder;
  }
  final String base = home.endsWith('/') || home.endsWith(r'\')
      ? home.substring(0, home.length - 1)
      : home;
  if (folder == base) {
    return '~';
  }
  for (final String separator in <String>['/', r'\']) {
    if (folder.startsWith('$base$separator')) {
      return '~$separator${folder.substring(base.length + 1)}';
    }
  }
  return folder;
}
