/// The composition root's git wiring over a real repository: one client per
/// folder, kept, so every use case's commands share one queue
/// (`docs/technical/runtime/git.md`).
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_desktop/bootstrap/providers.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_infra/tom_infra.dart';
import 'package:tom_presentation/tom_presentation.dart';

import '../support/real_stack.dart';

void main() {
  late RealStack stack;

  setUp(() => stack = RealStack.create()..commitBase('# Guide\n'));

  test('a folder is given the same client every time it is asked for', () {
    final GitClientFor clients = stack.container.read(gitClientForProvider);

    expect(
      clients(stack.repository),
      same(clients(stack.repository)),
      reason: 'a client per call is a queue per call',
    );
  });

  test(
    'git is asked its version once, however many spaces are opened',
    () async {
      final SpaceRepository spaces = stack.container.read(
        spaceRepositoryProvider,
      );

      await spaces.open('${stack.repository}/docs');
      await spaces.open(stack.repository);
      await spaces.open('${stack.repository}/docs');

      expect(
        stack.container
            .read(commandsProvider)
            .rows
            .where(
              (CommandRow row) => row.record.commandLine == 'git --version',
            ),
        hasLength(1),
      );
    },
  );

  test('two folders are two clients', () {
    final GitClientFor clients = stack.container.read(gitClientForProvider);

    expect(
      clients(stack.repository),
      isNot(same(clients('${stack.repository}/docs'))),
    );
  });

  // What the queue is for: `git add` takes `index.lock`, and two of them
  // started together collide. Each write here asks for the repository
  // afresh, the way each use case does.
  test('writes started together through separate asks all land', () async {
    final GitRepositoryFor gitFor = stack.container.read(
      gitRepositoryForProvider,
    );
    final List<RepoRelativePathValueObject> files =
        <RepoRelativePathValueObject>[
          for (int number = 0; number < 24; number++)
            RepoRelativePathValueObject('docs/new-$number.md'),
        ];
    for (final RepoRelativePathValueObject file in files) {
      stack.write(file.value, '# ${file.value}\n' * 200);
    }

    final List<Result<void, GitFailure>> results = await Future.wait(
      <Future<Result<void, GitFailure>>>[
        for (final RepoRelativePathValueObject file in files)
          gitFor(stack.space).stage(<RepoRelativePathValueObject>[file]),
      ],
    );

    expect(
      results.whereType<Failure<void, GitFailure>>().map(
        (Failure<void, GitFailure> it) => it.failure.cause,
      ),
      isEmpty,
      reason: 'a write lost a race for the index',
    );
    expect(stack.staged, hasLength(files.length));
  });
}
