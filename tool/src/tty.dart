// Whether this process is drawing for a person or writing to a log.
library;

import 'dart:io';

/// True when output should be plain, appended lines: no cursor moves, no
/// redraw, no spinner.
///
/// Two cases, and both matter. Stdout redirected to a pipe or a file has no
/// cursor to move, so an ANSI rewind is written into the file as garbage. CI
/// has a terminal-shaped stream but no terminal behind it: every frame of a
/// redraw prints as new lines instead of overwriting, and a dashboard that
/// repaints four times a second buries the log it was meant to clarify.
///
/// This is what lets one command serve both. Before it existed, the CI
/// workflow had to bypass `make codegen-gate` and `make flutter-test` and
/// inline its own loops — two implementations of the same run, only one of
/// which anybody tested.
bool get isPlain => !stdout.hasTerminal || Platform.environment['CI'] == 'true';
