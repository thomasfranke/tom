/// The gear at the end of the top bar, and what it opens.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tom_desktop/l10n/l10n.dart';
import 'package:tom_desktop/screens/about/update_dot_widget.dart';
import 'package:tom_desktop/screens/preferences/preferences_design.dart';
import 'package:tom_desktop/screens/preferences/widgets/preferences_popover_widget.dart';
import 'package:tom_desktop/screens/workspace/workspace_design.dart';
import 'package:tom_ui/tom_ui.dart';

/// The preferences button, on every screen including Home
/// (`docs/product/preferences/the-popover/doc.md`).
///
/// **It hangs from the button's right edge**, because a control at the right
/// of a bar with a popover under its left edge lands off the window — the
/// same trap the branch switcher paid for.
///
/// **The button stays lit while the popover is open**, so pressing it again
/// closes it; clicking outside and `Esc` do the same, which is three ways
/// out and one of them visible.
class PreferencesControlWidget extends StatefulWidget {
  /// Creates the control.
  const PreferencesControlWidget({super.key});

  /// Popover top to the **bar's** bottom edge, not the button's — negative:
  /// the boards draw the card two *over* the bar, five under the ring
  /// (`design/screens/desktop/preferences/preferences-dark.svg`, card top at
  /// y 38 under a bar that ends at 40).
  static const double gap = -2;

  /// The popover's right edge past the button's: the boards hang the card
  /// under the ring, which sits two to the right of the glyph.
  static const double overhang = 2;

  /// The ring's side — the box's 24 and one more on each side.
  static const double ring = 26;

  /// Where it starts, from the box's left edge.
  static const double ringLeft = 1;

  /// How far it rises above the box's top.
  static const double ringOutset = 1;

  /// Its corner.
  static const double ringRadius = 6;

  /// The accent's share in its stroke, which the board draws at about half.
  static const double ringAlpha = 0.48;

  @override
  State<PreferencesControlWidget> createState() =>
      _PreferencesControlWidgetState();
}

class _PreferencesControlWidgetState extends State<PreferencesControlWidget> {
  final GlobalKey _button = GlobalKey();
  final OverlayPortalController _portal = OverlayPortalController();

  /// The button and the popover are one region, so pressing the button while
  /// it is open is a **toggle** and not a dismissal followed by a reopen.
  final Object _group = Object();

  bool _isOpen = false;

  void _toggle() {
    setState(() => _isOpen = !_isOpen);
    _isOpen ? _portal.show() : _portal.hide();
  }

  void _close() {
    if (!_isOpen) {
      return;
    }
    setState(() => _isOpen = false);
    _portal.hide();
  }

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    return OverlayPortal(
      controller: _portal,
      overlayChildBuilder: _popover,
      child: TapRegion(
        groupId: _group,
        child: Tooltip(
          message: context.l10n.preferencesTooltip,
          child: InkWell(
            key: _button,
            onTap: _toggle,
            borderRadius: BorderRadius.circular(WorkspaceDesign.toggleRadius),
            child: SizedBox.square(
              dimension: WorkspaceDesign.gearBox,
              child: Stack(
                alignment: Alignment.center,
                // The ring and the dot reach past the box, as the boards'.
                clipBehavior: Clip.none,
                children: <Widget>[
                  // Ringed while it is open — the selected face, so the way
                  // to close it is visible (`about-updates/an-update-is-waiting`).
                  if (_isOpen)
                    Positioned(
                      key: const Key('gearRing'),
                      left: PreferencesControlWidget.ringLeft,
                      top: -PreferencesControlWidget.ringOutset,
                      width: PreferencesControlWidget.ring,
                      height: PreferencesControlWidget.ring,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: colors.accent.withValues(
                              alpha: PreferencesControlWidget.ringAlpha,
                            ),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(
                            PreferencesControlWidget.ringRadius,
                          ),
                        ),
                      ),
                    ),
                  TomGlyphWidget(
                    glyph: TomGlyphEnum.preferences,
                    color: colors.textSecondary,
                    size: WorkspaceDesign.gear,
                    outline: true,
                  ),
                  // An update found at opening, said quietly.
                  const UpdateDotWidget(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// The popover, placed under the button's **right** edge.
  ///
  /// Measured rather than followed: a `CompositedTransformFollower` cannot
  /// hand a paint transform to anything that lays out inside it, and the
  /// language select is a `MenuAnchor` that needs one. The top bar does not
  /// scroll, so a position read once is a position that stays right.
  Widget _popover(BuildContext context) {
    final RenderBox? button =
        _button.currentContext?.findRenderObject() as RenderBox?;
    if (button == null) {
      return const SizedBox.shrink();
    }
    final Offset corner = button.localToGlobal(
      Offset(button.size.width, button.size.height),
    );
    const double underTheBar = TomMetrics.topBar + PreferencesControlWidget.gap;
    return Stack(
      children: <Widget>[
        Positioned(
          // Its **right** edge under the button's, because a popover hung
          // under the left edge of a control at the right of a bar lands off
          // the window (`docs/product/preferences/the-popover/doc.md`).
          left:
              corner.dx +
              PreferencesControlWidget.overhang -
              PreferencesDesign.width,
          top: underTheBar,
          child: TapRegion(
            groupId: _group,
            onTapOutside: (PointerDownEvent _) => _close(),
            child: CallbackShortcuts(
              bindings: <ShortcutActivator, VoidCallback>{
                const SingleActivator(LogicalKeyboardKey.escape): _close,
              },
              child: Focus(
                autofocus: true,
                child: PreferencesPopoverWidget(
                  tapGroup: _group,
                  onDismissed: _close,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<bool>('isOpen', _isOpen));
  }
}
