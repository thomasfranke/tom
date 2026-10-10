// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pull_request_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Reads where a pull request would go.

@ProviderFor(readPullRequestTarget)
final readPullRequestTargetProvider = ReadPullRequestTargetProvider._();

/// Reads where a pull request would go.

final class ReadPullRequestTargetProvider
    extends
        $FunctionalProvider<
          ReadPullRequestTargetUseCase,
          ReadPullRequestTargetUseCase,
          ReadPullRequestTargetUseCase
        >
    with $Provider<ReadPullRequestTargetUseCase> {
  /// Reads where a pull request would go.
  ReadPullRequestTargetProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'readPullRequestTargetProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$readPullRequestTargetHash();

  @$internal
  @override
  $ProviderElement<ReadPullRequestTargetUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ReadPullRequestTargetUseCase create(Ref ref) {
    return readPullRequestTarget(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReadPullRequestTargetUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReadPullRequestTargetUseCase>(value),
    );
  }
}

String _$readPullRequestTargetHash() =>
    r'40f3a1aeacf86ff407d8d5dac3ad06b77ff17fa2';

/// Reads what the branch proposes onto a base.

@ProviderFor(readBranchProposal)
final readBranchProposalProvider = ReadBranchProposalProvider._();

/// Reads what the branch proposes onto a base.

final class ReadBranchProposalProvider
    extends
        $FunctionalProvider<
          ReadBranchProposalUseCase,
          ReadBranchProposalUseCase,
          ReadBranchProposalUseCase
        >
    with $Provider<ReadBranchProposalUseCase> {
  /// Reads what the branch proposes onto a base.
  ReadBranchProposalProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'readBranchProposalProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$readBranchProposalHash();

  @$internal
  @override
  $ProviderElement<ReadBranchProposalUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ReadBranchProposalUseCase create(Ref ref) {
    return readBranchProposal(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReadBranchProposalUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReadBranchProposalUseCase>(value),
    );
  }
}

String _$readBranchProposalHash() =>
    r'569ee6962c5ee4634684581d0a9fe5c3d9338dee';

/// Reads what the branch did, in numbers.

@ProviderFor(readBranchOverview)
final readBranchOverviewProvider = ReadBranchOverviewProvider._();

/// Reads what the branch did, in numbers.

final class ReadBranchOverviewProvider
    extends
        $FunctionalProvider<
          ReadBranchOverviewUseCase,
          ReadBranchOverviewUseCase,
          ReadBranchOverviewUseCase
        >
    with $Provider<ReadBranchOverviewUseCase> {
  /// Reads what the branch did, in numbers.
  ReadBranchOverviewProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'readBranchOverviewProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$readBranchOverviewHash();

  @$internal
  @override
  $ProviderElement<ReadBranchOverviewUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ReadBranchOverviewUseCase create(Ref ref) {
    return readBranchOverview(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReadBranchOverviewUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReadBranchOverviewUseCase>(value),
    );
  }
}

String _$readBranchOverviewHash() =>
    r'18e2c652aa9542d4ea083f02da26b79d1ab97223';

/// Asks the host whether the branch already has a pull request.

@ProviderFor(readOpenPullRequest)
final readOpenPullRequestProvider = ReadOpenPullRequestProvider._();

/// Asks the host whether the branch already has a pull request.

final class ReadOpenPullRequestProvider
    extends
        $FunctionalProvider<
          ReadOpenPullRequestUseCase,
          ReadOpenPullRequestUseCase,
          ReadOpenPullRequestUseCase
        >
    with $Provider<ReadOpenPullRequestUseCase> {
  /// Asks the host whether the branch already has a pull request.
  ReadOpenPullRequestProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'readOpenPullRequestProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$readOpenPullRequestHash();

  @$internal
  @override
  $ProviderElement<ReadOpenPullRequestUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ReadOpenPullRequestUseCase create(Ref ref) {
    return readOpenPullRequest(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReadOpenPullRequestUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReadOpenPullRequestUseCase>(value),
    );
  }
}

String _$readOpenPullRequestHash() =>
    r'27915e761e2e44c6d564c536c6c0f5c6ebe77422';

/// Opens the pull request through `gh`.

@ProviderFor(createPullRequest)
final createPullRequestProvider = CreatePullRequestProvider._();

/// Opens the pull request through `gh`.

final class CreatePullRequestProvider
    extends
        $FunctionalProvider<
          CreatePullRequestUseCase,
          CreatePullRequestUseCase,
          CreatePullRequestUseCase
        >
    with $Provider<CreatePullRequestUseCase> {
  /// Opens the pull request through `gh`.
  CreatePullRequestProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createPullRequestProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createPullRequestHash();

  @$internal
  @override
  $ProviderElement<CreatePullRequestUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CreatePullRequestUseCase create(Ref ref) {
    return createPullRequest(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreatePullRequestUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreatePullRequestUseCase>(value),
    );
  }
}

String _$createPullRequestHash() => r'2955e59dc554ea1b223450c12392b67be3510107';

/// Opens the host's compare page in the browser.

@ProviderFor(openUrl)
final openUrlProvider = OpenUrlProvider._();

/// Opens the host's compare page in the browser.

final class OpenUrlProvider
    extends $FunctionalProvider<OpenUrlUseCase, OpenUrlUseCase, OpenUrlUseCase>
    with $Provider<OpenUrlUseCase> {
  /// Opens the host's compare page in the browser.
  OpenUrlProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'openUrlProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$openUrlHash();

  @$internal
  @override
  $ProviderElement<OpenUrlUseCase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  OpenUrlUseCase create(Ref ref) {
    return openUrl(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OpenUrlUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OpenUrlUseCase>(value),
    );
  }
}

String _$openUrlHash() => r'e5608ab4fd98c95d9f884b41ca3b00a6e28aa845';
