// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'held_buffers_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Every unsaved buffer a tab holds while another is on screen, by path
/// (`docs/product/editor/tabs/doc.md`).
///
/// The editor still has one buffer, the one on screen; choosing another tab
/// puts a dirty one here and takes the next one back out, so switching tabs
/// never throws work away. Emptied with the space, because a buffer belongs
/// to a folder.
///
/// Typed [EditorState] rather than `EditorReady` because the generator
/// cannot see a class Freezed declares in a part; only ready buffers are
/// ever put here.

@ProviderFor(HeldBuffersNotifier)
final heldBuffersProvider = HeldBuffersNotifierProvider._();

/// Every unsaved buffer a tab holds while another is on screen, by path
/// (`docs/product/editor/tabs/doc.md`).
///
/// The editor still has one buffer, the one on screen; choosing another tab
/// puts a dirty one here and takes the next one back out, so switching tabs
/// never throws work away. Emptied with the space, because a buffer belongs
/// to a folder.
///
/// Typed [EditorState] rather than `EditorReady` because the generator
/// cannot see a class Freezed declares in a part; only ready buffers are
/// ever put here.
final class HeldBuffersNotifierProvider
    extends
        $NotifierProvider<HeldBuffersNotifier, Map<DocumentTab, EditorState>> {
  /// Every unsaved buffer a tab holds while another is on screen, by path
  /// (`docs/product/editor/tabs/doc.md`).
  ///
  /// The editor still has one buffer, the one on screen; choosing another tab
  /// puts a dirty one here and takes the next one back out, so switching tabs
  /// never throws work away. Emptied with the space, because a buffer belongs
  /// to a folder.
  ///
  /// Typed [EditorState] rather than `EditorReady` because the generator
  /// cannot see a class Freezed declares in a part; only ready buffers are
  /// ever put here.
  HeldBuffersNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'heldBuffersProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$heldBuffersNotifierHash();

  @$internal
  @override
  HeldBuffersNotifier create() => HeldBuffersNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<DocumentTab, EditorState> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<DocumentTab, EditorState>>(
        value,
      ),
    );
  }
}

String _$heldBuffersNotifierHash() =>
    r'1fe2a983a2111327c4fb7e63369fa2d49680e303';

/// Every unsaved buffer a tab holds while another is on screen, by path
/// (`docs/product/editor/tabs/doc.md`).
///
/// The editor still has one buffer, the one on screen; choosing another tab
/// puts a dirty one here and takes the next one back out, so switching tabs
/// never throws work away. Emptied with the space, because a buffer belongs
/// to a folder.
///
/// Typed [EditorState] rather than `EditorReady` because the generator
/// cannot see a class Freezed declares in a part; only ready buffers are
/// ever put here.

abstract class _$HeldBuffersNotifier
    extends $Notifier<Map<DocumentTab, EditorState>> {
  Map<DocumentTab, EditorState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              Map<DocumentTab, EditorState>,
              Map<DocumentTab, EditorState>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                Map<DocumentTab, EditorState>,
                Map<DocumentTab, EditorState>
              >,
              Map<DocumentTab, EditorState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Every tab with edits the disk does not have: the held buffers and the
/// one on screen. What the tab strip and the tree mark with a dot.

@ProviderFor(unsavedDocuments)
final unsavedDocumentsProvider = UnsavedDocumentsProvider._();

/// Every tab with edits the disk does not have: the held buffers and the
/// one on screen. What the tab strip and the tree mark with a dot.

final class UnsavedDocumentsProvider
    extends
        $FunctionalProvider<
          Set<DocumentTab>,
          Set<DocumentTab>,
          Set<DocumentTab>
        >
    with $Provider<Set<DocumentTab>> {
  /// Every tab with edits the disk does not have: the held buffers and the
  /// one on screen. What the tab strip and the tree mark with a dot.
  UnsavedDocumentsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'unsavedDocumentsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$unsavedDocumentsHash();

  @$internal
  @override
  $ProviderElement<Set<DocumentTab>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Set<DocumentTab> create(Ref ref) {
    return unsavedDocuments(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<DocumentTab> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<DocumentTab>>(value),
    );
  }
}

String _$unsavedDocumentsHash() => r'8b1bf4eb08acd5396c0821335095c65b192ce7f7';
