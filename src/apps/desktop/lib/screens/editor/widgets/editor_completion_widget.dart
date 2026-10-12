/// What `[[` offers under the caret.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tom_desktop/l10n/l10n.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_ui/tom_ui.dart';

/// The documents a wikilink being typed could become, and how to choose
/// (`docs/product/wikilinks/doc.md`,
/// board `editor-links-export/linking-a-document`).
///
/// A list in the menu's own box — its corner, edge and shadow — with the
/// chosen row tinted `accent_soft`, and the keys spelled out under it.
class EditorCompletionWidget extends StatelessWidget {
  /// Creates the list of [candidates], [chosen] tinted, calling [onChoose]
  /// with the row clicked.
  const EditorCompletionWidget({
    required this.candidates,
    required this.chosen,
    required this.onChoose,
    super.key,
  });

  /// The rows, best first; never more than [maxRows].
  final List<WikilinkCandidateValueObject> candidates;

  /// The row Enter would insert.
  final int chosen;

  /// What clicking a row does.
  final ValueChanged<int> onChoose;

  /// The list's width.
  static const double width = 300;

  /// The list's edge to a row, every side.
  static const double inset = 6;

  /// A row's corner, inside the list's.
  static const double rowRadius = 6;

  /// A row's edge to its document's name.
  static const double nameLeft = 12;

  /// A row's edge to the end of its folder.
  static const double folderRight = 6;

  /// The line under the `[[` to the list's top edge.
  static const double drop = 6;

  /// The list's foot to the line of keys under it.
  static const double hintGap = 8;

  /// The most rows offered; typing more narrows the rest.
  static const int maxRows = 8;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        IterableProperty<WikilinkCandidateValueObject>(
          'candidates',
          candidates,
        ),
      )
      ..add(IntProperty('chosen', chosen))
      ..add(ObjectFlagProperty<ValueChanged<int>>.has('onChoose', onChoose));
  }

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    // A material of its own: the overlay is under none, and text there
    // would wear the framework's missing-material underline.
    return Material(
      type: MaterialType.transparency,
      child: _list(context.l10n, colors, isDark),
    );
  }

  Widget _list(AppLocalizations l10n, TomColors colors, bool isDark) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Container(
        width: width,
        padding: const EdgeInsets.all(inset),
        decoration: BoxDecoration(
          color: colors.surfaceRaised,
          borderRadius: BorderRadius.circular(TomMenuWidget.radius),
          border: Border.all(color: colors.border),
          // The menu's shadow, deeper in the dark.
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.18),
              offset: const Offset(0, 8),
              blurRadius: 24,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            for (int at = 0; at < candidates.length; at++)
              _RowWidget(
                candidate: candidates[at],
                isChosen: at == chosen,
                onTap: () => onChoose(at),
              ),
          ],
        ),
      ),
      const SizedBox(height: hintGap),
      // The keys, as the board spells them.
      Text(
        l10n.editorCompletionHint,
        style: TextStyle(
          fontFamily: TomFonts.sans,
          fontSize: 10.5,
          height: 1,
          color: colors.textMuted,
        ),
      ),
    ],
  );
}

class _RowWidget extends StatelessWidget {
  const _RowWidget({
    required this.candidate,
    required this.isChosen,
    required this.onTap,
  });

  final WikilinkCandidateValueObject candidate;
  final bool isChosen;
  final VoidCallback onTap;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        DiagnosticsProperty<WikilinkCandidateValueObject>(
          'candidate',
          candidate,
        ),
      )
      ..add(DiagnosticsProperty<bool>('isChosen', isChosen))
      ..add(ObjectFlagProperty<VoidCallback>.has('onTap', onTap));
  }

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    final String path = candidate.path.value;
    final int slash = path.lastIndexOf('/');
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: TomMenuWidget.rowHeight,
          padding: const EdgeInsets.only(
            left: EditorCompletionWidget.nameLeft,
            right: EditorCompletionWidget.folderRight,
          ),
          decoration: BoxDecoration(
            color: isChosen ? colors.accentSoft : Colors.transparent,
            borderRadius: BorderRadius.circular(
              EditorCompletionWidget.rowRadius,
            ),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  path.substring(slash + 1),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: TomFonts.sans,
                    fontSize: TomMenuWidget.text,
                    height: 1,
                    fontWeight: isChosen ? FontWeight.w600 : FontWeight.w500,
                    color: isChosen ? colors.accent : colors.textPrimary,
                  ),
                ),
              ),
              if (slash > 0)
                Text(
                  path.substring(0, slash),
                  maxLines: 1,
                  style: TextStyle(
                    fontFamily: TomFonts.sans,
                    fontSize: 11,
                    height: 1,
                    color: colors.textMuted,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
