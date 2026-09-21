// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'panel_registry.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The registry in scope.
///
/// Overridden by `runTom` at the root of the app. It has no default: a shell
/// built without one is a wiring mistake, and failing loudly at startup is
/// better than drawing an empty window.

@ProviderFor(panelRegistry)
final panelRegistryProvider = PanelRegistryProvider._();

/// The registry in scope.
///
/// Overridden by `runTom` at the root of the app. It has no default: a shell
/// built without one is a wiring mistake, and failing loudly at startup is
/// better than drawing an empty window.

final class PanelRegistryProvider
    extends $FunctionalProvider<PanelRegistry, PanelRegistry, PanelRegistry>
    with $Provider<PanelRegistry> {
  /// The registry in scope.
  ///
  /// Overridden by `runTom` at the root of the app. It has no default: a shell
  /// built without one is a wiring mistake, and failing loudly at startup is
  /// better than drawing an empty window.
  PanelRegistryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'panelRegistryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$panelRegistryHash();

  @$internal
  @override
  $ProviderElement<PanelRegistry> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PanelRegistry create(Ref ref) {
    return panelRegistry(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PanelRegistry value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PanelRegistry>(value),
    );
  }
}

String _$panelRegistryHash() => r'c7f8a37064809b7797a00cc0288c70bae7a0d3cd';
