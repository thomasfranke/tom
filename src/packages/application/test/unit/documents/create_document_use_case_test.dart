import 'package:test/test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  final SpaceEntity docs = SpaceEntity(
    root: '/code/app/docs',
    repositoryRoot: '/code/app',
    name: 'docs',
  );
  final SpaceRelativePathValueObject tasks = SpaceRelativePathValueObject(
    'tasks',
  );

  /// Creates [typed] in [folder] against [documents].
  Future<Result<SpaceRelativePathValueObject, AppFailure>> create(
    _Documents documents,
    SpaceRelativePathValueObject? folder,
    String typed,
  ) => CreateDocumentUseCase(
    documentsFor: (SpaceEntity space) => documents,
    observability: const _Silent(),
  ).create(docs, folder, typed);

  group('the name', () {
    test('a name without .md gets it', () {
      expect(
        CreateDocumentUseCase.pathFor(tasks, 'untitled')?.value,
        'tasks/untitled.md',
      );
    });

    test('a name that already says .md is kept as typed', () {
      expect(
        CreateDocumentUseCase.pathFor(tasks, 'Notes.MD')?.value,
        'tasks/Notes.MD',
      );
    });

    test('another extension still becomes markdown', () {
      // The `+` creates the one thing the editor opens.
      expect(
        CreateDocumentUseCase.pathFor(null, 'notes.txt')?.value,
        'notes.txt.md',
      );
    });

    test('at the root there is no folder before it', () {
      expect(CreateDocumentUseCase.pathFor(null, 'index')?.value, 'index.md');
    });

    test('spaces around the name are not part of it', () {
      expect(
        CreateDocumentUseCase.pathFor(tasks, '  plan  ')?.value,
        'tasks/plan.md',
      );
    });

    for (final String bad in <String>['', '   ', '.', '..', 'a/b', r'a\b']) {
      test('"$bad" is not a name', () {
        expect(CreateDocumentUseCase.pathFor(tasks, bad), isNull);
      });
    }
  });

  test('it creates an empty document and answers with its path', () async {
    final _Documents documents = _Documents();

    final Result<SpaceRelativePathValueObject, AppFailure> result =
        await create(documents, tasks, 'untitled');

    expect(
      (result as Success<SpaceRelativePathValueObject, AppFailure>).value,
      SpaceRelativePathValueObject('tasks/untitled.md'),
    );
    expect(documents.created, <DocumentEntity>[
      DocumentEntity(
        path: SpaceRelativePathValueObject('tasks/untitled.md'),
        content: '',
      ),
    ]);
  });

  test('a name that is not one is refused before the disk is asked', () async {
    final _Documents documents = _Documents();

    final Result<SpaceRelativePathValueObject, AppFailure> result =
        await create(documents, tasks, '../escape');

    expect(
      (result as Failure<SpaceRelativePathValueObject, AppFailure>).failure,
      const DocumentInvalidName('../escape'),
    );
    expect(documents.created, isEmpty);
  });

  test('a name already taken comes back as taken, never overwritten', () async {
    final _Documents documents = _Documents(
      answer: const Failure<void, DocumentFailure>(
        DocumentAlreadyExists('tasks/roadmap.md'),
      ),
    );

    final Result<SpaceRelativePathValueObject, AppFailure> result =
        await create(documents, tasks, 'roadmap');

    expect(
      (result as Failure<SpaceRelativePathValueObject, AppFailure>).failure,
      const DocumentAlreadyExists('tasks/roadmap.md'),
    );
    expect(documents.written, isEmpty);
  });
}

/// A repository that keeps what it was asked to create.
final class _Documents implements DocumentRepository {
  _Documents({this.answer});

  final Result<void, DocumentFailure>? answer;
  final List<DocumentEntity> created = <DocumentEntity>[];
  final List<DocumentEntity> written = <DocumentEntity>[];

  @override
  Future<Result<DocumentEntity, DocumentFailure>> read(
    SpaceRelativePathValueObject path,
  ) async => throw UnimplementedError();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<Result<void, DocumentFailure>> create(DocumentEntity document) async {
    if (answer case final Result<void, DocumentFailure> refused) {
      return refused;
    }
    created.add(document);
    return const Success<void, DocumentFailure>(null);
  }

  @override
  Future<Result<void, DocumentFailure>> write(DocumentEntity document) async {
    written.add(document);
    return const Success<void, DocumentFailure>(null);
  }
}

/// The no-op observability, which is also the shipping default.
final class _Silent implements Observability {
  const _Silent();

  @override
  Future<void> capture(
    Object error,
    StackTrace stackTrace, {
    required String layer,
  }) async {}
}
