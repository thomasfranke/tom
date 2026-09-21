/// The first screen anyone sees.
library;

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_desktop/theme/tom_colors.dart';
import 'package:tom_desktop/theme/tom_metrics.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';

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
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(TomMetrics.pad * 2),
                child: switch (state) {
                  HomeInitial() || HomeLoading() => const _Working(),
                  HomeReady(recents: final List<RecentSpace> recents) =>
                    _Welcome(recents: recents),
                  HomeFailed(
                    failure: final AppFailure failure,
                    recents: final List<RecentSpace> recents,
                  ) =>
                    _Refused(failure: failure, recents: recents),
                  // Nothing, deliberately: the shell has taken over and
                  // this frame is on its way out. A spinner here would be
                  // an animation that never ends, because nothing is
                  // coming — which is also what made a widget test hang.
                  HomeOpened() => const SizedBox.shrink(),
                },
              ),
            ),
          ),
          _StatusStrip(colors: colors),
        ],
      ),
    );
  }
}

/// Asks the user for a folder and opens it.
///
/// The picker is a Flutter plugin and can only live in this package, which
/// is why nothing below takes a folder from anywhere but its own arguments.
/// A cancelled picker is not a failure and not a state: the user changed
/// their mind, and the screen does not move.
Future<void> _chooseFolder(WidgetRef ref) async {
  final String? folder = await getDirectoryPath();
  if (folder != null) {
    await ref.read(homeProvider.notifier).open(folder);
  }
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
        Text(
          'TOM',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Team-Oriented Markdown',
          style: TextStyle(fontSize: 16, color: colors.textSecondary),
        ),
        const SizedBox(height: 4),
        Text(
          'A Git client built for documentation, not code.',
          style: TextStyle(fontSize: 13, color: colors.textMuted),
        ),
        const SizedBox(height: 40),
        FilledButton(
          onPressed: () => _chooseFolder(ref),
          child: const Text('Choose folder…'),
        ),
        const SizedBox(height: 12),
        // M3, and shown disabled rather than hidden: the wireframe puts it
        // here, and a button that appears later moves everything under it.
        const Tooltip(
          message: 'Cloning arrives in M3',
          child: OutlinedButton(onPressed: null, child: Text('Clone from URL')),
        ),
        if (recents.isNotEmpty) ...<Widget>[
          const SizedBox(height: 40),
          _RecentList(recents: recents),
        ],
      ],
    );
  }
}

/// The one way opening a folder fails, and everything else.
class _Refused extends ConsumerWidget {
  const _Refused({required this.failure, required this.recents});

  /// Why the folder did not open.
  final AppFailure failure;

  /// What is still there to go back to.
  final List<RecentSpace> recents;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<AppFailure>('failure', failure))
      ..add(IterableProperty<RecentSpace>('recents', recents));
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
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        if (said.$2 case final String path) ...<Widget>[
          const SizedBox(height: 12),
          SelectableText(
            path,
            style: TextStyle(
              fontFamily: 'Menlo',
              fontSize: 13,
              color: colors.textSecondary,
            ),
          ),
        ],
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Text(
            said.$3,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: colors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 28),
        FilledButton(
          onPressed: () => _chooseFolder(ref),
          child: const Text('Choose another folder…'),
        ),
        const SizedBox(height: 28),
        // The line the product insists on: TOM never creates a repository on
        // the user's behalf, and says so rather than leaving them looking
        // for the button.
        Text(
          'Creating a repository is not something TOM does.',
          style: TextStyle(fontSize: 12, color: colors.textMuted),
        ),
        if (recents.isNotEmpty) ...<Widget>[
          const SizedBox(height: 40),
          _RecentList(recents: recents),
        ],
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
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Recent',
            style: TextStyle(
              fontSize: 12,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w600,
              color: colors.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          for (final RecentSpace recent in recents) _RecentRow(recent: recent),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextButton(
              onPressed: () =>
                  ref.read(homeProvider.notifier).open(recent.root),
              style: TextButton.styleFrom(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    recent.name,
                    style: TextStyle(fontSize: 14, color: colors.textPrimary),
                  ),
                  Text(
                    recent.root,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: colors.textMuted),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            tooltip: 'Forget this space',
            onPressed: () =>
                ref.read(homeProvider.notifier).forget(recent.root),
            icon: const Icon(Icons.close, size: 16),
          ),
        ],
      ),
    );
  }
}

/// Home's status bar.
///
/// Both wireframes draw it, and both say the same thing — which is the
/// honest amount of status there is with nothing open.
class _StatusStrip extends StatelessWidget {
  const _StatusStrip({required this.colors});

  /// The palette in scope.
  final TomColors colors;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<TomColors>('colors', colors));
  }

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      Divider(height: 1, color: colors.border),
      SizedBox(
        height: TomMetrics.statusBar,
        child: ColoredBox(
          color: colors.surfaceSunken,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: TomMetrics.padTight,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'no space open',
                style: TextStyle(fontSize: 12, color: colors.textMuted),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

/// Something is happening and there is nothing to decide yet.
class _Working extends StatelessWidget {
  const _Working();

  @override
  Widget build(BuildContext context) => const SizedBox(
    width: 24,
    height: 24,
    child: CircularProgressIndicator(strokeWidth: 2),
  );
}
