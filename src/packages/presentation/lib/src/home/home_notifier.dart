/// Home's state, and the three things it can be asked to do.
library;

import 'dart:async';

import 'package:riverpod/riverpod.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/src/home/home_providers.dart';
import 'package:tom_presentation/src/home/home_state.dart';

/// Drives the first screen: open a folder, go back to one, forget one.
///
/// **No business logic here.** It calls a use case and turns [Result] into
/// state, and that is the whole job
/// ([flows](../../../../../docs/technical/flows.md)). Deciding what a folder
/// is, what gets remembered and what a failure means all happened before the
/// result arrived.
///
/// Pure Dart, like everything in this package: it is tested by `dart test`
/// with no Flutter binding, and the same notifier drives a phone when one
/// arrives ([Decision
/// 14](../../../../../docs/technical/decisions/014-each-layer-is-its-own-package.md)).
class HomeNotifier extends Notifier<HomeState> {
  /// Turns a folder into a space, and remembers it.
  ///
  /// Read from the scope rather than taken in a constructor, because
  /// Riverpod builds a notifier with no arguments. What is *in* the scope is
  /// the composition root's decision — see `home_providers.dart`.
  OpenSpace get openSpace => ref.read(openSpaceProvider);

  /// Reads the list of spaces to offer going back to.
  ListRecentSpaces get listRecentSpaces => ref.read(listRecentSpacesProvider);

  /// Drops one space from that list.
  ForgetRecentSpace get forgetRecentSpace =>
      ref.read(forgetRecentSpaceProvider);

  @override
  HomeState build() {
    // The list is read on the way in rather than on a button, because Home
    // *is* the list: a screen that offered to load its own content would be
    // asking the user to do the app's work. Scheduled rather than awaited,
    // because `build` produces the first state synchronously and the first
    // state is "reading it".
    unawaited(Future<void>.microtask(load));
    return const HomeState.loading();
  }

  /// Reads the recent list.
  Future<void> load() async {
    final Result<List<RecentSpace>> listed = await listRecentSpaces();
    state = HomeState.ready(_recentsOf(listed));
  }

  /// Opens [folder], and takes Home out of the way if it worked.
  ///
  /// The recent list is kept across a failure: whatever went wrong with one
  /// folder, the others are still there to click.
  Future<void> open(String folder) async {
    state = const HomeState.loading();
    final Result<Space> opened = await openSpace(folder);
    if (opened case Success<Space>(value: final Space space)) {
      state = HomeState.opened(space);
      return;
    }
    // The list is re-read rather than remembered from before: opening may
    // have changed it, and the screen the user lands on should show what is
    // actually there.
    state = HomeState.failed(
      failure: (opened as Failure<Space>).failure,
      recents: _recentsOf(await listRecentSpaces()),
    );
  }

  /// Drops [root] from the recent list, and shows what is left.
  Future<void> forget(String root) async {
    await forgetRecentSpace(root);
    await load();
  }

  /// What [listed] holds, or nothing.
  ///
  /// A list that cannot be read is an empty list and never an error screen:
  /// the use case below already treats it as a convenience, and Home's job
  /// with no recents is to offer the folder picker — which it does anyway.
  static List<RecentSpace> _recentsOf(Result<List<RecentSpace>> listed) =>
      switch (listed) {
        Success<List<RecentSpace>>(value: final List<RecentSpace> recents) =>
          recents,
        Failure<List<RecentSpace>>() => const <RecentSpace>[],
      };
}
