// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preview_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Renders whatever the editor is holding — or the version being read.
///
/// **It reads the buffer, never the disk**, which is what makes an edit
/// appear here with no refresh step (`docs/product/editor/source-mode/doc.md`).
/// The one exception is an opened history entry: the session names a commit,
/// that version is what is rendered — not diff text — and the editor is not
/// listened to at all while it is on screen.
///
/// It *listens* rather than watching: a rebuild would throw the rendered
/// blocks away and flash the pane back to "reading it" on every keystroke.

@ProviderFor(PreviewNotifier)
final previewProvider = PreviewNotifierProvider._();

/// Renders whatever the editor is holding — or the version being read.
///
/// **It reads the buffer, never the disk**, which is what makes an edit
/// appear here with no refresh step (`docs/product/editor/source-mode/doc.md`).
/// The one exception is an opened history entry: the session names a commit,
/// that version is what is rendered — not diff text — and the editor is not
/// listened to at all while it is on screen.
///
/// It *listens* rather than watching: a rebuild would throw the rendered
/// blocks away and flash the pane back to "reading it" on every keystroke.
final class PreviewNotifierProvider
    extends $NotifierProvider<PreviewNotifier, PreviewState> {
  /// Renders whatever the editor is holding — or the version being read.
  ///
  /// **It reads the buffer, never the disk**, which is what makes an edit
  /// appear here with no refresh step (`docs/product/editor/source-mode/doc.md`).
  /// The one exception is an opened history entry: the session names a commit,
  /// that version is what is rendered — not diff text — and the editor is not
  /// listened to at all while it is on screen.
  ///
  /// It *listens* rather than watching: a rebuild would throw the rendered
  /// blocks away and flash the pane back to "reading it" on every keystroke.
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

String _$previewNotifierHash() => r'0da6066542b844596c6363c4adaad6012e0d08fa';

/// Renders whatever the editor is holding — or the version being read.
///
/// **It reads the buffer, never the disk**, which is what makes an edit
/// appear here with no refresh step (`docs/product/editor/source-mode/doc.md`).
/// The one exception is an opened history entry: the session names a commit,
/// that version is what is rendered — not diff text — and the editor is not
/// listened to at all while it is on screen.
///
/// It *listens* rather than watching: a rebuild would throw the rendered
/// blocks away and flash the pane back to "reading it" on every keystroke.

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
