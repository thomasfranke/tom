// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'remote_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Fetch, pull and push, each started by somebody and never on its own.
///
/// **Nothing here runs in the background** — no timer, no retry, no sync
/// (`docs/product/git-workflow/push-pull/doc.md`). A button is pressed and
/// one thing happens.
///
/// It reads no git of its own: every action ends by asking [ChangesNotifier]
/// to re-read, so what the window believes about the repository has one
/// source and one way of becoming stale.

@ProviderFor(RemoteNotifier)
final remoteProvider = RemoteNotifierProvider._();

/// Fetch, pull and push, each started by somebody and never on its own.
///
/// **Nothing here runs in the background** — no timer, no retry, no sync
/// (`docs/product/git-workflow/push-pull/doc.md`). A button is pressed and
/// one thing happens.
///
/// It reads no git of its own: every action ends by asking [ChangesNotifier]
/// to re-read, so what the window believes about the repository has one
/// source and one way of becoming stale.
final class RemoteNotifierProvider
    extends $NotifierProvider<RemoteNotifier, RemoteState> {
  /// Fetch, pull and push, each started by somebody and never on its own.
  ///
  /// **Nothing here runs in the background** — no timer, no retry, no sync
  /// (`docs/product/git-workflow/push-pull/doc.md`). A button is pressed and
  /// one thing happens.
  ///
  /// It reads no git of its own: every action ends by asking [ChangesNotifier]
  /// to re-read, so what the window believes about the repository has one
  /// source and one way of becoming stale.
  RemoteNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'remoteProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$remoteNotifierHash();

  @$internal
  @override
  RemoteNotifier create() => RemoteNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RemoteState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RemoteState>(value),
    );
  }
}

String _$remoteNotifierHash() => r'56dbe29793cafce7437559d16438c945a50ae481';

/// Fetch, pull and push, each started by somebody and never on its own.
///
/// **Nothing here runs in the background** — no timer, no retry, no sync
/// (`docs/product/git-workflow/push-pull/doc.md`). A button is pressed and
/// one thing happens.
///
/// It reads no git of its own: every action ends by asking [ChangesNotifier]
/// to re-read, so what the window believes about the repository has one
/// source and one way of becoming stale.

abstract class _$RemoteNotifier extends $Notifier<RemoteState> {
  RemoteState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<RemoteState, RemoteState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<RemoteState, RemoteState>,
              RemoteState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
