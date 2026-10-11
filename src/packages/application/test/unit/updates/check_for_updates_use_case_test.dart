import 'package:test/test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  final AppVersionValueObject running = AppVersionValueObject.tryParse(
    '1.0.0',
  )!;

  Future<Result<UpdateAnswerValueObject, AppFailure>> check(
    Result<ReleaseValueObject?, UpdateFailure> latest,
  ) => CheckForUpdatesUseCase(
    updates: _Updates(latest),
    observability: const _Silent(),
  ).check(running);

  ReleaseValueObject release(String tag) => ReleaseValueObject(
    version: AppVersionValueObject.tryParse(tag)!,
    notesUrl: 'https://example.com/$tag',
  );

  UpdateAnswerValueObject value(
    Result<UpdateAnswerValueObject, AppFailure> r,
  ) => (r as Success<UpdateAnswerValueObject, AppFailure>).value;

  test('nothing published', () async {
    expect(
      value(
        await check(const Success<ReleaseValueObject?, UpdateFailure>(null)),
      ),
      isA<UpdateNoRelease>(),
    );
  });

  test('the same release is up to date', () async {
    expect(
      value(
        await check(
          Success<ReleaseValueObject?, UpdateFailure>(release('v1.0.0')),
        ),
      ),
      isA<UpdateUpToDate>(),
    );
  });

  test('an older release is up to date too', () async {
    expect(
      value(
        await check(
          Success<ReleaseValueObject?, UpdateFailure>(release('v0.9.0')),
        ),
      ),
      isA<UpdateUpToDate>(),
    );
  });

  test('a newer release is named', () async {
    final UpdateAnswerValueObject got = value(
      await check(
        Success<ReleaseValueObject?, UpdateFailure>(release('v1.1.0')),
      ),
    );

    expect((got as UpdateNewer).release.version.text, '1.1.0');
  });

  test('a host that did not answer is a failure', () async {
    expect(
      await check(
        const Failure<ReleaseValueObject?, UpdateFailure>(
          UpdateFailure.unreachable(),
        ),
      ),
      isA<Failure<UpdateAnswerValueObject, AppFailure>>(),
    );
  });
}

final class _Updates implements UpdatesRepository {
  const _Updates(this.answer);

  final Result<ReleaseValueObject?, UpdateFailure> answer;

  @override
  Future<Result<ReleaseValueObject?, UpdateFailure>> latest() async => answer;
}

final class _Silent implements Observability {
  const _Silent();

  @override
  Future<void> capture(
    Object error,
    StackTrace stackTrace, {
    required String layer,
  }) async {}
}
