// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'compare_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Reads the branch the one checked out came from.
///
/// Declared here and overridden by the composition root, which is how every
/// use case reaches this package.

@ProviderFor(readDiffBase)
final readDiffBaseProvider = ReadDiffBaseProvider._();

/// Reads the branch the one checked out came from.
///
/// Declared here and overridden by the composition root, which is how every
/// use case reaches this package.

final class ReadDiffBaseProvider
    extends
        $FunctionalProvider<
          ReadDiffBaseUseCase,
          ReadDiffBaseUseCase,
          ReadDiffBaseUseCase
        >
    with $Provider<ReadDiffBaseUseCase> {
  /// Reads the branch the one checked out came from.
  ///
  /// Declared here and overridden by the composition root, which is how every
  /// use case reaches this package.
  ReadDiffBaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'readDiffBaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$readDiffBaseHash();

  @$internal
  @override
  $ProviderElement<ReadDiffBaseUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ReadDiffBaseUseCase create(Ref ref) {
    return readDiffBase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReadDiffBaseUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReadDiffBaseUseCase>(value),
    );
  }
}

String _$readDiffBaseHash() => r'4c2b1d0bb4a2bfc6dc91dc97653eb33d5260cb2f';
