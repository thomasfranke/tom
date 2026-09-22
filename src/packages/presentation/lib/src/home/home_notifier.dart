/// Home's state, and the three things it can be asked to do.
library;

import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/src/home/home_providers.dart';
import 'package:tom_presentation/src/home/home_state.dart';
import 'package:tom_presentation/src/spaces/space_session_notifier.dart';

part 'home_notifier.g.dart';

/// Drives the first screen: open a folder, go back to one, forget one.
///
/// **No business logic here** — it calls a use case and turns [Result] into
/// state. Pure Dart like the rest of this package, so `dart test` runs it
/// with no Flutter binding and a phone could drive the same notifier.
@riverpod
class HomeNotifier extends _$HomeNotifier {
  /// Turns a folder into a space, and remembers it.
  ///
  /// Read from the scope rather than taken in a constructor, because
  /// Riverpod builds a notifier with no arguments; what is *in* the scope is
  /// the composition root's decision.
  OpenSpaceUseCase get openSpace => ref.read(openSpaceProvider);

  /// Reads the list of spaces to offer going back to.
  ListRecentSpacesUseCase get listRecentSpaces =>
      ref.read(listRecentSpacesProvider);

  /// Drops one space from that list.
  ForgetRecentSpaceUseCase get forgetRecentSpace =>
      ref.read(forgetRecentSpaceProvider);

  @override
  HomeState build() {
    // The list is read on the way in rather than on a button: Home *is* the
    // list, and a screen offering to load its own content would be asking
    // the user to do the app's work.
    unawaited(Future<void>.microtask(load));
    return const HomeState.loading();
  }

  /// Reads the recent list.
  Future<void> load() async {
    final Result<List<RecentSpaceEntity>, AppFailure> listed =
        await listRecentSpaces.list();
    state = HomeState.ready(_recentsOf(listed));
  }

  /// Opens [folder], and takes Home out of the way if it worked.
  ///
  /// A space that opened goes to the session, which is what the window is
  /// built on: Home does not navigate anywhere and there is no route to push
  /// ([Decision
  /// 9](../../../../../../docs/technical/decisions/009-space-session-is-single-source-of-truth.md)).
  ///
  /// The recent list is kept across a failure: whatever went wrong with one
  /// folder, the others are still there to click.
  Future<void> open(String folder) async {
    state = const HomeState.loading();
    final Result<SpaceEntity, AppFailure> opened = await openSpace.open(folder);
    if (opened case Success<SpaceEntity, AppFailure>(
      value: final SpaceEntity space,
    )) {
      // Home stays on `loading`, the honest state for a screen being
      // replaced: re-reading the recent list here would write to a notifier
      // the window has already disposed.
      ref.read(spaceSessionProvider.notifier).open(space);
      return;
    }
    // The list is re-read rather than remembered: opening may have changed
    // it, and the screen the user lands on should show what is there.
    state = HomeState.failed(
      failure: (opened as Failure<SpaceEntity, AppFailure>).failure,
      recents: _recentsOf(await listRecentSpaces.list()),
    );
  }

  /// Drops [root] from the recent list, and shows what is left.
  Future<void> forget(String root) async {
    await forgetRecentSpace.forget(root);
    await load();
  }

  /// What [listed] holds, or nothing.
  ///
  /// A list that cannot be read is an empty list and never an error screen:
  /// Home's job with no recents is to offer the folder picker, which it does
  /// anyway.
  static List<RecentSpaceEntity> _recentsOf(
    Result<List<RecentSpaceEntity>, AppFailure> listed,
  ) => listed.valueOrNull ?? const <RecentSpaceEntity>[];
}
