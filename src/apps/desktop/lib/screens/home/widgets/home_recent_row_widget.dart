/// One row of the recent list.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/l10n/l10n.dart';
import 'package:tom_desktop/screens/home/home_design.dart';
import 'package:tom_desktop/widgets/home_relative_path.dart';
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
    final BranchNameValueObject? branch = ref
        .watch(recentBranchProvider(recent))
        .value;
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
                    // The same spelling the status bar and the breadcrumb
                    // use: two spellings of one folder read as two folders.
                    homeRelative(recent.root),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Asked of git each time Home shows the row, so it is the branch
            // the folder is on now; nothing while it answers or when there
            // is none to name.
            if (branch != null) ...<Widget>[
              const SizedBox(width: HomeDesign.rowPad),
              _BranchWidget(branch: branch),
            ],
            IconButton(
              tooltip: context.l10n.homeForgetSpace,
              onPressed: () =>
                  ref.read(homeProvider.notifier).forget(recent.root),
              icon: TomGlyphWidget(
                glyph: TomGlyphEnum.close,
                color: colors.textMuted,
              ),
            ),
            const SizedBox(width: HomeDesign.rowPad - TomMetrics.padTight),
          ],
        ),
      ),
    );
  }
}

/// The branch a row's space is on, drawn as the status bar draws it.
class _BranchWidget extends StatelessWidget {
  const _BranchWidget({required this.branch});

  final BranchNameValueObject branch;

  /// The most a branch takes from the name beside it; past this it is cut.
  static const double _widest = 160;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('branch', branch.value));
  }

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _widest),
      child: Tooltip(
        message: branch.value,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TomGlyphWidget(
              glyph: TomGlyphEnum.branch,
              color: colors.textMuted,
              size: 11,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                branch.value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                  color: colors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
