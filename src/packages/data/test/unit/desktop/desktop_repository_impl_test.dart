/// [DesktopRepositoryImpl] over a shell that records what it is asked.
library;

import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_infra/tom_infra.dart';

void main() {
  late _Shell shell;
  late DesktopRepositoryImpl repository;

  setUp(() {
    shell = _Shell();
    repository = DesktopRepositoryImpl(source: DesktopDataSource(shell: shell));
  });

  test('each request reaches the shell with what was asked', () async {
    await repository.reveal('/code/docs');
    await repository.openTerminal('/code');
    await repository.openUrl(Uri.parse('https://example.com/a'));

    expect(shell.asked, <String>[
      'reveal /code/docs',
      'terminal /code',
      'url https://example.com/a',
    ]);
  });

  test('a shell that did it is a success', () async {
    expect(await repository.reveal('/code'), isA<Success<void, AppFailure>>());
    expect(
      await repository.openTerminal('/code'),
      isA<Success<void, AppFailure>>(),
    );
    expect(
      await repository.openUrl(Uri.parse('https://example.com')),
      isA<Success<void, AppFailure>>(),
    );
  });

  test('the capability failure passes through, one per request', () async {
    shell.failure = const DesktopShellUnavailable('xdg-open');

    for (final Result<void, AppFailure> result in <Result<void, AppFailure>>[
      await repository.reveal('/code'),
      await repository.openTerminal('/code'),
      await repository.openUrl(Uri.parse('https://example.com')),
    ]) {
      expect(
        (result as Failure<void, AppFailure>).failure,
        isA<DesktopShellUnavailable>(),
      );
    }
  });
}

final class _Shell implements DesktopShell {
  DesktopShellFailure? failure;
  final List<String> asked = <String>[];

  Result<void, DesktopShellFailure> _answer() {
    final DesktopShellFailure? refused = failure;
    return refused == null
        ? const Success<void, DesktopShellFailure>(null)
        : Failure<void, DesktopShellFailure>(refused);
  }

  @override
  Future<Result<void, DesktopShellFailure>> reveal(String folder) async {
    asked.add('reveal $folder');
    return _answer();
  }

  @override
  Future<Result<void, DesktopShellFailure>> openTerminal(String folder) async {
    asked.add('terminal $folder');
    return _answer();
  }

  @override
  Future<Result<void, DesktopShellFailure>> openUrl(Uri address) async {
    asked.add('url $address');
    return _answer();
  }
}
