// Terminal ownership: raw mode, the key stream, and putting the terminal back
// the way it was found.
//
// The last part is not a detail. A process that exits with `echoMode` still
// false leaves the user's shell silently swallowing every keystroke they type
// afterwards, and nothing on screen explains why — so every path out of raw
// mode, including SIGINT and an uncaught error, goes through `restore`.
library;

import 'dart:async';
import 'dart:io';

import '../theme/theme.dart';
import '../tty.dart' as tty;

/// Keys the menus act on, decoded from the byte sequences a terminal sends.
enum Key { up, down, left, right, enter, space, escape, quit, other }

/// The terminal this process is attached to, if it is attached to one.
///
/// Construct with [Terminal.attach] and always release with [restore]; the
/// idiom is `try { ... } finally { terminal.restore(); }`.
final class Terminal {
  Terminal._(this._interactive, this._keys, this._signals);

  final bool _interactive;
  final Stream<List<int>>? _keys;
  final StreamSubscription<ProcessSignal>? _signals;

  /// The one real subscription to `stdin`, behind the broadcast stream.
  ///
  /// Held because pausing it is not enough to let the process end: a live
  /// subscription keeps the event loop alive, so leaving it paused turns
  /// every clean exit into a hang. [restore] cancels it.
  StreamSubscription<List<int>>? _source;

  var _fullScreen = false;
  var _suspended = false;
  var _restored = false;

  /// True when there is nothing to draw on. See `isPlain` in `../tty.dart`,
  /// which the command dashboards share.
  static bool get isPlain => tty.isPlain;

  /// Takes over the terminal: raw mode, no echo, no cursor.
  ///
  /// Returns a non-interactive terminal when [isPlain], so callers can be
  /// written once and simply find [interactive] false.
  static Terminal attach() {
    if (isPlain) return Terminal._(false, null, null);

    _setRawMode(true);
    stdout.write(Ansi.hideCursor);

    late final Terminal terminal;

    // A single broadcast stream, kept alive across screens: listening to
    // `stdin` a second time throws, and every screen subscribes in turn.
    // Pausing instead of cancelling on the last listener is what keeps the
    // underlying subscription usable for the next one — and why `restore`
    // has to cancel it, since a paused subscription still holds the process
    // open.
    final keys = stdin.asBroadcastStream(
      onListen: (s) {
        terminal._source = s;
        s.resume();
      },
      onCancel: (s) => s.pause(),
    );

    // Raw mode delivers Ctrl-C as byte 3 rather than a signal, but the process
    // can still be killed from elsewhere — a `kill`, a parent shell going
    // down. Restoring here covers that.
    final signals = ProcessSignal.sigint.watch().listen((_) {
      terminal.restore();
      exit(130);
    });

    return terminal = Terminal._(true, keys, signals);
  }

  /// False when output is being piped or read by CI; the menus never run.
  bool get interactive => _interactive;

  /// Decoded keystrokes. Empty when not [interactive].
  Stream<Key> get keys {
    final source = _keys;
    if (source == null) return const Stream.empty();
    return source.map(_decode);
  }

  /// Swaps in the alternate screen buffer, cleared, cursor at the top left.
  ///
  /// Paired with [leaveFullScreen] around navigation only. A command's output
  /// must be printed outside the buffer or the terminal discards it on the
  /// way out, which would make `tom test` scroll past and leave nothing
  /// behind. Idempotent, and a no-op when not [interactive].
  void enterFullScreen() {
    if (!_interactive || _fullScreen) return;
    _fullScreen = true;
    stdout.write('${Ansi.enterFullScreen}${Ansi.clearScreen}${Ansi.home}');
  }

  /// Hands the terminal back to a child process, and takes it again with
  /// [resume].
  ///
  /// Not cosmetic: raw mode turns off the driver's signal handling, so a
  /// Ctrl-C typed during a long `build_runner` would arrive as a stray byte
  /// nobody is reading instead of killing it. Cooked mode for the duration of
  /// the work is what keeps a command interruptible.
  void suspend() {
    if (!_interactive || _suspended) return;
    _suspended = true;
    stdout.write(Ansi.showCursor);
    _setRawMode(false);
  }

  /// Retakes the terminal after [suspend]. Idempotent.
  void resume() {
    if (!_interactive || !_suspended) return;
    _suspended = false;
    _setRawMode(true);
    stdout.write(Ansi.hideCursor);
  }

  /// Readies the terminal for a screen about to be drawn from scratch.
  ///
  /// Full screen, that means wiping what the previous screen left and parking
  /// at the top left: the buffer persists across screens, so without this a
  /// second screen renders below the first instead of replacing it. Outside
  /// full screen it does nothing, and screens stack in the scrollback the way
  /// ordinary command output does.
  void beginScreen() {
    if (!_interactive || !_fullScreen) return;
    stdout.write('${Ansi.clearScreen}${Ansi.home}');
  }

  /// Swaps the normal screen back, exactly as it was before
  /// [enterFullScreen]. Idempotent.
  void leaveFullScreen() {
    if (!_interactive || !_fullScreen) return;
    _fullScreen = false;
    stdout.write(Ansi.leaveFullScreen);
  }

  /// Rows available for layout, with a sane floor when the terminal does not
  /// report a height.
  int get rows {
    if (!_interactive) return 24;
    final height = stdout.terminalLines;
    return height > 0 ? height : 24;
  }

  /// Columns available for layout, with a sane floor when the terminal does
  /// not report a width.
  int get columns {
    if (!_interactive) return 80;
    final width = stdout.terminalColumns;
    return width > 0 ? width : 80;
  }

  /// Puts echo, line mode and the cursor back, and releases everything that
  /// would otherwise hold the process open.
  ///
  /// Idempotent: the `finally` that calls it and the signal handler that calls
  /// it may both run.
  void restore() {
    if (_restored || !_interactive) return;
    _restored = true;
    // Both of these keep the event loop alive on their own. Cancelling them
    // is what allows `main` to return instead of the process hanging with a
    // restored terminal and nothing left to do.
    _signals?.cancel();
    _source?.cancel();
    _source = null;
    // Before the cursor, so what comes back is the normal screen with its
    // cursor visible — never the alternate buffer left on screen.
    leaveFullScreen();
    stdout.write(Ansi.showCursor);
    _setRawMode(false);
  }

  /// Guarded: stdin may already be gone when a shell tears the process down,
  /// and failing to set a terminal mode must never be what surfaces as the
  /// error.
  static void _setRawMode(bool raw) {
    try {
      stdin.echoMode = !raw;
      stdin.lineMode = !raw;
    } on StdinException {
      // Nothing left to set.
    }
  }

  static Key _decode(List<int> bytes) {
    if (bytes.isEmpty) return Key.other;

    // CSI sequences: ESC [ A..D for the arrows.
    if (bytes.length >= 3 && bytes[0] == 27 && bytes[1] == 91) {
      return switch (bytes[2]) {
        65 => Key.up,
        66 => Key.down,
        67 => Key.right,
        68 => Key.left,
        _ => Key.other,
      };
    }

    return switch (bytes[0]) {
      13 || 10 => Key.enter,
      32 => Key.space,
      27 => Key.escape,
      3 || 113 || 81 => Key.quit, // Ctrl-C, q, Q
      107 => Key.up, // k
      106 => Key.down, // j
      _ => Key.other,
    };
  }
}
