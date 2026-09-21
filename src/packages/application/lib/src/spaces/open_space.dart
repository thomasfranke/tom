/// Turning a folder the user picked into a space.
library;

import 'package:tom_application/src/use_case.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

/// Opens a folder as a space.
///
/// The first thing every session does, and the one the product is most
/// specific about (`docs/product/home/doc.md`):
///
/// - **A space is a folder, not a repository.** Opening `docs/` inside a
///   code repository is the normal case, not an edge one, and the [Space]
///   that comes back carries both paths so git and the file tree can each
///   use the right one.
/// - **Failing is a named state, not a crash.** A folder outside any
///   repository answers `GitNotARepository`, which Home explains; a folder
///   that is no longer there answers `SpaceFolderMissing`, which Home offers
///   to forget. **TOM never creates a repository on the user's behalf**, and
///   never opens the folder in a quieter, degraded mode instead.
///
/// It orchestrates nothing today — one call to one repository — and it still
/// exists rather than letting presentation reach the repository directly.
/// Two reasons, both structural: `tom_presentation` cannot see `tom_data`,
/// and this is where the standardized `try/catch` lives, so the guarantee
/// that nothing throws across a boundary has a single home
/// ([layers](../../../../../docs/technical/layers.md#errors-across-boundaries)).
final class OpenSpace with UseCase {
  /// Creates the use case.
  const OpenSpace({
    required this.spaces,
    required this.recents,
    required this.observability,
  });

  /// Where spaces come from.
  final SpaceRepository spaces;

  /// Where the list Home offers to go back to is kept.
  final RecentSpacesRepository recents;

  @override
  final Observability observability;

  /// Opens [folder], and remembers it if it opened.
  ///
  /// Remembering is part of opening rather than a second thing the caller
  /// must not forget: if it were separate, the one screen that opened a
  /// space without recording it would be a bug nobody notices until a user
  /// asks why their list is empty.
  ///
  /// **It only remembers what actually opened**, and remembering never fails
  /// the open. A folder that is not a repository is not a place to return
  /// to, and a preferences file that cannot be written is not a reason to
  /// refuse a session — `RecentSpacesRepository` says why it reports that
  /// way.
  Future<Result<Space>> call(String folder) => guard(() async {
    final Result<Space> opened = await spaces.open(folder);
    if (opened case Success<Space>(value: final Space space)) {
      await recents.remember(space);
    }
    return opened;
  });
}
