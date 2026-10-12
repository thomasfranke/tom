import 'package:test/test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  late _Observability observability;
  final RecentSpaceEntity recent = RecentSpaceEntity(
    root: '/work/docs',
    name: 'docs',
    lastOpened: DateTime.utc(2026, 10, 8),
  );

  setUp(() => observability = _Observability());

  test(
    'it asks about the row it was handed, and hands the branch back',
    () async {
      final _Branches branches = _Branches(BranchNameValueObject('feat/notes'));

      final Result<BranchNameValueObject?, AppFailure> read =
          await ReadRecentBranchUseCase(
            branches: branches,
            observability: observability,
          ).read(recent);

      expect(branches.asked, <RecentSpaceEntity>[recent]);
      expect(
        (read as Success<BranchNameValueObject?, AppFailure>).value,
        BranchNameValueObject('feat/notes'),
      );
    },
  );

  test('no branch is an answer, not a failure', () async {
    final Result<BranchNameValueObject?, AppFailure> read =
        await ReadRecentBranchUseCase(
          branches: _Branches(null),
          observability: observability,
        ).read(recent);

    expect((read as Success<BranchNameValueObject?, AppFailure>).value, isNull);
  });

  test('an exception becomes a failure, and is reported', () async {
    final Result<BranchNameValueObject?, AppFailure> read =
        await ReadRecentBranchUseCase(
          branches: _ThrowingBranches(),
          observability: observability,
        ).read(recent);

    expect(
      (read as Failure<BranchNameValueObject?, AppFailure>).failure,
      isA<UnexpectedFailure>(),
    );
    expect(observability.captured, hasLength(1));
  });
}

/// Answers [branch] for every row, remembering which it was asked about.
final class _Branches implements RecentBranchRepository {
  _Branches(this.branch);

  final BranchNameValueObject? branch;
  final List<RecentSpaceEntity> asked = <RecentSpaceEntity>[];

  @override
  Future<Result<BranchNameValueObject?, Never>> branchOf(
    RecentSpaceEntity recent,
  ) async {
    asked.add(recent);
    return Success<BranchNameValueObject?, Never>(branch);
  }
}

/// Breaks its contract by throwing, the only way left when [Never] says it
/// cannot return a failure.
final class _ThrowingBranches implements RecentBranchRepository {
  @override
  Future<Result<BranchNameValueObject?, Never>> branchOf(
    RecentSpaceEntity recent,
  ) => throw StateError('broken');
}

/// An [Observability] that remembers what it was handed.
final class _Observability implements Observability {
  final List<Object> captured = <Object>[];

  @override
  Future<void> capture(
    Object error,
    StackTrace stackTrace, {
    required String layer,
  }) async => captured.add(error);
}
