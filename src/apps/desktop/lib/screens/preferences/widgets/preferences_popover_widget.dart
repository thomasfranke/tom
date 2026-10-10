/// What opens under the gear: three preferences, and the file behind them.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/l10n/l10n.dart';
import 'package:tom_desktop/screens/preferences/preferences_design.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// The popover the preferences button opens
/// (`docs/product/preferences/the-popover/doc.md`).
///
/// **A popover, not a menu**: a menu is a list of choices in one tall row
/// each, and these are controls — a three-way choice, a select and a checkbox.
/// **No scrim**, because dimming would say the rest of the window is blocked
/// and the point is to watch the app change behind it.
///
/// **A preference applies when it is chosen**: there is no OK and no Cancel,
/// so closing decides nothing.
class PreferencesPopoverWidget extends ConsumerWidget {
  /// Creates the popover.
  const PreferencesPopoverWidget({this.tapGroup, this.onDismissed, super.key});

  /// The tap region the popover closes outside of, which the language's
  /// menu joins: it opens in the overlay, so a choice there would otherwise
  /// read as a tap outside and close the popover before the window answers.
  final Object? tapGroup;

  /// Closes the popover — what opening the file does first, since the tab
  /// it opens is behind it.
  final VoidCallback? onDismissed;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<Object?>('tapGroup', tapGroup))
      ..add(ObjectFlagProperty<VoidCallback?>.has('onDismissed', onDismissed));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PreferencesValueObject chosen = ref.watch(preferencesProvider);
    final PreferencesNotifier notifier = ref.read(preferencesProvider.notifier);
    final TomColors colors = TomColors.of(context);
    return SizedBox(
      width: PreferencesDesign.width,
      // The shadow **is** the difference between a card and a popover: a
      // surface that leaves the page says so (`design/components/controls.md`).
      child: Material(
        color: colors.surfaceRaised,
        elevation: 8,
        borderRadius: BorderRadius.circular(TomMetrics.radius),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: colors.border),
            borderRadius: BorderRadius.circular(TomMetrics.radius),
          ),
          child: Padding(
            // The card's own inset, less the stroke Flutter draws inside it.
            padding: const EdgeInsets.all(PreferencesDesign.inset - 1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(
                  height:
                      PreferencesDesign.captionTop - PreferencesDesign.inset,
                ),
                _CaptionWidget(context.l10n.preferencesTheme),
                _ThemeControlWidget(
                  chosen: chosen.theme,
                  onChoose: notifier.chooseTheme,
                ),
                const SizedBox(height: PreferencesDesign.settingGap),
                _CaptionWidget(context.l10n.preferencesLanguage),
                _LanguageControlWidget(
                  tapGroup: tapGroup,
                  chosen: chosen.language,
                  onChoose: notifier.chooseLanguage,
                ),
                const SizedBox(height: PreferencesDesign.settingGap),
                _FormattingBarCheckWidget(
                  isShowing: chosen.showingFormattingBar,
                  onToggle: notifier.toggleFormattingBar,
                ),
                const SizedBox(height: PreferencesDesign.ruleGap),
                Divider(height: 1, color: colors.border),
                const SizedBox(height: PreferencesDesign.ruleGap),
                _OpenTheFileWidget(onDismissed: onDismissed),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// What a group of controls is called, in the caption every panel uses.
class _CaptionWidget extends StatelessWidget {
  const _CaptionWidget(this.text);

  final String text;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('text', text));
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: PreferencesDesign.captionToControl),
    child: Text(
      text,
      style: TextStyle(
        fontSize: PreferencesDesign.captionSize,
        height: 1.4,
        letterSpacing: 0.8,
        fontWeight: FontWeight.w600,
        color: TomColors.of(context).textMuted,
      ),
    ),
  );
}

/// `Light · Dark`, the choice the top bar used to carry.
///
/// Two-way rather than three: the board offers the two themes and not the
/// platform's, so choosing here is always an answer
/// (`docs/product/preferences/what-it-holds/doc.md`).
class _ThemeControlWidget extends StatelessWidget {
  const _ThemeControlWidget({required this.chosen, required this.onChoose});

  final ThemeChoiceEnum chosen;
  final void Function(ThemeChoiceEnum) onChoose;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(EnumProperty<ThemeChoiceEnum>('chosen', chosen))
      ..add(
        ObjectFlagProperty<void Function(ThemeChoiceEnum)>.has(
          'onChoose',
          onChoose,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    final AppLocalizations l10n = context.l10n;
    // What was chosen, not what is drawn: `System` is a choice of its own —
    // follow the machine — and lit as one, whichever theme it lands on.
    return SizedBox(
      height: PreferencesDesign.switchHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surfaceSunken,
          border: Border.all(color: colors.border),
          borderRadius: BorderRadius.circular(TomMetrics.radius),
        ),
        child: Padding(
          padding: const EdgeInsets.all(PreferencesDesign.switchInset),
          child: Row(
            children: <Widget>[
              for (final (ThemeChoiceEnum choice, String label)
                  in <(ThemeChoiceEnum, String)>[
                    (ThemeChoiceEnum.system, l10n.preferencesThemeSystem),
                    (ThemeChoiceEnum.light, l10n.preferencesThemeLight),
                    (ThemeChoiceEnum.dark, l10n.preferencesThemeDark),
                  ])
                _HalfWidget(
                  label: label,
                  isChosen: chosen == choice,
                  onPressed: () => onChoose(choice),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One segment of the theme control.
class _HalfWidget extends StatelessWidget {
  const _HalfWidget({
    required this.label,
    required this.isChosen,
    required this.onPressed,
  });

  final String label;
  final bool isChosen;
  final VoidCallback onPressed;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('label', label))
      ..add(DiagnosticsProperty<bool>('isChosen', isChosen))
      ..add(ObjectFlagProperty<VoidCallback>.has('onPressed', onPressed));
  }

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    return Expanded(
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(TomMetrics.radiusTight),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: isChosen ? colors.control : Colors.transparent,
            borderRadius: BorderRadius.circular(TomMetrics.radiusTight),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: PreferencesDesign.label,
                height: 1,
                fontWeight: isChosen ? FontWeight.w600 : FontWeight.w500,
                color: isChosen ? colors.textPrimary : colors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The language, as a select whose current choice carries a tick.
class _LanguageControlWidget extends StatelessWidget {
  const _LanguageControlWidget({
    required this.tapGroup,
    required this.chosen,
    required this.onChoose,
  });

  final Object? tapGroup;
  final LanguageEnum chosen;
  final void Function(LanguageEnum) onChoose;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<Object?>('tapGroup', tapGroup))
      ..add(EnumProperty<LanguageEnum>('chosen', chosen))
      ..add(
        ObjectFlagProperty<void Function(LanguageEnum)>.has(
          'onChoose',
          onChoose,
        ),
      );
  }

  /// What [language] is called: its own name, or `System` in the window's.
  static String _nameOf(BuildContext context, LanguageEnum language) =>
      language.label ?? context.l10n.preferencesLanguageSystem;

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    return SizedBox(
      height: PreferencesDesign.rowHeight,
      child: MenuAnchor(
        menuChildren: <Widget>[
          for (final LanguageEnum language in LanguageEnum.values)
            TapRegion(
              groupId: tapGroup,
              child: MenuItemButton(
                onPressed: () => onChoose(language),
                // **A tick, not a highlight alone** — colour is never the only
                // signal, here as everywhere else.
                trailingIcon: language == chosen
                    ? SizedBox.square(
                        dimension: 16,
                        child: Center(
                          child: TomGlyphWidget(
                            glyph: TomGlyphEnum.check,
                            color: colors.accent,
                            size: 12,
                          ),
                        ),
                      )
                    : const SizedBox(width: 16),
                child: Text(_nameOf(context, language)),
              ),
            ),
        ],
        builder: (BuildContext context, MenuController menu, Widget? child) =>
            OutlinedButton(
              onPressed: () => menu.isOpen ? menu.close() : menu.open(),
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.textPrimary,
                backgroundColor: colors.surfaceRaised,
                side: BorderSide(color: colors.borderStrong),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(TomMetrics.radius),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: PreferencesDesign.boxToLabel + 6,
                ),
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      _nameOf(context, chosen),
                      style: const TextStyle(
                        fontSize: PreferencesDesign.label,
                        height: 1.4,
                      ),
                    ),
                  ),
                  TomChevronWidget(
                    isOpen: menu.isOpen,
                    color: colors.textSecondary,
                  ),
                ],
              ),
            ),
      ),
    );
  }
}

/// The formatting bar's own preference, as a checkbox and its sentence.
class _FormattingBarCheckWidget extends StatelessWidget {
  const _FormattingBarCheckWidget({
    required this.isShowing,
    required this.onToggle,
  });

  final bool isShowing;
  final VoidCallback onToggle;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<bool>('isShowing', isShowing))
      ..add(ObjectFlagProperty<VoidCallback>.has('onToggle', onToggle));
  }

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onToggle,
    child: Row(
      children: <Widget>[
        TomCheckWidget(isChecked: isShowing, onChanged: (bool _) => onToggle()),
        const SizedBox(width: PreferencesDesign.boxToLabel),
        // Flexible so a longer sentence shrinks the row instead of throwing.
        // It never happens in the app — but a widget test has no vendored
        // font, so every character measures its font size square.
        Flexible(
          child: Text(
            context.l10n.preferencesShowFormattingBar,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.fade,
            style: TextStyle(
              fontSize: PreferencesDesign.label,
              height: 1.4,
              color: TomColors.of(context).textPrimary,
            ),
          ),
        ),
      ],
    ),
  );
}

/// The button at the foot, which opens the store in TOM's own editor as **a
/// tab from outside the tree** (`docs/product/preferences/where-it-is-stored/doc.md`).
///
/// Dim on Home, which has no tabs to open it in: a control that cannot act
/// is dim, never absent.
class _OpenTheFileWidget extends ConsumerWidget {
  const _OpenTheFileWidget({required this.onDismissed});

  final VoidCallback? onDismissed;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      ObjectFlagProperty<VoidCallback?>.has('onDismissed', onDismissed),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TomColors colors = TomColors.of(context);
    final bool hasSpace = ref.watch(
      spaceSessionProvider.select(
        (SpaceSessionState? session) => session != null,
      ),
    );
    return SizedBox(
      height: PreferencesDesign.rowHeight,
      child: OutlinedButton(
        onPressed: hasSpace
            ? () {
                // Read before closing: the popover leaves the tree with it.
                final PreferencesNotifier preferences = ref.read(
                  preferencesProvider.notifier,
                );
                onDismissed?.call();
                unawaited(preferences.openFile());
              }
            : null,
        style: OutlinedButton.styleFrom(
          // Secondary while it can act (`design/components/controls.md`).
          foregroundColor: colors.textSecondary,
          side: BorderSide(
            color: hasSpace ? colors.borderStrong : colors.border,
          ),
          disabledForegroundColor: colors.textMuted,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TomMetrics.radius),
          ),
          textStyle: const TextStyle(
            fontSize: PreferencesDesign.label,
            fontWeight: FontWeight.w500,
          ),
        ),
        child: Text(context.l10n.preferencesOpenFile),
      ),
    );
  }
}
