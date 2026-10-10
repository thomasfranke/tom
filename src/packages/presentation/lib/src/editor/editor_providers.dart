/// What the editor is wired from, declared where the editor lives.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tom_application/tom_application.dart';

part 'editor_providers.g.dart';

/// Reads a document's source off the disk.
///
/// Declared here and overridden by the composition root, which is how every
/// use case reaches this package.
@riverpod
ReadDocumentUseCase readDocument(Ref ref) => throw StateError(
  'readDocumentProvider has no default. The composition root overrides it '
  '— see runTom() in tom_desktop.',
);

/// Reads a file that is not markdown, finding out whether it is text
/// (`docs/product/git-workflow/commit/opening-a-change/doc.md`).
@riverpod
ReadFileUseCase readFile(Ref ref) => throw StateError(
  'readFileProvider has no default. The composition root overrides it '
  '— see runTom() in tom_desktop.',
);

/// Reads a deleted file as the last commit left it.
@riverpod
ReadCommittedFileUseCase readCommittedFile(Ref ref) => throw StateError(
  'readCommittedFileProvider has no default. The composition root '
  'overrides it — see runTom() in tom_desktop.',
);

/// Compares a file that is not markdown against its base, line by line.
@riverpod
DiffLinesUseCase diffLines(Ref ref) => throw StateError(
  'diffLinesProvider has no default. The composition root overrides it '
  '— see runTom() in tom_desktop.',
);

/// Writes the buffer back to the file it came from.
@riverpod
SaveDocumentUseCase saveDocument(Ref ref) => throw StateError(
  'saveDocumentProvider has no default. The composition root overrides it '
  '— see runTom() in tom_desktop.',
);

/// Reads a branch's pull request draft, seeding it the first time.
@riverpod
OpenPullRequestDraftUseCase openPullRequestDraft(Ref ref) => throw StateError(
  'openPullRequestDraftProvider has no default. The composition root '
  'overrides it — see runTom() in tom_desktop.',
);

/// Reads the preferences file: the same use case as [readDocument], over the
/// app's own folder rather than the space
/// (`docs/product/preferences/where-it-is-stored/doc.md`).
@riverpod
ReadDocumentUseCase readPreferencesFile(Ref ref) => throw StateError(
  'readPreferencesFileProvider has no default. The composition root '
  'overrides it — see runTom() in tom_desktop.',
);

/// Writes the preferences file back, as [saveDocument] over the app's folder.
@riverpod
SaveDocumentUseCase savePreferencesFile(Ref ref) => throw StateError(
  'savePreferencesFileProvider has no default. The composition root '
  'overrides it — see runTom() in tom_desktop.',
);

/// Writes a pull request draft back: the same use case as [saveDocument],
/// over the drafts folder rather than the space (Decision 33).
@riverpod
SaveDocumentUseCase saveDraft(Ref ref) => throw StateError(
  'saveDraftProvider has no default. The composition root overrides it '
  '— see runTom() in tom_desktop.',
);
