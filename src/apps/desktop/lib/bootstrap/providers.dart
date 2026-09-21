/// The object graph, wired.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_infra/tom_infra.dart';
import 'package:tom_presentation/tom_presentation.dart';

/// Where unexpected errors go.
///
/// The no-op is the shipping default and stays that way until the user turns
/// something on: **no data leaves the machine** ([Decision
/// 11](../../../../../docs/technical/decisions/011-telemetry-is-opt-in.md)).
/// A module replaces this by overriding it, which is what module overrides
/// are for.
final Provider<Observability> observabilityProvider = Provider<Observability>(
  (Ref ref) => const _SilentObservability(),
);

/// Reading and writing files.
final Provider<Filesystem> filesystemProvider = Provider<Filesystem>(
  (Ref ref) => const DartIoFilesystem(),
);

/// How to get a git client for a folder.
///
/// App lifetime, but what it *builds* is per folder: a client holds the
/// directory its commands run in and the queue that serializes them
/// ([flows](../../../../../docs/technical/flows.md#wiring-three-lifetimes)).
final Provider<GitClientFor> gitClientForProvider = Provider<GitClientFor>(
  (Ref ref) =>
      (String folder) => DartIoGitClient(workingDirectory: folder),
);

/// Per-machine preferences.
///
/// One JSON file in the platform's application-support folder. Not
/// `shared_preferences`: it is a Flutter plugin, and settings belong to
/// `tom_infra`, which is pure Dart — see `JsonFileSettings`.
final Provider<Settings> settingsProvider = Provider<Settings>(
  (Ref ref) => JsonFileSettings(
    filesystem: ref.watch(filesystemProvider),
    path: '${applicationSupportDirectory()}/preferences.json',
  ),
);

/// The folders spaces are made of.
final Provider<SpaceRepository> spaceRepositoryProvider =
    Provider<SpaceRepository>(
      (Ref ref) => SpaceRepositoryImpl(
        filesystem: ref.watch(filesystemProvider),
        gitClientFor: ref.watch(gitClientForProvider),
      ),
    );

/// The spaces Home offers to go back to.
final Provider<RecentSpacesRepository> recentSpacesRepositoryProvider =
    Provider<RecentSpacesRepository>(
      (Ref ref) =>
          RecentSpacesRepositoryImpl(settings: ref.watch(settingsProvider)),
    );

/// The overrides that turn the contracts above into the app's own wiring.
///
/// `tom_presentation` declares the use cases it needs and nothing else: it
/// does not depend on `tom_data` or `tom_infra`, so it cannot know which
/// repository, which git client or which disk ends up behind them. This is
/// the one place that does ([Decision
/// 12](../../../../../docs/technical/decisions/012-shell-is-extensible-via-compile-time-modules.md)).
final List<Override> appOverrides = <Override>[
  openSpaceProvider.overrideWith(
    (Ref ref) => OpenSpace(
      spaces: ref.watch(spaceRepositoryProvider),
      recents: ref.watch(recentSpacesRepositoryProvider),
      observability: ref.watch(observabilityProvider),
    ),
  ),
  listRecentSpacesProvider.overrideWith(
    (Ref ref) => ListRecentSpaces(
      recents: ref.watch(recentSpacesRepositoryProvider),
      observability: ref.watch(observabilityProvider),
    ),
  ),
  forgetRecentSpaceProvider.overrideWith(
    (Ref ref) => ForgetRecentSpace(
      recents: ref.watch(recentSpacesRepositoryProvider),
      observability: ref.watch(observabilityProvider),
    ),
  ),
];

/// Discards everything, which is the point.
///
/// The default implementation of a port that exists so telemetry *can* be
/// added without every use case learning about it.
final class _SilentObservability implements Observability {
  const _SilentObservability();

  @override
  Future<void> capture(
    Object error,
    StackTrace stackTrace, {
    required String layer,
  }) async {}
}
