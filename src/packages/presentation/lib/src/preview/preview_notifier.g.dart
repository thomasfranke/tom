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

@ProviderFor(PreviewNotifier)
final previewProvider = PreviewNotifierProvider._();

/// Reads whatever document the session says is open.
///
/// **No business logic**: it calls a use case and turns [Result] into state.
/// It watches the whole session rather than a part of it, because both
/// halves matter — another space and another document are both a different
/// file to read.
final class PreviewNotifierProvider
    extends $NotifierProvider<PreviewNotifier, PreviewState> {
  /// Reads whatever document the session says is open.
  ///
  /// **No business logic**: it calls a use case and turns [Result] into state.
  /// It watches the whole session rather than a part of it, because both
  /// halves matter — another space and another document are both a different
  /// file to read.
  PreviewNotifierProvider._()
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
  String debugGetCreateSourceHash() => _$previewNotifierHash();

  @$internal
  @override
  PreviewNotifier create() => PreviewNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PreviewState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PreviewState>(value),
    );
  }
}

String _$previewNotifierHash() => r'275419f1c674a5a51dc713dae35a03692f5a0a90';

/// Reads whatever document the session says is open.
///
/// **No business logic**: it calls a use case and turns [Result] into state.
/// It watches the whole session rather than a part of it, because both
/// halves matter — another space and another document are both a different
/// file to read.

abstract class _$PreviewNotifier extends $Notifier<PreviewState> {
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
