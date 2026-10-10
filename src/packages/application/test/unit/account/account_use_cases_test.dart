import 'package:test/test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  late _RecordingObservability observability;
  late _Git git;
  late _Accounts github;

  final SpaceEntity docs = SpaceEntity(
    root: '/code/app/docs',
    repositoryRoot: '/code/app',
    name: 'docs',
  );

  const GithubAccountValueObject ada = GithubAccountValueObject(
    login: 'ada',
    source: AccountSourceEnum.gh,
  );
  const GithubAccountValueObject grace = GithubAccountValueObject(
    login: 'grace',
    source: AccountSourceEnum.gh,
  );
  const GithubAccountValueObject linus = GithubAccountValueObject(
    login: 'linus',
    source: AccountSourceEnum.ssh,
  );

  final RepositoryAccessValueObject reads = RepositoryAccessValueObject.granted(
    pull: true,
    push: false,
    admin: false,
  );
  final RepositoryAccessValueObject writes =
      RepositoryAccessValueObject.granted(pull: true, push: true, admin: false);

  setUp(() {
    observability = _RecordingObservability();
    git = _Git();
    github = _Accounts();
  });

  late _Git machine;
  late _Accounts machineAccounts;

  setUp(() {
    machine = _Git()..recorded = 'grace';
    machineAccounts = _Accounts();
  });

  ReadAccountUseCase reading() => ReadAccountUseCase(
    gitFor: (SpaceEntity space) => git,
    accountsFor: (SpaceEntity space) => github,
    machineGit: machine,
    machineAccounts: machineAccounts,
    observability: observability,
  );

  group('with no space open', () {
    test("the machine's identity and accounts, and no repository", () async {
      machineAccounts
        ..accounts_ = <GithubAccountValueObject>[ada, grace]
        ..access_ = <String, RepositoryAccessValueObject?>{'ada': writes};

      final AccountSummaryValueObject summary = (await reading().read(
        null,
      )).valueOrNull!;

      expect(summary.identity.name, 'Ada Lovelace');
      // No repository: nothing recorded is read, no access is asked.
      expect(summary.chosen, ada);
      expect(summary.project, isNull);
      expect(summary.access, isNull);
      expect(machineAccounts.askedAbout, isEmpty);
      expect(github.askedAbout, isEmpty);
    });
  });

  Future<AccountSummaryValueObject> read() async =>
      (await reading().read(docs)).valueOrNull!;

  group('reading the account', () {
    test('with nothing on the machine, nothing is known', () async {
      final AccountSummaryValueObject summary = await read();

      expect(summary.accounts, isEmpty);
      expect(summary.chosen, isNull);
      expect(summary.access, isNull);
      expect(summary.project?.label, 'github.com/acme/docs');
      expect(summary.identity.name, 'Ada Lovelace');
    });

    test('a remote on another host is no repository to speak of', () async {
      git.address = 'git@gitlab.com:acme/docs.git';
      github.accounts_ = <GithubAccountValueObject>[ada];

      final AccountSummaryValueObject summary = await read();

      expect(summary.project, isNull);
      expect(summary.chosen, ada);
      expect(github.askedAbout, isEmpty);
    });

    test('the recorded choice wins, and only its access is asked', () async {
      github
        ..accounts_ = <GithubAccountValueObject>[ada, grace]
        ..access_ = <String, RepositoryAccessValueObject?>{
          'ada': writes,
          'grace': reads,
        };
      git.recorded = 'grace';

      final AccountSummaryValueObject summary = await read();

      expect(summary.chosen, grace);
      expect(summary.access, reads);
      expect(github.askedAbout, <String>['grace']);
    });

    test('without a choice, the first that may push is used', () async {
      github
        ..accounts_ = <GithubAccountValueObject>[ada, grace]
        ..access_ = <String, RepositoryAccessValueObject?>{
          'ada': reads,
          'grace': writes,
        };

      final AccountSummaryValueObject summary = await read();

      expect(summary.chosen, grace);
      expect(summary.access, writes);
      // Each account is asked once, the chosen one included.
      expect(github.askedAbout, <String>['ada', 'grace']);
    });

    test(
      'a choice the machine no longer holds falls back to the rule',
      () async {
        github.accounts_ = <GithubAccountValueObject>[ada];
        git.recorded = 'gone';

        expect((await read()).chosen, ada);
      },
    );

    test('without one that may push, the first is used', () async {
      github.accounts_ = <GithubAccountValueObject>[linus, ada];

      final AccountSummaryValueObject summary = await read();

      expect(summary.chosen, linus);
      expect(summary.access, isNull);
    });

    test('GitHub out of reach is nothing known, not a failure', () async {
      github
        ..accounts_ = <GithubAccountValueObject>[ada]
        ..unreachable = true;

      final Result<AccountSummaryValueObject, AppFailure> result =
          await reading().read(docs);

      expect(result.valueOrNull?.chosen, ada);
      expect(result.valueOrNull?.access, isNull);
    });

    test("git's half first: who commits and the project, no GitHub", () async {
      github.accounts_ = <GithubAccountValueObject>[ada];

      final AccountSummaryValueObject local = (await reading().readLocal(
        docs,
      )).valueOrNull!;

      expect(local.identity.name, 'Ada Lovelace');
      expect(local.project?.label, 'github.com/acme/docs');
      expect(local.accounts, isEmpty);
      expect(local.chosen, isNull);
      expect(github.askedAbout, isEmpty);
    });

    test("handed git's half, the reading does not ask git again", () async {
      github.accounts_ = <GithubAccountValueObject>[ada];
      final AccountSummaryValueObject local = (await reading().readLocal(
        docs,
      )).valueOrNull!;

      final AccountSummaryValueObject summary = (await reading().read(
        docs,
        local: local,
      )).valueOrNull!;

      expect(git.identityReads, 1);
      expect(summary.identity, local.identity);
      expect(summary.chosen, ada);
    });

    test('an exception never escapes the use case, and is reported', () async {
      github.throws = true;

      final Result<AccountSummaryValueObject, AppFailure> result =
          await reading().read(docs);

      expect(
        (result as Failure<AccountSummaryValueObject, AppFailure>).failure,
        isA<UnexpectedFailure>(),
      );
      expect(observability.captured.single.layer, 'application');
    });

    test('a question the person refused is a refusal, not "nothing is '
        'known", and nothing more is asked', () async {
      github
        ..accounts_ = <GithubAccountValueObject>[ada]
        ..refuses = true;

      final Result<AccountSummaryValueObject, AppFailure> result =
          await reading().read(docs);

      final AppFailure refused =
          (result as Failure<AccountSummaryValueObject, AppFailure>).failure;
      expect(refused, isA<AccountDenied>());
      expect(refused.isDenial, isTrue);
      expect(github.askedAbout, isEmpty);
      expect(observability.captured, isEmpty, reason: 'nothing went wrong');
    });

    test("git's half refused is a refusal too", () async {
      git.refuses = true;

      expect(
        (await reading().readLocal(docs)
                as Failure<AccountSummaryValueObject, AppFailure>)
            .failure,
        isA<AccountDenied>(),
      );
    });

    test('an access refused is one as well: the summary is not half '
        'answered', () async {
      github
        ..accounts_ = <GithubAccountValueObject>[ada]
        ..accessRefused = true;

      expect(
        (await reading().read(docs)
                as Failure<AccountSummaryValueObject, AppFailure>)
            .failure,
        isA<AccountDenied>(),
      );
    });
  });

  group('choosing an account', () {
    test('it is recorded in the repository', () async {
      final Result<void, AppFailure> result = await ChooseAccountUseCase(
        gitFor: (SpaceEntity space) => git,
        observability: observability,
      ).choose(docs, grace);

      expect(result, isA<Success<void, AppFailure>>());
      expect(git.recorded, 'grace');
    });
  });
}

/// Git, with an identity, a GitHub remote and a recorded choice.
final class _Git implements GitRepository {
  String? address = 'https://github.com/acme/docs.git';
  String? recorded;
  int identityReads = 0;

  /// Whether the person says no to reading who commits.
  bool refuses = false;

  @override
  Future<Result<CommitIdentityValueObject, GitFailure>> commitIdentity() async {
    identityReads++;
    if (refuses) {
      return const Failure<CommitIdentityValueObject, GitFailure>(
        GitCommandDenied(),
      );
    }
    return const Success<CommitIdentityValueObject, GitFailure>(
      CommitIdentityValueObject(name: 'Ada Lovelace', email: 'ada@x.org'),
    );
  }

  @override
  Future<Result<String?, GitFailure>> remoteAddress() async =>
      Success<String?, GitFailure>(address);

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

/// The machine's accounts, and what each may do.
final class _Accounts implements GithubAccountRepository {
  List<GithubAccountValueObject> accounts_ = <GithubAccountValueObject>[];
  Map<String, RepositoryAccessValueObject?> access_ =
      <String, RepositoryAccessValueObject?>{};
  bool unreachable = false;
  bool throws = false;

  /// Whether the person says no to listing the accounts, or to an access.
  bool refuses = false;
  bool accessRefused = false;
  final List<String> askedAbout = <String>[];

  @override
  Future<Result<List<GithubAccountValueObject>, AccountFailure>>
  accounts() async {
    if (throws) {
      throw StateError('gh fell over');
    }
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
  ) async {
    askedAbout.add(account.login);
    if (accessRefused) {
      return const Failure<RepositoryAccessValueObject?, AccountFailure>(
        AccountDenied(),
      );
    }
    return unreachable
        ? const Failure<RepositoryAccessValueObject?, AccountFailure>(
            AccountUnreachable(),
          )
        : Success<RepositoryAccessValueObject?, AccountFailure>(
            access_[account.login],
          );
  }
}

/// An [Observability] that keeps what it was handed.
final class _RecordingObservability implements Observability {
  final List<({Object error, StackTrace stackTrace, String layer})> captured =
      <({Object error, StackTrace stackTrace, String layer})>[];

  @override
  Future<void> capture(
    Object error,
    StackTrace stackTrace, {
    required String layer,
  }) async =>
      captured.add((error: error, stackTrace: stackTrace, layer: layer));
}
