// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preferences_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// What the machine remembers, and the one place it is changed.
///
/// **A preference applies when it is chosen** — there is no OK and no Cancel,
/// so every setter writes the state first and the store after: the window
/// changes behind the popover, and a store that refused loses the choice
/// between runs rather than on screen
/// (`docs/product/preferences/the-popover/doc.md`).
///
/// Kept alive because the theme is read above the shell, by the window
/// itself: a provider nobody in the shell listened to would be disposed
/// between screens and the choice would go with it.

@ProviderFor(PreferencesNotifier)
final preferencesProvider = PreferencesNotifierProvider._();

/// What the machine remembers, and the one place it is changed.
///
/// **A preference applies when it is chosen** — there is no OK and no Cancel,
/// so every setter writes the state first and the store after: the window
/// changes behind the popover, and a store that refused loses the choice
/// between runs rather than on screen
/// (`docs/product/preferences/the-popover/doc.md`).
///
/// Kept alive because the theme is read above the shell, by the window
/// itself: a provider nobody in the shell listened to would be disposed
/// between screens and the choice would go with it.
final class PreferencesNotifierProvider
    extends $NotifierProvider<PreferencesNotifier, PreferencesValueObject> {
  /// What the machine remembers, and the one place it is changed.
  ///
  /// **A preference applies when it is chosen** — there is no OK and no Cancel,
  /// so every setter writes the state first and the store after: the window
  /// changes behind the popover, and a store that refused loses the choice
  /// between runs rather than on screen
  /// (`docs/product/preferences/the-popover/doc.md`).
  ///
  /// Kept alive because the theme is read above the shell, by the window
  /// itself: a provider nobody in the shell listened to would be disposed
  /// between screens and the choice would go with it.
  PreferencesNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'preferencesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$preferencesNotifierHash();

  @$internal
  @override
  PreferencesNotifier create() => PreferencesNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PreferencesValueObject value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PreferencesValueObject>(value),
    );
  }
}

String _$preferencesNotifierHash() =>
    r'3019432ba6a6c072f30234cfa6f48fc05198fc5a';

/// What the machine remembers, and the one place it is changed.
///
/// **A preference applies when it is chosen** — there is no OK and no Cancel,
/// so every setter writes the state first and the store after: the window
/// changes behind the popover, and a store that refused loses the choice
/// between runs rather than on screen
/// (`docs/product/preferences/the-popover/doc.md`).
///
/// Kept alive because the theme is read above the shell, by the window
/// itself: a provider nobody in the shell listened to would be disposed
/// between screens and the choice would go with it.

abstract class _$PreferencesNotifier extends $Notifier<PreferencesValueObject> {
  PreferencesValueObject build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<PreferencesValueObject, PreferencesValueObject>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PreferencesValueObject, PreferencesValueObject>,
              PreferencesValueObject,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
