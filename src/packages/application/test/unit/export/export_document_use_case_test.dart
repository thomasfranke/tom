/// [ExportDocumentUseCase]: the preview's parse handed to the repository as
/// it is, and nothing thrown past it.
library;

import 'package:test/test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  late _Exports exports;
  late _Recording observability;
  late ExportDocumentUseCase useCase;

  final SpaceEntity space = SpaceEntity(
    root: '/code/docs',
    repositoryRoot: '/code',
    name: 'docs',
  );
  final ParsedDocumentValueObject parsed = ParsedDocumentValueObject(
    document: DocumentEntity(
      path: SpaceRelativePathValueObject('guide/intro.md'),
      content: '# Intro',
    ),
    blocks: const <BlockValueObject>[
      BlockValueObject(
        startLine: 0,
        endLine: 0,
        source: '# Intro',
        kind: BlockKindEnum.heading,
      ),
    ],
    linkDefinitions: '',
  );

  setUp(() {
    exports = _Exports();
    observability = _Recording();
    useCase = ExportDocumentUseCase(
      exports: exports,
      observability: observability,
    );
  });

  test('the space, the parse, the format and the destination reach the '
      'repository untouched', () async {
    final Result<void, AppFailure> result = await useCase.export(
      space,
      parsed,
      ExportFormatEnum.pdf,
      '/home/me/intro.pdf',
    );

    expect(result, isA<Success<void, AppFailure>>());
    expect(exports.asked, hasLength(1));
    expect(exports.asked.single.$1, space);
    expect(exports.asked.single.$2, same(parsed));
    expect(exports.asked.single.$3, ExportFormatEnum.pdf);
    expect(exports.asked.single.$4, '/home/me/intro.pdf');
  });

  test('a failure is passed through, not reported', () async {
    exports.answer = const Failure<void, ExportFailure>(
      ExportFailure.tooLarge(ExportFormatEnum.pdf),
    );

    final Result<void, AppFailure> result = await useCase.export(
      space,
      parsed,
      ExportFormatEnum.pdf,
      '/home/me/intro.pdf',
    );

    expect(
      (result as Failure<void, AppFailure>).failure,
      const ExportFailure.tooLarge(ExportFormatEnum.pdf),
    );
    expect(observability.captured, isEmpty);
  });

  test('an exception never escapes, and is reported', () async {
    exports.throws = true;

    final Result<void, AppFailure> result = await useCase.export(
      space,
      parsed,
      ExportFormatEnum.html,
      '/home/me/intro.html',
    );

    expect(
      (result as Failure<void, AppFailure>).failure,
      isA<UnexpectedFailure>(),
    );
    expect(observability.captured, hasLength(1));
  });
}

/// An export repository that remembers what it was asked and answers as told.
final class _Exports implements ExportRepository {
  Result<void, ExportFailure> answer = const Success<void, ExportFailure>(null);
  bool throws = false;
  final List<(SpaceEntity, ParsedDocumentValueObject, ExportFormatEnum, String)>
  asked =
      <(SpaceEntity, ParsedDocumentValueObject, ExportFormatEnum, String)>[];

  @override
  Future<Result<void, ExportFailure>> export(
    SpaceEntity space,
    ParsedDocumentValueObject document,
    ExportFormatEnum format,
    String destination,
  ) async {
    if (throws) {
      throw StateError('the exporter fell over');
    }
    asked.add((space, document, format, destination));
    return answer;
  }
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
