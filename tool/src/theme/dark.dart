// The dark palette: the default, and the one the screens were drawn against.
library;

import 'theme.dart';

/// For a dark terminal background.
///
/// Rows are white — the same white as `← Quit` — so the list reads as one
/// even block and the cursor is what says where you are. Grey is kept for the
/// things around the rows (title suffix, section, prompt, rules, metadata),
/// which is what puts the rows in front of their own chrome.
const dark = Palette(
  title: '${Ansi.bold}${Ansi.white}',
  titleSuffix: Ansi.grey,
  section: Ansi.grey,
  prompt: Ansi.grey,
  selected: '${Ansi.bold}${Ansi.cyan}',
  row: Ansi.white,
  // Emphasis has to outrank an already-white row, so it is bold rather than
  // brighter: there is nothing brighter left.
  rowEmphasized: '${Ansi.bold}${Ansi.white}',
  rowDisabled: '${Ansi.dim}${Ansi.grey}',
  rule: Ansi.grey,
  detail: Ansi.grey,
  detailIcon: Ansi.yellow,
  back: Ansi.white,
  ok: Ansi.green,
  fail: Ansi.red,
  running: Ansi.cyan,
  queued: Ansi.grey,
  skipped: '${Ansi.dim}${Ansi.grey}',
);
