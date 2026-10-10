// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'export_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The export the tab's menu asked for (`docs/product/export/doc.md`).
///
/// **What is exported is the buffer, not the file**: the preview renders the
/// buffer, and the export is the preview's rendering. Kept alive because the
/// menu that starts it is gone before the file is written; emptied when
/// another document opens, which is the next thing happening.

@ProviderFor(ExportNotifier)
final exportProvider = ExportNotifierProvider._();

/// The export the tab's menu asked for (`docs/product/export/doc.md`).
///
/// **What is exported is the buffer, not the file**: the preview renders the
/// buffer, and the export is the preview's rendering. Kept alive because the
/// menu that starts it is gone before the file is written; emptied when
/// another document opens, which is the next thing happening.
final class ExportNotifierProvider
    extends $NotifierProvider<ExportNotifier, ExportState> {
  /// The export the tab's menu asked for (`docs/product/export/doc.md`).
  ///
  /// **What is exported is the buffer, not the file**: the preview renders the
  /// buffer, and the export is the preview's rendering. Kept alive because the
  /// menu that starts it is gone before the file is written; emptied when
  /// another document opens, which is the next thing happening.
  ExportNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exportProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exportNotifierHash();

  @$internal
  @override
  ExportNotifier create() => ExportNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExportState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExportState>(value),
    );
  }
}

String _$exportNotifierHash() => r'db41c5da052d61acd8fd813bb8e83b71bcf3b175';

/// The export the tab's menu asked for (`docs/product/export/doc.md`).
///
/// **What is exported is the buffer, not the file**: the preview renders the
/// buffer, and the export is the preview's rendering. Kept alive because the
/// menu that starts it is gone before the file is written; emptied when
/// another document opens, which is the next thing happening.

abstract class _$ExportNotifier extends $Notifier<ExportState> {
  ExportState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ExportState, ExportState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ExportState, ExportState>,
              ExportState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
