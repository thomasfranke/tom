// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'updates_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// What the host last said about a newer TOM
/// (`docs/product/about/doc.md`).
///
/// Kept alive: the gear's dot and the status bar read it from the window,
/// long before anybody opens the dialog. It asks on its own only when the
/// person ticked `Check for updates when TOM opens` — once, for the
/// preference as the store first held it.

@ProviderFor(UpdatesNotifier)
final updatesProvider = UpdatesNotifierProvider._();

/// What the host last said about a newer TOM
/// (`docs/product/about/doc.md`).
///
/// Kept alive: the gear's dot and the status bar read it from the window,
/// long before anybody opens the dialog. It asks on its own only when the
/// person ticked `Check for updates when TOM opens` — once, for the
/// preference as the store first held it.
final class UpdatesNotifierProvider
    extends $NotifierProvider<UpdatesNotifier, UpdatesState> {
  /// What the host last said about a newer TOM
  /// (`docs/product/about/doc.md`).
  ///
  /// Kept alive: the gear's dot and the status bar read it from the window,
  /// long before anybody opens the dialog. It asks on its own only when the
  /// person ticked `Check for updates when TOM opens` — once, for the
  /// preference as the store first held it.
  UpdatesNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updatesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updatesNotifierHash();

  @$internal
  @override
  UpdatesNotifier create() => UpdatesNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdatesState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdatesState>(value),
    );
  }
}

String _$updatesNotifierHash() => r'8f6cb058ceea4cb575b25fd780750e7edcfab016';

/// What the host last said about a newer TOM
/// (`docs/product/about/doc.md`).
///
/// Kept alive: the gear's dot and the status bar read it from the window,
/// long before anybody opens the dialog. It asks on its own only when the
/// person ticked `Check for updates when TOM opens` — once, for the
/// preference as the store first held it.

abstract class _$UpdatesNotifier extends $Notifier<UpdatesState> {
  UpdatesState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<UpdatesState, UpdatesState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<UpdatesState, UpdatesState>,
              UpdatesState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
