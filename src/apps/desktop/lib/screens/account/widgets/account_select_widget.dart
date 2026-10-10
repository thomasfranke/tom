/// The GitHub account a repository is used with, and the menu of the rest.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tom_desktop/l10n/l10n.dart';
import 'package:tom_desktop/screens/account/account_design.dart';
import 'package:tom_desktop/screens/account/widgets/account_avatar_widget.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_ui/tom_ui.dart';

/// A select holding [chosen]; pressed, the machine's accounts open under it.
///
/// The menu is the accounts and nothing else: setting a login up is the
/// person's business with `gh`, `git` or `ssh`, never TOM's
/// (`docs/product/workspace/the-account/doc.md`).
class AccountSelectWidget extends StatefulWidget {
  /// Creates the select.
  const AccountSelectWidget({
    required this.accounts,
    required this.chosen,
    required this.onChoose,
    this.tapGroup,
    super.key,
  });

  /// Every account the machine holds.
  final List<GithubAccountValueObject> accounts;

  /// The one this repository is used with.
  final GithubAccountValueObject chosen;

  /// What choosing another does.
  final ValueChanged<GithubAccountValueObject> onChoose;

  /// The popover's tap region, which the menu joins so a choice is not a
  /// tap outside it.
  final Object? tapGroup;

  @override
  State<AccountSelectWidget> createState() => _AccountSelectWidgetState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(IterableProperty<GithubAccountValueObject>('accounts', accounts))
      ..add(DiagnosticsProperty<GithubAccountValueObject>('chosen', chosen))
      ..add(
        ObjectFlagProperty<ValueChanged<GithubAccountValueObject>>.has(
          'onChoose',
          onChoose,
        ),
      )
      ..add(DiagnosticsProperty<Object?>('tapGroup', tapGroup));
  }
}

class _AccountSelectWidgetState extends State<AccountSelectWidget> {
  final GlobalKey _select = GlobalKey();
  final OverlayPortalController _portal = OverlayPortalController();

  /// The select and its menu, so pressing the select while the menu is open
  /// closes it, and a press anywhere else in the popover does too.
  final Object _menuGroup = Object();

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
      overlayChildBuilder: _menu,
      child: TapRegion(
        groupId: _menuGroup,
        child: InkWell(
          key: _select,
          onTap: _toggle,
          borderRadius: BorderRadius.circular(AccountDesign.selectRadius),
          child: Container(
            height: AccountDesign.selectHeight,
            decoration: BoxDecoration(
              border: Border.all(
                color: _isOpen ? colors.accent : colors.borderStrong,
              ),
              borderRadius: BorderRadius.circular(AccountDesign.selectRadius),
            ),
            child: Row(
              children: <Widget>[
                Expanded(child: AccountRowWidget(account: widget.chosen)),
                TomGlyphWidget(
                  glyph: TomGlyphEnum.chevronDown,
                  color: colors.textSecondary,
                  size: AccountDesign.chevron,
                ),
                // The chevron's left edge 16 from the select's right, the
                // stroke Flutter draws inside the box taken off.
                const SizedBox(
                  width: AccountDesign.chevronInset - AccountDesign.chevron - 1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// The menu, 4 under the select and as wide.
  Widget _menu(BuildContext context) {
    final RenderBox? select =
        _select.currentContext?.findRenderObject() as RenderBox?;
    if (select == null) {
      return const SizedBox.shrink();
    }
    final Offset corner = select.localToGlobal(Offset(0, select.size.height));
    final TomColors colors = TomColors.of(context);
    return Stack(
      children: <Widget>[
        Positioned(
          left: corner.dx,
          top: corner.dy + AccountDesign.menuGap,
          width: select.size.width,
          child: TapRegion(
            groupId: widget.tapGroup,
            child: TapRegion(
              groupId: _menuGroup,
              onTapOutside: (PointerDownEvent _) => _close(),
              child: Material(
                color: colors.surfaceRaised,
                elevation: 8,
                borderRadius: BorderRadius.circular(AccountDesign.menuRadius),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: AccountDesign.menuPad - 1,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: colors.border),
                    borderRadius: BorderRadius.circular(
                      AccountDesign.menuRadius,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      for (final GithubAccountValueObject account
                          in widget.accounts)
                        _MenuRowWidget(
                          account: account,
                          isChosen: account == widget.chosen,
                          onPressed: () {
                            _close();
                            widget.onChoose(account);
                          },
                        ),
                    ],
                  ),
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

/// One account of the menu, the chosen one ticked and filled.
class _MenuRowWidget extends StatelessWidget {
  const _MenuRowWidget({
    required this.account,
    required this.isChosen,
    required this.onPressed,
  });

  final GithubAccountValueObject account;
  final bool isChosen;
  final VoidCallback onPressed;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<GithubAccountValueObject>('account', account))
      ..add(DiagnosticsProperty<bool>('isChosen', isChosen))
      ..add(ObjectFlagProperty<VoidCallback>.has('onPressed', onPressed));
  }

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    return InkWell(
      onTap: onPressed,
      hoverColor: colors.control,
      child: Container(
        height: AccountDesign.selectHeight,
        color: isChosen ? colors.control : null,
        child: Row(
          children: <Widget>[
            Expanded(child: AccountRowWidget(account: account)),
            // A tick, not the fill alone: colour is never the only signal.
            SizedBox.square(
              dimension: AccountDesign.chevronInset,
              child: isChosen
                  ? Center(
                      child: TomGlyphWidget(
                        glyph: TomGlyphEnum.check,
                        color: colors.added,
                        size: AccountDesign.tick,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: AccountDesign.avatarInset),
          ],
        ),
      ),
    );
  }
}

/// An account as the select and the menu draw it: its mark, `@login`, and
/// the tool it came from.
class AccountRowWidget extends StatelessWidget {
  /// Creates the row for [account].
  const AccountRowWidget({required this.account, super.key});

  /// Whose.
  final GithubAccountValueObject account;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      DiagnosticsProperty<GithubAccountValueObject>('account', account),
    );
  }

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    final AppLocalizations l10n = context.l10n;
    return Row(
      children: <Widget>[
        // Measured from the box's outer edge, the stroke taken off.
        const SizedBox(width: AccountDesign.avatarInset - 1),
        AccountAvatarWidget(
          initials: String.fromCharCode(
            account.login.runes.first,
          ).toUpperCase(),
          size: AccountDesign.avatar,
        ),
        const SizedBox(
          width:
              AccountDesign.loginInset -
              AccountDesign.avatarInset -
              AccountDesign.avatar,
        ),
        Flexible(
          child: Text(
            '@${account.login}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: AccountDesign.text,
              height: 1,
              fontWeight: FontWeight.w500,
              color: colors.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: AccountDesign.viaGap),
        Text(
          switch (account.source) {
            AccountSourceEnum.gh => l10n.accountViaGh,
            AccountSourceEnum.git => l10n.accountViaGit,
            AccountSourceEnum.ssh => l10n.accountViaSsh,
          },
          maxLines: 1,
          style: TextStyle(
            fontSize: AccountDesign.small,
            height: 1,
            color: colors.textMuted,
          ),
        ),
      ],
    );
  }
}
