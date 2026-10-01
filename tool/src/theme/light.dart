// The light palette: the same roles, inverted where the background demands
// it.
library;

import 'theme.dart';

/// For a light terminal background: every role that reached for brightness
/// in [dark] reaches for darkness here.
///
/// Not reachable yet — nothing sets [palette] to it. It exists so the split
/// between [Layout] and [Palette] is honest.
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
