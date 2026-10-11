/// The account button's notifier, over the real use cases and recorded
/// repositories.
library;

import 'dart:async';

import 'package:riverpod/misc.dart';
import 'package:riverpod/riverpod.dart';
import 'package:test/test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_presentation/tom_presentation.dart';

void main() {
  late _Git git;
  late _Accounts github;
  late _Git machine;
  late _Accounts machineAccounts;
  late _Desktop desktop;
  late ProviderContainer container;

  final SpaceEntity docs = SpaceEntity(
    root: '/code/app/docs',
    repositoryRoot: '/code/app',
    name: 'docs',
  );
  const GithubAccountValueObject ada = GithubAccountValueObject(
    login: 'ada',
    source: AccountSourceEnum.gh,
  );
  const GithubAccountValueObject linus = GithubAccountValueObject(
    login: 'linus',
    source: AccountSourceEnum.ssh,
  );

  setUp(() {
    git = _Git();
    github = _Accounts();
    machine = _Git()..name = 'Ada at home';
    machineAccounts = _Accounts();
    desktop = _Desktop();
    const Observability silent = _Silent();
    container = ProviderContainer(
      overrides: <Override>[
        readAccountProvider.overrideWithValue(
          ReadAccountUseCase(
            gitFor: (SpaceEntity _) => git,
            accountsFor: (SpaceEntity _) => github,
            machineGit: machine,
            machineAccounts: machineAccounts,
            observability: silent,
          ),
        ),
        chooseAccountProvider.overrideWithValue(
          ChooseAccountUseCase(
            gitFor: (SpaceEntity _) => git,
            observability: silent,
          ),
        ),
        openUrlProvider.overrideWithValue(
          OpenUrlUseCase(desktop: desktop, observability: silent),
        ),
      ],
    );
    addTearDown(container.dispose);
  });

  Future<void> settle() async {
    for (int i = 0; i < 8; i++) {
      await Future<void>.delayed(Duration.zero);
    }
  }

  Future<AccountState> openSpace() async {
    container
      ..listen<AccountState>(accountProvider, (_, _) {})
      ..read(spaceSessionProvider.notifier).open(docs);
    await settle();
    return container.read(accountProvider);
  }

  group('where git asks first', () {
    test('Manual: Home alone reads nothing and says it is not read yet; '
        'opening the popover reads', () async {
      container.dispose();
      container = ProviderContainer(
        overrides: <Override>[
          preferencesProvider.overrideWith(
            () => _Prefs(GitApprovalModeEnum.manual),
          ),
          readAccountProvider.overrideWithValue(
            ReadAccountUseCase(
              gitFor: (SpaceEntity _) => git,
              accountsFor: (SpaceEntity _) => github,
              machineGit: machine,
              machineAccounts: machineAccounts,
              observability: const _Silent(),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);
      container
        ..listen<PreferencesValueObject>(preferencesProvider, (_, _) {})
        ..listen<AccountState>(accountProvider, (_, _) {});
      await settle();

      expect(container.read(accountProvider).isUnread, isTrue);
      expect(container.read(accountProvider).summary, isNull);
      expect(machine.identityReads, 0, reason: 'Home asked git by itself');

      await container.read(accountProvider.notifier).readIfUnread();

      expect(container.read(accountProvider).isUnread, isFalse);
      expect(container.read(accountProvider).summary?.identity.name, isNotNull);
    });
  });

  test("with no space open, the machine's own is read — Home's", () async {
    container.listen<AccountState>(accountProvider, (_, _) {});
    await settle();

    final AccountState state = container.read(accountProvider);
    expect(state.summary?.identity.name, 'Ada at home');
    expect(state.summary?.project, isNull);
    expect(git.identityReads, 0);
  });

  test(
    'opening a space reads it: nothing on the machine, nothing known',
    () async {
      final AccountState state = await openSpace();

      expect(state.isReading, isFalse);
      expect(state.summary?.identity.name, 'Ada Lovelace');
      expect(state.summary?.chosen, isNull);
      expect(state.summary?.access, isNull);
      expect(state.summary?.project?.label, 'github.com/acme/docs');
    },
  );

  test("while GitHub is asked, git's half is known and nothing else", () async {
    github.gate = Completer<void>();
    final AccountState asking = await openSpace();

    expect(asking.isAsking, isTrue);
    expect(asking.summary, isNull);
    expect(asking.known?.identity.name, 'Ada Lovelace');
    expect(asking.known?.project?.label, 'github.com/acme/docs');
    expect(asking.initials, 'AL');

    github.gate!.complete();
    await settle();

    final AccountState answered = container.read(accountProvider);
    expect(answered.isAsking, isFalse);
    expect(answered.summary?.identity.name, 'Ada Lovelace');
    // Git's half was not asked twice.
    expect(git.identityReads, 1);
  });

  test('a later reading keeps the last answer on screen', () async {
    github.accounts_ = <GithubAccountValueObject>[ada];
    await openSpace();
    github.gate = Completer<void>();

    final Future<void> reloading = container
        .read(accountProvider.notifier)
        .reload();
    await settle();

    final AccountState state = container.read(accountProvider);
    expect(state.isReading, isTrue);
    expect(state.isAsking, isFalse);
    expect(state.known?.chosen, ada);

    github.gate!.complete();
    await reloading;
  });

  test('the button wears the initials of the name git commits as', () async {
    expect((await openSpace()).initials, 'AL');
  });

  test(
    'without a name, the first letter of the login; without both, none',
    () async {
      git.name = null;
      github.accounts_ = <GithubAccountValueObject>[linus];

      expect((await openSpace()).initials, 'L');

      github.accounts_ = <GithubAccountValueObject>[];
      await container.read(accountProvider.notifier).reload();

      expect(container.read(accountProvider).initials, isNull);
    },
  );

  test('Reload asks the machine again', () async {
    await openSpace();
    github.accounts_ = <GithubAccountValueObject>[ada];

    await container.read(accountProvider.notifier).reload();

    expect(container.read(accountProvider).summary?.chosen, ada);
  });

  test('choosing records it in the repository and reads again', () async {
    github.accounts_ = <GithubAccountValueObject>[ada, linus];
    await openSpace();

    await container.read(accountProvider.notifier).choose(linus);

    expect(git.recorded, 'linus');
    expect(container.read(accountProvider).summary?.chosen, linus);
  });

  test('the repository link opens its page in the browser', () async {
    await openSpace();

    await container.read(accountProvider.notifier).openRepository();

    expect(desktop.opened, <Uri>[Uri.parse('https://github.com/acme/docs')]);
  });

  test("a folder with no repository reads the machine's, as Home", () async {
    // No repository section, and the space's git never asked
    // (`docs/product/workspace/without-a-repository/doc.md`).
    github.accounts_ = <GithubAccountValueObject>[ada];
    container
      ..listen<AccountState>(accountProvider, (_, _) {})
      ..read(
        spaceSessionProvider.notifier,
      ).open(SpaceEntity(root: '/notes', repositoryRoot: null, name: 'notes'));
    await settle();

    final AccountState state = container.read(accountProvider);
    expect(state.isReading, isFalse);
    expect(state.summary?.identity.name, 'Ada at home');
    expect(state.summary?.project, isNull);
    expect(git.identityReads, 0);

    await container.read(accountProvider.notifier).choose(ada);
    expect(git.recorded, isNull, reason: 'there is no repository to record in');
  });

  test("leaving the space goes back to the machine's account", () async {
    github.accounts_ = <GithubAccountValueObject>[ada];
    await openSpace();

    container.read(spaceSessionProvider.notifier).close();
    await settle();

    final AccountState state = container.read(accountProvider);
    expect(state.summary?.chosen, isNull);
    expect(state.summary?.identity.name, 'Ada at home');
  });

  test('a reading the person refused keeps what the popover knew', () async {
    github.accounts_ = <GithubAccountValueObject>[ada];
    await openSpace();
    github.refuses = true;

    await container.read(accountProvider.notifier).reload();

    final AccountState state = container.read(accountProvider);
    expect(state.isReading, isFalse);
    expect(state.summary?.accounts, <GithubAccountValueObject>[ada]);
    expect(state.summary?.identity.name, 'Ada Lovelace');
  });

  test(
    'refused the first time, nothing is known and nothing is said',
    () async {
      github.refuses = true;

      final AccountState state = await openSpace();

      expect(state.isReading, isFalse);
      expect(state.summary, isNull);
      expect(state.local?.identity.name, 'Ada Lovelace', reason: "git's half");
    },
  );
}

/// Preferences that already hold [mode], nothing read from a store.
final class _Prefs extends PreferencesNotifier {
  _Prefs(this.mode);

  final GitApprovalModeEnum mode;

  @override
  PreferencesValueObject build() =>
      PreferencesValueObject.defaults.copyWith(gitApprovals: mode);

  @override
  Future<void> get loaded => Future<void>.value();
}

final class _Git implements GitRepository {
  String? name = 'Ada Lovelace';
  String? recorded;
  int identityReads = 0;

  @override
  Future<Result<CommitIdentityValueObject, GitFailure>> commitIdentity() async {
    identityReads++;
    return Success<CommitIdentityValueObject, GitFailure>(
      CommitIdentityValueObject(name: name, email: 'ada@x.org'),
    );
  }

  @override
  Future<Result<String?, GitFailure>> remoteAddress() async =>
      const Success<String?, GitFailure>('git@github.com:acme/docs.git');

  @override
  Future<Result<String?, GitFailure>> chosenAccount() async =>
      Success<String?, GitFailure>(recorded);

  @override
  Future<Result<void, GitFailure>> chooseAccount(String login) async {
    recorded = login;
    return const Success<void, GitFailure>(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _Accounts implements GithubAccountRepository {
  List<GithubAccountValueObject> accounts_ = <GithubAccountValueObject>[];

  /// Held until completed, as `gh` holds its answer while it asks GitHub.
  Completer<void>? gate;

  /// Whether the person says no to asking the machine's tools.
  bool refuses = false;

  @override
  Future<Result<List<GithubAccountValueObject>, AccountFailure>>
  accounts() async {
    await gate?.future;
    return refuses
        ? const Failure<List<GithubAccountValueObject>, AccountFailure>(
            AccountDenied(),
          )
        : Success<List<GithubAccountValueObject>, AccountFailure>(accounts_);
  }

  @override
  Future<Result<RepositoryAccessValueObject?, AccountFailure>> access(
    GithubAccountValueObject account,
    RemoteProjectValueObject project,
  ) async => const Success<RepositoryAccessValueObject?, AccountFailure>(null);
}

final class _Desktop implements DesktopRepository {
  final List<Uri> opened = <Uri>[];

  @override
  Future<Result<void, AppFailure>> openUrl(Uri address) async {
    opened.add(address);
    return const Success<void, AppFailure>(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
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
