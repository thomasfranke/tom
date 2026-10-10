// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'save_location_picker.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The platform's save dialog, filtered to the one format asked for.
///
/// A seam for the same reason the folder picker is: a native dialog is the
/// one thing no test can drive, so the e2e suite replaces it through a
/// `TomModule`.

@ProviderFor(saveLocationPicker)
final saveLocationPickerProvider = SaveLocationPickerProvider._();

/// The platform's save dialog, filtered to the one format asked for.
///
/// A seam for the same reason the folder picker is: a native dialog is the
/// one thing no test can drive, so the e2e suite replaces it through a
/// `TomModule`.

final class SaveLocationPickerProvider
    extends
        $FunctionalProvider<
          SaveLocationPicker,
          SaveLocationPicker,
          SaveLocationPicker
        >
    with $Provider<SaveLocationPicker> {
  /// The platform's save dialog, filtered to the one format asked for.
  ///
  /// A seam for the same reason the folder picker is: a native dialog is the
  /// one thing no test can drive, so the e2e suite replaces it through a
  /// `TomModule`.
  SaveLocationPickerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saveLocationPickerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saveLocationPickerHash();

  @$internal
  @override
  $ProviderElement<SaveLocationPicker> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SaveLocationPicker create(Ref ref) {
    return saveLocationPicker(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SaveLocationPicker value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SaveLocationPicker>(value),
    );
  }
}

String _$saveLocationPickerHash() =>
    r'960db01690ad3be28a55bf7c8ffcd2647d550997';
