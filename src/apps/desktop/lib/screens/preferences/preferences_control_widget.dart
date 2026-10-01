/// The gear at the end of the top bar, and what it opens.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  /// Popover top to the **bar's** bottom edge, not the button's.
  ///
  /// The button is a twenty-point glyph centred in a fifty-two-point bar, so
  /// hanging the card off it would put it inside the bar
  /// (`design/screens/desktop/preferences/preferences-light.svg` draws the
  /// card eight under the bar).
  static const double gap = 8;

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
          message: 'Preferences',
          child: InkWell(
            key: _button,
            onTap: _toggle,
            borderRadius: BorderRadius.circular(WorkspaceDesign.toggleRadius),
            child: TomGlyphWidget(
              glyph: TomGlyphEnum.preferences,
              // Lit while it is open: the way to close it must be visible.
              color: _isOpen ? colors.accent : colors.textSecondary,
              size: WorkspaceDesign.gear,
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
          left: corner.dx - PreferencesDesign.width,
          top: underTheBar,
          child: TapRegion(
            groupId: _group,
            onTapOutside: (PointerDownEvent _) => _close(),
            child: CallbackShortcuts(
              bindings: <ShortcutActivator, VoidCallback>{
                const SingleActivator(LogicalKeyboardKey.escape): _close,
              },
              child: const Focus(
                autofocus: true,
                child: PreferencesPopoverWidget(),
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
