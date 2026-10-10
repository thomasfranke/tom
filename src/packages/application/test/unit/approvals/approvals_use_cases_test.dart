import 'package:test/test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  late _Approvals approvals;
  late _RecordingObservability observability;

  setUp(() {
    approvals = _Approvals();
    observability = _RecordingObservability();
  });

  test('reading is what the file allows, and cannot fail', () async {
    approvals.held = const ApprovalsValueObject(<String, bool>{
      'git fetch': true,
    });

    final ApprovalsValueObject read = await ReadApprovalsUseCase(
      approvals: approvals,
    ).read();

    expect(read.allows('git fetch'), isTrue);
    expect(read.allows('git push'), isFalse);
  });

  group('allowing a command', () {
    AllowCommandUseCase allowing() =>
        AllowCommandUseCase(approvals: approvals, observability: observability);

    test('writes true beside its key, and only that', () async {
      final Result<void, AppFailure> allowed = await allowing().allow(
        'git restore --staged -- <files>',
      );

      expect(allowed, isA<Success<void, AppFailure>>());
      expect(approvals.written, <(String, bool)>[
        ('git restore --staged -- <files>', true),
      ]);
    });

    test('a file that cannot be written is passed through', () async {
      approvals.refusal = const UnexpectedFailure('read-only disk');

      expect(
        (await allowing().allow('git push') as Failure<void, AppFailure>)
            .failure,
        const UnexpectedFailure('read-only disk'),
      );
      expect(observability.captured, isEmpty);
    });

    test('an exception becomes a failure, and is reported', () async {
      approvals.throws = true;

      expect(
        (await allowing().allow('git push') as Failure<void, AppFailure>)
            .failure,
        isA<UnexpectedFailure>(),
      );
      expect(observability.captured, hasLength(1));
    });
  });

  group('seeding the list', () {
    SeedApprovalsUseCase seeding() => SeedApprovalsUseCase(
      approvals: approvals,
      observability: observability,
    );

    test('asks the repository to list what is missing', () async {
      expect(await seeding().seed(), isA<Success<void, AppFailure>>());
      expect(approvals.seeded, 1);
    });

    test('an exception becomes a failure, and is reported', () async {
      approvals.throws = true;

      expect(await seeding().seed(), isA<Failure<void, AppFailure>>());
      expect(observability.captured, hasLength(1));
    });
  });
}

final class _Approvals implements ApprovalsRepository {
  ApprovalsValueObject held = ApprovalsValueObject.none;
  AppFailure? refusal;
  bool throws = false;
  int seeded = 0;
  final List<(String, bool)> written = <(String, bool)>[];

  @override
  Future<ApprovalsValueObject> read() async => held;

  @override
  Future<Result<void, AppFailure>> write(
    String key, {
    required bool allowed,
  }) async {
    if (throws) {
      throw StateError('the disk caught fire');
    }
    if (refusal case final AppFailure failure) {
      return Failure<void, AppFailure>(failure);
    }
    written.add((key, allowed));
    return const Success<void, AppFailure>(null);
  }

  @override
  Future<Result<void, AppFailure>> seed() async {
    if (throws) {
      throw StateError('the disk caught fire');
    }
    seeded++;
    return const Success<void, AppFailure>(null);
  }
}

final class _RecordingObservability implements Observability {
  final List<Object> captured = <Object>[];

  @override
  Future<void> capture(
    Object error,
    StackTrace stackTrace, {
    required String layer,
  }) async => captured.add(error);
}
