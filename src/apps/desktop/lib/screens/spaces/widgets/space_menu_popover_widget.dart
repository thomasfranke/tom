/// The surface the breadcrumb opens.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/l10n/l10n.dart';
import 'package:tom_desktop/screens/spaces/space_menu_design.dart';
import 'package:tom_desktop/screens/spaces/widgets/space_menu_row_widget.dart';
import 'package:tom_desktop/screens/spaces/widgets/space_menu_unsaved_widget.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// Recent spaces, or the question about the buffer first
/// (`docs/product/workspace/leaving-a-space/doc.md`).
///
/// Two faces, one surface, and which is drawn is the state's to say — the
/// home button beside the breadcrumb raises the question here too. Closing
/// it is *stay*: no departure is left standing behind a surface nobody sees.
class SpaceMenuPopoverWidget extends ConsumerWidget {
  /// Creates the surface, calling [onDismissed] when it should go away.
  const SpaceMenuPopoverWidget({required this.onDismissed, super.key});

  /// What to call to put the surface away.
  final VoidCallback onDismissed;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      ObjectFlagProperty<VoidCallback>.has('onDismissed', onDismissed),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TomColors colors = TomColors.of(context);
    return TapRegion(
      onTapOutside: (PointerDownEvent _) => onDismissed(),
      child: CallbackShortcuts(
        bindings: <ShortcutActivator, VoidCallback>{
          const SingleActivator(LogicalKeyboardKey.escape): onDismissed,
        },
        child: Material(
          color: colors.surfaceRaised,
          elevation: 8,
          borderRadius: BorderRadius.circular(SpaceMenuDesign.radius),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: colors.border),
              borderRadius: BorderRadius.circular(SpaceMenuDesign.radius),
            ),
            padding: const EdgeInsets.all(SpaceMenuDesign.pad),
            child: const _ContentsWidget(),
          ),
        ),
      ),
    );
  }
}

/// The list, or the question standing in front of it.
class _ContentsWidget extends ConsumerWidget {
  const _ContentsWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SpaceMenuState state = ref.watch(spaceMenuProvider);
    if (state.pending != null) {
      return const SpaceMenuUnsavedWidget();
    }
    final String? openRoot = ref.watch(
      spaceSessionProvider.select(
        (SpaceSessionState? session) => session?.space.root,
      ),
    );
    final TomColors colors = TomColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (state.recents.isNotEmpty) ...<Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              SpaceMenuDesign.rowPad,
              SpaceMenuDesign.captionTop - SpaceMenuDesign.pad,
              SpaceMenuDesign.rowPad,
              SpaceMenuDesign.captionGap,
            ),
            child: Text(
              context.l10n.spacesRecentSpaces,
              style: TextStyle(
                fontSize: SpaceMenuDesign.caption,
                height: 1.4,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
                color: colors.textMuted,
              ),
            ),
          ),
          for (final RecentSpaceEntity each in state.recents)
            SpaceMenuRowWidget(
              space: each,
              isOpen: each.root == openRoot,
              isBusy: state.isBusy,
            ),
        ],
        // Said where the row that failed is, because the space on screen
        // never closed and there is no other surface to say it on.
        if (state.unopened case final RecentSpaceEntity unopened)
          Padding(
            padding: const EdgeInsets.all(SpaceMenuDesign.rowPad),
            child: Text(
              context.l10n.spacesUnopened(unopened.name),
              style: TextStyle(
                fontSize: SpaceMenuDesign.path,
                height: 1.4,
                color: colors.removed,
              ),
            ),
          ),
      ],
    );
  }
}
