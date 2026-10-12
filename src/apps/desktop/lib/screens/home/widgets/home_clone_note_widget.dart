/// The line under the clone field: what to do, how far, or what went wrong.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tom_desktop/l10n/l10n.dart';
import 'package:tom_desktop/screens/home/home_design.dart';
import 'package:tom_desktop/widgets/home_relative_path.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';
import 'package:tom_ui/tom_ui.dart';

/// The hint while the field waits, git's phase over a bar while it clones,
/// the refusal in `removed` when it failed — never a silent hang
/// (`docs/product/home/cloning/doc.md`).
class HomeCloneNoteWidget extends StatelessWidget {
  /// Creates the line for [clone].
  const HomeCloneNoteWidget({required this.clone, super.key});

  /// Where cloning has got to.
  final HomeCloneState clone;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<HomeCloneState>('clone', clone));
  }

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    final AppLocalizations l10n = context.l10n;
    return switch (clone) {
      HomeCloneClosed() => const SizedBox.shrink(),
      HomeCloneOpen() => _line(
        l10n.homeCloneHint,
        colors.textMuted,
        FontWeight.w400,
      ),
      final HomeCloneFailed failed => _line(
        sentenceOf(l10n, failed),
        colors.removed,
        FontWeight.w500,
      ),
      HomeCloneCloning(
        :final String destination,
        :final CloneProgressValueObject? progress,
      ) =>
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: HomeDesign.controlsToTrack),
            _Track(percent: progress?.percent),
            const SizedBox(height: HomeDesign.trackToPhase),
            Text(
              phaseOf(l10n, progress, destination),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _style(colors.textSecondary, FontWeight.w400),
            ),
          ],
        ),
    };
  }

  /// One line of text at the note's place.
  static Widget _line(String text, Color ink, FontWeight weight) => Padding(
    padding: const EdgeInsets.only(top: HomeDesign.controlsToNote),
    // Two lines at most: a long folder in the refusal wraps rather than
    // reaching the recent list.
    child: Text(
      text,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: _style(ink, weight),
    ),
  );

  static TextStyle _style(Color ink, FontWeight weight) => TextStyle(
    fontSize: HomeDesign.note,
    height: 14 / HomeDesign.note,
    fontWeight: weight,
    color: ink,
  );

  /// Git's phase in its own words, how far through it, and where it lands.
  static String phaseOf(
    AppLocalizations l10n,
    CloneProgressValueObject? progress,
    String destination,
  ) {
    final String stage = switch (progress?.stage) {
      null || CloneStageEnum.starting => l10n.homeCloneStarting,
      CloneStageEnum.preparing => l10n.homeCloneCounting,
      CloneStageEnum.receiving => l10n.homeCloneReceiving,
      CloneStageEnum.resolving => l10n.homeCloneResolving,
      CloneStageEnum.checkingOut => l10n.homeCloneUpdating,
    };
    final String into = homeRelative(destination);
    return switch (progress?.percent) {
      null => l10n.homeClonePhase(stage, into),
      final int percent => l10n.homeClonePhasePercent(stage, percent, into),
    };
  }

  /// What went wrong, in a sentence that says what to do about it.
  static String sentenceOf(AppLocalizations l10n, HomeCloneFailed failed) =>
      switch (failed.failure) {
        GitRemoteNotFound() => l10n.homeCloneNoRepository,
        GitAuthenticationFailed() => switch (cloneHostOf(failed.url)) {
          null => l10n.homeCloneCredentialsAnywhere,
          final String host => l10n.homeCloneCredentials(host),
        },
        GitNetworkUnavailable() => l10n.homeCloneNoNetwork,
        GitTimedOut() => l10n.homeCloneTimedOut,
        GitCloneDestinationTaken(:final String path) =>
          l10n.homeCloneFolderTaken(homeRelative(path)),
        GitNotInstalled() => l10n.homeCloneNoGit,
        _ => l10n.homeCloneFailed,
      };
}

/// Three points of `accent_soft` with `accent` across [percent] of it, or
/// travelling along it while git gives no fraction.
class _Track extends StatelessWidget {
  const _Track({required this.percent});

  final int? percent;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('percent', percent));
  }

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    const BorderRadius round = BorderRadius.all(
      Radius.circular(HomeDesign.track / 2),
    );
    return ClipRRect(
      borderRadius: round,
      child: SizedBox(
        width: HomeDesign.column,
        height: HomeDesign.track,
        child: switch (percent) {
          null => const TomProgressBarWidget(),
          final int done => ColoredBox(
            color: colors.accentSoft,
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: done / 100,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.accent,
                    borderRadius: round,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
        },
      ),
    );
  }
}
