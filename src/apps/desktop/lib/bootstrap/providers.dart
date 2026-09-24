/// The object graph, wired.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_infra/tom_infra.dart';
import 'package:tom_presentation/tom_presentation.dart';

part 'providers.g.dart';

/// Where unexpected errors go.
///
/// The no-op is the shipping default and stays that way until the user turns
/// something on: **no data leaves the machine** ([Decision
/// 11](../../../../../docs/technical/decisions/011-telemetry-is-opt-in.md)).
/// A module replaces this by overriding it.
@Riverpod(keepAlive: true)
Observability observability(Ref ref) => const _SilentObservabilityImpl();

/// Reading and writing files.
@Riverpod(keepAlive: true)
Filesystem filesystem(Ref ref) => const DartIoFilesystemImpl();

/// How to get a git client for a folder.
///
/// App lifetime, but what it *builds* is per folder: a client holds the
/// directory its commands run in and the queue that serializes them
/// ([flows](../../../../../docs/technical/flows.md#wiring-three-lifetimes)).
@Riverpod(keepAlive: true)
GitClientFor gitClientFor(Ref ref) =>
    (String folder) => DartIoGitClientImpl(workingDirectory: folder);

/// What this platform calls its folders.
@Riverpod(keepAlive: true)
PlatformPaths platformPaths(Ref ref) => const DartIoPlatformPathsImpl();

/// Per-machine preferences.
///
/// One JSON file in the folder this platform keeps app data in. Not
/// `shared_preferences`: it is a Flutter plugin, and settings belong to
/// `tom_infra`, which is pure Dart.
/// The throw is deliberate and belongs here rather than in `tom_infra`: a
/// machine that names no folder for an app's files is one TOM cannot run on
/// at all, and deciding that is the composition root's call, not a
/// capability's.
@Riverpod(keepAlive: true)
Settings settings(Ref ref) =>
    switch (ref.watch(platformPathsProvider).applicationData()) {
      Success<String, PlatformPathsFailure>(value: final String folder) =>
        JsonFileSettingsImpl(
          filesystem: ref.watch(filesystemProvider),
          path: '$folder/preferences.json',
        ),
      Failure<String, PlatformPathsFailure>(
        failure: final PlatformPathsFailure failure,
      ) =>
        throw StateError('TOM cannot start on this machine: $failure'),
    };

/// The folders spaces are made of.
@Riverpod(keepAlive: true)
SpaceRepository spaceRepository(Ref ref) => SpaceRepositoryImpl(
  spaces: SpaceDataSource(
    filesystem: ref.watch(filesystemProvider),
    gitClientFor: ref.watch(gitClientForProvider),
  ),
);

/// The spaces Home offers to go back to.
@Riverpod(keepAlive: true)
RecentSpacesRepository recentSpacesRepository(Ref ref) =>
    RecentSpacesRepositoryImpl(
      recents: RecentSpacesDataSource(settings: ref.watch(settingsProvider)),
      observability: ref.watch(observabilityProvider),
    );

/// How to reach the documents of a space.
///
/// A repository is per space — every path on it is relative to that space's
/// root — and the space is picked at runtime, so what is app-wide is the way
/// to build one.
@Riverpod(keepAlive: true)
DocumentRepositoryFor documentRepositoryFor(Ref ref) {
  final DocumentDataSource documents = DocumentDataSource(
    filesystem: ref.watch(filesystemProvider),
  );
  return (SpaceEntity space) =>
      DocumentRepositoryImpl(documents: documents, space: space);
}

/// How to reach git for a space.
///
/// Per space, for the same reason a document repository is: the client runs
/// in one folder and serializes that folder's commands, so what is app-wide
/// is the way to build one.
@Riverpod(keepAlive: true)
GitRepositoryFor gitRepositoryFor(Ref ref) {
  final GitClientFor clients = ref.watch(gitClientForProvider);
  return (SpaceEntity space) => GitRepositoryImpl(
    git: GitDataSource(client: clients(space.repositoryRoot)),
  );
}

/// What splits a document into blocks.
@Riverpod(keepAlive: true)
BlockReaderPort blockReader(Ref ref) => const MarkdownBlockReaderImpl(
  markdown: MarkdownDataSource(parser: MarkdownPackageParserImpl()),
);

/// The overrides that turn the contracts above into the app's own wiring.
///
/// `tom_presentation` declares the use cases it needs and nothing else: it
/// does not depend on `tom_data` or `tom_infra`, so it cannot know which
/// repository, which git client or which disk ends up behind them. **This is
/// the one place that does.**
List<Override> appOverrides = <Override>[
  openSpaceProvider.overrideWith(
    (Ref ref) => OpenSpaceUseCase(
      spaces: ref.watch(spaceRepositoryProvider),
      recents: ref.watch(recentSpacesRepositoryProvider),
      observability: ref.watch(observabilityProvider),
    ),
  ),
  listRecentSpacesProvider.overrideWith(
    (Ref ref) => ListRecentSpacesUseCase(
      recents: ref.watch(recentSpacesRepositoryProvider),
      observability: ref.watch(observabilityProvider),
    ),
  ),
  forgetRecentSpaceProvider.overrideWith(
    (Ref ref) => ForgetRecentSpaceUseCase(
      recents: ref.watch(recentSpacesRepositoryProvider),
      observability: ref.watch(observabilityProvider),
    ),
  ),
  listSpaceEntriesProvider.overrideWith(
    (Ref ref) => ListSpaceEntriesUseCase(
      spaces: ref.watch(spaceRepositoryProvider),
      observability: ref.watch(observabilityProvider),
    ),
  ),
  readDocumentProvider.overrideWith(
    (Ref ref) => ReadDocumentUseCase(
      documentsFor: ref.watch(documentRepositoryForProvider),
      observability: ref.watch(observabilityProvider),
    ),
  ),
  saveDocumentProvider.overrideWith(
    (Ref ref) => SaveDocumentUseCase(
      documentsFor: ref.watch(documentRepositoryForProvider),
      observability: ref.watch(observabilityProvider),
    ),
  ),
  splitDocumentProvider.overrideWith(
    (Ref ref) => SplitDocumentUseCase(
      blocks: ref.watch(blockReaderProvider),
      observability: ref.watch(observabilityProvider),
    ),
  ),
  readGitStatusProvider.overrideWith(
    (Ref ref) => ReadGitStatusUseCase(
      gitFor: ref.watch(gitRepositoryForProvider),
      observability: ref.watch(observabilityProvider),
    ),
  ),
  stageChangesProvider.overrideWith(
    (Ref ref) => StageChangesUseCase(
      gitFor: ref.watch(gitRepositoryForProvider),
      observability: ref.watch(observabilityProvider),
    ),
  ),
  commitChangesProvider.overrideWith(
    (Ref ref) => CommitChangesUseCase(
      gitFor: ref.watch(gitRepositoryForProvider),
      observability: ref.watch(observabilityProvider),
    ),
  ),
  fetchRemoteProvider.overrideWith(
    (Ref ref) => FetchRemoteUseCase(
      gitFor: ref.watch(gitRepositoryForProvider),
      observability: ref.watch(observabilityProvider),
    ),
  ),
  pullRemoteProvider.overrideWith(
    (Ref ref) => PullRemoteUseCase(
      gitFor: ref.watch(gitRepositoryForProvider),
      observability: ref.watch(observabilityProvider),
    ),
  ),
  pushRemoteProvider.overrideWith(
    (Ref ref) => PushRemoteUseCase(
      gitFor: ref.watch(gitRepositoryForProvider),
      observability: ref.watch(observabilityProvider),
    ),
  ),
  listBranchesProvider.overrideWith(
    (Ref ref) => ListBranchesUseCase(
      gitFor: ref.watch(gitRepositoryForProvider),
      observability: ref.watch(observabilityProvider),
    ),
  ),
  switchBranchProvider.overrideWith(
    (Ref ref) => SwitchBranchUseCase(
      gitFor: ref.watch(gitRepositoryForProvider),
      observability: ref.watch(observabilityProvider),
    ),
  ),
  readFileHistoryProvider.overrideWith(
    (Ref ref) => ReadFileHistoryUseCase(
      gitFor: ref.watch(gitRepositoryForProvider),
      observability: ref.watch(observabilityProvider),
    ),
  ),
  readVersionProvider.overrideWith(
    (Ref ref) => ReadVersionUseCase(
      gitFor: ref.watch(gitRepositoryForProvider),
      observability: ref.watch(observabilityProvider),
    ),
  ),
];

/// Discards everything, which is the point.
///
/// The default implementation of a port that exists so telemetry *can* be
/// added without every use case learning about it.
final class _SilentObservabilityImpl implements Observability {
  const _SilentObservabilityImpl();

  @override
  Future<void> capture(
    Object error,
    StackTrace stackTrace, {
    required String layer,
  }) async {}
}
