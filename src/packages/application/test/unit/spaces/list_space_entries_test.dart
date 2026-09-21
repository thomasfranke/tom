import 'package:test/test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  late _RecordingObservability observability;

  final Space docs = Space(
    root: '/code/app/docs',
    repositoryRoot: '/code/app',
    name: 'docs',
  );

  final List<SpaceEntry> held = <SpaceEntry>[
    SpaceEntry(
      path: SpaceRelativePath('guides'),
      type: SpaceEntryType.directory,
    ),
    SpaceEntry(
      path: SpaceRelativePath('guides/writing.md'),
      type: SpaceEntryType.file,
    ),
  ];

  setUp(() => observability = _RecordingObservability());

  /// The use case over a repository that answers [answer].
  ListSpaceEntries listingWith(Result<List<SpaceEntry>> answer) =>
      ListSpaceEntries(
        spaces: _Spaces(answer: answer),
        observability: observability,
      );

  test('it hands back what the space holds, in the order given', () async {
    // In order, because the order *is* the tree: a folder immediately
    // followed by what is inside it.
    final Result<List<SpaceEntry>> result = await listingWith(
      Success<List<SpaceEntry>>(held),
    )(docs);

    expect((result as Success<List<SpaceEntry>>).value, held);
  });

  test('the space it was asked about reaches the repository', () async {
    final _Spaces spaces = _Spaces(answer: Success<List<SpaceEntry>>(held));

    await ListSpaceEntries(spaces: spaces, observability: observability)(docs);

    expect(spaces.asked, docs);
  });

  group('an expected failure stays expected', () {
    test('a folder that is gone is passed through', () async {
      // The file tree shows this as its own line, and relabelling it would
      // put "an unexpected error occurred" on a screen where the product has
      // something specific to say.
      final Result<List<SpaceEntry>> result = await listingWith(
        const Failure<List<SpaceEntry>>(SpaceFolderMissing('/code/app/docs')),
      )(docs);

      expect(
        (result as Failure<List<SpaceEntry>>).failure,
        const SpaceFolderMissing('/code/app/docs'),
      );
    });

    test('and nothing is reported to observability', () async {
      await listingWith(
        const Failure<List<SpaceEntry>>(SpaceAccessDenied('/code/app/docs')),
      )(docs);

      expect(observability.captured, isEmpty);
    });
  });

  group('an exception becomes a failure', () {
    test('it never escapes the use case', () async {
      final Result<List<SpaceEntry>> result = await ListSpaceEntries(
        spaces: _ThrowingSpaces(),
        observability: observability,
      )(docs);

      expect(
        (result as Failure<List<SpaceEntry>>).failure,
        isA<UnexpectedFailure>(),
      );
    });

    test('and it is reported, tagged with the layer that caught it', () async {
      await ListSpaceEntries(
        spaces: _ThrowingSpaces(),
        observability: observability,
      )(docs);

      expect(observability.captured, hasLength(1));
      expect(observability.captured.single.layer, 'application');
      expect(
        observability.captured.single.error.toString(),
        contains('the disk caught fire'),
      );
    });
  });
}

/// A repository that answers what it was told to, and remembers the space.
final class _Spaces implements SpaceRepository {
  _Spaces({required this.answer});

  final Result<List<SpaceEntry>> answer;
  Space? asked;

  @override
  Future<Result<Space>> open(String folder) async => throw UnimplementedError();

  @override
  Future<Result<List<SpaceEntry>>> entries(Space space) async {
    asked = space;
    return answer;
  }
}

/// A repository that breaks its contract by throwing.
final class _ThrowingSpaces implements SpaceRepository {
  @override
  Future<Result<Space>> open(String folder) async => throw UnimplementedError();

  @override
  Future<Result<List<SpaceEntry>>> entries(Space space) async =>
      throw StateError('the disk caught fire');
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
