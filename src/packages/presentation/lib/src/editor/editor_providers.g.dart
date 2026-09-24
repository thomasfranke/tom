// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'editor_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Reads a document's source off the disk.
///
/// Declared here and **overridden by the composition root**: this package
/// names the use case it needs and cannot see which disk ends up behind it.

@ProviderFor(readDocument)
final readDocumentProvider = ReadDocumentProvider._();

/// Reads a document's source off the disk.
///
/// Declared here and **overridden by the composition root**: this package
/// names the use case it needs and cannot see which disk ends up behind it.

final class ReadDocumentProvider
    extends
        $FunctionalProvider<
          ReadDocumentUseCase,
          ReadDocumentUseCase,
          ReadDocumentUseCase
        >
    with $Provider<ReadDocumentUseCase> {
  /// Reads a document's source off the disk.
  ///
  /// Declared here and **overridden by the composition root**: this package
  /// names the use case it needs and cannot see which disk ends up behind it.
  ReadDocumentProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'readDocumentProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$readDocumentHash();

  @$internal
  @override
  $ProviderElement<ReadDocumentUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ReadDocumentUseCase create(Ref ref) {
    return readDocument(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReadDocumentUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReadDocumentUseCase>(value),
    );
  }
}

String _$readDocumentHash() => r'67451dad96922ca9d240e8d62aaabf2032500249';

/// Writes the buffer back to the file it came from.

@ProviderFor(saveDocument)
final saveDocumentProvider = SaveDocumentProvider._();

/// Writes the buffer back to the file it came from.

final class SaveDocumentProvider
    extends
        $FunctionalProvider<
          SaveDocumentUseCase,
          SaveDocumentUseCase,
          SaveDocumentUseCase
        >
    with $Provider<SaveDocumentUseCase> {
  /// Writes the buffer back to the file it came from.
  SaveDocumentProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saveDocumentProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saveDocumentHash();

  @$internal
  @override
  $ProviderElement<SaveDocumentUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SaveDocumentUseCase create(Ref ref) {
    return saveDocument(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SaveDocumentUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SaveDocumentUseCase>(value),
    );
  }
}

String _$saveDocumentHash() => r'2dde8a7605fc307dd4f20aac1cfe31fa7a0c5e31';
