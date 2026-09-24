/// The spaces to go back to, one click each.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tom_desktop/screens/home/home_design.dart';
import 'package:tom_desktop/screens/home/widgets/home_recent_row_widget.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_ui/tom_ui.dart';

/// The spaces to go back to, one click each.
///
/// The folders are not checked before they are drawn: a row whose folder is
/// gone is still shown, because Home's answer to that is to offer to forget
/// it rather than to hide it (`docs/product/home/doc.md`).
class HomeRecentListWidget extends StatelessWidget {
  /// Creates the list of [recents].
  const HomeRecentListWidget({required this.recents, super.key});

  /// What to show, newest first.
  final List<RecentSpaceEntity> recents;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<RecentSpaceEntity>('recents', recents));
  }

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    return SizedBox(
      width: HomeDesign.column,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'RECENT',
            style: TextStyle(
              fontSize: 10,
              height: 1.4,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
              color: colors.textMuted,
            ),
          ),
          const SizedBox(height: HomeDesign.recentToCard),
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surfaceRaised,
              border: Border.all(color: colors.border),
              borderRadius: BorderRadius.circular(HomeDesign.cardRadius),
            ),
            child: Column(
              children: <Widget>[
                for (final (int i, RecentSpaceEntity recent)
                    in recents.indexed) ...<Widget>[
                  if (i > 0)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: HomeDesign.rulePad - 1,
                      ),
                      child: Divider(height: 1, color: colors.border),
                    ),
                  HomeRecentRowWidget(recent: recent),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
