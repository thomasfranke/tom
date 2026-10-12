/// [RevealFolderUseCase] and [OpenTerminalUseCase]: one call each, through
/// the desktop, with nothing thrown past them.
library;

import 'package:test/test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  late _Desktop desktop;
  late _Recording observability;

  setUp(() {
    desktop = _Desktop();
    observability = _Recording();
  });

  test('revealing hands the folder to the file manager', () async {
    await RevealFolderUseCase(
      desktop: desktop,
      observability: observability,
    ).reveal('/code/app/docs');

    expect(desktop.asked, <String>['reveal /code/app/docs']);
  });

  test('a terminal is opened in the folder asked for', () async {
    await OpenTerminalUseCase(
      desktop: desktop,
      observability: observability,
    ).open('/code/app');

    expect(desktop.asked, <String>['terminal /code/app']);
  });

  test('a refusal is passed through, not reported', () async {
    desktop.answer = const Failure<void, AppFailure>(UnexpectedFailure('no'));

    final Result<void, AppFailure> result = await RevealFolderUseCase(
      desktop: desktop,
      observability: observability,
    ).reveal('/code');

    expect(result, isA<Failure<void, AppFailure>>());
    expect(observability.captured, isEmpty);
  });

  test('an exception never escapes, and is reported', () async {
    desktop.throws = true;

    final Result<void, AppFailure> result = await OpenTerminalUseCase(
      desktop: desktop,
      observability: observability,
    ).open('/code');

    expect(
      (result as Failure<void, AppFailure>).failure,
      isA<UnexpectedFailure>(),
    );
    expect(observability.captured, hasLength(1));
  });
}

/// A desktop that remembers what it was asked and answers as told.
final class _Desktop implements DesktopRepository {
  Result<void, AppFailure> answer = const Success<void, AppFailure>(null);
  bool throws = false;
  final List<String> asked = <String>[];

  Result<void, AppFailure> _done(String what) {
    if (throws) {
      throw StateError('the desktop fell over');
    }
    asked.add(what);
    return answer;
  }

  @override
  Future<Result<void, AppFailure>> reveal(String folder) async =>
      _done('reveal $folder');

  @override
  Future<Result<void, AppFailure>> openTerminal(String folder) async =>
      _done('terminal $folder');

  @override
  Future<Result<void, AppFailure>> openUrl(Uri address) async =>
      _done('url $address');
}

/// An [Observability] that keeps what it was handed.
final class _Recording implements Observability {
  final List<Object> captured = <Object>[];

  @override
  Future<void> capture(
    Object error,
    StackTrace stackTrace, {
    required String layer,
  }) async => captured.add(error);
}
