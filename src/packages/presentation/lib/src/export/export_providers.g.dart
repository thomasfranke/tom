// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'export_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Writes a document as PDF or HTML.
///
/// Declared here and overridden by the composition root, which is how every
/// use case reaches this package.

@ProviderFor(exportDocument)
final exportDocumentProvider = ExportDocumentProvider._();

/// Writes a document as PDF or HTML.
///
/// Declared here and overridden by the composition root, which is how every
/// use case reaches this package.

final class ExportDocumentProvider
    extends
        $FunctionalProvider<
          ExportDocumentUseCase,
          ExportDocumentUseCase,
          ExportDocumentUseCase
        >
    with $Provider<ExportDocumentUseCase> {
  /// Writes a document as PDF or HTML.
  ///
  /// Declared here and overridden by the composition root, which is how every
  /// use case reaches this package.
  ExportDocumentProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exportDocumentProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exportDocumentHash();

  @$internal
  @override
  $ProviderElement<ExportDocumentUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ExportDocumentUseCase create(Ref ref) {
    return exportDocument(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExportDocumentUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExportDocumentUseCase>(value),
    );
  }
}

String _$exportDocumentHash() => r'241f82bf2a244c5ad83b2f707510d232854a3e9a';
