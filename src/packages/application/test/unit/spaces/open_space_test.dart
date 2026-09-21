import 'package:test/test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  late _RecordingObservability observability;

  final Space opened = Space(
    root: '/code/app/docs',
    repositoryRoot: '/code/app',
    name: 'docs',
  );

  setUp(() => observability = _RecordingObservability());

  /// The use case over a repository that answers [answer].
  OpenSpace openingWith(Result<Space> answer) => OpenSpace(
    spaces: _Spaces(answer: answer),
    recents: _Recents(),
    observability: observability,
  );

  group('what it hands back', () {
    test('the space the repository opened', () async {
      final Result<Space> result = await openingWith(Success<Space>(opened))(
        '/code/app/docs',
      );

      expect(result, isA<Success<Space>>());
      expect((result as Success<Space>).value, opened);
    });

    test('the folder it was asked about reaches the repository', () async {
      final _Spaces spaces = _Spaces(answer: Success<Space>(opened));

      await OpenSpace(
        spaces: spaces,
        recents: _Recents(),
        observability: observability,
      )('/picked');

      expect(spaces.asked, '/picked');
    });
  });

  group('an expected failure stays expected', () {
    // The distinction the whole use case turns on: a repository that
    // *reports* has not thrown, so nothing here may relabel it. Home shows
    // "that folder is not inside a Git repository"; it must never show "an
    // unexpected error occurred".
    test('a folder outside any repository is passed through', () async {
      final Result<Space> result = await openingWith(
        const Failure<Space>(GitNotARepository('/loose')),
      )('/loose');

      expect(
        (result as Failure<Space>).failure,
        const GitNotARepository('/loose'),
      );
    });

    test('a folder that is gone is passed through', () async {
      final Result<Space> result = await openingWith(
        const Failure<Space>(SpaceFolderMissing('/gone')),
      )('/gone');

      expect(
        (result as Failure<Space>).failure,
        const SpaceFolderMissing('/gone'),
      );
    });

    test('and nothing is reported to observability', () async {
      // Reporting an expected failure would fill the log with the product
      // working correctly, and hide the one entry that mattered.
      await openingWith(const Failure<Space>(GitNotARepository('/loose')))(
        '/loose',
      );

      expect(observability.captured, isEmpty);
    });
  });

  group('an exception becomes a failure', () {
    test('it never escapes the use case', () async {
      final OpenSpace open = OpenSpace(
        spaces: _ThrowingSpaces(),
        recents: _Recents(),
        observability: observability,
      );

      final Result<Space> result = await open('/anywhere');

      expect(result, isA<Failure<Space>>());
      expect((result as Failure<Space>).failure, isA<UnexpectedFailure>());
    });

    test('and it is reported, tagged with the layer that caught it', () async {
      await OpenSpace(
        spaces: _ThrowingSpaces(),
        recents: _Recents(),
        observability: observability,
      )('/anywhere');

      expect(observability.captured, hasLength(1));
      expect(observability.captured.single.layer, 'application');
      expect(
        observability.captured.single.error.toString(),
        contains('the disk caught fire'),
      );
    });

    test('what it caught survives into the failure, as text', () async {
      final Result<Space> result = await OpenSpace(
        spaces: _ThrowingSpaces(),
        recents: _Recents(),
        observability: observability,
      )('/anywhere');

      expect(
        ((result as Failure<Space>).failure as UnexpectedFailure).description,
        contains('the disk caught fire'),
      );
    });
  });
}

/// A repository that answers what it was told to, and remembers the folder.
final class _Spaces implements SpaceRepository {
  _Spaces({required this.answer});

  final Result<Space> answer;
  String? asked;

  @override
  Future<Result<Space>> open(String folder) async {
    asked = folder;
    return answer;
  }

  @override
  Future<Result<List<SpaceEntry>>> entries(Space space) async =>
      throw UnimplementedError();
}

/// A repository that breaks its contract by throwing.
final class _ThrowingSpaces implements SpaceRepository {
  @override
  Future<Result<Space>> open(String folder) async =>
      throw StateError('the disk caught fire');

  @override
  Future<Result<List<SpaceEntry>>> entries(Space space) async =>
      throw UnimplementedError();
}

/// A recent list that keeps what it was told, in memory.
final class _Recents implements RecentSpacesRepository {
  final List<Space> remembered = <Space>[];
  final List<String> forgotten = <String>[];

  @override
  Future<Result<List<RecentSpace>>> list() async =>
      const Success<List<RecentSpace>>(<RecentSpace>[]);

  @override
  Future<Result<void>> remember(Space space) async {
    remembered.add(space);
    return const Success<void>(null);
  }

  @override
  Future<Result<void>> forget(String root) async {
    forgotten.add(root);
    return const Success<void>(null);
  }
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
