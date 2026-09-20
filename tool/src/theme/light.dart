// The light palette: the same roles, inverted where the background demands
// it.
library;

import 'theme.dart';

/// For a light terminal background.
///
/// Every role that reached for brightness in [dark] reaches for darkness
/// here: bright white is invisible on white, and grey — which carries the
/// ordinary rows there — is too faint to be the quiet default against it. So
/// the ordinary row is the terminal's own foreground, emphasis is black, and
/// the dim roles move up to grey rather than down.
///
/// Not reachable yet: nothing sets [palette] to it. It exists so the split
/// between [Layout] and [Palette] is honest — a structure that holds one
/// palette has not been shown to hold two.
const light = Palette(
  title: '${Ansi.bold}${Ansi.black}',
  titleSuffix: Ansi.grey,
  section: Ansi.grey,
  prompt: Ansi.grey,
  selected: '${Ansi.bold}${Ansi.blue}',
  row: Ansi.reset,
  rowEmphasized: '${Ansi.bold}${Ansi.black}',
  rowDisabled: Ansi.grey,
  rule: Ansi.grey,
  detail: Ansi.grey,
  detailIcon: Ansi.darkYellow,
  back: Ansi.black,
  ok: Ansi.green,
  fail: Ansi.red,
  running: Ansi.blue,
  queued: Ansi.grey,
  skipped: Ansi.grey,
);
