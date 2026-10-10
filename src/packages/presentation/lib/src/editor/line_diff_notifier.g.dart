// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'line_diff_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// What the text buffer on screen changed against the documents' base, or
/// null when there is nothing to mark
/// (`docs/product/git-workflow/commit/opening-a-change/doc.md`).
///
/// The preview's twin for a file with no page: it listens to the editor, so
/// a keystroke waits as the preview's does. **The `Diff` chip is not read**:
/// a text tab has no chip to turn the marks back on with.

@ProviderFor(LineDiffNotifier)
final lineDiffProvider = LineDiffNotifierProvider._();

/// What the text buffer on screen changed against the documents' base, or
/// null when there is nothing to mark
/// (`docs/product/git-workflow/commit/opening-a-change/doc.md`).
///
/// The preview's twin for a file with no page: it listens to the editor, so
/// a keystroke waits as the preview's does. **The `Diff` chip is not read**:
/// a text tab has no chip to turn the marks back on with.
final class LineDiffNotifierProvider
    extends $NotifierProvider<LineDiffNotifier, LineDiffValueObject?> {
  /// What the text buffer on screen changed against the documents' base, or
  /// null when there is nothing to mark
  /// (`docs/product/git-workflow/commit/opening-a-change/doc.md`).
  ///
  /// The preview's twin for a file with no page: it listens to the editor, so
  /// a keystroke waits as the preview's does. **The `Diff` chip is not read**:
  /// a text tab has no chip to turn the marks back on with.
  LineDiffNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lineDiffProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lineDiffNotifierHash();

  @$internal
  @override
  LineDiffNotifier create() => LineDiffNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LineDiffValueObject? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LineDiffValueObject?>(value),
    );
  }
}

String _$lineDiffNotifierHash() => r'cac446a46054b91bb7bf252ab823433ab2b7d95b';

/// What the text buffer on screen changed against the documents' base, or
/// null when there is nothing to mark
/// (`docs/product/git-workflow/commit/opening-a-change/doc.md`).
///
/// The preview's twin for a file with no page: it listens to the editor, so
/// a keystroke waits as the preview's does. **The `Diff` chip is not read**:
/// a text tab has no chip to turn the marks back on with.

abstract class _$LineDiffNotifier extends $Notifier<LineDiffValueObject?> {
  LineDiffValueObject? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<LineDiffValueObject?, LineDiffValueObject?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LineDiffValueObject?, LineDiffValueObject?>,
              LineDiffValueObject?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
