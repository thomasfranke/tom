// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'remote_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Fetch, pull and push, each started by somebody and never on its own
/// (`docs/product/git-workflow/push-pull/README.md`).
///
/// It reads no git of its own: every action ends in [GitReadingNotifier]
/// re-reading, so what the window believes about the repository has one
/// source.

@ProviderFor(RemoteNotifier)
final remoteProvider = RemoteNotifierProvider._();

/// Fetch, pull and push, each started by somebody and never on its own
/// (`docs/product/git-workflow/push-pull/README.md`).
///
/// It reads no git of its own: every action ends in [GitReadingNotifier]
/// re-reading, so what the window believes about the repository has one
/// source.
final class RemoteNotifierProvider
    extends $NotifierProvider<RemoteNotifier, RemoteState> {
  /// Fetch, pull and push, each started by somebody and never on its own
  /// (`docs/product/git-workflow/push-pull/README.md`).
  ///
  /// It reads no git of its own: every action ends in [GitReadingNotifier]
  /// re-reading, so what the window believes about the repository has one
  /// source.
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

String _$remoteNotifierHash() => r'ee5f5e8b4158dc300f5aba15d80fe85b029f3f81';

/// Fetch, pull and push, each started by somebody and never on its own
/// (`docs/product/git-workflow/push-pull/README.md`).
///
/// It reads no git of its own: every action ends in [GitReadingNotifier]
/// re-reading, so what the window believes about the repository has one
/// source.

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

/// Whether the remote action in flight is still waiting for somebody to say
/// yes: the control that was pressed says so, and the progress bar stays
/// down — nothing is on the network yet
/// (`docs/product/git-workflow/approvals/doc.md`).

@ProviderFor(remoteAwaitingApproval)
final remoteAwaitingApprovalProvider = RemoteAwaitingApprovalProvider._();

/// Whether the remote action in flight is still waiting for somebody to say
/// yes: the control that was pressed says so, and the progress bar stays
/// down — nothing is on the network yet
/// (`docs/product/git-workflow/approvals/doc.md`).

final class RemoteAwaitingApprovalProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether the remote action in flight is still waiting for somebody to say
  /// yes: the control that was pressed says so, and the progress bar stays
  /// down — nothing is on the network yet
  /// (`docs/product/git-workflow/approvals/doc.md`).
  RemoteAwaitingApprovalProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'remoteAwaitingApprovalProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$remoteAwaitingApprovalHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return remoteAwaitingApproval(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$remoteAwaitingApprovalHash() =>
    r'8e21141751adfdeb2f1abc2ad79f40e99940755b';

/// What the link is, when it is anything: what the last request said, else
/// that the repository has no remote — read from the pull request's target
/// when the space opened, so nobody has to fail a fetch to learn it
/// (`docs/product/git-workflow/push-pull/when-the-link-is-broken/doc.md`).

@ProviderFor(remoteLink)
final remoteLinkProvider = RemoteLinkProvider._();

/// What the link is, when it is anything: what the last request said, else
/// that the repository has no remote — read from the pull request's target
/// when the space opened, so nobody has to fail a fetch to learn it
/// (`docs/product/git-workflow/push-pull/when-the-link-is-broken/doc.md`).

final class RemoteLinkProvider
    extends $FunctionalProvider<LinkStateEnum?, LinkStateEnum?, LinkStateEnum?>
    with $Provider<LinkStateEnum?> {
  /// What the link is, when it is anything: what the last request said, else
  /// that the repository has no remote — read from the pull request's target
  /// when the space opened, so nobody has to fail a fetch to learn it
  /// (`docs/product/git-workflow/push-pull/when-the-link-is-broken/doc.md`).
  RemoteLinkProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'remoteLinkProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$remoteLinkHash();

  @$internal
  @override
  $ProviderElement<LinkStateEnum?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LinkStateEnum? create(Ref ref) {
    return remoteLink(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LinkStateEnum? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LinkStateEnum?>(value),
    );
  }
}

String _$remoteLinkHash() => r'bdcdc0c71d2e67fd869d70e1fc0d7c81c2141ab6';
