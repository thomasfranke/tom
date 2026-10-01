// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'branches_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Switches branches, starts them, and refuses to lose work doing either.
///
/// A switch rewrites the working tree, so it ends by re-reading the status,
/// the folder and the open buffer, in that order. It reads no git status of
/// its own — [ChangesNotifier] does, so the window keeps one source.

@ProviderFor(BranchesNotifier)
final branchesProvider = BranchesNotifierProvider._();

/// Switches branches, starts them, and refuses to lose work doing either.
///
/// A switch rewrites the working tree, so it ends by re-reading the status,
/// the folder and the open buffer, in that order. It reads no git status of
/// its own — [ChangesNotifier] does, so the window keeps one source.
final class BranchesNotifierProvider
    extends $NotifierProvider<BranchesNotifier, BranchesState> {
  /// Switches branches, starts them, and refuses to lose work doing either.
  ///
  /// A switch rewrites the working tree, so it ends by re-reading the status,
  /// the folder and the open buffer, in that order. It reads no git status of
  /// its own — [ChangesNotifier] does, so the window keeps one source.
  BranchesNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'branchesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$branchesNotifierHash();

  @$internal
  @override
  BranchesNotifier create() => BranchesNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BranchesState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BranchesState>(value),
    );
  }
}

String _$branchesNotifierHash() => r'c719bb64885a43568685bcabb9803bc2a06f1444';

/// Switches branches, starts them, and refuses to lose work doing either.
///
/// A switch rewrites the working tree, so it ends by re-reading the status,
/// the folder and the open buffer, in that order. It reads no git status of
/// its own — [ChangesNotifier] does, so the window keeps one source.

abstract class _$BranchesNotifier extends $Notifier<BranchesState> {
  BranchesState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<BranchesState, BranchesState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<BranchesState, BranchesState>,
              BranchesState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
