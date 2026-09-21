// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'folder_picker.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// What Home calls when the user wants to open a folder.
///
/// A provider rather than a direct call into `file_selector`, for a reason
/// that is not testing hygiene: **a native dialog is the one thing no test
/// can drive**, and without a seam an end-to-end run would stop exactly
/// where the product starts.
///
/// The seam is the app's own: `tom_e2e` replaces it through a `TomModule`,
/// the same mechanism a third party would use to contribute a panel
/// ([Decision
/// 12](../../../../../../docs/technical/decisions/012-shell-is-extensible-via-compile-time-modules.md)).

@ProviderFor(folderPicker)
final folderPickerProvider = FolderPickerProvider._();

/// What Home calls when the user wants to open a folder.
///
/// A provider rather than a direct call into `file_selector`, for a reason
/// that is not testing hygiene: **a native dialog is the one thing no test
/// can drive**, and without a seam an end-to-end run would stop exactly
/// where the product starts.
///
/// The seam is the app's own: `tom_e2e` replaces it through a `TomModule`,
/// the same mechanism a third party would use to contribute a panel
/// ([Decision
/// 12](../../../../../../docs/technical/decisions/012-shell-is-extensible-via-compile-time-modules.md)).

final class FolderPickerProvider
    extends $FunctionalProvider<FolderPicker, FolderPicker, FolderPicker>
    with $Provider<FolderPicker> {
  /// What Home calls when the user wants to open a folder.
  ///
  /// A provider rather than a direct call into `file_selector`, for a reason
  /// that is not testing hygiene: **a native dialog is the one thing no test
  /// can drive**, and without a seam an end-to-end run would stop exactly
  /// where the product starts.
  ///
  /// The seam is the app's own: `tom_e2e` replaces it through a `TomModule`,
  /// the same mechanism a third party would use to contribute a panel
  /// ([Decision
  /// 12](../../../../../../docs/technical/decisions/012-shell-is-extensible-via-compile-time-modules.md)).
  FolderPickerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'folderPickerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$folderPickerHash();

  @$internal
  @override
  $ProviderElement<FolderPicker> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FolderPicker create(Ref ref) {
    return folderPicker(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FolderPicker value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FolderPicker>(value),
    );
  }
}

String _$folderPickerHash() => r'b01aa5a365d7d640f59b9d455ec1a0c9d38d04c2';
