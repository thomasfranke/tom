// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'remote_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Updates the remote-tracking branches, touching no file on disk.
///
/// Declared here and **overridden by the composition root**: this package
/// names the use cases it needs and cannot see that a process answers them.

@ProviderFor(fetchRemote)
final fetchRemoteProvider = FetchRemoteProvider._();

/// Updates the remote-tracking branches, touching no file on disk.
///
/// Declared here and **overridden by the composition root**: this package
/// names the use cases it needs and cannot see that a process answers them.

final class FetchRemoteProvider
    extends
        $FunctionalProvider<
          FetchRemoteUseCase,
          FetchRemoteUseCase,
          FetchRemoteUseCase
        >
    with $Provider<FetchRemoteUseCase> {
  /// Updates the remote-tracking branches, touching no file on disk.
  ///
  /// Declared here and **overridden by the composition root**: this package
  /// names the use cases it needs and cannot see that a process answers them.
  FetchRemoteProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'fetchRemoteProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$fetchRemoteHash();

  @$internal
  @override
  $ProviderElement<FetchRemoteUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FetchRemoteUseCase create(Ref ref) {
    return fetchRemote(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FetchRemoteUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FetchRemoteUseCase>(value),
    );
  }
}

String _$fetchRemoteHash() => r'0c900f9a4d2375a52142a816263797ab5f640b62';

/// Brings the remote's commits into the current branch.

@ProviderFor(pullRemote)
final pullRemoteProvider = PullRemoteProvider._();

/// Brings the remote's commits into the current branch.

final class PullRemoteProvider
    extends
        $FunctionalProvider<
          PullRemoteUseCase,
          PullRemoteUseCase,
          PullRemoteUseCase
        >
    with $Provider<PullRemoteUseCase> {
  /// Brings the remote's commits into the current branch.
  PullRemoteProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pullRemoteProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pullRemoteHash();

  @$internal
  @override
  $ProviderElement<PullRemoteUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PullRemoteUseCase create(Ref ref) {
    return pullRemote(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PullRemoteUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PullRemoteUseCase>(value),
    );
  }
}

String _$pullRemoteHash() => r'af620359d018a5e2270d893d2bae80fc171b2399';

/// Publishes the current branch's commits.

@ProviderFor(pushRemote)
final pushRemoteProvider = PushRemoteProvider._();

/// Publishes the current branch's commits.

final class PushRemoteProvider
    extends
        $FunctionalProvider<
          PushRemoteUseCase,
          PushRemoteUseCase,
          PushRemoteUseCase
        >
    with $Provider<PushRemoteUseCase> {
  /// Publishes the current branch's commits.
  PushRemoteProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pushRemoteProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pushRemoteHash();

  @$internal
  @override
  $ProviderElement<PushRemoteUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PushRemoteUseCase create(Ref ref) {
    return pushRemote(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PushRemoteUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PushRemoteUseCase>(value),
    );
  }
}

String _$pushRemoteHash() => r'aba6876465a7b26d413ad80bf02a9e5bcdc618f7';
