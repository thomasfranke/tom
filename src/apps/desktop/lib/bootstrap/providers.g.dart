// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Where unexpected errors go: a no-op until a module overrides it
/// ([Decision 11](../../../../../docs/technical/decisions/011-telemetry-is-opt-in.md)).

@ProviderFor(observability)
final observabilityProvider = ObservabilityProvider._();

/// Where unexpected errors go: a no-op until a module overrides it
/// ([Decision 11](../../../../../docs/technical/decisions/011-telemetry-is-opt-in.md)).

final class ObservabilityProvider
    extends $FunctionalProvider<Observability, Observability, Observability>
    with $Provider<Observability> {
  /// Where unexpected errors go: a no-op until a module overrides it
  /// ([Decision 11](../../../../../docs/technical/decisions/011-telemetry-is-opt-in.md)).
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

String _$observabilityHash() => r'e73188f30469fceda69cec07b25f099649d1118b';

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

String _$filesystemHash() => r'1a4248bf6a67aa5d464587e1e0c9e525093b0be0';

/// How to get a git client for a folder.
///
/// App lifetime, but what it builds is per folder: a client holds the
/// directory its commands run in and the queue that serializes them
/// ([composition](../../../../../docs/technical/runtime/composition.md)).

@ProviderFor(gitClientFor)
final gitClientForProvider = GitClientForProvider._();

/// How to get a git client for a folder.
///
/// App lifetime, but what it builds is per folder: a client holds the
/// directory its commands run in and the queue that serializes them
/// ([composition](../../../../../docs/technical/runtime/composition.md)).

final class GitClientForProvider
    extends $FunctionalProvider<GitClientFor, GitClientFor, GitClientFor>
    with $Provider<GitClientFor> {
  /// How to get a git client for a folder.
  ///
  /// App lifetime, but what it builds is per folder: a client holds the
  /// directory its commands run in and the queue that serializes them
  /// ([composition](../../../../../docs/technical/runtime/composition.md)).
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

String _$gitClientForHash() => r'169285c18d1b9ce0f46a03cbcbe745921a9ff0dc';

/// What this platform calls its folders.

@ProviderFor(platformPaths)
final platformPathsProvider = PlatformPathsProvider._();

/// What this platform calls its folders.

final class PlatformPathsProvider
    extends $FunctionalProvider<PlatformPaths, PlatformPaths, PlatformPaths>
    with $Provider<PlatformPaths> {
  /// What this platform calls its folders.
  PlatformPathsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'platformPathsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$platformPathsHash();

  @$internal
  @override
  $ProviderElement<PlatformPaths> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PlatformPaths create(Ref ref) {
    return platformPaths(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlatformPaths value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlatformPaths>(value),
    );
  }
}

String _$platformPathsHash() => r'e68b7ff10e441ba5eb21d528dbcb654f27baef16';

/// Per-machine preferences, one JSON file in the platform's app-data folder.
///
/// The throw is deliberate and belongs here: a machine that names no folder
/// for an app's files is one TOM cannot run on, and deciding that is the
/// composition root's call, not a capability's.

@ProviderFor(settings)
final settingsProvider = SettingsProvider._();

/// Per-machine preferences, one JSON file in the platform's app-data folder.
///
/// The throw is deliberate and belongs here: a machine that names no folder
/// for an app's files is one TOM cannot run on, and deciding that is the
/// composition root's call, not a capability's.

final class SettingsProvider
    extends $FunctionalProvider<Settings, Settings, Settings>
    with $Provider<Settings> {
  /// Per-machine preferences, one JSON file in the platform's app-data folder.
  ///
  /// The throw is deliberate and belongs here: a machine that names no folder
  /// for an app's files is one TOM cannot run on, and deciding that is the
  /// composition root's call, not a capability's.
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

String _$settingsHash() => r'85eb0764b984379c92bc857bd2dd7af347aef6a0';

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

String _$spaceRepositoryHash() => r'6fd24995c6baf79245228f8b7c1bd58f7d20393c';

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
    r'5661f76eeb1090b4ec05139ce031b53221146bbf';

/// How to reach the documents of a space.
///
/// A repository is per space and the space is picked at runtime, so what is
/// app-wide is the way to build one.

@ProviderFor(documentRepositoryFor)
final documentRepositoryForProvider = DocumentRepositoryForProvider._();

/// How to reach the documents of a space.
///
/// A repository is per space and the space is picked at runtime, so what is
/// app-wide is the way to build one.

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
  /// A repository is per space and the space is picked at runtime, so what is
  /// app-wide is the way to build one.
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
    r'd5aa73313822ce4ebff02349ab0d660c2d006bf8';

/// How to reach git for a space; per space for the same reason
/// [documentRepositoryFor] is.

@ProviderFor(gitRepositoryFor)
final gitRepositoryForProvider = GitRepositoryForProvider._();

/// How to reach git for a space; per space for the same reason
/// [documentRepositoryFor] is.

final class GitRepositoryForProvider
    extends
        $FunctionalProvider<
          GitRepositoryFor,
          GitRepositoryFor,
          GitRepositoryFor
        >
    with $Provider<GitRepositoryFor> {
  /// How to reach git for a space; per space for the same reason
  /// [documentRepositoryFor] is.
  GitRepositoryForProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gitRepositoryForProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gitRepositoryForHash();

  @$internal
  @override
  $ProviderElement<GitRepositoryFor> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GitRepositoryFor create(Ref ref) {
    return gitRepositoryFor(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GitRepositoryFor value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GitRepositoryFor>(value),
    );
  }
}

String _$gitRepositoryForHash() => r'a4c8b05b0e581fdfcfa426133a33480581a7fb1d';

/// How to reach the search index of a space.
///
/// One index per space and the same one every time, because an index holds
/// an open database and a fresh one would be empty — which is a search that
/// silently finds nothing. Closed with the app, since it is in memory
/// ([search](../../../../../docs/technical/runtime/search.md)).

@ProviderFor(searchRepositoryFor)
final searchRepositoryForProvider = SearchRepositoryForProvider._();

/// How to reach the search index of a space.
///
/// One index per space and the same one every time, because an index holds
/// an open database and a fresh one would be empty — which is a search that
/// silently finds nothing. Closed with the app, since it is in memory
/// ([search](../../../../../docs/technical/runtime/search.md)).

final class SearchRepositoryForProvider
    extends
        $FunctionalProvider<
          SearchRepositoryFor,
          SearchRepositoryFor,
          SearchRepositoryFor
        >
    with $Provider<SearchRepositoryFor> {
  /// How to reach the search index of a space.
  ///
  /// One index per space and the same one every time, because an index holds
  /// an open database and a fresh one would be empty — which is a search that
  /// silently finds nothing. Closed with the app, since it is in memory
  /// ([search](../../../../../docs/technical/runtime/search.md)).
  SearchRepositoryForProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchRepositoryForProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchRepositoryForHash();

  @$internal
  @override
  $ProviderElement<SearchRepositoryFor> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SearchRepositoryFor create(Ref ref) {
    return searchRepositoryFor(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SearchRepositoryFor value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SearchRepositoryFor>(value),
    );
  }
}

String _$searchRepositoryForHash() =>
    r'95c0a90021096ad1ab5a18ece4688e85ad18a853';

/// What splits a document into blocks.

@ProviderFor(blockReader)
final blockReaderProvider = BlockReaderProvider._();

/// What splits a document into blocks.

final class BlockReaderProvider
    extends
        $FunctionalProvider<BlockReaderPort, BlockReaderPort, BlockReaderPort>
    with $Provider<BlockReaderPort> {
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
  $ProviderElement<BlockReaderPort> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BlockReaderPort create(Ref ref) {
    return blockReader(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BlockReaderPort value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BlockReaderPort>(value),
    );
  }
}

String _$blockReaderHash() => r'cc3900403c3cedc679d2a596f456b0289f048cbc';

/// What tells two versions of a document apart, block by block.

@ProviderFor(blockDiffer)
final blockDifferProvider = BlockDifferProvider._();

/// What tells two versions of a document apart, block by block.

final class BlockDifferProvider
    extends
        $FunctionalProvider<
          BlockDifferService,
          BlockDifferService,
          BlockDifferService
        >
    with $Provider<BlockDifferService> {
  /// What tells two versions of a document apart, block by block.
  BlockDifferProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'blockDifferProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$blockDifferHash();

  @$internal
  @override
  $ProviderElement<BlockDifferService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BlockDifferService create(Ref ref) {
    return blockDiffer(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BlockDifferService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BlockDifferService>(value),
    );
  }
}

String _$blockDifferHash() => r'ac9901d4e6782f9392343d3247255351f91b8588';
