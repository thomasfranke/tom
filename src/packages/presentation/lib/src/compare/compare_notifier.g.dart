// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'compare_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Offers the branches and the document's commits, and records the choice.
///
/// **It asks git nothing.** The branches are the switcher's reading and the
/// commits are the history panel's, so what this surface offers cannot
/// disagree with what the control beside it says or the list under it shows.
/// The choice is written to the session, because the preview and the bar
/// above the document both have to know.

@ProviderFor(CompareNotifier)
final compareProvider = CompareNotifierProvider._();

/// Offers the branches and the document's commits, and records the choice.
///
/// **It asks git nothing.** The branches are the switcher's reading and the
/// commits are the history panel's, so what this surface offers cannot
/// disagree with what the control beside it says or the list under it shows.
/// The choice is written to the session, because the preview and the bar
/// above the document both have to know.
final class CompareNotifierProvider
    extends $NotifierProvider<CompareNotifier, CompareState> {
  /// Offers the branches and the document's commits, and records the choice.
  ///
  /// **It asks git nothing.** The branches are the switcher's reading and the
  /// commits are the history panel's, so what this surface offers cannot
  /// disagree with what the control beside it says or the list under it shows.
  /// The choice is written to the session, because the preview and the bar
  /// above the document both have to know.
  CompareNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'compareProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$compareNotifierHash();

  @$internal
  @override
  CompareNotifier create() => CompareNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CompareState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CompareState>(value),
    );
  }
}

String _$compareNotifierHash() => r'e31e60d65909e0f5775c4fbd0817537c3854b5dd';

/// Offers the branches and the document's commits, and records the choice.
///
/// **It asks git nothing.** The branches are the switcher's reading and the
/// commits are the history panel's, so what this surface offers cannot
/// disagree with what the control beside it says or the list under it shows.
/// The choice is written to the session, because the preview and the bar
/// above the document both have to know.

abstract class _$CompareNotifier extends $Notifier<CompareState> {
  CompareState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<CompareState, CompareState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CompareState, CompareState>,
              CompareState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
