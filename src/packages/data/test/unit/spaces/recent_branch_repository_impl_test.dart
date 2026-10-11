/// [RecentBranchRepositoryImpl] over a git client that answers on command.
library;

import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_infra/tom_infra.dart';

void main() {
  late _Git git;
  late _Observability observability;
  late RecentBranchRepositoryImpl repository;
  final RecentSpaceEntity recent = RecentSpaceEntity(
    root: '/code/docs',
    name: 'docs',
    lastOpened: DateTime.utc(2026, 10),
  );

  setUp(() {
    git = _Git();
    observability = _Observability();
    repository = RecentBranchRepositoryImpl(
      branches: RecentBranchDataSource(
        gitClientFor: (String folder) {
          git.folder = folder;
          return git;
        },
      ),
      observability: observability,
    );
  });

  Future<BranchNameValueObject?> branch() async =>
      (await repository.branchOf(recent)
              as Success<BranchNameValueObject?, Never>)
          .value;

  test('the branch is read in the remembered folder', () async {
    git.answer = const Success<String, GitClientFailure>('main');

    expect(await branch(), BranchNameValueObject('main'));
    expect(git.folder, '/code/docs');
  });

  test('a detached head is no branch', () async {
    git.answer = const Success<String, GitClientFailure>('');

    expect(await branch(), isNull);
  });

  test(
    'a folder that is no longer a repository is no branch, unrecorded',
    () async {
      git.answer = const Failure<String, GitClientFailure>(
        GitClientNotARepository('/code/docs'),
      );

      expect(await branch(), isNull);
      expect(observability.captured, isEmpty);
    },
  );

  test('a refusal at the gate is no branch, unrecorded', () async {
    git.answer = const Failure<String, GitClientFailure>(
      GitClientCommandDenied('git symbolic-ref'),
    );

    expect(await branch(), isNull);
    expect(observability.captured, isEmpty);
  });

  test('anything else git says is recorded and still no branch', () async {
    const GitClientFailure failure = GitClientCommandFailed('git x', 1, 'boom');
    git.answer = const Failure<String, GitClientFailure>(failure);

    expect(await branch(), isNull);
    expect(observability.captured, <Object>[failure]);
  });
}

final class _Git implements GitClient {
  String? folder;
  Result<String, GitClientFailure> answer =
      const Success<String, GitClientFailure>('');

  @override
  Future<Result<String, GitClientFailure>> currentBranch() async => answer;

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

final class _Observability implements Observability {
  final List<Object> captured = <Object>[];

  @override
  Future<void> capture(
    Object error,
    StackTrace stackTrace, {
    required String layer,
  }) async => captured.add(error);
}
