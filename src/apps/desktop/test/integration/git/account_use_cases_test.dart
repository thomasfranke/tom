/// The account a repository acts as, read and chosen through the
/// composition root over real git configuration and a `gh` that is a script
/// ([Decision 35](../../../../../../docs/technical/decisions/035-github-is-reached-through-the-gh-cli.md)).
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';

import '../support/real_remote_stack.dart';

void main() {
  late RealRemoteStack stack;

  const GithubAccountValueObject ada = GithubAccountValueObject(
    login: 'ada',
    source: AccountSourceEnum.gh,
  );
  const GithubAccountValueObject hopper = GithubAccountValueObject(
    login: 'hopper',
    source: AccountSourceEnum.gh,
  );

  setUp(() => stack = RealRemoteStack.create());

  Future<void> choose(
    GithubAccountValueObject account, [
    SpaceEntity? space,
  ]) async {
    final Result<void, AppFailure> chosen = await stack.container
        .read(chooseAccountProvider)
        .choose(space ?? stack.space, account);
    expect(chosen, isA<Success<void, AppFailure>>());
  }

  Future<AccountSummaryValueObject> read(SpaceEntity? space) async =>
      (await stack.container.read(readAccountProvider).read(space))
          .valueOrNull!;

  /// What the clone's own configuration holds for the choice.
  String chosen({String? inside}) => stack
      .git(
        <String>['config', '--local', '--get', 'tom.githubAccount'],
        inside: inside,
        allowFailure: true,
      )
      .trim();

  void githubRemote() => stack.git(<String>[
    'remote',
    'set-url',
    'origin',
    'git@github.com:acme/docs.git',
  ]);

  group('choosing the account of a repository', () {
    test('writes the login into the repository\'s own configuration, from '
        'a space below its root', () async {
      await choose(hopper);

      expect(chosen(), 'hopper');
      expect(
        stack.git(<String>['config', '--global', '--list'], allowFailure: true),
        isNot(contains('tom.githubaccount')),
        reason: 'the machine\'s configuration is never written',
      );
    });

    test('choosing again replaces it, and leaves one value', () async {
      await choose(hopper);
      await choose(ada);

      expect(chosen(), 'ada');
      expect(
        stack
            .git(<String>[
              'config',
              '--local',
              '--get-all',
              'tom.githubAccount',
            ])
            .trim()
            .split('\n'),
        <String>['ada'],
      );
    });

    test('is the same choice from a worktree, which shares the '
        'configuration', () async {
      final String worktree = '${stack.root}/work/wt';
      stack.git(<String>[
        'worktree',
        'add',
        '--quiet',
        '-b',
        'feat/wt',
        worktree,
      ]);
      await choose(
        hopper,
        SpaceEntity(
          root: '$worktree/docs',
          repositoryRoot: worktree,
          name: 'docs',
        ),
      );

      expect(chosen(), 'hopper');
    });

    test('a folder git does not know cannot hold one', () async {
      final Result<void, AppFailure> chosen = await stack.container
          .read(chooseAccountProvider)
          .choose(
            SpaceEntity(
              root: '${stack.root}/plain',
              repositoryRoot: '${stack.root}/plain',
              name: 'plain',
            ),
            hopper,
          );

      expect(chosen, isA<Failure<void, AppFailure>>());
    });
  });

  group('reading the account of a repository', () {
    test('without a GitHub remote it knows who commits and nothing '
        'about a project', () async {
      stack.installGh();

      final AccountSummaryValueObject summary = await read(stack.space);

      expect(summary.identity.name, 'Test');
      expect(summary.identity.email, 'test@example.com');
      expect(summary.project, isNull);
      expect(summary.access, isNull);
    });

    test('with a GitHub remote it knows the project, the accounts and '
        'the first that can push', () async {
      githubRemote();
      stack.installGh(
        logins: <String>['ada', 'hopper'],
        pushers: <String>['hopper'],
      );

      final AccountSummaryValueObject summary = await read(stack.space);

      expect(summary.project?.label, 'github.com/acme/docs');
      expect(
        summary.accounts.map((GithubAccountValueObject it) => it.login),
        <String>['ada', 'hopper'],
      );
      expect(summary.chosen?.login, 'hopper');
      expect(summary.access?.canPush, isTrue);
    });

    test('a recorded choice wins over the one that can push', () async {
      githubRemote();
      stack.installGh(
        logins: <String>['ada', 'hopper'],
        pushers: <String>['hopper'],
      );
      await choose(ada);

      final AccountSummaryValueObject summary = await read(stack.space);

      expect(summary.chosen?.login, 'ada');
      expect(summary.access?.canPush, isFalse);
      expect(summary.access?.canRead, isTrue);
    });

    test('a recorded login the machine no longer holds falls back to '
        'what it does hold', () async {
      githubRemote();
      stack.installGh(logins: <String>['hopper'], pushers: <String>['hopper']);
      await choose(ada);

      final AccountSummaryValueObject summary = await read(stack.space);

      expect(summary.chosen?.login, 'hopper');
      expect(chosen(), 'ada', reason: 'reading never rewrites the choice');
    });

    test('with no gh on the machine there are no accounts and no '
        'choice', () async {
      githubRemote();

      final AccountSummaryValueObject summary = await read(stack.space);

      expect(summary.accounts, isEmpty);
      expect(summary.chosen, isNull);
      expect(summary.identity.name, 'Test');
    });

    test('a login git\'s credential helper holds is an account too, and '
        'its password never reaches the commands panel', () async {
      githubRemote();
      stack
        ..installGh(logins: <String>[])
        ..git(<String>[
          'config',
          'credential.helper',
          '!f() { echo username=ghbot; echo password=s3cret-pass; }; f',
        ]);

      final AccountSummaryValueObject summary = await read(stack.space);

      expect(summary.accounts, const <GithubAccountValueObject>[
        GithubAccountValueObject(login: 'ghbot', source: AccountSourceEnum.git),
      ]);
      final String panel = stack.container
          .read(commandsProvider)
          .rows
          .map(
            (CommandRow it) => '${it.record.commandLine}\n${it.record.output}',
          )
          .join('\n');
      expect(panel, contains('credential'));
      expect(panel, isNot(contains('s3cret-pass')));
    });

    test('with no space it reads the machine: the global identity and the '
        'accounts, no project', () async {
      stack
        ..git(<String>['config', '--global', 'user.name', 'Machine Ada'])
        ..git(<String>['config', '--global', 'user.email', 'ada@machine'])
        ..installGh(logins: <String>['ada', 'hopper']);

      final AccountSummaryValueObject summary = await read(null);

      expect(summary.identity.name, 'Machine Ada');
      expect(summary.identity.email, 'ada@machine');
      expect(summary.project, isNull);
      expect(
        summary.accounts.map((GithubAccountValueObject it) => it.login),
        <String>['ada', 'hopper'],
      );
    });

    test('a machine with no identity at all is incomplete, not a '
        'failure', () async {
      final AccountSummaryValueObject summary = await read(null);

      expect(summary.identity.isIncomplete, isTrue);
    });
  });
}
