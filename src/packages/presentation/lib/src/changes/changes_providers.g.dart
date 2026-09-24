// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'changes_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Reads where the repository stands.
///
/// Declared here and **overridden by the composition root**: this package
/// names the use case it needs and cannot see that a process is what answers
/// it.

@ProviderFor(readGitStatus)
final readGitStatusProvider = ReadGitStatusProvider._();

/// Reads where the repository stands.
///
/// Declared here and **overridden by the composition root**: this package
/// names the use case it needs and cannot see that a process is what answers
/// it.

final class ReadGitStatusProvider
    extends
        $FunctionalProvider<
          ReadGitStatusUseCase,
          ReadGitStatusUseCase,
          ReadGitStatusUseCase
        >
    with $Provider<ReadGitStatusUseCase> {
  /// Reads where the repository stands.
  ///
  /// Declared here and **overridden by the composition root**: this package
  /// names the use case it needs and cannot see that a process is what answers
  /// it.
  ReadGitStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'readGitStatusProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$readGitStatusHash();

  @$internal
  @override
  $ProviderElement<ReadGitStatusUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ReadGitStatusUseCase create(Ref ref) {
    return readGitStatus(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReadGitStatusUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReadGitStatusUseCase>(value),
    );
  }
}

String _$readGitStatusHash() => r'74cec93695a29c7ce781313590f61097b1d73c29';

/// Moves whole files in and out of the index.

@ProviderFor(stageChanges)
final stageChangesProvider = StageChangesProvider._();

/// Moves whole files in and out of the index.

final class StageChangesProvider
    extends
        $FunctionalProvider<
          StageChangesUseCase,
          StageChangesUseCase,
          StageChangesUseCase
        >
    with $Provider<StageChangesUseCase> {
  /// Moves whole files in and out of the index.
  StageChangesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'stageChangesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$stageChangesHash();

  @$internal
  @override
  $ProviderElement<StageChangesUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  StageChangesUseCase create(Ref ref) {
    return stageChanges(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StageChangesUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StageChangesUseCase>(value),
    );
  }
}

String _$stageChangesHash() => r'59ba92da150e057a3bbe216cfaca2796d2071377';

/// Records the index as a commit.

@ProviderFor(commitChanges)
final commitChangesProvider = CommitChangesProvider._();

/// Records the index as a commit.

final class CommitChangesProvider
    extends
        $FunctionalProvider<
          CommitChangesUseCase,
          CommitChangesUseCase,
          CommitChangesUseCase
        >
    with $Provider<CommitChangesUseCase> {
  /// Records the index as a commit.
  CommitChangesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'commitChangesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$commitChangesHash();

  @$internal
  @override
  $ProviderElement<CommitChangesUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CommitChangesUseCase create(Ref ref) {
    return commitChanges(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CommitChangesUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CommitChangesUseCase>(value),
    );
  }
}

String _$commitChangesHash() => r'cd422c8e224175f2390d4198fbc40be95fbd1ca8';
