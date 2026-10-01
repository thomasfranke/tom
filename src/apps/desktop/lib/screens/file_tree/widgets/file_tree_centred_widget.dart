/// One thing in a row, centred on the row's own box.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tom_desktop/screens/file_tree/file_tree_design.dart';

/// One thing in a row, centred on the row's own box.
///
/// Centred rather than placed at the design's absolute y, because Flutter
/// splits a line's leading by ascent and descent and the text lands low;
/// centring hits the design's number and survives a change of font.
class FileTreeCentredWidget extends StatelessWidget {
  /// Places [child] at [left], centred on the row.
  const FileTreeCentredWidget({
    required this.left,
    required this.child,
    this.right,
    super.key,
  });

  /// Where it starts, from the panel's edge.
  final double left;

  /// Where it stops, or null to take what it needs.
  final double? right;

  /// What to centre.
  final Widget child;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DoubleProperty('left', left))
      ..add(DoubleProperty('right', right));
  }

  @override
  Widget build(BuildContext context) => Positioned(
    left: left,
    right: right,
    top: 0,
    height: FileTreeDesign.rowHeight,
    child: Align(alignment: Alignment.centerLeft, child: child),
  );
}
