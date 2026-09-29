// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workspace_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The three controls at the right of the top bar, and the right column's
/// switch (`docs/product/workspace/columns/doc.md`).
///
/// Kept alive because the theme is read above the shell, by the window
/// itself: a provider nobody in the shell listened to would be disposed
/// between screens and the choice would go with it.

@ProviderFor(WorkspaceNotifier)
final workspaceProvider = WorkspaceNotifierProvider._();

/// The three controls at the right of the top bar, and the right column's
/// switch (`docs/product/workspace/columns/doc.md`).
///
/// Kept alive because the theme is read above the shell, by the window
/// itself: a provider nobody in the shell listened to would be disposed
/// between screens and the choice would go with it.
final class WorkspaceNotifierProvider
    extends $NotifierProvider<WorkspaceNotifier, WorkspaceState> {
  /// The three controls at the right of the top bar, and the right column's
  /// switch (`docs/product/workspace/columns/doc.md`).
  ///
  /// Kept alive because the theme is read above the shell, by the window
  /// itself: a provider nobody in the shell listened to would be disposed
  /// between screens and the choice would go with it.
  WorkspaceNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'workspaceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$workspaceNotifierHash();

  @$internal
  @override
  WorkspaceNotifier create() => WorkspaceNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WorkspaceState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WorkspaceState>(value),
    );
  }
}

String _$workspaceNotifierHash() => r'ee83ef9cea398153ac3c42a20088a6aae2686f9b';

/// The three controls at the right of the top bar, and the right column's
/// switch (`docs/product/workspace/columns/doc.md`).
///
/// Kept alive because the theme is read above the shell, by the window
/// itself: a provider nobody in the shell listened to would be disposed
/// between screens and the choice would go with it.

abstract class _$WorkspaceNotifier extends $Notifier<WorkspaceState> {
  WorkspaceState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<WorkspaceState, WorkspaceState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<WorkspaceState, WorkspaceState>,
              WorkspaceState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
