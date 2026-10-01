/// One space the menu offers going back to.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/screens/spaces/space_menu_design.dart';
import 'package:tom_desktop/widgets/home_relative_path.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// A recent space: its name over where it is, and a mark when it is the one
/// already open (`docs/product/workspace/leaving-a-space/doc.md`).
///
/// The open one stays in the list rather than being filtered out — a menu
/// whose contents change with what is open is a menu that moves under the
/// pointer.
class SpaceMenuRowWidget extends ConsumerWidget {
  /// Creates the row for [space].
  const SpaceMenuRowWidget({
    required this.space,
    required this.isOpen,
    required this.isBusy,
    super.key,
  });

  /// The space this row offers.
  final RecentSpaceEntity space;

  /// Whether it is the space on screen.
  final bool isOpen;

  /// Whether another one is being opened, which makes every row wait.
  final bool isBusy;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<RecentSpaceEntity>('space', space))
      ..add(DiagnosticsProperty<bool>('isOpen', isOpen))
      ..add(DiagnosticsProperty<bool>('isBusy', isBusy));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TomColors colors = TomColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: SpaceMenuDesign.rowGap),
      child: SpaceMenuTapWidget(
        // The space already open is a click on where you are, not an error.
        onTap: isOpen || isBusy
            ? null
            : () => unawaited(
                ref.read(spaceMenuProvider.notifier).switchTo(space),
              ),
        fill: isOpen ? colors.accentSoft : null,
        child: SizedBox(
          height: SpaceMenuDesign.rowHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: SpaceMenuDesign.rowPad,
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        space.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: SpaceMenuDesign.name,
                          height: 1.2,
                          fontWeight: isOpen
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: colors.textPrimary,
                        ),
                      ),
                      Text(
                        homeRelative(space.root),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: SpaceMenuDesign.path,
                          height: 1.4,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isOpen)
                  Text(
                    '✓',
                    style: TextStyle(
                      fontSize: SpaceMenuDesign.check,
                      fontWeight: FontWeight.w700,
                      color: colors.accent,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A row of the menu: the hover, the corner and the click.
class SpaceMenuTapWidget extends StatelessWidget {
  /// Wraps [child], calling [onTap] unless it is null.
  const SpaceMenuTapWidget({
    required this.child,
    required this.onTap,
    this.fill,
    super.key,
  });

  /// What the row draws.
  final Widget child;

  /// What clicking it does; null makes it inert rather than hiding it.
  final VoidCallback? onTap;

  /// The row's own background, for the one that is already open.
  final Color? fill;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(ObjectFlagProperty<VoidCallback?>.has('onTap', onTap))
      ..add(ColorProperty('fill', fill));
  }

  @override
  Widget build(BuildContext context) => Material(
    color: fill ?? Colors.transparent,
    borderRadius: BorderRadius.circular(SpaceMenuDesign.rowRadius),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(SpaceMenuDesign.rowRadius),
      child: child,
    ),
  );
}
