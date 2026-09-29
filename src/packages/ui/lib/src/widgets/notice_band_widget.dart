/// News from git: a sentence, and one thing to do about it.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tom_ui/src/theme/tom_metrics.dart';

/// The notice band of
/// [components](../../../../../../docs/design/components/controls.md): a
/// sentence at the left, one action at the right, on a tinted strip the width
/// of the document area.
///
/// A colour and a sentence rather than a meaning, the way the diff mark takes
/// its letter, so a refusal, a failure and a confirmation are one component
/// instead of three. **One action**: a band with two is a dialog that forgot
/// to be one (`docs/product/workspace/feedback/doc.md`).
///
/// The fill is the only thing drawn — the boards carry no rule around the
/// band, and the divider above it is the mode bar's own.
class NoticeBandWidget extends StatelessWidget {
  /// Creates the band.
  const NoticeBandWidget({
    required this.sentence,
    required this.ink,
    required this.fill,
    required this.raised,
    this.action,
    this.onAction,
    super.key,
  });

  /// The action's pill, and how far its right edge sits from the band's.
  static const double _actionWidth = 96;
  static const double _actionHeight = 24;
  static const double _actionInset = 24;

  /// What happened, in the product's words.
  final String sentence;

  /// The role's colour, for the sentence and the action.
  final Color ink;

  /// The role's soft colour, filling the strip.
  final Color fill;

  /// What the action's pill is filled with — the raised surface, so it reads
  /// as a control sitting on the band rather than a word on it.
  final Color raised;

  /// The one thing to do about it, or null when there is nothing to offer.
  final String? action;

  /// What that action does; null leaves it on screen and disabled, which is
  /// what a band says while git is already working.
  final VoidCallback? onAction;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('sentence', sentence))
      ..add(ColorProperty('ink', ink))
      ..add(ColorProperty('fill', fill))
      ..add(ColorProperty('raised', raised))
      ..add(StringProperty('action', action))
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
    child: SizedBox(
      height: TomMetrics.noticeBand,
      child: Row(
        children: <Widget>[
          const SizedBox(width: TomMetrics.barInset),
          Expanded(
            child: Text(
              sentence,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13, height: 1.4, color: ink),
            ),
          ),
          if (action != null) ...<Widget>[
            const SizedBox(width: TomMetrics.barInset),
            SizedBox(
              width: _actionWidth,
              height: _actionHeight,
              child: OutlinedButton(
                onPressed: onAction,
                style: OutlinedButton.styleFrom(
                  foregroundColor: ink,
                  disabledForegroundColor: ink.withValues(alpha: 0.4),
                  backgroundColor: raised,
                  side: BorderSide(color: ink),
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(TomMetrics.radius),
                    ),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: Text(action!),
              ),
            ),
          ],
          const SizedBox(width: _actionInset),
        ],
      ),
    ),
  );
}
