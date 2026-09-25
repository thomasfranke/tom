// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preview_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Renders the editor's buffer, never the disk — or, for an opened history
/// entry, the version git holds (`docs/product/editor/source-mode/doc.md`).
///
/// It *listens* to the editor rather than watching: a rebuild would throw
/// the rendered blocks away and flash "reading it" on every keystroke.

@ProviderFor(PreviewNotifier)
final previewProvider = PreviewNotifierProvider._();

/// Renders the editor's buffer, never the disk — or, for an opened history
/// entry, the version git holds (`docs/product/editor/source-mode/doc.md`).
///
/// It *listens* to the editor rather than watching: a rebuild would throw
/// the rendered blocks away and flash "reading it" on every keystroke.
final class PreviewNotifierProvider
    extends $NotifierProvider<PreviewNotifier, PreviewState> {
  /// Renders the editor's buffer, never the disk — or, for an opened history
  /// entry, the version git holds (`docs/product/editor/source-mode/doc.md`).
  ///
  /// It *listens* to the editor rather than watching: a rebuild would throw
  /// the rendered blocks away and flash "reading it" on every keystroke.
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

String _$previewNotifierHash() => r'd6ae5d8c63017ee82c12966c8f057ddc32a8bc92';

/// Renders the editor's buffer, never the disk — or, for an opened history
/// entry, the version git holds (`docs/product/editor/source-mode/doc.md`).
///
/// It *listens* to the editor rather than watching: a rebuild would throw
/// the rendered blocks away and flash "reading it" on every keystroke.

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
