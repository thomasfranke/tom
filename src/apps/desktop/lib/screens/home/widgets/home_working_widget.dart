/// Something is happening and there is nothing to decide yet.
library;

import 'package:flutter/material.dart';
import 'package:tom_ui/tom_ui.dart';

/// Something is happening and there is nothing to decide yet.
///
/// Text rather than a spinner: a spinner animates forever when the read
/// never finishes, which makes a stuck app look busy and hangs
/// `pumpAndSettle` in an end-to-end run.
class HomeWorkingWidget extends StatelessWidget {
  /// Creates the line.
  const HomeWorkingWidget({super.key});

  @override
  Widget build(BuildContext context) => Text(
    'Opening…',
    style: TextStyle(fontSize: 13, color: TomColors.of(context).textMuted),
  );
}
