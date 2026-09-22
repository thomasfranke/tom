import 'package:test/test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  late _Recents recents;
  late _Observability observability;

  setUp(() {
    recents = _Recents();
    observability = _Observability();
  });

  ListRecentSpacesUseCase listing() =>
      ListRecentSpacesUseCase(recents: recents, observability: observability);

  test('the list comes back as the repository ordered it', () async {
    // The order is the repository's business — most recent first — and this
    // use case does not re-sort what it was handed.
    recents.stored = <RecentSpaceEntity>[
      RecentSpaceEntity(
        root: '/b',
        name: 'b',
        lastOpened: DateTime.utc(2026, 9, 2),
      ),
      RecentSpaceEntity(
        root: '/a',
        name: 'a',
        lastOpened: DateTime.utc(2026, 9),
      ),
    ];

    final Result<List<RecentSpaceEntity>, AppFailure> result = await listing()
        .list();

    expect(
      (result as Success<List<RecentSpaceEntity>, AppFailure>).value.map(
        (RecentSpaceEntity recent) => recent.root,
      ),
      <String>['/b', '/a'],
    );
  });

  test('an empty list is an ordinary answer', () async {
    expect(
      (await listing().list() as Success<List<RecentSpaceEntity>, AppFailure>)
          .value,
      isEmpty,
    );
  });

  test('nothing checks whether the folders are still there', () async {
    // A row whose folder went away is still offered: the product's answer is
    // to let the user forget it, and checking would be a disk read per row
    // of a list nobody may click.
    recents.stored = <RecentSpaceEntity>[
      RecentSpaceEntity(
        root: '/gone',
        name: 'gone',
        lastOpened: DateTime.utc(2026, 9),
      ),
    ];

    final Result<List<RecentSpaceEntity>, AppFailure> result = await listing()
        .list();

    expect(
      (result as Success<List<RecentSpaceEntity>, AppFailure>).value,
      hasLength(1),
    );
  });

  test('an exception becomes a failure, and is reported', () async {
    final Result<List<RecentSpaceEntity>, AppFailure> result =
        await ListRecentSpacesUseCase(
          recents: _ThrowingRecents(),
          observability: observability,
        ).list();

    expect(
      (result as Failure<List<RecentSpaceEntity>, AppFailure>).failure,
      isA<UnexpectedFailure>(),
    );
    expect(observability.captured, hasLength(1));
  });
}

/// A recent list held in memory.
final class _Recents implements RecentSpacesRepository {
  List<RecentSpaceEntity> stored = <RecentSpaceEntity>[];

  @override
  Future<Result<List<RecentSpaceEntity>, Never>> list() async =>
      Success<List<RecentSpaceEntity>, Never>(stored);

  @override
  Future<Result<void, Never>> remember(SpaceEntity space) async =>
      const Success<void, Never>(null);

  @override
  Future<Result<void, Never>> forget(String root) async =>
      const Success<void, Never>(null);
}

/// A repository that breaks its contract by throwing.
///
/// [Never] says it cannot *return* a failure, which is exactly why throwing is
/// the only way left to break it — and what the use case's guard is for.
final class _ThrowingRecents implements RecentSpacesRepository {
  @override
  Future<Result<List<RecentSpaceEntity>, Never>> list() async =>
      throw StateError('the preferences file is a directory');

  @override
  Future<Result<void, Never>> remember(SpaceEntity space) async =>
      const Success<void, Never>(null);

  @override
  Future<Result<void, Never>> forget(String root) async =>
      const Success<void, Never>(null);
}

/// An [Observability] that keeps what it was handed.
final class _Observability implements Observability {
  final List<Object> captured = <Object>[];

  @override
  Future<void> capture(
    Object error,
    StackTrace stackTrace, {
    required String layer,
  }) async => captured.add(error);
}
