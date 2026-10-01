// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'editor_marks.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// What the gutter draws beside the open document, and what tints it.
///
/// **The conflict comes first and wins**, which is the rule the preview
/// already follows: while a marker is on screen the diff is not asked for at
/// all. Conflicts are read from the text and offered only while git says the
/// document is conflicted, so a `<<<<<<<` typed into a document *about*
/// merging stays text (`docs/product/editor/conflicted-document/doc.md`).
///
/// The diff is the preview's, not a second comparison: one reading, both
/// panes — which is also why the marks are absent in source-only mode, where
/// there is no preview and the product asks for them in split.

@ProviderFor(editorMarks)
final editorMarksProvider = EditorMarksProvider._();

/// What the gutter draws beside the open document, and what tints it.
///
/// **The conflict comes first and wins**, which is the rule the preview
/// already follows: while a marker is on screen the diff is not asked for at
/// all. Conflicts are read from the text and offered only while git says the
/// document is conflicted, so a `<<<<<<<` typed into a document *about*
/// merging stays text (`docs/product/editor/conflicted-document/doc.md`).
///
/// The diff is the preview's, not a second comparison: one reading, both
/// panes — which is also why the marks are absent in source-only mode, where
/// there is no preview and the product asks for them in split.

final class EditorMarksProvider
    extends $FunctionalProvider<EditorMarks, EditorMarks, EditorMarks>
    with $Provider<EditorMarks> {
  /// What the gutter draws beside the open document, and what tints it.
  ///
  /// **The conflict comes first and wins**, which is the rule the preview
  /// already follows: while a marker is on screen the diff is not asked for at
  /// all. Conflicts are read from the text and offered only while git says the
  /// document is conflicted, so a `<<<<<<<` typed into a document *about*
  /// merging stays text (`docs/product/editor/conflicted-document/doc.md`).
  ///
  /// The diff is the preview's, not a second comparison: one reading, both
  /// panes — which is also why the marks are absent in source-only mode, where
  /// there is no preview and the product asks for them in split.
  EditorMarksProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'editorMarksProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$editorMarksHash();

  @$internal
  @override
  $ProviderElement<EditorMarks> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  EditorMarks create(Ref ref) {
    return editorMarks(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EditorMarks value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EditorMarks>(value),
    );
  }
}

String _$editorMarksHash() => r'd107d91cab159cf8df4fd0ec3196714941c1e3b0';
