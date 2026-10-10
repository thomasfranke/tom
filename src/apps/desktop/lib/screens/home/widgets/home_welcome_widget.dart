/// The empty state: brand, the ways in, and what was open before.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/l10n/l10n.dart';
import 'package:tom_desktop/screens/home/folder_picker.dart';
import 'package:tom_desktop/screens/home/home_design.dart';
import 'package:tom_desktop/screens/home/widgets/home_clone_widget.dart';
import 'package:tom_desktop/screens/home/widgets/home_primary_button_widget.dart';
import 'package:tom_desktop/screens/home/widgets/home_recent_list_widget.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// The empty state: brand, the ways in, and what was open before.
class HomeWelcomeWidget extends ConsumerWidget {
  /// Creates the welcome, offering [recents], cloning as far as [clone].
  const HomeWelcomeWidget({
    required this.recents,
    this.clone = const HomeCloneState.closed(),
    super.key,
  });

  /// What to offer going back to.
  final List<RecentSpaceEntity> recents;

  /// Where cloning by URL has got to.
  final HomeCloneState clone;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(IterableProperty<RecentSpaceEntity>('recents', recents))
      ..add(DiagnosticsProperty<HomeCloneState>('clone', clone));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TomColors colors = TomColors.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // The key is what the trunk behind this measures itself against; null
        // on a screen without one.
        TomWordmarkWidget(
          key: CommitTrunkWidget.anchorOf(context),
          letters: colors.textPrimary,
          commit: colors.accent,
        ),
        const SizedBox(height: HomeDesign.wordmarkToExpansion),
        Text(
          'Team-Oriented Markdown',
          style: TextStyle(
            fontSize: 16,
            height: 1.4,
            fontWeight: FontWeight.w500,
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: HomeDesign.expansionToTagline),
        Text(
          context.l10n.homeTagline,
          style: TextStyle(fontSize: 15, height: 1.5, color: colors.textMuted),
        ),
        const SizedBox(height: HomeDesign.taglineToChoose),
        HomePrimaryButtonWidget(
          label: context.l10n.homeChooseFolder,
          glyph: TomGlyphEnum.folder,
          onPressed: () => chooseFolder(ref),
        ),
        const SizedBox(height: HomeDesign.chooseToClone),
        HomeCloneWidget(clone: clone, keepsGap: recents.isNotEmpty),
        if (recents.isNotEmpty) HomeRecentListWidget(recents: recents),
      ],
    );
  }
}
