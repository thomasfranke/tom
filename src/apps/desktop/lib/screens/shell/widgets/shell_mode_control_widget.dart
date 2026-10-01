/// Source · Split · Preview, as the segmented control the boards draw.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// The three modes, as one control rather than three tabs.
///
/// A `Segmented · 3` from the library
/// (`docs/design/components/controls.md`): a sunken track with the chosen
/// segment raised out of it. Every number here is measured off
/// `design/screens/desktop/workspace/shell-dark.svg`.
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
            (SpaceSessionState? session) => session?.mode,
          ),
        ) ??
        DocumentModeEnum.split;
    return SizedBox(
      width: trackWidth,
      height: trackHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surfaceSunken,
          borderRadius: BorderRadius.circular(trackRadius),
        ),
        child: Row(
          children: <Widget>[
            for (final DocumentModeEnum each in DocumentModeEnum.values)
              _SegmentWidget(mode: each, isChosen: each == mode),
          ],
        ),
      ),
    );
  }
}

/// One of the three, raised when it is the mode the window is in.
class _SegmentWidget extends ConsumerWidget {
  const _SegmentWidget({required this.mode, required this.isChosen});

  final DocumentModeEnum mode;
  final bool isChosen;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(EnumProperty<DocumentModeEnum>('mode', mode))
      ..add(DiagnosticsProperty<bool>('isChosen', isChosen));
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
        child: InkWell(
          onTap: () => ref.read(spaceSessionProvider.notifier).look(mode),
          borderRadius: BorderRadius.circular(
            ShellModeControlWidget.tileRadius,
          ),
          child: Padding(
            padding: const EdgeInsets.all(ShellModeControlWidget.tileInset),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: isChosen ? colors.surfaceRaised : Colors.transparent,
                borderRadius: BorderRadius.circular(
                  ShellModeControlWidget.tileRadius,
                ),
              ),
              child: Center(
                child: Text(
                  _labels[mode]!,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    fontWeight: isChosen ? FontWeight.w600 : FontWeight.w400,
                    color: isChosen ? colors.textPrimary : colors.textSecondary,
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
const Map<DocumentModeEnum, String> _labels = <DocumentModeEnum, String>{
  DocumentModeEnum.source: 'Source',
  DocumentModeEnum.split: 'Split',
  DocumentModeEnum.preview: 'Preview',
};
