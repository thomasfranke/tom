/// The empty state: brand, the ways in, and what was open before.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/screens/home/folder_picker.dart';
import 'package:tom_desktop/screens/home/home_design.dart';
import 'package:tom_desktop/screens/home/widgets/home_primary_button_widget.dart';
import 'package:tom_desktop/screens/home/widgets/home_recent_list_widget.dart';
import 'package:tom_desktop/screens/home/widgets/home_secondary_button_widget.dart';
import 'package:tom_desktop/theme/tom_colors.dart';
import 'package:tom_desktop/theme/tom_metrics.dart';
import 'package:tom_desktop/widgets/commit_trunk_widget.dart';
import 'package:tom_desktop/widgets/milestone_chip_widget.dart';
import 'package:tom_desktop/widgets/tom_wordmark_widget.dart';
import 'package:tom_domain/tom_domain.dart';

/// The empty state: brand, the ways in, and what was open before.
class HomeWelcomeWidget extends ConsumerWidget {
  /// Creates the welcome, offering [recents].
  const HomeWelcomeWidget({required this.recents, super.key});

  /// What to offer going back to.
  final List<RecentSpaceEntity> recents;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<RecentSpaceEntity>('recents', recents));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TomColors colors = TomColors.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // The key is what the trunk behind this measures itself against; it
        // is null on any screen without one, and the mark does not care.
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
          'A Git client built for documentation, not code.',
          style: TextStyle(fontSize: 15, height: 1.5, color: colors.textMuted),
        ),
        const SizedBox(height: HomeDesign.taglineToChoose),
        HomePrimaryButtonWidget(
          label: 'Choose folder…',
          onPressed: () => chooseFolder(ref),
        ),
        const SizedBox(height: HomeDesign.chooseToClone),
        // M3, and shown disabled rather than hidden: the design puts it
        // here, and a control that appears later moves everything under it.
        // The chip beside it is what says *later* — the row is as wide as
        // the column plus the chip, so the column itself stays centred.
        const Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(width: HomeDesign.chipGutter),
            Tooltip(
              message: 'Cloning arrives in M3',
              child: HomeSecondaryButtonWidget(label: 'Clone from URL'),
            ),
            SizedBox(width: TomMetrics.padTight),
            MilestoneChipWidget(label: 'M3'),
          ],
        ),
        if (recents.isNotEmpty) ...<Widget>[
          const SizedBox(height: HomeDesign.cloneToRecent),
          HomeRecentListWidget(recents: recents),
        ],
      ],
    );
  }
}
