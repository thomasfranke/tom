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

  group('in two halves', () {
    final SpaceEntity folder = SpaceEntity(
      root: '/code/app/docs',
      repositoryRoot: null,
      name: 'docs',
    );

    test(
      'the folder is opened and remembered with git asked nothing',
      () async {
        final _Locator locator = _Locator(folder, opened);

        final Result<SpaceEntity, AppFailure> result = await OpenSpaceUseCase(
          spaces: _Spaces(answer: Success<SpaceEntity, AppFailure>(opened)),
          locator: locator,
          recents: recents,
          observability: observability,
        ).openFolder('/code/app/docs');

        expect((result as Success<SpaceEntity, AppFailure>).value, folder);
        expect(locator.located, 0);
        expect(recents.remembered, <SpaceEntity>[folder]);
      },
    );

    test('the repository is found apart, a failure passed through', () async {
      final _Locator locator = _Locator(folder, opened);
      final OpenSpaceUseCase use = OpenSpaceUseCase(
        spaces: _Spaces(answer: Success<SpaceEntity, AppFailure>(opened)),
        locator: locator,
        recents: recents,
        observability: observability,
      );

      expect(
        ((await use.locate(folder)) as Success<SpaceEntity, AppFailure>).value,
        opened,
      );
      locator.refusal = const GitCommandDenied();
      expect(
        ((await use.locate(folder)) as Failure<SpaceEntity, AppFailure>)
            .failure
            .isDenial,
        isTrue,
      );
    });

    test('with no locator the whole opening is the only opening', () async {
      final _Spaces spaces = _Spaces(
        answer: Success<SpaceEntity, AppFailure>(opened),
      );
      final OpenSpaceUseCase use = OpenSpaceUseCase(
        spaces: spaces,
        recents: recents,
        observability: observability,
      );

      expect(
        ((await use.openFolder('/p')) as Success<SpaceEntity, AppFailure>)
            .value,
        opened,
      );
      expect(
        ((await use.locate(opened)) as Success<SpaceEntity, AppFailure>).value,
        opened,
      );
    });
  });

  group('an expected failure stays expected', () {
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
        const Failure<SpaceEntity, AppFailure>(SpaceFolderMissing('/gone')),
      ).open('/gone');

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

    test('a folder with no repository, which opened like any other', () async {
      // It is a space (`docs/product/workspace/without-a-repository/doc.md`).
      final SpaceEntity loose = SpaceEntity(
        root: '/loose',
        repositoryRoot: null,
        name: 'loose',
      );

      await openingWith(Success<SpaceEntity, AppFailure>(loose)).open('/loose');

      expect(recents.remembered, <SpaceEntity>[loose]);
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
final class _Locator implements SpaceLocationRepository {
  _Locator(this.folder, this.found);

  final SpaceEntity folder;
  final SpaceEntity found;
  AppFailure? refusal;
  int located = 0;

  @override
  Future<Result<SpaceEntity, AppFailure>> openFolder(String _) async =>
      Success<SpaceEntity, AppFailure>(folder);

  @override
  Future<Result<SpaceEntity, AppFailure>> locate(SpaceEntity space) async {
    located++;
    final AppFailure? refused = refusal;
    return refused != null
        ? Failure<SpaceEntity, AppFailure>(refused)
        : Success<SpaceEntity, AppFailure>(found);
  }
}

final class _Spaces implements SpaceRepository {
  _Spaces({required this.answer});

  final Result<SpaceEntity, AppFailure> answer;
  String? asked;

  @override
  Future<Result<void, SpaceFailure>> createFolder(
    SpaceEntity space,
    SpaceRelativePathValueObject path,
  ) async => throw UnimplementedError();

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
  Future<Result<void, SpaceFailure>> createFolder(
    SpaceEntity space,
    SpaceRelativePathValueObject path,
  ) async => throw UnimplementedError();

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
