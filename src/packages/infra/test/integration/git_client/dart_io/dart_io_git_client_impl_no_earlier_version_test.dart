/// [DartIoGitClientImpl] asked for a path `HEAD` does not hold: the answer is
/// "no earlier version", typed, and its row in the Commands panel is an
/// answer rather than a failure (defect 10.1).
///
/// Git runs under [GitWorld]'s empty configuration (decision T5).
library;

// Arranging a repository is a run of statements on one world.
// ignore_for_file: cascade_invocations

import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_infra/tom_infra.dart';

import '../../../support/git_remote_world.dart';
import '../../../support/git_world.dart';

void main() {
  late GitWorld world;
  late KeptCommandLog log;

  setUp(() {
    world = GitWorld()..seed();
    log = KeptCommandLog();
  });

  tearDown(() => world.dispose());

  DartIoGitClientImpl clientIn(String folder) => DartIoGitClientImpl(
    workingDirectory: folder,
    executable: world.executable,
    commandLog: log,
  );

  /// The one `git show` the test made, which must not have drawn red.
  void expectAnAnswer() {
    final List<CommandRecord> shows = log.records
        .where((CommandRecord r) => r.arguments.contains('show'))
        .toList();
    expect(shows, isNotEmpty);
    for (final CommandRecord record in shows) {
      expect(record.failed, isFalse, reason: record.output);
      expect(record.answered, isTrue, reason: 'a non-zero exit as an answer');
    }
    expect(log.records.where((CommandRecord r) => r.failed), isEmpty);
  }

  Future<void> expectNoEarlierVersion(
    DartIoGitClientImpl client,
    String path,
  ) async {
    expect(
      failureOf(await client.show('HEAD', path)),
      isA<GitClientPathNotInRevision>(),
    );
    expect(
      failureOf(await client.showBytes('HEAD', path)),
      isA<GitClientPathNotInRevision>(),
    );
    expectAnAnswer();
  }

  test('a new file git was never told about', () async {
    world.write('new.md', '# New\n');

    await expectNoEarlierVersion(clientIn(world.repo), 'new.md');
  });

  test('a new file that is staged', () async {
    world.write('new.md', '# New\n');
    world.git(<String>['add', 'new.md']);

    await expectNoEarlierVersion(clientIn(world.repo), 'new.md');
  });

  test('a file added and then edited again', () async {
    world.write('new.md', '# New\n');
    world.git(<String>['add', 'new.md']);
    world.write('new.md', '# New, edited\n');

    await expectNoEarlierVersion(clientIn(world.repo), 'new.md');
  });

  test('the new name of a renamed file', () async {
    world.git(<String>['mv', 'a.md', 'renamed.md']);

    await expectNoEarlierVersion(clientIn(world.repo), 'renamed.md');
  });

  test('a new file in a space below the repository root', () async {
    world.commitFile('docs/old.md', '# Old\n');
    world.write('docs/new.md', '# New\n');

    // The client runs in the space's folder; `rev:path` is from the top.
    await expectNoEarlierVersion(clientIn('${world.repo}/docs'), 'docs/new.md');
  });

  test('a path git cannot resolve at all is still a red row', () async {
    final DartIoGitClientImpl client = clientIn(world.repo);

    final GitClientFailure failure = failureOf(
      await client.show('no-such-branch', 'a.md'),
    );

    expect(failure, isNot(isA<GitClientPathNotInRevision>()));
    expect(log.records.where((CommandRecord r) => r.failed), hasLength(1));
  });
}
