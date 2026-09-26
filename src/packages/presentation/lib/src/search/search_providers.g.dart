// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Reads a space's documents into the index.
///
/// Declared here and overridden by the composition root, which is how every
/// use case reaches this package.

@ProviderFor(indexSpace)
final indexSpaceProvider = IndexSpaceProvider._();

/// Reads a space's documents into the index.
///
/// Declared here and overridden by the composition root, which is how every
/// use case reaches this package.

final class IndexSpaceProvider
    extends
        $FunctionalProvider<
          IndexSpaceUseCase,
          IndexSpaceUseCase,
          IndexSpaceUseCase
        >
    with $Provider<IndexSpaceUseCase> {
  /// Reads a space's documents into the index.
  ///
  /// Declared here and overridden by the composition root, which is how every
  /// use case reaches this package.
  IndexSpaceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'indexSpaceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$indexSpaceHash();

  @$internal
  @override
  $ProviderElement<IndexSpaceUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  IndexSpaceUseCase create(Ref ref) {
    return indexSpace(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IndexSpaceUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IndexSpaceUseCase>(value),
    );
  }
}

String _$indexSpaceHash() => r'9b9e15887b77cdc8752e0a3e4af26b79ffc6530e';

/// Files one document again, after it was written.

@ProviderFor(indexDocument)
final indexDocumentProvider = IndexDocumentProvider._();

/// Files one document again, after it was written.

final class IndexDocumentProvider
    extends
        $FunctionalProvider<
          IndexDocumentUseCase,
          IndexDocumentUseCase,
          IndexDocumentUseCase
        >
    with $Provider<IndexDocumentUseCase> {
  /// Files one document again, after it was written.
  IndexDocumentProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'indexDocumentProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$indexDocumentHash();

  @$internal
  @override
  $ProviderElement<IndexDocumentUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  IndexDocumentUseCase create(Ref ref) {
    return indexDocument(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IndexDocumentUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IndexDocumentUseCase>(value),
    );
  }
}

String _$indexDocumentHash() => r'9951f851e20a50f994bcef61b988958e3ad6123f';

/// Asks the index what matches what was typed.

@ProviderFor(searchSpace)
final searchSpaceProvider = SearchSpaceProvider._();

/// Asks the index what matches what was typed.

final class SearchSpaceProvider
    extends
        $FunctionalProvider<
          SearchSpaceUseCase,
          SearchSpaceUseCase,
          SearchSpaceUseCase
        >
    with $Provider<SearchSpaceUseCase> {
  /// Asks the index what matches what was typed.
  SearchSpaceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchSpaceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchSpaceHash();

  @$internal
  @override
  $ProviderElement<SearchSpaceUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SearchSpaceUseCase create(Ref ref) {
    return searchSpace(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SearchSpaceUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SearchSpaceUseCase>(value),
    );
  }
}

String _$searchSpaceHash() => r'dc2c3fea24fadd58fa1f7416a8490e5af92f74c3';
