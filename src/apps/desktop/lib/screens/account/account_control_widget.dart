/// The account button at the far right of the top bar, and what it opens.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/l10n/l10n.dart';
import 'package:tom_desktop/screens/account/account_design.dart';
import 'package:tom_desktop/screens/account/widgets/account_avatar_widget.dart';
import 'package:tom_desktop/screens/account/widgets/account_popover_widget.dart';
import 'package:tom_presentation/tom_presentation.dart';

/// The person behind the window: who commits, and as whom GitHub is reached
/// (`docs/product/workspace/the-account/doc.md`).
///
/// It hangs its popover from its right edge, for the gear's reason: a
/// control at the right of a bar drops its surface leftwards. It wears no
/// mark of its own while open.
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
    if (_isOpen) {
      _portal.show();
      // Where git asks first nothing was read by itself: opening is the ask.
      unawaited(ref.read(accountProvider.notifier).readIfUnread());
    } else {
      _portal.hide();
    }
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
    final String? initials = ref.watch(
      accountProvider.select((AccountState state) => state.initials),
    );
    final bool isUnread = ref.watch(
      accountProvider.select((AccountState state) => state.isUnread),
    );
    return OverlayPortal(
      controller: _portal,
      overlayChildBuilder: _popover,
      child: TapRegion(
        groupId: _group,
        child: Tooltip(
          message: isUnread
              ? context.l10n.accountTooltipUnread
              : context.l10n.accountTooltip,
          child: InkWell(
            key: _button,
            onTap: _toggle,
            customBorder: const CircleBorder(),
            // The disc is the whole button, open or not: the popover under
            // it is what says it is open.
            child: AccountAvatarWidget(
              initials: initials,
              size: AccountDesign.button,
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
