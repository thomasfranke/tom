/// The bar above everything, on Home.
library;

import 'package:flutter/material.dart';
import 'package:tom_desktop/screens/account/account_control_widget.dart';
import 'package:tom_desktop/screens/preferences/preferences_control_widget.dart';
import 'package:tom_desktop/screens/workspace/workspace_design.dart';
import 'package:tom_ui/tom_ui.dart';

/// The bar above everything, carrying the preferences and the account.
///
/// Home has the same chrome as every screen, so opening a space changes what
/// is in the window and not its shape — and the gear is here because the
/// language is chosen before a space is open
/// (`docs/product/preferences/the-popover/doc.md`).
class HomeTopStripWidget extends StatelessWidget {
  /// Creates the strip.
  const HomeTopStripWidget({super.key});

  /// The account's right edge to the window's, the space's own top bar's
  /// number, so the two buttons sit where they do there.
  static const double rightEdge = 14;

  @override
  Widget build(BuildContext context) => const TomBarWidget(
    height: TomMetrics.topBar,
    child: Padding(
      padding: EdgeInsets.only(left: TomMetrics.barEdge, right: rightEdge),
      child: Align(
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            PreferencesControlWidget(),
            SizedBox(width: WorkspaceDesign.accountGap),
            // With no space open the popover is the machine's: who commits,
            // and the GitHub account, with no repository to speak of
            // (`docs/product/workspace/the-account/doc.md`).
            AccountControlWidget(),
          ],
        ),
      ),
    ),
  );
}
