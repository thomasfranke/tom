// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preview_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Reads a document and splits it into blocks.
///
/// Declared here and **overridden by the composition root**: this package
/// names the use case it needs and cannot see which parser or which disk
/// ends up behind it.

@ProviderFor(readDocument)
final readDocumentProvider = ReadDocumentProvider._();

/// Reads a document and splits it into blocks.
///
/// Declared here and **overridden by the composition root**: this package
/// names the use case it needs and cannot see which parser or which disk
/// ends up behind it.

final class ReadDocumentProvider
    extends
        $FunctionalProvider<
          ReadDocumentUseCase,
          ReadDocumentUseCase,
          ReadDocumentUseCase
        >
    with $Provider<ReadDocumentUseCase> {
  /// Reads a document and splits it into blocks.
  ///
  /// Declared here and **overridden by the composition root**: this package
  /// names the use case it needs and cannot see which parser or which disk
  /// ends up behind it.
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
