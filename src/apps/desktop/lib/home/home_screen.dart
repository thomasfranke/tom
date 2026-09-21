/// The first screen anyone sees.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_desktop/brand/tom_wordmark.dart';
import 'package:tom_desktop/home/folder_picker.dart';
import 'package:tom_desktop/theme/tom_colors.dart';
import 'package:tom_desktop/theme/tom_metrics.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';

/// What the design fixes about this screen.
///
/// Transcribed from
/// [`homeEmpty()` and `homeNotARepo()`](../../../../../docs/technical/design/tools/penpot_screens.js),
/// which are what the mocks in `docs/product/home/mocks/` are generated
/// from — so these are the drawing's own numbers rather than a reading of
/// the picture, and **when the two disagree the drawing is right**
/// (`docs/technical/design/README.md`).
///
/// The design targets a 1440×900 window. Everything horizontal is centred
/// and everything vertical is a gap between two things, so the layout holds
/// at any size; the one number that would not survive is where the block
/// sits in the empty space, and [_Canvas] keeps that as a proportion.
abstract final class _Mock {
  /// The width the ways in share.
  static const double column = 440;

  /// A button, and the field that is not one yet.
  static const double control = 48;

  /// Corner radius: controls, then cards and pills.
  static const double controlRadius = 8;
  static const double cardRadius = 10;

  /// The milestone chip, and the gutter that keeps the column centred
  /// despite it: the design hangs the chip *outside* the column rather than
  /// inside, so the clone control lines up with the one above it.
  static const double chip = 30;
  static const double chipHeight = 20;
  static const double chipGutter = chip + TomMetrics.padTight;

  /// One row of the recent list.
  static const double row = 60;

  /// Row edge to its content.
  static const double rowPad = 20;

  /// Card edge to the rule between two rows.
  static const double rulePad = 16;

  /// The gaps down the empty state, each from the bottom of what is above.
  static const double wordmarkToExpansion = 11.2;
  static const double expansionToTagline = 5.6;
  static const double taglineToChoose = 51.5;
  static const double chooseToClone = 12;
  static const double cloneToRecent = 38;
  static const double recentToCard = 8;

  /// The gaps down the refusal.
  static const double headingToPath = 18.3;
  static const double pathToBody = 26;
  static const double bodyToRetry = 38.5;
  static const double retryToHint = 20;

  /// The refusal's measures.
  static const double pathBox = 30;
  static const double pathLine = 16;
  static const double body = 560;
  static const double retry = 280;
}

/// Home: open a space, or go back to one.
///
/// Two states the product draws as two screens
/// (`docs/product/home/mocks/`): the empty state, and the one way opening a
/// folder fails. The wording here is the wireframes' own — they are the
/// source for what is on the screen, and when code and wireframe disagree
/// the wireframe is right (`docs/technical/design/README.md`).
class HomeScreen extends ConsumerWidget {
  /// Creates the screen.
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final HomeState state = ref.watch(homeProvider);
    final TomColors colors = TomColors.of(context);
    return Scaffold(
      backgroundColor: colors.surface,
      body: Column(
        children: <Widget>[
          const _TopStrip(),
          Expanded(
            child: switch (state) {
              HomeInitial() || HomeLoading() => const _Canvas(
                above: 1,
                below: 1,
                child: _Working(),
              ),
              HomeReady(recents: final List<RecentSpace> recents) => _Canvas(
                // 98 above and 166 below, on the 900-tall window the design
                // was drawn for. Kept as a ratio rather than as a top
                // padding so a taller window does not leave the block
                // hugging the chrome.
                above: 98,
                below: 166,
                child: _Welcome(recents: recents),
              ),
              HomeFailed(failure: final AppFailure failure) => _Canvas(
                above: 248,
                below: 288.5,
                child: _Refused(failure: failure),
              ),
              // Nothing, deliberately: the shell has taken over and this
              // frame is on its way out. A spinner here would be an
              // animation that never ends, because nothing is coming —
              // which is also what made a widget test hang.
              HomeOpened() => const SizedBox.shrink(),
            },
          ),
          const _StatusStrip(),
        ],
      ),
    );
  }
}

/// Asks the user for a folder and opens it.
///
/// The picker comes from a provider rather than from `file_selector`
/// directly — see [folderPickerProvider] for why, and for who replaces it.
/// A cancelled picker is not a failure and not a state: the user changed
/// their mind, and the screen does not move.
Future<void> _chooseFolder(WidgetRef ref) async {
  final String? folder = await ref.read(folderPickerProvider)();
  if (folder != null) {
    await ref.read(homeProvider.notifier).open(folder);
  }
}

/// The body between the two bars, with the content where the design put it.
///
/// [above] and [below] are the design's own empty space in pixels; only
/// their ratio is used, so the block sits a third of the way down whatever
/// window it is given rather than at a fixed offset that centres wrongly on
/// every other size. It scrolls when the window is shorter than the content,
/// which the minimum window height allows.
class _Canvas extends StatelessWidget {
  const _Canvas({
    required this.above,
    required this.below,
    required this.child,
  });

  /// The design's empty space over the content.
  final double above;

  /// The design's empty space under it.
  final double below;

  /// What sits between them.
  final Widget child;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DoubleProperty('above', above))
      ..add(DoubleProperty('below', below));
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (BuildContext context, BoxConstraints constraints) =>
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: TomMetrics.pad),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight - TomMetrics.pad * 2,
            ),
            child: Align(
              alignment: Alignment(0, above / (above + below) * 2 - 1),
              child: child,
            ),
          ),
        ),
  );
}

/// The empty state: brand, the ways in, and what was open before.
class _Welcome extends ConsumerWidget {
  const _Welcome({required this.recents});

  /// What to offer going back to.
  final List<RecentSpace> recents;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<RecentSpace>('recents', recents));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TomColors colors = TomColors.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        TomWordmark(letters: colors.textPrimary, commit: colors.accent),
        const SizedBox(height: _Mock.wordmarkToExpansion),
        Text(
          'Team-Oriented Markdown',
          style: TextStyle(
            fontSize: 16,
            height: 1.4,
            fontWeight: FontWeight.w500,
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: _Mock.expansionToTagline),
        Text(
          'A Git client built for documentation, not code.',
          style: TextStyle(fontSize: 15, height: 1.5, color: colors.textMuted),
        ),
        const SizedBox(height: _Mock.taglineToChoose),
        _Primary(label: 'Choose folder…', onPressed: () => _chooseFolder(ref)),
        const SizedBox(height: _Mock.chooseToClone),
        // M3, and shown disabled rather than hidden: the design puts it
        // here, and a control that appears later moves everything under it.
        // The chip beside it is what says *later* — the row is as wide as
        // the column plus the chip, so the column itself stays centred.
        const Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(width: _Mock.chipGutter),
            Tooltip(
              message: 'Cloning arrives in M3',
              child: _Secondary(label: 'Clone from URL'),
            ),
            SizedBox(width: TomMetrics.padTight),
            _Chip(label: 'M3'),
          ],
        ),
        if (recents.isNotEmpty) ...<Widget>[
          const SizedBox(height: _Mock.cloneToRecent),
          _RecentList(recents: recents),
        ],
      ],
    );
  }
}

/// The one way opening a folder fails, and everything else.
///
/// No recent list: the design draws this screen with the retry and the one
/// line about repositories, and nothing else. It is a state to move on from
/// in one click, and a second list of choices underneath would make the
/// first one look optional.
class _Refused extends ConsumerWidget {
  const _Refused({required this.failure});

  /// Why the folder did not open.
  final AppFailure failure;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<AppFailure>('failure', failure));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TomColors colors = TomColors.of(context);
    final (String headline, String? path, String explanation) said =
        switch (failure) {
          GitNotARepository(path: final String folder) => (
            'That folder is not inside a Git repository',
            folder,
            'TOM works on documentation that is already versioned. Open a '
                'folder inside a repository — the repository root, or any '
                'folder within it.',
          ),
          SpaceFolderMissing(root: final String root) => (
            'That folder is no longer there',
            root,
            'It may be on a disk that is not connected, or it was moved or '
                'renamed outside TOM.',
          ),
          GitNotInstalled() => (
            'TOM cannot find git on this machine',
            null,
            'TOM drives the git you already have. Install it, or make sure it '
                'is on your PATH, and try again.',
          ),
          _ => ('That folder could not be opened', null, failure.toString()),
        };
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          said.$1,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            height: 1.35,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        if (said.$2 case final String path) ...<Widget>[
          const SizedBox(height: _Mock.headingToPath),
          // A box, not a bare line: the folder is the one piece of this
          // screen the user did not write, and it reads as quoted.
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surfaceSunken,
              borderRadius: BorderRadius.circular(_Mock.controlRadius),
            ),
            // Padded to the design's height rather than given it: a box
            // that is *told* how tall it is needs something inside to
            // centre the text, and anything that centres also takes every
            // pixel of width it is offered — which drew the quote as a band
            // across the window.
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: TomMetrics.pad,
                vertical: (_Mock.pathBox - _Mock.pathLine) / 2,
              ),
              child: SelectableText(
                path,
                style: TextStyle(
                  fontFamily: 'Menlo',
                  fontSize: 13.5,
                  height: _Mock.pathLine / 13.5,
                  color: colors.textSecondary,
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: _Mock.pathToBody),
        SizedBox(
          width: _Mock.body,
          child: Text(
            said.$3,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              height: 1.65,
              color: colors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: _Mock.bodyToRetry),
        _Primary(
          label: 'Choose another folder…',
          width: _Mock.retry,
          onPressed: () => _chooseFolder(ref),
        ),
        const SizedBox(height: _Mock.retryToHint),
        // The line the product insists on: TOM never creates a repository on
        // the user's behalf, and says so rather than leaving them looking
        // for the button.
        Text(
          'Creating a repository is not something TOM does.',
          style: TextStyle(fontSize: 13, height: 1.5, color: colors.textMuted),
        ),
      ],
    );
  }
}

/// The spaces to go back to, one click each.
class _RecentList extends ConsumerWidget {
  const _RecentList({required this.recents});

  /// What to show, newest first.
  final List<RecentSpace> recents;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<RecentSpace>('recents', recents));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TomColors colors = TomColors.of(context);
    return SizedBox(
      width: _Mock.column,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'RECENT',
            style: TextStyle(
              fontSize: 10,
              height: 1.4,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
              color: colors.textMuted,
            ),
          ),
          const SizedBox(height: _Mock.recentToCard),
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surfaceRaised,
              border: Border.all(color: colors.border),
              borderRadius: BorderRadius.circular(_Mock.cardRadius),
            ),
            child: Column(
              children: <Widget>[
                for (final (int i, RecentSpace recent)
                    in recents.indexed) ...<Widget>[
                  if (i > 0)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: _Mock.rulePad - 1,
                      ),
                      child: Divider(height: 1, color: colors.border),
                    ),
                  _RecentRow(recent: recent),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One row of the recent list.
class _RecentRow extends ConsumerWidget {
  const _RecentRow({required this.recent});

  /// The space this row offers.
  final RecentSpace recent;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<RecentSpace>('recent', recent));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TomColors colors = TomColors.of(context);
    return InkWell(
      onTap: () => ref.read(homeProvider.notifier).open(recent.root),
      child: SizedBox(
        height: _Mock.row,
        child: Row(
          children: <Widget>[
            const SizedBox(width: _Mock.rowPad),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    recent.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                      color: colors.textPrimary,
                    ),
                  ),
                  Text(
                    recent.root,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: colors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            // Where the design puts the branch this space is on. It is not
            // drawn yet and the row says why: a `RecentSpace` is what can be
            // remembered *without asking git*, and a branch for every row is
            // a disk read per row of a list the user may not click.
            IconButton(
              tooltip: 'Forget this space',
              onPressed: () =>
                  ref.read(homeProvider.notifier).forget(recent.root),
              iconSize: 16,
              color: colors.textMuted,
              icon: const Icon(Icons.close),
            ),
            const SizedBox(width: _Mock.rowPad - TomMetrics.padTight),
          ],
        ),
      ),
    );
  }
}

/// The primary way forward.
class _Primary extends StatelessWidget {
  const _Primary({
    required this.label,
    required this.onPressed,
    this.width = _Mock.column,
  });

  /// What it says.
  final String label;

  /// What it does.
  final VoidCallback onPressed;

  /// How wide the design draws it.
  final double width;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('label', label))
      ..add(DoubleProperty('width', width))
      ..add(
        ObjectFlagProperty<VoidCallback>.has('onPressed', onPressed),
      );
  }

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: colors.accent,
        foregroundColor: colors.surfaceRaised,
        fixedSize: Size(width, _Mock.control),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_Mock.controlRadius),
        ),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
      child: Text(label),
    );
  }
}

/// A way forward that is not open yet.
class _Secondary extends StatelessWidget {
  const _Secondary({required this.label});

  /// What it says.
  final String label;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('label', label));
  }

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    return OutlinedButton(
      onPressed: null,
      style: OutlinedButton.styleFrom(
        disabledForegroundColor: colors.textMuted,
        side: BorderSide(color: colors.borderStrong),
        fixedSize: const Size(_Mock.column, _Mock.control),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_Mock.controlRadius),
        ),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      child: Text(label),
    );
  }
}

/// The milestone something arrives in.
class _Chip extends StatelessWidget {
  const _Chip({required this.label});

  /// The milestone.
  final String label;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('label', label));
  }

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    return Container(
      width: _Mock.chip,
      height: _Mock.chipHeight,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: colors.borderStrong),
        borderRadius: BorderRadius.circular(_Mock.cardRadius),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          height: 1.4,
          fontWeight: FontWeight.w600,
          color: colors.textMuted,
        ),
      ),
    );
  }
}

/// The bar above everything.
///
/// Empty here, and drawn anyway: the design gives Home the same chrome as
/// every other screen, so opening a space changes what is *in* the window
/// and not the shape of it.
class _TopStrip extends StatelessWidget {
  const _TopStrip();

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    return _Bar(
      colors: colors,
      height: TomMetrics.topBar,
      rule: _Edge.bottom,
      child: const SizedBox.shrink(),
    );
  }
}

/// Home's status bar.
///
/// Both mocks draw it, and both say the same thing — which is the honest
/// amount of status there is with nothing open.
class _StatusStrip extends StatelessWidget {
  const _StatusStrip();

  @override
  Widget build(BuildContext context) {
    final TomColors colors = TomColors.of(context);
    return _Bar(
      colors: colors,
      height: TomMetrics.statusBar,
      rule: _Edge.top,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: TomMetrics.pad + 4),
          child: Text(
            'no space open',
            style: TextStyle(fontSize: 11, color: colors.textMuted),
          ),
        ),
      ),
    );
  }
}

/// Which edge a bar's rule sits on.
enum _Edge { top, bottom }

/// One of the two bars: a fixed height, a raised fill, and one hairline.
///
/// The rule is *inside* the height rather than added to it, because that is
/// what the design measures — a bar plus a divider would make every screen
/// one pixel taller than the drawing it came from.
class _Bar extends StatelessWidget {
  const _Bar({
    required this.colors,
    required this.height,
    required this.rule,
    required this.child,
  });

  /// The palette in scope.
  final TomColors colors;

  /// How tall, rule included.
  final double height;

  /// Where the hairline goes.
  final _Edge rule;

  /// What the bar holds.
  final Widget child;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<TomColors>('colors', colors))
      ..add(DoubleProperty('height', height))
      ..add(EnumProperty<_Edge>('rule', rule));
  }

  @override
  Widget build(BuildContext context) {
    final BorderSide side = BorderSide(color: colors.border);
    return Container(
      // Both, and the width is not redundant: a `Container` with a height
      // and no width sizes itself to its child, and the top bar's child is
      // nothing at all — which drew a bar zero pixels wide.
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: colors.surfaceRaised,
        border: Border(
          top: rule == _Edge.top ? side : BorderSide.none,
          bottom: rule == _Edge.bottom ? side : BorderSide.none,
        ),
      ),
      child: child,
    );
  }
}

/// Something is happening and there is nothing to decide yet.
///
/// Text rather than a spinner, and the reason is not taste. Reading the
/// recent list takes a few milliseconds — a spinner would be a flicker
/// nobody sees. What it *would* do is animate forever if the read never
/// finished, which turns a stuck app into a stuck app that looks busy, and
/// turns an end-to-end failure into a run that hangs until the harness
/// gives up ten minutes later with nothing to say.
///
/// A loading state that cannot animate forever is one that always fails
/// loudly.
class _Working extends StatelessWidget {
  const _Working();

  @override
  Widget build(BuildContext context) => Text(
    'Opening…',
    style: TextStyle(fontSize: 13, color: TomColors.of(context).textMuted),
  );
}
