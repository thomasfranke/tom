// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preview_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Renders whatever the editor is holding — or the version being read.
///
/// **It reads the buffer, never the disk** — which is what makes an edit
/// appear here with no refresh step, and what keeps one document from being
/// read twice per open (`docs/product/editor/source-mode/doc.md`).
///
/// The one exception is a history entry that has been opened: the session
/// then names a commit, and what is rendered is that version, which the
/// product asks to be shown **rendered rather than as diff text**
/// (`docs/product/git-workflow/file-history/doc.md`). The editor is not
/// listened to at all while that is on screen — a buffer arriving from a
/// pane nobody is being shown must not replace the past.
///
/// It *listens* to the editor rather than watching it: a rebuild would throw
/// the rendered blocks away and flash the pane back to "reading it" on every
/// keystroke.

@ProviderFor(PreviewNotifier)
final previewProvider = PreviewNotifierProvider._();

/// Renders whatever the editor is holding — or the version being read.
///
/// **It reads the buffer, never the disk** — which is what makes an edit
/// appear here with no refresh step, and what keeps one document from being
/// read twice per open (`docs/product/editor/source-mode/doc.md`).
///
/// The one exception is a history entry that has been opened: the session
/// then names a commit, and what is rendered is that version, which the
/// product asks to be shown **rendered rather than as diff text**
/// (`docs/product/git-workflow/file-history/doc.md`). The editor is not
/// listened to at all while that is on screen — a buffer arriving from a
/// pane nobody is being shown must not replace the past.
///
/// It *listens* to the editor rather than watching it: a rebuild would throw
/// the rendered blocks away and flash the pane back to "reading it" on every
/// keystroke.
final class PreviewNotifierProvider
    extends $NotifierProvider<PreviewNotifier, PreviewState> {
  /// Renders whatever the editor is holding — or the version being read.
  ///
  /// **It reads the buffer, never the disk** — which is what makes an edit
  /// appear here with no refresh step, and what keeps one document from being
  /// read twice per open (`docs/product/editor/source-mode/doc.md`).
  ///
  /// The one exception is a history entry that has been opened: the session
  /// then names a commit, and what is rendered is that version, which the
  /// product asks to be shown **rendered rather than as diff text**
  /// (`docs/product/git-workflow/file-history/doc.md`). The editor is not
  /// listened to at all while that is on screen — a buffer arriving from a
  /// pane nobody is being shown must not replace the past.
  ///
  /// It *listens* to the editor rather than watching it: a rebuild would throw
  /// the rendered blocks away and flash the pane back to "reading it" on every
  /// keystroke.
  PreviewNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'previewProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$previewNotifierHash();

  @$internal
  @override
  PreviewNotifier create() => PreviewNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PreviewState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PreviewState>(value),
    );
  }
}

String _$previewNotifierHash() => r'ac1ab5906880d37a92549d875142f6e24860db9d';

/// Renders whatever the editor is holding — or the version being read.
///
/// **It reads the buffer, never the disk** — which is what makes an edit
/// appear here with no refresh step, and what keeps one document from being
/// read twice per open (`docs/product/editor/source-mode/doc.md`).
///
/// The one exception is a history entry that has been opened: the session
/// then names a commit, and what is rendered is that version, which the
/// product asks to be shown **rendered rather than as diff text**
/// (`docs/product/git-workflow/file-history/doc.md`). The editor is not
/// listened to at all while that is on screen — a buffer arriving from a
/// pane nobody is being shown must not replace the past.
///
/// It *listens* to the editor rather than watching it: a rebuild would throw
/// the rendered blocks away and flash the pane back to "reading it" on every
/// keystroke.

abstract class _$PreviewNotifier extends $Notifier<PreviewState> {
  PreviewState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<PreviewState, PreviewState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PreviewState, PreviewState>,
              PreviewState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
