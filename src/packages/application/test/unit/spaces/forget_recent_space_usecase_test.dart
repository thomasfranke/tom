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

  ForgetRecentSpaceUseCase forgetting() =>
      ForgetRecentSpaceUseCase(recents: recents, observability: observability);

  test('it names the folder, and touches nothing else', () async {
    // Forgetting is about the list. A space TOM forgets is a space the user
    // can still open by picking it again.
    await forgetting().forget('/a');

    expect(recents.forgotten, <String>['/a']);
  });

  test('an exception becomes a failure, and is reported', () async {
    final Result<void, AppFailure> result = await ForgetRecentSpaceUseCase(
      recents: _ThrowingRecents(),
      observability: observability,
    ).forget('/a');

    expect(
      (result as Failure<void, AppFailure>).failure,
      isA<UnexpectedFailure>(),
    );
    expect(observability.captured, hasLength(1));
  });
}

/// A recent list that records what it was asked to forget.
final class _Recents implements RecentSpacesRepository {
  final List<String> forgotten = <String>[];

  @override
  Future<Result<List<RecentSpaceEntity>, Never>> list() async =>
      const Success<List<RecentSpaceEntity>, Never>(<RecentSpaceEntity>[]);

  @override
  Future<Result<void, Never>> remember(SpaceEntity space) async =>
      const Success<void, Never>(null);

  @override
  Future<Result<void, Never>> forget(String root) async {
    forgotten.add(root);
    return const Success<void, Never>(null);
  }
}

/// A repository that breaks its contract by throwing.
///
/// [Never] says it cannot *return* a failure, which is exactly why throwing is
/// the only way left to break it — and what the use case's guard is for.
final class _ThrowingRecents implements RecentSpacesRepository {
  @override
  Future<Result<List<RecentSpaceEntity>, Never>> list() async =>
      const Success<List<RecentSpaceEntity>, Never>(<RecentSpaceEntity>[]);

  @override
  Future<Result<void, Never>> remember(SpaceEntity space) async =>
      const Success<void, Never>(null);

  @override
  Future<Result<void, Never>> forget(String root) async =>
      throw StateError('the preferences file is a directory');
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
