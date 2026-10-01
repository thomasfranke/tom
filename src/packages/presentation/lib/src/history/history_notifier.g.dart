// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Lists what touched the open document, and opens one of those versions.
///
/// It follows the document, not the repository
/// (`docs/product/git-workflow/file-history/doc.md`). Which version is open
/// is written to the session, because the preview and the bar read it too.

@ProviderFor(HistoryNotifier)
final historyProvider = HistoryNotifierProvider._();

/// Lists what touched the open document, and opens one of those versions.
///
/// It follows the document, not the repository
/// (`docs/product/git-workflow/file-history/doc.md`). Which version is open
/// is written to the session, because the preview and the bar read it too.
final class HistoryNotifierProvider
    extends $NotifierProvider<HistoryNotifier, HistoryState> {
  /// Lists what touched the open document, and opens one of those versions.
  ///
  /// It follows the document, not the repository
  /// (`docs/product/git-workflow/file-history/doc.md`). Which version is open
  /// is written to the session, because the preview and the bar read it too.
  HistoryNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'historyProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$historyNotifierHash();

  @$internal
  @override
  HistoryNotifier create() => HistoryNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HistoryState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HistoryState>(value),
    );
  }
}

String _$historyNotifierHash() => r'eeca63687c31107263fe6c246f1679e7e0fde5d2';

/// Lists what touched the open document, and opens one of those versions.
///
/// It follows the document, not the repository
/// (`docs/product/git-workflow/file-history/doc.md`). Which version is open
/// is written to the session, because the preview and the bar read it too.

abstract class _$HistoryNotifier extends $Notifier<HistoryState> {
  HistoryState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<HistoryState, HistoryState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<HistoryState, HistoryState>,
              HistoryState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
