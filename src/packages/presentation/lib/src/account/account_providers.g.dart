// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Reads who the person is, here and on GitHub.

@ProviderFor(readAccount)
final readAccountProvider = ReadAccountProvider._();

/// Reads who the person is, here and on GitHub.

final class ReadAccountProvider
    extends
        $FunctionalProvider<
          ReadAccountUseCase,
          ReadAccountUseCase,
          ReadAccountUseCase
        >
    with $Provider<ReadAccountUseCase> {
  /// Reads who the person is, here and on GitHub.
  ReadAccountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'readAccountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$readAccountHash();

  @$internal
  @override
  $ProviderElement<ReadAccountUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ReadAccountUseCase create(Ref ref) {
    return readAccount(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReadAccountUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReadAccountUseCase>(value),
    );
  }
}

String _$readAccountHash() => r'ddafef1002959d67f8290f24b0a1c37602172391';

/// Records which account this repository is used with.

@ProviderFor(chooseAccount)
final chooseAccountProvider = ChooseAccountProvider._();

/// Records which account this repository is used with.

final class ChooseAccountProvider
    extends
        $FunctionalProvider<
          ChooseAccountUseCase,
          ChooseAccountUseCase,
          ChooseAccountUseCase
        >
    with $Provider<ChooseAccountUseCase> {
  /// Records which account this repository is used with.
  ChooseAccountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chooseAccountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chooseAccountHash();

  @$internal
  @override
  $ProviderElement<ChooseAccountUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ChooseAccountUseCase create(Ref ref) {
    return chooseAccount(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChooseAccountUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChooseAccountUseCase>(value),
    );
  }
}

String _$chooseAccountHash() => r'0f1fbdf3b9acf55800e2243d04378492a2f50ca2';
