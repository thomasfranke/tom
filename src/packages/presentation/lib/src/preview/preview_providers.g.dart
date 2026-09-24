// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preview_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Splits a document's source into blocks.
///
/// Declared here and **overridden by the composition root**: this package
/// names the use case it needs and cannot see which parser ends up behind
/// it.

@ProviderFor(splitDocument)
final splitDocumentProvider = SplitDocumentProvider._();

/// Splits a document's source into blocks.
///
/// Declared here and **overridden by the composition root**: this package
/// names the use case it needs and cannot see which parser ends up behind
/// it.

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
  /// Declared here and **overridden by the composition root**: this package
  /// names the use case it needs and cannot see which parser ends up behind
  /// it.
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

/// Reads a document as one commit left it.
///
/// Here rather than beside the history panel because the preview is what
/// needs it: history says *which* version is on screen, and this is what
/// turns that into text to render.

@ProviderFor(readVersion)
final readVersionProvider = ReadVersionProvider._();

/// Reads a document as one commit left it.
///
/// Here rather than beside the history panel because the preview is what
/// needs it: history says *which* version is on screen, and this is what
/// turns that into text to render.

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
  /// Here rather than beside the history panel because the preview is what
  /// needs it: history says *which* version is on screen, and this is what
  /// turns that into text to render.
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
