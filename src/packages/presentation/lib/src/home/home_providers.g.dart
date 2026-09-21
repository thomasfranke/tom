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
    extends $FunctionalProvider<OpenSpace, OpenSpace, OpenSpace>
    with $Provider<OpenSpace> {
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
  $ProviderElement<OpenSpace> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  OpenSpace create(Ref ref) {
    return openSpace(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OpenSpace value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OpenSpace>(value),
    );
  }
}

String _$openSpaceHash() => r'0d651c147c5e8e361d69f8c333b489a1b922fc5a';

/// Reads the spaces to offer going back to.

@ProviderFor(listRecentSpaces)
final listRecentSpacesProvider = ListRecentSpacesProvider._();

/// Reads the spaces to offer going back to.

final class ListRecentSpacesProvider
    extends
        $FunctionalProvider<
          ListRecentSpaces,
          ListRecentSpaces,
          ListRecentSpaces
        >
    with $Provider<ListRecentSpaces> {
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
  $ProviderElement<ListRecentSpaces> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ListRecentSpaces create(Ref ref) {
    return listRecentSpaces(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ListRecentSpaces value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ListRecentSpaces>(value),
    );
  }
}

String _$listRecentSpacesHash() => r'02c557e6d5ce7174afc5880fe809b4c9b476497b';

/// Drops one space from that list.

@ProviderFor(forgetRecentSpace)
final forgetRecentSpaceProvider = ForgetRecentSpaceProvider._();

/// Drops one space from that list.

final class ForgetRecentSpaceProvider
    extends
        $FunctionalProvider<
          ForgetRecentSpace,
          ForgetRecentSpace,
          ForgetRecentSpace
        >
    with $Provider<ForgetRecentSpace> {
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
  $ProviderElement<ForgetRecentSpace> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ForgetRecentSpace create(Ref ref) {
    return forgetRecentSpace(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ForgetRecentSpace value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ForgetRecentSpace>(value),
    );
  }
}

String _$forgetRecentSpaceHash() => r'a1bb58517e365e32ef53846ed20f65537f768b2a';
