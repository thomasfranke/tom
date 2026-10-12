/// The five columns of what an account may do in a repository.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tom_desktop/l10n/l10n.dart';
import 'package:tom_desktop/screens/account/account_design.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_ui/tom_ui.dart';

/// `READ · PR · PUSH · MERGE · ADMIN`, each over a tick or a dash.
///
/// The columns are the whole answer — GitHub's name for the role is not
/// shown. With [access] null every column is a dash: nothing known is drawn
/// as nothing known, never as "no" (`docs/product/workspace/the-account/doc.md`).
class AccountAccessWidget extends StatelessWidget {
  /// Creates the grid.
  const AccountAccessWidget({required this.access, super.key});

  /// What the account may do, or null when nothing says.
  final RepositoryAccessValueObject? access;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      DiagnosticsProperty<RepositoryAccessValueObject?>('access', access),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final RepositoryAccessValueObject? known = access;
    return Row(
      children: <Widget>[
        for (final (String label, bool? granted) in <(String, bool?)>[
          (l10n.accountColumnRead, known?.canRead),
          (l10n.accountColumnPullRequest, known?.canOpenPullRequests),
          (l10n.accountColumnPush, known?.canPush),
          (l10n.accountColumnMerge, known?.canMerge),
          (l10n.accountColumnAdmin, known?.canAdminister),
        ])
          Expanded(
            child: _ColumnWidget(label: label, granted: granted),
          ),
      ],
    );
  }
}

/// One column: its label, and 28 under the label's top, its mark.
class _ColumnWidget extends StatelessWidget {
  const _ColumnWidget({required this.label, required this.granted});

  final String label;
  final bool? granted;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('label', label))
      ..add(DiagnosticsProperty<bool?>('granted', granted));
  }

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    final AppLocalizations l10n = context.l10n;
    const double labelLine = AccountDesign.caption * 1.2;
    return Semantics(
      label:
          '$label: ${switch (granted) {
            true => l10n.accountCan,
            false => l10n.accountCannot,
            null => l10n.accountUnknown,
          }}',
      excludeSemantics: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            label,
            maxLines: 1,
            style: TextStyle(
              fontSize: AccountDesign.caption,
              height: 1.2,
              letterSpacing: AccountDesign.captionSpacing,
              fontWeight: FontWeight.w600,
              color: colors.textMuted,
            ),
          ),
          const SizedBox(height: AccountDesign.labelToMark - labelLine),
          SizedBox(
            height: AccountDesign.check,
            child: Center(
              child: granted ?? false
                  ? TomGlyphWidget(
                      glyph: TomGlyphEnum.check,
                      color: colors.added,
                      size: AccountDesign.check,
                    )
                  : TomGlyphWidget(
                      glyph: TomGlyphEnum.rule,
                      color: colors.textMuted,
                      size: AccountDesign.dash,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
