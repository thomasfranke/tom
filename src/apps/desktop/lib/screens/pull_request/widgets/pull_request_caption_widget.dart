/// A section's name in the pull request's column.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tom_desktop/screens/changes/changes_design.dart';
import 'package:tom_desktop/screens/pull_request/pull_request_design.dart';
import 'package:tom_ui/tom_ui.dart';

/// `PROPOSING ONTO`, `WORDS`: the git column's caption, on a line of its own.
class PullRequestCaptionWidget extends StatelessWidget {
  /// Creates the caption [text], upper-cased as the boards set it.
  const PullRequestCaptionWidget(this.text, {super.key});

  /// What the section is.
  final String text;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('text', text));
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    height: PullRequestDesign.captionHeight,
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: ChangesDesign.caption,
          height: 1.3,
          letterSpacing: 0.6,
          fontWeight: FontWeight.w600,
          color: TomColors.of(context).textMuted,
        ),
      ),
    ),
  );
}
