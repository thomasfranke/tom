// The escape sequences themselves, which mean the same thing under every
// palette.
library;

/// ANSI SGR sequences, and the cursor moves the screens redraw with.
///
/// Plain constants rather than a helper class: a screen that redraws on every
/// keystroke should not allocate to print a color.
abstract final class Ansi {
  static const reset = '\x1B[0m';
  static const bold = '\x1B[1m';
  static const dim = '\x1B[2m';

  static const black = '\x1B[30m';
  static const white = '\x1B[97m';
  static const cyan = '\x1B[96m';
  static const blue = '\x1B[34m';
  static const yellow = '\x1B[33m';
  static const darkYellow = '\x1B[93m';
  static const green = '\x1B[32m';
  static const red = '\x1B[31m';
  static const grey = '\x1B[90m';
  static const darkGrey = '\x1B[37m';

  /// Erase from the cursor to the end of the line, so a shorter row can
  /// overwrite a longer one.
  static const clearLine = '\x1B[K';

  static const hideCursor = '\x1B[?25l';
  static const showCursor = '\x1B[?25h';

  /// Erase the whole screen, and park the cursor at the top left.
  static const clearScreen = '\x1B[2J';
  static const home = '\x1B[H';

  /// The alternate screen buffer, swapped back out untouched on exit — so
  /// anything worth keeping has to be printed with it switched off.
  static const enterFullScreen = '\x1B[?1049h';
  static const leaveFullScreen = '\x1B[?1049l';

  /// Move the cursor up [n] rows, to rewind over the rendered block.
  static String up(int n) => n > 0 ? '\x1B[${n}A' : '';

  /// Move the cursor down [n] rows.
  static String down(int n) => n > 0 ? '\x1B[${n}B' : '';
}
