// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deleted_documents.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Every open tab whose file git reports deleted, and the one on screen when
/// the editor found it gone — what the strip strikes through and calls
/// `(deleted)` (`docs/product/git-workflow/commit/opening-a-change/doc.md`).
///
/// Git's reading rather than each tab's buffer, because a tab that is not on
/// screen holds no buffer to ask.

@ProviderFor(deletedDocuments)
final deletedDocumentsProvider = DeletedDocumentsProvider._();

/// Every open tab whose file git reports deleted, and the one on screen when
/// the editor found it gone — what the strip strikes through and calls
/// `(deleted)` (`docs/product/git-workflow/commit/opening-a-change/doc.md`).
///
/// Git's reading rather than each tab's buffer, because a tab that is not on
/// screen holds no buffer to ask.

final class DeletedDocumentsProvider
    extends
        $FunctionalProvider<
          Set<DocumentTab>,
          Set<DocumentTab>,
          Set<DocumentTab>
        >
    with $Provider<Set<DocumentTab>> {
  /// Every open tab whose file git reports deleted, and the one on screen when
  /// the editor found it gone — what the strip strikes through and calls
  /// `(deleted)` (`docs/product/git-workflow/commit/opening-a-change/doc.md`).
  ///
  /// Git's reading rather than each tab's buffer, because a tab that is not on
  /// screen holds no buffer to ask.
  DeletedDocumentsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deletedDocumentsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deletedDocumentsHash();

  @$internal
  @override
  $ProviderElement<Set<DocumentTab>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Set<DocumentTab> create(Ref ref) {
    return deletedDocuments(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<DocumentTab> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<DocumentTab>>(value),
    );
  }
}

String _$deletedDocumentsHash() => r'54de20d7ad33394f1564a5d79f10a7140916f0c8';
