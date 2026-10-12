/// Which TOM this is, and whether there is a newer one.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_desktop/about/app_build.dart';
import 'package:tom_desktop/l10n/l10n.dart';
import 'package:tom_desktop/screens/about/about_design.dart';
import 'package:tom_desktop/screens/about/about_icon_widget.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// The About dialog (`docs/product/about/doc.md`): the build, three links,
/// and the update check with its states. `Update and restart` and the
/// download are not here until an updater exists.
class AboutDialogWidget extends ConsumerWidget {
  /// Creates the dialog.
  const AboutDialogWidget({super.key});

  /// Opens it over [context]'s window; a press outside and Escape shut it.
  static Future<void> show(BuildContext context) => showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(
      alpha: TomDialogWidget.barrierOpacity,
    ),
    builder: (BuildContext context) => const AboutDialogWidget(),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TomColors colors = TomColors.of(context);
    final AppLocalizations l10n = context.l10n;
    final UpdatesState updates = ref.watch(updatesProvider);
    final TextStyle label = TextStyle(
      fontSize: AboutDesign.labelSize,
      height: 1.5,
      color: colors.textMuted,
    );
    final TextStyle value = TextStyle(
      fontSize: AboutDesign.valueSize,
      height: 1.5,
      fontWeight: FontWeight.w500,
      color: colors.textPrimary,
    );
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: TomDialogWidget.width,
          // The card's own inset, less the stroke Flutter draws inside it.
          padding: const EdgeInsets.all(
            TomDialogWidget.inset - TomDialogWidget.outline,
          ),
          decoration: BoxDecoration(
            color: colors.surfaceRaised,
            border: Border.all(color: colors.border),
            borderRadius: BorderRadius.circular(TomMetrics.radius),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const AboutIconWidget(),
                  const SizedBox(width: AboutDesign.iconToName),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'TOM',
                          style: TextStyle(
                            fontSize: AboutDesign.nameSize,
                            height: 1.3,
                            fontWeight: FontWeight.w600,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          l10n.aboutTagline,
                          style: label.copyWith(
                            fontSize: AboutDesign.taglineSize,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AboutDesign.headerToFacts),
              _Row(
                l10n.aboutVersion,
                '${AppBuild.version} (${AppBuild.build})',
                label,
                value,
              ),
              _Row(l10n.aboutPlatform, platformName(), label, value),
              _Row(l10n.aboutLicense, 'MIT', label, value),
              const SizedBox(height: AboutDesign.factsToLinks),
              Wrap(
                spacing: AboutDesign.linkGap,
                children: <Widget>[
                  _Link(l10n.aboutSource, AppBuild.repository),
                  _Link(
                    l10n.aboutLicenses,
                    '${AppBuild.repository}/blob/main/docs/technical/stack',
                  ),
                  _Link(
                    l10n.aboutReleaseNotes,
                    '${AppBuild.repository}/releases',
                  ),
                ],
              ),
              const SizedBox(height: AboutDesign.linksToRule),
              TomRulePainter.of(colors.border),
              const SizedBox(height: AboutDesign.ruleToCaption),
              _UpdateWidget(updates: updates),
              const SizedBox(height: AboutDesign.buttonGap),
              SizedBox(
                height: AboutDesign.button,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: _secondary(colors),
                  child: _buttonLabel(l10n.aboutClose),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A button's words, lifted: their ink sits 1 to 2 lower than the board's in
/// the 48 of the button, so 4 of room under them raises the line by 2.
Widget _buttonLabel(String text) =>
    Padding(padding: const EdgeInsets.only(bottom: 4), child: Text(text));

/// The secondary button the dialog's two buttons are: outlined, its label in
/// `text_secondary` at the regular weight, and — when it cannot act — the
/// sunken face with a muted label and no outline.
ButtonStyle _secondary(TomColors colors) =>
    OutlinedButton.styleFrom(
      foregroundColor: colors.textSecondary,
      disabledForegroundColor: colors.textMuted,
      disabledBackgroundColor: colors.surfaceSunken,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TomMetrics.radius),
      ),
      textStyle: const TextStyle(
        fontSize: AboutDesign.buttonSize,
        fontWeight: FontWeight.w500,
      ),
    ).copyWith(
      side: WidgetStateProperty.resolveWith(
        (Set<WidgetState> states) => states.contains(WidgetState.disabled)
            ? BorderSide.none
            : BorderSide(color: colors.borderStrong),
      ),
    );

/// One fact: its name in the label column, its value left-aligned in the
/// value column, on one baseline.
class _Row extends StatelessWidget {
  const _Row(this.name, this.text, this.label, this.value);

  final String name;
  final String text;
  final TextStyle label;
  final TextStyle value;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('name', name))
      ..add(StringProperty('text', text))
      ..add(DiagnosticsProperty<TextStyle>('label', label))
      ..add(DiagnosticsProperty<TextStyle>('value', value));
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    height: AboutDesign.factRow,
    child: Padding(
      padding: const EdgeInsets.only(top: AboutDesign.factInset),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: <Widget>[
          SizedBox(
            width: AboutDesign.valueColumn,
            child: Text(name, style: label),
          ),
          Expanded(child: Text(text, style: value)),
        ],
      ),
    ),
  );
}

/// An address that opens in the browser.
class _Link extends ConsumerWidget {
  const _Link(this.text, this.address);

  final String text;
  final String address;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('text', text))
      ..add(StringProperty('address', address));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => InkWell(
    onTap: () => unawaited(ref.read(openUrlProvider).open(Uri.parse(address))),
    child: Text(
      text,
      style: TextStyle(
        fontSize: AboutDesign.valueSize,
        height: 1.5,
        fontWeight: FontWeight.w500,
        color: TomColors.of(context).accent,
      ),
    ),
  );
}

/// The update check: what it last said, and the button that asks again.
class _UpdateWidget extends ConsumerWidget {
  const _UpdateWidget({required this.updates});

  final UpdatesState updates;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<UpdatesState>('updates', updates));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TomColors colors = TomColors.of(context);
    final AppLocalizations l10n = context.l10n;
    final TextStyle line = TextStyle(
      fontSize: AboutDesign.valueSize,
      height: 1.5,
      color: colors.textPrimary,
    );
    final TextStyle aside = TextStyle(
      fontSize: AboutDesign.labelSize,
      height: 1.5,
      color: colors.textMuted,
    );
    final bool canAsk =
        updates is! UpdatesNoRelease && updates is! UpdatesAsking;
    final List<Widget> said = switch (updates) {
      UpdatesNoRelease() => <Widget>[Text(l10n.aboutNoRelease, style: line)],
      UpdatesIdle() => const <Widget>[],
      UpdatesAsking() => <Widget>[
        Row(
          children: <Widget>[
            const SizedBox.square(
              dimension: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(l10n.aboutAsking, style: line)),
          ],
        ),
      ],
      UpdatesUpToDate(:final DateTime checkedAt) => <Widget>[
        Text(l10n.aboutUpToDate(AppBuild.version), style: line),
        const SizedBox(height: AboutDesign.sentenceGap),
        Text(l10n.aboutChecked(_clock(checkedAt)), style: aside),
      ],
      UpdatesNewer(:final String version, :final String notesUrl) => <Widget>[
        Text(l10n.aboutNewer(version, AppBuild.version), style: line),
        const SizedBox(height: AboutDesign.sentenceGap),
        if (notesUrl.isNotEmpty) _Link(l10n.aboutWhatsNew, notesUrl),
      ],
      UpdatesFailed() => <Widget>[
        Text(l10n.aboutFailed, style: line.copyWith(color: colors.modified)),
      ],
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          l10n.aboutUpdates,
          style: TextStyle(
            fontSize: AboutDesign.captionSize,
            height: 1.4,
            fontWeight: FontWeight.w600,
            color: colors.textMuted,
          ),
        ),
        const SizedBox(height: AboutDesign.captionToLine),
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AboutDesign.lineHeight),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: said,
          ),
        ),
        SizedBox(
          height: AboutDesign.button,
          child: OutlinedButton(
            onPressed: canAsk
                ? () => unawaited(ref.read(updatesProvider.notifier).check())
                : null,
            style: _secondary(colors),
            child: _buttonLabel(
              updates is UpdatesFailed ? l10n.aboutTryAgain : l10n.aboutCheck,
            ),
          ),
        ),
      ],
    );
  }

  /// `14:05`, the machine's own clock.
  static String _clock(DateTime at) =>
      '${at.hour.toString().padLeft(2, '0')}:'
      '${at.minute.toString().padLeft(2, '0')}';
}
