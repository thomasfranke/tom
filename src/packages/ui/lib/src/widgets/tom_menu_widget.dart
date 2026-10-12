/// A column's own menu: rows of actions, in groups.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tom_ui/src/theme/tom_colors.dart';
import 'package:tom_ui/src/widgets/tom_glyph_widget.dart';
import 'package:tom_ui/src/widgets/tom_rule_painter.dart';

/// One row of a [TomMenuWidget].
@immutable
final class TomMenuEntry {
  /// Creates the row [label], led by [glyph], doing [onSelected].
  const TomMenuEntry({
    required this.glyph,
    required this.label,
    required this.onSelected,
    this.detail,
    this.isDestructive = false,
  });

  /// The shape before the words.
  final TomGlyphEnum glyph;

  /// The words.
  final String label;

  /// Quieter words after [label], in a column of their own — a candidate's
  /// folder, where two rows share a name.
  final String? detail;

  /// What choosing it does; the menu closes first.
  final VoidCallback onSelected;

  /// Whether it loses work, which wears `removed` and sits in a group alone.
  final bool isDestructive;
}

/// The popover the `⋮` at the head of a column opens
/// ([explorer menu](../../../../../../docs/product/navigation/file-tree/explorer-menu/doc.md),
/// [git menu](../../../../../../docs/product/git-workflow/git-menu/doc.md)),
/// and the one an ambiguous wikilink opens
/// ([wikilinks](../../../../../../docs/product/wikilinks/doc.md)).
///
/// Rows of [rowHeight], a rule between groups, and a choice, a click outside
/// or Escape all close it — the boards' `explorer-menu` and `git-menu`.
class TomMenuWidget extends StatelessWidget {
  /// Creates the menu of [groups], [width] wide, calling [onDismissed] when
  /// it should go away.
  const TomMenuWidget({
    required this.groups,
    required this.width,
    required this.onDismissed,
    this.tapRegionGroupId,
    super.key,
  });

  /// The rows, a rule between each group.
  final List<List<TomMenuEntry>> groups;

  /// The menu's width; the boards draw the explorer's at 200, git's at 220.
  final double width;

  /// What to call to put the menu away.
  final VoidCallback onDismissed;

  /// Shared with the button that opens it, so pressing that button again
  /// closes the menu rather than closing and reopening it.
  final Object? tapRegionGroupId;

  /// A row, edge to edge.
  static const double rowHeight = 30;

  /// Above the first row and below the last.
  static const double pad = 6;

  /// A rule's band: the rule four points down it.
  static const double ruleBand = 9;

  /// The menu's corner.
  static const double radius = 8;

  /// The menu's edge to the centre of a row's glyph.
  static const double glyphCentre = 18;

  /// The menu's edge to a row's words.
  static const double labelLeft = 34;

  /// A row's glyph.
  static const double glyph = 12;

  /// A row's words.
  static const double text = 12.5;

  /// A row's words to its detail, at the least
  /// (the board `Ambiguous link`).
  static const double detailLeft = 70;

  /// A row's detail.
  static const double detailText = 11;

  /// The hover's inset from the menu's sides.
  static const double hoverInset = 4;

  /// The hover's corner.
  static const double hoverRadius = 6;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DoubleProperty('width', width))
      ..add(IterableProperty<List<TomMenuEntry>>('groups', groups))
      ..add(ObjectFlagProperty<VoidCallback>.has('onDismissed', onDismissed))
      ..add(DiagnosticsProperty<Object?>('tapRegionGroupId', tapRegionGroupId));
  }

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return TapRegion(
      groupId: tapRegionGroupId,
      onTapOutside: (PointerDownEvent _) => onDismissed(),
      child: CallbackShortcuts(
        bindings: <ShortcutActivator, VoidCallback>{
          const SingleActivator(LogicalKeyboardKey.escape): onDismissed,
        },
        child: _TakesFocusWidget(
          child: Container(
            width: width,
            padding: const EdgeInsets.symmetric(vertical: pad),
            decoration: BoxDecoration(
              color: colors.surfaceRaised,
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(color: colors.border),
              // The boards' own shadow, deeper in the dark; the light one
              // is authored at 18 % and renders as 36 % under the menu
              // (`#BBBAB7` against the app's `#CDCCC9` at 25 %).
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.36),
                  offset: const Offset(0, 8),
                  blurRadius: 24,
                ),
              ],
            ),
            child: Material(
              type: MaterialType.transparency,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  for (int g = 0; g < groups.length; g++) ...<Widget>[
                    if (g > 0)
                      SizedBox(
                        height: ruleBand,
                        // Centred, a point tall: four above and four below.
                        child: Center(child: TomRulePainter.of(colors.border)),
                      ),
                    for (final TomMenuEntry entry in groups[g])
                      _RowWidget(entry: entry, onDismissed: onDismissed),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RowWidget extends StatelessWidget {
  const _RowWidget({required this.entry, required this.onDismissed});

  final TomMenuEntry entry;
  final VoidCallback onDismissed;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<TomMenuEntry>('entry', entry))
      ..add(ObjectFlagProperty<VoidCallback>.has('onDismissed', onDismissed));
  }

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    final Text label = Text(
      entry.label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: TomMenuWidget.text,
        fontWeight: FontWeight.w500,
        color: entry.isDestructive ? colors.removed : colors.textPrimary,
      ),
    );
    final String? detail = entry.detail;
    // The hover is the boards' inset pill rather than a fill across the
    // whole row, so everything inside it is placed less the inset.
    const double inset = TomMenuWidget.hoverInset;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: inset),
      child: InkWell(
        borderRadius: BorderRadius.circular(TomMenuWidget.hoverRadius),
        hoverColor: colors.control,
        onTap: () {
          onDismissed();
          entry.onSelected();
        },
        child: SizedBox(
          height: TomMenuWidget.rowHeight,
          child: Stack(
            children: <Widget>[
              Positioned(
                left:
                    TomMenuWidget.glyphCentre -
                    TomMenuWidget.rowHeight / 2 -
                    inset,
                width: TomMenuWidget.rowHeight,
                top: 0,
                bottom: 0,
                child: Center(
                  child: TomGlyphWidget(
                    glyph: entry.glyph,
                    color: entry.isDestructive
                        ? colors.removed
                        : colors.textSecondary,
                    size: TomMenuWidget.glyph,
                  ),
                ),
              ),
              Positioned(
                left: TomMenuWidget.labelLeft - inset,
                right: 8 - inset,
                top: 0,
                bottom: 0,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: detail == null
                      ? label
                      : Row(
                          children: <Widget>[
                            // The detail starts at one column while the
                            // label is short, and after it when it is not.
                            ConstrainedBox(
                              constraints: const BoxConstraints(
                                minWidth: TomMenuWidget.detailLeft,
                                maxWidth: TomMenuWidget.detailLeft * 2,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: label,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                detail,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: TomMenuWidget.detailText,
                                  color: colors.textMuted,
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Takes the keyboard when it appears, so Escape reaches the menu.
///
/// Asked for, not `autofocus`: autofocus yields to anything already focused
/// in the scope — the editor, or the shell's own shortcut node — and the
/// menu then never hears Escape.
class _TakesFocusWidget extends StatefulWidget {
  const _TakesFocusWidget({required this.child});

  final Widget child;

  @override
  State<_TakesFocusWidget> createState() => _TakesFocusWidgetState();
}

class _TakesFocusWidgetState extends State<_TakesFocusWidget> {
  final FocusNode _node = FocusNode(debugLabel: 'menu');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _node.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _node.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      Focus(focusNode: _node, child: widget.child);
}
