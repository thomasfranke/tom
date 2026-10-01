// Terminal ownership: raw mode, the key stream, and putting the terminal back
// the way it was found.
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

  /// The one real subscription to `stdin`, behind the broadcast stream; held
  /// because a paused subscription still keeps the event loop alive, so
  /// [restore] has to cancel it.
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

    // One broadcast stream kept alive across screens: listening to `stdin` a
    // second time throws, and every screen subscribes in turn. Paused rather
    // than cancelled on the last listener, so the next screen can subscribe.
    final keys = stdin.asBroadcastStream(
      onListen: (s) {
        terminal._source = s;
        s.resume();
      },
      onCancel: (s) => s.pause(),
    );

    // Raw mode delivers Ctrl-C as byte 3, but a `kill` or a parent shell
    // going down still arrives as a signal.
    // ignore: cancel_subscriptions, held in _signals and cancelled in restore
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
  /// Paired with [leaveFullScreen] around navigation only: output printed
  /// inside the buffer is discarded on the way out, so `tom test` would leave
  /// nothing behind. Idempotent, and a no-op when not [interactive].
  void enterFullScreen() {
    if (!_interactive || _fullScreen) return;
    _fullScreen = true;
    stdout.write('${Ansi.enterFullScreen}${Ansi.clearScreen}${Ansi.home}');
  }

  /// Hands the terminal back to a child process, until [resume].
  ///
  /// Raw mode turns off the driver's signal handling, so a Ctrl-C typed
  /// during a long `build_runner` would arrive as a stray byte instead of
  /// killing it.
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

  /// Readies the terminal for a screen drawn from scratch: in full screen,
  /// wipes what the previous one left, since the buffer persists across
  /// screens; outside it, nothing, and screens stack in the scrollback.
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
  /// would hold the process open.
  ///
  /// Idempotent, and on every path out of raw mode — SIGINT and an uncaught
  /// error included — because a process that exits with `echoMode` false
  /// leaves the shell silently swallowing every keystroke typed afterwards.
  void restore() {
    if (_restored || !_interactive) return;
    _restored = true;
    // Both keep the event loop alive on their own, and neither cancellation
    // is awaited: this is the teardown, and nothing after it could care.
    // ignore: discarded_futures
    _signals?.cancel();
    // Same for this one, and for the same reason.
    // ignore: discarded_futures
    _source?.cancel();
    _source = null;
    // Before the cursor, so what comes back is the normal screen with its
    // cursor visible — never the alternate buffer left on screen.
    leaveFullScreen();
    stdout.write(Ansi.showCursor);
    _setRawMode(false);
  }

  /// Guarded: stdin may already be gone when a shell tears the process down,
  /// and a failed mode change must never be the error that surfaces.
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
