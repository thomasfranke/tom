// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Turns a folder into a space, and remembers it.
///
/// Declared here and overridden by the composition root: this package names
/// the use case it needs and cannot see what satisfies it
/// ([architecture](../../../../../../docs/technical/architecture.md)). Throwing rather
/// than defaulting keeps that decision in one place.

@ProviderFor(openSpace)
final openSpaceProvider = OpenSpaceProvider._();

/// Turns a folder into a space, and remembers it.
///
/// Declared here and overridden by the composition root: this package names
/// the use case it needs and cannot see what satisfies it
/// ([architecture](../../../../../../docs/technical/architecture.md)). Throwing rather
/// than defaulting keeps that decision in one place.

final class OpenSpaceProvider
    extends
        $FunctionalProvider<
          OpenSpaceUseCase,
          OpenSpaceUseCase,
          OpenSpaceUseCase
        >
    with $Provider<OpenSpaceUseCase> {
  /// Turns a folder into a space, and remembers it.
  ///
  /// Declared here and overridden by the composition root: this package names
  /// the use case it needs and cannot see what satisfies it
  /// ([architecture](../../../../../../docs/technical/architecture.md)). Throwing rather
  /// than defaulting keeps that decision in one place.
  OpenSpaceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'openSpaceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$openSpaceHash();

  @$internal
  @override
  $ProviderElement<OpenSpaceUseCase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  OpenSpaceUseCase create(Ref ref) {
    return openSpace(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OpenSpaceUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OpenSpaceUseCase>(value),
    );
  }
}

String _$openSpaceHash() => r'a59fe5c2185d61b4b540a0274f3788517e156b2f';

/// Reads the spaces to offer going back to.

@ProviderFor(listRecentSpaces)
final listRecentSpacesProvider = ListRecentSpacesProvider._();

/// Reads the spaces to offer going back to.

final class ListRecentSpacesProvider
    extends
        $FunctionalProvider<
          ListRecentSpacesUseCase,
          ListRecentSpacesUseCase,
          ListRecentSpacesUseCase
        >
    with $Provider<ListRecentSpacesUseCase> {
  /// Reads the spaces to offer going back to.
  ListRecentSpacesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'listRecentSpacesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$listRecentSpacesHash();

  @$internal
  @override
  $ProviderElement<ListRecentSpacesUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ListRecentSpacesUseCase create(Ref ref) {
    return listRecentSpaces(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ListRecentSpacesUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ListRecentSpacesUseCase>(value),
    );
  }
}

String _$listRecentSpacesHash() => r'7e94028f07980cf24cc1c40e2c0d96210d52a14b';

/// Drops one space from that list.

@ProviderFor(forgetRecentSpace)
final forgetRecentSpaceProvider = ForgetRecentSpaceProvider._();

/// Drops one space from that list.

final class ForgetRecentSpaceProvider
    extends
        $FunctionalProvider<
          ForgetRecentSpaceUseCase,
          ForgetRecentSpaceUseCase,
          ForgetRecentSpaceUseCase
        >
    with $Provider<ForgetRecentSpaceUseCase> {
  /// Drops one space from that list.
  ForgetRecentSpaceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'forgetRecentSpaceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$forgetRecentSpaceHash();

  @$internal
  @override
  $ProviderElement<ForgetRecentSpaceUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ForgetRecentSpaceUseCase create(Ref ref) {
    return forgetRecentSpace(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ForgetRecentSpaceUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ForgetRecentSpaceUseCase>(value),
    );
  }
}

String _$forgetRecentSpaceHash() => r'92e6c7b36c74d49694d20c261af821a93187f181';

/// Clones a repository by URL and opens it as a space.

@ProviderFor(cloneRepository)
final cloneRepositoryProvider = CloneRepositoryProvider._();

/// Clones a repository by URL and opens it as a space.

final class CloneRepositoryProvider
    extends
        $FunctionalProvider<
          CloneRepositoryUseCase,
          CloneRepositoryUseCase,
          CloneRepositoryUseCase
        >
    with $Provider<CloneRepositoryUseCase> {
  /// Clones a repository by URL and opens it as a space.
  CloneRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cloneRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cloneRepositoryHash();

  @$internal
  @override
  $ProviderElement<CloneRepositoryUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CloneRepositoryUseCase create(Ref ref) {
    return cloneRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CloneRepositoryUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CloneRepositoryUseCase>(value),
    );
  }
}

String _$cloneRepositoryHash() => r'0c92317f24e082fdfe077b9a9ff836c1ae9aafe7';

/// Reads the branch a recent space was left on.

@ProviderFor(readRecentBranch)
final readRecentBranchProvider = ReadRecentBranchProvider._();

/// Reads the branch a recent space was left on.

final class ReadRecentBranchProvider
    extends
        $FunctionalProvider<
          ReadRecentBranchUseCase,
          ReadRecentBranchUseCase,
          ReadRecentBranchUseCase
        >
    with $Provider<ReadRecentBranchUseCase> {
  /// Reads the branch a recent space was left on.
  ReadRecentBranchProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'readRecentBranchProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$readRecentBranchHash();

  @$internal
  @override
  $ProviderElement<ReadRecentBranchUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ReadRecentBranchUseCase create(Ref ref) {
    return readRecentBranch(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReadRecentBranchUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReadRecentBranchUseCase>(value),
    );
  }
}

String _$readRecentBranchHash() => r'2c6e34da08c7be22db926eb0f3eedfcc0bd80f40';
