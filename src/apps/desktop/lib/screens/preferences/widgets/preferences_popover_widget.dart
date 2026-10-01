/// What opens under the gear: three preferences, and the file behind them.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/screens/preferences/preferences_design.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// The popover the preferences button opens
/// (`docs/product/preferences/the-popover/doc.md`).
///
/// **A popover, not a menu**: a menu is a list of choices in one tall row
/// each, and these are controls — a two-way choice, a select and a checkbox.
/// **No scrim**, because dimming would say the rest of the window is blocked
/// and the point is to watch the app change behind it.
///
/// **A preference applies when it is chosen**: there is no OK and no Cancel,
/// so closing decides nothing.
class PreferencesPopoverWidget extends ConsumerWidget {
  /// Creates the popover.
  const PreferencesPopoverWidget({super.key});

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
                const _CaptionWidget('THEME'),
                _ThemeControlWidget(
                  chosen: chosen.theme,
                  onChoose: notifier.chooseTheme,
                ),
                const SizedBox(height: PreferencesDesign.settingGap),
                const _CaptionWidget('LANGUAGE'),
                _LanguageControlWidget(
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
                const _OpenTheFileWidget(),
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
    // What is drawn, not what was chosen: `system` is whichever the platform
    // gave us, and the control must show the theme on screen.
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: PreferencesDesign.switchHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surfaceSunken,
          borderRadius: BorderRadius.circular(TomMetrics.radius),
        ),
        child: Padding(
          padding: const EdgeInsets.all(PreferencesDesign.switchInset),
          child: Row(
            children: <Widget>[
              _HalfWidget(
                label: 'Light',
                isChosen: !isDark,
                onPressed: () => onChoose(ThemeChoiceEnum.light),
              ),
              _HalfWidget(
                label: 'Dark',
                isChosen: isDark,
                onPressed: () => onChoose(ThemeChoiceEnum.dark),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One side of the two-way control.
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
            color: isChosen ? colors.accentSoft : Colors.transparent,
            borderRadius: BorderRadius.circular(TomMetrics.radiusTight),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: PreferencesDesign.label,
                height: 1,
                fontWeight: isChosen ? FontWeight.w600 : FontWeight.w500,
                color: isChosen ? colors.accent : colors.textSecondary,
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
  const _LanguageControlWidget({required this.chosen, required this.onChoose});

  final LanguageEnum chosen;
  final void Function(LanguageEnum) onChoose;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(EnumProperty<LanguageEnum>('chosen', chosen))
      ..add(
        ObjectFlagProperty<void Function(LanguageEnum)>.has(
          'onChoose',
          onChoose,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    return SizedBox(
      height: PreferencesDesign.rowHeight,
      child: MenuAnchor(
        menuChildren: <Widget>[
          for (final LanguageEnum language in LanguageEnum.values)
            MenuItemButton(
              onPressed: () => onChoose(language),
              // **A tick, not a highlight alone** — colour is never the only
              // signal, here as everywhere else.
              trailingIcon: language == chosen
                  ? Icon(Icons.check, size: 16, color: colors.accent)
                  : const SizedBox(width: 16),
              child: Text(language.label),
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
                      chosen.label,
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
            'Show the formatting bar',
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

/// The button at the foot, which opens the store in TOM's own editor.
///
/// Drawn and unavailable: what it produces is **a tab from outside the
/// tree**, and there is no tab strip yet
/// (`docs/design/screens/not-drawn-yet.md`). A control that cannot act is
/// dim, never absent.
class _OpenTheFileWidget extends StatelessWidget {
  const _OpenTheFileWidget();

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    return SizedBox(
      height: PreferencesDesign.rowHeight,
      child: OutlinedButton(
        onPressed: null,
        style: OutlinedButton.styleFrom(
          disabledForegroundColor: colors.textMuted,
          side: BorderSide(color: colors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TomMetrics.radius),
          ),
          textStyle: const TextStyle(
            fontSize: PreferencesDesign.label,
            fontWeight: FontWeight.w500,
          ),
        ),
        child: const Text('Open preferences.json'),
      ),
    );
  }
}
