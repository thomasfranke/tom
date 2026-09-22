/// What the application may ask about a space's folder.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/src/spaces/space.dart';
import 'package:tom_domain/src/spaces/space_entry.dart';
import 'package:tom_domain/src/spaces/space_failure.dart';

/// The folders spaces are made of, as the product talks about them.
///
/// One instance for the app, not one per space: a `Space` is data, so it
/// travels as an argument rather than as a lifetime. That also makes [open]
/// belong here — a repository that could list a space but not produce one
/// would need a factory beside it, and factories are a pattern this project
/// does not take ([Decision
/// 15](../../../../../../docs/technical/decisions/015-ddd-is-applied-selectively.md)).
///
/// Folder-level work lives here and file-level work on `DocumentRepository`,
/// because the two fail differently: a document that cannot be read sends
/// the user to another document, a folder that cannot be read sends them to
/// another space.
abstract interface class SpaceRepository {
  /// Opens [folder] as a space, finding the repository that encloses it.
  ///
  /// **A space is a folder, not a repository.** The user opens `docs/` and
  /// git still runs against the repository above it, which is why the
  /// answer is a [Space] carrying both paths rather than one
  /// (`docs/product/home/doc.md`).
  ///
  /// Two ways it fails, and they send the user somewhere different:
  ///
  /// - `SpaceFolderMissing` — nothing is at [folder]. What a recent space
  ///   whose folder was deleted or unmounted answers, which Home offers to
  ///   forget rather than reporting as a fault.
  /// - `GitNotARepository` — the folder is there and nothing encloses it.
  ///   A named failure with an explanation, never a crash and never a
  ///   quieter mode: **TOM does not create a repository on the user's
  ///   behalf.**
  ///
  /// [AppFailure] rather than one hierarchy, and deliberately: opening asks
  /// the disk *and* git, so the two outcomes above come from two vocabularies
  /// and Home switches over both. Narrowing this would mean copying git's
  /// variants into [SpaceFailure], which is the duplication two vocabularies
  /// exist to avoid.
  Future<Result<Space, AppFailure>> open(String folder);

  /// Everything [space] holds, in the order a tree shows it.
  ///
  /// Depth first and sorted: a folder is immediately followed by what is
  /// inside it, so a tree can be built by walking the list once.
  ///
  /// **`.git/` is not in it, and is never descended into.** That is this
  /// layer's policy, not the filesystem capability's
  /// (`docs/product/navigation/file-tree/doc.md`) — and it is also what
  /// keeps the listing affordable: the space of a mature repository holds a
  /// few hundred documents and a `.git/` holding a hundred thousand loose
  /// objects. Every other dotfolder is included, `.ai/` and `.github/` among
  /// them, because a team's own tooling is documentation too.
  ///
  /// A folder the machine will not open is skipped, with everything else
  /// still returned: one unreadable folder inside a space costs that folder,
  /// not the file tree. Only the space root itself failing fails the call.
  ///
  /// Files of every kind are reported, not only `.md` — what the tree draws
  /// and what the editor will open are two different questions, and
  /// `SpaceEntry.isDocument` answers the second.
  Future<Result<List<SpaceEntry>, SpaceFailure>> entries(Space space);
}
