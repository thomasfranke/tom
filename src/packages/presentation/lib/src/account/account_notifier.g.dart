// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The account of the open space — or the machine's, on Home — read when
/// the space opens or closes, on the git menu's `Reload`, and after a choice
/// (`docs/product/workspace/the-account/doc.md`).
///
/// Kept alive because the button is in the top bar and the popover comes
/// and goes: a reading that died with the popover would be asked for again
/// every time it opened, each time a round of `gh` and `ssh`.

@ProviderFor(AccountNotifier)
final accountProvider = AccountNotifierProvider._();

/// The account of the open space — or the machine's, on Home — read when
/// the space opens or closes, on the git menu's `Reload`, and after a choice
/// (`docs/product/workspace/the-account/doc.md`).
///
/// Kept alive because the button is in the top bar and the popover comes
/// and goes: a reading that died with the popover would be asked for again
/// every time it opened, each time a round of `gh` and `ssh`.
final class AccountNotifierProvider
    extends $NotifierProvider<AccountNotifier, AccountState> {
  /// The account of the open space — or the machine's, on Home — read when
  /// the space opens or closes, on the git menu's `Reload`, and after a choice
  /// (`docs/product/workspace/the-account/doc.md`).
  ///
  /// Kept alive because the button is in the top bar and the popover comes
  /// and goes: a reading that died with the popover would be asked for again
  /// every time it opened, each time a round of `gh` and `ssh`.
  AccountNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountNotifierHash();

  @$internal
  @override
  AccountNotifier create() => AccountNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AccountState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AccountState>(value),
    );
  }
}

String _$accountNotifierHash() => r'6892f82bb7f212cecf6f3dd58a1c6a005d7e4ce7';

/// The account of the open space — or the machine's, on Home — read when
/// the space opens or closes, on the git menu's `Reload`, and after a choice
/// (`docs/product/workspace/the-account/doc.md`).
///
/// Kept alive because the button is in the top bar and the popover comes
/// and goes: a reading that died with the popover would be asked for again
/// every time it opened, each time a round of `gh` and `ssh`.

abstract class _$AccountNotifier extends $Notifier<AccountState> {
  AccountState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AccountState, AccountState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AccountState, AccountState>,
              AccountState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
