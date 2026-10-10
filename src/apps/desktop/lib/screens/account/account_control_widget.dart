/// The account button at the far right of the top bar, and what it opens.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/l10n/l10n.dart';
import 'package:tom_desktop/screens/account/account_design.dart';
import 'package:tom_desktop/screens/account/widgets/account_avatar_widget.dart';
import 'package:tom_desktop/screens/account/widgets/account_popover_widget.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// The person behind the window: who commits, and as whom GitHub is reached
/// (`docs/product/workspace/the-account/doc.md`).
///
/// It hangs its popover from its right edge and wears an `accent` ring while
/// it is open, the way the gear does, for the gear's reason: a control at
/// the right of a bar drops its surface leftwards, and the way to close it
/// must be visible.
class AccountControlWidget extends ConsumerStatefulWidget {
  /// Creates the control.
  const AccountControlWidget({super.key});

  @override
  ConsumerState<AccountControlWidget> createState() =>
      _AccountControlWidgetState();
}

class _AccountControlWidgetState extends ConsumerState<AccountControlWidget> {
  final GlobalKey _button = GlobalKey();
  final OverlayPortalController _portal = OverlayPortalController();

  /// The button and the popover are one region, so pressing the button while
  /// it is open closes it rather than closing and reopening it.
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
    final String? initials = ref.watch(
      accountProvider.select((AccountState state) => state.initials),
    );
    return OverlayPortal(
      controller: _portal,
      overlayChildBuilder: _popover,
      child: TapRegion(
        groupId: _group,
        child: Tooltip(
          message: context.l10n.accountTooltip,
          child: InkWell(
            key: _button,
            onTap: _toggle,
            customBorder: const CircleBorder(),
            child: Container(
              width: AccountDesign.button,
              height: AccountDesign.button,
              alignment: Alignment.center,
              // The ring is drawn whether or not it shows, so opening the
              // popover does not move the circle inside it.
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _isOpen ? colors.accent : Colors.transparent,
                ),
              ),
              child: AccountAvatarWidget(
                initials: initials,
                size: AccountDesign.button - AccountDesign.ring * 2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// The popover, its right edge under the button's.
  Widget _popover(BuildContext context) {
    final RenderBox? button =
        _button.currentContext?.findRenderObject() as RenderBox?;
    if (button == null) {
      return const SizedBox.shrink();
    }
    final Offset corner = button.localToGlobal(
      Offset(button.size.width, button.size.height),
    );
    return Stack(
      children: <Widget>[
        Positioned(
          left: corner.dx + AccountDesign.overhang - AccountDesign.width,
          top: corner.dy + AccountDesign.gap,
          child: TapRegion(
            groupId: _group,
            onTapOutside: (PointerDownEvent _) => _close(),
            child: CallbackShortcuts(
              bindings: <ShortcutActivator, VoidCallback>{
                const SingleActivator(LogicalKeyboardKey.escape): _close,
              },
              child: Focus(
                autofocus: true,
                child: AccountPopoverWidget(tapGroup: _group),
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
