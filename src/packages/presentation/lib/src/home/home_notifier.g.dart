// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Drives the first screen: open a folder, clone one, go back to one,
/// forget one.
///
/// No business logic here — it calls a use case and turns [Result] into
/// state.

@ProviderFor(HomeNotifier)
final homeProvider = HomeNotifierProvider._();

/// Drives the first screen: open a folder, clone one, go back to one,
/// forget one.
///
/// No business logic here — it calls a use case and turns [Result] into
/// state.
final class HomeNotifierProvider
    extends $NotifierProvider<HomeNotifier, HomeState> {
  /// Drives the first screen: open a folder, clone one, go back to one,
  /// forget one.
  ///
  /// No business logic here — it calls a use case and turns [Result] into
  /// state.
  HomeNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeNotifierHash();

  @$internal
  @override
  HomeNotifier create() => HomeNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HomeState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HomeState>(value),
    );
  }
}

String _$homeNotifierHash() => r'a062291a2e23ab58e561519088a277c91a8a80fa';

/// Drives the first screen: open a folder, clone one, go back to one,
/// forget one.
///
/// No business logic here — it calls a use case and turns [Result] into
/// state.

abstract class _$HomeNotifier extends $Notifier<HomeState> {
  HomeState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<HomeState, HomeState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<HomeState, HomeState>,
              HomeState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
