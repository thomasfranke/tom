// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preview_anchor_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Holds an `#anchor` until its document is drawn, then hands over the
/// heading it names (`docs/product/wikilinks/doc.md`).
///
/// Apart from `PreviewLinksNotifier`'s state, which is worked out again
/// whenever the preview changes — and opening the next document is exactly
/// such a change.

@ProviderFor(PreviewAnchorNotifier)
final previewAnchorProvider = PreviewAnchorNotifierProvider._();

/// Holds an `#anchor` until its document is drawn, then hands over the
/// heading it names (`docs/product/wikilinks/doc.md`).
///
/// Apart from `PreviewLinksNotifier`'s state, which is worked out again
/// whenever the preview changes — and opening the next document is exactly
/// such a change.
final class PreviewAnchorNotifierProvider
    extends $NotifierProvider<PreviewAnchorNotifier, PreviewAnchor?> {
  /// Holds an `#anchor` until its document is drawn, then hands over the
  /// heading it names (`docs/product/wikilinks/doc.md`).
  ///
  /// Apart from `PreviewLinksNotifier`'s state, which is worked out again
  /// whenever the preview changes — and opening the next document is exactly
  /// such a change.
  PreviewAnchorNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'previewAnchorProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$previewAnchorNotifierHash();

  @$internal
  @override
  PreviewAnchorNotifier create() => PreviewAnchorNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PreviewAnchor? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PreviewAnchor?>(value),
    );
  }
}

String _$previewAnchorNotifierHash() =>
    r'0cb14e164504bdcb9dfb464784487bdc9ee905c5';

/// Holds an `#anchor` until its document is drawn, then hands over the
/// heading it names (`docs/product/wikilinks/doc.md`).
///
/// Apart from `PreviewLinksNotifier`'s state, which is worked out again
/// whenever the preview changes — and opening the next document is exactly
/// such a change.

abstract class _$PreviewAnchorNotifier extends $Notifier<PreviewAnchor?> {
  PreviewAnchor? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<PreviewAnchor?, PreviewAnchor?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PreviewAnchor?, PreviewAnchor?>,
              PreviewAnchor?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
