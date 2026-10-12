/// What a tab holding a binary file shows instead of its bytes.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/l10n/l10n.dart';
import 'package:tom_desktop/widgets/file_manager_words.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// One sentence and the way to the file, centred in the pane, rather than a
/// page of noise (`docs/product/git-workflow/commit/opening-a-change/doc.md`).
class EditorBinaryWidget extends ConsumerWidget {
  /// Creates the body.
  const EditorBinaryWidget({super.key});

  /// The sentence to the button under it.
  static const double gap = 12;

  /// The button, the git column's `Fetch` at the board's own width.
  static const Size button = Size(140, 30);

  /// The button's corner, the git column's.
  static const double radius = 6;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TomColors colors = TomColors.of(context);
    final AppLocalizations l10n = context.l10n;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            l10n.editorBinaryFile,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.3,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: gap),
          SizedBox.fromSize(
            size: button,
            child: OutlinedButton(
              onPressed: () =>
                  unawaited(ref.read(editorProvider.notifier).reveal()),
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.textPrimary,
                side: BorderSide(color: colors.borderStrong),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(radius),
                ),
                padding: EdgeInsets.zero,
              ),
              child: Text(
                revealLabel(l10n),
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.fade,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: colors.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
