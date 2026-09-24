/// The bar above everything: what space is open, and the global actions.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// The bar above everything: what space is open, and the global actions.
///
/// The design writes it `repository / folder`, because a space is a folder
/// and three checkouts all have a `docs/`. The folder is the emphasis and
/// the repository the context, which is what the two weights say.
///
/// The branch control beside it, with Fetch and Push, arrives with M1 — it
/// belongs to another product, and absent beats a control that cannot say
/// which branch this is.
class ShellTopBarWidget extends ConsumerWidget {
  /// Creates the top bar.
  const ShellTopBarWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SpaceSessionState? session = ref.watch(spaceSessionProvider);
    final TomColors colors = TomColors.of(context);
    return SizedBox(
      height: TomMetrics.topBar,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: TomMetrics.pad + TomMetrics.chromeInset,
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: session == null
              // Nothing, which is what the design draws with no space open —
              // and the shell only shows with one anyway.
              ? const SizedBox.shrink()
              : Row(
                  children: <Widget>[
                    Text(
                      SpaceEntity.nameOfFolder(session.space.repositoryRoot),
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                        color: colors.textSecondary,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text(
                        '/',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: colors.textMuted,
                        ),
                      ),
                    ),
                    Text(
                      session.space.name,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
