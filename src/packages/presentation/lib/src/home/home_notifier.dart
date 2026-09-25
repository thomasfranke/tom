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
/// No business logic here — it calls a use case and turns [Result] into
/// state.
@riverpod
class HomeNotifier extends _$HomeNotifier {
  /// Turns a folder into a space, and remembers it.
  ///
  /// Read from the scope rather than a constructor, because Riverpod builds
  /// a notifier with no arguments.
  OpenSpaceUseCase get openSpace => ref.read(openSpaceProvider);

  /// Reads the list of spaces to offer going back to.
  ListRecentSpacesUseCase get listRecentSpaces =>
      ref.read(listRecentSpacesProvider);

  /// Drops one space from that list.
  ForgetRecentSpaceUseCase get forgetRecentSpace =>
      ref.read(forgetRecentSpaceProvider);

  @override
  HomeState build() {
    // Home *is* the list, so it is read on the way in rather than on a button.
    unawaited(Future<void>.microtask(load));
    return const HomeState.loading();
  }

  /// Reads the recent list.
  Future<void> load() async {
    final Result<List<RecentSpaceEntity>, AppFailure> listed =
        await listRecentSpaces.list();
    if (!ref.mounted) {
      return;
    }
    state = HomeState.ready(_recentsOf(listed));
  }

  /// Opens [folder], and takes Home out of the way if it worked.
  ///
  /// A space that opened goes to the session; there is no route to push
  /// ([Decision
  /// 9](../../../../../../docs/technical/decisions/009-space-session-is-single-source-of-truth.md)).
  /// The recents are kept across a failure: the other rows still click.
  Future<void> open(String folder) async {
    state = const HomeState.loading();
    final Result<SpaceEntity, AppFailure> opened = await openSpace.open(folder);
    // The window can be gone by the time git answers, and a disposed
    // notifier has no `Ref` to write with.
    if (!ref.mounted) {
      return;
    }
    if (opened case Success<SpaceEntity, AppFailure>(
      value: final SpaceEntity space,
    )) {
      // Home stays on `loading`: re-reading the recents here would write to
      // a notifier the window has already disposed.
      ref.read(spaceSessionProvider.notifier).open(space);
      return;
    }
    // Re-read rather than remembered, because opening may have changed it.
    final Result<List<RecentSpaceEntity>, AppFailure> listed =
        await listRecentSpaces.list();
    if (!ref.mounted) {
      return;
    }
    state = HomeState.failed(
      failure: (opened as Failure<SpaceEntity, AppFailure>).failure,
      recents: _recentsOf(listed),
    );
  }

  /// Drops [root] from the recent list, and shows what is left.
  Future<void> forget(String root) async {
    await forgetRecentSpace.forget(root);
    if (!ref.mounted) {
      return;
    }
    await load();
  }

  /// What [listed] holds, or nothing.
  ///
  /// A list that cannot be read is an empty list, never an error screen: the
  /// folder picker is offered anyway.
  static List<RecentSpaceEntity> _recentsOf(
    Result<List<RecentSpaceEntity>, AppFailure> listed,
  ) => listed.valueOrNull ?? const <RecentSpaceEntity>[];
}
