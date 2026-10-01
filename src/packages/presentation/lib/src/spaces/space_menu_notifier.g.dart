// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'space_menu_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The way out of a space, and the way straight into another one
/// (`docs/product/workspace/leaving-a-space/doc.md`).
///
/// It reads the same recents Home does, through the same use case: one list,
/// asked for twice, so a space forgotten on Home is gone here too.

@ProviderFor(SpaceMenuNotifier)
final spaceMenuProvider = SpaceMenuNotifierProvider._();

/// The way out of a space, and the way straight into another one
/// (`docs/product/workspace/leaving-a-space/doc.md`).
///
/// It reads the same recents Home does, through the same use case: one list,
/// asked for twice, so a space forgotten on Home is gone here too.
final class SpaceMenuNotifierProvider
    extends $NotifierProvider<SpaceMenuNotifier, SpaceMenuState> {
  /// The way out of a space, and the way straight into another one
  /// (`docs/product/workspace/leaving-a-space/doc.md`).
  ///
  /// It reads the same recents Home does, through the same use case: one list,
  /// asked for twice, so a space forgotten on Home is gone here too.
  SpaceMenuNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'spaceMenuProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$spaceMenuNotifierHash();

  @$internal
  @override
  SpaceMenuNotifier create() => SpaceMenuNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SpaceMenuState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SpaceMenuState>(value),
    );
  }
}

String _$spaceMenuNotifierHash() => r'941a711a8b347a522cc53ddfd8015d0a17b6eb85';

/// The way out of a space, and the way straight into another one
/// (`docs/product/workspace/leaving-a-space/doc.md`).
///
/// It reads the same recents Home does, through the same use case: one list,
/// asked for twice, so a space forgotten on Home is gone here too.

abstract class _$SpaceMenuNotifier extends $Notifier<SpaceMenuState> {
  SpaceMenuState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SpaceMenuState, SpaceMenuState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SpaceMenuState, SpaceMenuState>,
              SpaceMenuState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
