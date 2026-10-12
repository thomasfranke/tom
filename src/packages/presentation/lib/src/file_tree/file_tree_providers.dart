/// What the file tree is wired from, declared where the file tree lives.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tom_application/tom_application.dart';

part 'file_tree_providers.g.dart';

/// Reads everything a space holds.
///
/// Declared here and overridden by the composition root, which is how every
/// use case reaches this package: it names what it needs and cannot see
/// what satisfies it.
@riverpod
ListSpaceEntriesUseCase listSpaceEntries(Ref ref) => throw StateError(
  'listSpaceEntriesProvider has no default. The composition root overrides '
  'it — see runTom() in tom_desktop.',
);

/// Creates a folder where the explorer menu's `New folder` asks.
@riverpod
CreateFolderUseCase createFolder(Ref ref) => throw StateError(
  'createFolderProvider has no default. The composition root overrides '
  'it — see runTom() in tom_desktop.',
);

/// Shows a folder in the platform's file manager — the space's from the
/// explorer, the repository's from the git column.
@riverpod
RevealFolderUseCase revealFolder(Ref ref) => throw StateError(
  'revealFolderProvider has no default. The composition root overrides '
  'it — see runTom() in tom_desktop.',
);

/// Creates a markdown document where the explorer's `+` was pressed.
@riverpod
CreateDocumentUseCase createDocument(Ref ref) => throw StateError(
  'createDocumentProvider has no default. The composition root overrides '
  'it — see runTom() in tom_desktop.',
);
