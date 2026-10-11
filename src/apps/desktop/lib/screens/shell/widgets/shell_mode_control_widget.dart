/// Source · Split · Preview, as the segmented control the boards draw.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/l10n/l10n.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// The three modes, as one control rather than three tabs.
///
/// A `Segmented · 3` from the library
/// (`docs/design/components/controls.md`): a sunken track with the chosen
/// segment raised out of it. Every number here is measured off
/// `design/screens/desktop/workspace-shell/shell-dark.svg`.
class ShellModeControlWidget extends ConsumerWidget {
  /// Creates the control.
  const ShellModeControlWidget({super.key});

  /// The track the three segments sit in.
  static const double trackWidth = 222;

  /// The track's height, which is the control's.
  static const double trackHeight = 26;

  /// The track's corner.
  static const double trackRadius = 7;

  /// One segment: a third of the track, whatever the label is.
  static const double segment = trackWidth / 3;

  /// How far the raised tile sits inside its segment.
  static const double tileInset = 2;

  /// The raised tile's corner, tighter than the track's.
  static const double tileRadius = 5;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TomColors colors = TomColors.of(context);
    final DocumentModeEnum mode =
        ref.watch(
          spaceSessionProvider.select(
            (SpaceSessionState? session) => session?.drawnMode,
          ),
        ) ??
        DocumentModeEnum.split;
    // A file that is not markdown has no page to render, so the two modes
    // that render are drawn unavailable while it is on screen; a binary file
    // has no text either, so no mode is chosen and none is offered
    // (`docs/product/git-workflow/commit/opening-a-change/doc.md`).
    final bool sourceOnly = ref.watch(
      spaceSessionProvider.select(
        (SpaceSessionState? session) => session?.isSourceOnly ?? false,
      ),
    );
    final bool binary = ref.watch(
      editorProvider.select(
        (EditorState editor) => editor is EditorReady && editor.isBinary,
      ),
    );
    return SizedBox(
      width: trackWidth,
      height: trackHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surfaceSunken,
          border: Border.all(color: colors.border),
          borderRadius: BorderRadius.circular(trackRadius),
        ),
        child: Row(
          children: <Widget>[
            for (final DocumentModeEnum each in DocumentModeEnum.values)
              _SegmentWidget(
                mode: each,
                isChosen: !binary && each == mode,
                isAvailable:
                    !binary && (!sourceOnly || each == DocumentModeEnum.source),
              ),
          ],
        ),
      ),
    );
  }
}

/// One of the three, raised when it is the mode the window is in.
class _SegmentWidget extends ConsumerWidget {
  const _SegmentWidget({
    required this.mode,
    required this.isChosen,
    required this.isAvailable,
  });

  final DocumentModeEnum mode;
  final bool isChosen;
  final bool isAvailable;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(EnumProperty<DocumentModeEnum>('mode', mode))
      ..add(DiagnosticsProperty<bool>('isChosen', isChosen))
      ..add(DiagnosticsProperty<bool>('isAvailable', isAvailable));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TomColors colors = TomColors.of(context);
    return SizedBox(
      width: ShellModeControlWidget.segment,
      height: ShellModeControlWidget.trackHeight,
      child: Semantics(
        button: true,
        selected: isChosen,
        enabled: isAvailable,
        child: InkWell(
          onTap: isAvailable
              ? () => ref.read(spaceSessionProvider.notifier).look(mode)
              : null,
          borderRadius: BorderRadius.circular(
            ShellModeControlWidget.tileRadius,
          ),
          child: Padding(
            padding: const EdgeInsets.all(ShellModeControlWidget.tileInset),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: isChosen ? colors.control : Colors.transparent,
                borderRadius: BorderRadius.circular(
                  ShellModeControlWidget.tileRadius,
                ),
              ),
              child: Center(
                child: Text(
                  _labelOf(context.l10n, mode),
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    fontWeight: isChosen
                        ? TomFonts.segmentChosen
                        : TomFonts.segmentRest,
                    color: isChosen
                        ? colors.textPrimary
                        : isAvailable
                        ? colors.textSecondary
                        : colors.textMuted,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// What each mode is called on screen.
String _labelOf(AppLocalizations l10n, DocumentModeEnum mode) => switch (mode) {
  DocumentModeEnum.source => l10n.modeSource,
  DocumentModeEnum.split => l10n.modeSplit,
  DocumentModeEnum.preview => l10n.modePreview,
};
