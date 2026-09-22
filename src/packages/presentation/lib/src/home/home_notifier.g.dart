// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Drives the first screen: open a folder, go back to one, forget one.
///
/// **No business logic here** — it calls a use case and turns [Result] into
/// state. Pure Dart like the rest of this package, so `dart test` runs it
/// with no Flutter binding and a phone could drive the same notifier.

@ProviderFor(Home)
final homeProvider = HomeProvider._();

/// Drives the first screen: open a folder, go back to one, forget one.
///
/// **No business logic here** — it calls a use case and turns [Result] into
/// state. Pure Dart like the rest of this package, so `dart test` runs it
/// with no Flutter binding and a phone could drive the same notifier.
final class HomeProvider extends $NotifierProvider<Home, HomeState> {
  /// Drives the first screen: open a folder, go back to one, forget one.
  ///
  /// **No business logic here** — it calls a use case and turns [Result] into
  /// state. Pure Dart like the rest of this package, so `dart test` runs it
  /// with no Flutter binding and a phone could drive the same notifier.
  HomeProvider._()
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
  String debugGetCreateSourceHash() => _$homeHash();

  @$internal
  @override
  Home create() => Home();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HomeState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HomeState>(value),
    );
  }
}

String _$homeHash() => r'3e86728d44007c587ee9fa4d668e87d02b6fe04f';

/// Drives the first screen: open a folder, go back to one, forget one.
///
/// **No business logic here** — it calls a use case and turns [Result] into
/// state. Pure Dart like the rest of this package, so `dart test` runs it
/// with no Flutter binding and a phone could drive the same notifier.

abstract class _$Home extends $Notifier<HomeState> {
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
