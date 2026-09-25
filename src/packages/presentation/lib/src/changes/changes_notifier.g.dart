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

@ProviderFor(ChangesNotifier)
final changesProvider = ChangesNotifierProvider._();

/// Stages, unstages and commits, and writes what git says into the session.
///
/// It re-reads rather than patches: nothing can predict what git will say
/// after an operation (a deleted file staged, an editor saving underneath,
/// a rebase in another terminal), so every one ends in `status()` again.
final class ChangesNotifierProvider
    extends $NotifierProvider<ChangesNotifier, ChangesState> {
  /// Stages, unstages and commits, and writes what git says into the session.
  ///
  /// It re-reads rather than patches: nothing can predict what git will say
  /// after an operation (a deleted file staged, an editor saving underneath,
  /// a rebase in another terminal), so every one ends in `status()` again.
  ChangesNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'changesProvider',
        isAutoDispose: true,
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

String _$changesNotifierHash() => r'539fc399395843ad86cbe927267f18734e4ffa49';

/// Stages, unstages and commits, and writes what git says into the session.
///
/// It re-reads rather than patches: nothing can predict what git will say
/// after an operation (a deleted file staged, an editor saving underneath,
/// a rebase in another terminal), so every one ends in `status()` again.

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
