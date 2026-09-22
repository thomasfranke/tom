// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Turns a folder into a space, and remembers it.
///
/// Declared here and **overridden by the composition root**: this package
/// names the use case it needs and has no idea which repository, which git
/// client or which disk ends up behind it — it cannot even find out
/// ([layers](../../../../../../docs/technical/layers.md)).
///
/// Throwing rather than defaulting is deliberate: a default would be a
/// second place where the app decides what satisfies a contract.

@ProviderFor(openSpace)
final openSpaceProvider = OpenSpaceProvider._();

/// Turns a folder into a space, and remembers it.
///
/// Declared here and **overridden by the composition root**: this package
/// names the use case it needs and has no idea which repository, which git
/// client or which disk ends up behind it — it cannot even find out
/// ([layers](../../../../../../docs/technical/layers.md)).
///
/// Throwing rather than defaulting is deliberate: a default would be a
/// second place where the app decides what satisfies a contract.

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
  /// Declared here and **overridden by the composition root**: this package
  /// names the use case it needs and has no idea which repository, which git
  /// client or which disk ends up behind it — it cannot even find out
  /// ([layers](../../../../../../docs/technical/layers.md)).
  ///
  /// Throwing rather than defaulting is deliberate: a default would be a
  /// second place where the app decides what satisfies a contract.
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
