import 'dart:convert';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  late _RecordingObservability observability;

  final SpaceEntity app = SpaceEntity(
    root: '/code/app',
    repositoryRoot: '/code/app',
    name: 'app',
  );
  final SpaceRelativePathValueObject path = SpaceRelativePathValueObject(
    'config/site.yaml',
  );

  setUp(() => observability = _RecordingObservability());

  Future<Result<FileContentValueObject, AppFailure>> reading(
    Future<Result<Uint8List, DocumentFailure>> Function() answer,
  ) => ReadFileUseCase(
    documentsFor: (SpaceEntity space) => _Documents(answer),
    observability: observability,
  ).read(app, path);

  Future<Result<FileContentValueObject, AppFailure>> holding(List<int> bytes) =>
      reading(
        () async =>
            Success<Uint8List, DocumentFailure>(Uint8List.fromList(bytes)),
      );

  test('text comes back as the document its bytes decode to', () async {
    final Result<FileContentValueObject, AppFailure> result = await holding(
      utf8.encode('a: 1\n'),
    );
    expect(
      (result as Success<FileContentValueObject, AppFailure>).value,
      FileContentValueObject.text(
        DocumentEntity(path: path, content: 'a: 1\n'),
      ),
    );
  });

  test('a zero byte near the start is binary', () async {
    final Result<FileContentValueObject, AppFailure> result = await holding(
      <int>[...utf8.encode('GIF89a'), 0],
    );
    expect(
      (result as Success<FileContentValueObject, AppFailure>).value,
      const FileContentValueObject.binary(),
    );
  });

  test('bytes that are not UTF-8 are binary, not a failure', () async {
    final Result<FileContentValueObject, AppFailure> result = await holding(
      <int>[0xFF, 0xD8, 0xFF, 0xE0],
    );
    expect(
      (result as Success<FileContentValueObject, AppFailure>).value,
      const FileContentValueObject.binary(),
    );
  });

  test('a file that is gone is passed through', () async {
    final Result<FileContentValueObject, AppFailure> result = await reading(
      () async =>
          Failure<Uint8List, DocumentFailure>(DocumentNotFound(path.value)),
    );
    expect(
      (result as Failure<FileContentValueObject, AppFailure>).failure,
      DocumentNotFound(path.value),
    );
    expect(observability.captured, isEmpty);
  });

  test('an exception becomes a failure, and is reported', () async {
    final Result<FileContentValueObject, AppFailure> result = await reading(
      () async => throw StateError('the disk caught fire'),
    );
    expect(
      (result as Failure<FileContentValueObject, AppFailure>).failure,
      isA<UnexpectedFailure>(),
    );
    expect(observability.captured, hasLength(1));
  });
}

final class _Documents implements DocumentRepository {
  const _Documents(this.answer);

  final Future<Result<Uint8List, DocumentFailure>> Function() answer;

  @override
  Future<Result<Uint8List, DocumentFailure>> readBytes(
    SpaceRelativePathValueObject path,
  ) => answer();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _RecordingObservability implements Observability {
  final List<Object> captured = <Object>[];

  @override
  Future<void> capture(
    Object error,
    StackTrace stackTrace, {
    required String layer,
  }) async => captured.add(error);
}
