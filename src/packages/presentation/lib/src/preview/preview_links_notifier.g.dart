// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preview_links_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The preview's wikilinks resolved against the file tree's listing
/// ([Decision 28](../../../../../../docs/technical/decisions/028-a-wikilink-resolves-by-name-inside-the-space.md)).
///
/// Beside the preview rather than inside it, so only a surface that draws
/// links makes the tree exist: the listing is the tree's walk, read once per
/// space and again whenever TOM writes a file, never a second walk of its own.

@ProviderFor(PreviewLinksNotifier)
final previewLinksProvider = PreviewLinksNotifierProvider._();

/// The preview's wikilinks resolved against the file tree's listing
/// ([Decision 28](../../../../../../docs/technical/decisions/028-a-wikilink-resolves-by-name-inside-the-space.md)).
///
/// Beside the preview rather than inside it, so only a surface that draws
/// links makes the tree exist: the listing is the tree's walk, read once per
/// space and again whenever TOM writes a file, never a second walk of its own.
final class PreviewLinksNotifierProvider
    extends $NotifierProvider<PreviewLinksNotifier, PreviewLinksState> {
  /// The preview's wikilinks resolved against the file tree's listing
  /// ([Decision 28](../../../../../../docs/technical/decisions/028-a-wikilink-resolves-by-name-inside-the-space.md)).
  ///
  /// Beside the preview rather than inside it, so only a surface that draws
  /// links makes the tree exist: the listing is the tree's walk, read once per
  /// space and again whenever TOM writes a file, never a second walk of its own.
  PreviewLinksNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'previewLinksProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$previewLinksNotifierHash();

  @$internal
  @override
  PreviewLinksNotifier create() => PreviewLinksNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PreviewLinksState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PreviewLinksState>(value),
    );
  }
}

String _$previewLinksNotifierHash() =>
    r'40f10139156d35b7054027ba9cf3cfb3dd80b99e';

/// The preview's wikilinks resolved against the file tree's listing
/// ([Decision 28](../../../../../../docs/technical/decisions/028-a-wikilink-resolves-by-name-inside-the-space.md)).
///
/// Beside the preview rather than inside it, so only a surface that draws
/// links makes the tree exist: the listing is the tree's walk, read once per
/// space and again whenever TOM writes a file, never a second walk of its own.

abstract class _$PreviewLinksNotifier extends $Notifier<PreviewLinksState> {
  PreviewLinksState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<PreviewLinksState, PreviewLinksState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PreviewLinksState, PreviewLinksState>,
              PreviewLinksState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
