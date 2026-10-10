// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diff_base_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Writes the branch the checked-out one came from, and where it left it,
/// into [SpaceSessionState.comparingAgainst]
/// (`docs/product/diff/branch-diff/doc.md`).
///
/// It follows the session's git reading rather than the operations that move
/// `HEAD`, so a branch switched in a terminal is followed like one switched
/// here: another branch is read whole, any other reading only moves the fork
/// point, which a merge or a pull can shift. **Kept alive, and made to exist
/// by the shell**, because nothing else listens to it — the session is what
/// the preview and the bar read.

@ProviderFor(DiffBaseNotifier)
final diffBaseProvider = DiffBaseNotifierProvider._();

/// Writes the branch the checked-out one came from, and where it left it,
/// into [SpaceSessionState.comparingAgainst]
/// (`docs/product/diff/branch-diff/doc.md`).
///
/// It follows the session's git reading rather than the operations that move
/// `HEAD`, so a branch switched in a terminal is followed like one switched
/// here: another branch is read whole, any other reading only moves the fork
/// point, which a merge or a pull can shift. **Kept alive, and made to exist
/// by the shell**, because nothing else listens to it — the session is what
/// the preview and the bar read.
final class DiffBaseNotifierProvider
    extends $NotifierProvider<DiffBaseNotifier, void> {
  /// Writes the branch the checked-out one came from, and where it left it,
  /// into [SpaceSessionState.comparingAgainst]
  /// (`docs/product/diff/branch-diff/doc.md`).
  ///
  /// It follows the session's git reading rather than the operations that move
  /// `HEAD`, so a branch switched in a terminal is followed like one switched
  /// here: another branch is read whole, any other reading only moves the fork
  /// point, which a merge or a pull can shift. **Kept alive, and made to exist
  /// by the shell**, because nothing else listens to it — the session is what
  /// the preview and the bar read.
  DiffBaseNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'diffBaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$diffBaseNotifierHash();

  @$internal
  @override
  DiffBaseNotifier create() => DiffBaseNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$diffBaseNotifierHash() => r'a31fabe86006597a6eeeb62d79bf992858578418';

/// Writes the branch the checked-out one came from, and where it left it,
/// into [SpaceSessionState.comparingAgainst]
/// (`docs/product/diff/branch-diff/doc.md`).
///
/// It follows the session's git reading rather than the operations that move
/// `HEAD`, so a branch switched in a terminal is followed like one switched
/// here: another branch is read whole, any other reading only moves the fork
/// point, which a merge or a pull can shift. **Kept alive, and made to exist
/// by the shell**, because nothing else listens to it — the session is what
/// the preview and the bar read.

abstract class _$DiffBaseNotifier extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
