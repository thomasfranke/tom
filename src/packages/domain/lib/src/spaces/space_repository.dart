/// What the application may ask of a space's folder.
library;

import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/src/spaces/space_entry.dart';

/// The folder behind one space, as the product talks about it.
///
/// One instance per space. Folder-level work lives here and file-level work
/// on `DocumentRepository`, because the two fail differently: a document
/// that cannot be read sends the user to another document, a folder that
/// cannot be read sends them to another space.
abstract interface class SpaceRepository {
  /// Everything the space holds, in the order a tree shows it.
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
  Future<Result<List<SpaceEntry>>> entries();
}
