// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_tree_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Drives the explorer: list the space, open and close its folders, and say
/// which document the window should show.
///
/// **No business logic.** It calls a use case and turns [Result] into state;
/// what a space holds and what counts as a document were decided before the
/// result arrived.
///
/// Which folders are closed lives here because no other panel has an opinion
/// about it. Which *document* is open is the opposite — the editor, the
/// preview and the status bar all read it — so that goes to the session and
/// no copy is kept here.

@ProviderFor(FileTree)
final fileTreeProvider = FileTreeProvider._();

/// Drives the explorer: list the space, open and close its folders, and say
/// which document the window should show.
///
/// **No business logic.** It calls a use case and turns [Result] into state;
/// what a space holds and what counts as a document were decided before the
/// result arrived.
///
/// Which folders are closed lives here because no other panel has an opinion
/// about it. Which *document* is open is the opposite — the editor, the
/// preview and the status bar all read it — so that goes to the session and
/// no copy is kept here.
final class FileTreeProvider
    extends $NotifierProvider<FileTree, FileTreeState> {
  /// Drives the explorer: list the space, open and close its folders, and say
  /// which document the window should show.
  ///
  /// **No business logic.** It calls a use case and turns [Result] into state;
  /// what a space holds and what counts as a document were decided before the
  /// result arrived.
  ///
  /// Which folders are closed lives here because no other panel has an opinion
  /// about it. Which *document* is open is the opposite — the editor, the
  /// preview and the status bar all read it — so that goes to the session and
  /// no copy is kept here.
  FileTreeProvider._()
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
  String debugGetCreateSourceHash() => _$fileTreeHash();

  @$internal
  @override
  FileTree create() => FileTree();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FileTreeState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FileTreeState>(value),
    );
  }
}

String _$fileTreeHash() => r'44129361a5882b5ed578ed423c127346543ef3cb';

/// Drives the explorer: list the space, open and close its folders, and say
/// which document the window should show.
///
/// **No business logic.** It calls a use case and turns [Result] into state;
/// what a space holds and what counts as a document were decided before the
/// result arrived.
///
/// Which folders are closed lives here because no other panel has an opinion
/// about it. Which *document* is open is the opposite — the editor, the
/// preview and the status bar all read it — so that goes to the session and
/// no copy is kept here.

abstract class _$FileTree extends $Notifier<FileTreeState> {
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
