import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_infra/tom_infra.dart';

void main() {
  Future<Result<ReleaseValueObject?, UpdateFailure>> ask(
    Result<String?, AppUpdatesFailure> answer,
  ) => UpdatesRepositoryImpl(updates: _Updates(answer)).latest();

  test('a release is its version and its page', () async {
    final Result<ReleaseValueObject?, UpdateFailure> got = await ask(
      const Success<String?, AppUpdatesFailure>(
        '{"tag_name":"v1.4.0","html_url":"https://example.com/r"}',
      ),
    );

    final ReleaseValueObject release =
        (got as Success<ReleaseValueObject?, UpdateFailure>).value!;
    expect(release.version.text, '1.4.0');
    expect(release.notesUrl, 'https://example.com/r');
  });

  test('nothing published is null', () async {
    final Result<ReleaseValueObject?, UpdateFailure> got = await ask(
      const Success<String?, AppUpdatesFailure>(null),
    );

    expect((got as Success<ReleaseValueObject?, UpdateFailure>).value, isNull);
  });

  test('an answer with no readable tag is nothing published', () async {
    for (final String body in <String>['not json', '[]', '{"tag_name":"x"}']) {
      final Result<ReleaseValueObject?, UpdateFailure> got = await ask(
        Success<String?, AppUpdatesFailure>(body),
      );
      expect(
        (got as Success<ReleaseValueObject?, UpdateFailure>).value,
        isNull,
        reason: body,
      );
    }
  });

  test('a host that did not answer is unreachable', () async {
    final Result<ReleaseValueObject?, UpdateFailure> got = await ask(
      const Failure<String?, AppUpdatesFailure>(
        AppUpdatesFailure.unreachable('offline'),
      ),
    );

    expect(
      (got as Failure<ReleaseValueObject?, UpdateFailure>).failure,
      isA<UpdateUnreachable>(),
    );
  });
}

final class _Updates implements AppUpdates {
  const _Updates(this.answer);

  final Result<String?, AppUpdatesFailure> answer;

  @override
  Future<Result<String?, AppUpdatesFailure>> latest() async => answer;
}
