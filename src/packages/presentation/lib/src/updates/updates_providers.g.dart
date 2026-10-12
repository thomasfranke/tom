// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'updates_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Asks whether a newer TOM has been published.

@ProviderFor(checkForUpdates)
final checkForUpdatesProvider = CheckForUpdatesProvider._();

/// Asks whether a newer TOM has been published.

final class CheckForUpdatesProvider
    extends
        $FunctionalProvider<
          CheckForUpdatesUseCase,
          CheckForUpdatesUseCase,
          CheckForUpdatesUseCase
        >
    with $Provider<CheckForUpdatesUseCase> {
  /// Asks whether a newer TOM has been published.
  CheckForUpdatesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'checkForUpdatesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$checkForUpdatesHash();

  @$internal
  @override
  $ProviderElement<CheckForUpdatesUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CheckForUpdatesUseCase create(Ref ref) {
    return checkForUpdates(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CheckForUpdatesUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CheckForUpdatesUseCase>(value),
    );
  }
}

String _$checkForUpdatesHash() => r'eada10c0b35eaffa0d8623f1551c1cb32b1c2d50';

/// The version this build is, read at build time.

@ProviderFor(runningVersion)
final runningVersionProvider = RunningVersionProvider._();

/// The version this build is, read at build time.

final class RunningVersionProvider
    extends
        $FunctionalProvider<
          AppVersionValueObject,
          AppVersionValueObject,
          AppVersionValueObject
        >
    with $Provider<AppVersionValueObject> {
  /// The version this build is, read at build time.
  RunningVersionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'runningVersionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$runningVersionHash();

  @$internal
  @override
  $ProviderElement<AppVersionValueObject> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AppVersionValueObject create(Ref ref) {
    return runningVersion(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppVersionValueObject value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppVersionValueObject>(value),
    );
  }
}

String _$runningVersionHash() => r'9130d611c0a0b08d307dbbaa16844036a071ca0d';

/// Whether a first release has been published; until then the check is
/// unavailable and the dialog says so
/// (`docs/product/about/doc.md`).

@ProviderFor(releasesPublished)
final releasesPublishedProvider = ReleasesPublishedProvider._();

/// Whether a first release has been published; until then the check is
/// unavailable and the dialog says so
/// (`docs/product/about/doc.md`).

final class ReleasesPublishedProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether a first release has been published; until then the check is
  /// unavailable and the dialog says so
  /// (`docs/product/about/doc.md`).
  ReleasesPublishedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'releasesPublishedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$releasesPublishedHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return releasesPublished(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$releasesPublishedHash() => r'12e1d6da03aa20919983ae4d11e8c140514445d1';
