/// One row of the recent list.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/screens/home/home_design.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// One row of the recent list: a space, and the way to forget it.
class HomeRecentRowWidget extends ConsumerWidget {
  /// Creates the row offering [recent].
  const HomeRecentRowWidget({required this.recent, super.key});

  /// The space this row offers.
  final RecentSpaceEntity recent;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<RecentSpaceEntity>('recent', recent));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TomColors colors = TomColors.of(context);
    return InkWell(
      onTap: () => ref.read(homeProvider.notifier).open(recent.root),
      child: SizedBox(
        height: HomeDesign.row,
        child: Row(
          children: <Widget>[
            const SizedBox(width: HomeDesign.rowPad),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    recent.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                      color: colors.textPrimary,
                    ),
                  ),
                  Text(
                    recent.root,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: colors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            // Where the design puts the branch this space is on. It is not
            // drawn yet and the row says why: a `RecentSpaceEntity` is what
            // can be remembered *without asking git*, and a branch for every
            // row is a disk read per row of a list the user may not click.
            IconButton(
              tooltip: 'Forget this space',
              onPressed: () =>
                  ref.read(homeProvider.notifier).forget(recent.root),
              iconSize: 16,
              color: colors.textMuted,
              icon: const Icon(Icons.close),
            ),
            const SizedBox(width: HomeDesign.rowPad - TomMetrics.padTight),
          ],
        ),
      ),
    );
  }
}
