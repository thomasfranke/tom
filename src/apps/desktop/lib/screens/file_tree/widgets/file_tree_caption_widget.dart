/// What the left column is called, in the design's own words.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/l10n/l10n.dart';
import 'package:tom_desktop/screens/file_tree/file_tree_design.dart';
import 'package:tom_desktop/widgets/file_manager_words.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// The column's caption, drawn by the panel because the shell draws no chrome.
///
/// It says what is under it: the space while the tree is showing, the search
/// while its results are
/// (`docs/product/search/full-text-search/the-surface/doc.md`). The `+` is
/// the tree's, so it goes when the results come
/// (`docs/product/navigation/file-tree/new-document/doc.md`).
class FileTreeCaptionWidget extends ConsumerWidget {
  /// Creates the caption.
  const FileTreeCaptionWidget({this.searching = false, super.key});

  /// Whether the column is showing what a search found.
  final bool searching;

  /// The caption's line, which the `+` is centred on.
  static const double _line = FileTreeDesign.caption * 1.4;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<bool>('searching', searching));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TomColors colors = TomColors.of(context);
    // The column's whole width, or the `+` is placed from the caption's end.
    return SizedBox(
      width: double.infinity,
      height: _line,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: FileTreeDesign.captionLeft),
            child: Text(
              searching
                  ? context.l10n.fileTreeSearchCaption
                  : context.l10n.fileTreeExplorerCaption,
              style: TextStyle(
                fontSize: FileTreeDesign.caption,
                height: 1.4,
                letterSpacing: 0.8,
                fontWeight: FontWeight.w600,
                color: colors.textMuted,
              ),
            ),
          ),
          if (!searching)
            Positioned(
              right:
                  FileTreeDesign.newCentreRight -
                  FileTreeDesign.captionButton / 2,
              top: (_line - FileTreeDesign.captionButton) / 2,
              width: FileTreeDesign.captionButton,
              height: FileTreeDesign.captionButton,
              child: Tooltip(
                message: context.l10n.fileTreeNewDocument,
                child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    onTap: ref.read(fileTreeProvider.notifier).startNewDocument,
                    borderRadius: BorderRadius.circular(TomMetrics.radiusTight),
                    child: Center(
                      child: TomGlyphWidget(
                        glyph: TomGlyphEnum.plus,
                        color: colors.textMuted,
                        size: FileTreeDesign.newGlyph,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (!searching)
            Positioned(
              right:
                  FileTreeDesign.menuCentreRight - TomMenuButtonWidget.box / 2,
              top: (_line - TomMenuButtonWidget.box) / 2,
              child: TomMenuButtonWidget(
                tooltip: context.l10n.fileTreeMenu,
                width: FileTreeDesign.menuWidth,
                overhang: FileTreeDesign.menuOverhang,
                drop: FileTreeDesign.menuDrop,
                groups: _menu(
                  context.l10n,
                  ref.read(fileTreeProvider.notifier),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// `New folder`; `Collapse all` and `Reload`; then the file manager
  /// (`docs/product/navigation/file-tree/explorer-menu/doc.md`).
  static List<List<TomMenuEntry>> _menu(
    AppLocalizations l10n,
    FileTreeNotifier tree,
  ) => <List<TomMenuEntry>>[
    <TomMenuEntry>[
      TomMenuEntry(
        glyph: TomGlyphEnum.folder,
        label: l10n.fileTreeNewFolder,
        onSelected: tree.startNewFolder,
      ),
    ],
    <TomMenuEntry>[
      TomMenuEntry(
        glyph: TomGlyphEnum.chevronDown,
        label: l10n.fileTreeCollapseAll,
        onSelected: tree.collapseAll,
      ),
      TomMenuEntry(
        glyph: TomGlyphEnum.fetch,
        label: l10n.commonReload,
        onSelected: () => unawaited(tree.reload()),
      ),
    ],
    <TomMenuEntry>[
      TomMenuEntry(
        glyph: TomGlyphEnum.folderOpen,
        label: revealLabel(l10n),
        onSelected: () => unawaited(tree.revealSpace()),
      ),
    ],
  ];
}
