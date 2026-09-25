// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'space_session_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The open space, or null while the window shows Home ([Decision
/// 9](../../../../../../docs/technical/decisions/009-space-session-is-single-source-of-truth.md)).
///
/// Kept alive on purpose: Riverpod disposes a provider as soon as nothing
/// listens, and this one is written by Home — the screen on its way out.

@ProviderFor(SpaceSessionNotifier)
final spaceSessionProvider = SpaceSessionNotifierProvider._();

/// The open space, or null while the window shows Home ([Decision
/// 9](../../../../../../docs/technical/decisions/009-space-session-is-single-source-of-truth.md)).
///
/// Kept alive on purpose: Riverpod disposes a provider as soon as nothing
/// listens, and this one is written by Home — the screen on its way out.
final class SpaceSessionNotifierProvider
    extends $NotifierProvider<SpaceSessionNotifier, SpaceSessionState?> {
  /// The open space, or null while the window shows Home ([Decision
  /// 9](../../../../../../docs/technical/decisions/009-space-session-is-single-source-of-truth.md)).
  ///
  /// Kept alive on purpose: Riverpod disposes a provider as soon as nothing
  /// listens, and this one is written by Home — the screen on its way out.
  SpaceSessionNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'spaceSessionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$spaceSessionNotifierHash();

  @$internal
  @override
  SpaceSessionNotifier create() => SpaceSessionNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SpaceSessionState? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SpaceSessionState?>(value),
    );
  }
}

String _$spaceSessionNotifierHash() =>
    r'672deeb74f54b51b753cd484fa2cac12bc7cb66d';

/// The open space, or null while the window shows Home ([Decision
/// 9](../../../../../../docs/technical/decisions/009-space-session-is-single-source-of-truth.md)).
///
/// Kept alive on purpose: Riverpod disposes a provider as soon as nothing
/// listens, and this one is written by Home — the screen on its way out.

abstract class _$SpaceSessionNotifier extends $Notifier<SpaceSessionState?> {
  SpaceSessionState? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SpaceSessionState?, SpaceSessionState?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SpaceSessionState?, SpaceSessionState?>,
              SpaceSessionState?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
