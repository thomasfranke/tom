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

  late _Spaces spaces;
  late _Recording observability;

  setUp(() {
    spaces = _Spaces();
    observability = _Recording();
  });

  Future<Result<SpaceRelativePathValueObject, AppFailure>> create(
    SpaceRelativePathValueObject? folder,
    String typed,
  ) => CreateFolderUseCase(
    spaces: spaces,
    observability: observability,
  ).create(docs, folder, typed);

  test('creates the folder inside the one asked for, as typed', () async {
    final Result<SpaceRelativePathValueObject, AppFailure> result =
        await create(tasks, '  drafts  ');

    expect(spaces.created, <String>['tasks/drafts']);
    expect(
      (result as Success<SpaceRelativePathValueObject, AppFailure>).value,
      SpaceRelativePathValueObject('tasks/drafts'),
    );
  });

  test('no extension is added: it is a folder', () async {
    await create(null, 'archive');

    expect(spaces.created, <String>['archive']);
  });

  for (final String bad in <String>['', ' ', '.', '..', 'a/b', r'a\b']) {
    test('"$bad" is not a name, and the disk is never asked', () async {
      final Result<SpaceRelativePathValueObject, AppFailure> result =
          await create(tasks, bad);

      expect(
        (result as Failure<SpaceRelativePathValueObject, AppFailure>).failure,
        isA<SpaceInvalidName>(),
      );
      expect(spaces.created, isEmpty);
    });
  }

  test('a name already taken is passed through, not reported', () async {
    spaces.answer = const Failure<void, SpaceFailure>(
      SpaceEntryExists('tasks'),
    );

    final Result<SpaceRelativePathValueObject, AppFailure> result =
        await create(null, 'tasks');

    expect(
      (result as Failure<SpaceRelativePathValueObject, AppFailure>).failure,
      const SpaceEntryExists('tasks'),
    );
    expect(observability.captured, isEmpty);
  });

  test('an exception never escapes, and is reported', () async {
    spaces.throws = true;

    final Result<SpaceRelativePathValueObject, AppFailure> result =
        await create(null, 'tasks');

    expect(
      (result as Failure<SpaceRelativePathValueObject, AppFailure>).failure,
      isA<UnexpectedFailure>(),
    );
    expect(observability.captured, hasLength(1));
  });
}

/// Folders that answer as told, and remember what was asked.
final class _Spaces implements SpaceRepository {
  Result<void, SpaceFailure> answer = const Success<void, SpaceFailure>(null);
  bool throws = false;
  final List<String> created = <String>[];

  @override
  Future<Result<void, SpaceFailure>> createFolder(
    SpaceEntity space,
    SpaceRelativePathValueObject path,
  ) async {
    if (throws) {
      throw StateError('the disk caught fire');
    }
    created.add(path.value);
    return answer;
  }

  @override
  Future<Result<SpaceEntity, AppFailure>> open(String folder) async =>
      throw UnimplementedError();

  @override
  Future<Result<List<SpaceEntryValueObject>, SpaceFailure>> entries(
    SpaceEntity space,
  ) async => throw UnimplementedError();
}

/// An [Observability] that keeps what it was handed.
final class _Recording implements Observability {
  final List<Object> captured = <Object>[];

  @override
  Future<void> capture(
    Object error,
    StackTrace stackTrace, {
    required String layer,
  }) async => captured.add(error);
}
