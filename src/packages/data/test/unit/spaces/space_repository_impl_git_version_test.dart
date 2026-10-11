/// Opening a space over a git the product does not work on
/// (`docs/product/home/opening-a-space/doc.md`).
///
/// A unit test, because an older git cannot be provoked from a machine that
/// has a newer one; the version line is what a double says, and the rest of
/// opening is real.
library;

import 'dart:io';

import 'package:test/test.dart';
import 'package:tom_core/tom_core.dart';
import 'package:tom_data/tom_data.dart';
import 'package:tom_domain/tom_domain.dart';
import 'package:tom_infra/tom_infra.dart';

void main() {
  late Directory folder;

  setUp(() {
    folder = Directory.systemTemp.createTempSync('tom_git_version_');
    addTearDown(() => folder.deleteSync(recursive: true));
  });

  Future<Result<SpaceEntity, AppFailure>> open(_Git git) => SpaceRepositoryImpl(
    spaces: SpaceDataSource(
      filesystem: const DartIoFilesystemImpl(),
      gitClientFor: (String folder) => git,
    ),
  ).open(folder.path);

  test('an older git is refused, saying which one this machine has', () async {
    final _Git git = _Git(said: 'git version 2.39.2 (Apple Git-143)');

    final Result<SpaceEntity, AppFailure> opened = await open(git);

    expect(
      (opened as Failure<SpaceEntity, AppFailure>).failure,
      const GitTooOld('2.39.2'),
    );
    expect(git.askedForTheRoot, isFalse, reason: 'nothing else was asked');
  });

  test('git 2.41 itself is enough', () async {
    final Result<SpaceEntity, AppFailure> opened = await open(
      _Git(said: 'git version 2.41.0'),
    );

    expect(opened, isA<Success<SpaceEntity, AppFailure>>());
  });

  test('a machine with no git is the missing-git refusal', () async {
    final Result<SpaceEntity, AppFailure> opened = await open(
      _Git(failure: const GitClientExecutableNotFound()),
    );

    expect(
      (opened as Failure<SpaceEntity, AppFailure>).failure,
      isA<GitNotInstalled>(),
    );
  });

  test('a line nobody can read is no reason to refuse', () async {
    final Result<SpaceEntity, AppFailure> opened = await open(
      _Git(said: 'git, a version of some kind'),
    );

    expect(opened, isA<Success<SpaceEntity, AppFailure>>());
  });
}

/// A git that says [version] and is somewhere a repository is not.
final class _Git implements GitClient {
  _Git({this.said = '', this.failure});

  final String said;
  final GitClientFailure? failure;
  bool askedForTheRoot = false;

  @override
  Future<Result<String, GitClientFailure>> version() async {
    final GitClientFailure? refused = failure;
    return refused == null
        ? Success<String, GitClientFailure>(said)
        : Failure<String, GitClientFailure>(refused);
  }

  @override
  Future<Result<String, GitClientFailure>> repositoryRoot() async {
    askedForTheRoot = true;
    return const Failure<String, GitClientFailure>(
      GitClientNotARepository('/nowhere'),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
