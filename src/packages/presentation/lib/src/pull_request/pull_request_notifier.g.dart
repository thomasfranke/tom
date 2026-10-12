// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pull_request_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The page's readings, beside the session's two positions — which branch,
/// onto which base ([Decision
/// 33](../../../../../../docs/technical/decisions/033-a-pull-request-draft-is-a-document-outside-the-space.md)).
///
/// Kept alive because the control lives in the tree and the page in the
/// document area, and the explorer can be shut while the page is up.

@ProviderFor(PullRequestNotifier)
final pullRequestProvider = PullRequestNotifierProvider._();

/// The page's readings, beside the session's two positions — which branch,
/// onto which base ([Decision
/// 33](../../../../../../docs/technical/decisions/033-a-pull-request-draft-is-a-document-outside-the-space.md)).
///
/// Kept alive because the control lives in the tree and the page in the
/// document area, and the explorer can be shut while the page is up.
final class PullRequestNotifierProvider
    extends $NotifierProvider<PullRequestNotifier, PullRequestState> {
  /// The page's readings, beside the session's two positions — which branch,
  /// onto which base ([Decision
  /// 33](../../../../../../docs/technical/decisions/033-a-pull-request-draft-is-a-document-outside-the-space.md)).
  ///
  /// Kept alive because the control lives in the tree and the page in the
  /// document area, and the explorer can be shut while the page is up.
  PullRequestNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pullRequestProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pullRequestNotifierHash();

  @$internal
  @override
  PullRequestNotifier create() => PullRequestNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PullRequestState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PullRequestState>(value),
    );
  }
}

String _$pullRequestNotifierHash() =>
    r'61917a6d6926ec43edd0c5340d29ada2decb73bd';

/// The page's readings, beside the session's two positions — which branch,
/// onto which base ([Decision
/// 33](../../../../../../docs/technical/decisions/033-a-pull-request-draft-is-a-document-outside-the-space.md)).
///
/// Kept alive because the control lives in the tree and the page in the
/// document area, and the explorer can be shut while the page is up.

abstract class _$PullRequestNotifier extends $Notifier<PullRequestState> {
  PullRequestState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<PullRequestState, PullRequestState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PullRequestState, PullRequestState>,
              PullRequestState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// What the status row says, from git, the proposal and the draft's title.

@ProviderFor(pullRequestStatus)
final pullRequestStatusProvider = PullRequestStatusProvider._();

/// What the status row says, from git, the proposal and the draft's title.

final class PullRequestStatusProvider
    extends
        $FunctionalProvider<
          PullRequestStatus,
          PullRequestStatus,
          PullRequestStatus
        >
    with $Provider<PullRequestStatus> {
  /// What the status row says, from git, the proposal and the draft's title.
  PullRequestStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pullRequestStatusProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pullRequestStatusHash();

  @$internal
  @override
  $ProviderElement<PullRequestStatus> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PullRequestStatus create(Ref ref) {
    return pullRequestStatus(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PullRequestStatus value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PullRequestStatus>(value),
    );
  }
}

String _$pullRequestStatusHash() => r'428e9028aaeb7bb8bc6ca83156e13dcee1709d18';
