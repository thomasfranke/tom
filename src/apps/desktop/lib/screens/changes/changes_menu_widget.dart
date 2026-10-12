/// The `⋮` at the head of the git column.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/l10n/l10n.dart';
import 'package:tom_desktop/screens/changes/changes_design.dart';
import 'package:tom_desktop/widgets/file_manager_words.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// `Reload`, `Open in terminal`, `Open repository in Finder`; then
/// `Discard all changes` alone, in `removed`
/// (`docs/product/git-workflow/git-menu/doc.md`).
///
/// The discard asks first, naming how many documents go back; with nothing
/// to put back, or mid-merge — where `Abort the pull` is the way back — it
/// is not offered.
class ChangesMenuWidget extends ConsumerWidget {
  /// Creates the button and its menu.
  const ChangesMenuWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ChangesNotifier changes = ref.read(changesProvider.notifier);
    final int discardable = ref.watch(
      spaceSessionProvider.select(
        (SpaceSessionState? session) => session?.git?.discardable ?? 0,
      ),
    );
    final bool isMerging = ref.watch(
      spaceSessionProvider.select(
        (SpaceSessionState? session) => session?.merge?.inProgress ?? false,
      ),
    );
    return Padding(
      padding: const EdgeInsets.only(
        right: ChangesDesign.menuCentreRight - TomMenuButtonWidget.box / 2,
      ),
      child: _button(context, ref, changes, discardable, isMerging),
    );
  }

  Widget _button(
    BuildContext context,
    WidgetRef ref,
    ChangesNotifier changes,
    int discardable,
    bool isMerging,
  ) => TomMenuButtonWidget(
    tooltip: context.l10n.changesMenuTooltip,
    width: ChangesDesign.menuWidth,
    overhang: ChangesDesign.menuOverhang,
    groups: <List<TomMenuEntry>>[
      <TomMenuEntry>[
        TomMenuEntry(
          glyph: TomGlyphEnum.fetch,
          label: context.l10n.commonReload,
          // Git asked again, and the link's last word forgotten, so a column
          // that went unavailable for *no network* is offered again.
          onSelected: () {
            ref.read(remoteProvider.notifier).recheck();
            unawaited(ref.read(gitReadingProvider.notifier).refresh());
            // A login added with `gh auth login` meanwhile shows up here.
            unawaited(ref.read(accountProvider.notifier).reload());
          },
        ),
        TomMenuEntry(
          glyph: TomGlyphEnum.terminal,
          label: context.l10n.changesOpenInTerminal,
          onSelected: () => unawaited(changes.openTerminalHere()),
        ),
        TomMenuEntry(
          glyph: TomGlyphEnum.folderOpen,
          label: openRepositoryLabel(context.l10n),
          onSelected: () => unawaited(changes.revealRepository()),
        ),
      ],
      if (discardable > 0 && !isMerging)
        <TomMenuEntry>[
          TomMenuEntry(
            glyph: TomGlyphEnum.close,
            label: context.l10n.changesDiscardAll,
            isDestructive: true,
            onSelected: () =>
                unawaited(_confirmDiscard(context, ref, discardable)),
          ),
        ],
    ],
  );

  /// Asks before going back, and says how much goes.
  static Future<void> _confirmDiscard(
    BuildContext context,
    WidgetRef ref,
    int count,
  ) async {
    final AppLocalizations l10n = context.l10n;
    final bool? discard = await TomDialogWidget.show<bool>(
      context,
      title: l10n.changesDiscardAllQuestion,
      body: <String>[
        l10n.changesDiscardAllGoesBack(count),
        l10n.changesDiscardAllKeepsNew,
      ],
      actions: (void Function(bool) answer) => <TomDialogAction>[
        TomDialogAction(
          label: l10n.changesKeepTheChanges,
          onPressed: () => answer(false),
        ),
        TomDialogAction(
          label: l10n.changesDiscardAll,
          onPressed: () => answer(true),
          destructive: true,
        ),
      ],
    );
    // Dismissed without choosing is *do nothing*, never a default.
    if (discard ?? false) {
      await ref.read(changesProvider.notifier).discardAll();
    }
  }
}
