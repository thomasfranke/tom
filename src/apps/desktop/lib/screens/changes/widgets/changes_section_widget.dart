/// The head of one of the changes list's two sections.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tom_desktop/screens/changes/changes_design.dart';
import 'package:tom_ui/tom_ui.dart';

/// `STAGED · 2` or `CHANGES · 1`, and the one action that moves the whole
/// section to the other.
///
/// Two sections rather than one list with a box per row: what is going into
/// the commit and what is not are the two questions somebody asks before
/// committing, and a 1b board answers them apart.
class ChangesSectionWidget extends StatelessWidget {
  /// Creates the head of a section called [title] holding [count] rows.
  const ChangesSectionWidget({
    required this.title,
    required this.count,
    required this.action,
    required this.onAction,
    super.key,
  });

  /// The section's name, as written: capitals are the caption's own style.
  final String title;

  /// How many rows it holds.
  final int count;

  /// What the action at the right is called.
  final String action;

  /// What it does, or null while git is busy.
  final VoidCallback? onAction;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('title', title))
      ..add(IntProperty('count', count))
      ..add(StringProperty('action', action))
      ..add(ObjectFlagProperty<VoidCallback?>.has('onAction', onAction));
  }

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    return SizedBox(
      height: ChangesDesign.sectionHeight,
      child: Padding(
        padding: const EdgeInsets.only(
          left: ChangesDesign.inset,
          right: ChangesDesign.actionInset,
        ),
        child: Row(
          children: <Widget>[
            Text(
              '$title · $count',
              style: TextStyle(
                fontSize: ChangesDesign.caption,
                height: 1.3,
                letterSpacing: 0.6,
                fontWeight: FontWeight.w600,
                color: colors.textMuted,
              ),
            ),
            const Spacer(),
            InkWell(
              onTap: onAction,
              borderRadius: BorderRadius.circular(TomMetrics.radiusTight),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  action,
                  style: TextStyle(
                    fontSize: ChangesDesign.action,
                    height: 1.3,
                    fontWeight: FontWeight.w500,
                    color: onAction == null ? colors.textMuted : colors.accent,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
