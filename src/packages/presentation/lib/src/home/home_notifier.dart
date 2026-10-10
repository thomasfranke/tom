/// Home's state, and the things it can be asked to do.
library;

import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/src/commands/command_action_enum.dart';
import 'package:tom_presentation/src/commands/command_scope.dart';
import 'package:tom_presentation/src/home/clone_address.dart';
import 'package:tom_presentation/src/home/home_clone_state.dart';
import 'package:tom_presentation/src/home/home_providers.dart';
import 'package:tom_presentation/src/home/home_state.dart';
import 'package:tom_presentation/src/spaces/space_session_notifier.dart';

part 'home_notifier.g.dart';

/// Drives the first screen: open a folder, clone one, go back to one,
/// forget one.
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

  /// Clones a repository by URL and opens it.
  CloneRepositoryUseCase get cloneRepository =>
      ref.read(cloneRepositoryProvider);

  /// Reads the recent list.
  ///
  /// The clone field survives it, because forgetting a row while it is open
  /// reads the list again.
  Future<void> load() async {
    final Result<List<RecentSpaceEntity>, AppFailure> listed =
        await listRecentSpaces.list();
    if (!ref.mounted) {
      return;
    }
    state = switch (state) {
      final HomeReady ready => ready.copyWith(recents: _recentsOf(listed)),
      _ => HomeState.ready(_recentsOf(listed)),
    };
  }

  /// Turns `Clone from URL` into the field.
  void showClone() {
    if (state case final HomeReady ready when ready.clone is HomeCloneClosed) {
      state = ready.copyWith(clone: const HomeCloneState.open());
    }
  }

  /// Puts the button back; a clone in flight cannot be called back, so it
  /// keeps the field.
  void closeClone() {
    if (state case final HomeReady ready
        when ready.clone is! HomeCloneCloning) {
      state = ready.copyWith(clone: const HomeCloneState.closed());
    }
  }

  /// Clones [url] into a folder of its own inside [parent], named the way
  /// `git clone` names it, then opens it as [open] would.
  ///
  /// A blank address does nothing, and one that names no folder is refused
  /// before git is asked.
  Future<void> clone({required String url, required String parent}) async {
    final String address = url.trim();
    final HomeState before = state;
    if (address.isEmpty ||
        before is! HomeReady ||
        before.clone is HomeCloneCloning) {
      return;
    }
    final String? name = cloneFolderNameOf(address);
    if (name == null) {
      state = before.copyWith(
        clone: HomeCloneState.failed(
          url: address,
          failure: const GitRemoteNotFound(),
        ),
      );
      return;
    }
    final String destination = cloneDestinationIn(parent, name);
    state = before.copyWith(
      clone: HomeCloneState.cloning(url: address, destination: destination),
    );
    final Result<SpaceEntity, AppFailure> cloned = await CommandScope.run(
      CommandActionEnum.cloneRepository,
      () => cloneRepository.clone(
        url: address,
        destination: destination,
        onProgress: _report,
      ),
    );
    if (!ref.mounted) {
      return;
    }
    switch (cloned) {
      case Success<SpaceEntity, AppFailure>(value: final SpaceEntity space):
        // Home stays as it is, for the reason [open] gives.
        ref.read(spaceSessionProvider.notifier).open(space);
      // Refused, nothing was cloned and nothing failed: the field is back
      // as it was before the press.
      case Failure<SpaceEntity, AppFailure>(
        failure: AppFailure(isDenial: true),
      ):
        if (state case final HomeReady ready) {
          state = ready.copyWith(clone: const HomeCloneState.open());
        }
      case Failure<SpaceEntity, AppFailure>(failure: final AppFailure failure):
        if (state case final HomeReady ready) {
          state = ready.copyWith(
            clone: HomeCloneState.failed(url: address, failure: failure),
          );
        }
    }
  }

  /// Writes git's latest stage onto the clone in flight.
  void _report(CloneProgressValueObject progress) {
    if (!ref.mounted) {
      return;
    }
    if (state case HomeReady(clone: final HomeCloneCloning cloning)) {
      state = (state as HomeReady).copyWith(
        clone: cloning.copyWith(progress: progress),
      );
    }
  }

  /// Opens [folder], and takes Home out of the way if it worked.
  ///
  /// A space that opened goes to the session; there is no route to push
  /// ([Decision
  /// 9](../../../../../../docs/technical/decisions/009-space-session-is-single-source-of-truth.md)).
  /// The recents are kept across a failure: the other rows still click.
  Future<void> open(String folder) async {
    state = const HomeState.loading();
    final Result<SpaceEntity, AppFailure> opened = await CommandScope.run(
      CommandActionEnum.openSpace,
      () => openSpace.open(folder),
    );
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
    final AppFailure failure =
        (opened as Failure<SpaceEntity, AppFailure>).failure;
    // Refused, the folder was not opened and Home is the list again, with
    // nothing to say about it.
    state = failure.isDenial
        ? HomeState.ready(_recentsOf(listed))
        : HomeState.failed(failure: failure, recents: _recentsOf(listed));
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
