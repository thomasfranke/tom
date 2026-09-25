// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'branches_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Lists the repository's local branches.
///
/// Declared here and overridden by the composition root, which is how every
/// use case reaches this package.

@ProviderFor(listBranches)
final listBranchesProvider = ListBranchesProvider._();

/// Lists the repository's local branches.
///
/// Declared here and overridden by the composition root, which is how every
/// use case reaches this package.

final class ListBranchesProvider
    extends
        $FunctionalProvider<
          ListBranchesUseCase,
          ListBranchesUseCase,
          ListBranchesUseCase
        >
    with $Provider<ListBranchesUseCase> {
  /// Lists the repository's local branches.
  ///
  /// Declared here and overridden by the composition root, which is how every
  /// use case reaches this package.
  ListBranchesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'listBranchesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$listBranchesHash();

  @$internal
  @override
  $ProviderElement<ListBranchesUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ListBranchesUseCase create(Ref ref) {
    return listBranches(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ListBranchesUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ListBranchesUseCase>(value),
    );
  }
}

String _$listBranchesHash() => r'fbd9765f5a9f8aeb9577ff34160a8820c8619681';

/// Moves `HEAD` onto a branch, or starts one and moves onto that.

@ProviderFor(switchBranch)
final switchBranchProvider = SwitchBranchProvider._();

/// Moves `HEAD` onto a branch, or starts one and moves onto that.

final class SwitchBranchProvider
    extends
        $FunctionalProvider<
          SwitchBranchUseCase,
          SwitchBranchUseCase,
          SwitchBranchUseCase
        >
    with $Provider<SwitchBranchUseCase> {
  /// Moves `HEAD` onto a branch, or starts one and moves onto that.
  SwitchBranchProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'switchBranchProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$switchBranchHash();

  @$internal
  @override
  $ProviderElement<SwitchBranchUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SwitchBranchUseCase create(Ref ref) {
    return switchBranch(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SwitchBranchUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SwitchBranchUseCase>(value),
    );
  }
}

String _$switchBranchHash() => r'2a2f5c41e84a4500d4cd860e8692246dd83be90f';
