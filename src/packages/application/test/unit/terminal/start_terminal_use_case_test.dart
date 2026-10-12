/// [StartTerminalUseCase]: the shell opens at the repository's root, and
/// nothing thrown gets past it.
library;

import 'package:test/test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  late _Terminals terminals;
  late _Recording observability;
  late StartTerminalUseCase useCase;

  const TerminalSizeValueObject size = TerminalSizeValueObject(
    columns: 80,
    rows: 24,
  );

  setUp(() {
    terminals = _Terminals();
    observability = _Recording();
    useCase = StartTerminalUseCase(
      terminals: terminals,
      observability: observability,
    );
  });

  test('opens at the repository root, not at the space', () async {
    await useCase.start(
      SpaceEntity(
        root: '/code/app/docs',
        repositoryRoot: '/code/app',
        name: 'docs',
      ),
      size,
    );

    expect(terminals.asked, <String>['/code/app']);
  });

  test('opens at the space itself when it has no repository', () async {
    await useCase.start(
      SpaceEntity(root: '/notes', repositoryRoot: null, name: 'notes'),
      size,
    );

    expect(terminals.asked, <String>['/notes']);
  });

  test('a refusal is passed through, not reported', () async {
    terminals.answer = const Failure<TerminalSessionPort, AppFailure>(
      UnexpectedFailure('no pty'),
    );

    final Result<TerminalSessionPort, AppFailure> result = await useCase.start(
      SpaceEntity(root: '/code', repositoryRoot: '/code', name: 'code'),
      size,
    );

    expect(result, isA<Failure<TerminalSessionPort, AppFailure>>());
    expect(observability.captured, isEmpty);
  });

  test('a throw becomes an unexpected failure, and is reported', () async {
    terminals.throws = true;

    final Result<TerminalSessionPort, AppFailure> result = await useCase.start(
      SpaceEntity(root: '/code', repositoryRoot: '/code', name: 'code'),
      size,
    );

    expect(
      result,
      isA<Failure<TerminalSessionPort, AppFailure>>().having(
        (Failure<TerminalSessionPort, AppFailure> it) => it.failure,
        'failure',
        isA<UnexpectedFailure>(),
      ),
    );
    expect(observability.captured, hasLength(1));
  });
}

final class _Terminals implements TerminalRepository {
  final List<String> asked = <String>[];
  Result<TerminalSessionPort, AppFailure>? answer;
  bool throws = false;

  @override
  Future<Result<TerminalSessionPort, AppFailure>> start(
    String folder,
    TerminalSizeValueObject size,
  ) async {
    asked.add(folder);
    if (throws) {
      throw StateError('the pty broke');
    }
    return answer ??
        const Failure<TerminalSessionPort, AppFailure>(
          UnexpectedFailure('nothing behind this fake'),
        );
  }
}

final class _Recording implements Observability {
  final List<Object> captured = <Object>[];

  @override
  Future<void> capture(
    Object error,
    StackTrace stackTrace, {
    required String layer,
  }) async => captured.add(error);
}
