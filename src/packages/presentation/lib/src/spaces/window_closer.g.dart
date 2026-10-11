// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'window_closer.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// What closes the window once leaving was answered for.
///
/// A seam with no default because the window is a plugin's, and a plugin
/// lives in the application: this package decides *when* the window may go,
/// never how (`docs/product/editor/tabs/doc.md`).

@ProviderFor(windowCloser)
final windowCloserProvider = WindowCloserProvider._();

/// What closes the window once leaving was answered for.
///
/// A seam with no default because the window is a plugin's, and a plugin
/// lives in the application: this package decides *when* the window may go,
/// never how (`docs/product/editor/tabs/doc.md`).

final class WindowCloserProvider
    extends $FunctionalProvider<WindowCloser, WindowCloser, WindowCloser>
    with $Provider<WindowCloser> {
  /// What closes the window once leaving was answered for.
  ///
  /// A seam with no default because the window is a plugin's, and a plugin
  /// lives in the application: this package decides *when* the window may go,
  /// never how (`docs/product/editor/tabs/doc.md`).
  WindowCloserProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'windowCloserProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$windowCloserHash();

  @$internal
  @override
  $ProviderElement<WindowCloser> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  WindowCloser create(Ref ref) {
    return windowCloser(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WindowCloser value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WindowCloser>(value),
    );
  }
}

String _$windowCloserHash() => r'3ac2628062780d7adf1dbfbe1bdc879edb7b3e45';
