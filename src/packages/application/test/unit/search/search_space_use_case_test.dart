import 'package:test/test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  late _RecordingObservability observability;

  final SpaceEntity docs = SpaceEntity(
    root: '/code/app/docs',
    repositoryRoot: '/code/app',
    name: 'docs',
  );
  final SearchHitValueObject found = SearchHitValueObject(
    path: SpaceRelativePathValueObject('guides/writing.md'),
    excerpt: '…a rendered diff…',
  );

  setUp(() => observability = _RecordingObservability());

  /// The use case over an index answering what it is told to.
  SearchSpaceUseCase searchingWith(
    Result<List<SearchHitValueObject>, SearchFailure> answer,
  ) => SearchSpaceUseCase(
    searchFor: (SpaceEntity space) => _Search(answer: answer),
    observability: observability,
  );

  test('it hands back the hits in the order the index ranked them', () async {
    final Result<List<SearchHitValueObject>, AppFailure> result =
        await searchingWith(
          Success<List<SearchHitValueObject>, SearchFailure>(
            <SearchHitValueObject>[found],
          ),
        ).find(docs, 'rendered', limit: 50);

    expect(
      (result as Success<List<SearchHitValueObject>, AppFailure>).value,
      <SearchHitValueObject>[found],
    );
  });

  test('the terms and the limit reach the index unchanged', () async {
    // What was typed is not a query language, and nothing here parses it.
    final _Search index = _Search(
      answer: const Success<List<SearchHitValueObject>, SearchFailure>(
        <SearchHitValueObject>[],
      ),
    );

    await SearchSpaceUseCase(
      searchFor: (SpaceEntity space) => index,
      observability: observability,
    ).find(docs, 'rendered diff*', limit: 12);

    expect(index.asked, 'rendered diff*');
    expect(index.limited, 12);
  });

  test('an index that refuses is passed through, and not reported', () async {
    final Result<List<SearchHitValueObject>, AppFailure> result =
        await searchingWith(
          const Failure<List<SearchHitValueObject>, SearchFailure>(
            SearchIndexCorrupted(),
          ),
        ).find(docs, 'rendered', limit: 50);

    expect(
      (result as Failure<List<SearchHitValueObject>, AppFailure>).failure,
      isA<SearchIndexCorrupted>(),
    );
    expect(observability.captured, isEmpty);
  });

  test('an exception never escapes the use case, and is reported', () async {
    final Result<List<SearchHitValueObject>, AppFailure> result =
        await SearchSpaceUseCase(
          searchFor: (SpaceEntity space) => _ThrowingSearch(),
          observability: observability,
        ).find(docs, 'rendered', limit: 50);

    expect(
      (result as Failure<List<SearchHitValueObject>, AppFailure>).failure,
      isA<UnexpectedFailure>(),
    );
    expect(observability.captured.single.layer, 'application');
  });
}

/// An index that answers what it was told to, keeping what it was asked.
final class _Search implements SearchRepository {
  _Search({required this.answer});

  final Result<List<SearchHitValueObject>, SearchFailure> answer;
  String? asked;
  int? limited;

  @override
  Future<Result<List<SearchHitValueObject>, SearchFailure>> find(
    String terms, {
    required int limit,
  }) async {
    asked = terms;
    limited = limit;
    return answer;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// An index that breaks its contract by throwing.
final class _ThrowingSearch implements SearchRepository {
  @override
  Future<Result<List<SearchHitValueObject>, SearchFailure>> find(
    String terms, {
    required int limit,
  }) async => throw StateError('the database caught fire');

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// An [Observability] that keeps what it was handed.
final class _RecordingObservability implements Observability {
  final List<({Object error, StackTrace stackTrace, String layer})> captured =
      <({Object error, StackTrace stackTrace, String layer})>[];

  @override
  Future<void> capture(
    Object error,
    StackTrace stackTrace, {
    required String layer,
  }) async =>
      captured.add((error: error, stackTrace: stackTrace, layer: layer));
}
