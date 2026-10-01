/// The three dots that say a column's width can be dragged.
library;

import 'package:flutter/material.dart';
import 'package:tom_ui/src/theme/tom_colors.dart';

/// Three 2-point dots in a gutter, at half the window's height.
///
/// **It is the only thing that says a width can be dragged**, which is why a
/// closed column keeps its grip at the window's edge: the way to bring a
/// column back must not close with the column
/// (`docs/design/components/controls.md`).
class TomColumnGripWidget extends StatelessWidget {
  /// Creates the grip.
  const TomColumnGripWidget({super.key});

  /// One dot.
  static const double dot = 2;

  /// Between one dot and the next, centre to centre.
  static const double pitch = 6;

  /// The three of them together.
  static const double height = pitch * 2 + dot;

  @override
  Widget build(BuildContext context) {
    final Color ink = TomColors.of(context).borderStrong;
    return SizedBox(
      width: dot,
      height: height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          for (int each = 0; each < 3; each++)
            SizedBox(
              width: dot,
              height: dot,
              child: DecoratedBox(decoration: BoxDecoration(color: ink)),
            ),
        ],
      ),
    );
  }
}
