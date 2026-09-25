// Whether this process is drawing for a person or writing to a log.
library;

import 'dart:io';

/// True when output should be plain, appended lines: no cursor moves, no
/// redraw, no spinner.
///
/// Two cases: stdout redirected to a pipe or a file has no cursor to move,
/// and CI has a terminal-shaped stream with no terminal behind it, so every
/// frame of a redraw prints as new lines.
bool get isPlain => !stdout.hasTerminal || Platform.environment['CI'] == 'true';
