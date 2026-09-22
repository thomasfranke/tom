// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preview_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Reads whatever document the session says is open.
///
/// **No business logic**: it calls a use case and turns [Result] into state.
/// It watches the whole session rather than a part of it, because both
/// halves matter — another space and another document are both a different
/// file to read.

@ProviderFor(Preview)
final previewProvider = PreviewProvider._();

/// Reads whatever document the session says is open.
///
/// **No business logic**: it calls a use case and turns [Result] into state.
/// It watches the whole session rather than a part of it, because both
/// halves matter — another space and another document are both a different
/// file to read.
final class PreviewProvider extends $NotifierProvider<Preview, PreviewState> {
  /// Reads whatever document the session says is open.
  ///
  /// **No business logic**: it calls a use case and turns [Result] into state.
  /// It watches the whole session rather than a part of it, because both
  /// halves matter — another space and another document are both a different
  /// file to read.
  PreviewProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'previewProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$previewHash();

  @$internal
  @override
  Preview create() => Preview();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PreviewState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PreviewState>(value),
    );
  }
}

String _$previewHash() => r'6f1695030889dc02fe5057fb220eac3cecdab2ef';

/// Reads whatever document the session says is open.
///
/// **No business logic**: it calls a use case and turns [Result] into state.
/// It watches the whole session rather than a part of it, because both
/// halves matter — another space and another document are both a different
/// file to read.

abstract class _$Preview extends $Notifier<PreviewState> {
  PreviewState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<PreviewState, PreviewState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PreviewState, PreviewState>,
              PreviewState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
