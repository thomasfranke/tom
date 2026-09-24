/// Something is happening and there is nothing to decide yet.
library;

import 'package:flutter/material.dart';
import 'package:tom_ui/tom_ui.dart';

/// Something is happening and there is nothing to decide yet.
///
/// Text rather than a spinner, and the reason is not taste. Reading the
/// recent list takes a few milliseconds — a spinner would be a flicker
/// nobody sees. What it *would* do is animate forever if the read never
/// finished, which turns a stuck app into a stuck app that looks busy, and
/// turns an end-to-end failure into a run that hangs until the harness
/// gives up ten minutes later with nothing to say.
///
/// A loading state that cannot animate forever is one that always fails
/// loudly.
class HomeWorkingWidget extends StatelessWidget {
  /// Creates the line.
  const HomeWorkingWidget({super.key});

  @override
  Widget build(BuildContext context) => Text(
    'Opening…',
    style: TextStyle(fontSize: 13, color: TomColors.of(context).textMuted),
  );
}
