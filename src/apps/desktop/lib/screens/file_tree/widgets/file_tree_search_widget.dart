/// Full-text search, which arrives in M2.
library;

import 'package:flutter/material.dart';
import 'package:tom_desktop/screens/file_tree/file_tree_design.dart';
import 'package:tom_ui/tom_ui.dart';

/// The search field, on screen and disabled until M2.
///
/// Shown rather than absent, the way Home draws cloning: a control that
/// appears later moves everything under it.
class FileTreeSearchWidget extends StatelessWidget {
  /// Creates the search field.
  const FileTreeSearchWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: TomMetrics.padTight),
      child: Row(
        children: <Widget>[
          Tooltip(
            message: 'Searching the space arrives in M2',
            child: Container(
              width: FileTreeDesign.searchWidth,
              height: FileTreeDesign.searchHeight,
              padding: const EdgeInsets.only(left: 12),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: colors.surfaceSunken,
                border: Border.all(color: colors.border),
                borderRadius: BorderRadius.circular(FileTreeDesign.radius),
              ),
              child: Text(
                'Search',
                style: TextStyle(
                  fontSize: FileTreeDesign.placeholder,
                  height: 1.4,
                  color: colors.textMuted,
                ),
              ),
            ),
          ),
          const SizedBox(
            width:
                FileTreeDesign.chipLeft -
                TomMetrics.padTight -
                FileTreeDesign.searchWidth,
          ),
          // Centred on the field; the design's own y is a pixel off centre.
          const MilestoneChipWidget(label: 'M2'),
        ],
      ),
    );
  }
}
