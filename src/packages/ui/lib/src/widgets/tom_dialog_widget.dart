/// The question the app stops to ask, over everything else.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tom_ui/src/theme/tom_colors.dart';
import 'package:tom_ui/src/theme/tom_metrics.dart';

/// One action a [TomDialogWidget] offers.
@immutable
class TomDialogAction {
  /// Creates an action reading [label], calling [onPressed] when pressed.
  const TomDialogAction({
    required this.label,
    required this.onPressed,
    this.destructive = false,
  });

  /// What the button says — a verb phrase, never `OK`.
  final String label;

  /// What it does; null draws it unavailable.
  final VoidCallback? onPressed;

  /// Whether the label is drawn in `removed`.
  ///
  /// The ink is the only thing this changes: a destructive action is never
  /// the filled one, so it cannot be reached by pressing Enter through a
  /// dialog nobody read.
  final bool destructive;
}

/// A card over a scrim, with a question, what it costs, and the ways out
/// stacked under it.
///
/// **The actions are stacked at the card's full width**, first one filled,
/// the rest outlined — not a pair at the right corner. Every board draws
/// them this way, and a column of full-width buttons reads in one direction
/// instead of two (`docs/design/screens/desktop/git-conflict/aborting-the-pull-light.svg`).
///
/// **The first action is the safe one.** A dialog exists because something
/// cannot be undone, so the press that needs no thought is the one that
/// changes nothing.
class TomDialogWidget extends StatelessWidget {
  /// Creates the dialog, asking [title] with [actions] under it.
  const TomDialogWidget({
    required this.title,
    required this.actions,
    this.body = const <String>[],
    super.key,
  });

  /// The question, in the user's words.
  final String title;

  /// What it costs, one line per sentence; empty when the title is enough.
  final List<String> body;

  /// The ways out, safest first.
  final List<TomDialogAction> actions;

  /// What the card is wide.
  static const double width = 400;

  /// Card edge to content, measured from the card's outer edge.
  static const double inset = 24;

  /// The card's own outline, which Flutter draws *inside* the box.
  ///
  /// It is [Border.all]'s own default width, so it is not passed; what it is
  /// here for is the padding.
  ///
  /// So the padding is [inset] minus this: the board measures the inset from
  /// the outer edge, and padding the full 24 would land the content two
  /// points narrow.
  static const double outline = 1;

  /// The question's size.
  static const double titleSize = 22;

  /// A body line's size.
  static const double bodySize = 14;

  /// The card's top to the question's box.
  static const double titleTop = 32;

  /// The question to the first body line.
  static const double titleGap = 22;

  /// A body line to the next.
  static const double lineGap = 20;

  /// The last body line to the first action.
  static const double bodyToActions = 27;

  /// An action's height.
  static const double actionHeight = 48;

  /// The gap between two actions.
  static const double actionGap = 8;

  /// An action's label size.
  static const double actionSize = 15;

  /// How dark the window goes behind the card.
  ///
  /// The barrier is `Navigator`'s ([Decision
  /// 6](../../../../../../docs/technical/decisions/006-no-navigation-package.md)
  /// allows it for dialogs and nothing else), so this is the one number the
  /// scrim contributes — focus, Escape and the press that cannot reach
  /// through come with it.
  static const double barrierOpacity = 0.55;

  /// Asks [title] over the window, answering with what was pressed.
  ///
  /// Null when the dialog was dismissed without choosing, which callers must
  /// treat as *do nothing* rather than as a default.
  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required List<TomDialogAction> Function(void Function(T) answer) actions,
    List<String> body = const <String>[],
    bool dismissible = false,
  }) => showDialog<T>(
    context: context,
    barrierDismissible: dismissible,
    barrierColor: Colors.black.withValues(alpha: barrierOpacity),
    builder: (BuildContext context) => TomDialogWidget(
      title: title,
      body: body,
      actions: actions((T value) => Navigator.of(context).pop(value)),
    ),
  );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('title', title))
      ..add(IterableProperty<String>('body', body))
      ..add(IntProperty('actions', actions.length));
  }

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: width,
          decoration: BoxDecoration(
            color: colors.surfaceRaised,
            border: Border.all(color: colors.border),
            borderRadius: BorderRadius.circular(TomMetrics.radius),
          ),
          padding: const EdgeInsets.all(inset - outline),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: titleTop - inset + outline),
              Text(
                title,
                style: TextStyle(
                  fontSize: titleSize,
                  height: 1.3,
                  color: colors.textPrimary,
                ),
              ),
              if (body.isNotEmpty) ...<Widget>[
                const SizedBox(height: titleGap),
                for (final String line in body) ...<Widget>[
                  Text(
                    line,
                    style: TextStyle(
                      fontSize: bodySize,
                      height: lineGap / bodySize,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ],
              const SizedBox(height: bodyToActions),
              for (int i = 0; i < actions.length; i++) ...<Widget>[
                if (i > 0) const SizedBox(height: actionGap),
                _action(colors, actions[i], filled: i == 0),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// One of them: the first filled, the rest outlined.
  Widget _action(
    TomColors colors,
    TomDialogAction action, {
    required bool filled,
  }) {
    final Color ink = action.destructive ? colors.removed : colors.textPrimary;
    return SizedBox(
      height: actionHeight,
      child: filled
          ? FilledButton(
              onPressed: action.onPressed,
              style: FilledButton.styleFrom(
                backgroundColor: colors.accent,
                foregroundColor: colors.surfaceRaised,
                disabledBackgroundColor: colors.surfaceSunken,
                disabledForegroundColor: colors.textMuted,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(TomMetrics.radius),
                ),
                textStyle: const TextStyle(
                  fontSize: actionSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: Text(action.label),
            )
          : OutlinedButton(
              onPressed: action.onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: ink,
                disabledForegroundColor: colors.textMuted,
                side: BorderSide(color: colors.borderStrong),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(TomMetrics.radius),
                ),
                textStyle: const TextStyle(
                  fontSize: actionSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
              child: Text(action.label),
            ),
    );
  }
}
