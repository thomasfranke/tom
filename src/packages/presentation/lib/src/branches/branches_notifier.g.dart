// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'branches_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Switches branches, starts them, and refuses to lose work doing either.
///
/// **A switch rewrites the working tree**, which is what makes this more
/// than a git call: git has to be asked where it now stands, the explorer
/// has to walk the folder again, and every open document has to be read
/// again. All three happen here, after the switch, in that order.
///
/// It reads no git status of its own — [ChangesNotifier] does that, so what
/// the window believes about the repository keeps one source
/// (`docs/product/git-workflow/push-pull/doc.md`).

@ProviderFor(BranchesNotifier)
final branchesProvider = BranchesNotifierProvider._();

/// Switches branches, starts them, and refuses to lose work doing either.
///
/// **A switch rewrites the working tree**, which is what makes this more
/// than a git call: git has to be asked where it now stands, the explorer
/// has to walk the folder again, and every open document has to be read
/// again. All three happen here, after the switch, in that order.
///
/// It reads no git status of its own — [ChangesNotifier] does that, so what
/// the window believes about the repository keeps one source
/// (`docs/product/git-workflow/push-pull/doc.md`).
final class BranchesNotifierProvider
    extends $NotifierProvider<BranchesNotifier, BranchesState> {
  /// Switches branches, starts them, and refuses to lose work doing either.
  ///
  /// **A switch rewrites the working tree**, which is what makes this more
  /// than a git call: git has to be asked where it now stands, the explorer
  /// has to walk the folder again, and every open document has to be read
  /// again. All three happen here, after the switch, in that order.
  ///
  /// It reads no git status of its own — [ChangesNotifier] does that, so what
  /// the window believes about the repository keeps one source
  /// (`docs/product/git-workflow/push-pull/doc.md`).
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

String _$branchesNotifierHash() => r'b5cfa7d39cf05e7e21f8edfa7defbddf5aa9c648';

/// Switches branches, starts them, and refuses to lose work doing either.
///
/// **A switch rewrites the working tree**, which is what makes this more
/// than a git call: git has to be asked where it now stands, the explorer
/// has to walk the folder again, and every open document has to be read
/// again. All three happen here, after the switch, in that order.
///
/// It reads no git status of its own — [ChangesNotifier] does that, so what
/// the window believes about the repository keeps one source
/// (`docs/product/git-workflow/push-pull/doc.md`).

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
