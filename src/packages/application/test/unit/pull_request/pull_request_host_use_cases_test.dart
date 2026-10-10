/// Asking the host about the branch's pull request, and opening one: as
/// which account, and what each answer becomes.
library;

import 'package:test/test.dart';
import 'package:tom_application/tom_application.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_domain/tom_domain.dart';

void main() {
  late _Git git;
  late _Accounts github;
  late _Host host;
  late _RecordingObservability observability;

  final SpaceEntity docs = SpaceEntity(
    root: '/code/app/docs',
    repositoryRoot: '/code/app',
    name: 'docs',
  );
  final RemoteProjectValueObject project = RemoteProjectValueObject.tryParse(
    'https://github.com/acme/docs.git',
  )!;
  final BranchNameValueObject feature = BranchNameValueObject('feat/x');
  final BranchNameValueObject main = BranchNameValueObject('main');
  const GithubAccountValueObject ada = GithubAccountValueObject(
    login: 'ada',
    source: AccountSourceEnum.gh,
  );
  const GithubAccountValueObject grace = GithubAccountValueObject(
    login: 'grace',
    source: AccountSourceEnum.gh,
  );
  final OpenedPullRequestValueObject opened = OpenedPullRequestValueObject(
    number: 123,
    address: Uri.parse('https://github.com/acme/docs/pull/123'),
    title: 'Release notes',
  );

  setUp(() {
    git = _Git();
    github = _Accounts();
    host = _Host();
    observability = _RecordingObservability();
  });

  ReadOpenPullRequestUseCase reading() => ReadOpenPullRequestUseCase(
    gitFor: (SpaceEntity _) => git,
    accountsFor: (SpaceEntity _) => github,
    hostFor: (SpaceEntity _) => host,
    observability: observability,
  );

  CreatePullRequestUseCase creating() => CreatePullRequestUseCase(
    gitFor: (SpaceEntity _) => git,
    accountsFor: (SpaceEntity _) => github,
    hostFor: (SpaceEntity _) => host,
    observability: observability,
  );

  Future<Result<OpenedPullRequestValueObject, AppFailure>> create() =>
      creating().create(
        docs,
        project,
        base: main,
        head: feature,
        title: 'Release notes',
        body: 'Why it exists.',
      );

  group('the one already open', () {
    test('is asked as the account chosen for this repository', () async {
      github.accounts_ = <GithubAccountValueObject>[ada, grace];
      git.recorded = 'grace';
      host.open = opened;

      final Result<OpenedPullRequestValueObject?, AppFailure> read =
          await reading().read(docs, project, feature);

      expect(read.valueOrNull, opened);
      expect(host.asked, <String>['open grace feat/x']);
    });

    test('none is null, and that is an answer', () async {
      github.accounts_ = <GithubAccountValueObject>[ada];

      final Result<OpenedPullRequestValueObject?, AppFailure> read =
          await reading().read(docs, project, feature);

      expect(read, isA<Success<OpenedPullRequestValueObject?, AppFailure>>());
      expect(read.valueOrNull, isNull);
    });

    test('with no account there is nobody to ask as', () async {
      final Result<OpenedPullRequestValueObject?, AppFailure> read =
          await reading().read(docs, project, feature);

      expect(
        (read as Failure<OpenedPullRequestValueObject?, AppFailure>).failure,
        const PullRequestHostUnavailable(),
      );
      expect(host.asked, isEmpty);
    });

    test('what the host could not say is handed up as it was', () async {
      github.accounts_ = <GithubAccountValueObject>[ada];
      host.failure = const PullRequestHostUnreachable();

      final Result<OpenedPullRequestValueObject?, AppFailure> read =
          await reading().read(docs, project, feature);

      expect(
        (read as Failure<OpenedPullRequestValueObject?, AppFailure>).failure,
        const PullRequestHostUnreachable(),
      );
    });
  });

  group('opening one', () {
    test('creates it, then answers it as the host lists it', () async {
      github.accounts_ = <GithubAccountValueObject>[ada];
      host
        ..created = opened.copyWith(title: 'Release notes (draft)')
        ..open = opened;

      final Result<OpenedPullRequestValueObject, AppFailure> result =
          await create();

      expect(result.valueOrNull, opened);
      expect(host.asked, <String>[
        'create ada main feat/x Release notes Why it exists.',
        'open ada feat/x',
      ]);
    });

    test('a list that does not answer still leaves the one created', () async {
      github.accounts_ = <GithubAccountValueObject>[ada];
      host
        ..created = opened
        ..listFails = true;

      expect((await create()).valueOrNull, opened);
    });

    test('a refusal is handed up, and nothing is asked after it', () async {
      github.accounts_ = <GithubAccountValueObject>[ada];
      host.failure = const PullRequestHostOperationFailed();

      final Result<OpenedPullRequestValueObject, AppFailure> result =
          await create();

      expect(
        (result as Failure<OpenedPullRequestValueObject, AppFailure>).failure,
        isA<PullRequestHostOperationFailed>(),
      );
      expect(host.asked, hasLength(1));
    });

    test('with no account it is unavailable', () async {
      expect(
        (await create() as Failure<OpenedPullRequestValueObject, AppFailure>)
            .failure,
        isA<PullRequestHostUnavailable>(),
      );
    });

    test('asking who the person is, refused, is a refusal — never "no '
        'account", and the host is not reached', () async {
      github
        ..accounts_ = <GithubAccountValueObject>[ada]
        ..refuses = true;

      final AppFailure refused =
          (await create() as Failure<OpenedPullRequestValueObject, AppFailure>)
              .failure;

      expect(refused, isA<PullRequestHostDenied>());
      expect(refused.isDenial, isTrue);
      expect(host.asked, isEmpty);
      expect(
        (await reading().read(docs, project, feature)
                as Failure<OpenedPullRequestValueObject?, AppFailure>)
            .failure,
        isA<PullRequestHostDenied>(),
      );
    });

    test('the recorded choice refused is a refusal too', () async {
      github.accounts_ = <GithubAccountValueObject>[ada];
      git.refuses = true;

      expect(
        (await create() as Failure<OpenedPullRequestValueObject, AppFailure>)
            .failure,
        isA<PullRequestHostDenied>(),
      );
      expect(host.asked, isEmpty);
    });

    test('an exception is caught and reported, never thrown', () async {
      github.accounts_ = <GithubAccountValueObject>[ada];
      host.throws = true;

      final Result<OpenedPullRequestValueObject, AppFailure> result =
          await create();

      expect(
        (result as Failure<OpenedPullRequestValueObject, AppFailure>).failure,
        isA<UnexpectedFailure>(),
      );
      expect(observability.captured.single.layer, 'application');
    });
  });
}

/// Git, with a recorded choice of account.
final class _Git implements GitRepository {
  String? recorded;

  /// Whether the person says no to reading the choice.
  bool refuses = false;

  @override
  Future<Result<String?, GitFailure>> chosenAccount() async => refuses
      ? const Failure<String?, GitFailure>(GitCommandDenied())
      : Success<String?, GitFailure>(recorded);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// The machine's accounts; none may push, so the first is the fallback.
final class _Accounts implements GithubAccountRepository {
  List<GithubAccountValueObject> accounts_ = <GithubAccountValueObject>[];

  /// Whether the person says no to asking the machine's tools.
  bool refuses = false;

  @override
  Future<Result<List<GithubAccountValueObject>, AccountFailure>>
  accounts() async => refuses
      ? const Failure<List<GithubAccountValueObject>, AccountFailure>(
          AccountDenied(),
        )
      : Success<List<GithubAccountValueObject>, AccountFailure>(accounts_);

  @override
  Future<Result<RepositoryAccessValueObject?, AccountFailure>> access(
    GithubAccountValueObject account,
    RemoteProjectValueObject project,
  ) async => const Success<RepositoryAccessValueObject?, AccountFailure>(null);
}

/// The host, writing down each question.
final class _Host implements PullRequestHostRepository {
  OpenedPullRequestValueObject? open;
  OpenedPullRequestValueObject? created;
  PullRequestHostFailure? failure;
  bool listFails = false;
  bool throws = false;
  final List<String> asked = <String>[];

  @override
  Future<Result<OpenedPullRequestValueObject?, PullRequestHostFailure>>
  openFrom(
    GithubAccountValueObject account,
    RemoteProjectValueObject project,
    BranchNameValueObject head,
  ) async {
    asked.add('open ${account.login} ${head.value}');
    if (failure != null || listFails) {
      return Failure<OpenedPullRequestValueObject?, PullRequestHostFailure>(
        failure ?? const PullRequestHostUnreachable(),
      );
    }
    return Success<OpenedPullRequestValueObject?, PullRequestHostFailure>(open);
  }

  @override
  Future<Result<OpenedPullRequestValueObject, PullRequestHostFailure>> create(
    GithubAccountValueObject account,
    RemoteProjectValueObject project, {
    required BranchNameValueObject base,
    required BranchNameValueObject head,
    required String title,
    required String body,
  }) async {
    if (throws) {
      throw StateError('gh fell over');
    }
    asked.add(
      'create ${account.login} ${base.value} ${head.value} $title $body',
    );
    return failure == null
        ? Success<OpenedPullRequestValueObject, PullRequestHostFailure>(
            created!,
          )
        : Failure<OpenedPullRequestValueObject, PullRequestHostFailure>(
            failure!,
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
