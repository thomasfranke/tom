// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Where unexpected errors go.
///
/// The no-op is the shipping default and stays that way until the user turns
/// something on: **no data leaves the machine** ([Decision
/// 11](../../../../../docs/technical/decisions/011-telemetry-is-opt-in.md)).
/// A module replaces this by overriding it.

@ProviderFor(observability)
final observabilityProvider = ObservabilityProvider._();

/// Where unexpected errors go.
///
/// The no-op is the shipping default and stays that way until the user turns
/// something on: **no data leaves the machine** ([Decision
/// 11](../../../../../docs/technical/decisions/011-telemetry-is-opt-in.md)).
/// A module replaces this by overriding it.

final class ObservabilityProvider
    extends $FunctionalProvider<Observability, Observability, Observability>
    with $Provider<Observability> {
  /// Where unexpected errors go.
  ///
  /// The no-op is the shipping default and stays that way until the user turns
  /// something on: **no data leaves the machine** ([Decision
  /// 11](../../../../../docs/technical/decisions/011-telemetry-is-opt-in.md)).
  /// A module replaces this by overriding it.
  ObservabilityProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'observabilityProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$observabilityHash();

  @$internal
  @override
  $ProviderElement<Observability> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Observability create(Ref ref) {
    return observability(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Observability value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Observability>(value),
    );
  }
}

String _$observabilityHash() => r'2c9c1d6bb22827babcfaa4acf8e57f54dec0216f';

/// Reading and writing files.

@ProviderFor(filesystem)
final filesystemProvider = FilesystemProvider._();

/// Reading and writing files.

final class FilesystemProvider
    extends $FunctionalProvider<Filesystem, Filesystem, Filesystem>
    with $Provider<Filesystem> {
  /// Reading and writing files.
  FilesystemProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filesystemProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filesystemHash();

  @$internal
  @override
  $ProviderElement<Filesystem> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Filesystem create(Ref ref) {
    return filesystem(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Filesystem value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Filesystem>(value),
    );
  }
}

String _$filesystemHash() => r'b17beefa8352fa34399a7350ca9bf0ec9cc87998';

/// How to get a git client for a folder.
///
/// App lifetime, but what it *builds* is per folder: a client holds the
/// directory its commands run in and the queue that serializes them
/// ([flows](../../../../../docs/technical/flows.md#wiring-three-lifetimes)).

@ProviderFor(gitClientFor)
final gitClientForProvider = GitClientForProvider._();

/// How to get a git client for a folder.
///
/// App lifetime, but what it *builds* is per folder: a client holds the
/// directory its commands run in and the queue that serializes them
/// ([flows](../../../../../docs/technical/flows.md#wiring-three-lifetimes)).

final class GitClientForProvider
    extends $FunctionalProvider<GitClientFor, GitClientFor, GitClientFor>
    with $Provider<GitClientFor> {
  /// How to get a git client for a folder.
  ///
  /// App lifetime, but what it *builds* is per folder: a client holds the
  /// directory its commands run in and the queue that serializes them
  /// ([flows](../../../../../docs/technical/flows.md#wiring-three-lifetimes)).
  GitClientForProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gitClientForProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gitClientForHash();

  @$internal
  @override
  $ProviderElement<GitClientFor> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GitClientFor create(Ref ref) {
    return gitClientFor(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GitClientFor value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GitClientFor>(value),
    );
  }
}

String _$gitClientForHash() => r'1902b90e84caf93d9cc9e6bc0e590ed2b288d0a3';

/// Per-machine preferences.
///
/// One JSON file in the platform's application-support folder. Not
/// `shared_preferences`: it is a Flutter plugin, and settings belong to
/// `tom_infra`, which is pure Dart.

@ProviderFor(settings)
final settingsProvider = SettingsProvider._();

/// Per-machine preferences.
///
/// One JSON file in the platform's application-support folder. Not
/// `shared_preferences`: it is a Flutter plugin, and settings belong to
/// `tom_infra`, which is pure Dart.

final class SettingsProvider
    extends $FunctionalProvider<Settings, Settings, Settings>
    with $Provider<Settings> {
  /// Per-machine preferences.
  ///
  /// One JSON file in the platform's application-support folder. Not
  /// `shared_preferences`: it is a Flutter plugin, and settings belong to
  /// `tom_infra`, which is pure Dart.
  SettingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsHash();

  @$internal
  @override
  $ProviderElement<Settings> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Settings create(Ref ref) {
    return settings(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Settings value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Settings>(value),
    );
  }
}

String _$settingsHash() => r'0961b52a01f6bd1df9396a89f32e0e78a69c5ed3';

/// The folders spaces are made of.

@ProviderFor(spaceRepository)
final spaceRepositoryProvider = SpaceRepositoryProvider._();

/// The folders spaces are made of.

final class SpaceRepositoryProvider
    extends
        $FunctionalProvider<SpaceRepository, SpaceRepository, SpaceRepository>
    with $Provider<SpaceRepository> {
  /// The folders spaces are made of.
  SpaceRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'spaceRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$spaceRepositoryHash();

  @$internal
  @override
  $ProviderElement<SpaceRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SpaceRepository create(Ref ref) {
    return spaceRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SpaceRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SpaceRepository>(value),
    );
  }
}

String _$spaceRepositoryHash() => r'56cc8770fc0d1676f0a618fa7d1a63dc2c8404d3';

/// The spaces Home offers to go back to.

@ProviderFor(recentSpacesRepository)
final recentSpacesRepositoryProvider = RecentSpacesRepositoryProvider._();

/// The spaces Home offers to go back to.

final class RecentSpacesRepositoryProvider
    extends
        $FunctionalProvider<
          RecentSpacesRepository,
          RecentSpacesRepository,
          RecentSpacesRepository
        >
    with $Provider<RecentSpacesRepository> {
  /// The spaces Home offers to go back to.
  RecentSpacesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recentSpacesRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recentSpacesRepositoryHash();

  @$internal
  @override
  $ProviderElement<RecentSpacesRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RecentSpacesRepository create(Ref ref) {
    return recentSpacesRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RecentSpacesRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RecentSpacesRepository>(value),
    );
  }
}

String _$recentSpacesRepositoryHash() =>
    r'5455b229f81cffe1c7a5b446c0765016f2d315b8';

/// How to reach the documents of a space.
///
/// A repository is per space — every path on it is relative to that space's
/// root — and the space is picked at runtime, so what is app-wide is the way
/// to build one.

@ProviderFor(documentRepositoryFor)
final documentRepositoryForProvider = DocumentRepositoryForProvider._();

/// How to reach the documents of a space.
///
/// A repository is per space — every path on it is relative to that space's
/// root — and the space is picked at runtime, so what is app-wide is the way
/// to build one.

final class DocumentRepositoryForProvider
    extends
        $FunctionalProvider<
          DocumentRepositoryFor,
          DocumentRepositoryFor,
          DocumentRepositoryFor
        >
    with $Provider<DocumentRepositoryFor> {
  /// How to reach the documents of a space.
  ///
  /// A repository is per space — every path on it is relative to that space's
  /// root — and the space is picked at runtime, so what is app-wide is the way
  /// to build one.
  DocumentRepositoryForProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'documentRepositoryForProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$documentRepositoryForHash();

  @$internal
  @override
  $ProviderElement<DocumentRepositoryFor> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DocumentRepositoryFor create(Ref ref) {
    return documentRepositoryFor(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DocumentRepositoryFor value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DocumentRepositoryFor>(value),
    );
  }
}

String _$documentRepositoryForHash() =>
    r'069535e8faa8f8efddba2e7a8f657fd313c4998d';

/// What splits a document into blocks.

@ProviderFor(blockReader)
final blockReaderProvider = BlockReaderProvider._();

/// What splits a document into blocks.

final class BlockReaderProvider
    extends $FunctionalProvider<BlockReader, BlockReader, BlockReader>
    with $Provider<BlockReader> {
  /// What splits a document into blocks.
  BlockReaderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'blockReaderProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$blockReaderHash();

  @$internal
  @override
  $ProviderElement<BlockReader> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BlockReader create(Ref ref) {
    return blockReader(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BlockReader value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BlockReader>(value),
    );
  }
}

String _$blockReaderHash() => r'5ac3b474afb0811b712b918bcde79e213d3a0c26';
