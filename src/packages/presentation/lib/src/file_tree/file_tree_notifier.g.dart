// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_tree_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Drives the explorer: list the space, open and close its folders, say
/// which document the window should show. No business logic — a use case is
/// called and its [Result] becomes state.
///
/// Which folders are closed lives here because no other panel cares; which
/// document is open goes to the session, because every panel does.

@ProviderFor(FileTreeNotifier)
final fileTreeProvider = FileTreeNotifierProvider._();

/// Drives the explorer: list the space, open and close its folders, say
/// which document the window should show. No business logic — a use case is
/// called and its [Result] becomes state.
///
/// Which folders are closed lives here because no other panel cares; which
/// document is open goes to the session, because every panel does.
final class FileTreeNotifierProvider
    extends $NotifierProvider<FileTreeNotifier, FileTreeState> {
  /// Drives the explorer: list the space, open and close its folders, say
  /// which document the window should show. No business logic — a use case is
  /// called and its [Result] becomes state.
  ///
  /// Which folders are closed lives here because no other panel cares; which
  /// document is open goes to the session, because every panel does.
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

String _$fileTreeNotifierHash() => r'25e567ab0a15b8779f8a515ac826ec838d6f8695';

/// Drives the explorer: list the space, open and close its folders, say
/// which document the window should show. No business logic — a use case is
/// called and its [Result] becomes state.
///
/// Which folders are closed lives here because no other panel cares; which
/// document is open goes to the session, because every panel does.

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
