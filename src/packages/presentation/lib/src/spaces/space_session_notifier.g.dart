// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'space_session_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Holds the open space for as long as one is open.
///
/// **No business logic, and not even a use case.** Opening a folder is
/// `OpenSpace`'s job and has already happened when a [Space] arrives here;
/// this is where the answer is put so every panel reads the same one
/// ([Decision
/// 9](../../../../../../docs/technical/decisions/009-space-session-is-single-source-of-truth.md)).
///
/// Null is "no space open", which is what the window shows Home for. There
/// is no `close` because nothing closes a space yet, and a method nobody
/// calls is a claim nobody checks.
///
/// Kept alive deliberately: Riverpod disposes a provider as soon as nothing
/// listens, and this one is written by Home — the screen on its way out — so
/// a disposal between the write and the first panel would leave the window
/// on Home with nothing to say.

@ProviderFor(SpaceSession)
final spaceSessionProvider = SpaceSessionProvider._();

/// Holds the open space for as long as one is open.
///
/// **No business logic, and not even a use case.** Opening a folder is
/// `OpenSpace`'s job and has already happened when a [Space] arrives here;
/// this is where the answer is put so every panel reads the same one
/// ([Decision
/// 9](../../../../../../docs/technical/decisions/009-space-session-is-single-source-of-truth.md)).
///
/// Null is "no space open", which is what the window shows Home for. There
/// is no `close` because nothing closes a space yet, and a method nobody
/// calls is a claim nobody checks.
///
/// Kept alive deliberately: Riverpod disposes a provider as soon as nothing
/// listens, and this one is written by Home — the screen on its way out — so
/// a disposal between the write and the first panel would leave the window
/// on Home with nothing to say.
final class SpaceSessionProvider
    extends $NotifierProvider<SpaceSession, SpaceSessionState?> {
  /// Holds the open space for as long as one is open.
  ///
  /// **No business logic, and not even a use case.** Opening a folder is
  /// `OpenSpace`'s job and has already happened when a [Space] arrives here;
  /// this is where the answer is put so every panel reads the same one
  /// ([Decision
  /// 9](../../../../../../docs/technical/decisions/009-space-session-is-single-source-of-truth.md)).
  ///
  /// Null is "no space open", which is what the window shows Home for. There
  /// is no `close` because nothing closes a space yet, and a method nobody
  /// calls is a claim nobody checks.
  ///
  /// Kept alive deliberately: Riverpod disposes a provider as soon as nothing
  /// listens, and this one is written by Home — the screen on its way out — so
  /// a disposal between the write and the first panel would leave the window
  /// on Home with nothing to say.
  SpaceSessionProvider._()
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
  String debugGetCreateSourceHash() => _$spaceSessionHash();

  @$internal
  @override
  SpaceSession create() => SpaceSession();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SpaceSessionState? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SpaceSessionState?>(value),
    );
  }
}

String _$spaceSessionHash() => r'670cae04556cdcace414d3816c9ec90514e0c31b';

/// Holds the open space for as long as one is open.
///
/// **No business logic, and not even a use case.** Opening a folder is
/// `OpenSpace`'s job and has already happened when a [Space] arrives here;
/// this is where the answer is put so every panel reads the same one
/// ([Decision
/// 9](../../../../../../docs/technical/decisions/009-space-session-is-single-source-of-truth.md)).
///
/// Null is "no space open", which is what the window shows Home for. There
/// is no `close` because nothing closes a space yet, and a method nobody
/// calls is a claim nobody checks.
///
/// Kept alive deliberately: Riverpod disposes a provider as soon as nothing
/// listens, and this one is written by Home — the screen on its way out — so
/// a disposal between the write and the first panel would leave the window
/// on Home with nothing to say.

abstract class _$SpaceSession extends $Notifier<SpaceSessionState?> {
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
