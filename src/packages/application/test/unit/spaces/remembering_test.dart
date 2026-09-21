/// What opening a space records, and what it refuses to let that cost.
library;

import 'package:test/test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  late _Recents recents;
  late _Observability observability;

  final Space opened = Space(
    root: '/code/app/docs',
    repositoryRoot: '/code/app',
    name: 'docs',
  );

  setUp(() {
    recents = _Recents();
    observability = _Observability();
  });

  OpenSpace openingWith(Result<Space> answer) => OpenSpace(
    spaces: _Spaces(answer: answer),
    recents: recents,
    observability: observability,
  );

  group('what gets remembered', () {
    test('a space that opened', () async {
      await openingWith(Success<Space>(opened))('/code/app/docs');

      expect(recents.remembered, <Space>[opened]);
    });

    test(
      'a folder that is not a repository is not a place to return to',
      () async {
        await openingWith(const Failure<Space>(GitNotARepository('/loose')))(
          '/loose',
        );

        expect(recents.remembered, isEmpty);
      },
    );

    test('nor is a folder that is gone', () async {
      await openingWith(const Failure<Space>(SpaceFolderMissing('/gone')))(
        '/gone',
      );

      expect(recents.remembered, isEmpty);
    });
  });

  group('when the list cannot be written', () {
    test('the space still opens', () async {
      // A preferences file that cannot be written is not a reason to refuse
      // a session. Everything the recent list holds is a convenience.
      recents.breaks = true;

      final Result<Space> result = await openingWith(Success<Space>(opened))(
        '/code/app/docs',
      );

      expect(result, isA<Success<Space>>());
      expect((result as Success<Space>).value, opened);
    });

    test('and nothing is reported as unexpected', () async {
      // The repository reports rather than throws, so the use case's
      // try/catch must never see it — an entry in the log here would be the
      // product working correctly.
      recents.breaks = true;

      await openingWith(Success<Space>(opened))('/code/app/docs');

      expect(observability.captured, isEmpty);
    });
  });

  group('listing and forgetting', () {
    test('the list comes back as the repository ordered it', () async {
      recents.stored = <RecentSpace>[
        RecentSpace(
          root: '/b',
          name: 'b',
          lastOpened: DateTime.utc(2026, 9, 2),
        ),
        RecentSpace(root: '/a', name: 'a', lastOpened: DateTime.utc(2026, 9)),
      ];

      final Result<List<RecentSpace>> result = await ListRecentSpaces(
        recents: recents,
        observability: observability,
      )();

      expect(
        (result as Success<List<RecentSpace>>).value.map(
          (RecentSpace recent) => recent.root,
        ),
        <String>['/b', '/a'],
      );
    });

    test('forgetting names the folder, and touches nothing else', () async {
      await ForgetRecentSpace(recents: recents, observability: observability)(
        '/a',
      );

      expect(recents.forgotten, <String>['/a']);
    });
  });
}

/// A repository that answers what it was told to.
final class _Spaces implements SpaceRepository {
  const _Spaces({required this.answer});

  final Result<Space> answer;

  @override
  Future<Result<Space>> open(String folder) async => answer;

  @override
  Future<Result<List<SpaceEntry>>> entries(Space space) async =>
      throw UnimplementedError();
}

/// A recent list that records what it was asked, and can be made to fail.
final class _Recents implements RecentSpacesRepository {
  final List<Space> remembered = <Space>[];
  final List<String> forgotten = <String>[];
  List<RecentSpace> stored = <RecentSpace>[];

  /// Whether the store underneath is broken.
  ///
  /// It still reports success, because that is what the contract says this
  /// repository does — what a broken store costs is the list, not the
  /// session.
  bool breaks = false;

  @override
  Future<Result<List<RecentSpace>>> list() async =>
      Success<List<RecentSpace>>(breaks ? <RecentSpace>[] : stored);

  @override
  Future<Result<void>> remember(Space space) async {
    if (!breaks) {
      remembered.add(space);
    }
    return const Success<void>(null);
  }

  @override
  Future<Result<void>> forget(String root) async {
    forgotten.add(root);
    return const Success<void>(null);
  }
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
