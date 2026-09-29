/// The breadcrumb in the top bar, and the menu it opens.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/screens/spaces/space_menu_design.dart';
import 'package:tom_desktop/screens/spaces/widgets/space_menu_popover_widget.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// `repository / folder`, and the way out of the space
/// (`docs/product/workspace/leaving-a-space/doc.md`).
///
/// The breadcrumb is the control because it already names the space: a
/// second button in the bar would say the same thing twice. Repository and
/// folder both, because a space is a folder and three checkouts all have a
/// `docs/`.
class SpaceMenuControlWidget extends ConsumerStatefulWidget {
  /// Creates the breadcrumb.
  const SpaceMenuControlWidget({super.key});

  @override
  ConsumerState<SpaceMenuControlWidget> createState() =>
      _SpaceMenuControlWidgetState();
}

class _SpaceMenuControlWidgetState
    extends ConsumerState<SpaceMenuControlWidget> {
  final OverlayPortalController _portal = OverlayPortalController();
  final LayerLink _link = LayerLink();

  void _dismiss() {
    if (_portal.isShowing) {
      _portal.hide();
      ref.read(spaceMenuProvider.notifier).dismiss();
    }
  }

  void _toggle() {
    if (_portal.isShowing) {
      _dismiss();
      return;
    }
    _portal.show();
    ref.read(spaceMenuProvider.notifier).show();
  }

  @override
  Widget build(BuildContext context) {
    // The notifier closes the menu when it has left the space, so the window
    // never swaps with a surface still hanging over it.
    ref.listen<bool>(
      spaceMenuProvider.select((SpaceMenuState state) => state.isShowing),
      (bool? before, bool after) {
        if (!after && _portal.isShowing) {
          _portal.hide();
        }
      },
    );
    final SpaceEntity? space = ref.watch(
      spaceSessionProvider.select(
        (SpaceSessionState? session) => session?.space,
      ),
    );
    if (space == null) {
      return const SizedBox.shrink();
    }
    return CompositedTransformTarget(
      link: _link,
      child: OverlayPortal(
        controller: _portal,
        overlayChildBuilder: (BuildContext context) => Positioned(
          width: SpaceMenuDesign.width,
          child: CompositedTransformFollower(
            link: _link,
            targetAnchor: Alignment.bottomLeft,
            // Out and down: the menu's rows sit under the breadcrumb's own
            // text, which is why it starts further left than the control,
            // and the drop is measured from where the control sits in the
            // bar rather than from the bar's own edge.
            offset: const Offset(
              -SpaceMenuDesign.nudge,
              SpaceMenuDesign.top -
                  (TomMetrics.topBar + SpaceMenuDesign.controlHeight) / 2,
            ),
            child: SpaceMenuPopoverWidget(onDismissed: _dismiss),
          ),
        ),
        child: _TriggerWidget(space: space, onPressed: _toggle),
      ),
    );
  }
}

/// What the bar shows: the repository, the folder, and that there is a menu.
class _TriggerWidget extends StatelessWidget {
  const _TriggerWidget({required this.space, required this.onPressed});

  final SpaceEntity space;
  final VoidCallback onPressed;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<SpaceEntity>('space', space))
      ..add(ObjectFlagProperty<VoidCallback>.has('onPressed', onPressed));
  }

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(SpaceMenuDesign.rowRadius),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SizedBox(height: SpaceMenuDesign.controlHeight),
          // Both halves always, even when they are the same word: a space
          // opened at the repository's own root really is `notes / notes`,
          // and hiding one half would make the bar mean two different
          // things.
          _CrumbWidget(
            label: SpaceEntity.nameOfFolder(space.repositoryRoot),
            colour: colors.textSecondary,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              '/',
              style: TextStyle(
                fontSize: SpaceMenuDesign.crumb,
                height: 1.4,
                color: colors.textMuted,
              ),
            ),
          ),
          _CrumbWidget(label: space.name, colour: colors.textPrimary),
          const SizedBox(width: 2),
          TomChevronWidget(isOpen: true, color: colors.textMuted),
        ],
      ),
    );
  }
}

/// One half of the breadcrumb.
class _CrumbWidget extends StatelessWidget {
  const _CrumbWidget({required this.label, required this.colour});

  final String label;
  final Color colour;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('label', label))
      ..add(ColorProperty('colour', colour));
  }

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: TextStyle(
      fontSize: SpaceMenuDesign.crumb,
      height: 1.4,
      fontWeight: FontWeight.w600,
      color: colour,
    ),
  );
}
