/// What opens under the gear: three preferences, and the file behind them.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/about/app_build.dart';
import 'package:tom_desktop/l10n/l10n.dart';
import 'package:tom_desktop/screens/about/about_dialog_widget.dart';
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

  /// What a rule runs past the content on each side: the boards draw it from
  /// stroke to stroke, the card's whole inside.
  static const double _bleed = PreferencesDesign.inset - 1;

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
                const SizedBox(height: PreferencesDesign.afterSwitch),
                _CaptionWidget(context.l10n.preferencesLanguage),
                _LanguageControlWidget(
                  tapGroup: tapGroup,
                  chosen: chosen.language,
                  onChoose: notifier.chooseLanguage,
                ),
                const SizedBox(height: PreferencesDesign.settingGap),
                _FormattingBarCheckWidget(
                  label: context.l10n.preferencesShowFormattingBar,
                  isShowing: chosen.showingFormattingBar,
                  onToggle: notifier.toggleFormattingBar,
                ),
                const SizedBox(height: PreferencesDesign.checkGap),
                _FormattingBarCheckWidget(
                  label: context.l10n.preferencesCheckForUpdates,
                  isShowing: chosen.checkingForUpdates,
                  onToggle: notifier.toggleCheckingForUpdates,
                ),
                const SizedBox(height: PreferencesDesign.settingGap),
                _CaptionWidget(context.l10n.preferencesGitCommands),
                _GitModeControlWidget(
                  chosen: chosen.gitApprovals,
                  onChoose: notifier.chooseGitApprovals,
                ),
                const SizedBox(height: PreferencesDesign.switchToWhy),
                Text(
                  switch (chosen.gitApprovals) {
                    GitApprovalModeEnum.automatic =>
                      context.l10n.preferencesGitAutomaticWhy,
                    GitApprovalModeEnum.semi =>
                      context.l10n.preferencesGitSemiWhy,
                    GitApprovalModeEnum.manual =>
                      context.l10n.preferencesGitManualWhy,
                  },
                  style: TextStyle(
                    fontSize: PreferencesDesign.why,
                    height: 1.4,
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: PreferencesDesign.whyToButton),
                _OpenTheFileWidget(
                  label: context.l10n.preferencesOpenApprovals,
                  open: (PreferencesNotifier it) => it.openApprovalsFile(),
                  onDismissed: onDismissed,
                ),
                const SizedBox(height: PreferencesDesign.ruleAbove),
                TomRulePainter.of(colors.border, bleed: _bleed),
                const SizedBox(height: PreferencesDesign.ruleBelow),
                _OpenTheFileWidget(
                  label: context.l10n.preferencesOpenFile,
                  open: (PreferencesNotifier it) => it.openFile(),
                  onDismissed: onDismissed,
                ),
                const SizedBox(height: PreferencesDesign.ruleAbove),
                TomRulePainter.of(colors.border, bleed: _bleed),
                const SizedBox(height: PreferencesDesign.ruleBelow),
                _AboutRowWidget(onDismissed: onDismissed),
                const SizedBox(height: PreferencesDesign.footer),
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
                fontSize: PreferencesDesign.segment,
                height: 1,
                fontWeight: isChosen
                    ? TomFonts.segmentChosen
                    : TomFonts.segmentRest,
                color: isChosen ? colors.textPrimary : colors.textMuted,
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
      height: PreferencesDesign.selectHeight,
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
                // The theme track's own fill and stroke, in both themes
                // (`preferences-{dark,light}.svg`, the rect at y 130).
                backgroundColor: colors.surfaceSunken,
                side: BorderSide(color: colors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(TomMetrics.radius),
                ),
                // The chevron's box keeps its own margin, so less on the right.
                padding: const EdgeInsets.fromLTRB(14, 0, 6, 0),
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      _nameOf(context, chosen),
                      style: const TextStyle(
                        fontSize: PreferencesDesign.label,
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  // A select says *down* open or shut: the menu is what it
                  // opens, not a branch of a tree.
                  TomChevronWidget(isOpen: true, color: colors.textSecondary),
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
    required this.label,
    required this.isShowing,
    required this.onToggle,
  });

  final String label;
  final bool isShowing;
  final VoidCallback onToggle;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('label', label))
      ..add(DiagnosticsProperty<bool>('isShowing', isShowing))
      ..add(ObjectFlagProperty<VoidCallback>.has('onToggle', onToggle));
  }

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onToggle,
    child: SizedBox(
      height: PreferencesDesign.checkRow,
      child: Row(
        children: <Widget>[
          TomCheckWidget(
            isChecked: isShowing,
            onChanged: (bool _) => onToggle(),
          ),
          const SizedBox(width: PreferencesDesign.boxToLabel),
          // Flexible so a longer sentence shrinks the row instead of
          // throwing. It never happens in the app — but a widget test has no
          // vendored font, so every character measures its font size square.
          Flexible(
            child: Text(
              label,
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
    ),
  );
}

/// The last row: `About TOM` with the running version at its right, or
/// `Update available` where the version was when the opening check found
/// one (`docs/product/about/doc.md`).
class _AboutRowWidget extends ConsumerWidget {
  const _AboutRowWidget({required this.onDismissed});

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
    final bool isNewer = ref.watch(
      updatesProvider.select((UpdatesState state) => state is UpdatesNewer),
    );
    return InkWell(
      onTap: () {
        // The popover leaves the tree when it closes, so the dialog is
        // opened over the navigator's own context.
        final NavigatorState navigator = Navigator.of(context);
        onDismissed?.call();
        unawaited(AboutDialogWidget.show(navigator.context));
      },
      child: SizedBox(
        height: PreferencesDesign.aboutHeight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              context.l10n.aboutRow,
              style: TextStyle(
                fontSize: PreferencesDesign.label,
                fontWeight: FontWeight.w500,
                color: colors.textPrimary,
              ),
            ),
            Text(
              isNewer ? context.l10n.aboutUpdateAvailable : AppBuild.version,
              style: TextStyle(
                fontSize: PreferencesDesign.label,
                fontWeight: isNewer ? FontWeight.w500 : FontWeight.w400,
                color: isNewer ? colors.accent : colors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The button at the foot, which opens the store in TOM's own editor as **a
/// tab from outside the tree** (`docs/product/preferences/where-it-is-stored/doc.md`).
///
/// Dim on Home, which has no tabs to open it in: a control that cannot act
/// is dim, never absent.
class _OpenTheFileWidget extends ConsumerWidget {
  const _OpenTheFileWidget({
    required this.label,
    required this.open,
    required this.onDismissed,
  });

  /// The file's name on the button.
  final String label;

  /// Opens the file behind it.
  final Future<void> Function(PreferencesNotifier) open;

  final VoidCallback? onDismissed;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('label', label))
      ..add(
        ObjectFlagProperty<Future<void> Function(PreferencesNotifier)>.has(
          'open',
          open,
        ),
      )
      ..add(ObjectFlagProperty<VoidCallback?>.has('onDismissed', onDismissed));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TomColors colors = TomColors.of(context);
    final bool hasSpace = ref.watch(
      spaceSessionProvider.select(
        (SpaceSessionState? session) => session != null,
      ),
    );
    final Color ink = hasSpace ? colors.textSecondary : colors.textMuted;
    return SizedBox(
      height: PreferencesDesign.buttonHeight,
      child: OutlinedButton(
        onPressed: hasSpace
            ? () {
                // Read before closing: the popover leaves the tree with it.
                final PreferencesNotifier preferences = ref.read(
                  preferencesProvider.notifier,
                );
                onDismissed?.call();
                unawaited(open(preferences));
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
            fontSize: PreferencesDesign.buttonLabel,
            fontWeight: FontWeight.w500,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // The document the button opens, as the tree draws one.
            TomGlyphWidget(
              glyph: TomGlyphEnum.file,
              color: ink,
              size: PreferencesDesign.fileGlyph,
            ),
            const SizedBox(width: PreferencesDesign.glyphToLabel),
            Flexible(child: Text(label)),
          ],
        ),
      ),
    );
  }
}

/// `Automatic · Semi · Manual`: who says yes before git and `gh` run.
///
/// The theme control's shape — a segmented choice that applies when it is
/// pressed — with its own three words
/// (`docs/product/git-workflow/approvals/doc.md`).
class _GitModeControlWidget extends StatelessWidget {
  const _GitModeControlWidget({required this.chosen, required this.onChoose});

  final GitApprovalModeEnum chosen;
  final void Function(GitApprovalModeEnum) onChoose;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(EnumProperty<GitApprovalModeEnum>('chosen', chosen))
      ..add(
        ObjectFlagProperty<void Function(GitApprovalModeEnum)>.has(
          'onChoose',
          onChoose,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    final AppLocalizations l10n = context.l10n;
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
              for (final (GitApprovalModeEnum mode, String label)
                  in <(GitApprovalModeEnum, String)>[
                    (
                      GitApprovalModeEnum.automatic,
                      l10n.preferencesGitAutomatic,
                    ),
                    (GitApprovalModeEnum.semi, l10n.preferencesGitSemi),
                    (GitApprovalModeEnum.manual, l10n.preferencesGitManual),
                  ])
                _HalfWidget(
                  label: label,
                  isChosen: chosen == mode,
                  onPressed: () => onChoose(mode),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
