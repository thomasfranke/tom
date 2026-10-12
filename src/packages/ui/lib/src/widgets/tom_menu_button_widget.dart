/// The `⋮` at the head of a column, and the menu it opens.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tom_ui/src/theme/tom_colors.dart';
import 'package:tom_ui/src/theme/tom_metrics.dart';
import 'package:tom_ui/src/widgets/tom_glyph_widget.dart';
import 'package:tom_ui/src/widgets/tom_menu_widget.dart';

/// A [box]-square `⋮` that hangs a [TomMenuWidget] of [groups] from its
/// right, [overhang] past the glyph's centre — a control at the right of a
/// column opens leftwards, or it lands off the window.
class TomMenuButtonWidget extends StatefulWidget {
  /// Creates the button, [tooltip] naming the menu.
  const TomMenuButtonWidget({
    required this.tooltip,
    required this.groups,
    required this.width,
    this.overhang = 5,
    this.drop = defaultDrop,
    super.key,
  });

  /// The menu's name, for whoever does not read the shape.
  final String tooltip;

  /// The menu's rows, a rule between each group.
  final List<List<TomMenuEntry>> groups;

  /// The menu's width.
  final double width;

  /// How far the menu's right edge runs past the glyph's centre.
  final double overhang;

  /// The button's square, centred on its glyph.
  static const double box = 20;

  /// The glyph; its ink is the boards' ten points.
  static const double glyph = 12;

  /// How far the menu hangs below the button when a column says nothing:
  /// the git column's board.
  static const double defaultDrop = 1.5;

  /// The button's bottom to the menu's top; the explorer's board hangs it
  /// straight from the button, so its rules land on whole pixels.
  final double drop;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('tooltip', tooltip))
      ..add(IterableProperty<List<TomMenuEntry>>('groups', groups))
      ..add(DoubleProperty('width', width))
      ..add(DoubleProperty('overhang', overhang))
      ..add(DoubleProperty('drop', drop));
  }

  @override
  State<TomMenuButtonWidget> createState() => _TomMenuButtonWidgetState();
}

class _TomMenuButtonWidgetState extends State<TomMenuButtonWidget> {
  final OverlayPortalController _portal = OverlayPortalController();
  final LayerLink _link = LayerLink();

  /// Shared by the button and the menu, so pressing the button while the
  /// menu is open closes it instead of closing and reopening it.
  final Object _group = Object();

  void _toggle() => setState(_portal.toggle);

  void _dismiss() {
    if (_portal.isShowing) {
      setState(_portal.hide);
    }
  }

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    return CompositedTransformTarget(
      link: _link,
      child: OverlayPortal(
        controller: _portal,
        overlayChildBuilder: (BuildContext context) => Positioned(
          width: widget.width,
          child: CompositedTransformFollower(
            link: _link,
            targetAnchor: Alignment.bottomRight,
            followerAnchor: Alignment.topRight,
            offset: Offset(
              widget.overhang - TomMenuButtonWidget.box / 2,
              widget.drop,
            ),
            child: Align(
              alignment: Alignment.topRight,
              child: TomMenuWidget(
                groups: widget.groups,
                width: widget.width,
                onDismissed: _dismiss,
                tapRegionGroupId: _group,
              ),
            ),
          ),
        ),
        child: TapRegion(
          groupId: _group,
          child: Tooltip(
            message: widget.tooltip,
            child: SizedBox.square(
              dimension: TomMenuButtonWidget.box,
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  onTap: _toggle,
                  borderRadius: BorderRadius.circular(TomMetrics.radiusTight),
                  child: Center(
                    child: TomGlyphWidget(
                      glyph: TomGlyphEnum.menu,
                      color: _portal.isShowing
                          ? colors.textPrimary
                          : colors.textMuted,
                      size: TomMenuButtonWidget.glyph,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
