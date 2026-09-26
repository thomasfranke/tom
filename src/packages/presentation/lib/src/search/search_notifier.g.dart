// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Indexes the space when it opens, answers the box, and opens what is
/// clicked (`docs/product/search/full-text-search/doc.md`).
///
/// One notifier for two surfaces — the field above the file tree and the
/// results in the aside — because they are one conversation, and the index
/// under it is a cache that nothing else in the app reads.

@ProviderFor(SearchNotifier)
final searchProvider = SearchNotifierProvider._();

/// Indexes the space when it opens, answers the box, and opens what is
/// clicked (`docs/product/search/full-text-search/doc.md`).
///
/// One notifier for two surfaces — the field above the file tree and the
/// results in the aside — because they are one conversation, and the index
/// under it is a cache that nothing else in the app reads.
final class SearchNotifierProvider
    extends $NotifierProvider<SearchNotifier, SearchState> {
  /// Indexes the space when it opens, answers the box, and opens what is
  /// clicked (`docs/product/search/full-text-search/doc.md`).
  ///
  /// One notifier for two surfaces — the field above the file tree and the
  /// results in the aside — because they are one conversation, and the index
  /// under it is a cache that nothing else in the app reads.
  SearchNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchNotifierHash();

  @$internal
  @override
  SearchNotifier create() => SearchNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SearchState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SearchState>(value),
    );
  }
}

String _$searchNotifierHash() => r'9febad37225ec36a3c8ca0723569db2c47171a47';

/// Indexes the space when it opens, answers the box, and opens what is
/// clicked (`docs/product/search/full-text-search/doc.md`).
///
/// One notifier for two surfaces — the field above the file tree and the
/// results in the aside — because they are one conversation, and the index
/// under it is a cache that nothing else in the app reads.

abstract class _$SearchNotifier extends $Notifier<SearchState> {
  SearchState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SearchState, SearchState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SearchState, SearchState>,
              SearchState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
