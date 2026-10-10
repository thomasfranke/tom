// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'changes_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Stages, unstages and commits, and holds the git column's draft on top of
/// what [GitReadingNotifier] reads.
///
/// It re-reads rather than patches: nothing can predict what git will say
/// after an operation (a deleted file staged, an editor saving underneath,
/// a rebase in another terminal), so every one ends in a reading again.
///
/// **Kept alive for the commit message being written**, which outlives the
/// column being put away; `build` still watches the open space, so leaving
/// one clears the draft — the case where dropping it is right.

@ProviderFor(ChangesNotifier)
final changesProvider = ChangesNotifierProvider._();

/// Stages, unstages and commits, and holds the git column's draft on top of
/// what [GitReadingNotifier] reads.
///
/// It re-reads rather than patches: nothing can predict what git will say
/// after an operation (a deleted file staged, an editor saving underneath,
/// a rebase in another terminal), so every one ends in a reading again.
///
/// **Kept alive for the commit message being written**, which outlives the
/// column being put away; `build` still watches the open space, so leaving
/// one clears the draft — the case where dropping it is right.
final class ChangesNotifierProvider
    extends $NotifierProvider<ChangesNotifier, ChangesState> {
  /// Stages, unstages and commits, and holds the git column's draft on top of
  /// what [GitReadingNotifier] reads.
  ///
  /// It re-reads rather than patches: nothing can predict what git will say
  /// after an operation (a deleted file staged, an editor saving underneath,
  /// a rebase in another terminal), so every one ends in a reading again.
  ///
  /// **Kept alive for the commit message being written**, which outlives the
  /// column being put away; `build` still watches the open space, so leaving
  /// one clears the draft — the case where dropping it is right.
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

String _$changesNotifierHash() => r'766bd0f5d7b89d10efc5ec643552f44b98890594';

/// Stages, unstages and commits, and holds the git column's draft on top of
/// what [GitReadingNotifier] reads.
///
/// It re-reads rather than patches: nothing can predict what git will say
/// after an operation (a deleted file staged, an editor saving underneath,
/// a rebase in another terminal), so every one ends in a reading again.
///
/// **Kept alive for the commit message being written**, which outlives the
/// column being put away; `build` still watches the open space, so leaving
/// one clears the draft — the case where dropping it is right.

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
