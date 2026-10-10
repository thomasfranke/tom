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

String _$remoteNotifierHash() => r'1a77cc7afda739aa993f5153dd52e9b8a05656ac';

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
