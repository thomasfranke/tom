/// The right column of a space git knows nothing about.
library;

import 'package:flutter/material.dart';
import 'package:tom_desktop/l10n/l10n.dart';
import 'package:tom_ui/tom_ui.dart';

/// The fact, alone in the column, and what still works said before what
/// does not (`docs/product/workspace/without-a-repository/doc.md`).
///
/// No button: TOM never creates a repository on the user's behalf, and a
/// control that cannot work here is not drawn
/// (`git-not-git/no-repository-light.svg`).
class WorkspaceNoRepositoryPanel extends StatelessWidget {
  /// Creates the panel.
  const WorkspaceNoRepositoryPanel({super.key});

  /// A touch above the middle, where the board puts the group's centre:
  /// 408 in a column running 40 … 868 (measured against the render).
  static const Alignment _place = Alignment(0, -0.125);

  /// The glyph, which the board draws 30 tall.
  static const double _glyph = 30;

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    final AppLocalizations l10n = context.l10n;
    final TextStyle quiet = TextStyle(
      fontSize: 12,
      height: 1.5,
      color: colors.textSecondary,
    );
    return Align(
      alignment: _place,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: TomMetrics.pad),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TomGlyphWidget(
              glyph: TomGlyphEnum.branch,
              color: colors.textMuted,
              size: _glyph,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.workspaceNoRepository,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                height: 1.4,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.workspaceNoRepositoryWorks,
              textAlign: TextAlign.center,
              style: quiet,
            ),
            Text(
              l10n.workspaceNoRepositoryUnversioned,
              textAlign: TextAlign.center,
              style: quiet,
            ),
          ],
        ),
      ),
    );
  }
}
