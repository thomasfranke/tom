/// What a document changed against a version of itself.
library;

import 'package:tom_application/src/use_case.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

/// Compares the document on screen against what a revision holds.
///
/// The **after** side arrives already parsed, because the preview has just
/// split it to draw it: parsing the buffer twice per keystroke is the one
/// cost this use case could not justify.
final class DiffDocumentUseCase with UseCase {
  /// Creates the use case.
  const DiffDocumentUseCase({
    required this.gitFor,
    required this.blocks,
    required this.differ,
    required this.observability,
  });

  /// How to reach git for a space.
  final GitRepositoryFor gitFor;

  /// What splits the committed version into blocks.
  final BlockReaderPort blocks;

  /// What classifies one version against the other.
  final BlockDifferService differ;

  @override
  final Observability observability;

  /// The revision the working tree is compared against.
  ///
  /// `HEAD` is what the product means by "what changed"
  /// (`docs/product/diff/rendered-diff/doc.md`); the branch and commit diff
  /// is the item that passes something else.
  static const String head = 'HEAD';

  /// What [after] changed against [revision].
  ///
  /// **A document the revision does not hold is every block added**, not a
  /// failure: a new file, one only ever renamed into place, or a space on a
  /// repository with no commits yet are all normal, and the reader is shown
  /// the same thing in each case — everything here is new.
  Future<Result<DocumentDiffValueObject, AppFailure>> diff({
    required SpaceEntity space,
    required ParsedDocumentValueObject after,
    String revision = head,
    // Spelled out because the body answers in two vocabularies — git's for
    // the version it could not read, the document's for one it could not
    // parse — and inference lands on `Object?` between them.
  }) => guard<DocumentDiffValueObject, AppFailure>(() async {
    final Result<String, GitFailure> committed = await gitFor(space).contentAt(
      revision: revision,
      path: space.toRepoRelative(after.document.path),
    );
    final String source;
    switch (committed) {
      case Success<String, GitFailure>(value: final String content):
        source = content;
      case Failure<String, GitFailure>(failure: GitPathNotInRevision()):
        source = '';
      case Failure<String, GitFailure>(failure: final GitFailure failure):
        return Failure<DocumentDiffValueObject, GitFailure>(failure);
    }
    final Result<ParsedDocumentValueObject, DocumentFailure> before =
        await blocks.read(
          DocumentEntity(path: after.document.path, content: source),
        );
    return switch (before) {
      Success<ParsedDocumentValueObject, DocumentFailure>(
        value: final ParsedDocumentValueObject parsed,
      ) =>
        await differ.diff(before: parsed, after: after),
      Failure<ParsedDocumentValueObject, DocumentFailure>(
        failure: final DocumentFailure failure,
      ) =>
        Failure<DocumentDiffValueObject, DocumentFailure>(failure),
    };
  });
}
