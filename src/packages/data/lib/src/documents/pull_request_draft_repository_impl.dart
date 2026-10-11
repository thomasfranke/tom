/// Pull request drafts, read where git keeps its own files.
library;

import 'dart:typed_data';

import 'package:tom_core/tom_core.dart';
import 'package:tom_data/src/documents/document_data_source.dart';
import 'package:tom_data/src/documents/document_repository_impl.dart';
import 'package:tom_domain/tom_domain.dart';

/// [DocumentRepository] over `<git directory>/tom/pull-request`, the git
/// directory asked of git once and kept ([Decision
/// 33](../../../../../../docs/technical/decisions/033-a-pull-request-draft-is-a-document-outside-the-space.md)).
///
/// Asked rather than assumed at `<repository>/.git`: in a worktree or a
/// submodule `.git` is a file, and the shared directory is elsewhere.
final class PullRequestDraftRepositoryImpl implements DocumentRepository {
  /// Creates the drafts of the repository [git] answers for.
  PullRequestDraftRepositoryImpl({required this.git, required this.documents});

  /// Where the git directory is asked.
  final GitRepository git;

  /// Where a draft's text is read and written.
  final DocumentDataSource documents;

  Future<Result<DocumentRepository, GitFailure>>? _drafts;

  /// The repository over the drafts folder, built on the first call.
  /// Asked once and kept: what is kept is the answer, so saving a draft
  /// asks git nothing. **An answer that is a failure is not kept** — a
  /// refusal at the gate must not stop every later save.
  Future<Result<DocumentRepository, GitFailure>> _resolve() {
    final Future<Result<DocumentRepository, GitFailure>> asked = _drafts ??= git
        .gitDirectory()
        .then(
          (Result<String, GitFailure> found) => found.map(
            (String directory) => DocumentRepositoryImpl(
              documents: documents,
              root: '$directory/tom/pull-request',
            ),
          ),
        );
    return asked.then((Result<DocumentRepository, GitFailure> result) {
      if (result is Failure<DocumentRepository, GitFailure> &&
          identical(_drafts, asked)) {
        _drafts = null;
      }
      return result;
    });
  }

  /// [action] over the drafts folder, or git's refusal said about [path].
  Future<Result<T, DocumentFailure>> _through<T>(
    String path,
    Future<Result<T, DocumentFailure>> Function(DocumentRepository) action,
  ) async {
    final Result<DocumentRepository, GitFailure> drafts = await _resolve();
    return switch (drafts) {
      Success<DocumentRepository, GitFailure>(
        value: final DocumentRepository repository,
      ) =>
        action(repository),
      Failure<DocumentRepository, GitFailure>(
        failure: final GitFailure failure,
      ) =>
        Failure<T, DocumentFailure>(
          DocumentOperationFailed(path, cause: failure),
        ),
    };
  }

  @override
  Future<Result<DocumentEntity, DocumentFailure>> read(
    SpaceRelativePathValueObject path,
  ) => _through(path.value, (DocumentRepository it) => it.read(path));

  @override
  Future<Result<Uint8List, DocumentFailure>> readBytes(
    SpaceRelativePathValueObject path,
  ) => _through(path.value, (DocumentRepository it) => it.readBytes(path));

  @override
  Future<Result<void, DocumentFailure>> create(DocumentEntity document) =>
      _through(
        document.path.value,
        (DocumentRepository it) => it.create(document),
      );

  @override
  Future<Result<void, DocumentFailure>> write(DocumentEntity document) =>
      _through(
        document.path.value,
        (DocumentRepository it) => it.write(document),
      );
}
