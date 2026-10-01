// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'editor_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The one buffer in the app, over whatever document the session says is
/// open; the preview renders it rather than the file
/// (`docs/product/editor/source-mode/doc.md`).
///
/// Kept alive because changing the mode takes the source panel off screen,
/// and an unsaved buffer must not go with it.

@ProviderFor(EditorNotifier)
final editorProvider = EditorNotifierProvider._();

/// The one buffer in the app, over whatever document the session says is
/// open; the preview renders it rather than the file
/// (`docs/product/editor/source-mode/doc.md`).
///
/// Kept alive because changing the mode takes the source panel off screen,
/// and an unsaved buffer must not go with it.
final class EditorNotifierProvider
    extends $NotifierProvider<EditorNotifier, EditorState> {
  /// The one buffer in the app, over whatever document the session says is
  /// open; the preview renders it rather than the file
  /// (`docs/product/editor/source-mode/doc.md`).
  ///
  /// Kept alive because changing the mode takes the source panel off screen,
  /// and an unsaved buffer must not go with it.
  EditorNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'editorProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$editorNotifierHash();

  @$internal
  @override
  EditorNotifier create() => EditorNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EditorState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EditorState>(value),
    );
  }
}

String _$editorNotifierHash() => r'e9d79f1f5a9af57ae1794cf7bf95324ab370163c';

/// The one buffer in the app, over whatever document the session says is
/// open; the preview renders it rather than the file
/// (`docs/product/editor/source-mode/doc.md`).
///
/// Kept alive because changing the mode takes the source panel off screen,
/// and an unsaved buffer must not go with it.

abstract class _$EditorNotifier extends $Notifier<EditorState> {
  EditorState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<EditorState, EditorState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<EditorState, EditorState>,
              EditorState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
