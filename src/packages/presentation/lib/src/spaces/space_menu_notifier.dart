/// Drives the breadcrumb's menu: where to go, and what to do about the buffer.
library;

import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/src/editor/editor_notifier.dart';
import 'package:tom_presentation/src/home/home_providers.dart';
import 'package:tom_presentation/src/spaces/space_departure.dart';
import 'package:tom_presentation/src/spaces/space_menu_state.dart';
import 'package:tom_presentation/src/spaces/space_session_notifier.dart';

part 'space_menu_notifier.g.dart';

/// The way out of a space, and the way straight into another one
/// (`docs/product/workspace/leaving-a-space/doc.md`).
///
/// It reads the same recents Home does, through the same use case: one list,
/// asked for twice, so a space forgotten on Home is gone here too.
@riverpod
class SpaceMenuNotifier extends _$SpaceMenuNotifier {
  /// Turns a folder into a space, and remembers it.
  OpenSpaceUseCase get openSpace => ref.read(openSpaceProvider);

  /// Reads the spaces to offer going back to.
  ListRecentSpacesUseCase get listRecentSpaces =>
      ref.read(listRecentSpacesProvider);

  @override
  SpaceMenuState build() {
    // Read on the way in, not when the menu opens: a list that arrives after
    // the click is a menu that changes shape under the pointer.
    unawaited(Future<void>.microtask(load));
    return const SpaceMenuState();
  }

  /// Reads the recent list.
  Future<void> load() async {
    final Result<List<RecentSpaceEntity>, AppFailure> listed =
        await listRecentSpaces.list();
    if (!ref.mounted) {
      return;
    }
    state = state.copyWith(
      recents: switch (listed) {
        Success<List<RecentSpaceEntity>, AppFailure>(
          value: final List<RecentSpaceEntity> spaces,
        ) =>
          List<RecentSpaceEntity>.unmodifiable(spaces),
        // A list that cannot be read is an empty list: `Close space` is the
        // point of this menu and it works without one.
        Failure<List<RecentSpaceEntity>, AppFailure>() =>
          const <RecentSpaceEntity>[],
      },
    );
  }

  /// Opens the menu.
  void show() => state = state.copyWith(isShowing: true);

  /// Puts it away, answering every question it was asking.
  ///
  /// A departure waiting on unsaved work is cancelled rather than left
  /// standing behind a surface nobody can see — the same rule the branch
  /// switcher follows.
  void dismiss() =>
      state = state.copyWith(isShowing: false, pending: null, failure: null);

  /// Goes to [space], asking first if that would lose unsaved work.
  Future<void> switchTo(RecentSpaceEntity space) async {
    if (state.isBusy) {
      return;
    }
    await _leave(SpaceDeparture.switching(space));
  }

  /// Leaves for the opening screen, asking first for the same reason.
  Future<void> close() => _leave(const SpaceDeparture.closing());

  /// Saves what is open, then goes where the question was about.
  Future<void> saveAndLeave() async {
    if (state.pending case final SpaceDeparture departure) {
      await ref.read(editorProvider.notifier).save();
      if (!ref.mounted) {
        return;
      }
      // A save that did not take leaves the buffer dirty, and leaving now
      // would lose exactly what the question was asked to protect.
      if (ref.read(editorProvider).isDirty) {
        return;
      }
      await _depart(departure);
    }
  }

  /// Goes anyway, letting the buffer go: nothing here writes to the disk,
  /// so discarding is simply not saving.
  Future<void> discardAndLeave() async {
    if (state.pending case final SpaceDeparture departure) {
      await _depart(departure);
    }
  }

  /// Stays, and takes the question away.
  void stay() => state = state.copyWith(pending: null);

  /// Asks about the buffer first, and departs when there is nothing to ask.
  Future<void> _leave(SpaceDeparture departure) async {
    if (ref.read(editorProvider).isDirty) {
      state = state.copyWith(pending: departure, failure: null);
      return;
    }
    await _depart(departure);
  }

  /// Does what was decided, whichever of the two it is.
  Future<void> _depart(SpaceDeparture departure) => switch (departure) {
    SpaceDepartureClosing() => _close(),
    SpaceDepartureSwitching(space: final RecentSpaceEntity space) => _open(
      space,
    ),
  };

  /// Leaves the space, which puts Home back on the window.
  Future<void> _close() async {
    state = state.copyWith(isShowing: false, pending: null);
    ref.read(spaceSessionProvider.notifier).close();
  }

  /// Opens [space], replacing the one on screen.
  ///
  /// A folder that has moved keeps the space that is open: this menu is not
  /// Home and has no screen to refuse on, so the row says so and the window
  /// does not move.
  Future<void> _open(RecentSpaceEntity space) async {
    state = state.copyWith(isBusy: true, pending: null, failure: null);
    final Result<SpaceEntity, AppFailure> opened = await openSpace.open(
      space.root,
    );
    if (!ref.mounted) {
      return;
    }
    switch (opened) {
      case Success<SpaceEntity, AppFailure>(value: final SpaceEntity it):
        state = state.copyWith(isBusy: false, isShowing: false);
        ref.read(spaceSessionProvider.notifier).open(it);
      case Failure<SpaceEntity, AppFailure>():
        state = state.copyWith(
          isBusy: false,
          failure: '${space.name} could not be opened — has it moved?',
        );
    }
  }
}
