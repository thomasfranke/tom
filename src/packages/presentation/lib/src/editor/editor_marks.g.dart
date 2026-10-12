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
/// A document's diff is the preview's, not a second comparison: one reading,
/// both panes. A file that is not markdown has no preview, so its lines are
/// compared on their own ([LineDiffNotifier]).

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
/// A document's diff is the preview's, not a second comparison: one reading,
/// both panes. A file that is not markdown has no preview, so its lines are
/// compared on their own ([LineDiffNotifier]).

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
  /// A document's diff is the preview's, not a second comparison: one reading,
  /// both panes. A file that is not markdown has no preview, so its lines are
  /// compared on their own ([LineDiffNotifier]).
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

String _$editorMarksHash() => r'bdcd08f0efb622c088fc046b589ed36b2893c965';
