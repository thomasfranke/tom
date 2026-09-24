// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_tree_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Drives the explorer: list the space, open and close its folders, and say
/// which document the window should show. **No business logic** — it calls a
/// use case and turns [Result] into state.
///
/// Which folders are closed lives here because no other panel cares. Which
/// *document* is open is the opposite, so it goes to the session.

@ProviderFor(FileTreeNotifier)
final fileTreeProvider = FileTreeNotifierProvider._();

/// Drives the explorer: list the space, open and close its folders, and say
/// which document the window should show. **No business logic** — it calls a
/// use case and turns [Result] into state.
///
/// Which folders are closed lives here because no other panel cares. Which
/// *document* is open is the opposite, so it goes to the session.
final class FileTreeNotifierProvider
    extends $NotifierProvider<FileTreeNotifier, FileTreeState> {
  /// Drives the explorer: list the space, open and close its folders, and say
  /// which document the window should show. **No business logic** — it calls a
  /// use case and turns [Result] into state.
  ///
  /// Which folders are closed lives here because no other panel cares. Which
  /// *document* is open is the opposite, so it goes to the session.
  FileTreeNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'fileTreeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$fileTreeNotifierHash();

  @$internal
  @override
  FileTreeNotifier create() => FileTreeNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FileTreeState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FileTreeState>(value),
    );
  }
}

String _$fileTreeNotifierHash() => r'5f6a2c85683352b87fc05da258e3a095cc0e934e';

/// Drives the explorer: list the space, open and close its folders, and say
/// which document the window should show. **No business logic** — it calls a
/// use case and turns [Result] into state.
///
/// Which folders are closed lives here because no other panel cares. Which
/// *document* is open is the opposite, so it goes to the session.

abstract class _$FileTreeNotifier extends $Notifier<FileTreeState> {
  FileTreeState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<FileTreeState, FileTreeState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<FileTreeState, FileTreeState>,
              FileTreeState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
