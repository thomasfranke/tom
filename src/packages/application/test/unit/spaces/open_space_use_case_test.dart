import 'package:test/test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  late _RecordingObservability observability;
  late _Recents recents;

  final SpaceEntity opened = SpaceEntity(
    root: '/code/app/docs',
    repositoryRoot: '/code/app',
    name: 'docs',
  );

  setUp(() {
    observability = _RecordingObservability();
    recents = _Recents();
  });

  /// The use case over a repository that answers [answer].
  OpenSpaceUseCase openingWith(Result<SpaceEntity, AppFailure> answer) =>
      OpenSpaceUseCase(
        spaces: _Spaces(answer: answer),
        recents: recents,
        observability: observability,
      );

  group('what it hands back', () {
    test('the space the repository opened', () async {
      final Result<SpaceEntity, AppFailure> result = await openingWith(
        Success<SpaceEntity, AppFailure>(opened),
      ).open('/code/app/docs');

      expect((result as Success<SpaceEntity, AppFailure>).value, opened);
    });

    test('the folder it was asked about reaches the repository', () async {
      final _Spaces spaces = _Spaces(
        answer: Success<SpaceEntity, AppFailure>(opened),
      );

      await OpenSpaceUseCase(
        spaces: spaces,
        recents: recents,
        observability: observability,
      ).open('/picked');

      expect(spaces.asked, '/picked');
    });
  });

  group('an expected failure stays expected', () {
    test('a folder outside any repository is passed through', () async {
      final Result<SpaceEntity, AppFailure> result = await openingWith(
        const Failure<SpaceEntity, AppFailure>(GitNotARepository('/loose')),
      ).open('/loose');

      expect(
        (result as Failure<SpaceEntity, AppFailure>).failure,
        const GitNotARepository('/loose'),
      );
    });

    test('a folder that is gone is passed through', () async {
      final Result<SpaceEntity, AppFailure> result = await openingWith(
        const Failure<SpaceEntity, AppFailure>(SpaceFolderMissing('/gone')),
      ).open('/gone');

      expect(
        (result as Failure<SpaceEntity, AppFailure>).failure,
        const SpaceFolderMissing('/gone'),
      );
    });

    test('and nothing is reported to observability', () async {
      await openingWith(
        const Failure<SpaceEntity, AppFailure>(GitNotARepository('/loose')),
      ).open('/loose');

      expect(observability.captured, isEmpty);
    });
  });

  group('what gets remembered', () {
    test('a space that opened', () async {
      await openingWith(
        Success<SpaceEntity, AppFailure>(opened),
      ).open('/code/app/docs');

      expect(recents.remembered, <SpaceEntity>[opened]);
    });

    test('a folder outside a repository is not a place to return to', () async {
      await openingWith(
        const Failure<SpaceEntity, AppFailure>(GitNotARepository('/loose')),
      ).open('/loose');

      expect(recents.remembered, isEmpty);
    });

    test('nor is a folder that is gone', () async {
      await openingWith(
        const Failure<SpaceEntity, AppFailure>(SpaceFolderMissing('/gone')),
      ).open('/gone');

      expect(recents.remembered, isEmpty);
    });
  });

  group('when the list cannot be written', () {
    test('the space still opens', () async {
      recents.breaks = true;

      final Result<SpaceEntity, AppFailure> result = await openingWith(
        Success<SpaceEntity, AppFailure>(opened),
      ).open('/code/app/docs');

      expect((result as Success<SpaceEntity, AppFailure>).value, opened);
    });

    test('and nothing is reported as unexpected', () async {
      recents.breaks = true;

      await openingWith(
        Success<SpaceEntity, AppFailure>(opened),
      ).open('/code/app/docs');

      expect(observability.captured, isEmpty);
    });
  });

  group('an exception becomes a failure', () {
    test('it never escapes the use case', () async {
      final Result<SpaceEntity, AppFailure> result = await OpenSpaceUseCase(
        spaces: _ThrowingSpaces(),
        recents: recents,
        observability: observability,
      ).open('/anywhere');

      expect(
        (result as Failure<SpaceEntity, AppFailure>).failure,
        isA<UnexpectedFailure>(),
      );
    });

    test('and it is reported, tagged with the layer that caught it', () async {
      await OpenSpaceUseCase(
        spaces: _ThrowingSpaces(),
        recents: recents,
        observability: observability,
      ).open('/anywhere');

      expect(observability.captured, hasLength(1));
      expect(observability.captured.single.layer, 'application');
      expect(
        observability.captured.single.error.toString(),
        contains('the disk caught fire'),
      );
    });

    test('what it caught survives into the failure, as text', () async {
      final Result<SpaceEntity, AppFailure> result = await OpenSpaceUseCase(
        spaces: _ThrowingSpaces(),
        recents: recents,
        observability: observability,
      ).open('/anywhere');

      expect(
        ((result as Failure<SpaceEntity, AppFailure>).failure
                as UnexpectedFailure)
            .description,
        contains('the disk caught fire'),
      );
    });
  });
}

/// A repository that answers what it was told to, and remembers the folder.
final class _Spaces implements SpaceRepository {
  _Spaces({required this.answer});

  final Result<SpaceEntity, AppFailure> answer;
  String? asked;

  @override
  Future<Result<SpaceEntity, AppFailure>> open(String folder) async {
    asked = folder;
    return answer;
  }

  @override
  Future<Result<List<SpaceEntryValueObject>, SpaceFailure>> entries(
    SpaceEntity space,
  ) async => throw UnimplementedError();
}

/// A repository that breaks its contract by throwing.
final class _ThrowingSpaces implements SpaceRepository {
  @override
  Future<Result<SpaceEntity, AppFailure>> open(String folder) async =>
      throw StateError('the disk caught fire');

  @override
  Future<Result<List<SpaceEntryValueObject>, SpaceFailure>> entries(
    SpaceEntity space,
  ) async => throw UnimplementedError();
}

/// A recent list that records what it was asked, and can be made to fail.
final class _Recents implements RecentSpacesRepository {
  final List<SpaceEntity> remembered = <SpaceEntity>[];

  /// Whether the store underneath is broken; it still reports success, as
  /// the contract says.
  bool breaks = false;

  @override
  Future<Result<List<RecentSpaceEntity>, Never>> list() async =>
      const Success<List<RecentSpaceEntity>, Never>(<RecentSpaceEntity>[]);

  @override
  Future<Result<void, Never>> remember(SpaceEntity space) async {
    if (!breaks) {
      remembered.add(space);
    }
    return const Success<void, Never>(null);
  }

  @override
  Future<Result<void, Never>> forget(String root) async =>
      const Success<void, Never>(null);
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
