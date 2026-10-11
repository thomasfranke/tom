/// News from git: a sentence, and one thing to do about it.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tom_ui/src/theme/tom_metrics.dart';

/// The notice band of
/// [components](../../../../../../docs/design/components/controls.md): a
/// sentence, then one action, on a tinted strip as wide as the document.
///
/// A colour and a sentence rather than a meaning, so a refusal, a failure
/// and a confirmation are one component. **One action**: two is a dialog
/// that forgot to be one (`docs/product/workspace/feedback/doc.md`) — bar a
/// file changed under unsaved edits, where [alternative] keeps things as
/// they are, and a git failure, where it shows the command that failed.
///
/// Drawn to `git-pull/pull-worked`: the fill, a bar of [ink] at the left
/// edge and no outline; the action is an outline in [ink] on the band itself.
class NoticeBandWidget extends StatelessWidget {
  /// Creates the band.
  const NoticeBandWidget({
    required this.sentence,
    required this.ink,
    required this.fill,
    this.action,
    this.onAction,
    this.alternative,
    this.onAlternative,
    super.key,
  });

  /// Between the alternative's pill and the action's.
  static const double actionGap = 8;

  /// The bar at the band's left edge, the band's full height.
  static const double barWidth = 3;

  /// The action's pill, its top six below the band's.
  static const double actionHeight = 24;

  /// The room each side of the action's label, so the pill follows the word.
  static const double actionPadding = 14;

  /// How far the pill's right edge sits from the band's.
  static const double actionInset = 13;

  /// Where the sentence starts after the bar: 19 from the band's edge.
  static const double _sentenceGap = 16;
  static const double _actionRadius = 6;

  /// What happened, in the product's words.
  final String sentence;

  /// The role's colour, for the bar, the sentence and the action.
  final Color ink;

  /// The role's soft colour, filling the strip.
  final Color fill;

  /// The one thing to do about it, or null when there is nothing to offer.
  final String? action;

  /// What that action does; null leaves it on screen and disabled, which is
  /// what a band says while git is already working.
  final VoidCallback? onAction;

  /// A second pill before [action], or null for the usual one.
  final String? alternative;

  /// What [alternative] does.
  final VoidCallback? onAlternative;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('sentence', sentence))
      ..add(ColorProperty('ink', ink))
      ..add(ColorProperty('fill', fill))
      ..add(StringProperty('action', action))
      ..add(StringProperty('alternative', alternative))
      ..add(
        ObjectFlagProperty<VoidCallback?>.has('onAlternative', onAlternative),
      )
      ..add(
        FlagProperty(
          'onAction',
          value: onAction != null,
          ifTrue: 'enabled',
          ifFalse: 'disabled',
        ),
      );
  }

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: fill,
    child: ConstrainedBox(
      constraints: const BoxConstraints(minHeight: TomMetrics.noticeBand),
      child: Stack(
        children: <Widget>[
          // A sentence too long for the row wraps and the band grows; the
          // pills stay on its first line, top-aligned (the maintainer's call,
          // 2026-10-09: a shorter sentence cannot fit every window).
          Padding(
            padding: const EdgeInsets.only(
              left: barWidth + _sentenceGap,
              right: actionInset,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: _sentenceTop),
                    child: Text(
                      sentence,
                      style: TextStyle(
                        fontSize: 12.5,
                        height: _lineHeight,
                        fontWeight: FontWeight.w500,
                        color: ink,
                      ),
                    ),
                  ),
                ),
                if (alternative case final String label) ...<Widget>[
                  const SizedBox(width: _sentenceGap),
                  _placed(_pill(label, onAlternative)),
                ],
                if (action case final String label) ...<Widget>[
                  SizedBox(
                    width: alternative == null ? _sentenceGap : actionGap,
                  ),
                  _placed(_pill(label, onAction)),
                ],
              ],
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: barWidth,
            child: ColoredBox(color: ink),
          ),
        ],
      ),
    ),
  );

  /// The sentence's line height, as a multiple of its size.
  static const double _lineHeight = 1.3;

  /// Above and below the sentence, so one line sits centred in the band.
  static const double _sentenceTop =
      (TomMetrics.noticeBand - 12.5 * _lineHeight) / 2;

  /// A pill on the band's first line, wherever the sentence ends.
  Widget _placed(Widget pill) => Padding(
    padding: const EdgeInsets.only(
      top: (TomMetrics.noticeBand - actionHeight) / 2,
    ),
    child: SizedBox(height: actionHeight, child: pill),
  );

  /// The pill, as wide as its label: transparent, so the band shows through.
  Widget _pill(String label, VoidCallback? onPressed) {
    final Color faded = ink.withValues(alpha: 0.4);
    return OutlinedButton(
      onPressed: onPressed,
      style:
          OutlinedButton.styleFrom(
            foregroundColor: ink,
            disabledForegroundColor: faded,
            backgroundColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: actionPadding),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.standard,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(_actionRadius)),
            ),
            textStyle: const TextStyle(
              fontSize: 12,
              height: 1.3,
              fontWeight: FontWeight.w600,
            ),
          ).copyWith(
            side: WidgetStateProperty.resolveWith(
              (Set<WidgetState> states) => BorderSide(
                color: states.contains(WidgetState.disabled) ? faded : ink,
              ),
            ),
          ),
      child: Text(label, maxLines: 1),
    );
  }
}
