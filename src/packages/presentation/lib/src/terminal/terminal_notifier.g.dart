// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'terminal_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Starts the space's shell the first time the tab is drawn, keeps it while
/// the tab is away, and ends it with the space
/// (`docs/product/workspace/terminal/doc.md`).
///
/// **Kept alive**, because the panel is built only while its tab is chosen:
/// a shell owned by the widget would die on every switch to `Commands`.
/// What it drew is kept as text ([transcript]) for the emulator the next
/// panel builds, since the emulator itself is a widget's.

@ProviderFor(TerminalNotifier)
final terminalProvider = TerminalNotifierProvider._();

/// Starts the space's shell the first time the tab is drawn, keeps it while
/// the tab is away, and ends it with the space
/// (`docs/product/workspace/terminal/doc.md`).
///
/// **Kept alive**, because the panel is built only while its tab is chosen:
/// a shell owned by the widget would die on every switch to `Commands`.
/// What it drew is kept as text ([transcript]) for the emulator the next
/// panel builds, since the emulator itself is a widget's.
final class TerminalNotifierProvider
    extends $NotifierProvider<TerminalNotifier, TerminalState> {
  /// Starts the space's shell the first time the tab is drawn, keeps it while
  /// the tab is away, and ends it with the space
  /// (`docs/product/workspace/terminal/doc.md`).
  ///
  /// **Kept alive**, because the panel is built only while its tab is chosen:
  /// a shell owned by the widget would die on every switch to `Commands`.
  /// What it drew is kept as text ([transcript]) for the emulator the next
  /// panel builds, since the emulator itself is a widget's.
  TerminalNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'terminalProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$terminalNotifierHash();

  @$internal
  @override
  TerminalNotifier create() => TerminalNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TerminalState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TerminalState>(value),
    );
  }
}

String _$terminalNotifierHash() => r'fcbb89d29bef6b504dd80449d24367a88ecb001e';

/// Starts the space's shell the first time the tab is drawn, keeps it while
/// the tab is away, and ends it with the space
/// (`docs/product/workspace/terminal/doc.md`).
///
/// **Kept alive**, because the panel is built only while its tab is chosen:
/// a shell owned by the widget would die on every switch to `Commands`.
/// What it drew is kept as text ([transcript]) for the emulator the next
/// panel builds, since the emulator itself is a widget's.

abstract class _$TerminalNotifier extends $Notifier<TerminalState> {
  TerminalState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<TerminalState, TerminalState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TerminalState, TerminalState>,
              TerminalState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
