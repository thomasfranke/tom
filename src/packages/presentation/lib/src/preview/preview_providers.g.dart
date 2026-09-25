// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preview_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Splits a document's source into blocks.
///
/// Declared here and overridden by the composition root, which is how every
/// use case reaches this package.

@ProviderFor(splitDocument)
final splitDocumentProvider = SplitDocumentProvider._();

/// Splits a document's source into blocks.
///
/// Declared here and overridden by the composition root, which is how every
/// use case reaches this package.

final class SplitDocumentProvider
    extends
        $FunctionalProvider<
          SplitDocumentUseCase,
          SplitDocumentUseCase,
          SplitDocumentUseCase
        >
    with $Provider<SplitDocumentUseCase> {
  /// Splits a document's source into blocks.
  ///
  /// Declared here and overridden by the composition root, which is how every
  /// use case reaches this package.
  SplitDocumentProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'splitDocumentProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$splitDocumentHash();

  @$internal
  @override
  $ProviderElement<SplitDocumentUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SplitDocumentUseCase create(Ref ref) {
    return splitDocument(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SplitDocumentUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SplitDocumentUseCase>(value),
    );
  }
}

String _$splitDocumentHash() => r'46bb11a7f94f0107d8e6aaaf1a3dc7207e613d07';

/// Compares the document on screen against what `HEAD` holds.
///
/// Beside the preview because the preview draws the answer: the rendered
/// diff is decoration on the blocks already there
/// (`docs/product/diff/rendered-diff/doc.md`).

@ProviderFor(diffDocument)
final diffDocumentProvider = DiffDocumentProvider._();

/// Compares the document on screen against what `HEAD` holds.
///
/// Beside the preview because the preview draws the answer: the rendered
/// diff is decoration on the blocks already there
/// (`docs/product/diff/rendered-diff/doc.md`).

final class DiffDocumentProvider
    extends
        $FunctionalProvider<
          DiffDocumentUseCase,
          DiffDocumentUseCase,
          DiffDocumentUseCase
        >
    with $Provider<DiffDocumentUseCase> {
  /// Compares the document on screen against what `HEAD` holds.
  ///
  /// Beside the preview because the preview draws the answer: the rendered
  /// diff is decoration on the blocks already there
  /// (`docs/product/diff/rendered-diff/doc.md`).
  DiffDocumentProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'diffDocumentProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$diffDocumentHash();

  @$internal
  @override
  $ProviderElement<DiffDocumentUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DiffDocumentUseCase create(Ref ref) {
    return diffDocument(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DiffDocumentUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DiffDocumentUseCase>(value),
    );
  }
}

String _$diffDocumentHash() => r'45f90a1c47ad07bf2ef0d0a0e876281b00e4ddc6';

/// Reads a document as one commit left it.
///
/// Beside the preview rather than history, because the preview is what
/// turns the version history named into text to render.

@ProviderFor(readVersion)
final readVersionProvider = ReadVersionProvider._();

/// Reads a document as one commit left it.
///
/// Beside the preview rather than history, because the preview is what
/// turns the version history named into text to render.

final class ReadVersionProvider
    extends
        $FunctionalProvider<
          ReadVersionUseCase,
          ReadVersionUseCase,
          ReadVersionUseCase
        >
    with $Provider<ReadVersionUseCase> {
  /// Reads a document as one commit left it.
  ///
  /// Beside the preview rather than history, because the preview is what
  /// turns the version history named into text to render.
  ReadVersionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'readVersionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$readVersionHash();

  @$internal
  @override
  $ProviderElement<ReadVersionUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ReadVersionUseCase create(Ref ref) {
    return readVersion(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReadVersionUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReadVersionUseCase>(value),
    );
  }
}

String _$readVersionHash() => r'3cf6e48a1aea455f24126f74f342442fe1b4184f';
