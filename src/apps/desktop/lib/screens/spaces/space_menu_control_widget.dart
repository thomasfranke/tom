/// The breadcrumb in the top bar, the menu it opens, and the way home.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/l10n/l10n.dart';
import 'package:tom_desktop/screens/spaces/space_menu_design.dart';
import 'package:tom_desktop/screens/spaces/widgets/space_menu_popover_widget.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// A home button, then `repository / folder`
/// (`docs/product/workspace/leaving-a-space/doc.md`).
///
/// The button is the way out and the breadcrumb is the way across: one
/// press to the opening screen, one menu for the spaces that were open
/// before. Repository and folder both, because a space is a folder and three
/// checkouts all have a `docs/`.
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
    // The second listener is the home button's: it asks about an unsaved
    // buffer through the menu's own surface, so a question appearing opens
    // it — and `stay` on a menu nobody opened closes it again, rather than
    // leaving the list where a question was.
    ref
      ..listen<bool>(
        spaceMenuProvider.select((SpaceMenuState state) => state.isShowing),
        (bool? before, bool after) {
          if (!after && _portal.isShowing) {
            _portal.hide();
          }
        },
      )
      ..listen<SpaceDeparture?>(
        spaceMenuProvider.select((SpaceMenuState state) => state.pending),
        (SpaceDeparture? before, SpaceDeparture? after) {
          if (after != null && !_portal.isShowing) {
            _portal.show();
          } else if (after == null &&
              _portal.isShowing &&
              !ref.read(spaceMenuProvider).isShowing) {
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _HomeWidget(
          onPressed: () =>
              unawaited(ref.read(spaceMenuProvider.notifier).close()),
        ),
        const SizedBox(width: SpaceMenuDesign.homeGap),
        CompositedTransformTarget(
          link: _link,
          child: OverlayPortal(
            controller: _portal,
            overlayChildBuilder: (BuildContext context) => Positioned(
              width: SpaceMenuDesign.width,
              child: CompositedTransformFollower(
                link: _link,
                targetAnchor: Alignment.bottomLeft,
                // Out and down: the menu's rows sit under the breadcrumb's
                // own text, which is why it starts further left than the
                // control, and the drop is measured from where the control
                // sits in the bar rather than from the bar's own edge.
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
        ),
      ],
    );
  }
}

/// The way out: one press to the opening screen.
///
/// A glyph before the breadcrumb rather than a row at the foot of its menu,
/// because leaving is the one thing somebody does without choosing among
/// spaces first. Its words stay in the tooltip, so the vocabulary is the
/// doc's.
class _HomeWidget extends StatelessWidget {
  const _HomeWidget({required this.onPressed});

  final VoidCallback onPressed;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      ObjectFlagProperty<VoidCallback>.has('onPressed', onPressed),
    );
  }

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    return Tooltip(
      message: context.l10n.spacesCloseSpace,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(SpaceMenuDesign.rowRadius),
        child: SizedBox(
          width: SpaceMenuDesign.homeWidth,
          height: SpaceMenuDesign.controlHeight,
          // The gear's ink and line, so the bar's two ends read as one set.
          child: Center(
            child: TomGlyphWidget(
              glyph: TomGlyphEnum.home,
              color: colors.textSecondary,
              outline: true,
            ),
          ),
        ),
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
          // Both halves whenever there is a repository, even when they are
          // the same word: a space opened at the repository's own root really
          // is `notes / notes`. With none, the repository's half is git's
          // answer and goes (`workspace/without-a-repository/doc.md`).
          if (space.repositoryRoot case final String repository) ...<Widget>[
            _CrumbWidget(
              label: SpaceEntity.nameOfFolder(repository),
              colour: colors.textMuted,
              weight: FontWeight.w500,
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
          ],
          _CrumbWidget(
            label: space.name,
            colour: colors.textPrimary,
            weight: FontWeight.w600,
          ),
          const SizedBox(width: 6),
          TomChevronWidget(isOpen: true, color: colors.textMuted, size: 10),
        ],
      ),
    );
  }
}

/// One half of the breadcrumb.
class _CrumbWidget extends StatelessWidget {
  const _CrumbWidget({
    required this.label,
    required this.colour,
    required this.weight,
  });

  final String label;
  final Color colour;
  final FontWeight weight;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('label', label))
      ..add(ColorProperty('colour', colour))
      ..add(DiagnosticsProperty<FontWeight>('weight', weight));
  }

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: TextStyle(
      fontSize: SpaceMenuDesign.crumb,
      height: 1.4,
      fontWeight: weight,
      color: colour,
    ),
  );
}
