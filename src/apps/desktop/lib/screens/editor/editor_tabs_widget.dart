/// The documents that are open, and which of them is on screen.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/l10n/l10n.dart';
import 'package:tom_desktop/screens/export/save_location_picker.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// The numbers of the boards' tab strip
/// (`design/screens/desktop/editor/merged-rows-dark.svg`).
abstract final class EditorTabsDesign {
  /// The strip, the rule under it included.
  static const double height = 35;

  /// A tab's left edge to its glyph.
  static const double glyphLeft = 16;

  /// The document glyph.
  static const double glyph = 12;

  /// The glyph to the name: the name sits 33 from the tab's edge.
  static const double glyphGap = 5;

  /// The name to the close's box.
  static const double closeGap = 20.5;

  /// The close's box, or the unsaved dot's.
  static const double closeBox = 14;

  /// The close's box to the tab's right edge.
  static const double right = 10;

  /// The `✕`.
  static const double closeGlyph = 10;

  /// The unsaved dot.
  static const double dot = 7;

  /// The marker on the chosen tab's top edge.
  static const double marker = 2;

  /// A tab's name.
  static const double label = 12.5;

  /// The tab's menu.
  static const double menuWidth = 220;
}

/// The row of tabs at the head of the document area
/// (`docs/product/editor/tabs/doc.md`).
///
/// The chosen tab meets the row under it with no line between them, wears
/// the island's own fill and a marker on its top edge. A tab in preview is
/// italic; an unsaved one carries a dot where its close would be. **A tab
/// never shrinks** — with more open than fit, the strip scrolls.
class EditorTabsWidget extends ConsumerWidget {
  /// Creates the strip.
  const EditorTabsWidget({super.key});

  /// Closes [path]'s tab, asking first when it holds edits the disk does not
  /// have. The keyboard's way in, since an unsaved tab draws no close.
  static Future<void> close(
    BuildContext context,
    WidgetRef ref,
    DocumentTab path,
  ) async {
    final SpaceSessionNotifier session = ref.read(
      spaceSessionProvider.notifier,
    );
    if (!ref.read(unsavedDocumentsProvider).contains(path)) {
      ref.read(heldBuffersProvider.notifier).drop(path);
      session.closeTab(path);
      return;
    }
    final String name = path.name;
    final AppLocalizations l10n = context.l10n;
    final _Closing? answer = await TomDialogWidget.show<_Closing>(
      context,
      title: l10n.commonHasUnsavedChanges(name),
      body: <String>[l10n.editorCloseTabDiscards, l10n.editorCloseTabDiskKept],
      actions: (void Function(_Closing) answer) => <TomDialogAction>[
        TomDialogAction(
          label: l10n.commonSaveAndClose,
          onPressed: () => answer(_Closing.save),
        ),
        TomDialogAction(
          label: l10n.commonDiscardAndClose,
          onPressed: () => answer(_Closing.discard),
          destructive: true,
        ),
        TomDialogAction(
          label: l10n.editorKeepTabOpen,
          onPressed: () => answer(_Closing.keep),
        ),
      ],
    );
    switch (answer) {
      case _Closing.save:
        // Only the tab on screen can be saved from here; the shortcut only
        // ever closes that one.
        await ref.read(editorProvider.notifier).save();
        if (ref.read(unsavedDocumentsProvider).contains(path)) {
          return;
        }
        session.closeTab(path);
      case _Closing.discard:
        ref.read(heldBuffersProvider.notifier).drop(path);
        session.closeTab(path);
      case _Closing.keep || null:
        return;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TomColors colors = TomColors.of(context);
    final ({
      List<DocumentTab> tabs,
      DocumentTab? open,
      DocumentTab? preview,
      SpaceRelativePathValueObject? preferencesFile,
      DocumentTab? preferences,
      bool showingPreferences,
    })
    strip = ref.watch(
      spaceSessionProvider.select(
        (SpaceSessionState? session) => (
          tabs: session?.tabs ?? const <DocumentTab>[],
          open: session?.onScreen,
          preview: session?.previewTab,
          preferencesFile: session?.preferencesFile,
          preferences: session?.preferencesTab,
          showingPreferences: session?.isShowingPreferencesFile ?? false,
        ),
      ),
    );
    final SpaceSessionNotifier session = ref.read(
      spaceSessionProvider.notifier,
    );
    final Set<DocumentTab> unsaved = ref.watch(unsavedDocumentsProvider);
    final Set<DocumentTab> deleted = ref.watch(deletedDocumentsProvider);
    return Container(
      height: EditorTabsDesign.height,
      decoration: BoxDecoration(
        color: colors.surfaceSunken,
        border: Border(bottom: BorderSide(color: colors.border)),
      ),
      // From the strip's left edge: a scroll view narrower than the strip is
      // otherwise centred in it.
      alignment: Alignment.topLeft,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            for (final DocumentTab tab in strip.tabs)
              _TabWidget(
                path: tab,
                isChosen: tab == strip.open,
                isPreview: tab == strip.preview,
                isUnsaved: unsaved.contains(tab),
                isDeleted: deleted.contains(tab),
              ),
            // A file from outside the tree, after the space's own: no
            // preview, no export, the way out of any tab
            // (`docs/product/preferences/where-it-is-stored/doc.md`).
            if ((strip.preferencesFile, strip.preferences) case (
              final SpaceRelativePathValueObject file,
              final DocumentTab tab,
            ))
              _TabWidget(
                path: tab,
                isChosen: strip.showingPreferences,
                isPreview: false,
                isUnsaved: unsaved.contains(tab),
                onChoose: () => session.openPreferencesFile(file),
              ),
          ],
        ),
      ),
    );
  }
}

/// The last click on a tab, so the next one can tell it is the second.
({DocumentTab path, DateTime at})? _lastTap;

/// What the question about an unsaved tab was answered with.
enum _Closing { save, discard, keep }

/// One tab: glyph, name, and its close or its unsaved dot.
class _TabWidget extends ConsumerWidget {
  const _TabWidget({
    required this.path,
    required this.isChosen,
    required this.isPreview,
    required this.isUnsaved,
    this.isDeleted = false,
    this.onChoose,
  });

  final DocumentTab path;
  final bool isChosen;
  final bool isPreview;
  final bool isUnsaved;

  /// Whether the file is gone from the disk: the name struck through, then
  /// `(deleted)`, all of it in `removed` — VS Code's reading, with no band
  /// (`docs/product/git-workflow/commit/opening-a-change/doc.md`).
  final bool isDeleted;

  /// What a click does when the tab is not a document of the space, which
  /// has no preview to keep and no export in its menu; null for a document.
  final VoidCallback? onChoose;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<DocumentTab>('path', path))
      ..add(DiagnosticsProperty<bool>('isChosen', isChosen))
      ..add(DiagnosticsProperty<bool>('isPreview', isPreview))
      ..add(DiagnosticsProperty<bool>('isUnsaved', isUnsaved))
      ..add(DiagnosticsProperty<bool>('isDeleted', isDeleted))
      ..add(ObjectFlagProperty<VoidCallback?>.has('onChoose', onChoose));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TomColors colors = TomColors.of(context);
    final SpaceSessionNotifier session = ref.read(
      spaceSessionProvider.notifier,
    );
    final Widget tab = Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const SizedBox(width: EditorTabsDesign.glyphLeft),
        TomGlyphWidget(
          glyph: TomGlyphEnum.file,
          color: isChosen ? colors.accent : colors.textMuted,
          size: EditorTabsDesign.glyph,
        ),
        const SizedBox(width: EditorTabsDesign.glyphGap),
        Text.rich(
          TextSpan(
            children: <InlineSpan>[
              TextSpan(
                text: path.name,
                style: isDeleted
                    ? const TextStyle(decoration: TextDecoration.lineThrough)
                    : null,
              ),
              if (isDeleted)
                TextSpan(text: ' ${context.l10n.editorTabDeleted}'),
            ],
          ),
          maxLines: 1,
          style: TextStyle(
            fontSize: EditorTabsDesign.label,
            height: 1.4,
            fontWeight: isChosen ? FontWeight.w500 : FontWeight.w400,
            fontStyle: isPreview ? FontStyle.italic : FontStyle.normal,
            color: isDeleted
                ? colors.removed
                : isChosen
                ? colors.textPrimary
                : colors.textMuted,
            decorationColor: colors.removed,
          ),
        ),
        const SizedBox(width: EditorTabsDesign.closeGap),
        SizedBox.square(
          dimension: EditorTabsDesign.closeBox,
          // The dot takes the close's place: nothing in the strip discards
          // work with one stray click.
          child: isUnsaved
              ? Center(
                  child: Container(
                    width: EditorTabsDesign.dot,
                    height: EditorTabsDesign.dot,
                    decoration: BoxDecoration(
                      color: colors.textSecondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                )
              : Tooltip(
                  message: context.l10n.editorCloseTabTooltip,
                  child: InkWell(
                    onTap: () =>
                        unawaited(EditorTabsWidget.close(context, ref, path)),
                    borderRadius: BorderRadius.circular(TomMetrics.radiusTight),
                    child: Center(
                      child: TomGlyphWidget(
                        glyph: TomGlyphEnum.close,
                        color: isChosen
                            ? colors.textSecondary
                            : colors.textMuted,
                        size: EditorTabsDesign.closeGlyph,
                      ),
                    ),
                  ),
                ),
        ),
        const SizedBox(width: EditorTabsDesign.right),
      ],
    );
    final VoidCallback? choose = onChoose;
    return GestureDetector(
      // The tab's own menu, where an export is asked for
      // (`docs/product/export/doc.md`); the preferences file has none.
      onSecondaryTapUp: choose == null
          ? (TapUpDetails details) =>
                _openMenu(context, ref, details.globalPosition)
          : null,
      // A double click keeps a tab opened in preview. Timed here rather than
      // with `onDoubleTap`, which would hold every single click back.
      onTap: () {
        if (choose != null) {
          choose();
          return;
        }
        final DateTime now = DateTime.now();
        final bool isSecond =
            _lastTap?.path == path &&
            now.difference(_lastTap!.at) < kDoubleTapTimeout;
        _lastTap = (path: path, at: now);
        session.choose(path);
        if (isSecond) {
          session.keep(path);
        }
      },
      child: Container(
        // The chosen tab runs over the strip's rule, which is the join that
        // says it *is* the document under it.
        height: isChosen
            ? EditorTabsDesign.height
            : EditorTabsDesign.height - 1,
        decoration: BoxDecoration(
          color: isChosen ? colors.surfaceRaised : null,
          border: isChosen
              ? Border(
                  top: BorderSide(
                    color: colors.accent,
                    width: EditorTabsDesign.marker,
                  ),
                  right: BorderSide(color: colors.border),
                )
              : null,
        ),
        child: Material(type: MaterialType.transparency, child: tab),
      ),
    );
  }

  /// Opens the tab's menu with its corner at [at], kept inside the window
  /// (`editor-links-export/exporting-from-the-tab-dark.svg`).
  ///
  /// Export only for a markdown document of the space: it renders the page,
  /// and through the space, so any other file has nothing to offer but
  /// closing.
  void _openMenu(BuildContext context, WidgetRef ref, Offset at) {
    final SpaceRelativePathValueObject? document = switch (path) {
      final SpaceDocumentTab tab when tab.kind.isMarkdown => tab.path,
      _ => null,
    };
    final OverlayState overlay = Overlay.of(context);
    final RenderBox window = overlay.context.findRenderObject()! as RenderBox;
    final Offset local = window.globalToLocal(at);
    late final OverlayEntry entry;
    void dismiss() {
      if (entry.mounted) {
        entry.remove();
      }
    }

    entry = OverlayEntry(
      builder: (BuildContext _) => Positioned(
        left: local.dx.clamp(0, window.size.width - EditorTabsDesign.menuWidth),
        top: local.dy,
        child: TomMenuWidget(
          width: EditorTabsDesign.menuWidth,
          onDismissed: dismiss,
          groups: <List<TomMenuEntry>>[
            if (document != null)
              <TomMenuEntry>[
                TomMenuEntry(
                  glyph: TomGlyphEnum.file,
                  label: context.l10n.editorExportAsPdf,
                  onSelected: () =>
                      unawaited(_export(ref, document, ExportFormatEnum.pdf)),
                ),
                TomMenuEntry(
                  glyph: TomGlyphEnum.code,
                  label: context.l10n.editorExportAsHtml,
                  onSelected: () =>
                      unawaited(_export(ref, document, ExportFormatEnum.html)),
                ),
              ],
            <TomMenuEntry>[
              TomMenuEntry(
                glyph: TomGlyphEnum.close,
                label: context.l10n.editorCloseTab,
                onSelected: () =>
                    unawaited(EditorTabsWidget.close(context, ref, path)),
              ),
            ],
          ],
        ),
      ),
    );
    overlay.insert(entry);
  }

  /// Asks where, then writes [document] there as [format].
  Future<void> _export(
    WidgetRef ref,
    SpaceRelativePathValueObject document,
    ExportFormatEnum format,
  ) async {
    // Read before the dialog: the tab may be gone by the time it answers.
    final SaveLocationPicker pick = ref.read(saveLocationPickerProvider);
    final ExportNotifier exporting = ref.read(exportProvider.notifier);
    final String? destination = await pick(
      format.fileNameFor(document.name),
      format,
    );
    if (destination != null) {
      await exporting.export(document, format, destination);
    }
  }
}
