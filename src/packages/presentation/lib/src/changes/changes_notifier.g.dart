// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'changes_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Stages, unstages and commits, and writes what git says into the session.
///
/// It re-reads rather than patches: nothing can predict what git will say
/// after an operation (a deleted file staged, an editor saving underneath,
/// a rebase in another terminal), so every one ends in `status()` again.
/// **Kept alive because it is the app's one reader of git.** The shell builds
/// the git column under `if (showingAside)`, and Riverpod disposes a notifier
/// nobody listens to — so without this, hiding the column would leave
/// `SpaceSessionState.git` and `.merge` with nobody to write them, and a
/// space opened with the column shut would have no git reading at all. It
/// also keeps the commit message being written: closing a column is not a
/// reason to throw a sentence away.
///
/// `build` still watches the open space, so leaving one clears the draft —
/// which is the case where dropping it is right.

@ProviderFor(ChangesNotifier)
final changesProvider = ChangesNotifierProvider._();

/// Stages, unstages and commits, and writes what git says into the session.
///
/// It re-reads rather than patches: nothing can predict what git will say
/// after an operation (a deleted file staged, an editor saving underneath,
/// a rebase in another terminal), so every one ends in `status()` again.
/// **Kept alive because it is the app's one reader of git.** The shell builds
/// the git column under `if (showingAside)`, and Riverpod disposes a notifier
/// nobody listens to — so without this, hiding the column would leave
/// `SpaceSessionState.git` and `.merge` with nobody to write them, and a
/// space opened with the column shut would have no git reading at all. It
/// also keeps the commit message being written: closing a column is not a
/// reason to throw a sentence away.
///
/// `build` still watches the open space, so leaving one clears the draft —
/// which is the case where dropping it is right.
final class ChangesNotifierProvider
    extends $NotifierProvider<ChangesNotifier, ChangesState> {
  /// Stages, unstages and commits, and writes what git says into the session.
  ///
  /// It re-reads rather than patches: nothing can predict what git will say
  /// after an operation (a deleted file staged, an editor saving underneath,
  /// a rebase in another terminal), so every one ends in `status()` again.
  /// **Kept alive because it is the app's one reader of git.** The shell builds
  /// the git column under `if (showingAside)`, and Riverpod disposes a notifier
  /// nobody listens to — so without this, hiding the column would leave
  /// `SpaceSessionState.git` and `.merge` with nobody to write them, and a
  /// space opened with the column shut would have no git reading at all. It
  /// also keeps the commit message being written: closing a column is not a
  /// reason to throw a sentence away.
  ///
  /// `build` still watches the open space, so leaving one clears the draft —
  /// which is the case where dropping it is right.
  ChangesNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'changesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$changesNotifierHash();

  @$internal
  @override
  ChangesNotifier create() => ChangesNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChangesState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChangesState>(value),
    );
  }
}

String _$changesNotifierHash() => r'6c3cafef21d907723c2d34b5b522ee692d449017';

/// Stages, unstages and commits, and writes what git says into the session.
///
/// It re-reads rather than patches: nothing can predict what git will say
/// after an operation (a deleted file staged, an editor saving underneath,
/// a rebase in another terminal), so every one ends in `status()` again.
/// **Kept alive because it is the app's one reader of git.** The shell builds
/// the git column under `if (showingAside)`, and Riverpod disposes a notifier
/// nobody listens to — so without this, hiding the column would leave
/// `SpaceSessionState.git` and `.merge` with nobody to write them, and a
/// space opened with the column shut would have no git reading at all. It
/// also keeps the commit message being written: closing a column is not a
/// reason to throw a sentence away.
///
/// `build` still watches the open space, so leaving one clears the draft —
/// which is the case where dropping it is right.

abstract class _$ChangesNotifier extends $Notifier<ChangesState> {
  ChangesState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ChangesState, ChangesState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ChangesState, ChangesState>,
              ChangesState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
